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
        print('📸 [SCREENSHOT] ¡Captura detectada desde código nativo!');

        final data = Map<String, dynamic>.from(call.arguments);
        print('📸 [SCREENSHOT] Datos: $data');

        // Llamar callback si está configurado
        if (onScreenshotDetected != null) {
          onScreenshotDetected!(data);
        }
      }
    });

    print('👁️ [SCREENSHOT] Listener de detección configurado');
  }

  /// Inicializar el servicio
  Future<void> initialize() async {
    try {
      print('🔒 [SCREENSHOT] Inicializando servicio de seguridad...');

      // En web, no hay capturas de pantalla del sistema, solo avisar
      if (kIsWeb) {
        print('🌐 [SCREENSHOT] Web detectado - funcionalidad limitada');
        return;
      }

      print('✅ [SCREENSHOT] Servicio inicializado correctamente');
    } catch (e) {
      print('❌ [SCREENSHOT] Error inicializando servicio: $e');
    }
  }

  /// NUEVO: Iniciar detección de capturas de pantalla
  Future<bool> startScreenshotDetection() async {
    try {
      if (kIsWeb) {
        print('🌐 [SCREENSHOT] Web: Detección no disponible');
        return false;
      }

      if (_isDetectionActive) {
        print('👁️ [SCREENSHOT] Detección ya está activa');
        return true;
      }

      print('👁️ [SCREENSHOT] Iniciando detección de capturas...');

      final result = await _channel.invokeMethod('startScreenshotDetection');
      if (result == true) {
        _isDetectionActive = true;
        print('✅ [SCREENSHOT] ¡Detección de capturas INICIADA!');
        return true;
      } else {
        print('❌ [SCREENSHOT] Error iniciando detección: $result');
        return false;
      }
    } catch (e) {
      print('❌ [SCREENSHOT] Error iniciando detección: $e');
      return false;
    }
  }

  /// NUEVO: Detener detección de capturas de pantalla
  Future<bool> stopScreenshotDetection() async {
    try {
      if (kIsWeb) {
        print('🌐 [SCREENSHOT] Web: Detección no disponible');
        return false;
      }

      if (!_isDetectionActive) {
        print('👁️ [SCREENSHOT] Detección ya está inactiva');
        return true;
      }

      print('👁️ [SCREENSHOT] Deteniendo detección de capturas...');

      final result = await _channel.invokeMethod('stopScreenshotDetection');
      if (result == true) {
        _isDetectionActive = false;
        print('✅ [SCREENSHOT] ¡Detección de capturas DETENIDA!');
        return true;
      } else {
        print('❌ [SCREENSHOT] Error deteniendo detección: $result');
        return false;
      }
    } catch (e) {
      print('❌ [SCREENSHOT] Error deteniendo detección: $e');
      return false;
    }
  }

  /// BLOQUEAR capturas de pantalla (REAL como WhatsApp)
  Future<bool> blockScreenshots() async {
    try {
      if (kIsWeb) {
        print('🌐 [SCREENSHOT] Web: Bloqueo limitado - solo visual');
        _isBlocked = true;
        return true;
      }

      print('🔒 [SCREENSHOT] Bloqueando capturas de pantalla...');

      final result = await _channel.invokeMethod('blockScreenshots');
      if (result == true) {
        _isBlocked = true;
        print('✅ [SCREENSHOT] ¡Capturas BLOQUEADAS exitosamente!');
        print('🔒 [SCREENSHOT] Ahora las capturas mostrarán pantalla negra');
        return true;
      } else {
        print('❌ [SCREENSHOT] Error: resultado inesperado: $result');
        return false;
      }
    } catch (e) {
      print('❌ [SCREENSHOT] Error bloqueando capturas: $e');
      return false;
    }
  }

  /// HABILITAR capturas de pantalla
  Future<bool> enableScreenshots() async {
    try {
      if (kIsWeb) {
        print('🌐 [SCREENSHOT] Web: Habilitando capturas');
        _isBlocked = false;
        return true;
      }

      print('🔓 [SCREENSHOT] Habilitando capturas de pantalla...');

      final result = await _channel.invokeMethod('enableScreenshots');
      if (result == true) {
        _isBlocked = false;
        print('✅ [SCREENSHOT] ¡Capturas HABILITADAS exitosamente!');
        return true;
      } else {
        print('❌ [SCREENSHOT] Error: resultado inesperado: $result');
        return false;
      }
    } catch (e) {
      print('❌ [SCREENSHOT] Error habilitando capturas: $e');
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
    print('📸 [SCREENSHOT] Callback de detección configurado');
  }

  /// NUEVO: Remover callback
  void removeOnScreenshotDetected() {
    onScreenshotDetected = null;
    print('📸 [SCREENSHOT] Callback de detección removido');
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
    print('🗑️ [SCREENSHOT] Limpiando servicio...');

    // Detener detección si está activa
    if (_isDetectionActive) {
      stopScreenshotDetection();
    }

    // Remover callback
    removeOnScreenshotDetected();

    print('🗑️ [SCREENSHOT] Servicio limpiado');
  }
}
