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
      print('🔔💬 [EPHEMERAL-NTFY] Ya está inicializado');
      return;
    }

    try {
      _currentUserId = userId;

      print('🔔💬 [EPHEMERAL-NTFY] === INICIALIZANDO INTEGRACIÓN ===');
      print('🔔💬 [EPHEMERAL-NTFY] Usuario: $userId');
      print('🔔💬 [EPHEMERAL-NTFY] Plataforma: ${Platform.operatingSystem}');

      // Inicializar el servicio híbrido
      await HybridNotificationService.instance.initialize(
        userId: userId,
        token: token,
      );

      _isInitialized = true;
      print('✅ [EPHEMERAL-NTFY] Integración inicializada correctamente');
      print(
          '✅ [EPHEMERAL-NTFY] Chat efímero ahora usará ntfy para notificaciones');
    } catch (e) {
      print('❌ [EPHEMERAL-NTFY] Error inicializando: $e');
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
      print('❌ [EPHEMERAL-NTFY] Servicio no inicializado');
      return;
    }

    try {
      print('🔔💬 [EPHEMERAL-NTFY] === INVITACIÓN DE CHAT ===');
      print('🔔💬 [EPHEMERAL-NTFY] Target: $targetUserId');
      print('🔔💬 [EPHEMERAL-NTFY] Inviter: $inviterName');
      print('🔔💬 [EPHEMERAL-NTFY] InvitationId: $invitationId');

      await HybridNotificationService.instance.sendChatInvitationNotification(
        targetUserId: targetUserId,
        inviterName: inviterName,
        invitationId: invitationId,
        additionalData: additionalData,
      );

      print('✅ [EPHEMERAL-NTFY] Notificación de invitación enviada');
    } catch (e) {
      print('❌ [EPHEMERAL-NTFY] Error enviando invitación: $e');
    }
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
      print('❌ [EPHEMERAL-NTFY] Servicio no inicializado');
      return;
    }

    try {
      print('🔔💬 [EPHEMERAL-NTFY] === MENSAJE DE CHAT ===');
      print('🔔💬 [EPHEMERAL-NTFY] Target: $targetUserId');
      print('🔔💬 [EPHEMERAL-NTFY] Sender: $senderName');
      print('🔔💬 [EPHEMERAL-NTFY] Room: $roomId');
      print(
          '🔔💬 [EPHEMERAL-NTFY] Mensaje: ${messageText.length > 50 ? "${messageText.substring(0, 50)}..." : messageText}');

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

      print('✅ [EPHEMERAL-NTFY] Notificación de mensaje enviada');
    } catch (e) {
      print('❌ [EPHEMERAL-NTFY] Error enviando mensaje: $e');
    }
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
      print('❌ [EPHEMERAL-NTFY] Servicio no inicializado');
      return;
    }

    try {
      print('🔔💬 [EPHEMERAL-NTFY] === SALA CREADA ===');
      print('🔔💬 [EPHEMERAL-NTFY] Target: $targetUserId');
      print('🔔💬 [EPHEMERAL-NTFY] Partner: $partnerName');
      print('🔔💬 [EPHEMERAL-NTFY] Room: $roomId');

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

      print('✅ [EPHEMERAL-NTFY] Notificación de sala creada enviada');
    } catch (e) {
      print('❌ [EPHEMERAL-NTFY] Error enviando sala creada: $e');
    }
  }

  /// NUEVO: Mostrar notificación del sistema para invitaciones
  Future<void> _showSystemNotificationForInvitation(
      ChatInvitation invitation) async {
    try {
      print('🔔💬 [EPHEMERAL-NTFY] === INICIANDO NOTIFICACIÓN DEL SISTEMA ===');
      print('🔔💬 [EPHEMERAL-NTFY] InvitationId: ${invitation.id}');
      print('🔔💬 [EPHEMERAL-NTFY] FromUserId: ${invitation.fromUserId}');

      // PRIMERO: Verificar si LocalNotificationService está inicializado
      try {
        // Forzar inicialización si no está hecha
        await LocalNotificationService.instance.initialize();
        print('🔔💬 [EPHEMERAL-NTFY] ✅ LocalNotificationService inicializado');
      } catch (initError) {
        print(
            '🔔💬 [EPHEMERAL-NTFY] ❌ Error inicializando LocalNotificationService: $initError');
        return;
      }

      // SEGUNDO: Mostrar notificación con logs detallados
      print(
          '🔔💬 [EPHEMERAL-NTFY] 📱 Llamando a showChatInvitationNotification...');

      await LocalNotificationService.instance.showChatInvitationNotification(
        invitationId: invitation.id,
        senderName: invitation.fromUserId, // Usamos fromUserId por ahora
        message: 'Te ha enviado una invitación de chat efímero',
      );

      print(
          '✅ [EPHEMERAL-NTFY] 🎉 Notificación del sistema enviada para: ${invitation.id}');

      // TERCERO: Verificar estado después de mostrar
      print('🔔💬 [EPHEMERAL-NTFY] === NOTIFICACIÓN COMPLETADA ===');
    } catch (e) {
      print(
          '❌ [EPHEMERAL-NTFY] Error crítico mostrando notificación del sistema: $e');
      print('❌ [EPHEMERAL-NTFY] Stack trace: ${StackTrace.current}');
    }
  }

  /// NUEVO: Mostrar notificación del sistema para mensajes
  Future<void> _showSystemNotificationForMessage(dynamic message) async {
    try {
      print(
          '🔔💬 [EPHEMERAL-NTFY] === INICIANDO NOTIFICACIÓN DE MENSAJE DEL SISTEMA ===');
      print('🔔💬 [EPHEMERAL-NTFY] MessageId: ${message.id}');
      print('🔔💬 [EPHEMERAL-NTFY] SenderId: ${message.senderId}');

      // FILTRAR: No mostrar notificaciones para mensajes del sistema o especiales
      if (message.senderId == 'system' ||
          message.senderId == 'me' ||
          message.content.startsWith('VERIFICATION_CODES:') ||
          message.content.startsWith('CLEANUP_MESSAGES:') ||
          message.content.startsWith('AUTOCONFIG_DESTRUCTION:') ||
          message.content.startsWith('DESTRUCTION_COUNTDOWN:') ||
          message.content.startsWith('SCREENSHOT_NOTIFICATION:')) {
        print(
            '🔔💬 [EPHEMERAL-NTFY] ⚠️ Mensaje filtrado - no se muestra notificación');
        return;
      }

      // PRIMERO: Verificar si LocalNotificationService está inicializado
      try {
        // Forzar inicialización si no está hecha
        await LocalNotificationService.instance.initialize();
        print('🔔💬 [EPHEMERAL-NTFY] ✅ LocalNotificationService inicializado');
      } catch (initError) {
        print(
            '🔔💬 [EPHEMERAL-NTFY] ❌ Error inicializando LocalNotificationService: $initError');
        return;
      }

      // SEGUNDO: Mostrar notificación con logs detallados
      print('🔔💬 [EPHEMERAL-NTFY] 📱 Llamando a showMessageNotification...');

      await LocalNotificationService.instance.showMessageNotification(
        messageId: message.id,
        senderName: message.senderId, // Usamos senderId como nombre
        messageText:
            'Tienes un mensaje', // Sin mostrar contenido por privacidad
      );

      print(
          '✅ [EPHEMERAL-NTFY] 🎉 Notificación de mensaje del sistema enviada para: ${message.id}');

      // TERCERO: Verificar estado después de mostrar
      print('🔔💬 [EPHEMERAL-NTFY] === NOTIFICACIÓN DE MENSAJE COMPLETADA ===');
    } catch (e) {
      print(
          '❌ [EPHEMERAL-NTFY] Error crítico mostrando notificación de mensaje del sistema: $e');
      print('❌ [EPHEMERAL-NTFY] Stack trace: ${StackTrace.current}');
    }
  }

  /// Configurar callbacks del servicio de chat existente
  /// COMPLEMENTA el sistema existente sin alterarlo
  void setupEphemeralChatServiceCallbacks(EphemeralChatService chatService) {
    if (!_isInitialized) {
      print(
          '❌ [EPHEMERAL-NTFY] No se pueden configurar callbacks - no inicializado');
      return;
    }

    print('🔔💬 [EPHEMERAL-NTFY] === CONFIGURANDO CALLBACKS ===');
    print('🔔💬 [EPHEMERAL-NTFY] Configurando callbacks para chat efímero...');

    // Guardar callbacks originales para no perderlos
    final originalOnInvitationReceived = chatService.onInvitationReceived;
    final originalOnMessageReceived = chatService.onMessageReceived;
    final originalOnRoomCreated = chatService.onRoomCreated;

    // AMPLIAR (no reemplazar) callback de invitaciones recibidas
    chatService.onInvitationReceived = (invitation) {
      print(
          '🔔💬 [EPHEMERAL-NTFY] Invitación recibida detectada: ${invitation.id}');

      // MANTENER: Ejecutar callback original primero
      if (originalOnInvitationReceived != null) {
        originalOnInvitationReceived(invitation);
      }

      // NUEVO: Mostrar notificación del sistema para invitaciones
      _showSystemNotificationForInvitation(invitation);
    };

    // AMPLIAR callback de mensajes recibidos
    chatService.onMessageReceived = (message) {
      print('🔔💬 [EPHEMERAL-NTFY] Mensaje recibido detectado: ${message.id}');

      // MANTENER: Ejecutar callback original primero
      if (originalOnMessageReceived != null) {
        originalOnMessageReceived(message);
      }

      // NUEVO: Mostrar notificación del sistema para mensajes
      _showSystemNotificationForMessage(message);
    };

    // AMPLIAR callback de sala creada
    chatService.onRoomCreated = (room) {
      print('🔔💬 [EPHEMERAL-NTFY] Sala creada detectada: ${room.id}');

      // MANTENER: Ejecutar callback original primero
      if (originalOnRoomCreated != null) {
        originalOnRoomCreated(room);
      }

      // AÑADIR: Log para futura implementación
      print(
          '🔔💬 [EPHEMERAL-NTFY] Sala creada procesada por callback original');
      // Nota: Las notificaciones de sala creada se envían desde el servidor
    };

    print('✅ [EPHEMERAL-NTFY] Callbacks configurados correctamente');
    print('✅ [EPHEMERAL-NTFY] Sistema híbrido listo (original + ntfy)');
  }

  /// Obtener URLs de suscripción para el cliente
  /// El cliente debe suscribirse a estos topics para recibir notificaciones
  Map<String, String> getSubscriptionUrls(String userId) {
    if (!_isInitialized) {
      return {};
    }

    final topics =
        HybridNotificationService.instance.getNtfySubscriptionTopics(userId);

    print('🔔💬 [EPHEMERAL-NTFY] === URLs DE SUSCRIPCIÓN ===');
    topics.forEach((type, url) {
      print('🔔💬 [EPHEMERAL-NTFY] $type: $url');
    });

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
    print('🔔💬 [EPHEMERAL-NTFY] [SERVER] Enviar notificación:');
    print('🔔💬 [EPHEMERAL-NTFY] [SERVER] Tipo: $notificationType');
    print('🔔💬 [EPHEMERAL-NTFY] [SERVER] Target: $targetUserId');
    print('🔔💬 [EPHEMERAL-NTFY] [SERVER] Data: $data');
    print(
        '🔔💬 [EPHEMERAL-NTFY] [SERVER] URL: https://clubprivado.ws/ntfy/user_${notificationType}_$targetUserId');
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

    print('🔔💬 [EPHEMERAL-NTFY] Integración limpiada');
  }
}
