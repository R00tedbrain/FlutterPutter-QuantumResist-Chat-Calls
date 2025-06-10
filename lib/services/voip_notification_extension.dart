import 'dart:io';
import 'package:flutterputter/services/voip_integration.dart';

/// Extensión OPCIONAL para añadir VoIP al sistema de notificaciones existente
/// NO ALTERA el NotificationManager actual, solo añade funcionalidad VoIP
class VoIPNotificationExtension {
  static VoIPNotificationExtension? _instance;
  static VoIPNotificationExtension get instance =>
      _instance ??= VoIPNotificationExtension._internal();

  VoIPNotificationExtension._internal();

  /// Enviar notificación híbrida: WebSocket + VoIP (iOS)
  /// Mantiene la funcionalidad existente y añade VoIP como complemento
  Future<void> sendHybridCallNotification({
    required String callId,
    required String callerName,
    required String receiverId,
    String? callerAvatar,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      print('🔔 Enviando notificación híbrida para llamada: $callId');

      // 1. MANTENER: El sistema WebSocket/notificaciones existente sigue funcionando
      print('📡 Sistema WebSocket mantiene su funcionalidad normal');

      // 2. AÑADIR: Notificación VoIP solo en iOS como complemento
      if (Platform.isIOS) {
        await VoIPIntegration.instance.sendVoIPNotification(
          callId: callId,
          callerName: callerName,
          receiverId: receiverId,
          callerAvatar: callerAvatar,
        );
        print('✅ Notificación VoIP complementaria enviada');
      } else {
        print(
            '🔔 VoIP no disponible en esta plataforma, usando solo WebSocket');
      }

      print('✅ Notificación híbrida completada');
    } catch (e) {
      print('❌ Error en notificación híbrida: $e');
      // El error en VoIP no afecta el sistema principal
    }
  }

  /// Terminar llamada en ambos sistemas (WebSocket + VoIP)
  Future<void> endHybridCall(String callId) async {
    try {
      print('🔚 Terminando llamada híbrida: $callId');

      // 1. El sistema WebSocket maneja su lógica normal
      print('📡 Sistema WebSocket maneja el fin de llamada normalmente');

      // 2. Terminar también en VoIP si está disponible
      if (Platform.isIOS) {
        await VoIPIntegration.instance.endVoIPCall(callId);
        print('✅ Llamada VoIP terminada como complemento');
      }

      print('✅ Llamada híbrida terminada completamente');
    } catch (e) {
      print('❌ Error terminando llamada híbrida: $e');
    }
  }

  /// Obtener estado de llamadas en ambos sistemas
  Future<Map<String, dynamic>> getHybridCallStatus() async {
    try {
      final voipCalls = Platform.isIOS
          ? await VoIPIntegration.instance.getActiveVoIPCalls()
          : <dynamic>[];

      return {
        'platform': Platform.operatingSystem,
        'voipSupported': Platform.isIOS,
        'activeVoIPCalls': voipCalls.length,
        'voipCallDetails': voipCalls,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('❌ Error obteniendo estado híbrido: $e');
      return {
        'platform': Platform.operatingSystem,
        'voipSupported': false,
        'activeVoIPCalls': 0,
        'error': e.toString(),
      };
    }
  }

  /// Limpiar recursos híbridos
  Future<void> dispose() async {
    try {
      // Limpiar VoIP si está disponible
      if (Platform.isIOS) {
        VoIPIntegration.instance.dispose();
      }
      print('✅ Recursos híbridos limpiados');
    } catch (e) {
      print('❌ Error limpiando recursos híbridos: $e');
    }
  }
}
