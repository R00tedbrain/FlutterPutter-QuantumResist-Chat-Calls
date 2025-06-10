import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/socket_service.dart';
import '../services/voip_service.dart';
import '../services/voip_token_service.dart';
import '../services/hybrid_notification_service.dart';

/// Servicio para mantener la sesión persistente en background
/// Gestiona reconexión automática y mantiene viva la conexión
class SessionPersistenceService {
  static SessionPersistenceService? _instance;
  static SessionPersistenceService get instance =>
      _instance ??= SessionPersistenceService._internal();

  SessionPersistenceService._internal();

  // Estado de la sesión
  bool _isInitialized = false;
  String? _currentUserId;
  String? _authToken;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;

  // Servicios
  final SocketService _socketService = SocketService();
  final VoIPService _voipService = VoIPService.instance;
  final HybridNotificationService _notificationService =
      HybridNotificationService.instance;

  // Conectividad
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _hasConnection = true;

  // Platform channel para iOS background
  static const _backgroundChannel = MethodChannel('background_service');

  /// Inicializar servicio de persistencia
  Future<void> initialize({
    required String userId,
    required String authToken,
  }) async {
    if (_isInitialized) {
      return;
    }

    _currentUserId = userId;
    _authToken = authToken;

    // Guardar credenciales para recuperación
    await _saveCredentials(userId, authToken);

    // Inicializar servicios
    await _initializeServices();

    // Configurar listeners de conectividad
    _setupConnectivityListener();

    // Configurar heartbeat para mantener conexión viva
    _startHeartbeat();

    // Configurar reconexión automática
    _setupAutoReconnect();

    // En iOS, registrar para ejecución en background
    if (Platform.isIOS) {
      await _registerBackgroundExecution();
    }

    _isInitialized = true;
  }

  /// Inicializar todos los servicios necesarios
  Future<void> _initializeServices() async {
    // Asegurarse de que Socket esté conectado
    if (!_socketService.isConnected()) {
      // Socket se conecta automáticamente al crearse con token

      // Esperar conexión con timeout
      int attempts = 0;
      while (!_socketService.isConnected() && attempts < 10) {
        await Future.delayed(const Duration(milliseconds: 500));
        attempts++;
      }
    }

    // Inicializar VoIP para iOS
    if (Platform.isIOS && !_voipService.isInitialized) {
      await _voipService.initialize(
        userId: _currentUserId!,
        token: _authToken!,
      );
    }

    // Inicializar notificaciones
    await _notificationService.initialize(
      userId: _currentUserId!,
      token: _authToken!,
    );
  }

  /// Guardar credenciales para recuperación
  Future<void> _saveCredentials(String userId, String authToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('persistent_user_id', userId);
    await prefs.setString('persistent_auth_token', authToken);
    await prefs.setString('last_active_time', DateTime.now().toIso8601String());
  }

  /// Recuperar credenciales guardadas
  Future<Map<String, String>?> getStoredCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('persistent_user_id');
    final authToken = prefs.getString('persistent_auth_token');

    if (userId != null && authToken != null) {
      return {
        'userId': userId,
        'authToken': authToken,
      };
    }

