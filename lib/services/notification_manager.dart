import 'dart:convert';
import 'package:flutter/material.dart';
import 'notification_socket_service.dart';
import 'local_notification_service.dart';
import '../screens/incoming_call_screen.dart';
import '../models/user.dart';

class NotificationManager {
  static NotificationManager? _instance;
  static NotificationManager get instance =>
      _instance ??= NotificationManager._internal();

  NotificationManager._internal();

  late NotificationSocketService _notificationSocket;
  late LocalNotificationService _localNotifications;

  bool _isInitialized = false;
  GlobalKey<NavigatorState>? _navigatorKey;

  // Inicializar el gestor de notificaciones
  Future<void> initialize(String userId, String token,
      GlobalKey<NavigatorState> navigatorKey) async {
    if (_isInitialized) {
      return;
    }

    _navigatorKey = navigatorKey;

    // Inicializar servicios
    _notificationSocket = NotificationSocketService.getInstance();
    _localNotifications = LocalNotificationService.instance;

    // Inicializar notificaciones locales
    await _localNotifications.initialize();

    // Configurar callbacks de notificaciones locales
    _localNotifications.setOnNotificationTapped(_handleNotificationTapped);

    // Configurar callbacks del socket de notificaciones
    _notificationSocket
        .setCallbackIncomingCall(_handleIncomingCallNotification);
    _notificationSocket.setCallbackMessage(_handleMessageNotification);
    _notificationSocket
        .setCallbackGenericNotification(_handleGenericNotification);

    // Inicializar socket de notificaciones
    await _notificationSocket.initialize(userId, token);

    _isInitialized = true;
  }

  // Manejar notificación de llamada entrante desde WebSocket
  void _handleIncomingCallNotification(Map<String, dynamic> data) {
    final callId = data['callId'] as String?;
    final callerName = data['callerName'] as String?;
    final callerAvatar = data['callerAvatar'] as String?;
    final token = data['token'] as String?;

    if (callId == null || callerName == null) {
      return;
    }

    // Mostrar notificación local inmediatamente
    _localNotifications.showIncomingCallNotification(
      callId: callId,
      callerName: callerName,
      callerAvatar: callerAvatar ?? '',
      token: token,
    );

    // Si la app está en foreground, navegar directamente
    if (_navigatorKey?.currentContext != null) {
      _navigateToIncomingCall(callId, callerName, callerAvatar, token);
    }
  }

  // Manejar notificación de mensaje desde WebSocket
  void _handleMessageNotification(Map<String, dynamic> data) {
    final messageId = data['messageId'] as String?;
    final senderName = data['senderName'] as String?;
    final messageText = data['messageText'] as String?;
    final senderAvatar = data['senderAvatar'] as String?;

    if (messageId == null || senderName == null || messageText == null) {
      return;
    }

    // Mostrar notificación local
    _localNotifications.showMessageNotification(
      messageId: messageId,
      senderName: senderName,
      messageText: messageText,
      senderAvatar: senderAvatar,
    );
  }

  // Manejar notificación genérica desde WebSocket
  void _handleGenericNotification(Map<String, dynamic> data) {
    final id = data['id'] as String?;
    final title = data['title'] as String?;
    final body = data['body'] as String?;
    final extraData = data['data'] as Map<String, dynamic>?;

    if (id == null || title == null || body == null) {
      return;
    }

    // Mostrar notificación local
    _localNotifications.showGeneralNotification(
      id: id,
      title: title,
      body: body,
      data: extraData,
    );
  }

  // Manejar cuando se toca una notificación
  void _handleNotificationTapped(String? payload) {
    if (payload == null) return;

    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      final type = data['type'] as String?;

      switch (type) {
        case 'incoming_call':
          _handleIncomingCallTapped(data);
          break;
        case 'message':
          _handleMessageTapped(data);
          break;
        case 'general':
          _handleGeneralNotificationTapped(data);
          break;
        default:
          break;
      }
    } catch (e) {}
  }

  // Manejar cuando se toca notificación de llamada
  void _handleIncomingCallTapped(Map<String, dynamic> data) {
    final callId = data['callId'] as String?;
    final callerName = data['callerName'] as String?;
    final callerAvatar = data['callerAvatar'] as String?;
    final token = data['token'] as String?;

    if (callId != null && callerName != null) {
      _navigateToIncomingCall(callId, callerName, callerAvatar, token);
    }
  }

  // Manejar cuando se toca notificación de mensaje
  void _handleMessageTapped(Map<String, dynamic> data) {
    // TODO: Navegar a la pantalla de chat
  }

  // Manejar cuando se toca notificación genérica
  void _handleGeneralNotificationTapped(Map<String, dynamic> data) {
    // TODO: Manejar según el tipo de notificación
  }

  // Navegar a pantalla de llamada entrante
  void _navigateToIncomingCall(
      String callId, String callerName, String? callerAvatar, String? token) {
    if (_navigatorKey?.currentContext == null) {
      return;
    }

    // Cancelar la notificación ya que vamos a mostrar la pantalla
    _localNotifications.cancelNotification(callId);

    // Crear un objeto User temporal para el llamante
    // TODO: Obtener datos completos del usuario desde la API
    final caller = User(
      id: 'temp_caller_id', // Se debería obtener del WebSocket
      nickname: callerName,
      email: 'temp@email.com', // Se debería obtener de la API
      createdAt: DateTime.now(),
    );

    // Navegar a la pantalla de llamada entrante
    _navigatorKey!.currentState?.push(
      MaterialPageRoute(
        builder: (context) => IncomingCallScreen(
          callId: callId,
          caller: caller,
          isVideo: true, // Por defecto videollamada
        ),
      ),
    );
  }

  // Métodos públicos para controlar notificaciones

  // Actualizar estado del usuario
  void updateUserStatus(String status) {
    if (_isInitialized) {
      _notificationSocket.updateUserStatus(status);
    }
  }

  // Confirmar que se recibió una notificación
  void acknowledgeNotification(String notificationId) {
    if (_isInitialized) {
      _notificationSocket.acknowledgeNotification(notificationId);
    }
  }

  // Cancelar notificación específica
  Future<void> cancelNotification(String id) async {
    await _localNotifications.cancelNotification(id);
  }

  // Cancelar todas las notificaciones
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAllNotifications();
  }

  // Verificar si las notificaciones están habilitadas
  Future<bool> areNotificationsEnabled() async {
    return await _localNotifications.areNotificationsEnabled();
  }

  // Estado de conexión del socket de notificaciones
  bool get isConnected => _isInitialized && _notificationSocket.isConnected;

  // Limpiar recursos
  Future<void> dispose() async {
    if (_isInitialized) {
      await _notificationSocket.dispose();
      _isInitialized = false;
      _instance = null;
    }
  }
}
