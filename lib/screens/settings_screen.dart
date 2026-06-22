import 'package:flutter/material.dart';

import '../config/app_settings.dart';
import '../config/environment.dart';

/// Ajustes: elegir el entorno (Local / GCP) y editar sus URLs en tiempo real.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _search;
  late TextEditingController _ingest;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController(text: appSettings.env.searchBaseUrl);
    _ingest = TextEditingController(text: appSettings.env.ingestBaseUrl ?? '');
  }

  @override
  void dispose() {
    _search.dispose();
    _ingest.dispose();
    super.dispose();
  }

  void _onSelect(Environment env) {
    appSettings.select(env);
    setState(() {
      _search.text = env.searchBaseUrl;
      _ingest.text = env.ingestBaseUrl ?? '';
    });
  }

  void _save() {
    final updated = appSettings.env.copyWith(
      searchBaseUrl: _search.text.trim(),
      ingestBaseUrl: _ingest.text.trim().isEmpty ? null : _ingest.text.trim(),
    );
    appSettings.updateCurrent(updated);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Guardado')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Entorno de backend', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...appSettings.environments.map((e) {
            final selected = appSettings.env.id == e.id;
            return Card(
              color: selected ? Theme.of(context).colorScheme.primaryContainer : null,
              child: ListTile(
                leading: Icon(selected ? Icons.radio_button_checked : Icons.radio_button_unchecked),
                title: Text(e.name),
                subtitle: Text('search: ${e.searchBaseUrl}\nreporte: ${e.reportMode.name}'),
                isThreeLine: true,
                onTap: () => _onSelect(e),
              ),
            );
          }),
          const Divider(height: 32),
          Text('URLs del entorno seleccionado', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          TextField(
            controller: _search,
            decoration: const InputDecoration(
              labelText: 'searchBaseUrl (/v1/search)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _ingest,
            decoration: const InputDecoration(
              labelText: 'ingestBaseUrl (/v1/reports) — vacío si no aplica',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(onPressed: _save, icon: const Icon(Icons.save), label: const Text('Guardar URLs')),
          const SizedBox(height: 24),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Text(
                'Local: levanta la API del repo DogReID\n'
                '  GALLERY_DIR=local/data/gallery_found uvicorn local.app:app --port 8080\n'
                'Emulador Android: usa http://10.0.2.2:8080 en vez de localhost.\n\n'
                'GCP: pon las URLs de Cloud Run (inference para /v1/search, api para /v1/reports).',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
