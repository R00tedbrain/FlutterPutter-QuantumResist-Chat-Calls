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

  // NUEVO: Callbacks para sincronizar con CallProvider
  Function(String callUUID)? _onCallKitAccepted;
  Function(String callUUID)? _onCallKitEnded;

  /// NUEVO: Configurar callbacks para sincronización con CallProvider
  void setCallKitCallbacks({
    Function(String callUUID)? onCallKitAccepted,
    Function(String callUUID)? onCallKitEnded,
  }) {
    _onCallKitAccepted = onCallKitAccepted;
    _onCallKitEnded = onCallKitEnded;
  }

  /// Inicializar servicio VoIP (SOLO iOS)
  Future<void> initialize({
    required String userId,
    required String token,
    String? voipServerUrl,
  }) async {
    if (_isInitialized) {
      return;
    }

    // Solo funciona en iOS
    if (!Platform.isIOS) {
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
    } catch (e) {
      // Error inicializando VoIP Service
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
          _handleCallAnswered(callUUID, timestamp: timestamp, source: source);
          break;
        case 'onCallEnded':
          final callUUID = call.arguments['callUUID'] as String;
          final timestamp = call.arguments['timestamp'] as double?;
          final source = call.arguments['source'] as String?;
          _handleCallEnded(callUUID, timestamp: timestamp, source: source);
          break;
      }
    });
  }

  /// Registrar token VoIP en el servidor
  Future<void> _registerVoIPToken(String voipToken) async {
    try {
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
        // Token VoIP registrado exitosamente en el servidor
      } else {
        // Error registrando token VoIP
      }
    } catch (e) {
      // Error registrando token VoIP
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
    } catch (e) {
      // Error mostrando llamada VoIP nativa
    }
  }

  /// Manejar llamada aceptada
  void _handleCallAnswered(String callUUID,
      {double? timestamp, String? source}) {
    print('📞 [VoIP] Llamada aceptada: $callUUID (source: $source)');

    // NUEVO: Notificar al backend que la llamada fue aceptada desde CallKit
    if (source == 'callkit_native') {
      _notifyBackendCallAccepted(callUUID);

      // CRÍTICO: Notificar al CallProvider para sincronizar estado
      if (_onCallKitAccepted != null) {
        print('🔄 [VoIP] Sincronizando aceptación con CallProvider...');
        _onCallKitAccepted!(callUUID);
      } else {
        print('⚠️ [VoIP] No hay callback configurado para CallProvider');
      }
    }
  }

  /// NUEVO: Notificar al backend que la llamada fue aceptada desde CallKit
  Future<void> _notifyBackendCallAccepted(String callId) async {
    if (_authToken == null) {
      return;
    }

    try {
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
        // Backend notificado de aceptación CallKit
      } else {
        // Error notificando backend
      }
    } catch (e) {
      // Error notificando aceptación al backend
    }
  }

  /// Manejar llamada terminada
  void _handleCallEnded(String callUUID, {double? timestamp, String? source}) {
    print('📞 [VoIP] Llamada terminada: $callUUID (source: $source)');

    // NUEVO: Notificar al backend que la llamada fue terminada desde CallKit
    if (source == 'callkit_native') {
      _notifyBackendCallEnded(callUUID);

      // CRÍTICO: Notificar al CallProvider para sincronizar estado
      if (_onCallKitEnded != null) {
        print('🔄 [VoIP] Sincronizando terminación con CallProvider...');
        _onCallKitEnded!(callUUID);
      } else {
        print('⚠️ [VoIP] No hay callback configurado para CallProvider');
      }
    }
  }

  /// NUEVO: Notificar al backend que la llamada fue terminada desde CallKit
  Future<void> _notifyBackendCallEnded(String callId) async {
    if (_authToken == null) {
      return;
    }

    try {
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
        // final responseData = jsonDecode(response.body);
        // final duration = responseData['duration'] ?? 0;
      } else {
        // Error notificando backend
      }
    } catch (e) {
      // Error notificando finalización al backend
    }
  }

  /// Terminar llamada activa usando CallKit
  Future<void> endCall(String callUUID) async {
    if (!Platform.isIOS) return;

    try {
      await _channel.invokeMethod('endCall', {
        'callUUID': callUUID,
      });
    } catch (e) {
      // Error terminando llamada VoIP
    }
  }

  /// Terminar todas las llamadas activas
  Future<void> endAllCalls() async {
    if (!Platform.isIOS) return;

    try {
      await _channel.invokeMethod('endAllCalls');
    } catch (e) {
      // Error terminando todas las llamadas VoIP
    }
  }

  /// Obtener llamadas activas (no implementado en CallKit básico)
  Future<List<Map<String, dynamic>>> getActiveCalls() async {
    if (!Platform.isIOS) return [];

    try {
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Limpiar recursos
  void dispose() {
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
