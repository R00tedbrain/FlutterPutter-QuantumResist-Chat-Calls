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
      _isInitialized = true;
    } catch (e) {}
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
      return;
    }

    try {
      // Mostrar llamada entrante usando CallKit
      await VoIPService.instance.showIncomingCall(
        callId: callId,
        callerName: callerName,
        callerAvatar: callerAvatar,
      );
    } catch (e) {
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
    } catch (e) {}
  }

  /// Terminar todas las llamadas VoIP
  Future<void> endAllVoIPCalls() async {
    if (!Platform.isIOS || !_isInitialized) {
      return;
    }

    try {
      await VoIPService.instance.endAllCalls();
    } catch (e) {}
  }

  /// Obtener llamadas VoIP activas
  Future<List<dynamic>> getActiveVoIPCalls() async {
    if (!Platform.isIOS || !_isInitialized) {
      return [];
    }

    try {
      return await VoIPService.instance.getActiveCalls();
    } catch (e) {
      return [];
    }
  }

  /// Limpiar recursos
  void dispose() {
    _isInitialized = false;
  }
}
