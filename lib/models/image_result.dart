/// Resultado del procesamiento de UNA imagen del reporte (curación + detección).
class ImageResult {
  final String? qualityLabel;
  final bool dogDetected;
  final double? yoloConfidence;
  final String cropStatus;

  const ImageResult({
    required this.qualityLabel,
    required this.dogDetected,
    required this.yoloConfidence,
    required this.cropStatus,
  });

  factory ImageResult.fromJson(Map<String, dynamic> j) => ImageResult(
        qualityLabel: j['quality_label']?.toString(),
        dogDetected: j['dog_detected'] == true,
        yoloConfidence: (j['yolo_confidence'] is num) ? (j['yolo_confidence'] as num).toDouble() : null,
        cropStatus: (j['crop_status'] ?? 'pending').toString(),
      );
}
