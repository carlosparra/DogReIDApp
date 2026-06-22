import 'candidate.dart';
import 'image_result.dart';

/// Respuesta del backend (contrato `ReportResult` de dogreid/schemas.py).
/// Es LA RESPUESTA que el cliente recibe sobre su perro.
class ReportResult {
  final String reportId;
  final String reportType; // lost | found
  final String status; // received | searching | done | no_dog_detected | ...
  final List<ImageResult> images;
  final List<Candidate> candidates;

  const ReportResult({
    required this.reportId,
    required this.reportType,
    required this.status,
    required this.images,
    required this.candidates,
  });

  bool get anyDogDetected => images.any((i) => i.dogDetected);
  bool get isTerminal => status == 'done' || status == 'no_dog_detected';

  factory ReportResult.fromJson(Map<String, dynamic> j) => ReportResult(
        reportId: (j['report_id'] ?? '—').toString(),
        reportType: (j['report_type'] ?? 'lost').toString(),
        status: (j['status'] ?? 'unknown').toString(),
        images: (j['images'] is List)
            ? (j['images'] as List)
                .map((e) => ImageResult.fromJson(Map<String, dynamic>.from(e as Map)))
                .toList()
            : const [],
        candidates: (j['candidates'] is List)
            ? (j['candidates'] as List)
                .map((e) => Candidate.fromJson(Map<String, dynamic>.from(e as Map)))
                .toList()
            : const [],
      );
}
