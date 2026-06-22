/// Entorno de backend: define CONTRA QUÉ corre la app (local o GCP).
///
/// La app habla dos contratos del proyecto DogReID:
///   - búsqueda:  POST {searchBaseUrl}/v1/search   (síncrono, devuelve candidatos)
///   - reporte:   según [reportMode] (ver abajo)
///
/// El cliente SIEMPRE recibe respuesta sobre su perro: en búsqueda es inmediata;
/// en reporte GCP la app hace polling de GET {ingestBaseUrl}/v1/reports/{id}
/// hasta que el estado sea `done` / `no_dog_detected`.
enum ReportMode {
  /// GCP: POST /v1/reports -> {report_id, upload_urls}; se suben las imágenes
  /// con PUT a las signed URLs; luego se hace polling del resultado.
  signedUrl,

  /// Servidor local extendido: POST /v1/reports con images_b64 (sin signed URLs).
  directBase64,

  /// Local actual (local/app.py solo tiene /v1/search): "reportar" reutiliza
  /// la búsqueda para devolver coincidencias (no persiste en galería).
  searchFallback,
}

class Environment {
  final String id;
  final String name;

  /// Base del servicio con `/v1/search` (local app.py o inference de GCP).
  final String searchBaseUrl;

  /// Base del servicio de ingesta con `/v1/reports` (API de GCP). Puede ser
  /// igual a searchBaseUrl o null si el entorno no soporta ingesta.
  final String? ingestBaseUrl;

  final ReportMode reportMode;

  const Environment({
    required this.id,
    required this.name,
    required this.searchBaseUrl,
    required this.ingestBaseUrl,
    required this.reportMode,
  });

  Environment copyWith({
    String? name,
    String? searchBaseUrl,
    String? ingestBaseUrl,
    ReportMode? reportMode,
  }) {
    return Environment(
      id: id,
      name: name ?? this.name,
      searchBaseUrl: searchBaseUrl ?? this.searchBaseUrl,
      ingestBaseUrl: ingestBaseUrl ?? this.ingestBaseUrl,
      reportMode: reportMode ?? this.reportMode,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'searchBaseUrl': searchBaseUrl,
        'ingestBaseUrl': ingestBaseUrl,
        'reportMode': reportMode.name,
      };

  factory Environment.fromJson(Map<String, dynamic> j) => Environment(
        id: j['id'] as String,
        name: j['name'] as String,
        searchBaseUrl: j['searchBaseUrl'] as String,
        ingestBaseUrl: j['ingestBaseUrl'] as String?,
        reportMode: ReportMode.values
            .firstWhere((m) => m.name == j['reportMode'], orElse: () => ReportMode.searchFallback),
      );

  /// Presets por defecto. Edítalos en la pantalla de Ajustes en tiempo de ejecución.
  ///
  /// Nota Android emulador: `localhost` del host es `10.0.2.2` dentro del emulador.
  static const Environment local = Environment(
    id: 'local',
    name: 'Local (localhost:8080)',
    searchBaseUrl: 'http://localhost:8080',
    ingestBaseUrl: 'http://localhost:8080',  // reporte real persiste en la galería
    reportMode: ReportMode.directBase64,
  );

  static const Environment localAndroid = Environment(
    id: 'local_android',
    name: 'Local (emulador Android 10.0.2.2)',
    searchBaseUrl: 'http://10.0.2.2:8080',
    ingestBaseUrl: 'http://10.0.2.2:8080',
    reportMode: ReportMode.directBase64,
  );

  static const Environment gcp = Environment(
    id: 'gcp',
    name: 'GCP (Cloud Run)',
    // Reemplaza por las URLs reales de tus servicios Cloud Run.
    searchBaseUrl: 'https://dogreid-inference-XXXX.run.app',
    ingestBaseUrl: 'https://dogreid-api-XXXX.run.app',
    reportMode: ReportMode.signedUrl,
  );

  static const List<Environment> presets = [local, localAndroid, gcp];
}
