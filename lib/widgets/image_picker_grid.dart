import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/picked_image.dart';

/// Selector de 1 a 5 imágenes (galería múltiple o cámara), con miniaturas y
/// botón para quitar cada una. Notifica la lista vía [onChanged].
class ImagePickerGrid extends StatefulWidget {
  final ValueChanged<List<PickedImage>> onChanged;
  final int maxImages;

  const ImagePickerGrid({super.key, required this.onChanged, this.maxImages = 5});

  @override
  State<ImagePickerGrid> createState() => _ImagePickerGridState();
}

class _ImagePickerGridState extends State<ImagePickerGrid> {
  final ImagePicker _picker = ImagePicker();
  final List<PickedImage> _images = [];

  void _emit() => widget.onChanged(List.unmodifiable(_images));

  Future<void> _addFrom(ImageSource source) async {
    try {
      final List<XFile> picked = [];
      if (source == ImageSource.gallery) {
        picked.addAll(await _picker.pickMultiImage());
      } else {
        final XFile? f = await _picker.pickImage(source: ImageSource.camera);
        if (f != null) picked.add(f);
      }
      if (picked.isEmpty) return;

      final remaining = widget.maxImages - _images.length;
      if (remaining <= 0) {
        _snack('Máximo ${widget.maxImages} imágenes.');
        return;
      }
      final toAdd = picked.take(remaining);
      for (final xf in toAdd) {
        final bytes = await xf.readAsBytes();
        _images.add(PickedImage(bytes: bytes, name: xf.name));
      }
      if (picked.length > remaining) {
        _snack('Solo se agregaron $remaining (límite ${widget.maxImages}).');
      }
      setState(_emit);
    } catch (e) {
      _snack('No se pudo abrir la imagen: $e');
    }
  }

  void _removeAt(int i) => setState(() {
        _images.removeAt(i);
        _emit();
      });

  void _snack(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  @override
  Widget build(BuildContext context) {
    final full = _images.length >= widget.maxImages;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Imágenes (${_images.length}/${widget.maxImages})',
                style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            if (_images.isEmpty)
              Text('mín. 1', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < _images.length; i++)
              _Thumb(image: _images[i], onRemove: () => _removeAt(i)),
            if (!full) _AddTile(icon: Icons.photo_library, label: 'Galería', onTap: () => _addFrom(ImageSource.gallery)),
            if (!full) _AddTile(icon: Icons.photo_camera, label: 'Cámara', onTap: () => _addFrom(ImageSource.camera)),
          ],
        ),
      ],
    );
  }
}

class _Thumb extends StatelessWidget {
  final PickedImage image;
  final VoidCallback onRemove;
  const _Thumb({required this.image, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.memory(image.bytes, width: 92, height: 92, fit: BoxFit.cover),
        ),
        Positioned(
          right: -6,
          top: -6,
          child: IconButton(
            icon: const CircleAvatar(radius: 12, child: Icon(Icons.close, size: 14)),
            onPressed: onRemove,
          ),
        ),
      ],
    );
  }
}

class _AddTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _AddTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 92,
        height: 92,
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(icon), const SizedBox(height: 4), Text(label, style: const TextStyle(fontSize: 12))],
        ),
      ),
    );
  }
}
