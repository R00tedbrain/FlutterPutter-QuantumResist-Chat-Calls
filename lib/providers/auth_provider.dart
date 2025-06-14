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
import 'package:flutterputter/services/invitation_persistence_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutterputter/models/chat_invitation.dart';
import 'package:flutterputter/services/local_notification_service.dart';
import 'package:flutterputter/services/room_nickname_service.dart';

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

        // 🚨 NUEVO: Configurar contexto para alertas de seguridad
        if (_navigatorKey!.currentContext != null) {
          SecurityAlertService.instance
              .setContext(_navigatorKey!.currentContext!);
        }

        // NUEVO: Inicializar VoIP Service (NO ALTERA LÓGICA EXISTENTE)
        await _initializeVoIPService();

        // TEMPORALMENTE COMENTADO: Inicializar servicios ntfy
        // NOTA: Esto podría estar causando conflictos en iOS con el chat efímero
        // await _initializeNtfyServices();
      } catch (e) {}
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
      } catch (e) {
        // No es crítico, la app sigue funcionando sin VoIP
      }
    }
  }

  // NUEVO: Inicializar servicios ntfy (NO ALTERA VoIP)
  Future<void> _initializeNtfyServices() async {
    if (_user != null && _token != null) {
      try {
        // 1. Inicializar servicio híbrido principal
        await HybridNotificationService.instance.initialize(
          userId: _user!.id,
          token: _token!,
        );

        // 2. DESHABILITADO: Integración para chat efímero manejada por MainScreen
        // NOTA: MainScreen ya maneja EphemeralChatNotificationIntegration.initialize()
        // Evitamos inicialización duplicada que causa conflictos de callbacks
        /*
        await EphemeralChatNotificationIntegration.instance.initialize(
          userId: _user!.id,
          token: _token!,
        );
        */

        // 3. Inicializar integración para llamadas
        await CallNotificationIntegration.instance.initialize(
          userId: _user!.id,
          token: _token!,
        );

        // 4. CRÍTICO: Inicializar suscripción ACTIVA a ntfy (esto faltaba)
        await NtfySubscriptionService.instance.initialize(
          userId: _user!.id,
        );

        // Configurar callbacks para manejar notificaciones recibidas
        _setupNtfyCallbacks();

        // 5. NUEVO: Inicializar persistencia de sesión
        await _initializeSessionPersistence();
      } catch (e) {
        // No es crítico, los sistemas existentes siguen funcionando
      }
    }
  }

  // NUEVO: Inicializar persistencia de sesión
  Future<void> _initializeSessionPersistence() async {
    if (_user != null && _token != null) {
      try {
        await SessionPersistenceService.instance.initialize(
          userId: _user!.id,
          authToken: _token!,
        );
      } catch (e) {
        // No es crítico, pero la sesión no será persistente
      }
    }
  }

  // NUEVO: Configurar callbacks para manejar notificaciones de ntfy
  void _setupNtfyCallbacks() {
    // Callback para mensajes
    NtfySubscriptionService.instance.setMessageCallback((notification) {
      // Aquí puedes procesar la notificación como desees
      // Por ejemplo, mostrar un snackbar, actualizar UI, etc.
    });

    // Callback para invitaciones de chat
    NtfySubscriptionService.instance.setInvitationCallback((notification) {
      // Aquí puedes procesar invitaciones de chat efímero
    });

    // Callback para llamadas (solo si no es manejado por VoIP en iOS)
    NtfySubscriptionService.instance.setCallCallback((notification) {
      // Aquí puedes procesar llamadas de audio o videollamadas en Android
    });

    // Callback personalizado
    NtfySubscriptionService.instance.setCustomCallback((notification) {});
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
          _error = 'Error: respuesta vacía del servidor';
          _isLoading = false;
          notifyListeners();
          return false;
        }

        try {
          final dynamic userData = jsonDecode(response.body);

          // Verificar que userData sea un Map
          if (userData == null) {
            _error = 'Error al procesar datos de usuario';
            _isLoading = false;
            notifyListeners();
            return false;
          }

          if (userData is! Map<String, dynamic>) {
            // Intentar convertir si es un Map genérico
            if (userData is Map) {
              final Map<String, dynamic> safeUserData = {};
              userData.forEach((key, value) {
                if (key is String) {
                  safeUserData[key] = value;
                }
              });

              if (safeUserData.isEmpty) {
                _error = 'Error al procesar datos de usuario';
                _isLoading = false;
                notifyListeners();
                return false;
              }

              try {
                _user = User.fromJson(safeUserData);
              } catch (e) {
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
            }

            await SessionManagementService().initialize(userId: _user!.id);
          } catch (e) {
            // No es crítico, continúa con la autenticación
          }

          // 🔔 Inicializar notificaciones después de autenticación exitosa
          await _initializeNotifications();

          return true;
        } catch (e) {
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
          return true;
        } catch (e) {
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
    } catch (e) {}

    // ✅ NUEVO: Limpiar SessionManagementService COMPLETO
    try {
      // PRIMERO: Detener heartbeats inmediatamente
      SessionManagementService().stopHeartbeat();

      // SEGUNDO: Cerrar todas las sesiones activas en el servidor
      await SessionManagementService().terminateAllOtherSessions();

      // TERCERO: Logout completo del servicio
      await SessionManagementService().logout();
    } catch (e) {}

    // NUEVO: Limpiar persistencia de sesión
    try {
      await SessionPersistenceService.instance.logout();
    } catch (e) {}

    // NUEVO: Limpiar servicios híbridos
    try {
      HybridNotificationService.instance.dispose();
    } catch (e) {}

    // 🔒 CRÍTICO: NO hacer dispose de VoIPService
    // VoIPService debe mantenerse activo para recibir llamadas incluso cuando app está bloqueada
    // Solo se limpia en casos de logout REAL del usuario, no bloqueo de app
    print('🔒 [AUTH] Manteniendo VoIPService activo para llamadas entrantes');

    // NUEVO: Limpiar invitaciones persistentes en logout
    try {
      await InvitationPersistenceService.instance.clearAllInvitations();
      print('🔒 [AUTH] Invitaciones persistentes limpiadas');
    } catch (e) {
      print('❌ [AUTH] Error limpiando invitaciones persistentes: $e');
    }

    // NUEVO: Limpiar apodos de salas en logout
    try {
      await RoomNicknameService.clearAllNicknames();
      print('🔒 [AUTH] Apodos de salas limpiados');
    } catch (e) {
      print('❌ [AUTH] Error limpiando apodos de salas: $e');
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

          _isLoading = false;
          notifyListeners();
          return true;
        } catch (e) {
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
