/// Resultado del procesamiento de UNA imagen del reporte (curación + detección).
class ImageResult {
  final String? qualityLabel;
  final String? qualityFlags; // NB-01: "too_dark|very_blurry|..."
  final bool dogDetected;
  final double? yoloConfidence;
  final String cropStatus;
  final List<Map<String, dynamic>> otherDetections; // qué vio YOLO si no es perro

  const ImageResult({
    required this.qualityLabel,
    required this.qualityFlags,
    required this.dogDetected,
    required this.yoloConfidence,
    required this.cropStatus,
    required this.otherDetections,
  });

  factory ImageResult.fromJson(Map<String, dynamic> j) => ImageResult(
        qualityLabel: j['quality_label']?.toString(),
        qualityFlags: j['quality_flags']?.toString(),
        dogDetected: j['dog_detected'] == true,
        yoloConfidence: (j['yolo_confidence'] is num) ? (j['yolo_confidence'] as num).toDouble() : null,
        cropStatus: (j['crop_status'] ?? 'pending').toString(),
        otherDetections: (j['other_detections'] is List)
            ? (j['other_detections'] as List)
                .whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList()
            : const [],
      );

  // --- Validación 1: calidad de imagen (NB-01) ---
  static const _qualityBlockers = [
    'too_dark', 'too_bright', 'very_blurry', 'low_resolution', 'low_contrast', 'low_sharpness',
  ];

  List<String> get badQualityFlags =>
      _qualityBlockers.where((f) => (qualityFlags ?? '').contains(f)).toList();

  bool get hasQualityIssue => badQualityFlags.isNotEmpty;

  /// Texto legible de los problemas de calidad detectados.
  String get qualityIssueText {
    const es = {
      'too_dark': 'muy oscura',
      'too_bright': 'sobreexpuesta',
      'very_blurry': 'borrosa',
      'low_resolution': 'baja resolución',
      'low_contrast': 'bajo contraste',
      'low_sharpness': 'poco nítida',
    };
    return badQualityFlags.map((f) => es[f] ?? f).join(', ');
  }

  /// Lista legible de lo que YOLO identificó (cuando no es perro).
  String get sawText => otherDetections
      .map((d) => '${d['label']} ${(((d['conf'] ?? 0) as num) * 100).round()}%')
      .join(', ');
}
