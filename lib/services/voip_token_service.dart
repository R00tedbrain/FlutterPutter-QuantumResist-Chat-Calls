import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';

/// Servicio para gestionar el registro de tokens VoIP con el servidor
/// Mantiene la persistencia y reintenta el registro si falla
class VoipTokenService {
  static VoipTokenService? _instance;
  static VoipTokenService get instance =>
      _instance ??= VoipTokenService._internal();

  VoipTokenService._internal();

  // URL del servidor VPS configurado
  static const String _baseUrl = 'http://192.142.10.106:3004';
  static const String _voipRegisterEndpoint =
      '$_baseUrl/api/register-voip-token';

  Timer? _retryTimer;
  String? _pendingToken;
  String? _currentUserId;
  String? _authToken;

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Inicializar el servicio con las credenciales del usuario
  Future<void> initialize({
    required String userId,
    required String authToken,
  }) async {
    _currentUserId = userId;
    _authToken = authToken;

    // Guardar en SharedPreferences para persistencia
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentUserId', userId);
    await prefs.setString('authToken', authToken);

    // Si hay un token pendiente, intentar enviarlo
    await _checkAndSendPendingToken();
  }

  /// Registrar un nuevo token VoIP
  Future<bool> registerVoipToken(String token) async {
    if (_currentUserId == null || _authToken == null) {
      await _savePendingToken(token);
      return false;
    }

    try {
      // Obtener información del dispositivo
      final deviceData = await _getDeviceInfo();

      final response = await http
          .post(
            Uri.parse(_voipRegisterEndpoint),
            headers: {
              'Content-Type': 'application/json',
              'X-API-Key': 'i4UBgKHhQYzV*Hu9sSHcj@QS3jc3JX',
            },
            body: jsonEncode({
              'userId': _currentUserId,
              'deviceToken': token,
              'platform': 'ios',
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        await _clearPendingToken();
        _cancelRetryTimer();

        // Guardar el último token registrado
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('lastVoipToken', token);
        await prefs.setString(
            'lastVoipTokenDate', DateTime.now().toIso8601String());

        return true;
      } else {
        await _scheduleRetry(token);
        return false;
      }
    } catch (e) {
      await _scheduleRetry(token);
      return false;
    }
  }

  /// Registrar token APNs para notificaciones regulares
  Future<bool> registerApnsToken(String token) async {
    if (_currentUserId == null || _authToken == null) {
      return false;
    }

    try {
      final deviceData = await _getDeviceInfo();

      final response = await http
          .post(
            Uri.parse(
                '$_baseUrl/api/register-apns-token'), // Endpoint para APNs (si existe)
            headers: {
              'Content-Type': 'application/json',
              'X-API-Key': 'i4UBgKHhQYzV*Hu9sSHcj@QS3jc3JX',
            },
            body: jsonEncode({
              'userId': _currentUserId,
              'deviceToken': token,
              'platform': 'ios',
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Verificar si hay tokens pendientes y enviarlos
  Future<void> _checkAndSendPendingToken() async {
    final prefs = await SharedPreferences.getInstance();
    final pendingToken = prefs.getString('pendingVoipToken');

    if (pendingToken != null) {
      await registerVoipToken(pendingToken);
    }
  }

  /// Guardar token pendiente para enviar después
  Future<void> _savePendingToken(String token) async {
    _pendingToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pendingVoipToken', token);
  }

  /// Limpiar token pendiente
  Future<void> _clearPendingToken() async {
    _pendingToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pendingVoipToken');
  }

  /// Programar reintento de envío
  Future<void> _scheduleRetry(String token) async {
    await _savePendingToken(token);

    _cancelRetryTimer();

    // Reintentar cada 30 segundos
    _retryTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      final success = await registerVoipToken(token);
      if (success) {
        timer.cancel();
      }
    });
  }

  /// Cancelar timer de reintentos
  void _cancelRetryTimer() {
    _retryTimer?.cancel();
    _retryTimer = null;
  }

  /// Obtener información del dispositivo
  Future<Map<String, dynamic>> _getDeviceInfo() async {
    try {
      if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return {
          'model': iosInfo.model,
          'systemVersion': iosInfo.systemVersion,
          'name': iosInfo.name,
          'identifierForVendor': iosInfo.identifierForVendor,
          'isPhysicalDevice': iosInfo.isPhysicalDevice,
          'localizedModel': iosInfo.localizedModel,
        };
      } else {
        final androidInfo = await _deviceInfo.androidInfo;
        return {
          'model': androidInfo.model,
          'manufacturer': androidInfo.manufacturer,
          'androidVersion': androidInfo.version.release,
          'sdkInt': androidInfo.version.sdkInt,
          'brand': androidInfo.brand,
          'device': androidInfo.device,
          'isPhysicalDevice': androidInfo.isPhysicalDevice,
        };
      }
    } catch (e) {
      return {'error': 'Could not get device info'};
    }
  }

  /// Cerrar sesión y limpiar tokens
  Future<void> logout() async {
    _cancelRetryTimer();

    // Notificar al servidor que se va a cerrar sesión
    if (_currentUserId != null && _authToken != null) {
      try {
        await http.delete(
          Uri.parse('$_baseUrl/api/unregister-voip-token'),
          headers: {
            'X-API-Key': 'i4UBgKHhQYzV*Hu9sSHcj@QS3jc3JX',
          },
          body: jsonEncode({
            'userId': _currentUserId,
          }),
        );
      } catch (e) {}
    }

    // Limpiar datos locales
    _currentUserId = null;
    _authToken = null;
    _pendingToken = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentUserId');
    await prefs.remove('authToken');
    await prefs.remove('pendingVoipToken');
    await prefs.remove('lastVoipToken');
    await prefs.remove('lastVoipTokenDate');
  }

  /// Verificar si el token actual necesita renovarse
  Future<bool> needsTokenRefresh() async {
    final prefs = await SharedPreferences.getInstance();
    final lastTokenDateStr = prefs.getString('lastVoipTokenDate');

    if (lastTokenDateStr == null) {
      return true; // No hay token registrado
    }

    try {
      final lastTokenDate = DateTime.parse(lastTokenDateStr);
      final daysSinceLastToken =
          DateTime.now().difference(lastTokenDate).inDays;

      // Apple recomienda renovar tokens cada 30 días
      return daysSinceLastToken > 30;
    } catch (e) {
      return true;
    }
  }

  /// Limpiar recursos
  void dispose() {
    _cancelRetryTimer();
    _instance = null;
  }
}
