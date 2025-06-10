import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Servicio de notificaciones ntfy que NO ALTERA el sistema VoIP existente
/// iOS videollamadas: Mantiene VoIP (NO TOCAR)
/// iOS mensajes: ntfy
/// Android: ntfy para todo
class NtfyNotificationService {
  static NtfyNotificationService? _instance;
  static NtfyNotificationService get instance =>
      _instance ??= NtfyNotificationService._internal();

  NtfyNotificationService._internal();

  bool _isInitialized = false;
  String? _userId;
  String? _serverUrl;
  String? _deviceId;

  static const String _ntfyServerUrl = 'https://clubprivado.ws/ntfy';

  /// Inicializar servicio ntfy
  Future<void> initialize({
    required String userId,
    String? serverUrl,
  }) async {
    if (_isInitialized) {
      print('🔔 [NTFY] Ya está inicializado');
      return;
    }

    try {
      _userId = userId;
      _serverUrl = serverUrl ?? _ntfyServerUrl;
      _deviceId = await _generateDeviceId();

      print('🔔 [NTFY] Inicializando servicio ntfy...');
      print('🔔 [NTFY] Usuario: $_userId');
      print('🔔 [NTFY] Servidor: $_serverUrl');
      print('🔔 [NTFY] Device ID: $_deviceId');
      print('🔔 [NTFY] Plataforma: ${Platform.operatingSystem}');

      _isInitialized = true;
      print('✅ [NTFY] Servicio inicializado correctamente');
    } catch (e) {
      print('❌ [NTFY] Error inicializando: $e');
      rethrow;
    }
  }

  /// Enviar notificación de MENSAJE (iOS y Android)
  Future<void> sendMessageNotification({
    required String targetUserId,
    required String senderName,
    required String messageText,
    String? chatType,
    Map<String, dynamic>? additionalData,
  }) async {
    if (!_isInitialized) {
      print('❌ [NTFY] Servicio no inicializado');
      return;
    }

    try {
      print('🔔 [NTFY] === ENVIANDO NOTIFICACIÓN DE MENSAJE ===');
      print('🔔 [NTFY] Para: $targetUserId');
      print('🔔 [NTFY] De: $senderName');
      print('🔔 [NTFY] Texto: $messageText');
      print('🔔 [NTFY] Tipo: $chatType');

      final topic = 'user_messages_$targetUserId';
      final title = senderName;
      final message = messageText;

      // Datos adicionales para deep linking
      final data = {
        'type': 'message',
        'senderId': _userId,
        'senderName': senderName,
        'targetUserId': targetUserId,
        'messageText': messageText,
        'chatType': chatType ?? 'unknown',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'deviceId': _deviceId,
        ...?additionalData,
      };

      await _sendNtfyNotification(
        topic: topic,
        title: title,
        message: message,
        data: data,
        priority: 'default',
      );

      print('✅ [NTFY] Notificación de mensaje enviada exitosamente');
    } catch (e) {
      print('❌ [NTFY] Error enviando notificación de mensaje: $e');
    }
  }

  /// Enviar notificación de LLAMADA
  /// iOS: Solo si NO es videollamada WebRTC (NO ALTERAR VOIP)
  /// Android: Para todas las llamadas
  Future<void> sendCallNotification({
    required String targetUserId,
    required String callerName,
    required String callId,
    required String callType, // 'video', 'audio', 'voip'
    String? callerAvatar,
    Map<String, dynamic>? additionalData,
  }) async {
    if (!_isInitialized) {
      print('❌ [NTFY] Servicio no inicializado');
      return;
    }

    // CRÍTICO: En iOS, NO enviar para videollamadas WebRTC (mantener VoIP)
    if (Platform.isIOS && callType == 'video') {
      print('🔔 [NTFY] iOS + videollamada = SKIP (usar VoIP existente)');
      print('🔔 [NTFY] Manteniendo sistema VoIP nativo para iOS videollamadas');
      return;
    }

    try {
      print('🔔 [NTFY] === ENVIANDO NOTIFICACIÓN DE LLAMADA ===');
      print('🔔 [NTFY] Para: $targetUserId');
      print('🔔 [NTFY] De: $callerName');
      print('🔔 [NTFY] CallId: $callId');
      print('🔔 [NTFY] Tipo: $callType');
      print('🔔 [NTFY] Plataforma: ${Platform.operatingSystem}');

      final topic = 'user_calls_$targetUserId';
      const title = 'Llamada entrante';
      final message = callType == 'video'
          ? 'Videollamada de $callerName'
          : 'Llamada de $callerName';

      // Datos para deep linking a la llamada
      final data = {
        'type': 'call',
        'callType': callType,
        'callId': callId,
        'callerId': _userId,
        'callerName': callerName,
        'callerAvatar': callerAvatar,
        'targetUserId': targetUserId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'deviceId': _deviceId,
        ...?additionalData,
      };

      await _sendNtfyNotification(
        topic: topic,
        title: title,
        message: message,
        data: data,
        priority: 'urgent',
        actions: [
          {
            'action': 'view',
            'label': 'Contestar',
            'url': 'app://call/answer/$callId'
          },
          {
            'action': 'view',
            'label': 'Rechazar',
            'url': 'app://call/decline/$callId'
          }
        ],
      );

      print('✅ [NTFY] Notificación de llamada enviada exitosamente');
    } catch (e) {
      print('❌ [NTFY] Error enviando notificación de llamada: $e');
    }
  }

