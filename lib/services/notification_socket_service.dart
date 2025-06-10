import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart';

class NotificationSocketService {
  static NotificationSocketService? _instance;
  IO.Socket? _notificationSocket;
  bool _isConnected = false;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int MAX_RECONNECT_ATTEMPTS = 10;

  String? _userId;
  String? _token;

  // Callbacks para diferentes tipos de notificaciones
  Function(Map<String, dynamic>)? onIncomingCall;
  Function(Map<String, dynamic>)? onMessage;
  Function(Map<String, dynamic>)? onGenericNotification;

  // Singleton
  static NotificationSocketService getInstance() {
    _instance ??= NotificationSocketService._internal();
    return _instance!;
  }

  NotificationSocketService._internal();

  // Inicializar el socket de notificaciones
  Future<void> initialize(String userId, String token) async {
    _userId = userId;
    _token = token;

    await _connect();
  }

  Future<void> _connect() async {
    try {
      if (_notificationSocket != null) {
        await _disconnect();
      }

      _notificationSocket = IO.io(
        'http://192.142.10.106:3003', // Tu servidor de notificaciones
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .enableReconnection()
            .setReconnectionAttempts(MAX_RECONNECT_ATTEMPTS)
            .setReconnectionDelay(2000)
            .build(),
      );

      _setupNotificationListeners();
    } catch (e) {
      _scheduleReconnect();
    }
  }

  void _setupNotificationListeners() {
    _notificationSocket?.onConnect((_) {
      _isConnected = true;
      _reconnectAttempts = 0;

      // Registrar usuario para notificaciones
      _registerForNotifications();

      // Iniciar heartbeat
      _startHeartbeat();
    });

    _notificationSocket?.onDisconnect((_) {
      _isConnected = false;
      _stopHeartbeat();
      _scheduleReconnect();
    });

    _notificationSocket?.onConnectError((error) {
      _scheduleReconnect();
    });

    // Listener para llamadas entrantes
    _notificationSocket?.on('incoming-call-notification', (data) {
      if (onIncomingCall != null && data is Map<String, dynamic>) {
        onIncomingCall!(data);
      }
    });

    // Listener para mensajes
    _notificationSocket?.on('message-notification', (data) {
      if (onMessage != null && data is Map<String, dynamic>) {
        onMessage!(data);
      }
    });

    // Listener para notificaciones genéricas
    _notificationSocket?.on('generic-notification', (data) {
      if (onGenericNotification != null && data is Map<String, dynamic>) {
        onGenericNotification!(data);
      }
    });

    // Heartbeat response
    _notificationSocket?.on('pong', (_) {
      // Heartbeat recibido del servidor de notificaciones
    });
  }

  void _registerForNotifications() {
    if (_userId != null && _token != null) {
      _notificationSocket?.emit('register-for-notifications', {
        'userId': _userId,
        'token': _token,
        'platform': defaultTargetPlatform.name,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isConnected) {
        _notificationSocket?.emit('ping');
      }
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= MAX_RECONNECT_ATTEMPTS) {
      return;
    }

    _reconnectTimer?.cancel();
    final delay = Duration(seconds: 2 * (_reconnectAttempts + 1));

    _reconnectTimer = Timer(delay, () {
      _reconnectAttempts++;
      _connect();
    });
  }

  // Métodos públicos
  bool get isConnected => _isConnected;

  void setCallbackIncomingCall(Function(Map<String, dynamic>) callback) {
    onIncomingCall = callback;
  }

  void setCallbackMessage(Function(Map<String, dynamic>) callback) {
    onMessage = callback;
  }

  void setCallbackGenericNotification(Function(Map<String, dynamic>) callback) {
    onGenericNotification = callback;
  }

  // Enviar confirmación de notificación recibida
  void acknowledgeNotification(String notificationId) {
    _notificationSocket?.emit('notification-acknowledged', {
      'notificationId': notificationId,
      'userId': _userId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // Actualizar estado de usuario (online/offline)
  void updateUserStatus(String status) {
    _notificationSocket?.emit('user-status-update', {
      'userId': _userId,
      'status': status, // 'online', 'offline', 'busy', 'away'
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> _disconnect() async {
    _stopHeartbeat();
    _reconnectTimer?.cancel();

    if (_notificationSocket != null) {
      _notificationSocket!.disconnect();
      _notificationSocket!.dispose();
      _notificationSocket = null;
    }

    _isConnected = false;
  }

  Future<void> dispose() async {
    await _disconnect();
    _instance = null;
  }
}
