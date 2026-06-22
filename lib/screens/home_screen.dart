import 'package:flutter/material.dart';

import '../config/app_settings.dart';
import 'capture_screen.dart';
import 'settings_screen.dart';

/// Home minimal premium: hero limpio + dos acciones claras.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: scheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.pets, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Text('DogReID'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            const SizedBox(height: 12),
            Text('Reencuentra a\ntu compañero',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                  letterSpacing: -0.5,
                )),
            const SizedBox(height: 12),
            Text(
              'Sube de 1 a 5 fotos para buscar coincidencias o reportar un perro '
              'perdido o encontrado. Recibirás candidatos con evidencia visual.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 28),
            _ActionCard(
              icon: Icons.search_rounded,
              title: 'Buscar',
              subtitle: 'Tengo fotos de un perro y quiero ver coincidencias',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CaptureScreen(isReport: false)),
              ),
            ),
            const SizedBox(height: 14),
            _ActionCard(
              icon: Icons.add_a_photo_outlined,
              title: 'Reportar',
              subtitle: 'Registrar un perro perdido o encontrado',
              accent: true,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CaptureScreen(isReport: true)),
              ),
            ),
            const SizedBox(height: 28),
            _TrustRow(),
            const SizedBox(height: 18),
            Center(
              child: ListenableBuilder(
                listenable: appSettings,
                builder: (_, __) => _BackendChip(name: appSettings.env.name),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool accent;
  final VoidCallback onTap;
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final iconBg = accent ? scheme.primary : scheme.primaryContainer;
    final iconFg = accent ? Colors.white : scheme.onPrimaryContainer;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconFg, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text(subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant, height: 1.3)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrustRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.collections_outlined, '1–5 fotos'),
      (Icons.verified_user_outlined, 'Revisión humana'),
      (Icons.bolt_outlined, 'Resultados al instante'),
    ];
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final it in items)
          Expanded(
            child: Column(
              children: [
                Icon(it.$1, size: 22, color: scheme.primary),
                const SizedBox(height: 6),
                Text(it.$2,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: scheme.onSurfaceVariant)),
              ],
            ),
          ),
      ],
    );
  }
}

class _BackendChip extends StatelessWidget {
  final String name;
  const _BackendChip({required this.name});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_outlined, size: 14, color: scheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(name,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
