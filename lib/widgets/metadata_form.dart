import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../models/report_metadata.dart';
import '../screens/map_picker_screen.dart';

/// Formulario de metadata contextual (NB-10). Todo opcional. Notifica cambios
/// vía [onChanged] construyendo un [ReportMetadata].
class MetadataForm extends StatefulWidget {
  final ValueChanged<ReportMetadata> onChanged;
  const MetadataForm({super.key, required this.onChanged});

  @override
  State<MetadataForm> createState() => _MetadataFormState();
}

class _MetadataFormState extends State<MetadataForm> {
  final _color = TextEditingController();
  final _collar = TextEditingController();
  final _desc = TextEditingController();
  String? _size;
  DateTime? _date;
  LatLng? _location; // elegida en el mapa (no se escribe a mano)

  @override
  void dispose() {
    for (final c in [_color, _collar, _desc]) {
      c.dispose();
    }
    super.dispose();
  }

  void _emit() {
    widget.onChanged(ReportMetadata(
      latitude: _location?.latitude,
      longitude: _location?.longitude,
      reportDate: _date == null
          ? null
          : '${_date!.year.toString().padLeft(4, '0')}-${_date!.month.toString().padLeft(2, '0')}-${_date!.day.toString().padLeft(2, '0')}',
      color: _color.text.trim(),
      size: _size,
      collar: _collar.text.trim(),
      description: _desc.text.trim(),
    ));
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(builder: (_) => MapPickerScreen(initial: _location)),
    );
    if (result != null) {
      setState(() {
        _location = result;
        _emit();
      });
    }
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
        // Ubicación: se elige en el mapa (los humanos no saben lat/long exactas).
        Card(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            leading: Icon(Icons.place,
                color: _location == null ? Colors.grey : Theme.of(context).colorScheme.primary),
            title: Text(_location == null ? 'Ubicación (tocar para elegir en el mapa)' : 'Ubicación elegida'),
            subtitle: _location == null
                ? const Text('Busca y toca el lugar en el mapa')
                : Text('lat: ${_location!.latitude.toStringAsFixed(5)}, '
                    'lon: ${_location!.longitude.toStringAsFixed(5)}'),
            trailing: _location == null
                ? const Icon(Icons.map)
                : IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'Quitar ubicación',
                    onPressed: () => setState(() {
                      _location = null;
                      _emit();
                    }),
                  ),
            onTap: _pickLocation,
          ),
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
