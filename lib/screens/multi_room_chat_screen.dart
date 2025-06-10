import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/ephemeral_chat_manager.dart';
import '../services/local_notification_service.dart';
import '../models/chat_session.dart';
import '../models/chat_invitation.dart';
import '../models/user.dart';
import '../widgets/room_tab_widget.dart';
import '../widgets/user_search_widget.dart';
import '../screens/ephemeral_chat_screen_multimedia.dart';
import '../l10n/app_localizations.dart';

/// Pantalla principal para gestionar múltiples salas de chat simultáneas
/// Utiliza TabBarView para navegación fluida entre salas
class MultiRoomChatScreen extends StatefulWidget {
  final String? initialTargetUserId;
  final String? initialInvitationId;

  const MultiRoomChatScreen({
    super.key,
    this.initialTargetUserId,
    this.initialInvitationId,
  });

  @override
  State<MultiRoomChatScreen> createState() => _MultiRoomChatScreenState();
}

class _MultiRoomChatScreenState extends State<MultiRoomChatScreen>
    with TickerProviderStateMixin {
  late EphemeralChatManager _chatManager;
  late TabController _tabController;

  List<ChatSession> _sessions = [];
  bool _isLoading = false;
  String? _error;

  // NUEVO: Preservar callback original para no romper MainScreen
  Function(ChatInvitation)? _originalInvitationCallback;

  @override
  void initState() {
    super.initState();

    // NUEVO: Usar singleton en lugar de crear nueva instancia
    _chatManager = EphemeralChatManager.instance;

    // Configurar callbacks
    _setupManagerCallbacks();

    // NUEVO: Solo inicializar servicio global si no existe
    _initializeGlobalInvitationServiceIfNeeded();

    // Inicializar TabController con sesiones existentes
    _sessions = _chatManager.activeSessions;
    _tabController = TabController(length: _sessions.length + 1, vsync: this);

    // Si hay parámetros iniciales, crear/aceptar sesión
    if (widget.initialTargetUserId != null ||
        widget.initialInvitationId != null) {
      _handleInitialSession();
    }
  }

  /// Configurar callbacks del manager
  void _setupManagerCallbacks() {
    _chatManager.onSessionsChanged = (sessions) {
      // CORREGIDO: No filtrar sesiones tan agresivamente - mostrar TODAS las sesiones activas
      // Esto incluye sesiones "conectando", "esperando respuesta" y "con sala activa"
      final activeSessions = sessions
          .where((session) =>
              // Mostrar sesión si:
              // 1. Tiene una sala activa con ID válido
              (session.currentRoom != null &&
                  session.currentRoom!.id.isNotEmpty) ||
              // 2. Está conectando (nueva invitación enviada)
              session.isConnecting ||
              // 3. Tiene servicio de chat activo (esperando respuesta)
              session.chatService.isConnected ||
              // 4. Simplemente existe y está en el manager (mostrar siempre)
              true) // NUEVO: Mostrar TODAS las sesiones del manager
          .toList();

      if (mounted) {
        setState(() {
          _sessions = activeSessions;
          _updateTabController();
        });
      }
    };

    _chatManager.onMessageReceived = (sessionId, message) {
      // NUEVO: También manejar notificaciones desde MultiRoomChatScreen
      _showSystemNotificationForMessage(message);

      // La UI se actualiza automáticamente por onSessionsChanged
    };

    _chatManager.onSessionError = (sessionId, error) {
      // CORREGIDO: Limpiar sesión con error
      try {
        _chatManager.closeSession(sessionId);
      } catch (e) {}

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error en chat: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    };

    _chatManager.onSessionConnected = (sessionId) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chat conectado'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      }
    };
  }

  /// NUEVO: Solo inicializar servicio global si no existe
  Future<void> _initializeGlobalInvitationServiceIfNeeded() async {
    // CRÍTICO: Preservar callback original ANTES de sobrescribir
    _originalInvitationCallback = _chatManager.onGlobalInvitationReceived;

    // Verificar si ya está inicializado
    if (_chatManager.hasGlobalInvitationService) {
      // Configurar callback COMBINADO que llama ambos
      _chatManager.onGlobalInvitationReceived = (invitation) {
        // Primero ejecutar callback original (MainScreen)
        if (_originalInvitationCallback != null) {
          try {
            _originalInvitationCallback!(invitation);
          } catch (e) {
            print('🔐 [MULTIROOM] ⚠️ Error en callback original: $e');
          }
        }

        // Luego mostrar diálogo propio
        _showInvitationDialog(invitation);
      };

      return;
    }

    // Si no existe, inicializarlo
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUserId = authProvider.user?.id ?? 'unknown';

      await _chatManager.initializeGlobalInvitationService(currentUserId);

      // Configurar callback COMBINADO
      _chatManager.onGlobalInvitationReceived = (invitation) {
        // Primero ejecutar callback original (MainScreen)
        if (_originalInvitationCallback != null) {
          try {
            _originalInvitationCallback!(invitation);
          } catch (e) {
            print('🔐 [MULTIROOM] ⚠️ Error en callback original: $e');
          }
        }

        // Luego mostrar diálogo propio
        _showInvitationDialog(invitation);
      };
    } catch (e) {}
  }

  /// NUEVO: Mostrar diálogo de invitación recibida
  void _showInvitationDialog(invitation) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.mail, color: Colors.blue),
            SizedBox(width: 10),
            Text('📨 Invitación de Chat'),
          ],
        ),
        content: Text(
          'Has recibido una invitación de chat efímero.\n\n'
          'De: ${invitation.fromUserId}\n'
          'Expira en: ${invitation.timeLeftFormatted}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Rechazar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _acceptInvitation(invitation);
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  /// NUEVO: Aceptar invitación recibida
  Future<void> _acceptInvitation(invitation) async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUserId = authProvider.user?.id ?? 'unknown';

      final session = await _chatManager.acceptInvitation(
        invitationId: invitation.id,
        targetUserId: invitation.fromUserId,
        currentUserId: currentUserId,
      );

      // Cambiar a la nueva pestaña
      final sessionIndex = _sessions.indexOf(session);
      if (sessionIndex >= 0) {
        _tabController.animateTo(sessionIndex);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Invitación aceptada'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error aceptando invitación: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Manejar sesión inicial si se proporcionaron parámetros
  Future<void> _handleInitialSession() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUserId = authProvider.user?.id ?? 'unknown';

      if (widget.initialTargetUserId != null) {
        // Crear nueva sesión
        await _chatManager.createChatSession(
          targetUserId: widget.initialTargetUserId!,
          currentUserId: currentUserId,
        );
      } else if (widget.initialInvitationId != null) {
        // CORREGIDO: Obtener información real de la invitación
        try {
          // Intentar obtener la invitación del servicio global
          String fromUserId = 'unknown';

          // Si tenemos el servicio global, buscar la invitación
          if (_chatManager.hasGlobalInvitationService) {
            // Por ahora usamos 'unknown' pero se actualizará cuando se conecte la sala
            fromUserId = 'unknown';
          }

          await _chatManager.acceptInvitation(
            invitationId: widget.initialInvitationId!,
            targetUserId: fromUserId, // Se actualizará cuando se conecte
            currentUserId: currentUserId,
          );
        } catch (e) {
          rethrow;
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error iniciando chat: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Actualizar TabController cuando cambian las sesiones
  void _updateTabController() {
    final newLength = _sessions.length + 1; // +1 para el botón "Agregar"

    if (_tabController.length != newLength) {
      final oldIndex = _tabController.index;
      _tabController.dispose();
      _tabController = TabController(
        length: newLength,
        vsync: this,
        initialIndex: oldIndex < newLength ? oldIndex : 0,
      );

      // Configurar listener para cambios de pestaña
      _tabController.addListener(_onTabChanged);
    }
  }

  /// Manejar cambio de pestaña
  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;

    final index = _tabController.index;

    if (index < _sessions.length) {
      // Pestaña de sesión
      final session = _sessions[index];
      _chatManager.setActiveSession(session.sessionId);
    } else {
      // Pestaña "Agregar"
      _chatManager.setActiveSession(null);
    }
  }

  /// Mostrar diálogo para crear nueva sala
  Future<void> _showCreateRoomDialog() async {
    final result = await showModalBottomSheet<User>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: UserSearchWidget(
          onUserSelected: (user) {
            Navigator.of(context).pop(user);
          },
          onCancel: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );

    if (result != null) {
      await _createNewSession(result);
    }
  }

  /// Crear nueva sesión de chat
  Future<void> _createNewSession(User targetUser) async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUserId = authProvider.user?.id ?? 'unknown';

      final session = await _chatManager.createChatSession(
        targetUserId: targetUser.id,
        targetUserName: targetUser.nickname,
        currentUserId: currentUserId,
      );

      // Cambiar a la nueva pestaña
      final sessionIndex = _sessions.indexOf(session);
      if (sessionIndex >= 0) {
        _tabController.animateTo(sessionIndex);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error creando sala: $e';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Cerrar una sesión específica
  void _closeSession(String sessionId) {
    // Encontrar la sesión
    final session = _sessions.firstWhere(
      (s) => s.sessionId == sessionId,
      orElse: () => throw Exception('Sesión no encontrada: $sessionId'),
    );

    try {
      // NUEVO: Enviar evento de destrucción al servidor si hay sala activa
      if (session.currentRoom != null) {
        session.chatService.startDestructionCountdown();
      }

      // Cerrar la sesión en el manager
      _chatManager.closeSession(sessionId);
    } catch (e) {
      // Mostrar error al usuario
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error cerrando sala: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    // Si era la última pestaña, ir a la anterior
    if (_tabController.index >= _sessions.length && _sessions.isNotEmpty) {
      _tabController.animateTo(_sessions.length - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.multipleChatsTitle(_sessions.length)),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[900]
            : Colors.blue,
        foregroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // CORREGIDO: NO cerrar sesiones al volver atrás - deben persistir
            // Las sesiones solo se cierran cuando:
            // 1. El usuario las cierra explícitamente con la X
            // 2. Se autodestruyen
            // 3. Se usa el botón "Cerrar Todas"

            // Volver atrás manteniendo las sesiones
            Navigator.of(context).pop();
          },
          tooltip: 'Volver',
        ),
        actions: [
          // Botón de estadísticas
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showStatsDialog();
            },
          ),
          // Botón de cerrar todas las salas
          if (_sessions.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all, color: Colors.red),
              onPressed: () {
                _showCloseAllDialog();
              },
            ),
        ],
        bottom: _sessions.isNotEmpty || _isLoading
            ? PreferredSize(
                preferredSize: const Size.fromHeight(80),
                child: _buildTabBar(),
              )
            : null,
      ),
      body: _buildBody(),
      // NUEVO: FloatingActionButton que solo aparece cuando no hay chats activos
      floatingActionButton: _sessions.isEmpty && !_isLoading
          ? FloatingActionButton.extended(
              onPressed: _showCreateRoomDialog,
              icon: const Icon(Icons.add),
              label: Text(l10n.newRoom),
              backgroundColor: Colors.blue,
              tooltip: l10n.createNewChatRoom,
            )
          : null, // Ocultar cuando hay chats activos para evitar solapamiento
    );
  }

  /// Construir barra de pestañas
  Widget _buildTabBar() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: Colors.blue,
        indicatorWeight: 3,
        tabs: [
          // Pestañas de sesiones
          ..._sessions.map((session) => Tab(
                child: RoomTabWidget(
                  session: session,
                  isActive: _chatManager.currentActiveSession?.sessionId ==
                      session.sessionId,
                  onClose: () => _closeSession(session.sessionId),
                ),
              )),
          // Pestaña "Agregar"
          Tab(
            child: AddRoomTabWidget(
              onTap: _showCreateRoomDialog,
            ),
          ),
        ],
      ),
    );
  }

  /// Construir cuerpo principal
  Widget _buildBody() {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading && _sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(l10n.initiatingChat),
          ],
        ),
      );
    }

    if (_error != null && _sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _error = null;
                });
              },
              child: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    if (_sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              l10n.noActiveChats,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.useNewRoomButton,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        // Vistas de sesiones
        ..._sessions.map((session) => EphemeralChatScreenMultimedia(
              key: ValueKey(session.sessionId),
              ephemeralChatService: session.chatService,
              isFromMultiRoom: true,
            )),
        // Vista "Agregar"
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_circle_outline,
                  size: 64, color: Colors.blue),
              const SizedBox(height: 16),
              Text(
                l10n.createNewRoom,
                style: const TextStyle(fontSize: 18, color: Colors.blue),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _showCreateRoomDialog,
                child: Text(l10n.addChat),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Mostrar diálogo de estadísticas
  void _showStatsDialog() {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.statistics),
        content: ChatStatsWidget(stats: _chatManager.getStats()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  /// Mostrar diálogo de confirmación para cerrar todas las salas
  void _showCloseAllDialog() {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.closeAllRooms),
        content: Text(l10n.closeAllRoomsConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _chatManager.closeAllSessions();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.closeAll),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // CRÍTICO: Restaurar callback original ANTES de salir
    print('🔐 [MULTIROOM] 🔄 Restaurando callback original...');
    try {
      if (_originalInvitationCallback != null) {
        _chatManager.onGlobalInvitationReceived = _originalInvitationCallback;
        print('🔐 [MULTIROOM] ✅ Callback original restaurado');
      } else {
        print('🔐 [MULTIROOM] ⚠️ No había callback original para restaurar');
      }
    } catch (e) {
      print('🔐 [MULTIROOM] ❌ Error restaurando callback: $e');
    }

    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // NUEVO: Asegurar que el servicio global esté activo
    _ensureGlobalServiceActive();

    // NUEVO: Reconfigurar callbacks cada vez que se vuelve a la pantalla
    _setupManagerCallbacks();

    // NUEVO: Forzar actualización del estado de sesiones
    if (mounted) {
      setState(() {
        _sessions = _chatManager.activeSessions;
        _updateTabController();
      });
    }

    // NUEVO: Forzar actualización de sesiones al regresar
    _forceUpdateAllSessions();
  }

  /// NUEVO: Asegurar que el servicio global de invitaciones esté activo
  void _ensureGlobalServiceActive() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.id;

    if (userId != null && !_chatManager.hasGlobalInvitationService) {
      _chatManager.initializeGlobalInvitationService(userId).then((_) {
        // Reconfigurar callback de invitaciones globales
        _chatManager.onGlobalInvitationReceived = (invitation) {
          _showInvitationDialog(invitation);
        };
      }).catchError((e) {});
    } else {}
  }

  /// NUEVO: Forzar actualización de todas las sesiones activas
  void _forceUpdateAllSessions() {
    for (final session in _sessions) {
      if (session.currentRoom != null) {
        // Forzar actualización de participantes en cada sesión
        session.chatService.forceUpdateParticipants();
      }
    }

    // También actualizar la UI
    if (mounted) {
      setState(() {
        _sessions = _chatManager.activeSessions;
      });
    }
  }

  /// NUEVO: Mostrar notificación del sistema para mensajes (copiado desde MainScreen)
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
}
