import 'dart:io';
import 'ntfy_notification_service.dart';
// Sistema VoIP existente (NO ALTERAR)

/// Servicio híbrido que decide cuándo usar VoIP y cuándo usar ntfy
/// REGLAS ESTRICTAS:
/// - iOS videollamadas WebRTC: VoIP existente (NO TOCAR)
/// - iOS mensajes/chat: ntfy
/// - Android todo: ntfy
class HybridNotificationService {
  static HybridNotificationService? _instance;
  static HybridNotificationService get instance =>
      _instance ??= HybridNotificationService._internal();

  HybridNotificationService._internal();

  bool _isInitialized = false;
  String? _userId;

  /// Inicializar ambos servicios
  Future<void> initialize({
    required String userId,
    required String token,
  }) async {
    if (_isInitialized) {
      return;
    }

    try {
      _userId = userId;

      // 1. SIEMPRE inicializar ntfy
      await NtfyNotificationService.instance.initialize(userId: userId);

      // 2. En iOS: MANTENER VoIP existente para videollamadas
      if (Platform.isIOS) {
        // NOTA: VoIP ya debe estar inicializado por el sistema existente
        // NO MODIFICAMOS NADA del VoIP existente
      }

      _isInitialized = true;

      _printConfiguration();
    } catch (e) {
      rethrow;
    }
  }

  /// ENVIAR NOTIFICACIÓN DE VIDEOLLAMADA
  /// iOS: USA VoIP existente (NO TOCAR)
  /// Android: USA ntfy
  Future<void> sendVideoCallNotification({
    required String targetUserId,
    required String callerName,
    required String callId,
    String? callerAvatar,
    Map<String, dynamic>? additionalData,
  }) async {
    if (!_isInitialized) {
      return;
    }

    try {
      if (Platform.isIOS) {
        // NO HACEMOS NADA - el VoIP existente ya maneja esto
      } else {
        await NtfyNotificationService.instance.sendCallNotification(
          targetUserId: targetUserId,
          callerName: callerName,
          callId: callId,
          callType: 'video',
          callerAvatar: callerAvatar,
          additionalData: additionalData,
        );
      }
    } catch (e) {}
  }

  /// ENVIAR NOTIFICACIÓN DE LLAMADA DE AUDIO
  /// iOS y Android: USA ntfy
  Future<void> sendAudioCallNotification({
    required String targetUserId,
    required String callerName,
    required String callId,
    String? callerAvatar,
    Map<String, dynamic>? additionalData,
  }) async {
    if (!_isInitialized) {
      return;
    }

    try {
      await NtfyNotificationService.instance.sendCallNotification(
        targetUserId: targetUserId,
        callerName: callerName,
        callId: callId,
        callType: 'audio',
        callerAvatar: callerAvatar,
        additionalData: additionalData,
      );
    } catch (e) {}
  }

  /// ENVIAR NOTIFICACIÓN DE MENSAJE
  /// iOS y Android: USA ntfy
  Future<void> sendMessageNotification({
    required String targetUserId,
    required String senderName,
    required String messageText,
    String? chatType,
    Map<String, dynamic>? additionalData,
  }) async {
    if (!_isInitialized) {
      return;
    }

    try {
      await NtfyNotificationService.instance.sendMessageNotification(
        targetUserId: targetUserId,
        senderName: senderName,
        messageText: messageText,
        chatType: chatType,
        additionalData: additionalData,
      );
    } catch (e) {}
  }

  /// ENVIAR INVITACIÓN DE CHAT EFÍMERO
  /// iOS y Android: USA ntfy
  Future<void> sendChatInvitationNotification({
    required String targetUserId,
    required String inviterName,
    required String invitationId,
    Map<String, dynamic>? additionalData,
  }) async {
    if (!_isInitialized) {
      return;
    }

    try {
      await NtfyNotificationService.instance.sendChatInvitationNotification(
        targetUserId: targetUserId,
        inviterName: inviterName,
        invitationId: invitationId,
        additionalData: additionalData,
      );
    } catch (e) {}
  }

  /// Método genérico para notificaciones personalizadas
  Future<void> sendCustomNotification({
    required String targetUserId,
    required String title,
    required String message,
    String? priority,
    List<Map<String, String>>? actions,
    Map<String, dynamic>? data,
  }) async {
    if (!_isInitialized) {
      return;
    }

    try {
      await NtfyNotificationService.instance.sendCustomNotification(
        targetUserId: targetUserId,
        title: title,
        message: message,
        priority: priority,
        actions: actions,
        data: data,
      );
    } catch (e) {}
  }

  /// Obtener estrategia de notificaciones por plataforma
  String _getNotificationStrategy() {
    if (Platform.isIOS) {
      return 'iOS: VoIP para videollamadas, ntfy para mensajes';
    } else {
      return 'Android: ntfy para todo';
    }
  }

  /// Mostrar configuración actual
  void _printConfiguration() {
    if (Platform.isIOS) {
    } else {}
  }

  /// Obtener información completa del servicio
  Map<String, dynamic> getServiceInfo() {
    final ntfyInfo = NtfyNotificationService.instance.getServiceInfo();

    return {
      'isInitialized': _isInitialized,
      'userId': _userId,
      'platform': Platform.operatingSystem,
      'strategy': _getNotificationStrategy(),
      'ntfyService': ntfyInfo,
      'voipHandlesVideoCallsOnIOS': Platform.isIOS,
      'serviceMapping': _getServiceMapping(),
    };
  }

  /// Mapeo de qué servicio maneja cada tipo de notificación
  Map<String, String> _getServiceMapping() {
    if (Platform.isIOS) {
      return {
        'video_calls': 'VoIP (existente)',
        'audio_calls': 'ntfy',
        'messages': 'ntfy',
        'chat_invitations': 'ntfy',
        'custom': 'ntfy',
      };
    } else {
      return {
        'video_calls': 'ntfy',
        'audio_calls': 'ntfy',
        'messages': 'ntfy',
        'chat_invitations': 'ntfy',
        'custom': 'ntfy',
      };
    }
  }

  /// Obtener URLs de suscripción ntfy para el cliente
  Map<String, String> getNtfySubscriptionTopics(String userId) {
    return NtfyNotificationService.instance.getSubscriptionTopics(userId);
  }

  /// Verificar si el sistema VoIP maneja un tipo de notificación
  bool isHandledByVoIP(String notificationType) {
    return Platform.isIOS && notificationType == 'video_calls';
  }

  /// Verificar si ntfy maneja un tipo de notificación
  bool isHandledByNtfy(String notificationType) {
    if (Platform.isIOS) {
      return notificationType != 'video_calls';
    } else {
      return true; // Android: ntfy maneja todo
    }
  }

  /// Limpiar recursos
  void dispose() {
    NtfyNotificationService.instance.dispose();
    // NO tocamos VoIP - el sistema existente lo maneja

    _isInitialized = false;
    _userId = null;
    _instance = null;
  }
}
