import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Servicio para manejar las preferencias por defecto de auto-destrucción
class AutoDestructionPreferencesService {
  static const String _keyDefaultDestructionMinutes =
      'default_destruction_minutes';
  static const String _keyAutoApplyDefault = 'auto_apply_default_destruction';

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Singleton pattern
  static final AutoDestructionPreferencesService _instance =
      AutoDestructionPreferencesService._internal();
  factory AutoDestructionPreferencesService() => _instance;
  AutoDestructionPreferencesService._internal();

  int? _defaultDestructionMinutes; // null = sin auto-destrucción por defecto
  bool _autoApplyDefault =
      false; // Si aplicar automáticamente al unirse a salas
  bool _initialized = false;

  /// Opciones disponibles de auto-destrucción (mismas que en DestructionTimerWidget)
  static const List<Map<String, dynamic>> destructionOptions = [
    {
      'label': '🔥 Sin autodestrucción por defecto',
      'minutes': null,
      'icon': '♾️'
    },
    {'label': '🔥 1 minuto', 'minutes': 1, 'icon': '⚡'},
    {'label': '🔥 5 minutos', 'minutes': 5, 'icon': '🔥'},
    {'label': '🔥 30 minutos', 'minutes': 30, 'icon': '⏰'},
    {'label': '🔥 1 hora', 'minutes': 60, 'icon': '🕐'},
    {'label': '🔥 12 horas', 'minutes': 720, 'icon': '🕛'},
    {'label': '🔥 24 horas', 'minutes': 1440, 'icon': '📅'},
  ];

  /// Inicializar el servicio cargando configuración guardada
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Cargar tiempo por defecto
      final storedMinutes =
          await _storage.read(key: _keyDefaultDestructionMinutes);
      if (storedMinutes != null && storedMinutes != 'null') {
        _defaultDestructionMinutes = int.tryParse(storedMinutes);
      } else {
        _defaultDestructionMinutes = null;
      }

      // Cargar si aplicar automáticamente
      final storedAutoApply = await _storage.read(key: _keyAutoApplyDefault);
      _autoApplyDefault = storedAutoApply == 'true';

      _initialized = true;
    } catch (e) {
      _defaultDestructionMinutes = null;
      _autoApplyDefault = false;
      _initialized = true;
    }
  }

  /// Obtener tiempo por defecto de auto-destrucción
  int? get defaultDestructionMinutes {
    if (!_initialized) {}
    return _defaultDestructionMinutes;
  }

  /// Obtener si debe aplicar automáticamente
  bool get shouldAutoApplyDefault {
    if (!_initialized) {}
    return _autoApplyDefault && _defaultDestructionMinutes != null;
  }

  /// Configurar tiempo por defecto de auto-destrucción
  Future<bool> setDefaultDestructionMinutes(int? minutes) async {
    try {
      await _storage.write(
          key: _keyDefaultDestructionMinutes,
          value: minutes?.toString() ?? 'null');

      _defaultDestructionMinutes = minutes;

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Configurar si aplicar automáticamente
  Future<bool> setAutoApplyDefault(bool enabled) async {
    try {
      await _storage.write(
          key: _keyAutoApplyDefault, value: enabled.toString());
      _autoApplyDefault = enabled;

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Obtener la etiqueta legible del tiempo configurado
  String getTimeLabel(int? minutes) {
    if (minutes == null) return 'Sin autodestrucción';
    if (minutes == 1) return '1 minuto';
    if (minutes == 5) return '5 minutos';
    if (minutes == 30) return '30 minutos';
    if (minutes == 60) return '1 hora';
    if (minutes == 720) return '12 horas';
    if (minutes == 1440) return '24 horas';
    return '$minutes minutos';
  }

  /// Obtener la etiqueta corta del tiempo configurado
  String getShortTimeLabel(int? minutes) {
    if (minutes == null) return 'Sin límite';
    if (minutes == 1) return '1m';
    if (minutes == 5) return '5m';
    if (minutes == 30) return '30m';
    if (minutes == 60) return '1h';
    if (minutes == 720) return '12h';
    if (minutes == 1440) return '24h';
    return '${minutes}m';
  }

  /// Obtener el icono correspondiente
  String getTimeIcon(int? minutes) {
    if (minutes == null) return '♾️';
    if (minutes == 1) return '⚡';
    if (minutes == 5) return '🔥';
    if (minutes == 30) return '⏰';
    if (minutes == 60) return '🕐';
    if (minutes == 720) return '🕛';
    if (minutes == 1440) return '📅';
    return '🔥';
  }

  /// Limpiar todas las preferencias
  Future<void> clearPreferences() async {
    try {
      await _storage.delete(key: _keyDefaultDestructionMinutes);
      await _storage.delete(key: _keyAutoApplyDefault);

      _defaultDestructionMinutes = null;
      _autoApplyDefault = false;
    } catch (e) {}
  }

  /// Obtener información del estado del servicio
  Map<String, dynamic> getStatus() {
    return {
      'initialized': _initialized,
      'defaultDestructionMinutes': _defaultDestructionMinutes,
      'autoApplyDefault': _autoApplyDefault,
      'shouldAutoApply': shouldAutoApplyDefault,
      'timeLabel': getTimeLabel(_defaultDestructionMinutes),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
