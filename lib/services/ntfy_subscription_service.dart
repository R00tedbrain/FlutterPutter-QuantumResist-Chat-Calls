import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'native_notification_service.dart';

// Import condicional para web
import 'ntfy_subscription_service_web.dart'
    if (dart.library.io) 'ntfy_subscription_service_mobile.dart';

/// Servicio que se suscribe ACTIVAMENTE a notifications de ntfy
/// Funciona tanto en web (EventSource) como en móvil (polling)
class NtfySubscriptionService {
  static NtfySubscriptionService? _instance;
  static NtfySubscriptionService get instance =>
      _instance ??= NtfySubscriptionService._internal();

  NtfySubscriptionService._internal();

  bool _isInitialized = false;
  bool _isSubscribed = false;
  String? _userId;
  String? _serverUrl;

  // Implementación específica de plataforma
  late final NtfySubscriptionPlatform _platform;

  // Callbacks para diferentes tipos de notificaciones
  Function(Map<String, dynamic>)? onMessageNotification;
  Function(Map<String, dynamic>)? onCallNotification;
  Function(Map<String, dynamic>)? onInvitationNotification;
  Function(Map<String, dynamic>)? onCustomNotification;

  static const String _ntfyServerUrl = 'https://clubprivado.ws/ntfy';

  /// Inicializar y suscribirse automáticamente
  Future<void> initialize({
    required String userId,
    String? serverUrl,
  }) async {
    if (_isInitialized) {
      print('🔔📡 [NTFY-SUB] Ya está inicializado');
      return;
    }

    try {
      _userId = userId;
      _serverUrl = serverUrl ?? _ntfyServerUrl;

      print('🔔📡 [NTFY-SUB] === INICIALIZANDO SUSCRIPCIONES NTFY ===');
      print('🔔📡 [NTFY-SUB] Usuario: $_userId');
      print('🔔📡 [NTFY-SUB] Servidor: $_serverUrl');
      print('🔔📡 [NTFY-SUB] Plataforma: ${kIsWeb ? 'Web' : 'Mobile'}');

      // Inicializar servicio de notificaciones nativas
      await NativeNotificationService.instance.initialize();

      // Crear implementación específica de plataforma
      _platform = createNtfySubscriptionPlatform();
      await _platform.initialize(
        serverUrl: _serverUrl!,
        onNotificationReceived: _handleNotification,
      );

      _isInitialized = true;

      // Suscribirse automáticamente a todos los topics
      await subscribeToAllTopics();

      print('✅ [NTFY-SUB] Servicio de suscripción inicializado correctamente');
    } catch (e) {
      print('❌ [NTFY-SUB] Error inicializando: $e');
      rethrow;
    }
  }

  /// Suscribirse a todos los topics del usuario
  Future<void> subscribeToAllTopics() async {
    if (!_isInitialized || _userId == null) {
      print('❌ [NTFY-SUB] Servicio no inicializado');
      return;
    }

    if (_isSubscribed) {
      print('🔔📡 [NTFY-SUB] Ya está suscrito, cerrando suscripciones previas');
      await unsubscribeFromAllTopics();
    }

    try {
      print('🔔📡 [NTFY-SUB] === SUSCRIBIÉNDOSE A TOPICS ===');

      // Topics a los que suscribirse
      final topics = {
        'messages': 'user_messages_$_userId',
        'calls': 'user_calls_$_userId',
        'invitations': 'user_invitations_$_userId',
        'custom': 'user_custom_$_userId',
      };

      // Suscribirse usando la implementación de plataforma
      await _platform.subscribeToTopics(topics);

      _isSubscribed = true;
      print('✅ [NTFY-SUB] Suscrito a ${topics.length} topics correctamente');
    } catch (e) {
      print('❌ [NTFY-SUB] Error suscribiéndose: $e');
      rethrow;
    }
  }

