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
      _chatService = chatService;
      _currentUserId = userId;
      _currentNickname = nickname;

      // Inicializar servicio de detección
      _screenshotService = ScreenshotService();
      await _screenshotService!.initialize();
    } catch (e) {
      rethrow;
    }
  }

  /// Iniciar la detección de capturas
  Future<bool> startDetection() async {
    if (_isActive) {
      return true;
    }

    if (_screenshotService == null || _chatService == null) {
      return false;
    }

    try {
      // Configurar callback para cuando se detecte una captura
      ScreenshotService.onScreenshotDetected = _onScreenshotDetected;

      // Activar detección en el servicio base
      final success = await _screenshotService!.startScreenshotDetection();

      if (success) {
        _isActive = true;
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Detener la detección de capturas
  Future<void> stopDetection() async {
    if (!_isActive) {
      return;
    }

    try {
      // Limpiar callback
      ScreenshotService.onScreenshotDetected = null;

      // Detener detección en el servicio base
      if (_screenshotService != null) {
        await _screenshotService!.stopScreenshotDetection();
      }

      _isActive = false;
    } catch (e) {
      // Error deteniendo detección
    }
  }

  /// Callback que se ejecuta cuando se detecta una captura de pantalla
  void _onScreenshotDetected(Map<String, dynamic> data) {
    if (_chatService == null || _currentNickname == null) {
      return;
    }

    // ENVIAR MENSAJE AUTOMÁTICO AL CHAT
    _sendScreenshotNotificationMessage();
  }

  /// Enviar mensaje de notificación al chat cuando se detecta una captura
  Future<void> _sendScreenshotNotificationMessage() async {
    try {
      // Crear mensaje de notificación (similar a autodestrucción)
      final notificationMessage = 'SCREENSHOT_NOTIFICATION:$_currentNickname';

      // Enviar usando el servicio de chat
      await _chatService!.sendMessage(notificationMessage);
    } catch (e) {
      // Error enviando notificación
    }
  }

  /// Limpiar recursos
  void dispose() {
    stopDetection();

    _screenshotService?.dispose();
    _screenshotService = null;
    _chatService = null;
    _currentUserId = null;
    _currentNickname = null;
  }
}
