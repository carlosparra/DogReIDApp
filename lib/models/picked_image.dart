import 'dart:typed_data';

/// Imagen seleccionada por el usuario, lista para enviar (bytes en memoria).
/// Multiplataforma (móvil/web): no dependemos de rutas de archivo.
class PickedImage {
  final Uint8List bytes;
  final String name;

  const PickedImage({required this.bytes, required this.name});
}