  /// Enviar notificación de invitación de chat efímero
  Future<void> sendChatInvitationNotification({
    required String targetUserId,
    required String inviterName,
    required String invitationId,
    Map<String, dynamic>? additionalData,
  }) async {
    if (!_isInitialized) {
      print('❌ [NTFY] Servicio no inicializado');
      return;
    }

    try {
      print('🔔 [NTFY] === ENVIANDO INVITACIÓN DE CHAT ===');
      print('🔔 [NTFY] Para: $targetUserId');
      print('🔔 [NTFY] De: $inviterName');
      print('🔔 [NTFY] InvitationId: $invitationId');

      final topic = 'user_invitations_$targetUserId';
      const title = 'Invitación de chat';
      final message = '$inviterName te invita a un chat efímero';

      final data = {
        'type': 'chat_invitation',
        'invitationId': invitationId,
        'inviterId': _userId,
        'inviterName': inviterName,
        'targetUserId': targetUserId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'deviceId': _deviceId,
        ...?additionalData,
      };

      await _sendNtfyNotification(
        topic: topic,
        title: title,
        message: message,
        data: data,
        priority: 'default',
        actions: [
          {
            'action': 'view',
            'label': 'Aceptar',
            'url': 'app://chat/accept/$invitationId'
          },
          {
            'action': 'view',
            'label': 'Ver',
            'url': 'app://chat/view/$invitationId'
          }
        ],
      );

      print('✅ [NTFY] Invitación de chat enviada exitosamente');
    } catch (e) {
      print('❌ [NTFY] Error enviando invitación de chat: $e');
    }
  }

  /// Enviar notificación genérica personalizada
  Future<void> sendCustomNotification({
    required String targetUserId,
    required String title,
    required String message,
    String? priority,
    List<Map<String, String>>? actions,
    Map<String, dynamic>? data,
  }) async {
    if (!_isInitialized) {
      print('❌ [NTFY] Servicio no inicializado');
      return;
    }

    try {
      final topic = 'user_custom_$targetUserId';

      final notificationData = {
        'type': 'custom',
        'senderId': _userId,
        'targetUserId': targetUserId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'deviceId': _deviceId,
        ...?data,
      };

      await _sendNtfyNotification(
        topic: topic,
        title: title,
        message: message,
        data: notificationData,
        priority: priority ?? 'default',
        actions: actions,
      );

      print('✅ [NTFY] Notificación personalizada enviada');
    } catch (e) {
      print('❌ [NTFY] Error enviando notificación personalizada: $e');
    }
  }

  /// Método base para enviar notificaciones a ntfy
  Future<void> _sendNtfyNotification({
    required String topic,
    required String title,
    required String message,
    Map<String, dynamic>? data,
    String? priority,
    List<Map<String, String>>? actions,
  }) async {
    try {
      final url = '$_serverUrl/$topic';

      final headers = {
        'Content-Type': 'text/plain; charset=utf-8',
        'Title': title,
        'Priority': priority ?? 'default',
        'Tags': 'mobile_app,flutterputter',
      };

      // Agregar datos como headers personalizados si existen
      if (data != null) {
        headers['X-Data'] = jsonEncode(data);
      }

      // Agregar acciones si existen
      if (actions != null && actions.isNotEmpty) {
        headers['Actions'] = actions
            .map((action) =>
                '${action['action']}, ${action['label']}, ${action['url']}')
            .join('; ');
      }

      print('🔔 [NTFY] Enviando a: $url');
      print('🔔 [NTFY] Headers: $headers');
      print('🔔 [NTFY] Mensaje: $message');

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: message,
      );

      if (response.statusCode == 200) {
        print('✅ [NTFY] Notificación enviada exitosamente');
        print('✅ [NTFY] Response: ${response.body}');
      } else {
        print('❌ [NTFY] Error HTTP: ${response.statusCode}');
        print('❌ [NTFY] Response: ${response.body}');
        throw Exception('Error HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ [NTFY] Error en _sendNtfyNotification: $e');
      rethrow;
    }
  }

  /// Suscribirse a notificaciones (en el cliente)
  /// Esta función devuelve las URLs de suscripción que el cliente debe usar
  Map<String, String> getSubscriptionTopics(String userId) {
    return {
      'messages': '$_serverUrl/user_messages_$userId/json',
      'calls': '$_serverUrl/user_calls_$userId/json',
      'invitations': '$_serverUrl/user_invitations_$userId/json',
      'custom': '$_serverUrl/user_custom_$userId/json',
    };
  }

  /// Generar ID único del dispositivo
  Future<String> _generateDeviceId() async {
    // En una implementación real, deberías usar device_info_plus
    final platform = Platform.operatingSystem;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = timestamp.hashCode.abs();
    return '${platform}_${random}_$timestamp';
  }

  /// Obtener información del servicio
  Map<String, dynamic> getServiceInfo() {
    return {
      'isInitialized': _isInitialized,
      'userId': _userId,
      'serverUrl': _serverUrl,
      'deviceId': _deviceId,
      'platform': Platform.operatingSystem,
      'iosVideoCallsHandledByVoIP': Platform.isIOS,
      'supportedNotificationTypes': _getSupportedTypes(),
    };
  }

  /// Tipos de notificaciones soportados por plataforma
  List<String> _getSupportedTypes() {
    if (Platform.isIOS) {
      return [
        'messages', // ✅ ntfy
        'audio_calls', // ✅ ntfy
        'chat_invitations', // ✅ ntfy
        'custom', // ✅ ntfy
        // 'video_calls' → ❌ NO! Usa VoIP existente
      ];
    } else {
      return [
        'messages', // ✅ ntfy
        'video_calls', // ✅ ntfy
        'audio_calls', // ✅ ntfy
        'chat_invitations', // ✅ ntfy
        'custom', // ✅ ntfy
      ];
    }
  }

  /// Limpiar recursos
  void dispose() {
    _isInitialized = false;
    _userId = null;
    _serverUrl = null;
    _deviceId = null;
    _instance = null;
    print('🔔 [NTFY] Servicio limpiado');
  }
}
