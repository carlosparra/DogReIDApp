import 'package:flutter/material.dart';

import '../models/candidate.dart';
import '../models/report_result.dart';
import '../widgets/candidate_card.dart';

/// Pantalla de RESPUESTA al cliente. Tres niveles de confianza:
///  - >= 82%  : coincidencias mostradas normalmente (hasta 3).
///  - 50-81%  : INCIERTO -> se muestra SOLO el más parecido, con aviso honesto
///              ("podría no ser tu perro"), cuidando la credibilidad.
///  - < 50%   : no se muestra nada.
class ResultsScreen extends StatelessWidget {
  final ReportResult result;
  final bool wasReport;
  const ResultsScreen({super.key, required this.result, this.wasReport = false});

  @override
  Widget build(BuildContext context) {
    final detected = result.anyDogDetected;
    final confident = result.candidates.where((c) => c.isActionable).toList();

    // Si no hay coincidencia segura, el más parecido de la banda incierta (50-81%).
    Candidate? tentativeTop;
    if (confident.isEmpty) {
      final t = result.candidates.where((c) => c.isTentative).toList()
        ..sort((a, b) => b.visualScore.compareTo(a.visualScore));
      if (t.isNotEmpty) tentativeTop = t.first;
    }

    return Scaffold(
      appBar: AppBar(title: Text(wasReport ? 'Respuesta del reporte' : 'Resultados de búsqueda')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _StatusBanner(detected: detected, confident: confident, tentative: tentativeTop),
          const SizedBox(height: 16),
          if (!detected)
            _empty(context,
                icon: Icons.pets,
                title: 'No se detectó un perro',
                body: 'No pudimos detectar un perro en tus imágenes. Intenta con fotos más '
                    'claras, de cuerpo completo y bien iluminadas.')
          else if (confident.isNotEmpty) ...[
            Text(confident.length == 1 ? 'Mejor coincidencia' : 'Top ${confident.length > 3 ? 3 : confident.length} coincidencias',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...confident.take(3).map((c) => CandidateCard(candidate: c)),
            if (confident.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('+${confident.length - 3} coincidencia(s) adicional(es) ≥ 82%',
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ),
          ] else if (tentativeTop != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.shade700),
              ),
              child: const Text(
                'No encontramos una coincidencia segura. Te mostramos el perro más '
                'parecido por si acaso — pero podría NO ser tu perro. Compáralo tú con '
                'la foto y, si tienes más fotos, repórtalo/búscalo con varias para mejorar.',
                style: TextStyle(fontSize: 13),
              ),
            ),
            CandidateCard(candidate: tentativeTop),
          ] else
            _empty(context,
                icon: Icons.search_off,
                title: 'Sin coincidencias',
                body: wasReport
                    ? 'No hay un perro parecido (≥50%) en la base. Tu reporte quedó '
                        'registrado; te avisaremos si aparece una coincidencia.'
                    : 'No hay un perro lo bastante parecido en la base. Intenta con otra '
                        'foto o más tarde.'),
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
  final List<Candidate> confident; // >= 82%
  final Candidate? tentative; // 50-81% (solo el más parecido)
  const _StatusBanner({required this.detected, required this.confident, this.tentative});

  @override
  Widget build(BuildContext context) {
    final hasHighConfidence = confident.any((c) => c.matchDecision == 'found_high_confidence');
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
    } else if (confident.isNotEmpty) {
      color = Colors.orange.shade700;
      icon = Icons.info;
      text = 'Posible(s) coincidencia(s) entre 82% y 89%: requieren revisión humana.';
    } else if (tentative != null) {
      color = Colors.amber.shade800;
      icon = Icons.help_outline;
      text = 'Sin coincidencia segura. Te mostramos el más parecido por si acaso (puede no ser).';
    } else {
      color = Colors.blueGrey;
      icon = Icons.search_off;
      text = 'Sin coincidencias: no hay nada que confirmar.';
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
