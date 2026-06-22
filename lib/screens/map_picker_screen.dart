import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// Selector de ubicación en un mapa (OpenStreetMap, sin API key).
/// El usuario NO escribe lat/long: toca el punto en el mapa (o usa su
/// ubicación). Devuelve el [LatLng] elegido vía Navigator.pop.
class MapPickerScreen extends StatefulWidget {
  final LatLng? initial;
  const MapPickerScreen({super.key, this.initial});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  static const _fallback = LatLng(25.6866, -100.3161); // Monterrey por defecto
  final MapController _controller = MapController();
  LatLng? _selected;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.initial;
  }

  Future<void> _useMyLocation() async {
    setState(() => _locating = true);
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        _snack('Permiso de ubicación denegado. Toca el mapa para elegir.');
        return;
      }
      final pos = await Geolocator.getCurrentPosition();
      final here = LatLng(pos.latitude, pos.longitude);
      setState(() => _selected = here);
      _controller.move(here, 15);
    } catch (e) {
      _snack('No se pudo obtener tu ubicación: toca el mapa para elegir.');
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _snack(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  @override
  Widget build(BuildContext context) {
    final center = _selected ?? widget.initial ?? _fallback;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubicación en el mapa'),
        actions: [
          TextButton(
            onPressed: _selected == null ? null : () => Navigator.of(context).pop(_selected),
            child: Text('Listo',
                style: TextStyle(
                    color: _selected == null ? Colors.white38 : Colors.white,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _controller,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 13,
              onTap: (tapPos, point) => setState(() => _selected = point),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.carlosparra.dogreidapp',
              ),
              if (_selected != null)
                MarkerLayer(markers: [
                  Marker(
                    point: _selected!,
                    width: 44,
                    height: 44,
                    alignment: Alignment.topCenter,
                    child: const Icon(Icons.location_on, color: Colors.red, size: 44),
                  ),
                ]),
            ],
          ),
          // Hint superior
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Card(
              color: Colors.black87,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  _selected == null
                      ? 'Toca en el mapa el lugar donde viste o perdiste al perro.'
                      : 'Punto elegido — lat: ${_selected!.latitude.toStringAsFixed(5)}, '
                          'lon: ${_selected!.longitude.toStringAsFixed(5)}',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _locating ? null : _useMyLocation,
        icon: _locating
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.my_location),
        label: const Text('Mi ubicación'),
      ),
    );
  }
}
