import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:universal_html/html.dart' as html;
import '../models/active_session.dart';
import 'api_service.dart';

/// Servicio para gestionar sesiones activas como Signal/WhatsApp/Telegram
class SessionManagementService extends ChangeNotifier {
  static const String _keyCurrentSessionId = 'current_session_id';
  static const String _keyActiveSessions = 'active_sessions_cache';
  static const String _keyLastDeviceInfo = 'last_device_info';
  static const String _keySessionSettings = 'session_settings';
  static const String _keyAuthToken = 'auth_token';

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Singleton pattern
  static final SessionManagementService _instance =
      SessionManagementService._internal();
  factory SessionManagementService() => _instance;
  SessionManagementService._internal();

  String? _currentSessionId;
  String? _authToken;
  List<ActiveSession> _activeSessions = [];
  QRLinkingData? _currentQRLinking;
  Timer? _qrExpirationTimer;
  Timer? _sessionHeartbeatTimer;
  bool _initialized = false;

  // Configuraciones
  bool _allowMultipleSessions =
      false; // ✅ CAMBIADO: Solo 1 sesión por usuario para máxima seguridad
  int _maxSessions = 1; // ✅ CAMBIADO: Máximo 1 sesión
  int _sessionTimeoutMinutes = 30;

  // Callbacks para eventos
  Function(ActiveSession)? onNewSessionLinked;
  Function(String sessionId)? onSessionTerminated;
  Function()? onSessionConflict;
  Function(QRLinkingData)? onQRGenerated;
  Function(String error)? onError;

  // Getters
  String? get currentSessionId => _currentSessionId;
  String? get authToken => _authToken;
  List<ActiveSession> get activeSessions => List.unmodifiable(_activeSessions);
  QRLinkingData? get currentQRLinking => _currentQRLinking;
  bool get hasActiveSessions => _activeSessions.isNotEmpty;
  bool get allowMultipleSessions => _allowMultipleSessions;
  int get maxSessions => _maxSessions;
  bool get initialized => _initialized;

  /// Establecer token de autenticación
  Future<void> setAuthToken(String token) async {
    _authToken = token;
    await _storage.write(key: _keyAuthToken, value: token);

    // ✅ NUEVO: Iniciar heartbeat solo cuando se establece el token
    if (_initialized) {
      _startSessionHeartbeat();
    }
  }

  /// ✅ NUEVO: Actualizar sessionId desde el servidor (al hacer login)
  Future<void> updateSessionIdFromServer(String serverSessionId) async {
    if (serverSessionId.isNotEmpty && serverSessionId != _currentSessionId) {
      _currentSessionId = serverSessionId;
      await _storage.write(key: _keyCurrentSessionId, value: serverSessionId);

      // Detener heartbeat anterior si existía
      stopHeartbeat();

      // Reiniciar heartbeat con nueva sesión
      _startSessionHeartbeat();

      notifyListeners();
    }
  }

  /// Inicializar el servicio
  Future<void> initialize({String? userId}) async {
    if (_initialized) return;

    try {
      // ✅ SIMPLIFICADO: Solo cargar lo esencial
      _authToken = await _storage.read(key: _keyAuthToken);
      _currentSessionId = await _storage.read(key: _keyCurrentSessionId);

      // Generar sesión si no existe
      if (_currentSessionId == null) {
        _currentSessionId = _generateSessionId();
        await _storage.write(
            key: _keyCurrentSessionId, value: _currentSessionId);
      }

      // ✅ SIMPLIFICADO: No cargar configuraciones ni caché por ahora para evitar lag
      // Solo configuraciones básicas
      _allowMultipleSessions = false;
      _maxSessions = 1;
      _sessionTimeoutMinutes = 30;

      // ✅ SIMPLIFICADO: No iniciar heartbeat inmediatamente para evitar congelamiento
      // Se iniciará cuando sea necesario

      _initialized = true;

      notifyListeners();
    } catch (e) {
      _initialized =
          true; // Marcar como inicializado aunque falle para evitar loops
    }
  }

