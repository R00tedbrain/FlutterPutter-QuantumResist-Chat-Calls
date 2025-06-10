import 'dart:io';
import 'package:flutterputter/services/voip_service.dart';

/// Integración VoIP que NO ALTERA la lógica existente
/// Solo añade notificaciones VoIP como complemento al sistema actual
class VoIPIntegration {
  static VoIPIntegration? _instance;
  static VoIPIntegration get instance =>
      _instance ??= VoIPIntegration._internal();

  VoIPIntegration._internal();

  bool _isInitialized = false;

  /// Inicializar integración VoIP
  Future<void> initialize() async {
    if (_isInitialized || !Platform.isIOS) {
      return;
    }

    try {
      print('🔔 Inicializando integración VoIP...');
      _isInitialized = true;
      print('✅ Integración VoIP inicializada');
    } catch (e) {
      print('❌ Error inicializando integración VoIP: $e');
    }
  }

  /// Enviar notificación VoIP para llamada entrante
  /// COMPLEMENTA el sistema WebSocket existente, NO lo reemplaza
  Future<void> sendVoIPNotification({
    required String callId,
    required String callerName,
    required String receiverId,
    String? callerAvatar,
  }) async {
    if (!Platform.isIOS || !_isInitialized) {
      print('🔔 VoIP no disponible en esta plataforma');
      return;
    }

    try {
      print('🔔 Enviando notificación VoIP para llamada: $callId');

      // Mostrar llamada entrante usando CallKit
      await VoIPService.instance.showIncomingCall(
        callId: callId,
        callerName: callerName,
        callerAvatar: callerAvatar,
      );

      print('✅ Notificación VoIP enviada exitosamente');
    } catch (e) {
      print('❌ Error enviando notificación VoIP: $e');
      // No es crítico, el sistema WebSocket sigue funcionando
    }
  }

  /// Terminar llamada VoIP
  Future<void> endVoIPCall(String callId) async {
    if (!Platform.isIOS || !_isInitialized) {
      return;
    }

    try {
      await VoIPService.instance.endCall(callId);
      print('✅ Llamada VoIP terminada: $callId');
    } catch (e) {
      print('❌ Error terminando llamada VoIP: $e');
    }
  }

  /// Terminar todas las llamadas VoIP
  Future<void> endAllVoIPCalls() async {
    if (!Platform.isIOS || !_isInitialized) {
      return;
    }

    try {
      await VoIPService.instance.endAllCalls();
      print('✅ Todas las llamadas VoIP terminadas');
    } catch (e) {
      print('❌ Error terminando todas las llamadas VoIP: $e');
    }
  }

  /// Obtener llamadas VoIP activas
  Future<List<dynamic>> getActiveVoIPCalls() async {
    if (!Platform.isIOS || !_isInitialized) {
      return [];
    }

    try {
      return await VoIPService.instance.getActiveCalls();
    } catch (e) {
      print('❌ Error obteniendo llamadas VoIP activas: $e');
      return [];
    }
  }

  /// Limpiar recursos
  void dispose() {
    _isInitialized = false;
    print('🔔 VoIP Integration disposed');
  }
}