  /// Manejar notificación recibida
  void _handleNotification(String topicType, Map<String, dynamic> data) {
    print('🔔📡 [NTFY-SUB] === PROCESANDO NOTIFICACIÓN ===');
    print('🔔📡 [NTFY-SUB] Tipo de topic: $topicType');
    print('🔔📡 [NTFY-SUB] Título: ${data['title']}');
    print('🔔📡 [NTFY-SUB] Mensaje: ${data['message']}');
    print('🔔📡 [NTFY-SUB] ID: ${data['id']}');
    print('🔔📡 [NTFY-SUB] Tiempo: ${data['time']}');

    // Extraer datos personalizados
    Map<String, dynamic>? customData;
    if (data['extras'] != null && data['extras']['X-Data'] != null) {
      try {
        customData = jsonDecode(data['extras']['X-Data']);
        print('🔔📡 [NTFY-SUB] Datos personalizados: $customData');
      } catch (e) {
        print('❌ [NTFY-SUB] Error parseando datos personalizados: $e');
      }
    }

    // Crear objeto de notificación procesada
    final notification = {
      'id': data['id'],
      'title': data['title'],
      'message': data['message'],
      'topic': data['topic'],
      'time': data['time'],
      'topicType': topicType,
      'customData': customData,
      'rawData': data,
    };

    // Mostrar notificación nativa del sistema
    _showNativeNotification(topicType, data, customData);

    // Llamar callback específico según el tipo
    switch (topicType) {
      case 'messages':
        print('📩 [NTFY-SUB] Ejecutando callback de mensaje');
        onMessageNotification?.call(notification);
        break;
      case 'calls':
        print('📞 [NTFY-SUB] Ejecutando callback de llamada');
        onCallNotification?.call(notification);
        break;
      case 'invitations':
        print('📩 [NTFY-SUB] Ejecutando callback de invitación');
        onInvitationNotification?.call(notification);
        break;
      case 'custom':
        print('🔧 [NTFY-SUB] Ejecutando callback personalizado');
        onCustomNotification?.call(notification);
        break;
      default:
        print('❓ [NTFY-SUB] Tipo de topic desconocido: $topicType');
    }
  }

  /// Mostrar notificación nativa del sistema
  Future<void> _showNativeNotification(String topicType,
      Map<String, dynamic> data, Map<String, dynamic>? customData) async {
    try {
      final notificationService = NativeNotificationService.instance;

      switch (topicType) {
        case 'invitations':
          print('📲 [NTFY-SUB] Mostrando notificación nativa de invitación');

          // Extraer datos de la invitación
          String fromUserId = 'Usuario desconocido';
          String invitationId = data['id']?.toString() ?? 'inv_unknown';

          // Intentar extraer el usuario del mensaje
          final message = data['message']?.toString() ?? '';
          final userIdMatch =
              RegExp(r'^([a-f0-9-]+)\s+te invita').firstMatch(message);
          if (userIdMatch != null) {
            fromUserId = userIdMatch.group(1)!;
          }

          await notificationService.showChatInvitation(
            fromUserId: fromUserId,
            invitationId: invitationId,
            customMessage: message.isNotEmpty ? message : null,
          );
          break;

        case 'messages':
          print('📲 [NTFY-SUB] Mostrando notificación nativa de mensaje');

          // Extraer datos del mensaje
          String fromUserId = 'Usuario desconocido';
          String messageId = data['id']?.toString() ?? 'msg_unknown';
          String roomId = 'room_unknown';

          // Intentar extraer datos del título (generalmente es el ID del usuario)
          final title = data['title']?.toString() ?? '';
          if (title.isNotEmpty) {
            fromUserId = title;
          }

          // Intentar extraer roomId de customData
          if (customData != null && customData['roomId'] != null) {
            roomId = customData['roomId'].toString();
          }

          await notificationService.showChatMessage(
            fromUserId: fromUserId,
            messageId: messageId,
            roomId: roomId,
            messageContent: data['message']?.toString(),
          );
          break;

        case 'calls':
          print('📲 [NTFY-SUB] Mostrando notificación nativa de llamada');

          // Extraer datos de la llamada
          String fromUserId =
              data['title']?.toString() ?? 'Usuario desconocido';
          String callId = data['id']?.toString() ?? 'call_unknown';

          await notificationService.showIncomingCall(
            fromUserId: fromUserId,
            callId: callId,
            callerName: customData?['callerName']?.toString(),
          );
          break;

        default:
          print(
              '📲 [NTFY-SUB] Tipo de notificación no soportada para nativa: $topicType');
          break;
      }
    } catch (e) {
      print('❌ [NTFY-SUB] Error mostrando notificación nativa: $e');
    }
  }

