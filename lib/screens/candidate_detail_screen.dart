import 'package:flutter/material.dart';

import '../config/app_settings.dart';
import '../models/candidate.dart';

/// Detalle de una coincidencia: muestra la(s) imagen(es) COMPLETAS del perro
/// candidato (sin recortar, con zoom) más el score y la explicación.
/// Se abre al tocar una tarjeta de candidato.
class CandidateDetailScreen extends StatelessWidget {
  final Candidate candidate;
  const CandidateDetailScreen({super.key, required this.candidate});

  @override
  Widget build(BuildContext context) {
    final urls = candidate.evidenceUrls(appSettings.env.searchBaseUrl);
    return Scaffold(
      appBar: AppBar(title: Text(candidate.candidateGroupId)),
      body: ListView(
        children: [
          if (urls.isNotEmpty)
            _FullImageGallery(urls: urls)
          else
            Container(
              height: 160,
              color: Colors.black12,
              alignment: Alignment.center,
              child: const Text('Sin imagen disponible para este candidato',
                  style: TextStyle(color: Colors.grey)),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(candidate.decisionLabel,
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _Metric(label: 'Similitud visual', value: '${(candidate.visualScore * 100).toStringAsFixed(1)}%'),
                    const SizedBox(width: 24),
                    _Metric(label: 'Match', value: '${(candidate.finalDogMatchScore * 100).toStringAsFixed(1)}%'),
                  ],
                ),
                const SizedBox(height: 16),
                Text(candidate.explanation, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    if (candidate.crossPoseConsistent)
                      const Chip(avatar: Icon(Icons.threed_rotation, size: 16), label: Text('Varias poses')),
                    Chip(avatar: const Icon(Icons.visibility, size: 16), label: Text('${candidate.uniquePoseViewsCount} vistas')),
                    if (candidate.distanceKm != null)
                      Chip(avatar: const Icon(Icons.place, size: 16), label: Text('${candidate.distanceKm!.toStringAsFixed(1)} km')),
                    if (candidate.dateDiffDays != null)
                      Chip(avatar: const Icon(Icons.event, size: 16), label: Text('${candidate.dateDiffDays!.toStringAsFixed(0)} días')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Galería de imágenes completas (BoxFit.contain) deslizable + zoom (pinch).
class _FullImageGallery extends StatefulWidget {
  final List<String> urls;
  const _FullImageGallery({required this.urls});

  @override
  State<_FullImageGallery> createState() => _FullImageGalleryState();
}

class _FullImageGalleryState extends State<_FullImageGallery> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.black,
          height: 380,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.urls.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) => InteractiveViewer(
              minScale: 1,
              maxScale: 5,
              child: Image.network(
                widget.urls[i],
                fit: BoxFit.contain, // imagen COMPLETA, sin recortar
                loadingBuilder: (c, child, p) => p == null
                    ? child
                    : const Center(child: CircularProgressIndicator()),
                errorBuilder: (c, e, s) => const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image, color: Colors.white54, size: 40),
                      SizedBox(height: 8),
                      Text('No se pudo cargar la imagen',
                          style: TextStyle(color: Colors.white54)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (widget.urls.length > 1)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.urls.length, (i) {
                final active = i == _page;
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: active ? Theme.of(context).colorScheme.primary : Colors.grey.shade400,
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}
