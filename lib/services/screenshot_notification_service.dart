import 'package:flutterputter/services/screenshot_service.dart';
import 'package:flutterputter/services/ephemeral_chat_service.dart';
import 'package:flutter/foundation.dart';

/// 📸 Servicio para manejar notificaciones de capturas de pantalla en el chat
/// Integra la detección de capturas con el sistema de mensajes del chat efímero
class ScreenshotNotificationService {
  static ScreenshotNotificationService? _instance;

  ScreenshotService? _screenshotService;
  EphemeralChatService? _chatService;

  bool _isActive = false;
  String? _currentUserId;
  String? _currentNickname;

  // Singleton
  static ScreenshotNotificationService get instance {
    _instance ??= ScreenshotNotificationService._internal();
    return _instance!;
  }

  ScreenshotNotificationService._internal();

  /// Getter para saber si la detección está activa
  bool get isActive => _isActive;

  /// Inicializar el servicio con los servicios necesarios
  Future<void> initialize({
    required EphemeralChatService chatService,
    required String userId,
    required String nickname,
  }) async {
    try {
      print('📸 [SCREENSHOT-NOTIFICATION] Inicializando servicio...');

      _chatService = chatService;
      _currentUserId = userId;
      _currentNickname = nickname;

      // Inicializar servicio de detección
      _screenshotService = ScreenshotService();
      await _screenshotService!.initialize();

      print('📸 [SCREENSHOT-NOTIFICATION] ✅ Servicio inicializado');
      print(
          '📸 [SCREENSHOT-NOTIFICATION] Usuario: $_currentNickname ($_currentUserId)');
    } catch (e) {
      print('📸 [SCREENSHOT-NOTIFICATION] ❌ Error inicializando: $e');
      rethrow;
    }
  }

  /// Iniciar la detección de capturas
  Future<bool> startDetection() async {
    if (_isActive) {
      print('📸 [SCREENSHOT-NOTIFICATION] ⚠️ Detección ya está activa');
      return true;
    }

    if (_screenshotService == null || _chatService == null) {
      print('📸 [SCREENSHOT-NOTIFICATION] ❌ Servicios no inicializados');
      return false;
    }

    try {
      print('📸 [SCREENSHOT-NOTIFICATION] 🔄 Iniciando detección...');

      // Configurar callback para cuando se detecte una captura
      ScreenshotService.onScreenshotDetected = _onScreenshotDetected;

      // Activar detección en el servicio base
      final success = await _screenshotService!.startScreenshotDetection();

      if (success) {
        _isActive = true;
        print('📸 [SCREENSHOT-NOTIFICATION] ✅ Detección ACTIVADA');
        return true;
      } else {
        print('📸 [SCREENSHOT-NOTIFICATION] ❌ Error activando detección');
        return false;
      }
    } catch (e) {
      print('📸 [SCREENSHOT-NOTIFICATION] ❌ Error iniciando detección: $e');
      return false;
    }
  }

  /// Detener la detección de capturas
  Future<void> stopDetection() async {
    if (!_isActive) {
      print('📸 [SCREENSHOT-NOTIFICATION] ⚠️ Detección ya está detenida');
      return;
    }

    try {
      print('📸 [SCREENSHOT-NOTIFICATION] 🔄 Deteniendo detección...');

      // Limpiar callback
      ScreenshotService.onScreenshotDetected = null;

      // Detener detección en el servicio base
      if (_screenshotService != null) {
        await _screenshotService!.stopScreenshotDetection();
      }

      _isActive = false;
      print('📸 [SCREENSHOT-NOTIFICATION] ✅ Detección DETENIDA');
    } catch (e) {
      print('📸 [SCREENSHOT-NOTIFICATION] ❌ Error deteniendo detección: $e');
    }
  }

  /// Callback que se ejecuta cuando se detecta una captura de pantalla
  void _onScreenshotDetected(Map<String, dynamic> data) {
    print('📸 [SCREENSHOT-NOTIFICATION] === CAPTURA DETECTADA ===');
    print('📸 [SCREENSHOT-NOTIFICATION] Datos: $data');
    print('📸 [SCREENSHOT-NOTIFICATION] Usuario actual: $_currentNickname');
    print('📸 [SCREENSHOT-NOTIFICATION] Chat activo: ${_chatService != null}');

    if (_chatService == null || _currentNickname == null) {
      print(
          '📸 [SCREENSHOT-NOTIFICATION] ❌ Servicios no disponibles para enviar notificación');
      return;
    }

    // ENVIAR MENSAJE AUTOMÁTICO AL CHAT
    _sendScreenshotNotificationMessage();
  }

  /// Enviar mensaje de notificación al chat cuando se detecta una captura
  Future<void> _sendScreenshotNotificationMessage() async {
    try {
      print('📸 [SCREENSHOT-NOTIFICATION] 📤 Enviando notificación al chat...');

      // Crear mensaje de notificación (similar a autodestrucción)
      final notificationMessage = 'SCREENSHOT_NOTIFICATION:$_currentNickname';

      print('📸 [SCREENSHOT-NOTIFICATION] Mensaje: $notificationMessage');

      // Enviar usando el servicio de chat
      await _chatService!.sendMessage(notificationMessage);

      print(
          '📸 [SCREENSHOT-NOTIFICATION] ✅ Notificación enviada correctamente');
    } catch (e) {
      print('📸 [SCREENSHOT-NOTIFICATION] ❌ Error enviando notificación: $e');
    }
  }

  /// Limpiar recursos
  void dispose() {
    print('📸 [SCREENSHOT-NOTIFICATION] 🗑️ Limpiando servicio...');

    stopDetection();

    _screenshotService?.dispose();
    _screenshotService = null;
    _chatService = null;
    _currentUserId = null;
    _currentNickname = null;

    print('📸 [SCREENSHOT-NOTIFICATION] ✅ Servicio limpiado');
  }
}
