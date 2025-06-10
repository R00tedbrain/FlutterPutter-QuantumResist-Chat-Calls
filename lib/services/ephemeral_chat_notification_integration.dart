import 'dart:io';
import 'hybrid_notification_service.dart';
import 'ephemeral_chat_service.dart';
import 'local_notification_service.dart';
import '../models/chat_invitation.dart';

/// Integración de notificaciones ntfy para chat efímero
/// NO ALTERA el código existente de EphemeralChatService
/// Solo AÑADE notificaciones ntfy como complemento
class EphemeralChatNotificationIntegration {
  static EphemeralChatNotificationIntegration? _instance;
  static EphemeralChatNotificationIntegration get instance =>
      _instance ??= EphemeralChatNotificationIntegration._internal();

  EphemeralChatNotificationIntegration._internal();

  bool _isInitialized = false;
  String? _currentUserId;

  /// Inicializar integración de notificaciones
  Future<void> initialize({
    required String userId,
    required String token,
  }) async {
    if (_isInitialized) {
      return;
    }

    try {
      _currentUserId = userId;

      // Inicializar el servicio híbrido
      await HybridNotificationService.instance.initialize(
        userId: userId,
        token: token,
      );

      _isInitialized = true;
    } catch (e) {
      rethrow;
    }
  }

