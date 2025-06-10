import 'dart:convert';
import 'package:flutterputter/services/api_service.dart';
import 'package:flutterputter/services/socket_service.dart';

class CallService {
  SocketService? _socketService;
  String? _currentCallId;
  String? _currentReceiverId;
  // Almacenar datos adicionales para resolver problemas con el emisor/receptor
  final Map<String, Map<String, dynamic>> _callData = {};

  SocketService? get socket => _socketService;

  SocketService? getSocketService() => _socketService;

  // Obtener datos de la última llamada por ID
  Map<String, dynamic>? getLastCallData(String callId) {
    return _callData[callId];
  }

  /*───────────  iniciar llamada  ───────────*/
  Future<Map<String, dynamic>> initiateCall(
      String receiverId, String loginToken) async {
    if (receiverId.isEmpty) throw Exception('receiverId vacío');
    if (loginToken.isEmpty) throw Exception('login token vacío');

    // cerrar llamada previa
    if (_currentCallId != null) {
      try {
        await endCall(_currentCallId!, loginToken);
      } catch (_) {}
    }

    final data = await ApiService.postAndGetMap(
      '/api/calls/initiate',
      {'receiverId': receiverId},
      loginToken,
    );

    _currentCallId = data['callId'];
    _currentReceiverId = receiverId;

    // Imprimir datos detallados para debugging
    print(
        '⚡️ INICIANDO LLAMADA: callId=${data['callId']}, receiverId=$receiverId');
    print(
        '⚡️ Respuesta API: turnConfig=${data['turnConfig'] != null}, token=${data['token'] != null}');

    // Almacenar datos de la llamada para uso futuro
    if (data['callId'] != null) {
      // Guardar datos enriquecidos
      _callData[data['callId']] = Map<String, dynamic>.from(data);
      // Agregar datos adicionales que no vienen en la respuesta
      _callData[data['callId']]!['initiatorId'] =
          loginToken.split('.')[1]; // Intentar extraer ID del token
      _callData[data['callId']]!['receiverId'] = receiverId;

      print('📝 Datos de llamada almacenados para callId: ${data['callId']}');
    }

    // IMPORTANTE: Usar la instancia singleton existente en lugar de crear una nueva
    final existingSocketService = SocketService.getInstance();
    if (existingSocketService != null) {
      print(
          '✅ Usando instancia singleton de SocketService para iniciar llamada');
      _socketService = existingSocketService;

      // Actualizar token si es necesario
      _socketService!.updateToken(loginToken);
    } else {
      // Solo crear nueva instancia si no existe ninguna
      print('🔌 Creando nueva instancia SocketService (primera vez)');
      _ensureSocketIsReady(loginToken);
    }

    final callToken = data['token'] ?? loginToken;

    // 2️⃣ unirse a la sala enviando el call-token + `to` (SIEMPRE incluir el destinatario)
    print('🔔 Enviando join-call con to=$receiverId');
    _socketService!.joinCall(
      data['callId'],
      callToken,
      to: receiverId, // Siempre incluir el destinatario
    );

    return data;
  }

  /*───────────  método para asegurar que el socket está listo  ───────────*/
  void _ensureSocketIsReady(String loginToken) {
    // Si no hay socket, lo creamos
    if (_socketService == null) {
      print('🔌 Creando nueva instancia SocketService');
      _socketService = SocketService(token: loginToken);
      return;
    }

    // Actualizar token si es necesario
    print('🔄 Verificando token en SocketService existente');
    _socketService!.updateToken(loginToken);

    // Solo refrescar si la conexión está caída
    if (!_socketService!.isConnected()) {
      print('🔄 Reconectando SocketService existente');
      _socketService!.refreshConnection();
    } else {
      print('✅ SocketService ya conectado - no es necesario reconectar');
    }
  }

