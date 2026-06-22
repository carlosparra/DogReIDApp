// Smoke test de integración: ejecuta el MISMO ApiClient de la app contra un
// backend DogReID real y muestra la respuesta. No necesita GUI ni browser.
//
// Uso (con el backend local levantado en :8080):
//   dart run tool/smoke_search.dart [ruta_imagen] [lost|found]
//
// Por defecto usa la query del repo backend y report_type=lost.
import 'dart:io';

import 'package:dogreidapp/config/environment.dart';
import 'package:dogreidapp/models/picked_image.dart';
import 'package:dogreidapp/models/report_metadata.dart';
import 'package:dogreidapp/services/api_client.dart';

Future<void> main(List<String> args) async {
  final imgPath = args.isNotEmpty
      ? args[0]
      : '/Users/carlosparra/github/DogReID/local/data/queries/perdido1.jpg';
  final reportType = args.length > 1 ? args[1] : 'lost';

  final bytes = await File(imgPath).readAsBytes();
  final api = ApiClient(Environment.local); // http://localhost:8080

  stdout.writeln('Backend : ${Environment.local.searchBaseUrl}');
  stdout.writeln('Query   : $imgPath  (report_type=$reportType)\n');

  try {
    final r = await api.search(
      reportType: reportType,
      images: [PickedImage(bytes: bytes, name: 'query.jpg')],
      metadata: const ReportMetadata(
        color: 'brown',
        size: 'medium',
        collar: 'red',
        latitude: 25.6866,
        longitude: -100.3161,
        reportDate: '2026-06-21',
      ),
    );

    stdout.writeln('status: ${r.status}  ·  perro detectado: ${r.anyDogDetected}');
    for (final im in r.images) {
      stdout.writeln('  imagen: calidad=${im.qualityLabel} '
          'yolo=${im.yoloConfidence?.toStringAsFixed(2)} estado=${im.cropStatus}');
    }
    stdout.writeln('\ncandidatos: ${r.candidates.length}');
    for (final c in r.candidates.take(8)) {
      stdout.writeln('  #${c.candidateRank}  ${c.candidateGroupId}  '
          'visual=${(c.visualScore * 100).toStringAsFixed(1)}%  '
          'match=${(c.finalDogMatchScore * 100).toStringAsFixed(1)}%  '
          '-> ${c.decisionLabel}');
    }
    if (r.candidates.isNotEmpty) {
      stdout.writeln('\nMejor: ${r.candidates.first.candidateGroupId}');
      stdout.writeln('  ${r.candidates.first.explanation}');
    }
    stdout.writeln('\n✅ La app habló con el backend y parseó la respuesta correctamente.');
  } catch (e) {
    stderr.writeln('❌ Error: $e');
    exitCode = 1;
  } finally {
    api.close();
  }
}