    return null;
  }

  /// Configurar listener de conectividad
  void _setupConnectivityListener() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        final wasConnected = _hasConnection;
        _hasConnection = results.isNotEmpty &&
            results.any((result) => result != ConnectivityResult.none);

        // Si recuperamos conexión, reconectar
        if (!wasConnected && _hasConnection) {
          _reconnect();
        }
      },
    );
  }

  /// Iniciar heartbeat para mantener conexión viva
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();

    // Enviar ping cada 30 segundos
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_socketService.isConnected()) {
        _socketService.socket?.emit('heartbeat', {
          'userId': _currentUserId,
          'timestamp': DateTime.now().toIso8601String(),
        });

        // Actualizar última actividad
        _updateLastActive();
      } else {
        _reconnect();
      }
    });
  }

  /// Actualizar última actividad
  Future<void> _updateLastActive() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_active_time', DateTime.now().toIso8601String());
  }

  /// Configurar reconexión automática
  void _setupAutoReconnect() {
    // Escuchar desconexiones del socket
    _socketService.socket?.on('disconnect', (_) {
      _scheduleReconnect();
    });

    // Escuchar errores de conexión
    _socketService.socket?.on('connect_error', (error) {
      _scheduleReconnect();
    });

    // Escuchar reconexión exitosa
    _socketService.socket?.on('connect', (_) {
      _reconnectTimer?.cancel();

      // Re-autenticar si es necesario
      if (_currentUserId != null) {
        _socketService.socket?.emit('authenticate', {
          'userId': _currentUserId,
          'token': _authToken,
        });
      }
    });
  }

  /// Programar intento de reconexión
  void _scheduleReconnect() {
    _reconnectTimer?.cancel();

    // Reintentar con backoff exponencial
    int delay = 5; // Segundos iniciales
    int attempts = 0;

    _reconnectTimer = Timer.periodic(Duration(seconds: delay), (timer) {
      attempts++;

      if (_socketService.isConnected()) {
        timer.cancel();
        return;
      }

      _reconnect();

      // Aumentar delay hasta máximo de 60 segundos
      if (delay < 60) {
        delay = (delay * 1.5).round();
      }

      // Después de 10 intentos, reducir frecuencia
      if (attempts > 10) {
        timer.cancel();
        // Reintentar cada 5 minutos
        _reconnectTimer = Timer.periodic(const Duration(minutes: 5), (_) {
          if (!_socketService.isConnected()) {
            _reconnect();
          }
        });
      }
    });
  }

  /// Reconectar servicios
  Future<void> _reconnect() async {
    if (!_hasConnection) {
      return;
    }

    try {
      // Reconectar socket
      if (!_socketService.isConnected()) {
        // Recrear socket con token
        final newSocket = SocketService(token: _authToken);

        // Esperar un poco para la conexión
        await Future.delayed(const Duration(seconds: 2));

        // Re-autenticar
        if (newSocket.isConnected() && _currentUserId != null) {
          newSocket.socket?.emit('authenticate', {
            'userId': _currentUserId,
            'token': _authToken,
          });
        }
      }

      // Verificar si el token VoIP necesita renovarse
      if (Platform.isIOS) {
        final needsRefresh =
            await VoipTokenService.instance.needsTokenRefresh();
        if (needsRefresh) {
          // El token se renovará automáticamente cuando iOS lo proporcione
        }
      }
    } catch (e) {}
  }

  /// Registrar ejecución en background para iOS
  Future<void> _registerBackgroundExecution() async {
    try {
      // Registrar para actualizaciones en background
      await _backgroundChannel.invokeMethod('registerBackgroundTask');

      // Configurar handler para eventos de background
      _backgroundChannel.setMethodCallHandler((call) async {
        switch (call.method) {
          case 'backgroundFetch':
            // Ejecutar tareas de background
            await _performBackgroundTasks();
            break;
        }
      });
    } catch (e) {}
  }

  /// Ejecutar tareas en background
  Future<void> _performBackgroundTasks() async {
    // Verificar y reconectar si es necesario
    if (!_socketService.isConnected()) {
      await _reconnect();
    }

    // Actualizar estado
    await _updateLastActive();

    // Verificar mensajes o llamadas pendientes
    // (Aquí podrías agregar lógica adicional según necesites)
  }

  /// Pausar servicios (cuando la app va a background)
  void pause() {
    // En iOS, mantener conexión activa para VoIP
    if (!Platform.isIOS) {
      _heartbeatTimer?.cancel();
    }
  }

  /// Resumir servicios (cuando la app vuelve a foreground)
  void resume() {
    // Verificar conexión
    if (!_socketService.isConnected()) {
      _reconnect();
    }

    // Reiniciar heartbeat si estaba pausado
    if (_heartbeatTimer == null || !_heartbeatTimer!.isActive) {
      _startHeartbeat();
    }
  }

  /// Cerrar sesión y limpiar recursos
  Future<void> logout() async {
    _isInitialized = false;
    _currentUserId = null;
    _authToken = null;

    // Cancelar timers
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    _connectivitySubscription.cancel();

    // Limpiar credenciales guardadas
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('persistent_user_id');
    await prefs.remove('persistent_auth_token');
    await prefs.remove('last_active_time');

    // Limpiar servicios
    if (Platform.isIOS) {
      await VoipTokenService.instance.logout();
    }
  }

  /// Obtener estado de la sesión
  bool get isActive => _isInitialized && _socketService.isConnected();
  String? get userId => _currentUserId;
  bool get hasConnection => _hasConnection;
}