  /*───────────  aceptar llamada  ───────────*/
  Future<Map<String, dynamic>> acceptCall(
      String callId, String loginToken) async {
    if (callId.isEmpty) throw Exception('callId vacío');
    if (loginToken.isEmpty) throw Exception('login token vacío');

    // cerrar otra llamada si existiera
    if (_currentCallId != null && _currentCallId != callId) {
      try {
        await endCall(_currentCallId!, loginToken);
      } catch (_) {}
    }

    final data = await ApiService.postAndGetMap(
      '/api/calls/accept',
      {'callId': callId},
      loginToken,
    );

    _currentCallId = callId;

    // Enriquecer los datos con información adicional
    // Primero, intentar recuperar datos guardados previamente
    final socketCallData = SocketService.getIncomingCallData(callId);
    String? initiatorId;

    if (socketCallData != null && socketCallData.containsKey('initiatorId')) {
      print('🔍 Encontrados datos previos para callId: $callId');

      // Guardar el initiatorId para pasarlo al SocketService
      initiatorId = socketCallData['initiatorId'];

      // Agregar datos que puedan faltar
      if (!data.containsKey('initiatorId')) {
        data['initiatorId'] = initiatorId;
        print('✅ Agregado initiatorId de datos Socket: ${data['initiatorId']}');
      }
    } else {
      print(
          '⚠️ No se encontraron datos previos del emisor para el callId: $callId');
      // Intentar extraer initiatorId de otras fuentes
      if (data.containsKey('initiatorId')) {
        initiatorId = data['initiatorId'];
        print('✅ Usando initiatorId de la respuesta API: $initiatorId');
      }
    }

    // IMPORTANTE: Usar la instancia singleton existente en lugar de crear una nueva
    final existingSocketService = SocketService.getInstance();
    if (existingSocketService != null) {
      print(
          '✅ Usando instancia singleton de SocketService para aceptar llamada');
      _socketService = existingSocketService;

      // Importante: Asegurar que el callId actual esté configurado
      _socketService!.setCallData(callId, initiatorId);

      // Actualizar token si hay uno nuevo específico para la llamada
      if (data['token'] != null) {
        _socketService!.updateToken(data['token']);
      }
    } else {
      // Solo crear nueva instancia si no existe ninguna (caso muy raro)
      print(
          '⚠️ No se encontró instancia singleton, creando nueva (esto no debería pasar)');
      _ensureSocketIsReady(loginToken);

      // Importante: Guardar el callId actual en el socket service
      if (_socketService != null) {
        _socketService!.setCallData(callId, initiatorId);
      }
    }

    // Manualmente unirnos a la llamada para asegurar que estamos en la sala
    print(
        '✅ Uniendo explícitamente a sala de llamada: $callId, initiatorId: $initiatorId');
    _socketService!.joinCall(callId, data['token'] ?? loginToken,
        to: initiatorId // Pasamos el initiatorId para asegurar que esté disponible
        );

    return data;
  }

  /*───────────  rechazar / finalizar  ───────────*/
  Future<bool> rejectCall(String callId, String loginToken) async {
    final ok = await _postBool('/api/calls/reject', callId, loginToken);
    if (ok) _currentCallId = null; // ← limpiar estado
    return ok;
  }

  Future<bool> endCall(String callId, String loginToken) async {
    final ok = await _postBool('/api/calls/end', callId, loginToken);
    if (ok) {
      _socketService?.leaveCall(callId);
      _currentCallId = null;
    }
    return ok;
  }

  /*───────────  premium check  ───────────*/
  Future<bool> checkPremiumStatus(String token) async {
    final res = await ApiService.get('/api/calls/check-premium', token);
    if (res.body.isEmpty) return false;
    final data = jsonDecode(res.body);
    return (data is Map) &&
        data['success'] == true &&
        data['isPremium'] == true;
  }

  /*───────────  utils  ───────────*/
  Future<bool> _postBool(String url, String callId, String token) async {
    final res = await ApiService.post(url, {'callId': callId}, token);
    if (res.body.isEmpty) return res.statusCode < 300;
    try {
      final data = jsonDecode(res.body);
      return (data is Map) ? data['success'] == true : res.statusCode < 300;
    } catch (_) {
      return res.statusCode < 300;
    }
  }

  void dispose() {
    _socketService?.dispose();
    _socketService = null;
    _currentCallId = null;
    _currentReceiverId = null;
  }
}
