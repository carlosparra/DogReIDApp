import 'package:flutter/foundation.dart';

import 'environment.dart';

/// Estado global mínimo: el entorno seleccionado (local/GCP) y su edición en vivo.
/// Sin dependencias externas de estado — un simple [ValueNotifier].
class AppSettings extends ChangeNotifier {
  Environment _env = Environment.ngrok; // por defecto remoto (funciona en teléfono)
  Environment get env => _env;

  /// Lista editable de entornos (arranca con los presets).
  final List<Environment> environments = List.of(Environment.presets);

  void select(Environment env) {
    _env = env;
    notifyListeners();
  }

  void updateCurrent(Environment updated) {
    final i = environments.indexWhere((e) => e.id == updated.id);
    if (i >= 0) environments[i] = updated;
    if (_env.id == updated.id) _env = updated;
    notifyListeners();
  }
}

/// Instancia global única.
final appSettings = AppSettings();
