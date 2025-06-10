import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/ephemeral_chat_manager.dart';
import '../services/local_notification_service.dart';
import '../models/chat_session.dart';
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

  @override
  void initState() {
    super.initState();

    print('🏢 [MULTI-ROOM] Inicializando pantalla de múltiples salas');

    // NUEVO: Usar singleton en lugar de crear nueva instancia
    _chatManager = EphemeralChatManager.instance;
    print('🏢 [MULTI-ROOM] ✅ Usando singleton existente');

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
      print('🏢 [MULTI-ROOM] Sesiones cambiadas: ${sessions.length}');

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

      print('🏢 [MULTI-ROOM] Sesiones a mostrar: ${activeSessions.length}');
      for (final session in activeSessions) {
        print(
            '🏢 [MULTI-ROOM] - ${session.sessionId}: ${session.currentRoom?.id ?? "sin sala"} (conectando: ${session.isConnecting})');
      }

      if (mounted) {
        setState(() {
          _sessions = activeSessions;
          _updateTabController();
        });
      }
    };

    _chatManager.onMessageReceived = (sessionId, message) {
      print('🏢 [MULTI-ROOM] Mensaje recibido en sesión: $sessionId');

      // NUEVO: También manejar notificaciones desde MultiRoomChatScreen
      _showSystemNotificationForMessage(message);

      // La UI se actualiza automáticamente por onSessionsChanged
    };

    _chatManager.onSessionError = (sessionId, error) {
      print('🏢 [MULTI-ROOM] Error en sesión $sessionId: $error');

      // CORREGIDO: Limpiar sesión con error
      try {
        _chatManager.closeSession(sessionId);
        print('🏢 [MULTI-ROOM] ✅ Sesión con error cerrada: $sessionId');
      } catch (e) {
        print('🏢 [MULTI-ROOM] ⚠️ Error cerrando sesión: $e');
      }

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
      print('🏢 [MULTI-ROOM] Sesión conectada: $sessionId');
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
    // Verificar si ya está inicializado
    if (_chatManager.hasGlobalInvitationService) {
      print('🏢 [MULTI-ROOM] ✅ Servicio global ya existe - reutilizando');

      // Solo configurar callback
      _chatManager.onGlobalInvitationReceived = (invitation) {
        print(
            '🏢 [MULTI-ROOM] 📨 Invitación global recibida en UI: ${invitation.id}');
        _showInvitationDialog(invitation);
      };

      return;
    }

    // Si no existe, inicializarlo
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUserId = authProvider.user?.id ?? 'unknown';

      await _chatManager.initializeGlobalInvitationService(currentUserId);

      // Configurar callback para invitaciones globales
      _chatManager.onGlobalInvitationReceived = (invitation) {
        print(
            '🏢 [MULTI-ROOM] 📨 Invitación global recibida en UI: ${invitation.id}');
        _showInvitationDialog(invitation);
      };

      print('🏢 [MULTI-ROOM] ✅ Servicio global de invitaciones configurado');
    } catch (e) {
      print('🏢 [MULTI-ROOM] ❌ Error configurando servicio global: $e');
    }
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
      print('🏢 [MULTI-ROOM] ❌ Error aceptando invitación: $e');
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
          print('🏢 [MULTI-ROOM] Error específico con invitación: $e');
          rethrow;
        }
      }
    } catch (e) {
      print('🏢 [MULTI-ROOM] Error manejando sesión inicial: $e');
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
      print('🏢 [MULTI-ROOM] Pestaña activa: ${session.sessionId}');
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
      print('🏢 [MULTI-ROOM] Error creando nueva sesión: $e');
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
    print('🏢 [MULTI-ROOM] 🗑️ Cerrando sesión: $sessionId');

    // Encontrar la sesión
    final session = _sessions.firstWhere(
      (s) => s.sessionId == sessionId,
      orElse: () => throw Exception('Sesión no encontrada: $sessionId'),
    );

    try {
      // NUEVO: Enviar evento de destrucción al servidor si hay sala activa
      if (session.currentRoom != null) {
        print(
            '🏢 [MULTI-ROOM] 💥 Enviando destrucción de sala: ${session.currentRoom!.id}');
        session.chatService.startDestructionCountdown();
      }

      // Cerrar la sesión en el manager
      _chatManager.closeSession(sessionId);
      print('🏢 [MULTI-ROOM] ✅ Sesión cerrada correctamente');
    } catch (e) {
      print('🏢 [MULTI-ROOM] ❌ Error cerrando sesión: $e');

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
            print('🏢 [MULTI-ROOM] ⬅️ Volviendo atrás desde chats múltiples');

            // CORREGIDO: NO cerrar sesiones al volver atrás - deben persistir
            // Las sesiones solo se cierran cuando:
            // 1. El usuario las cierra explícitamente con la X
            // 2. Se autodestruyen
            // 3. Se usa el botón "Cerrar Todas"

            print(
                '🏢 [MULTI-ROOM] ✅ Sesiones mantenidas activas: ${_chatManager.activeSessions.length}');

            // Volver atrás manteniendo las sesiones
            Navigator.of(context).pop();
            print(
                '🏢 [MULTI-ROOM] ✅ Navegación hacia atrás completada - sesiones preservadas');
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
    print('🏢 [MULTI-ROOM] Liberando recursos de pantalla...');

    // CRÍTICO: Solo limpiar callbacks si MainScreen NO está activo
    // Verificar si estamos navegando de vuelta a MainScreen
    try {
      final navigator = Navigator.of(context);
      final canPop = navigator.canPop();

      if (canPop) {
        print('🏢 [MULTI-ROOM] ⚠️ Navegando de vuelta - NO limpiar callbacks');
        print('🏢 [MULTI-ROOM] ℹ️ MainScreen se hará cargo de los callbacks');
      } else {
        print(
            '🏢 [MULTI-ROOM] 🧹 Saliendo completamente - limpiando callbacks');
        _chatManager.clearCallbacks();
      }
    } catch (e) {
      print(
          '🏢 [MULTI-ROOM] ⚠️ Error verificando navegación: $e - NO limpiar callbacks por seguridad');
    }

    print('🏢 [MULTI-ROOM] ✅ Recursos liberados - singleton preservado');
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    print(
        '🏢 [MULTI-ROOM] 🔄 didChangeDependencies ejecutado - reconfigurar estado');

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
    print('🏢 [MULTI-ROOM] 🌐 Verificando servicio global de invitaciones...');

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.id;

    if (userId != null && !_chatManager.hasGlobalInvitationService) {
      print('🏢 [MULTI-ROOM] ⚠️ Servicio global perdido - reinicializando...');

      _chatManager.initializeGlobalInvitationService(userId).then((_) {
        print('🏢 [MULTI-ROOM] ✅ Servicio global reinicializado correctamente');

        // Reconfigurar callback de invitaciones globales
        _chatManager.onGlobalInvitationReceived = (invitation) {
          print(
              '🏢 [MULTI-ROOM] 📨 Invitación global recibida después de reinicio: ${invitation.id}');
          _showInvitationDialog(invitation);
        };
      }).catchError((e) {
        print('🏢 [MULTI-ROOM] ❌ Error reinicializando servicio global: $e');
      });
    } else {
      print('🏢 [MULTI-ROOM] ✅ Servicio global ya activo');
    }
  }

  /// NUEVO: Forzar actualización de todas las sesiones activas
  void _forceUpdateAllSessions() {
    print('🏢 [MULTI-ROOM] 🔄 Forzando actualización de todas las sesiones...');

    for (final session in _sessions) {
      if (session.currentRoom != null) {
        print('🏢 [MULTI-ROOM] 🔄 Actualizando sesión: ${session.sessionId}');

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
      print('🔔💬 [MULTI-ROOM] === INICIANDO NOTIFICACIÓN DE MENSAJE ===');
      print('🔔💬 [MULTI-ROOM] MessageId: ${message.id}');
      print('🔔💬 [MULTI-ROOM] SenderId: ${message.senderId}');
      print('🔔💬 [MULTI-ROOM] Content: ${message.content}');

      // FILTRAR: No mostrar notificaciones para mensajes de verificación
      if (message.content != null &&
          message.content.toString().startsWith('VERIFICATION_CODES:')) {
        print('🔔💬 [MULTI-ROOM] 🚫 Mensaje de verificación filtrado');
        return;
      }

      // VERIFICAR: LocalNotificationService está inicializado
      try {
        await LocalNotificationService.instance.initialize();
        print('🔔💬 [MULTI-ROOM] ✅ LocalNotificationService verificado');
      } catch (initError) {
        print(
            '🔔💬 [MULTI-ROOM] ❌ Error verificando LocalNotificationService: $initError');
        return;
      }

      // MOSTRAR: Notificación del sistema
      print('🔔💬 [MULTI-ROOM] 📱 Llamando a showMessageNotification...');

      await LocalNotificationService.instance.showMessageNotification(
        messageId: message.id ?? 'unknown',
        senderName: message.senderId ?? 'Usuario desconocido',
        messageText:
            'Tienes un mensaje', // PRIVACIDAD: No mostrar contenido real
        senderAvatar: null,
      );

      print(
          '🔔💬 [MULTI-ROOM] ✅ Notificación del sistema enviada para mensaje: ${message.id}');
      print('🔔💬 [MULTI-ROOM] === NOTIFICACIÓN DE MENSAJE COMPLETADA ===');
    } catch (e) {
      print(
          '❌ [MULTI-ROOM] Error crítico mostrando notificación de mensaje: $e');
      print('❌ [MULTI-ROOM] Stack trace: ${StackTrace.current}');
    }
  }
}
