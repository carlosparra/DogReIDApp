import 'package:flutter/material.dart';

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
    final candidates = result.candidates;
    return Scaffold(
      appBar: AppBar(title: Text(wasReport ? 'Respuesta del reporte' : 'Resultados de búsqueda')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _StatusBanner(result: result, detected: detected),
          const SizedBox(height: 16),
          if (!detected)
            _empty(
              context,
              icon: Icons.pets,
              title: 'No se detectó un perro',
              body: 'No pudimos detectar un perro en tus imágenes. Intenta con fotos más claras, '
                  'de cuerpo completo y bien iluminadas.',
            )
          else if (candidates.isEmpty)
            _empty(
              context,
              icon: Icons.search_off,
              title: 'Sin coincidencias por ahora',
              body: wasReport
                  ? 'Tu reporte quedó registrado. Te avisaremos si aparece una coincidencia.'
                  : 'No encontramos perros parecidos en la base. Intenta más tarde o con otra foto.',
            )
          else ...[
            Text(candidates.length == 1
                ? 'Mejor coincidencia'
                : 'Top ${candidates.length > 3 ? 3 : candidates.length} coincidencias',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...candidates.take(3).map((c) => CandidateCard(candidate: c)),
            if (candidates.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('+${candidates.length - 3} candidato(s) adicional(es) con menor coincidencia',
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
  final ReportResult result;
  final bool detected;
  const _StatusBanner({required this.result, required this.detected});

  @override
  Widget build(BuildContext context) {
    final hasHighConfidence =
        result.candidates.any((c) => c.matchDecision == 'found_high_confidence');
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
      text = '¡Posible coincidencia de alta confianza! Revisa los candidatos.';
    } else if (result.candidates.isNotEmpty) {
      color = Colors.orange.shade700;
      icon = Icons.info;
      text = 'Encontramos candidatos para revisión humana.';
    } else {
      color = Colors.blueGrey;
      icon = Icons.hourglass_empty;
      text = 'Sin coincidencias todavía.';
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
