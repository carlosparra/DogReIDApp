import 'package:flutter/material.dart';

import '../config/app_settings.dart';
import 'capture_screen.dart';
import 'settings_screen.dart';

/// Pantalla principal: dos acciones grandes (Buscar / Reportar) + Ajustes.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DogReID'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            Icon(Icons.pets, size: 72, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text('Encuentra a tu perro',
                textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            const Text(
              'Sube de 1 a 5 fotos para buscar coincidencias o reportar un perro '
              'perdido/encontrado. Recibirás una respuesta con los candidatos.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 36),
            _BigButton(
              icon: Icons.search,
              title: 'Buscar',
              subtitle: 'Tengo fotos de un perro y quiero ver coincidencias',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CaptureScreen(isReport: false)),
              ),
            ),
            const SizedBox(height: 16),
            _BigButton(
              icon: Icons.add_a_photo,
              title: 'Reportar',
              subtitle: 'Registrar un perro perdido o encontrado',
              filled: true,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CaptureScreen(isReport: true)),
              ),
            ),
            const Spacer(),
            ListenableBuilder(
              listenable: appSettings,
              builder: (_, __) => Center(
                child: Text('Backend: ${appSettings.env.name}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BigButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool filled;
  final VoidCallback onTap;
  const _BigButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = filled ? scheme.primaryContainer : scheme.surfaceContainerHighest;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(icon, size: 36, color: scheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
