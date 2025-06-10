import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/call_provider.dart';
import '../services/socket_service.dart';
import '../services/ephemeral_chat_service.dart';
import '../services/ephemeral_chat_manager.dart';
import '../services/ephemeral_chat_notification_integration.dart';
import '../services/local_notification_service.dart';
import '../services/invitation_tracking_service.dart';
import '../services/api_service.dart';
import '../models/chat_invitation.dart';
import '../models/user.dart';
import '../l10n/app_localizations.dart';
import 'chat_list_screen.dart';
import 'search_users_screen.dart';
import 'verification_demo_screen.dart';
import 'profile_screen.dart';
import 'security_settings_screen.dart';
import 'chat_invitations_screen.dart';
import 'incoming_call_screen.dart';
import 'dart:convert';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late SocketService _socketService;
  late EphemeralChatService _ephemeralChatService;
  final List<ChatInvitation> _pendingInvitations = [];

  // NUEVO: Controlar cuando se debe reconfigurar callbacks
  bool _callbacksConfigured = false;
  String? _lastRouteConfigured;

  @override
  void initState() {
    super.initState();
    _setupSocketService();
    _setupEphemeralChatService();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final currentRoute = ModalRoute.of(context)?.settings.name;

    print('🔐 [MAINSCREEN] 🔄 === didChangeDependencies EJECUTADO ===');
    print('🔐 [MAINSCREEN] 🔄 ModalRoute.of(context): $currentRoute');
    print('🔐 [MAINSCREEN] 🔄 Última ruta configurada: $_lastRouteConfigured');
    print('🔐 [MAINSCREEN] 🔄 Callbacks configurados: $_callbacksConfigured');

    // PATRÓN OFICIAL FLUTTER: Solo limpiar en home, callbacks se preservan
    if (currentRoute == '/home') {
      print('🔐 [MAINSCREEN] 🧹 Limpieza al regresar a home...');
      _cleanRejectedInvitations();

      // NUEVO: SIEMPRE verificar callbacks reales (no confiar en flag)
      print('🔐 [MAINSCREEN] 🔄 Verificando estado real de callbacks...');
      _ensureCallbacksConfigured();
      _callbacksConfigured = true;
      print('🔐 [MAINSCREEN] ✅ Callbacks verificados/restaurados');

      _lastRouteConfigured = currentRoute;
    }

    print('🔐 [MAINSCREEN] 🔄 === didChangeDependencies COMPLETADO ===');
  }

  @override
  void didUpdateWidget(covariant MainScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    print('🔐 [MAINSCREEN] 🔄 === didUpdateWidget EJECUTADO ===');

    // PATRÓN OFICIAL FLUTTER: Verificar callbacks cuando el widget se actualiza
    _ensureCallbacksConfigured();

    print('🔐 [MAINSCREEN] 🔄 === didUpdateWidget COMPLETADO ===');
  }

  void _setupSocketService() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final callProvider = Provider.of<CallProvider>(context, listen: false);

    if (authProvider.token == null) {
      print('⚠️ No hay token disponible para configurar SocketService');
      return;
    }

    _socketService = SocketService(token: authProvider.token);
    callProvider.setSocketService(_socketService);

    _socketService.onIncomingCall = _handleIncomingCall;
    _socketService.onCallEnded = _handleCallEnded;

    print('✅ Callbacks de llamada registrados en MainScreen');
  }

  void _setupEphemeralChatService() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.id;

    if (userId == null) {
      print('⚠️ No hay userId disponible para configurar EphemeralChatService');
      return;
    }

    _ephemeralChatService = EphemeralChatService();

    _ephemeralChatService.initialize(userId: userId).then((_) {
      print('✅ EphemeralChatService inicializado en MainScreen');

      // NUEVO: Inicializar LocalNotificationService Y EphemeralChatNotificationIntegration
      Future.wait([
        LocalNotificationService.instance.initialize(),
        EphemeralChatNotificationIntegration.instance.initialize(
          userId: userId,
          token: authProvider.token ?? '',
        ),
      ]).then((_) {
        print('✅ LocalNotificationService inicializado en MainScreen');
        print(
            '✅ EphemeralChatNotificationIntegration inicializado en MainScreen');

        // NOTA: Los callbacks se configuran directamente abajo para evitar sobrescritura
        print(
            '✅ Servicios de notificación inicializados - callbacks configurados directamente');
      }).catchError((e) {
        print('❌ Error inicializando servicios de notificación: $e');
      });

      // CONFIGURAR CALLBACKS DEL MAINSCREEN CON INTEGRACIÓN DE NOTIFICACIONES
      _ephemeralChatService.onInvitationReceived = (invitation) {
        print('🔐 [MAINSCREEN] Nueva invitación recibida: ${invitation.id}');
        // SOLUCIÓN OFICIAL FLUTTER 2025: Manejar callback sin async gaps
        _handleInvitationSync(invitation);
      };

      // NUEVO: Configurar callback para mensajes recibidos para notificaciones
      // NOTA: Los mensajes van a través del ChatManager, no del servicio global
      _ephemeralChatService.onMessageReceived = (message) {
        print(
            '🔐 [MAINSCREEN] 💬 Mensaje recibido en servicio global: ${message.id}');
        // NOTA: Esto solo maneja mensajes del servicio global (raramente usado)
        _showSystemNotificationForMessage(message);
      };

      // CRÍTICO: También configurar callback para ChatManager (donde realmente llegan los mensajes)
      _ensureCallbacksConfigured();
      _callbacksConfigured = true;

      _ephemeralChatService.onError = (error) {
        print('❌ Error en EphemeralChatService: $error');
      };

      // NOTA: Configuración de callbacks movida dentro del Future.wait() arriba
    }).catchError((error) {
      print('❌ Error inicializando EphemeralChatService: $error');
    });
  }

  /// PATRÓN OFICIAL FLUTTER: Asegurar que los callbacks estén configurados correctamente
  void _ensureCallbacksConfigured() {
    try {
      print('🔐 [MAINSCREEN] 🔗 === ASEGURANDO CALLBACKS CONFIGURADOS ===');
      print(
          '🔐 [MAINSCREEN] 🔍 Callback actual de invitaciones: ${_ephemeralChatService.onInvitationReceived != null ? "EXISTS" : "NULL"}');

      // VERIFICAR: Estado del callback de invitaciones del servicio
      if (_ephemeralChatService.onInvitationReceived == null) {
        print(
            '🔐 [MAINSCREEN] ⚠️ CALLBACK DE INVITACIONES PERDIDO - RECONFIGURAR');

        // SOLUCIÓN OFICIAL FLUTTER 2025: Usar método síncrono
        _ephemeralChatService.onInvitationReceived = (invitation) {
          print('🔐 [MAINSCREEN] Nueva invitación recibida: ${invitation.id}');
          _handleInvitationSync(invitation);
        };

        print('🔐 [MAINSCREEN] ✅ Callback de invitaciones RESTAURADO');
      } else {
        print('🔐 [MAINSCREEN] ✅ Callback de invitaciones PRESERVADO - OK');
      }

      // Importar ChatManager si no está disponible
      final chatManager = EphemeralChatManager.instance;
      print(
          '🔐 [MAINSCREEN] 🔍 Callback actual de ChatManager: ${chatManager.onMessageReceived != null ? "EXISTS" : "NULL"}');

      // PATRÓN OFICIAL: Solo configurar si no está configurado o se perdió
      if (chatManager.onMessageReceived == null) {
        print('🔐 [MAINSCREEN] 🔄 Configurando callback de ChatManager...');

        // Configurar callback para mensajes recibidos en cualquier sesión
        chatManager.onMessageReceived = (sessionId, message) {
          print('🔐 [MAINSCREEN] 💬 === CALLBACK EJECUTADO ===');
          print('🔐 [MAINSCREEN] 💬 Mensaje ID: ${message.id}');
          print('🔐 [MAINSCREEN] 💬 Sesión: $sessionId');
          print('🔐 [MAINSCREEN] 💬 Contenido: ${message.content}');
          print('🔐 [MAINSCREEN] 💬 SenderId: ${message.senderId}');

          // Filtrar mensajes de verificación
          if (message.content.startsWith('VERIFICATION_CODES:')) {
            print(
                '🔐 [MAINSCREEN] 🚫 Mensaje de verificación filtrado - NO notificar');
            return;
          }

          print(
              '🔐 [MAINSCREEN] 🔔 Llamando a _showSystemNotificationForMessage...');
          // Llamar a la función de notificación
          _showSystemNotificationForMessage(message);
        };

        print('🔐 [MAINSCREEN] ✅ Callback de ChatManager configurado');
      } else {
        print(
            '🔐 [MAINSCREEN] ✅ Callback de ChatManager ya existe - preservando');
      }

      print('🔐 [MAINSCREEN] ✅ === CALLBACKS ASEGURADOS EXITOSAMENTE ===');
    } catch (e) {
      print('🔐 [MAINSCREEN] ❌ Error asegurando callbacks de ChatManager: $e');
    }
  }

  /// DEPRECATED: Usar _ensureCallbacksConfigured en su lugar
  void _setupChatManagerCallback() {
    print(
        '🔐 [MAINSCREEN] ⚠️ _setupChatManagerCallback DEPRECATED - usando _ensureCallbacksConfigured');
    _ensureCallbacksConfigured();
  }

  /// NUEVO: Limpiar invitaciones rechazadas de la lista local
  void _cleanRejectedInvitations() {
    if (!mounted) return;

    final initialCount = _pendingInvitations.length;
    final rejectedInvitations = _pendingInvitations
        .where((inv) => InvitationTrackingService.instance.isRejected(inv.id))
        .toList();

    if (rejectedInvitations.isNotEmpty) {
      print(
          '🔐 [MAINSCREEN] 🧹 Limpiando ${rejectedInvitations.length} invitaciones rechazadas');

      for (final inv in rejectedInvitations) {
        print('🔐 [MAINSCREEN] 🗑️ Eliminando invitación rechazada: ${inv.id}');
      }

      setState(() {
        _pendingInvitations.removeWhere(
            (inv) => InvitationTrackingService.instance.isRejected(inv.id));
      });

      final finalCount = _pendingInvitations.length;
      print(
          '🔐 [MAINSCREEN] ✅ Limpieza completada: ${initialCount} → ${finalCount} invitaciones');
    } else {
      print('🔐 [MAINSCREEN] ✅ No hay invitaciones rechazadas que limpiar');
    }
  }

  /// NUEVO: Mostrar notificación del sistema para invitaciones
  Future<void> _showSystemNotificationForInvitation(dynamic invitation) async {
    try {
      print('🔔💬 [MAINSCREEN] === INICIANDO NOTIFICACIÓN DE INVITACIÓN ===');
      print('🔔💬 [MAINSCREEN] InvitationId: ${invitation.id}');
      print('🔔💬 [MAINSCREEN] FromUserId: ${invitation.fromUserId}');

      // VERIFICAR: LocalNotificationService está inicializado
      try {
        await LocalNotificationService.instance.initialize();
        print('🔔💬 [MAINSCREEN] ✅ LocalNotificationService verificado');
      } catch (initError) {
        print(
            '🔔💬 [MAINSCREEN] ❌ Error verificando LocalNotificationService: $initError');
        return;
      }

      // MOSTRAR: Notificación del sistema
      print(
          '🔔💬 [MAINSCREEN] 📱 Llamando a showChatInvitationNotification...');

      await LocalNotificationService.instance.showChatInvitationNotification(
        invitationId: invitation.id ?? 'unknown',
        senderName: invitation.fromUserId ?? 'Usuario desconocido',
        message: 'Te ha enviado una invitación de chat efímero',
        senderAvatar: null,
      );

      print(
          '🔔💬 [MAINSCREEN] ✅ Notificación del sistema enviada para invitación: ${invitation.id}');
      print('🔔💬 [MAINSCREEN] === NOTIFICACIÓN DE INVITACIÓN COMPLETADA ===');
    } catch (e) {
      print(
          '❌ [MAINSCREEN] Error crítico mostrando notificación de invitación: $e');
      print('❌ [MAINSCREEN] Stack trace: ${StackTrace.current}');
    }
  }

  /// NUEVO: Mostrar notificación del sistema para mensajes
  Future<void> _showSystemNotificationForMessage(dynamic message) async {
    try {
      print('🔔💬 [MAINSCREEN] === INICIANDO NOTIFICACIÓN DE MENSAJE ===');
      print('🔔💬 [MAINSCREEN] MessageId: ${message.id}');
      print('🔔💬 [MAINSCREEN] SenderId: ${message.senderId}');
      print('🔔💬 [MAINSCREEN] Content: ${message.content}');

      // FILTRAR: No mostrar notificaciones para mensajes de verificación
      if (message.content != null &&
          message.content.toString().startsWith('VERIFICATION_CODES:')) {
        print('🔔💬 [MAINSCREEN] 🚫 Mensaje de verificación filtrado');
        return;
      }

      // VERIFICAR: LocalNotificationService está inicializado
      try {
        await LocalNotificationService.instance.initialize();
        print('🔔💬 [MAINSCREEN] ✅ LocalNotificationService verificado');
      } catch (initError) {
        print(
            '🔔💬 [MAINSCREEN] ❌ Error verificando LocalNotificationService: $initError');
        return;
      }

      // MOSTRAR: Notificación del sistema
      print('🔔💬 [MAINSCREEN] 📱 Llamando a showMessageNotification...');

      await LocalNotificationService.instance.showMessageNotification(
        messageId: message.id ?? 'unknown',
        senderName: message.senderId ?? 'Usuario desconocido',
        messageText:
            'Tienes un mensaje', // PRIVACIDAD: No mostrar contenido real
        senderAvatar: null,
      );

      print(
          '🔔💬 [MAINSCREEN] ✅ Notificación del sistema enviada para mensaje: ${message.id}');
      print('🔔💬 [MAINSCREEN] === NOTIFICACIÓN DE MENSAJE COMPLETADA ===');
    } catch (e) {
      print(
          '❌ [MAINSCREEN] Error crítico mostrando notificación de mensaje: $e');
      print('❌ [MAINSCREEN] Stack trace: ${StackTrace.current}');
    }
  }

  void _handleIncomingCall(String callId, String from, String token) async {
    print(
        '📞 Llamada entrante recibida en MainScreen: callId=$callId, from=$from');

    // Obtener información del llamante
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (authProvider.token == null) {
        print('⚠️ No hay token disponible para obtener detalles del llamante');
        return;
      }

      // Obtener datos del usuario y parsear la respuesta
      final response = await ApiService.get(
        '/api/users/$from',
        authProvider.token!,
      );

      if (response.statusCode != 200) {
        print('⚠️ Error al obtener datos del llamante: ${response.statusCode}');
        return;
      }

      // Verificar si la respuesta está vacía
      if (response.body.isEmpty) {
        print('⚠️ Respuesta vacía al obtener datos del llamante');
        return;
      }

      try {
        final dynamic userData = jsonDecode(response.body);

        // Verificar que userData sea un Map antes de intentar crear un User
        if (userData == null) {
          print('⚠️ Datos del llamante son null después de decodificar');
          return;
        }

        if (userData is! Map<String, dynamic>) {
          print(
              '⚠️ Datos del llamante no son un objeto Map: ${userData.runtimeType}');
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
                  '⚠️ No se pudieron convertir los datos del llamante a Map<String, dynamic>');
              return;
            }

            final caller = User.fromJson(safeUserData);

            if (!mounted) return;

            // Mostrar pantalla de llamada entrante
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => IncomingCallScreen(
                  callId: callId,
                  caller: caller,
                  isVideo: true,
                ),
              ),
            );
            return;
          }
          return;
        }

        final caller = User.fromJson(userData);

        if (!mounted) return;

        // Mostrar pantalla de llamada entrante
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => IncomingCallScreen(
              callId: callId,
              caller: caller,
              isVideo: true,
            ),
          ),
        );
      } catch (e) {
        print('❌ Error al decodificar o procesar datos del llamante: $e');
      }
    } catch (e) {
      print('❌ Error al procesar llamada entrante: $e');
    }
  }

  void _handleCallEnded(Map<String, dynamic> data) {
    print('🔚 Llamada terminada recibida en MainScreen: $data');

    // Notificar al CallProvider que la llamada terminó
    final callProvider = Provider.of<CallProvider>(context, listen: false);
    callProvider.endCall();

    // FORZAR navegación de vuelta a MainScreen desde cualquier pantalla de llamada
    if (mounted) {
      // Verificar si estamos en una pantalla de llamada
      final currentRoute = ModalRoute.of(context);
      if (currentRoute != null) {
        final routeName = currentRoute.settings.name;
        print('🔍 Ruta actual: $routeName');

        // Si estamos en CallScreen o IncomingCallScreen, volver a MainScreen
        if (routeName == '/call' ||
            currentRoute.settings.arguments is Map &&
                (currentRoute.settings.arguments as Map)
                    .containsKey('callId')) {
          print(
              '🔄 Navegando de vuelta a MainScreen desde pantalla de llamada');
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else {
          // Si no podemos determinar la ruta, intentar pop hasta llegar a home
          print('🔄 Intentando navegación alternativa a MainScreen');
          try {
            Navigator.of(context).popUntil((route) => route.isFirst);
          } catch (e) {
            print('⚠️ Error en navegación alternativa: $e');
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    // 📱 Responsive: Obtener dimensiones de pantalla
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final isMobile = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getAppBarTitle(),
          style: TextStyle(
            fontSize: isMobile ? 18 : 20, // Texto adaptativo
          ),
        ),
        backgroundColor: Color(0xFF1C1C1E),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: _buildResponsiveAppBarActions(authProvider, isMobile),
      ),
      backgroundColor: Color(0xFF000000),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // Pestaña 1: Lista de Chats
          ChatListScreen(
            ephemeralChatService: _ephemeralChatService,
            pendingInvitations: _pendingInvitations,
            isMobile: isMobile,
            isTablet: isTablet,
          ),
          // Pestaña 2: Llamadas (SearchUsersScreen)
          SearchUsersScreen(
            ephemeralChatService: _ephemeralChatService,
          ),
          // Pestaña 3: Demo Verificación
          VerificationDemoScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Color(0xFF1C1C1E),
        selectedItemColor: Color(0xFF007AFF),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: isMobile ? 12 : 14, // Texto adaptativo
        unselectedFontSize: isMobile ? 10 : 12,
        iconSize: isMobile ? 24 : 28, // Iconos adaptativos
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble),
            label: AppLocalizations.of(context)!.chats,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.call),
            label: AppLocalizations.of(context)!.calls,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.security),
            label: AppLocalizations.of(context)!.verification,
          ),
        ],
      ),
    );
  }

  String _getAppBarTitle() {
    final l10n = AppLocalizations.of(context)!;
    switch (_currentIndex) {
      case 0:
        return l10n.chats;
      case 1:
        return l10n.calls;
      case 2:
        return l10n.verification;
      default:
        return l10n.appTitle;
    }
  }

  // 📱 AppBar actions responsivo
  List<Widget> _buildResponsiveAppBarActions(
      AuthProvider authProvider, bool isMobile) {
    final iconSize = isMobile ? 20.0 : 24.0;
    final badgeSize = isMobile ? 14.0 : 16.0;

    return [
      // Icono de invitaciones (escudo) - responsivo
      IconButton(
        iconSize: iconSize,
        icon: Stack(
          children: [
            Icon(Icons.security, color: Colors.white, size: iconSize),
            if (_pendingInvitations.isNotEmpty)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: EdgeInsets.all(isMobile ? 1 : 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(badgeSize / 2),
                  ),
                  constraints: BoxConstraints(
                    minWidth: badgeSize,
                    minHeight: badgeSize,
                  ),
                  child: Text(
                    '${_pendingInvitations.length}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 8 : 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatInvitationsScreen(
                ephemeralChatService: _ephemeralChatService,
                pendingInvitations: _pendingInvitations,
              ),
            ),
          );
        },
      ),

      // Icono de perfil - responsivo
      IconButton(
        iconSize: iconSize,
        icon: Icon(Icons.account_circle, color: Colors.white, size: iconSize),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ProfileScreen(),
            ),
          );
        },
      ),

      // Icono de configuraciones - responsivo
      IconButton(
        iconSize: iconSize,
        icon: Icon(Icons.settings, color: Colors.white, size: iconSize),
        tooltip: isMobile
            ? null
            : AppLocalizations.of(context)!
                .securitySettingsTooltip, // Solo tooltip en pantallas grandes
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const SecuritySettingsScreen(),
            ),
          );
        },
      ),

      // Icono de logout - responsivo
      IconButton(
        iconSize: iconSize,
        icon: Icon(Icons.logout, color: Colors.white, size: iconSize),
        tooltip: isMobile ? null : AppLocalizations.of(context)!.logout,
        onPressed: () {
          _showLogoutDialog(authProvider);
        },
      ),
    ];
  }

  // Diálogo de confirmación para logout
  void _showLogoutDialog(AuthProvider authProvider) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF1C1C1E),
          title: Text(
            l10n.logoutConfirmTitle,
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            l10n.logoutConfirmMessage,
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                l10n.cancel,
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                authProvider.logout();
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Text(
                l10n.logout,
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  /// SOLUCIÓN OFICIAL FLUTTER 2025: Método síncrono para manejar invitaciones
  void _handleInvitationSync(invitation) {
    // CRÍTICO: Verificar tracking global de invitaciones rechazadas
    if (!InvitationTrackingService.instance
        .shouldProcessInvitation(invitation.id)) {
      print(
          '🔐 [MAINSCREEN] 🚫 Invitación ignorada por tracking global: ${invitation.id}');
      return;
    }

    // NUEVO: Verificar si ya existe antes de añadir
    final alreadyExists =
        _pendingInvitations.any((inv) => inv.id == invitation.id);
    if (alreadyExists) {
      print(
          '🔐 [MAINSCREEN] ⚠️ Invitación ya existe en lista: ${invitation.id}');
      return;
    }

    // PATRÓN OFICIAL FLUTTER 2025: Solo procesar si el widget está montado
    if (!mounted) {
      print(
          '🔐 [MAINSCREEN] ⚠️ Widget no montado - ignorando invitación: ${invitation.id}');
      return;
    }

    // FLUTTER 2025: setState síncrono - sin async gaps
    setState(() {
      _pendingInvitations.add(invitation);
    });

    print(
        '🔐 [MAINSCREEN] ✅ Invitación añadida a pendientes: ${invitation.id}');
    print(
        '🔐 [MAINSCREEN] 📊 Total invitaciones pendientes: ${_pendingInvitations.length}');

    // FLUTTER 2025: Llamar async sin BuildContext
    _showSystemNotificationForInvitation(invitation);

    // FLUTTER 2025: Usar context inmediatamente - no hay async gap
    if (mounted && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(AppLocalizations.of(context)!.newChatInvitationReceived),
          backgroundColor: Colors.orange,
          action: SnackBarAction(
            label: AppLocalizations.of(context)!.view,
            textColor: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatInvitationsScreen(
                    ephemeralChatService: _ephemeralChatService,
                    pendingInvitations: _pendingInvitations,
                  ),
                ),
              );
            },
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    print('🔐 [MAINSCREEN] 🔄 === DISPOSE EJECUTADO ===');

    // PATRÓN OFICIAL FLUTTER: Marcar como disposed ANTES de limpiar
    _callbacksConfigured = false;
    _lastRouteConfigured = null;

    // PATRÓN OFICIAL FLUTTER: Limpiar callbacks para evitar memory leaks
    try {
      _ephemeralChatService.onInvitationReceived = null;
      _ephemeralChatService.onMessageReceived = null;
      _ephemeralChatService.onError = null;
      print('🔐 [MAINSCREEN] ✅ Callbacks de EphemeralChatService limpiados');
    } catch (e) {
      print('🔐 [MAINSCREEN] ⚠️ Error limpiando callbacks: $e');
    }

    // NOTA: No limpiar ChatManager callbacks aquí - pueden ser usados por otros widgets
    // Solo marcar que este widget ya no los controla
    try {
      print(
          '🔐 [MAINSCREEN] ℹ️ ChatManager callbacks preservados para otros widgets');
    } catch (e) {
      print('🔐 [MAINSCREEN] ⚠️ Error con ChatManager: $e');
    }

    // PATRÓN OFICIAL FLUTTER: Dispose del servicio al final
    try {
      _ephemeralChatService.dispose();
      print('🔐 [MAINSCREEN] ✅ EphemeralChatService disposed');
    } catch (e) {
      print('🔐 [MAINSCREEN] ⚠️ Error disposing EphemeralChatService: $e');
    }

    print('🔐 [MAINSCREEN] 🔄 === DISPOSE COMPLETADO ===');
    super.dispose();
  }
}