  /// Enviar notificación de invitación de chat
  /// Se llama cuando se crea una invitación
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
      await HybridNotificationService.instance.sendChatInvitationNotification(
        targetUserId: targetUserId,
        inviterName: inviterName,
        invitationId: invitationId,
        additionalData: additionalData,
      );
    } catch (e) {}
  }

  /// Enviar notificación de mensaje en chat efímero
  /// Se llama cuando se recibe un mensaje
  Future<void> sendMessageNotification({
    required String targetUserId,
    required String senderName,
    required String messageText,
    required String roomId,
    Map<String, dynamic>? additionalData,
  }) async {
    if (!_isInitialized) {
      return;
    }

    try {
      await HybridNotificationService.instance.sendMessageNotification(
        targetUserId: targetUserId,
        senderName: senderName,
        messageText: messageText,
        chatType: 'ephemeral',
        additionalData: {
          'roomId': roomId,
          'messageType': 'ephemeral_chat',
          ...?additionalData,
        },
      );
    } catch (e) {}
  }

  /// Enviar notificación de sala creada
  /// Se llama cuando se acepta una invitación y se crea la sala
  Future<void> sendRoomCreatedNotification({
    required String targetUserId,
    required String roomId,
    required String partnerName,
    Map<String, dynamic>? additionalData,
  }) async {
    if (!_isInitialized) {
      return;
    }

    try {
      await HybridNotificationService.instance.sendCustomNotification(
        targetUserId: targetUserId,
        title: 'Chat conectado',
        message: '$partnerName se ha unido al chat',
        priority: 'default',
        data: {
          'type': 'room_created',
          'roomId': roomId,
          'partnerName': partnerName,
          'chatType': 'ephemeral',
          ...?additionalData,
        },
      );
    } catch (e) {}
  }

  /// NUEVO: Mostrar notificación del sistema para invitaciones
  Future<void> _showSystemNotificationForInvitation(
      ChatInvitation invitation) async {
    try {
      // PRIMERO: Verificar si LocalNotificationService está inicializado
      try {
        // Forzar inicialización si no está hecha
        await LocalNotificationService.instance.initialize();
      } catch (initError) {
        return;
      }

      // SEGUNDO: Mostrar notificación con logs detallados

      await LocalNotificationService.instance.showChatInvitationNotification(
        invitationId: invitation.id,
        senderName: invitation.fromUserId, // Usamos fromUserId por ahora
        message: 'Te ha enviado una invitación de chat efímero',
      );

      // TERCERO: Verificar estado después de mostrar
    } catch (e) {}
  }

  /// NUEVO: Mostrar notificación del sistema para mensajes
  Future<void> _showSystemNotificationForMessage(dynamic message) async {
    try {
      // FILTRAR: No mostrar notificaciones para mensajes del sistema o especiales
      if (message.senderId == 'system' ||
          message.senderId == 'me' ||
          message.content.startsWith('VERIFICATION_CODES:') ||
          message.content.startsWith('CLEANUP_MESSAGES:') ||
          message.content.startsWith('AUTOCONFIG_DESTRUCTION:') ||
          message.content.startsWith('DESTRUCTION_COUNTDOWN:') ||
          message.content.startsWith('SCREENSHOT_NOTIFICATION:')) {
        return;
      }

      // PRIMERO: Verificar si LocalNotificationService está inicializado
      try {
        // Forzar inicialización si no está hecha
        await LocalNotificationService.instance.initialize();
      } catch (initError) {
        return;
      }

      // SEGUNDO: Mostrar notificación con logs detallados

      await LocalNotificationService.instance.showMessageNotification(
        messageId: message.id,
        senderName: message.senderId, // Usamos senderId como nombre
        messageText:
            'Tienes un mensaje', // Sin mostrar contenido por privacidad
      );

      // TERCERO: Verificar estado después de mostrar
    } catch (e) {}
  }

  /// Configurar callbacks del servicio de chat existente
  /// COMPLEMENTA el sistema existente sin alterarlo
  void setupEphemeralChatServiceCallbacks(EphemeralChatService chatService) {
    if (!_isInitialized) {
      return;
    }

    // Guardar callbacks originales para no perderlos
    final originalOnInvitationReceived = chatService.onInvitationReceived;
    final originalOnMessageReceived = chatService.onMessageReceived;
    final originalOnRoomCreated = chatService.onRoomCreated;

    // AMPLIAR (no reemplazar) callback de invitaciones recibidas
    chatService.onInvitationReceived = (invitation) {
      // MANTENER: Ejecutar callback original primero
      if (originalOnInvitationReceived != null) {
        originalOnInvitationReceived(invitation);
      }

      // NUEVO: Mostrar notificación del sistema para invitaciones
      _showSystemNotificationForInvitation(invitation);
    };

    // AMPLIAR callback de mensajes recibidos
    chatService.onMessageReceived = (message) {
      // MANTENER: Ejecutar callback original primero
      if (originalOnMessageReceived != null) {
        originalOnMessageReceived(message);
      }

      // NUEVO: Mostrar notificación del sistema para mensajes
      _showSystemNotificationForMessage(message);
    };

    // AMPLIAR callback de sala creada
    chatService.onRoomCreated = (room) {
      // MANTENER: Ejecutar callback original primero
      if (originalOnRoomCreated != null) {
        originalOnRoomCreated(room);
      }

      // AÑADIR: Log para futura implementación
      // Nota: Las notificaciones de sala creada se envían desde el servidor
    };
  }

  /// Obtener URLs de suscripción para el cliente
  /// El cliente debe suscribirse a estos topics para recibir notificaciones
  Map<String, String> getSubscriptionUrls(String userId) {
    if (!_isInitialized) {
      return {};
    }

    final topics =
        HybridNotificationService.instance.getNtfySubscriptionTopics(userId);

    topics.forEach((type, url) {});

    return topics;
  }

  /// Método auxiliar para que el servidor envíe notificaciones
  /// Este método debe ser llamado desde tu backend/servidor
  static Future<void> sendFromServer({
    required String notificationType,
    required String targetUserId,
    required Map<String, dynamic> data,
  }) async {
    // Este método es para documentación del servidor
    // El servidor debe implementar llamadas HTTP directas a ntfy
  }

  /// Obtener información del servicio
  Map<String, dynamic> getServiceInfo() {
    return {
      'isInitialized': _isInitialized,
      'currentUserId': _currentUserId,
      'platform': Platform.operatingSystem,
      'hybridService': _isInitialized
          ? HybridNotificationService.instance.getServiceInfo()
          : null,
      'subscriptionTopics': _isInitialized && _currentUserId != null
          ? getSubscriptionUrls(_currentUserId!)
          : {},
    };
  }

  /// Limpiar recursos
  void dispose() {
    // NO limpiamos HybridNotificationService aquí porque puede ser usado por otros servicios
    _isInitialized = false;
    _currentUserId = null;
    _instance = null;
  }
}
