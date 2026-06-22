import 'package:flutter/material.dart';

import '../models/candidate.dart';

/// Tarjeta de un candidato (perro) con su score y decisión — la "respuesta"
/// que recibe el cliente sobre su perro.
class CandidateCard extends StatelessWidget {
  final Candidate candidate;
  const CandidateCard({super.key, required this.candidate});

  Color _decisionColor(BuildContext context) {
    switch (candidate.matchDecision) {
      case 'found_high_confidence':
        return Colors.green.shade600;
      case 'possible_match_review':
        return Colors.orange.shade700;
      case 'weak_match_review':
        return Colors.amber.shade700;
      default:
        return Colors.grey.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _decisionColor(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.15),
                  child: Text('#${candidate.candidateRank}', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(candidate.candidateGroupId,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                        child: Text(candidate.decisionLabel, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${(candidate.finalScore * 100).toStringAsFixed(1)}%',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
                    Text('visual ${(candidate.visualScore * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(candidate.explanation, style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (candidate.crossPoseConsistent)
                  const _Chip(icon: Icons.threed_rotation, label: 'Varias poses'),
                _Chip(icon: Icons.visibility, label: '${candidate.uniquePoseViewsCount} vistas'),
                if (candidate.distanceKm != null)
                  _Chip(icon: Icons.place, label: '${candidate.distanceKm!.toStringAsFixed(1)} km'),
                if (candidate.dateDiffDays != null)
                  _Chip(icon: Icons.event, label: '${candidate.dateDiffDays!.toStringAsFixed(0)} días'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Chip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      visualDensity: VisualDensity.compact,
      avatar: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
}
