import 'package:flutter/material.dart';

import '../models/report_metadata.dart';

/// Formulario de metadata contextual (NB-10). Todo opcional. Notifica cambios
/// vía [onChanged] construyendo un [ReportMetadata].
class MetadataForm extends StatefulWidget {
  final ValueChanged<ReportMetadata> onChanged;
  const MetadataForm({super.key, required this.onChanged});

  @override
  State<MetadataForm> createState() => _MetadataFormState();
}

class _MetadataFormState extends State<MetadataForm> {
  final _lat = TextEditingController();
  final _lon = TextEditingController();
  final _color = TextEditingController();
  final _collar = TextEditingController();
  final _desc = TextEditingController();
  String? _size;
  DateTime? _date;

  @override
  void dispose() {
    for (final c in [_lat, _lon, _color, _collar, _desc]) {
      c.dispose();
    }
    super.dispose();
  }

  void _emit() {
    widget.onChanged(ReportMetadata(
      latitude: double.tryParse(_lat.text.trim()),
      longitude: double.tryParse(_lon.text.trim()),
      reportDate: _date == null
          ? null
          : '${_date!.year.toString().padLeft(4, '0')}-${_date!.month.toString().padLeft(2, '0')}-${_date!.day.toString().padLeft(2, '0')}',
      color: _color.text.trim(),
      size: _size,
      collar: _collar.text.trim(),
      description: _desc.text.trim(),
    ));
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );
    if (d != null) {
      setState(() {
        _date = d;
        _emit();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Datos del perro (opcional)', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextField(
          controller: _color,
          decoration: const InputDecoration(labelText: 'Color', border: OutlineInputBorder()),
          onChanged: (_) => _emit(),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _size,
          decoration: const InputDecoration(labelText: 'Tamaño', border: OutlineInputBorder()),
          items: const [
            DropdownMenuItem(value: 'small', child: Text('Pequeño')),
            DropdownMenuItem(value: 'medium', child: Text('Mediano')),
            DropdownMenuItem(value: 'large', child: Text('Grande')),
          ],
          onChanged: (v) => setState(() {
            _size = v;
            _emit();
          }),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _collar,
          decoration: const InputDecoration(labelText: 'Collar (color / ninguno)', border: OutlineInputBorder()),
          onChanged: (_) => _emit(),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _desc,
          maxLines: 2,
          decoration: const InputDecoration(labelText: 'Descripción', border: OutlineInputBorder()),
          onChanged: (_) => _emit(),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _lat,
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                decoration: const InputDecoration(labelText: 'Latitud', border: OutlineInputBorder()),
                onChanged: (_) => _emit(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _lon,
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                decoration: const InputDecoration(labelText: 'Longitud', border: OutlineInputBorder()),
                onChanged: (_) => _emit(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _pickDate,
          icon: const Icon(Icons.calendar_today),
          label: Text(_date == null
              ? 'Fecha del reporte'
              : 'Fecha: ${_date!.toIso8601String().substring(0, 10)}'),
        ),
      ],
    );
  }
}
