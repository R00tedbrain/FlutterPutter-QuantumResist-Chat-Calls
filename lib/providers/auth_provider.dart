import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutterputter/models/user.dart';
import 'package:flutterputter/services/api_service.dart';
import 'package:flutterputter/services/notification_manager.dart';
import 'package:flutterputter/services/voip_service.dart';
import 'package:flutterputter/services/hybrid_notification_service.dart';
import 'package:flutterputter/services/ephemeral_chat_notification_integration.dart';
import 'package:flutterputter/services/call_notification_integration.dart';
import 'package:flutterputter/services/session_persistence_service.dart';
import 'package:flutterputter/services/ntfy_subscription_service.dart';
import 'package:flutterputter/services/session_management_service.dart';
import 'package:flutterputter/services/security_alert_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;
  GlobalKey<NavigatorState>? _navigatorKey;

  bool get isAuthenticated => _token != null && _user != null;
  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get user => _user;
  String? get token => _token;

  // Configurar el navigatorKey para las notificaciones
  void setNavigatorKey(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
  }

  // Inicializar sistema de notificaciones
  Future<void> _initializeNotifications() async {
    if (_user != null && _token != null && _navigatorKey != null) {
      try {
        await NotificationManager.instance.initialize(
          _user!.id,
          _token!,
          _navigatorKey!,
        );
        print(
            '✅ Sistema de notificaciones inicializado para usuario: ${_user!.id}');

        // 🚨 NUEVO: Configurar contexto para alertas de seguridad
        if (_navigatorKey!.currentContext != null) {
          SecurityAlertService.instance
              .setContext(_navigatorKey!.currentContext!);
          print('🚨 [AUTH] SecurityAlertService contexto configurado');
        }

        // NUEVO: Inicializar VoIP Service (NO ALTERA LÓGICA EXISTENTE)
        await _initializeVoIPService();

        // TEMPORALMENTE COMENTADO: Inicializar servicios ntfy
        // NOTA: Esto podría estar causando conflictos en iOS con el chat efímero
        // await _initializeNtfyServices();
      } catch (e) {
        print('❌ Error inicializando notificaciones: $e');
      }
    }
  }

  // NUEVO: Inicializar VoIP Service (SOLO AÑADE, NO ALTERA NADA)
  Future<void> _initializeVoIPService() async {
    if (_user != null && _token != null) {
      try {
        await VoIPService.instance.initialize(
          userId: _user!.id,
          token: _token!,
          voipServerUrl: 'https://clubprivado.ws/voip',
        );
        print('✅ VoIP Service inicializado para usuario: ${_user!.id}');
      } catch (e) {
        print('❌ Error inicializando VoIP Service: $e');
        // No es crítico, la app sigue funcionando sin VoIP
      }
    }
  }

  // NUEVO: Inicializar servicios ntfy (NO ALTERA VoIP)
  Future<void> _initializeNtfyServices() async {
    if (_user != null && _token != null) {
      try {
        print('🔔 [AUTH] === INICIALIZANDO SERVICIOS NTFY ===');
        print(
            '🔔 [AUTH] IMPORTANTE: VoIP en iOS NO se toca - mantiene videollamadas');
        print('🔔 [AUTH] Usuario: ${_user!.id}');

        // 1. Inicializar servicio híbrido principal
        await HybridNotificationService.instance.initialize(
          userId: _user!.id,
          token: _token!,
        );
        print('✅ [AUTH] HybridNotificationService inicializado');

        // 2. DESHABILITADO: Integración para chat efímero manejada por MainScreen
        // NOTA: MainScreen ya maneja EphemeralChatNotificationIntegration.initialize()
        // Evitamos inicialización duplicada que causa conflictos de callbacks
        /*
        await EphemeralChatNotificationIntegration.instance.initialize(
          userId: _user!.id,
          token: _token!,
        );
        */
        print(
            '✅ [AUTH] EphemeralChatNotificationIntegration - manejado por MainScreen');

        // 3. Inicializar integración para llamadas
        await CallNotificationIntegration.instance.initialize(
          userId: _user!.id,
          token: _token!,
        );
        print('✅ [AUTH] CallNotificationIntegration inicializado');

        // 4. CRÍTICO: Inicializar suscripción ACTIVA a ntfy (esto faltaba)
        await NtfySubscriptionService.instance.initialize(
          userId: _user!.id,
        );
        print(
            '✅ [AUTH] NtfySubscriptionService inicializado - SUSCRIBIÉNDOSE A TOPICS');

        // Configurar callbacks para manejar notificaciones recibidas
        _setupNtfyCallbacks();

        print('✅ [AUTH] === SERVICIOS NTFY LISTOS ===');
        print('✅ [AUTH] iOS videollamadas: VoIP (NO ALTERADO)');
        print('✅ [AUTH] iOS mensajes: ntfy');
        print('✅ [AUTH] Android todo: ntfy');

        // 5. NUEVO: Inicializar persistencia de sesión
        await _initializeSessionPersistence();
      } catch (e) {
        print('❌ [AUTH] Error inicializando servicios ntfy: $e');
        // No es crítico, los sistemas existentes siguen funcionando
      }
    }
  }

  // NUEVO: Inicializar persistencia de sesión
  Future<void> _initializeSessionPersistence() async {
    if (_user != null && _token != null) {
      try {
        print('🔄 [AUTH] === INICIALIZANDO PERSISTENCIA DE SESIÓN ===');

        await SessionPersistenceService.instance.initialize(
          userId: _user!.id,
          authToken: _token!,
        );

        print('✅ [AUTH] SessionPersistenceService inicializado');
        print(
            '✅ [AUTH] Sesión persistente activa - mantiene conexión en background');
      } catch (e) {
        print('❌ [AUTH] Error inicializando persistencia de sesión: $e');
        // No es crítico, pero la sesión no será persistente
      }
    }
  }

  // NUEVO: Configurar callbacks para manejar notificaciones de ntfy
  void _setupNtfyCallbacks() {
    print('🔔📡 [AUTH] === CONFIGURANDO CALLBACKS NTFY ===');

    // Callback para mensajes
    NtfySubscriptionService.instance.setMessageCallback((notification) {
      print(
          '📩 [AUTH] Notificación de mensaje recibida: ${notification['title']}');
      print('📩 [AUTH] Contenido: ${notification['message']}');

      // Aquí puedes procesar la notificación como desees
      // Por ejemplo, mostrar un snackbar, actualizar UI, etc.
    });

    // Callback para invitaciones de chat
    NtfySubscriptionService.instance.setInvitationCallback((notification) {
      print('📩 [AUTH] Invitación de chat recibida: ${notification['title']}');
      print('📩 [AUTH] Contenido: ${notification['message']}');

      // Aquí puedes procesar invitaciones de chat efímero
    });

    // Callback para llamadas (solo si no es manejado por VoIP en iOS)
    NtfySubscriptionService.instance.setCallCallback((notification) {
      print(
          '📞 [AUTH] Notificación de llamada recibida: ${notification['title']}');
      print('📞 [AUTH] Contenido: ${notification['message']}');

      // Aquí puedes procesar llamadas de audio o videollamadas en Android
    });

    // Callback personalizado
    NtfySubscriptionService.instance.setCustomCallback((notification) {
      print(
          '🔧 [AUTH] Notificación personalizada recibida: ${notification['title']}');
      print('🔧 [AUTH] Contenido: ${notification['message']}');
    });

    print('✅ [AUTH] Callbacks ntfy configurados correctamente');
    print(
        '✅ [AUTH] La app AHORA ESTÁ SUSCRITA a ntfy y recibirá notificaciones');
  }

  // Comprobar si el usuario está autenticado (token almacenado)
  Future<bool> checkAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString('token');

      if (savedToken == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Verificar token con el servidor
      final response = await ApiService.get('/api/auth/profile', savedToken);

      if (response.statusCode == 200) {
        _token = savedToken;

        // Verificar si la respuesta está vacía
        if (response.body.isEmpty) {
          print('⚠️ Respuesta vacía al verificar perfil');
          _error = 'Error: respuesta vacía del servidor';
          _isLoading = false;
          notifyListeners();
          return false;
        }

        try {
          final dynamic userData = jsonDecode(response.body);

          // Verificar que userData sea un Map
          if (userData == null) {
            print('⚠️ Datos de usuario son null después de decodificar');
            _error = 'Error al procesar datos de usuario';
            _isLoading = false;
            notifyListeners();
            return false;
          }

          if (userData is! Map<String, dynamic>) {
            print(
                '⚠️ Datos de usuario no son un objeto Map: ${userData.runtimeType}');

            // Intentar convertir si es un Map genérico
            if (userData is Map) {
              final Map<String, dynamic> safeUserData = {};
              userData.forEach((key, value) {
                if (key is String) {
                  safeUserData[key] = value;
                }
              });

              if (safeUserData.isEmpty) {
                print(
                    '⚠️ No se pudieron convertir los datos de usuario a Map<String, dynamic>');
                _error = 'Error al procesar datos de usuario';
                _isLoading = false;
                notifyListeners();
                return false;
              }

              try {
                _user = User.fromJson(safeUserData);
              } catch (e) {
                print('❌ Error al crear objeto User: $e');
                _error = 'Error al procesar datos de usuario';
                _isLoading = false;
                notifyListeners();
                return false;
              }
            } else {
              _error = 'Error al procesar datos de usuario';
              _isLoading = false;
              notifyListeners();
              return false;
            }
          } else {
            try {
              _user = User.fromJson(userData);
            } catch (e) {
              print('❌ Error al crear objeto User: $e');
              _error = 'Error al procesar datos de usuario';
              _isLoading = false;
              notifyListeners();
              return false;
            }
          }

          _isLoading = false;
          notifyListeners();

          // ✅ NUEVO: Inicializar SessionManagementService con el token existente
          try {
            await SessionManagementService().setAuthToken(_token!);

            // ✅ CRUCIAL: Actualizar sessionId si el servidor lo devuelve
            if (userData['sessionId'] != null) {
              await SessionManagementService()
                  .updateSessionIdFromServer(userData['sessionId']);
              print(
                  '✅ [AUTH] SessionId actualizado desde respuesta del servidor: ${userData['sessionId']}');
            }

            await SessionManagementService().initialize(userId: _user!.id);
            print(
                '✅ [AUTH] SessionManagementService inicializado para sesiones activas');
          } catch (e) {
            print('❌ [AUTH] Error inicializando SessionManagementService: $e');
            // No es crítico, continúa con la autenticación
          }

          // 🔔 Inicializar notificaciones después de autenticación exitosa
          await _initializeNotifications();

          return true;
        } catch (e) {
          print('❌ Error al decodificar respuesta JSON: $e');
          _error = 'Error al procesar datos de usuario';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      } else {
        // Token inválido - logout
        await logout();
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error al verificar autenticación';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Inicio de sesión
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.post(
        '/api/auth/login',
        {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        // Verificar si la respuesta está vacía
        if (response.body.isEmpty) {
          print('⚠️ Respuesta vacía al hacer login');
          _error = 'Error: respuesta vacía del servidor';
          _isLoading = false;
          notifyListeners();
          return false;
        }

        try {
          final dynamic data = jsonDecode(response.body);

          // Verificar que data sea un Map
          if (data == null) {
            _error = 'Error al procesar respuesta del servidor';
            _isLoading = false;
            notifyListeners();
            return false;
          }

          if (data is! Map<String, dynamic>) {
            _error = 'Error: formato de respuesta inesperado';
            _isLoading = false;
            notifyListeners();
            return false;
          }

          // Verificar que token existe
          if (data['token'] == null) {
            _error = 'Error: token no encontrado en respuesta';
            _isLoading = false;
            notifyListeners();
            return false;
          }

          _token = data['token'].toString();

          // Verificar que user existe y es un Map
          if (data['user'] == null) {
            _error = 'Error: datos de usuario no encontrados';
            _isLoading = false;
            notifyListeners();
            return false;
          }

          if (data['user'] is! Map<String, dynamic>) {
            _error = 'Error: formato de datos de usuario inesperado';
            _isLoading = false;
            notifyListeners();
            return false;
          }

          try {
            _user = User.fromJson(data['user']);
          } catch (e) {
            _error = 'Error al procesar datos de usuario';
            _isLoading = false;
            notifyListeners();
            return false;
          }

          // Guardar token
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('token', _token!);

          _isLoading = false;
          notifyListeners();

          // ✅ NUEVO: Inicializar SessionManagementService con el token
          try {
            await SessionManagementService().setAuthToken(_token!);

            // ✅ CRUCIAL: Actualizar sessionId si el servidor lo devuelve
            if (data['sessionId'] != null) {
              await SessionManagementService()
                  .updateSessionIdFromServer(data['sessionId']);
            }

            await SessionManagementService().initialize(userId: _user!.id);
          } catch (e) {
            // No es crítico, continúa con el login
          }

          // 🔔 Inicializar notificaciones después de login exitoso
          await _initializeNotifications();

          return true;
        } catch (e) {
          print('❌ Error al decodificar respuesta JSON de login: $e');
          _error = 'Error al procesar respuesta del servidor';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      } else {
        try {
          if (response.body.isEmpty) {
            _error = 'Error al iniciar sesión (${response.statusCode})';
          } else {
            final dynamic data = jsonDecode(response.body);
            if (data is Map && data.containsKey('message')) {
              _error = data['message'] ?? 'Error al iniciar sesión';
            } else {
              _error = 'Error al iniciar sesión';
            }
          }
        } catch (e) {
          _error = 'Error al iniciar sesión';
        }

        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error de conexión';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Registro
  Future<bool> register(String email, String password, String nickname,
      String invitationCode) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.post(
        '/api/auth/register',
        {
          'email': email,
          'password': password,
          'nickname': nickname,
          'invitationCode': invitationCode
        },
      );

      if (response.statusCode == 201) {
        // Verificar si la respuesta está vacía
        if (response.body.isEmpty) {
          print('⚠️ Respuesta vacía al registrarse');
          _error = 'Error: respuesta vacía del servidor';
          _isLoading = false;
          notifyListeners();
          return false;
        }

        try {
          print('[DEBUG] register response.body: ${response.body}');
          final dynamic data = jsonDecode(response.body);
          print('[DEBUG] register data type: ${data.runtimeType}');

          // Verificar que data sea un Map
          if (data == null) {
            print('⚠️ Datos de registro son null después de decodificar');
            _error = 'Error al procesar respuesta del servidor';
            _isLoading = false;
            notifyListeners();
            return false;
          }

          if (data is! Map<String, dynamic>) {
            print(
                '⚠️ Datos de registro no son un objeto Map: ${data.runtimeType}');
            _error = 'Error: formato de respuesta inesperado';
            _isLoading = false;
            notifyListeners();
            return false;
          }

          // Verificar que token existe
          if (data['token'] == null) {
            print('⚠️ Token no encontrado en respuesta de registro');
            _error = 'Error: token no encontrado en respuesta';
            _isLoading = false;
            notifyListeners();
            return false;
          }

          _token = data['token'].toString();

          // Verificar que user existe y es un Map
          if (data['user'] == null) {
            print(
                '⚠️ Datos de usuario no encontrados en respuesta de registro');
            _error = 'Error: datos de usuario no encontrados';
            _isLoading = false;
            notifyListeners();
            return false;
          }

          if (data['user'] is! Map<String, dynamic>) {
            print('⚠️ User no es un Map: ${data['user'].runtimeType}');
            _error = 'Error: formato de datos de usuario inesperado';
            _isLoading = false;
            notifyListeners();
            return false;
          }

          try {
            _user = User.fromJson(data['user']);
          } catch (e) {
            print('❌ Error al crear objeto User: $e');
            _error = 'Error al procesar datos de usuario';
            _isLoading = false;
            notifyListeners();
            return false;
          }

          // Guardar token
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('token', _token!);

          _isLoading = false;
          notifyListeners();
          return true;
        } catch (e) {
          print('❌ Error al decodificar respuesta JSON de registro: $e');
          _error = 'Error al procesar respuesta del servidor';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      } else {
        try {
          if (response.body.isEmpty) {
            _error = 'Error al registrarse (${response.statusCode})';
          } else {
            final dynamic data = jsonDecode(response.body);
            if (data is Map && data.containsKey('message')) {
              _error = data['message'] ?? 'Error al registrarse';
            } else {
              _error = 'Error al registrarse';
            }
          }
        } catch (e) {
          _error = 'Error al registrarse';
        }

        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error de conexión';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Cerrar sesión
  Future<void> logout() async {
    // 🔔 Limpiar notificaciones antes del logout
    try {
      await NotificationManager.instance.dispose();
      print('✅ Sistema de notificaciones limpiado');
    } catch (e) {
      print('❌ Error limpiando notificaciones: $e');
    }

    // ✅ NUEVO: Limpiar SessionManagementService COMPLETO
    try {
      // PRIMERO: Detener heartbeats inmediatamente
      SessionManagementService().stopHeartbeat();

      // SEGUNDO: Cerrar todas las sesiones activas en el servidor
      await SessionManagementService().terminateAllOtherSessions();

      // TERCERO: Logout completo del servicio
      await SessionManagementService().logout();

      print('✅ SessionManagementService completamente limpiado');
    } catch (e) {
      print('❌ Error limpiando SessionManagementService: $e');
    }

    // NUEVO: Limpiar persistencia de sesión
    try {
      await SessionPersistenceService.instance.logout();
      print('✅ Persistencia de sesión limpiada');
    } catch (e) {
      print('❌ Error limpiando persistencia de sesión: $e');
    }

    // NUEVO: Limpiar servicios híbridos
    try {
      HybridNotificationService.instance.dispose();
      print('✅ Servicios híbridos limpiados');
    } catch (e) {
      print('❌ Error limpiando servicios híbridos: $e');
    }

    // NUEVO: Limpiar VoIP Service
    try {
      VoIPService.instance.dispose();
      print('✅ VoIP Service limpiado');
    } catch (e) {
      print('❌ Error limpiando VoIP Service: $e');
    }

    _user = null;
    _token = null;

    final prefs = await SharedPreferences.getInstance();
    prefs.remove('token');

    notifyListeners();
  }

  // Actualizar nickname
  Future<bool> updateNickname(String nickname) async {
    if (_token == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.put(
        '/api/auth/update-nickname',
        {'nickname': nickname},
        _token!,
      );

      if (response.statusCode == 200) {
        // Verificar si la respuesta está vacía
        if (response.body.isEmpty) {
          print('⚠️ Respuesta vacía al actualizar nickname');
          _error = 'Error: respuesta vacía del servidor';
          _isLoading = false;
          notifyListeners();
          return false;
        }

        try {
          print('[DEBUG] updateNickname response.body: ${response.body}');
          final dynamic data = jsonDecode(response.body);
          print('[DEBUG] updateNickname data type: ${data.runtimeType}');

          // Verificar que data sea un Map
          if (data == null) {
            print('⚠️ Datos de actualización son null después de decodificar');
            _error = 'Error al procesar respuesta del servidor';
            _isLoading = false;
            notifyListeners();
            return false;
          }

          if (data is! Map<String, dynamic>) {
            print(
                '⚠️ Datos de actualización no son un objeto Map: ${data.runtimeType}');
            _error = 'Error: formato de respuesta inesperado';
            _isLoading = false;
            notifyListeners();
            return false;
          }

          // Verificar que user existe y es un Map
          if (data['user'] == null) {
            print(
                '⚠️ Datos de usuario no encontrados en respuesta de actualización');
            _error = 'Error: datos de usuario no encontrados';
            _isLoading = false;
            notifyListeners();
            return false;
          }

          if (data['user'] is! Map<String, dynamic>) {
            print('⚠️ User no es un Map: ${data['user'].runtimeType}');
            _error = 'Error: formato de datos de usuario inesperado';
            _isLoading = false;
            notifyListeners();
            return false;
          }

          try {
            _user = User.fromJson(data['user']);
          } catch (e) {
            print('❌ Error al crear objeto User: $e');
            _error = 'Error al procesar datos de usuario';
            _isLoading = false;
            notifyListeners();
            return false;
          }

          _isLoading = false;
          notifyListeners();
          return true;
        } catch (e) {
          print('❌ Error al decodificar respuesta JSON de actualización: $e');
          _error = 'Error al procesar respuesta del servidor';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      } else {
        try {
          if (response.body.isEmpty) {
            _error = 'Error al actualizar nickname (${response.statusCode})';
          } else {
            final dynamic data = jsonDecode(response.body);
            if (data is Map && data.containsKey('message')) {
              _error = data['message'] ?? 'Error al actualizar nickname';
            } else {
              _error = 'Error al actualizar nickname';
            }
          }
        } catch (e) {
          _error = 'Error al actualizar nickname';
        }

        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error de conexión';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
