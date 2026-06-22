import 'package:flutter/material.dart';

import '../models/candidate.dart';
import '../models/report_result.dart';
import '../widgets/candidate_card.dart';

/// Pantalla de RESPUESTA al cliente: muestra el estado del procesamiento de sus
/// imágenes y el ranking de perros candidatos (o el motivo si no hay).
class ResultsScreen extends StatelessWidget {
  final ReportResult result;
  final bool wasReport;
  const ResultsScreen({super.key, required this.result, this.wasReport = false});

  @override
  Widget build(BuildContext context) {
    final detected = result.anyDogDetected;
    // Solo se muestran coincidencias >= 87% (alta confianza o revisión).
    // Las < 87% (no_confirmed) no son coincidencia y no ocupan ayuda humana.
    final matches = result.candidates.where((c) => c.isActionable).toList();
    final shown = matches.take(3).toList();
    return Scaffold(
      appBar: AppBar(title: Text(wasReport ? 'Respuesta del reporte' : 'Resultados de búsqueda')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _StatusBanner(detected: detected, matches: matches),
          const SizedBox(height: 16),
          if (!detected)
            _empty(
              context,
              icon: Icons.pets,
              title: 'No se detectó un perro',
              body: 'No pudimos detectar un perro en tus imágenes. Intenta con fotos más claras, '
                  'de cuerpo completo y bien iluminadas.',
            )
          else if (matches.isEmpty)
            _empty(
              context,
              icon: Icons.search_off,
              title: 'Sin coincidencias',
              body: wasReport
                  ? 'Ningún candidato supera el 87% de similitud. Tu reporte quedó registrado; '
                      'te avisaremos si aparece una coincidencia.'
                  : 'Ningún candidato supera el 87% de similitud, así que no hay coincidencias '
                      'que confirmar. Intenta más tarde o con otra foto.',
            )
          else ...[
            Text(shown.length == 1 ? 'Mejor coincidencia' : 'Top ${shown.length} coincidencias',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...shown.map((c) => CandidateCard(candidate: c)),
            if (matches.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('+${matches.length - 3} coincidencia(s) adicional(es) ≥ 87%',
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ),
          ],
          const SizedBox(height: 24),
          Center(
            child: Text('Reporte: ${result.reportId} · estado: ${result.status}',
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _empty(BuildContext context, {required IconData icon, required String title, required String body}) {
    return Column(
      children: [
        const SizedBox(height: 24),
        Icon(icon, size: 64, color: Colors.grey),
        const SizedBox(height: 12),
        Text(title, style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(body, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final bool detected;
  final List<Candidate> matches; // ya filtradas a >= 85%
  const _StatusBanner({required this.detected, required this.matches});

  @override
  Widget build(BuildContext context) {
    final hasHighConfidence =
        matches.any((c) => c.matchDecision == 'found_high_confidence');
    final Color color;
    final IconData icon;
    final String text;
    if (!detected) {
      color = Colors.grey;
      icon = Icons.help_outline;
      text = 'Procesamos tus imágenes pero no detectamos un perro.';
    } else if (hasHighConfidence) {
      color = Colors.green.shade600;
      icon = Icons.check_circle;
      text = '¡Coincidencia de alta confianza (≥90%)! Revisa y confirma.';
    } else if (matches.isNotEmpty) {
      color = Colors.orange.shade700;
      icon = Icons.info;
      text = 'Posible(s) coincidencia(s) entre 87% y 89%: requieren revisión humana.';
    } else {
      color = Colors.blueGrey;
      icon = Icons.search_off;
      text = 'Sin coincidencias ≥87%: no hay nada que confirmar.';
    }
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}
