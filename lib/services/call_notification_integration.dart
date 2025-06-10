import 'dart:io';
import 'hybrid_notification_service.dart';

/// Integración de notificaciones para llamadas
/// NO ALTERA SocketService ni VoIP existente
/// Solo AÑADE notificaciones ntfy como complemento
class CallNotificationIntegration {
  static CallNotificationIntegration? _instance;
  static CallNotificationIntegration get instance =>
      _instance ??= CallNotificationIntegration._internal();

  CallNotificationIntegration._internal();

  bool _isInitialized = false;
  String? _currentUserId;

  /// Inicializar integración de notificaciones para llamadas
  Future<void> initialize({
    required String userId,
    required String token,
  }) async {
    if (_isInitialized) {
      return;
    }

    try {
      _currentUserId = userId;

      // El HybridNotificationService ya debe estar inicializado por AuthProvider
      // Solo verificamos que esté disponible
      final serviceInfo = HybridNotificationService.instance.getServiceInfo();
      if (!serviceInfo['isInitialized']) {
        throw Exception(
            'HybridNotificationService debe estar inicializado primero');
      }

      _isInitialized = true;
      _printCallStrategy();
    } catch (e) {
      rethrow;
    }
  }

  /// Enviar notificación de VIDEOLLAMADA (respeta VoIP en iOS)
  /// iOS: NO envía (VoIP maneja)
  /// Android: Envía ntfy
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
        // NO hacemos nada - el VoIP existente maneja esto
        return;
      }

      // Solo Android envía ntfy para videollamadas
      await HybridNotificationService.instance.sendVideoCallNotification(
        targetUserId: targetUserId,
        callerName: callerName,
        callId: callId,
        callerAvatar: callerAvatar,
        additionalData: additionalData,
      );
    } catch (e) {}
  }

  /// Enviar notificación de LLAMADA DE AUDIO
  /// iOS y Android: Envía ntfy
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
      await HybridNotificationService.instance.sendAudioCallNotification(
        targetUserId: targetUserId,
        callerName: callerName,
        callId: callId,
        callerAvatar: callerAvatar,
        additionalData: additionalData,
      );
    } catch (e) {}
  }

  /// Método genérico para cualquier tipo de llamada
  /// Detecta automáticamente el tipo y envía según las reglas
  Future<void> sendCallNotificationAuto({
    required String targetUserId,
    required String callerName,
    required String callId,
    String callType = 'video', // 'video' o 'audio'
    String? callerAvatar,
    Map<String, dynamic>? additionalData,
  }) async {
    if (!_isInitialized) {
      return;
    }

    if (callType == 'video') {
      await sendVideoCallNotification(
        targetUserId: targetUserId,
        callerName: callerName,
        callId: callId,
        callerAvatar: callerAvatar,
        additionalData: additionalData,
      );
    } else {
      await sendAudioCallNotification(
        targetUserId: targetUserId,
        callerName: callerName,
        callId: callId,
        callerAvatar: callerAvatar,
        additionalData: additionalData,
      );
    }
  }

  /// Método para integrar con SocketService SIN ALTERARLO
  /// Este método debe ser llamado DESDE el SocketService existente
  static Future<void> onIncomingCallReceived({
    required String callId,
    required String from,
    required String callerName,
    String callType = 'video',
    String? callerAvatar,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      if (instance._isInitialized) {
        await instance.sendCallNotificationAuto(
          targetUserId: 'current_user', // El usuario actual recibe la llamada
          callerName: callerName,
          callId: callId,
          callType: callType,
          callerAvatar: callerAvatar,
          additionalData: {
            'fromUserId': from,
            'source': 'socket_service',
            ...?additionalData,
          },
        );
      } else {}
    } catch (e) {}
  }

  /// Mostrar estrategia de llamadas por plataforma
  void _printCallStrategy() {
    if (Platform.isIOS) {
    } else {}
  }

  /// Verificar qué servicio maneja cada tipo de llamada
  String getHandlerForCallType(String callType) {
    if (Platform.isIOS && callType == 'video') {
      return 'VoIP nativo (existente)';
    } else {
      return 'ntfy';
    }
  }

  /// Obtener URLs de suscripción para llamadas
  Map<String, String> getSubscriptionUrls(String userId) {
    if (!_isInitialized) {
      return {};
    }

    return HybridNotificationService.instance.getNtfySubscriptionTopics(userId);
  }

  /// Obtener información del servicio
  Map<String, dynamic> getServiceInfo() {
    return {
      'isInitialized': _isInitialized,
      'currentUserId': _currentUserId,
      'platform': Platform.operatingSystem,
      'videoCallHandler': getHandlerForCallType('video'),
      'audioCallHandler': getHandlerForCallType('audio'),
      'hybridService': _isInitialized
          ? HybridNotificationService.instance.getServiceInfo()
          : null,
    };
  }

  /// Limpiar recursos
  void dispose() {
    _isInitialized = false;
    _currentUserId = null;
    _instance = null;
  }
}
