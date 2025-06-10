import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// 🔒 Servicio de Bloqueo Real de Capturas de Pantalla
/// Como WhatsApp/Telegram - BLOQUEO REAL sin diálogos
/// NUEVO: Ahora incluye DETECCIÓN de capturas para notificar al chat
class ScreenshotService {
  static const MethodChannel _channel = MethodChannel('screenshot_security');
  static bool _isBlocked = false;
  // NUEVO: Variables para detección
  static bool _isDetectionActive = false;

  // NUEVO: Callbacks para eventos de captura
  static Function(Map<String, dynamic>)? onScreenshotDetected;

  /// Singleton
  static final ScreenshotService _instance = ScreenshotService._internal();
  factory ScreenshotService() => _instance;
  ScreenshotService._internal() {
    // NUEVO: Configurar listener para capturas detectadas
    _setupScreenshotDetectionListener();
  }

  /// NUEVO: Configurar listener para detección de capturas
  void _setupScreenshotDetectionListener() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onScreenshotDetected') {
        final data = Map<String, dynamic>.from(call.arguments);
        // Llamar callback si está configurado
        if (onScreenshotDetected != null) {
          onScreenshotDetected!(data);
        }
      }
    });
  }

  /// Inicializar el servicio
  Future<void> initialize() async {
    try {
      // En web, no hay capturas de pantalla del sistema, solo avisar
      if (kIsWeb) {
        return;
      }
    } catch (e) {
      // Error inicializando servicio
    }
  }

  /// NUEVO: Iniciar detección de capturas de pantalla
  Future<bool> startScreenshotDetection() async {
    try {
      if (kIsWeb) {
        return false;
      }

      if (_isDetectionActive) {
        return true;
      }

      final result = await _channel.invokeMethod('startScreenshotDetection');
      if (result == true) {
        _isDetectionActive = true;
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// NUEVO: Detener detección de capturas de pantalla
  Future<bool> stopScreenshotDetection() async {
    try {
      if (kIsWeb) {
        return false;
      }

      if (!_isDetectionActive) {
        return true;
      }

      final result = await _channel.invokeMethod('stopScreenshotDetection');
      if (result == true) {
        _isDetectionActive = false;
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// BLOQUEAR capturas de pantalla (REAL como WhatsApp)
  Future<bool> blockScreenshots() async {
    try {
      if (kIsWeb) {
        _isBlocked = true;
        return true;
      }

      final result = await _channel.invokeMethod('blockScreenshots');
      if (result == true) {
        _isBlocked = true;
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// HABILITAR capturas de pantalla
  Future<bool> enableScreenshots() async {
    try {
      if (kIsWeb) {
        _isBlocked = false;
        return true;
      }

      final result = await _channel.invokeMethod('enableScreenshots');
      if (result == true) {
        _isBlocked = false;
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Verificar si las capturas están bloqueadas
  bool get isBlocked => _isBlocked;

  /// NUEVO: Verificar si la detección está activa
  bool get isDetectionActive => _isDetectionActive;

  /// Alternar estado de bloqueo
  Future<bool> toggleScreenshots() async {
    if (_isBlocked) {
      return await enableScreenshots();
    } else {
      return await blockScreenshots();
    }
  }

  /// NUEVO: Alternar estado de detección
  Future<bool> toggleScreenshotDetection() async {
    if (_isDetectionActive) {
      return await stopScreenshotDetection();
    } else {
      return await startScreenshotDetection();
    }
  }

  /// NUEVO: Configurar callback para capturas detectadas
  void setOnScreenshotDetected(Function(Map<String, dynamic>) callback) {
    onScreenshotDetected = callback;
  }

  /// NUEVO: Remover callback
  void removeOnScreenshotDetected() {
    onScreenshotDetected = null;
  }

  /// NUEVO: Información del estado del servicio
  Map<String, dynamic> getStatus() {
    return {
      'isBlocked': _isBlocked,
      'isDetectionActive': _isDetectionActive,
      'platform': kIsWeb ? 'web' : 'native',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Limpiar recursos
  void dispose() {
    // Detener detección si está activa
    if (_isDetectionActive) {
      stopScreenshotDetection();
    }

    // Remover callback
    removeOnScreenshotDetected();
  }
}
