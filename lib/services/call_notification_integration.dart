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
      print('🔔📞 [CALL-NTFY] Ya está inicializado');
      return;
    }

    try {
      _currentUserId = userId;

      print('🔔📞 [CALL-NTFY] === INICIALIZANDO INTEGRACIÓN DE LLAMADAS ===');
      print('🔔📞 [CALL-NTFY] Usuario: $userId');
      print('🔔📞 [CALL-NTFY] Plataforma: ${Platform.operatingSystem}');
      print(
          '🔔📞 [CALL-NTFY] IMPORTANTE: iOS videollamadas mantienen VoIP nativo');

      // El HybridNotificationService ya debe estar inicializado por AuthProvider
      // Solo verificamos que esté disponible
      final serviceInfo = HybridNotificationService.instance.getServiceInfo();
      if (!serviceInfo['isInitialized']) {
        print('❌ [CALL-NTFY] HybridNotificationService no inicializado');
        throw Exception(
            'HybridNotificationService debe estar inicializado primero');
      }

      _isInitialized = true;
      print('✅ [CALL-NTFY] Integración de llamadas inicializada correctamente');
      _printCallStrategy();
    } catch (e) {
      print('❌ [CALL-NTFY] Error inicializando: $e');
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
      print('❌ [CALL-NTFY] Servicio no inicializado');
      return;
    }

    try {
      print('🔔📞 [CALL-NTFY] === VIDEOLLAMADA ===');
      print('🔔📞 [CALL-NTFY] Target: $targetUserId');
      print('🔔📞 [CALL-NTFY] Caller: $callerName');
      print('🔔📞 [CALL-NTFY] CallId: $callId');

      if (Platform.isIOS) {
        print(
            '🔔📞 [CALL-NTFY] iOS: OMITIENDO ntfy - VoIP nativo maneja videollamadas');
        print('🔔📞 [CALL-NTFY] El SocketService ya debe haber disparado VoIP');
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

      print('✅ [CALL-NTFY] Videollamada procesada');
    } catch (e) {
      print('❌ [CALL-NTFY] Error en videollamada: $e');
    }
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
      print('❌ [CALL-NTFY] Servicio no inicializado');
      return;
    }

    try {
      print('🔔📞 [CALL-NTFY] === LLAMADA DE AUDIO ===');
      print('🔔📞 [CALL-NTFY] Target: $targetUserId');
      print('🔔📞 [CALL-NTFY] Caller: $callerName');
      print('🔔📞 [CALL-NTFY] CallId: $callId');
      print('🔔📞 [CALL-NTFY] Enviando ntfy en todas las plataformas');

      await HybridNotificationService.instance.sendAudioCallNotification(
        targetUserId: targetUserId,
        callerName: callerName,
        callId: callId,
        callerAvatar: callerAvatar,
        additionalData: additionalData,
      );

      print('✅ [CALL-NTFY] Llamada de audio enviada');
    } catch (e) {
      print('❌ [CALL-NTFY] Error en llamada de audio: $e');
    }
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
      print('❌ [CALL-NTFY] Servicio no inicializado');
      return;
    }

    print('🔔📞 [CALL-NTFY] === LLAMADA AUTOMÁTICA ===');
    print('🔔📞 [CALL-NTFY] Tipo: $callType');
    print('🔔📞 [CALL-NTFY] Plataforma: ${Platform.operatingSystem}');

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
    print('🔔📞 [CALL-NTFY] [INTEGRATION] === LLAMADA RECIBIDA ===');
    print('🔔📞 [CALL-NTFY] [INTEGRATION] CallId: $callId');
    print('🔔📞 [CALL-NTFY] [INTEGRATION] From: $from');
    print('🔔📞 [CALL-NTFY] [INTEGRATION] Caller: $callerName');
    print('🔔📞 [CALL-NTFY] [INTEGRATION] Type: $callType');

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
        print('✅ [CALL-NTFY] [INTEGRATION] Notificación procesada');
      } else {
        print('❌ [CALL-NTFY] [INTEGRATION] Servicio no inicializado');
      }
    } catch (e) {
      print('❌ [CALL-NTFY] [INTEGRATION] Error: $e');
    }
  }

  /// Mostrar estrategia de llamadas por plataforma
  void _printCallStrategy() {
    print('🔔📞 [CALL-NTFY] === ESTRATEGIA DE LLAMADAS ===');

    if (Platform.isIOS) {
      print('🔔📞 [CALL-NTFY] iOS Videollamadas: VoIP nativo (NO ALTERADO)');
      print('🔔📞 [CALL-NTFY] iOS Llamadas audio: ntfy');
      print('🔔📞 [CALL-NTFY] iOS Otras llamadas: ntfy');
    } else {
      print('🔔📞 [CALL-NTFY] Android Videollamadas: ntfy');
      print('🔔📞 [CALL-NTFY] Android Llamadas audio: ntfy');
      print('🔔📞 [CALL-NTFY] Android Todas las llamadas: ntfy');
    }

    print('🔔📞 [CALL-NTFY] === FIN ESTRATEGIA ===');
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

    print('🔔📞 [CALL-NTFY] Integración de llamadas limpiada');
  }
}
