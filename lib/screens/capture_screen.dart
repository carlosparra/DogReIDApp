import 'package:flutter/material.dart';

import '../config/app_settings.dart';
import '../models/picked_image.dart';
import '../models/report_metadata.dart';
import '../models/report_result.dart';
import '../services/api_client.dart';
import '../widgets/image_picker_grid.dart';
import '../widgets/metadata_form.dart';
import 'results_screen.dart';

/// Pantalla de captura reutilizable para BUSCAR y REPORTAR.
/// El usuario elige si es perdido/encontrado, sube 1-5 imágenes y opcionalmente
/// metadata. Al enviar, siempre recibe una respuesta (pantalla de resultados).
class CaptureScreen extends StatefulWidget {
  final bool isReport;
  const CaptureScreen({super.key, required this.isReport});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  String _reportType = 'lost';
  List<PickedImage> _images = const [];
  ReportMetadata _metadata = const ReportMetadata();
  bool _loading = false;
  String _status = '';

  bool get _canSubmit => _images.isNotEmpty && _images.length <= 5 && !_loading;

  Future<void> _submit() async {
    final api = ApiClient(appSettings.env);
    setState(() {
      _loading = true;
      _status = 'enviando';
    });
    try {
      final ReportResult result;
      if (widget.isReport) {
        result = await api.report(
          reportType: _reportType,
          images: _images,
          metadata: _metadata,
          onStatus: (s) => setState(() => _status = s),
        );
      } else {
        result = await api.search(
          reportType: _reportType,
          images: _images,
          metadata: _metadata,
        );
      }
      if (!mounted) return;
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ResultsScreen(result: result, wasReport: widget.isReport),
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Theme.of(context).colorScheme.error),
      );
    } finally {
      api.close();
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isReport ? 'Reportar perro' : 'Buscar perro';
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: AbsorbPointer(
        absorbing: _loading,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              widget.isReport
                  ? '¿Perdiste a tu perro o encontraste uno? Súbelo para registrarlo y recibir coincidencias.'
                  : 'Sube fotos del perro para buscar coincidencias en la base.',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'lost', label: Text('Perdido'), icon: Icon(Icons.search)),
                ButtonSegment(value: 'found', label: Text('Encontrado'), icon: Icon(Icons.pets)),
              ],
              selected: {_reportType},
              onSelectionChanged: (s) => setState(() => _reportType = s.first),
            ),
            const SizedBox(height: 20),
            ImagePickerGrid(onChanged: (imgs) => setState(() => _images = imgs)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.isReport
                          ? 'Sube 2–5 fotos del perro en distintos ángulos (frente, lado, cuerpo '
                              'completo): mejora mucho las coincidencias.'
                          : 'Sube varias fotos del perro en distintos ángulos para encontrar más '
                              'coincidencias.',
                      style: const TextStyle(fontSize: 12.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            MetadataForm(onChanged: (m) => setState(() => _metadata = m)),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _canSubmit ? _submit : null,
                icon: _loading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : Icon(widget.isReport ? Icons.send : Icons.search),
                label: Text(_loading
                    ? 'Procesando… ${_status.isEmpty ? '' : '($_status)'}'
                    : (widget.isReport ? 'Enviar reporte' : 'Buscar')),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text('Backend: ${appSettings.env.name}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}
