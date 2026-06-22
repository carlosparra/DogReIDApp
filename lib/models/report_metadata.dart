/// Metadata contextual del reporte (NB-10). Todos los campos son opcionales;
/// el backend usa lo que esté disponible y neutraliza lo que falte.
class ReportMetadata {
  final double? latitude;
  final double? longitude;
  final String? reportDate; // ISO YYYY-MM-DD
  final String? color;
  final String? size;
  final String? collar;
  final String? description;

  const ReportMetadata({
    this.latitude,
    this.longitude,
    this.reportDate,
    this.color,
    this.size,
    this.collar,
    this.description,
  });

  /// Solo incluye las claves con valor (el backend trata ausencia como "desconocido").
  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{};
    if (latitude != null) m['latitude'] = latitude;
    if (longitude != null) m['longitude'] = longitude;
    if (reportDate != null && reportDate!.isNotEmpty) m['report_date'] = reportDate;
    if (color != null && color!.isNotEmpty) m['color'] = color;
    if (size != null && size!.isNotEmpty) m['size'] = size;
    if (collar != null && collar!.isNotEmpty) m['collar'] = collar;
    if (description != null && description!.isNotEmpty) m['description'] = description;
    return m;
  }
}
