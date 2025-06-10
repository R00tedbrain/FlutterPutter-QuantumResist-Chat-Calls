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
      // 1. MANTENER: El sistema WebSocket/notificaciones existente sigue funcionando

      // 2. AÑADIR: Notificación VoIP solo en iOS como complemento
      if (Platform.isIOS) {
        await VoIPIntegration.instance.sendVoIPNotification(
          callId: callId,
          callerName: callerName,
          receiverId: receiverId,
          callerAvatar: callerAvatar,
        );
      } else {}
    } catch (e) {
      // El error en VoIP no afecta el sistema principal
    }
  }

  /// Terminar llamada en ambos sistemas (WebSocket + VoIP)
  Future<void> endHybridCall(String callId) async {
    try {
      // 1. El sistema WebSocket maneja su lógica normal

      // 2. Terminar también en VoIP si está disponible
      if (Platform.isIOS) {
        await VoIPIntegration.instance.endVoIPCall(callId);
      }
    } catch (e) {}
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
    } catch (e) {}
  }
}
