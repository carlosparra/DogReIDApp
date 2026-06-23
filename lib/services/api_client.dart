import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/environment.dart';
import '../models/picked_image.dart';
import '../models/report_metadata.dart';
import '../models/report_result.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

/// Cliente del backend DogReID. Una sola clase sirve para LOCAL y GCP: cambia el
/// comportamiento según el [Environment] (URLs + [ReportMode]).
///
/// Garantía de producto: ambos flujos devuelven un [ReportResult] —> el cliente
/// SIEMPRE recibe respuesta sobre su perro (candidatos + decisión).
class ApiClient {
  final Environment env;
  final http.Client _http;

  ApiClient(this.env, {http.Client? client}) : _http = client ?? http.Client();

  // --------------------------------------------------------------------------
  // BÚSQUEDA — síncrona. POST /v1/search (local app.py o inference de GCP).
  // --------------------------------------------------------------------------
  Future<ReportResult> search({
    required String reportType,
    required List<PickedImage> images,
    required ReportMetadata metadata,
  }) async {
    _assertImages(images);
    final uri = Uri.parse('${env.searchBaseUrl}/v1/search');
    final body = jsonEncode({
      'report_type': reportType,
      'images_b64': images.map((i) => base64Encode(i.bytes)).toList(),
      'metadata': metadata.toJson(),
    });
    final resp = await _post(uri, body);
    return ReportResult.fromJson(_decodeMap(resp));
  }

  // --------------------------------------------------------------------------
  // REPORTE — según el modo del entorno. Siempre termina devolviendo la
  // respuesta (candidatos) para el cliente, haciendo polling si es asíncrono.
  // --------------------------------------------------------------------------
  Future<ReportResult> report({
    required String reportType,
    required List<PickedImage> images,
    required ReportMetadata metadata,
    void Function(String status)? onStatus,
  }) async {
    _assertImages(images);
    switch (env.reportMode) {
      case ReportMode.searchFallback:
        // Backend local actual: no persiste; reutilizamos la búsqueda para que
        // el cliente igualmente reciba posibles coincidencias de su perro.
        onStatus?.call('buscando');
        return search(reportType: reportType, images: images, metadata: metadata);

      case ReportMode.directBase64:
        return _reportDirectBase64(reportType, images, metadata, onStatus);

      case ReportMode.signedUrl:
        return _reportSignedUrl(reportType, images, metadata, onStatus);
    }
  }

  // --- GCP: signed URLs + polling ------------------------------------------
  Future<ReportResult> _reportSignedUrl(
    String reportType,
    List<PickedImage> images,
    ReportMetadata metadata,
    void Function(String)? onStatus,
  ) async {
    final ingest = _ingestBaseOrThrow();
    onStatus?.call('creando reporte');
    final created = _decodeMap(await _post(
      Uri.parse('$ingest/v1/reports'),
      jsonEncode({
        'report_type': reportType,
        'metadata': metadata.toJson(),
        'image_count': images.length,
      }),
    ));
    final reportId = (created['report_id'] ?? '').toString();
    final urls = (created['upload_urls'] as List?)?.map((e) => e.toString()).toList() ?? [];
    if (reportId.isEmpty || urls.length < images.length) {
      throw ApiException('Respuesta de /v1/reports incompleta.');
    }

    onStatus?.call('subiendo imágenes');
    for (var i = 0; i < images.length; i++) {
      final put = await _http.put(
        Uri.parse(urls[i]),
        headers: {'Content-Type': 'image/jpeg'},
        body: images[i].bytes,
      );
      if (put.statusCode >= 300) {
        throw ApiException('Falló la subida de la imagen ${i + 1} (HTTP ${put.statusCode}).');
      }
    }

    // El procesamiento es asíncrono (Eventarc -> inference). Hacemos polling
    // hasta tener la respuesta del perro.
    return _pollReport(ingest, reportId, onStatus);
  }

  // --- Servidor local extendido: POST /v1/reports con base64 ----------------
  Future<ReportResult> _reportDirectBase64(
    String reportType,
    List<PickedImage> images,
    ReportMetadata metadata,
    void Function(String)? onStatus,
  ) async {
    final ingest = _ingestBaseOrThrow();
    onStatus?.call('enviando reporte');
    final resp = _decodeMap(await _post(
      Uri.parse('$ingest/v1/reports'),
      jsonEncode({
        'report_type': reportType,
        'metadata': metadata.toJson(),
        'images_b64': images.map((i) => base64Encode(i.bytes)).toList(),
      }),
    ));
    // El backend puede responder ya con el ReportResult, o con {report_id} a polear.
    if (resp.containsKey('candidates') || resp.containsKey('status')) {
      final r = ReportResult.fromJson(resp);
      if (r.isTerminal) return r;
    }
    final reportId = (resp['report_id'] ?? '').toString();
    if (reportId.isEmpty) return ReportResult.fromJson(resp);
    return _pollReport(ingest, reportId, onStatus);
  }

  // --- Polling de GET /v1/reports/{id} -------------------------------------
  Future<ReportResult> _pollReport(
    String ingest,
    String reportId,
    void Function(String)? onStatus,
  ) async {
    const interval = Duration(seconds: 3);
    const maxAttempts = 30; // ~90s
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      await Future.delayed(interval);
      try {
        final resp = await _http.get(Uri.parse('$ingest/v1/reports/$reportId'), headers: _ngrok);
        if (resp.statusCode == 200) {
          final r = ReportResult.fromJson(_decodeMap(resp.body));
          onStatus?.call(r.status);
          if (r.isTerminal) return r;
        }
      } catch (_) {
        // reintenta hasta agotar maxAttempts
      }
    }
    throw ApiException(
        'El reporte $reportId sigue procesándose. Intenta consultarlo más tarde.');
  }

  // --------------------------------------------------------------------------
  // Helpers
  // --------------------------------------------------------------------------
  String _ingestBaseOrThrow() {
    final base = env.ingestBaseUrl;
    if (base == null || base.isEmpty) {
      throw ApiException(
          'Este entorno no tiene servicio de ingesta (/v1/reports). Configúralo en Ajustes.');
    }
    return base;
  }

  void _assertImages(List<PickedImage> images) {
    if (images.isEmpty) throw ApiException('Sube al menos 1 imagen.');
    if (images.length > 5) throw ApiException('Máximo 5 imágenes.');
  }

  // Header para que ngrok (free) no devuelva su página de advertencia.
  static const Map<String, String> _ngrok = {'ngrok-skip-browser-warning': 'true'};

  Future<String> _post(Uri uri, String body) async {
    late http.Response resp;
    try {
      resp = await _http
          .post(uri,
              headers: {'Content-Type': 'application/json', ..._ngrok}, body: body)
          .timeout(const Duration(seconds: 60));
    } on TimeoutException {
      throw ApiException('Tiempo de espera agotado conectando a $uri.');
    } catch (e) {
      throw ApiException('No se pudo conectar a $uri. ¿Backend levantado?\n$e');
    }
    if (resp.statusCode >= 300) {
      throw ApiException('El servidor respondió HTTP ${resp.statusCode}: ${resp.body}');
    }
    return resp.body;
  }

  Map<String, dynamic> _decodeMap(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map) throw ApiException('Respuesta inesperada del servidor.');
    return Map<String, dynamic>.from(decoded);
  }

  void close() => _http.close();
}
