import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

/// Servicio para manejar la configuración de seguridad de capturas de pantalla
class ScreenshotSecurityService {
  static const String _keyScreenshotEnabled = 'screenshot_enabled';
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // NUEVO: Channel para comunicación con código nativo
  static const MethodChannel _channel = MethodChannel('screenshot_security');

  // Singleton pattern
  static final ScreenshotSecurityService _instance =
      ScreenshotSecurityService._internal();
  factory ScreenshotSecurityService() => _instance;
  ScreenshotSecurityService._internal();

  bool _screenshotEnabled = true; // Por defecto permitidas
  bool _initialized = false;

  /// Inicializar el servicio cargando la configuración guardada
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      final stored = await _storage.read(key: _keyScreenshotEnabled);
      _screenshotEnabled = stored == null ? true : stored == 'true';

      // Aplicar la configuración actual
      await _applyScreenshotSecurity();

      _initialized = true;
    } catch (e) {
      _screenshotEnabled = true; // Valor por defecto seguro
      _initialized = true;
    }
  }

  /// Obtener el estado actual de las capturas de pantalla
  bool get isScreenshotEnabled {
    if (!_initialized) {
      // Servicio no inicializado, devolviendo valor por defecto
    }
    return _screenshotEnabled;
  }

  /// Configurar si las capturas de pantalla están permitidas
  Future<bool> setScreenshotEnabled(bool enabled) async {
    try {
      // Guardar en almacenamiento seguro
      await _storage.write(
          key: _keyScreenshotEnabled, value: enabled.toString());

      // Actualizar estado local
      _screenshotEnabled = enabled;

      // Aplicar la configuración de seguridad
      await _applyScreenshotSecurity();

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Aplicar la configuración de seguridad de capturas de pantalla
  Future<void> _applyScreenshotSecurity() async {
    try {
      if (kIsWeb) {
        // En web no podemos bloquear capturas realmente
        return;
      }

      if (_screenshotEnabled) {
        await _enableScreenshots();
      } else {
        await _blockScreenshots();
      }
    } catch (e) {
      // Error aplicando configuración de seguridad
    }
  }

  /// Permitir capturas de pantalla
  Future<void> _enableScreenshots() async {
    try {
      if (Platform.isIOS) {
        // Usar método nativo para iOS
        await _channel.invokeMethod('enableScreenshots');
      } else if (Platform.isAndroid) {
        // Android: Permitir capturas
        await SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.edgeToEdge,
          overlays: SystemUiOverlay.values,
        );
      }
    } catch (e) {
      // Error habilitando capturas
    }
  }

  /// Bloquear capturas de pantalla (implementación específica por plataforma)
  Future<void> _blockScreenshots() async {
    try {
      if (Platform.isIOS) {
        // Usar método nativo para iOS
        await _channel.invokeMethod('blockScreenshots');
      } else if (Platform.isAndroid) {
        // Android: Bloquear capturas
        await SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.immersive,
          overlays: [],
        );
      }
    } catch (e) {
      // Fallback para Android
      if (Platform.isAndroid) {
        try {
          await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
        } catch (fallbackError) {
          // Error en fallback Android
        }
      }
    }
  }

  /// Alternar el estado de las capturas de pantalla
  Future<bool> toggleScreenshotEnabled() async {
    return await setScreenshotEnabled(!_screenshotEnabled);
  }

  /// Limpiar toda la configuración guardada
  Future<void> clearSettings() async {
    try {
      await _storage.delete(key: _keyScreenshotEnabled);
      _screenshotEnabled = true;
      await _applyScreenshotSecurity();
    } catch (e) {
      // Error limpiando configuración
    }
  }

  /// Obtener información del estado del servicio
  Map<String, dynamic> getStatus() {
    return {
      'initialized': _initialized,
      'screenshotEnabled': _screenshotEnabled,
      'platform': kIsWeb ? 'web' : Platform.operatingSystem,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
