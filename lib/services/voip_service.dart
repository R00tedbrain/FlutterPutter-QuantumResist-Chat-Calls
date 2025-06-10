import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'voip_token_service.dart';

/// Servicio VoIP nativo para iOS
/// NO ALTERA la lógica existente de WebSocket/WebRTC
/// Solo AÑADE notificaciones VoIP nativas como complemento
class VoIPService {
  static VoIPService? _instance;
  static VoIPService get instance => _instance ??= VoIPService._internal();

  VoIPService._internal();

  bool _isInitialized = false;
  String? _currentUserId;
  String? _voipServerUrl;
  String? _authToken;

  // MethodChannel para comunicación con código nativo iOS
  static const MethodChannel _channel = MethodChannel('voip_native');

  /// Inicializar servicio VoIP (SOLO iOS)
  Future<void> initialize({
    required String userId,
    required String token,
    String? voipServerUrl,
  }) async {
    if (_isInitialized) {
      print('🔔 VoIP Service ya está inicializado');
      return;
    }

    // Solo funciona en iOS
    if (!Platform.isIOS) {
      print('🔔 VoIP Service: Solo disponible en iOS');
      return;
    }

    try {
      _currentUserId = userId;
      _authToken = token;
      // URL HTTPS del servidor VoIP a través del proxy nginx
      _voipServerUrl = voipServerUrl ?? 'https://clubprivado.ws';

      // Inicializar VoipTokenService
      await VoipTokenService.instance.initialize(
        userId: userId,
        authToken: token,
      );

      // Configurar listeners para eventos del plugin nativo
      _setupNativeListeners();

      // Inicializar VoIP nativo
      await _channel.invokeMethod('initializeVoIP');

      // Notificar al plugin nativo que envíe tokens pendientes
      // await _channel.invokeMethod('sendPendingTokenIfNeeded'); // Comentado temporalmente

      _isInitialized = true;
      print('✅ VoIP Service inicializado correctamente para usuario: $userId');
      print('📱 Usando VoIP nativo (PushKit + CallKit)');
    } catch (e) {
      print('❌ Error inicializando VoIP Service: $e');
    }
  }

