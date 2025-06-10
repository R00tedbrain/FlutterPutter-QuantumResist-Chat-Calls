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

    // PATRÓN OFICIAL FLUTTER: Solo limpiar en home, callbacks se preservan
    if (currentRoute == '/home') {
      _cleanRejectedInvitations();

      // NUEVO: SIEMPRE verificar callbacks reales (no confiar en flag)
      _ensureCallbacksConfigured();
      _callbacksConfigured = true;

      _lastRouteConfigured = currentRoute;
    }
  }

  @override
  void didUpdateWidget(covariant MainScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // PATRÓN OFICIAL FLUTTER: Verificar callbacks cuando el widget se actualiza
    _ensureCallbacksConfigured();
  }

  void _setupSocketService() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final callProvider = Provider.of<CallProvider>(context, listen: false);

    if (authProvider.token == null) {
      return;
    }

    _socketService = SocketService(token: authProvider.token);
    callProvider.setSocketService(_socketService);

    _socketService.onIncomingCall = _handleIncomingCall;
    _socketService.onCallEnded = _handleCallEnded;
  }

  void _setupEphemeralChatService() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.id;

    if (userId == null) {
      return;
    }

    _ephemeralChatService = EphemeralChatService();

    _ephemeralChatService.initialize(userId: userId).then((_) {
      // NUEVO: Inicializar LocalNotificationService Y EphemeralChatNotificationIntegration
      Future.wait([
        LocalNotificationService.instance.initialize(),
        EphemeralChatNotificationIntegration.instance.initialize(
          userId: userId,
          token: authProvider.token ?? '',
        ),
      ]).then((_) {
        // NOTA: Los callbacks se configuran directamente abajo para evitar sobrescritura
      }).catchError((e) {});

      // CONFIGURAR CALLBACKS DEL MAINSCREEN CON INTEGRACIÓN DE NOTIFICACIONES
      _ephemeralChatService.onInvitationReceived = (invitation) {
        // SOLUCIÓN OFICIAL FLUTTER 2025: Manejar callback sin async gaps
        _handleInvitationSync(invitation);
      };

      // NUEVO: Configurar callback para mensajes recibidos para notificaciones
      // NOTA: Los mensajes van a través del ChatManager, no del servicio global
      _ephemeralChatService.onMessageReceived = (message) {
        // NOTA: Esto solo maneja mensajes del servicio global (raramente usado)
        _showSystemNotificationForMessage(message);
      };

      // CRÍTICO: También configurar callback para ChatManager (donde realmente llegan los mensajes)
      _ensureCallbacksConfigured();
      _callbacksConfigured = true;

      _ephemeralChatService.onError = (error) {};

      // NOTA: Configuración de callbacks movida dentro del Future.wait() arriba
    }).catchError((error) {});
  }

  /// PATRÓN OFICIAL FLUTTER: Asegurar que los callbacks estén configurados correctamente
  void _ensureCallbacksConfigured() {
    try {
      // VERIFICAR: Estado del callback de invitaciones del servicio
      if (_ephemeralChatService.onInvitationReceived == null) {
        // SOLUCIÓN OFICIAL FLUTTER 2025: Usar método síncrono
        _ephemeralChatService.onInvitationReceived = (invitation) {
          _handleInvitationSync(invitation);
        };
      } else {}

      // Importar ChatManager si no está disponible
      final chatManager = EphemeralChatManager.instance;

      // PATRÓN OFICIAL: Solo configurar si no está configurado o se perdió
      if (chatManager.onMessageReceived == null) {
        // Configurar callback para mensajes recibidos en cualquier sesión
        chatManager.onMessageReceived = (sessionId, message) {
          // Filtrar mensajes de verificación
          if (message.content.startsWith('VERIFICATION_CODES:')) {
            return;
          }

          // Llamar a la función de notificación
          _showSystemNotificationForMessage(message);
        };
      } else {}
    } catch (e) {}
  }

  /// DEPRECATED: Usar _ensureCallbacksConfigured en su lugar
  void _setupChatManagerCallback() {
    _ensureCallbacksConfigured();
  }

  /// NUEVO: Limpiar invitaciones rechazadas de la lista local
  void _cleanRejectedInvitations() {
    if (!mounted) return;

    final initialCount = _pendingInvitations.length;

    // Limpiar invitaciones rechazadas
    final rejectedInvitations = _pendingInvitations
        .where((inv) => InvitationTrackingService.instance.isRejected(inv.id))
        .toList();

    // NUEVO: También limpiar invitaciones "fantasma" de usuarios con sesiones activas
    List<ChatInvitation> phantomInvitations = [];
    try {
      final chatManager = EphemeralChatManager.instance;
      final activeSessions = chatManager.activeSessions;

      phantomInvitations = _pendingInvitations.where((inv) {
        return activeSessions.any((session) =>
            session.targetUserId == inv.fromUserId &&
            (session.currentRoom != null || session.justReset));
      }).toList();
    } catch (e) {
      // Si hay error, continuar solo con limpieza de rechazadas
    }

    final allToRemove = [...rejectedInvitations, ...phantomInvitations];

    if (allToRemove.isNotEmpty) {
      for (final inv in allToRemove) {}

      setState(() {
        // Remover invitaciones rechazadas
        _pendingInvitations.removeWhere(
            (inv) => InvitationTrackingService.instance.isRejected(inv.id));

        // Remover invitaciones fantasma
        for (final phantom in phantomInvitations) {
          _pendingInvitations.remove(phantom);
        }
      });

      final finalCount = _pendingInvitations.length;
    } else {}
  }

  /// NUEVO: Mostrar notificación del sistema para invitaciones
  Future<void> _showSystemNotificationForInvitation(dynamic invitation) async {
    try {
      // VERIFICAR: LocalNotificationService está inicializado
      try {
        await LocalNotificationService.instance.initialize();
      } catch (initError) {
        return;
      }

      // MOSTRAR: Notificación del sistema
      await LocalNotificationService.instance.showChatInvitationNotification(
        invitationId: invitation.id ?? 'unknown',
        senderName: invitation.fromUserId ?? 'Usuario desconocido',
        message: 'Te ha enviado una invitación de chat efímero',
        senderAvatar: null,
      );
    } catch (e) {}
  }

  /// NUEVO: Mostrar notificación del sistema para mensajes
  Future<void> _showSystemNotificationForMessage(dynamic message) async {
    try {
      // FILTRAR: No mostrar notificaciones para mensajes de verificación
      if (message.content != null &&
          message.content.toString().startsWith('VERIFICATION_CODES:')) {
        return;
      }

      // VERIFICAR: LocalNotificationService está inicializado
      try {
        await LocalNotificationService.instance.initialize();
      } catch (initError) {
        return;
      }

      // MOSTRAR: Notificación del sistema
      await LocalNotificationService.instance.showMessageNotification(
        messageId: message.id ?? 'unknown',
        senderName: message.senderId ?? 'Usuario desconocido',
        messageText:
            'Tienes un mensaje', // PRIVACIDAD: No mostrar contenido real
        senderAvatar: null,
      );
    } catch (e) {}
  }

  void _handleIncomingCall(String callId, String from, String token) async {
    // Obtener información del llamante
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (authProvider.token == null) {
        return;
      }

      // Obtener datos del usuario y parsear la respuesta
      final response = await ApiService.get(
        '/api/users/$from',
        authProvider.token!,
      );

      if (response.statusCode != 200) {
        return;
      }

      // Verificar si la respuesta está vacía
      if (response.body.isEmpty) {
        return;
      }

      try {
        final dynamic userData = jsonDecode(response.body);

        // Verificar que userData sea un Map antes de intentar crear un User
        if (userData == null) {
          return;
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
      } catch (e) {}
    } catch (e) {}
  }

  void _handleCallEnded(Map<String, dynamic> data) {
    // Notificar al CallProvider que la llamada terminó
    final callProvider = Provider.of<CallProvider>(context, listen: false);
    callProvider.endCall();

    // FORZAR navegación de vuelta a MainScreen desde cualquier pantalla de llamada
    if (mounted) {
      // Verificar si estamos en una pantalla de llamada
      final currentRoute = ModalRoute.of(context);
      if (currentRoute != null) {
        final routeName = currentRoute.settings.name;

        // Si estamos en CallScreen o IncomingCallScreen, volver a MainScreen
        if (routeName == '/call' ||
            currentRoute.settings.arguments is Map &&
                (currentRoute.settings.arguments as Map)
                    .containsKey('callId')) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else {
          // Si no podemos determinar la ruta, intentar pop hasta llegar a home
          try {
            Navigator.of(context).popUntil((route) => route.isFirst);
          } catch (e) {}
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
    print('🔐 [MAINSCREEN] 📨 === INVITACIÓN RECIBIDA ===');
    print('🔐 [MAINSCREEN] 📨 ID: ${invitation.id}');
    print('🔐 [MAINSCREEN] 📨 From: ${invitation.fromUserId}');
    print('🔐 [MAINSCREEN] 📨 To: ${invitation.toUserId}');

    // CRÍTICO: Verificar tracking global de invitaciones rechazadas
    if (!InvitationTrackingService.instance
        .shouldProcessInvitation(invitation.id)) {
      print('🔐 [MAINSCREEN] ❌ Invitación ya rechazada - ignorando');
      return;
    }

    // NUEVO: Verificar si ya existe antes de añadir
    final alreadyExists =
        _pendingInvitations.any((inv) => inv.id == invitation.id);
    if (alreadyExists) {
      print('🔐 [MAINSCREEN] ❌ Invitación ya existe en lista - ignorando');
      return;
    }

    // NUEVO: Verificar si hay una sesión activa con este usuario para evitar invitaciones fantasma
    try {
      final chatManager = EphemeralChatManager.instance;
      final activeSessions = chatManager.activeSessions;

      print(
          '🔐 [MAINSCREEN] 🔍 Verificando sesiones activas: ${activeSessions.length}');

      // Si ya hay una sesión activa o recién destruida con este usuario, ignorar invitación
      final hasActiveSession = activeSessions.any((session) =>
          session.targetUserId == invitation.fromUserId &&
          (session.currentRoom != null || session.justReset));

      if (hasActiveSession) {
        print('🔐 [MAINSCREEN] 👻 INVITACIÓN FANTASMA DETECTADA Y BLOQUEADA');
        print('🔐 [MAINSCREEN] 👻 Usuario: ${invitation.fromUserId}');
        // Es una invitación fantasma - no procesarla
        return;
      } else {
        print('🔐 [MAINSCREEN] ✅ No hay sesión activa - invitación válida');
      }
    } catch (e) {
      print('🔐 [MAINSCREEN] ⚠️ Error verificando sesiones: $e');
      // Si hay error verificando, continuar con el flujo normal por seguridad
    }

    // PATRÓN OFICIAL FLUTTER 2025: Solo procesar si el widget está montado
    if (!mounted) {
      print('🔐 [MAINSCREEN] ❌ Widget no montado - ignorando');
      return;
    }

    print('🔐 [MAINSCREEN] ✅ PROCESANDO INVITACIÓN VÁLIDA');

    // FLUTTER 2025: setState síncrono - sin async gaps
    setState(() {
      _pendingInvitations.add(invitation);
    });

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
    // PATRÓN OFICIAL FLUTTER: Marcar como disposed ANTES de limpiar
    _callbacksConfigured = false;
    _lastRouteConfigured = null;

    // PATRÓN OFICIAL FLUTTER: Limpiar callbacks para evitar memory leaks
    try {
      _ephemeralChatService.onInvitationReceived = null;
      _ephemeralChatService.onMessageReceived = null;
      _ephemeralChatService.onError = null;
    } catch (e) {}

    // NOTA: No limpiar ChatManager callbacks aquí - pueden ser usados por otros widgets
    // Solo marcar que este widget ya no los controla
    try {} catch (e) {}

    // PATRÓN OFICIAL FLUTTER: Dispose del servicio al final
    try {
      _ephemeralChatService.dispose();
    } catch (e) {}

    super.dispose();
  }
}