  /// Desuscribirse de todos los topics
  Future<void> unsubscribeFromAllTopics() async {
    print('🔔📡 [NTFY-SUB] Cerrando todas las suscripciones...');

    if (_isInitialized) {
      await _platform.unsubscribeFromAllTopics();
    }

    _isSubscribed = false;
    print('✅ [NTFY-SUB] Todas las suscripciones cerradas');
  }

  /// Configurar callbacks
  void setMessageCallback(Function(Map<String, dynamic>) callback) {
    onMessageNotification = callback;
    print('✅ [NTFY-SUB] Callback de mensajes configurado');
  }

  void setCallCallback(Function(Map<String, dynamic>) callback) {
    onCallNotification = callback;
    print('✅ [NTFY-SUB] Callback de llamadas configurado');
  }

  void setInvitationCallback(Function(Map<String, dynamic>) callback) {
    onInvitationNotification = callback;
    print('✅ [NTFY-SUB] Callback de invitaciones configurado');
  }

  void setCustomCallback(Function(Map<String, dynamic>) callback) {
    onCustomNotification = callback;
    print('✅ [NTFY-SUB] Callback personalizado configurado');
  }

  /// Obtener estado del servicio
  Map<String, dynamic> getServiceInfo() {
    final platformInfo = _isInitialized ? _platform.getServiceInfo() : {};
    final nativeNotifInfo = NativeNotificationService.instance.getServiceInfo();

    return {
      'isInitialized': _isInitialized,
      'isSubscribed': _isSubscribed,
      'userId': _userId,
      'serverUrl': _serverUrl,
      'platform': kIsWeb ? 'web' : 'mobile',
      'nativeNotifications': nativeNotifInfo,
      ...platformInfo,
    };
  }

  /// Verificar si está suscrito a un topic específico
  bool isSubscribedToTopic(String topicType) {
    return _isInitialized && _platform.isSubscribedToTopic(topicType);
  }

  /// Obtener URLs de los topics activos
  Map<String, String> getActiveTopicUrls() {
    if (!_isInitialized || _userId == null) return {};

    return {
      'messages': '$_serverUrl/user_messages_$_userId/json',
      'calls': '$_serverUrl/user_calls_$_userId/json',
      'invitations': '$_serverUrl/user_invitations_$_userId/json',
      'custom': '$_serverUrl/user_custom_$_userId/json',
    };
  }

  /// Limpiar recursos
  void dispose() {
    print('🔔📡 [NTFY-SUB] Limpiando servicio...');

    if (_isInitialized) {
      _platform.dispose();
    }

    _isInitialized = false;
    _isSubscribed = false;
    _userId = null;
    _serverUrl = null;

    onMessageNotification = null;
    onCallNotification = null;
    onInvitationNotification = null;
    onCustomNotification = null;

    _instance = null;
    print('✅ [NTFY-SUB] Servicio limpiado completamente');
  }
}

/// Interfaz abstracta para implementaciones específicas de plataforma
abstract class NtfySubscriptionPlatform {
  Future<void> initialize({
    required String serverUrl,
    required Function(String topicType, Map<String, dynamic> data)
        onNotificationReceived,
  });

  Future<void> subscribeToTopics(Map<String, String> topics);
  Future<void> unsubscribeFromAllTopics();
  bool isSubscribedToTopic(String topicType);
  Map<String, dynamic> getServiceInfo();
  void dispose();
}