  /// Configurar listeners para eventos nativos
  void _setupNativeListeners() {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onVoIPTokenReceived':
          final token = call.arguments['token'] as String;
          // Usar VoipTokenService para registro robusto
          await VoipTokenService.instance.registerVoipToken(token);
          // Mantener registro legacy por compatibilidad
          await _registerVoIPToken(token);
          break;
        case 'onCallAnswered':
          final callUUID = call.arguments['callUUID'] as String;
          final timestamp = call.arguments['timestamp'] as double?;
          final source = call.arguments['source'] as String?;
          print(
              '✅ [VoIP] Llamada aceptada desde CallKit: $callUUID (source: $source)');
          _handleCallAnswered(callUUID, timestamp: timestamp, source: source);
          break;
        case 'onCallEnded':
          final callUUID = call.arguments['callUUID'] as String;
          final timestamp = call.arguments['timestamp'] as double?;
          final source = call.arguments['source'] as String?;
          print(
              '🔚 [VoIP] Llamada terminada desde CallKit: $callUUID (source: $source)');
          _handleCallEnded(callUUID, timestamp: timestamp, source: source);
          break;
      }
    });
  }

  /// Registrar token VoIP en el servidor
  Future<void> _registerVoIPToken(String voipToken) async {
    try {
      print('📱 Token VoIP recibido: ${voipToken.substring(0, 10)}...');

      // Registrar en el servidor VoIP
      final response = await http.post(
        Uri.parse('$_voipServerUrl/api/register-voip-token'),
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': 'i4UBgKHhQYzV*Hu9sSHcj@QS3jc3JX',
        },
        body: jsonEncode({
          'userId': _currentUserId,
          'deviceToken': voipToken,
          'platform': 'ios',
        }),
      );

      if (response.statusCode == 200) {
        print('✅ Token VoIP registrado exitosamente en el servidor');
      } else {
        print(
            '❌ Error registrando token VoIP: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error registrando token VoIP: $e');
    }
  }

  /// Mostrar llamada entrante usando CallKit nativo
  Future<void> showIncomingCall({
    required String callId,
    required String callerName,
    String? callerAvatar,
  }) async {
    if (!Platform.isIOS) return;

    try {
      await _channel.invokeMethod('reportIncomingCall', {
        'callerName': callerName,
        'hasVideo': true,
      });
      print('✅ Llamada VoIP nativa mostrada: $callId de $callerName');
    } catch (e) {
      print('❌ Error mostrando llamada VoIP nativa: $e');
    }
  }

  /// Manejar llamada aceptada
  void _handleCallAnswered(String callUUID,
      {double? timestamp, String? source}) {
    print(
        '✅ Llamada VoIP aceptada: $callUUID (timestamp: $timestamp, source: $source)');

    // NUEVO: Notificar al backend que la llamada fue aceptada desde CallKit
    if (source == 'callkit_native') {
      print('🔄 [VoIP] Sincronizando aceptación de CallKit con backend');
      _notifyBackendCallAccepted(callUUID);
    }
  }

  /// NUEVO: Notificar al backend que la llamada fue aceptada desde CallKit
  Future<void> _notifyBackendCallAccepted(String callId) async {
    if (_authToken == null) {
      print('⚠️ [VoIP] No hay token de autenticación para notificar backend');
      return;
    }

    try {
      print('🔄 [VoIP] Notificando al backend aceptación de llamada: $callId');

      final response = await http.post(
        Uri.parse('$_voipServerUrl/signaling/api/calls/accept'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
        body: jsonEncode({
          'callId': callId,
          'source': 'callkit_native',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        }),
      );

      if (response.statusCode == 200) {
        print('✅ [VoIP] Backend notificado de aceptación CallKit: $callId');
      } else {
        print(
            '❌ [VoIP] Error notificando backend (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      print('❌ [VoIP] Error notificando aceptación al backend: $e');
    }
  }

  /// Manejar llamada terminada
  void _handleCallEnded(String callUUID, {double? timestamp, String? source}) {
    print(
        '🔚 Llamada VoIP terminada: $callUUID (timestamp: $timestamp, source: $source)');

    // NUEVO: Notificar al backend que la llamada fue terminada desde CallKit
    if (source == 'callkit_native') {
      print('🔄 [VoIP] Sincronizando finalización de CallKit con backend');
      _notifyBackendCallEnded(callUUID);
    }
  }

  /// NUEVO: Notificar al backend que la llamada fue terminada desde CallKit
  Future<void> _notifyBackendCallEnded(String callId) async {
    if (_authToken == null) {
      print('⚠️ [VoIP] No hay token de autenticación para notificar backend');
      return;
    }

    try {
      print(
          '🔄 [VoIP] Notificando al backend finalización de llamada: $callId');

      final response = await http.post(
        Uri.parse('$_voipServerUrl/signaling/api/calls/end'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
        body: jsonEncode({
          'callId': callId,
          'source': 'callkit_native',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final duration = responseData['duration'] ?? 0;
        print(
            '✅ [VoIP] Backend notificado de finalización CallKit: $callId (duración: ${duration}s)');
      } else {
        print(
            '❌ [VoIP] Error notificando backend (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      print('❌ [VoIP] Error notificando finalización al backend: $e');
    }
  }

  /// Terminar llamada activa usando CallKit
  Future<void> endCall(String callUUID) async {
    if (!Platform.isIOS) return;

    try {
      print('🔚 Terminando llamada VoIP: $callUUID');
      await _channel.invokeMethod('endCall', {
        'callUUID': callUUID,
      });
      print('✅ Llamada VoIP terminada exitosamente: $callUUID');
    } catch (e) {
      print('❌ Error terminando llamada VoIP: $e');
    }
  }

  /// Terminar todas las llamadas activas
  Future<void> endAllCalls() async {
    if (!Platform.isIOS) return;

    try {
      print('🔚 Terminando todas las llamadas VoIP');
      await _channel.invokeMethod('endAllCalls');
      print('✅ Todas las llamadas VoIP terminadas');
    } catch (e) {
      print('❌ Error terminando todas las llamadas VoIP: $e');
    }
  }

  /// Obtener llamadas activas (no implementado en CallKit básico)
  Future<List<Map<String, dynamic>>> getActiveCalls() async {
    if (!Platform.isIOS) return [];

    try {
      print('📋 Obteniendo llamadas activas');
      return [];
    } catch (e) {
      print('❌ Error obteniendo llamadas activas: $e');
      return [];
    }
  }

  /// Limpiar recursos
  void dispose() {
    print('🧹 Limpiando recursos VoIP Service');
    _isInitialized = false;
    _currentUserId = null;
    _voipServerUrl = null;
    _authToken = null;
    VoipTokenService.instance.dispose();
  }

  /// Verificar si está inicializado
  bool get isInitialized => _isInitialized;

  /// Obtener ID del usuario actual
  String? get currentUserId => _currentUserId;
}
