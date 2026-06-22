/// Un candidato del ranking final (fila del NB-13) que la app muestra al usuario.
class Candidate {
  final String candidateGroupId; // dog_id
  final String? candidateReportId;
  final int candidateRank;
  final double visualScore;
  final double finalScore; // contextual NB-10 (== visual si no hay metadata)
  final double finalDogMatchScore; // ranking NB-13 (visual + contexto + pose)
  final String matchDecision; // found_high_confidence | possible_match_review | no_confirmed
  final String explanation;
  final int uniquePoseViewsCount;
  final bool crossPoseConsistent;
  final double? distanceKm;
  final double? dateDiffDays;
  final List<String> evidenceCrops;

  const Candidate({
    required this.candidateGroupId,
    required this.candidateReportId,
    required this.candidateRank,
    required this.visualScore,
    required this.finalScore,
    required this.finalDogMatchScore,
    required this.matchDecision,
    required this.explanation,
    required this.uniquePoseViewsCount,
    required this.crossPoseConsistent,
    required this.distanceKm,
    required this.dateDiffDays,
    required this.evidenceCrops,
  });

  factory Candidate.fromJson(Map<String, dynamic> j) {
    double d(dynamic v) => (v is num) ? v.toDouble() : 0.0;
    double? dn(dynamic v) => (v is num) ? v.toDouble() : null;
    return Candidate(
      candidateGroupId: (j['candidate_group_id'] ?? '—').toString(),
      candidateReportId: j['candidate_report_id']?.toString(),
      candidateRank: (j['candidate_rank'] is num) ? (j['candidate_rank'] as num).toInt() : 0,
      visualScore: d(j['visual_score']),
      finalScore: d(j['final_score']),
      finalDogMatchScore: d(j['final_dog_match_score']),
      matchDecision: (j['match_decision'] ?? 'no_confirmed').toString(),
      explanation: (j['explanation'] ?? '').toString(),
      uniquePoseViewsCount:
          (j['unique_pose_views_count'] is num) ? (j['unique_pose_views_count'] as num).toInt() : 0,
      crossPoseConsistent: j['cross_pose_consistent'] == true,
      distanceKm: dn(j['distance_km']),
      dateDiffDays: dn(j['date_diff_days']),
      evidenceCrops: (j['evidence_crops'] is List)
          ? (j['evidence_crops'] as List).map((e) => e.toString()).toList()
          : const [],
    );
  }

  /// Etiqueta legible de la decisión (NB-13) para el usuario.
  String get decisionLabel {
    switch (matchDecision) {
      case 'found_high_confidence':
        return 'Encontrado · alta confianza';
      case 'possible_match_review':
        return 'Posible coincidencia · revisar';
      case 'weak_match_review':
        return 'Coincidencia débil · revisar';
      case 'no_confirmed':
        return 'No confirmado';
      default:
        return matchDecision;
    }
  }
}