  /// Obtener sesiones activas del servidor
  Future<List<ActiveSession>> fetchActiveSessions() async {
    if (_authToken == null) {
      return _activeSessions; // Devolver caché local
    }

    try {
      final response = await ApiService.sessionsRequest(
        'GET',
        '/active',
        token: _authToken,
        sessionId: _currentSessionId,
      );

      if (response['success'] == true || response['sessions'] != null) {
        final sessionsList = response['sessions'] as List? ?? [];
        _activeSessions = sessionsList
            .map((sessionJson) => ActiveSession.fromJson(sessionJson))
            .toList();

        // ✅ NUEVO: Identificar correctamente la sesión actual
        _identifyCurrentSession();

        // Guardar en caché
        await _saveCachedSessions();

        notifyListeners();
        return _activeSessions;
      } else {
        throw Exception('Respuesta inválida del servidor');
      }
    } catch (e) {
      if (onError != null) {
        onError!('Error obteniendo sesiones: $e');
      }
      return _activeSessions; // Devolver caché local en caso de error
    }
  }

  /// Verificar si hay conflicto de sesión al hacer login
  Future<bool> checkSessionConflict({String? userId}) async {
    try {
      // Obtener sesiones actuales del servidor
      await fetchActiveSessions();

      // Si no permite múltiples sesiones y hay sesiones activas
      if (!_allowMultipleSessions && _activeSessions.isNotEmpty) {
        // Verificar si alguna sesión no es la actual
        final otherSessions = _activeSessions
            .where((session) =>
                session.sessionId != _currentSessionId && session.isActive)
            .toList();

        if (otherSessions.isNotEmpty) {
          if (onSessionConflict != null) {
            onSessionConflict!();
          }
          return true;
        }
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// ✅ ELIMINADO: QR linking ya no necesario con 1 sesión por usuario
  @Deprecated('QR linking eliminado - solo 1 sesión por usuario permitida')
  Future<QRLinkingData?> generateQRForLinking({String? fromUserId}) async {
    if (onError != null) {
      onError!(
          'Funcionalidad no disponible: solo se permite 1 sesión por usuario');
    }
    return null;
  }

  /// ✅ ELIMINADO: QR linking ya no necesario con 1 sesión por usuario
  @Deprecated('QR linking eliminado - solo 1 sesión por usuario permitida')
  Future<bool> linkSessionWithQR(String qrData) async {
    if (onError != null) {
      onError!(
          'Funcionalidad no disponible: solo se permite 1 sesión por usuario');
    }
    return false;
  }

  /// ✅ MEJORADO: Cerrar sesión específica (primero servidor, luego local)
  Future<bool> terminateSession(String sessionId) async {
    if (_authToken == null) {
      return false;
    }

    try {
      // ✅ MEJORADO: Intentar cerrar en servidor primero con timeout
      try {
        final response = await ApiService.sessionsRequest(
          'DELETE',
          '/$sessionId',
          token: _authToken,
          sessionId: _currentSessionId,
        ).timeout(const Duration(seconds: 5));

        if (response['success'] == true || response['message'] != null) {
          // Sesión cerrada en servidor
        }
      } catch (serverError) {
        // Error cerrando en servidor
        // Continuando con cierre local...
      }

      // ✅ SIEMPRE cerrar localmente también
      final sessionExists =
          _activeSessions.any((session) => session.sessionId == sessionId);

      if (sessionExists) {
        // Cerrar sesión localmente
        _activeSessions
            .removeWhere((session) => session.sessionId == sessionId);

        // Si es la sesión actual, detener heartbeat
        if (sessionId == _currentSessionId) {
          stopHeartbeat();
        }

        // ✅ NUEVO: Actualizar caché local
        await _saveCachedSessions();

        // ✅ NUEVO: Refrescar desde servidor para confirmar
        Timer(const Duration(milliseconds: 1000), () {
          refreshActiveSessions();
        });

        notifyListeners();
        return true;
      } else {
        // ✅ NUEVO: Refrescar desde servidor por si acaso
        await refreshActiveSessions();
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// ✅ ACTUALIZADO: Cerrar todas las sesiones excepto la actual (llamada real al servidor)
  Future<bool> terminateAllOtherSessions() async {
    if (_authToken == null) {
      return false;
    }

    try {
      final response = await ApiService.sessionsRequest(
        'DELETE',
        '/others/all',
        token: _authToken,
        sessionId: _currentSessionId,
      );

      if (response['success'] == true) {
        // final terminatedCount = response['terminatedCount'] ?? 0;

        // Actualizar sesiones locales
        await fetchActiveSessions();

        notifyListeners();
        return true;
      } else {
        throw Exception(response['message'] ?? 'Error desconocido');
      }
    } catch (e) {
      if (onError != null) {
        onError!('Error cerrando sesiones: $e');
      }
      return false;
    }
  }

  /// ✅ ACTUALIZADO: Enviar heartbeat al servidor
  Future<bool> sendHeartbeat() async {
    // Verificaciones más estrictas
    if (_authToken == null) {
      return false; // Silencioso si no hay token
    }

    if (_currentSessionId == null) {
      return false; // Silencioso si no hay sesión actual
    }

    try {
      final response = await ApiService.sessionsRequest(
        'POST',
        '/heartbeat',
        data: {'timestamp': DateTime.now().toIso8601String()},
        token: _authToken,
        sessionId: _currentSessionId,
      );

      // ✅ ARREGLADO: El servidor devuelve {"message":"Heartbeat actualizado","lastActivity":"..."}
      if (response['message'] != null &&
          (response['message'].toString().contains('actualizado') ||
              response['message'].toString().contains('Heartbeat'))) {
        return true;
      } else if (response['success'] == true) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      // ✅ NUEVO: Si el error es 404 (sesión no encontrada), detener heartbeat automáticamente
      if (e.toString().contains('404') ||
          e.toString().contains('Sesión no encontrada')) {
        stopHeartbeat();
        _currentSessionId = null;
        _authToken = null;
      }

      return false;
    }
  }

  /// Actualizar configuraciones de sesión
  Future<void> updateSessionSettings({
    bool? allowMultiple,
    int? maxSessions,
    int? timeoutMinutes,
  }) async {
    try {
      if (allowMultiple != null) _allowMultipleSessions = allowMultiple;
      if (maxSessions != null) _maxSessions = maxSessions;
      if (timeoutMinutes != null) _sessionTimeoutMinutes = timeoutMinutes;

      await _saveSettings();
      notifyListeners();
    } catch (e) {
      // Error actualizando configuraciones
    }
  }

  /// ✅ ACTUALIZADO: Obtener sesiones activas del servidor (reemplaza refreshActiveSessions)
  Future<void> refreshActiveSessions() async {
    try {
      // Verificar autenticación primero
      if (_authToken == null) {
        // No lanzar excepción, solo usar caché local
        notifyListeners();
        return;
      }

      // Intentar obtener del servidor
      await fetchActiveSessions();
    } catch (e) {
      // En lugar de lanzar la excepción, manejarla apropiadamente
      if (e.toString().contains('404') ||
          e.toString().contains('Sesión no encontrada')) {
        // Limpiar sesión actual
        _currentSessionId = null;
        _authToken = null;
        await _storage.delete(key: _keyCurrentSessionId);
        await _storage.delete(key: _keyAuthToken);

        // Limpiar sesiones activas
        _activeSessions.clear();
        await _storage.delete(key: _keyActiveSessions);

        notifyListeners();

        // Relanzar solo errores de autenticación para que la UI los maneje
        throw Exception('Sesión no encontrada - necesita autenticación');
      } else if (e.toString().contains('401') ||
          e.toString().contains('No autorizado')) {
        throw Exception('No autorizado - necesita autenticación');
      } else {
        // Para otros errores, usar caché local silenciosamente
        notifyListeners();
        // No relanzar errores de red para evitar crashes
      }
    }
  }

  /// ✅ NUEVO: Detener heartbeat
  void stopHeartbeat() {
    _sessionHeartbeatTimer?.cancel();
    _sessionHeartbeatTimer = null;
  }

  /// ✅ NUEVO: Logout completo - limpiar todo el servicio
  Future<void> logout() async {
    // Detener heartbeat inmediatamente
    stopHeartbeat();

    // Limpiar token y sesión
    _authToken = null;
    _currentSessionId = null;
    _activeSessions.clear();

    // Limpiar QR si está activo
    if (_currentQRLinking != null) {
      _qrExpirationTimer?.cancel();
      _qrExpirationTimer = null;
      _currentQRLinking = null;
    }

    // Limpiar almacenamiento
    try {
      await _storage.delete(key: _keyAuthToken);
      await _storage.delete(key: _keyCurrentSessionId);
      await _storage.delete(key: _keyActiveSessions);
    } catch (e) {
      // Error limpiando almacenamiento
    }

    // Resetear estado
    _initialized = false;

    notifyListeners();
  }

  // === MÉTODOS PRIVADOS ===

  Future<DeviceInfo> _detectDeviceInfo() async {
    try {
      if (kIsWeb) {
        // Información del navegador web
        final userAgent = html.window.navigator.userAgent;
        String browser = 'Desconocido';
        String os = 'Desconocido';

        // Detectar navegador
        if (userAgent.contains('Chrome')) {
          browser = 'Chrome';
        } else if (userAgent.contains('Firefox'))
          browser = 'Firefox';
        else if (userAgent.contains('Safari'))
          browser = 'Safari';
        else if (userAgent.contains('Edge')) browser = 'Edge';

        // Detectar OS
        if (userAgent.contains('Mac')) {
          os = 'macOS';
        } else if (userAgent.contains('Windows'))
          os = 'Windows';
        else if (userAgent.contains('Linux'))
          os = 'Linux';
        else if (userAgent.contains('iPhone'))
          os = 'iOS';
        else if (userAgent.contains('Android')) os = 'Android';

        return DeviceInfo(
          type: 'web',
          browser: browser,
          os: os,
          version: '1.0.0',
        );
      } else {
        // Información móvil/desktop
        return DeviceInfo(
          type: defaultTargetPlatform == TargetPlatform.iOS
              ? 'ios'
              : defaultTargetPlatform == TargetPlatform.android
                  ? 'android'
                  : 'desktop',
          os: defaultTargetPlatform.name,
          version: '1.0.0',
        );
      }
    } catch (e) {
      return DeviceInfo(type: 'unknown');
    }
  }

  String _generateSessionId() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomValue = random.nextInt(999999);
    return 'session_${timestamp}_$randomValue';
  }

  String _generateLinkingToken() {
    final random = Random();
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(32, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  /// ✅ ARREGLADO: Heartbeat real al servidor con logs correctos
  void _startSessionHeartbeat() {
    _sessionHeartbeatTimer?.cancel();
    _sessionHeartbeatTimer =
        Timer.periodic(const Duration(minutes: 5), (timer) async {
      // ✅ NUEVO: Verificar si aún debe enviar heartbeats
      if (_authToken == null || _currentSessionId == null) {
        stopHeartbeat();
        return;
      }

      final success = await sendHeartbeat();
      if (success) {
        // Heartbeat exitoso - sesión activa
      } else {
        // Heartbeat falló - posible sesión expirada
      }
    });
  }

  Future<void> _loadSettings() async {
    try {
      final settingsJson = await _storage.read(key: _keySessionSettings);
      if (settingsJson != null) {
        final settings = jsonDecode(settingsJson);
        _allowMultipleSessions = settings['allowMultiple'] ?? false;
        _maxSessions = settings['maxSessions'] ?? 5;
        _sessionTimeoutMinutes = settings['timeoutMinutes'] ?? 30;
      }
    } catch (e) {
      // Error cargando configuraciones
    }
  }

  Future<void> _saveSettings() async {
    try {
      final settings = {
        'allowMultiple': _allowMultipleSessions,
        'maxSessions': _maxSessions,
        'timeoutMinutes': _sessionTimeoutMinutes,
      };
      await _storage.write(
          key: _keySessionSettings, value: jsonEncode(settings));
    } catch (e) {
      // Error guardando configuraciones
    }
  }

  Future<void> _loadCachedSessions() async {
    try {
      final sessionsJson = await _storage.read(key: _keyActiveSessions);
      if (sessionsJson != null) {
        final sessionsList = jsonDecode(sessionsJson) as List;
        _activeSessions =
            sessionsList.map((json) => ActiveSession.fromJson(json)).toList();
      }
    } catch (e) {
      // Error cargando sesiones en caché
    }
  }

  Future<void> _saveCachedSessions() async {
    try {
      final sessionsJson =
          jsonEncode(_activeSessions.map((s) => s.toJson()).toList());
      await _storage.write(key: _keyActiveSessions, value: sessionsJson);
    } catch (e) {
      // Error guardando sesiones en caché
    }
  }

  Future<void> _createMockSessions() async {
    // Solo para testing - crear sesiones simuladas
    final currentDevice = await _detectDeviceInfo();

    _activeSessions = [
      ActiveSession(
        sessionId: _currentSessionId ?? _generateSessionId(),
        userId: 'current_user',
        deviceInfo: currentDevice,
        linkedAt: DateTime.now().subtract(const Duration(days: 1)),
        lastActivity: DateTime.now(),
        isCurrentSession: true,
        isPrimarySession: true,
      ),
      if (_allowMultipleSessions) ...[
        ActiveSession(
          sessionId: _generateSessionId(),
          userId: 'current_user',
          deviceInfo: DeviceInfo(type: 'ios', os: 'iOS 17.0'),
          linkedAt: DateTime.now().subtract(const Duration(hours: 2)),
          lastActivity: DateTime.now().subtract(const Duration(minutes: 15)),
          isCurrentSession: false,
          isPrimarySession: false,
          linkedBy: _currentSessionId,
        ),
        ActiveSession(
          sessionId: _generateSessionId(),
          userId: 'current_user',
          deviceInfo: DeviceInfo(type: 'android', os: 'Android 14'),
          linkedAt: DateTime.now().subtract(const Duration(days: 3)),
          lastActivity: DateTime.now().subtract(const Duration(hours: 2)),
          isCurrentSession: false,
          isPrimarySession: false,
          linkedBy: _currentSessionId,
        ),
      ],
    ];

    await _saveCachedSessions();
  }

  @override
  void dispose() {
    _qrExpirationTimer?.cancel();
    _sessionHeartbeatTimer?.cancel();
    super.dispose();
  }

  /// ✅ SIMPLIFICADO: Identificar la sesión actual en la lista del servidor
  void _identifyCurrentSession() {
    if (_activeSessions.isEmpty) return;

    try {
      // ✅ SIMPLIFICADO: Solo buscar por sessionId del token JWT primero
      String? tokenSessionId = _extractSessionIdFromToken();

      if (tokenSessionId != null) {
        final currentSession = _activeSessions
            .where((s) => s.sessionId == tokenSessionId)
            .firstOrNull;

        if (currentSession != null) {
          return;
        }
      }

      // ✅ SIMPLIFICADO: Fallback simple - usar la primera sesión activa
      if (_activeSessions.isNotEmpty) {
        final firstActiveSession = _activeSessions.first;
        _currentSessionId = firstActiveSession.sessionId;

        // Guardar para próxima vez
        _storage.write(key: _keyCurrentSessionId, value: _currentSessionId);
      }
    } catch (e) {
      // En caso de error, no hacer nada - usar sesión existente
    }
  }

  /// ✅ ARREGLADO: Extraer sessionId del token JWT
  String? _extractSessionIdFromToken() {
    if (_authToken == null) return null;

    try {
      // Decodificar JWT (solo la parte del payload, sin verificar firma)
      final parts = _authToken!.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];

      // ✅ ARREGLADO: Calcular padding correcto para base64
      String paddedPayload = payload;
      final missingPadding = 4 - (payload.length % 4);
      if (missingPadding != 4) {
        paddedPayload = payload + ('=' * missingPadding);
      }

      final decoded = utf8.decode(base64Url.decode(paddedPayload));
      final jsonPayload = json.decode(decoded) as Map<String, dynamic>;

      final sessionId = jsonPayload['sessionId'] as String?;

      return sessionId;
    } catch (e) {
      // No es crítico - usar fallback
      return null;
    }
  }

  /// ✅ NUEVO: Obtener la sesión actual de la lista
  ActiveSession? _getCurrentSessionFromList() {
    return _activeSessions
        .where((s) => s.sessionId == _currentSessionId)
        .firstOrNull;
  }

  /// ✅ NUEVO: Obtener UserAgent actual
  String _getCurrentUserAgent() {
    if (kIsWeb) {
      return html.window.navigator.userAgent;
    }
    return 'Flutter App';
  }
}
