import 'dart:async';
import '../models/chat_session.dart';
import '../models/ephemeral_message.dart';
import '../models/chat_invitation.dart';
import 'ephemeral_chat_service.dart';

/// Gestor central para múltiples salas de chat efímero simultáneas
/// Mantiene aislamiento completo entre sesiones para máxima seguridad
/// SINGLETON: Una sola instancia global para toda la aplicación
class EphemeralChatManager {
  static const int MAX_CONCURRENT_SESSIONS = 10;

  // SINGLETON PATTERN ROBUSTO
  static EphemeralChatManager? _instance;

  // Constructor privado
  EphemeralChatManager._internal() {
    _startDestructionTimer();
  }

  // Getter estático para obtener la instancia única
  static EphemeralChatManager get instance {
    if (_instance == null) {
      _instance = EphemeralChatManager._internal();
    } else {}
    return _instance!;
  }

  // DEPRECATED: Constructor factory (redirige al singleton)
  factory EphemeralChatManager() {
    return instance;
  }

  // Mapa de sesiones activas: sessionId -> ChatSession
  final Map<String, ChatSession> _activeSessions = {};

  // ID de la sesión actualmente visible
  String? _currentActiveSessionId;

  // Timer para limpieza automática de mensajes destruidos
  Timer? _destructionTimer;

  // NUEVO: Servicio global para escuchar invitaciones
  EphemeralChatService? _globalInvitationService;
  String? _currentUserId;

  // Callbacks para la UI
  Function(List<ChatSession>)? onSessionsChanged;
  Function(String sessionId, EphemeralMessage message)? onMessageReceived;
  Function(String sessionId, String error)? onSessionError;
  Function(String sessionId)? onSessionConnected;
  Function(ChatInvitation)? onGlobalInvitationReceived; // NUEVO

  // NUEVO: Sistema de callbacks apilados para invitaciones
  final List<Function(ChatInvitation)> _invitationCallbackStack = [];

  /// NUEVO: Verificar si el servicio global está inicializado
  bool get hasGlobalInvitationService => _globalInvitationService != null;

  /// NUEVO: Agregar callback al stack (permite múltiples callbacks activos)
  void pushInvitationCallback(Function(ChatInvitation) callback) {
    _invitationCallbackStack.add(callback);
    print(
        '🔐 [CHAT_MANAGER] 📚 Callback agregado al stack. Total: ${_invitationCallbackStack.length}');
  }

  /// NUEVO: Remover el último callback del stack
  Function(ChatInvitation)? popInvitationCallback() {
    if (_invitationCallbackStack.isNotEmpty) {
      final removed = _invitationCallbackStack.removeLast();
      print(
          '🔐 [CHAT_MANAGER] 📚 Callback removido del stack. Restantes: ${_invitationCallbackStack.length}');
      return removed;
    }
    return null;
  }

  /// NUEVO: Ejecutar TODOS los callbacks del stack
  void _executeInvitationCallbacks(ChatInvitation invitation) {
    print(
        '🔐 [CHAT_MANAGER] 📢 Ejecutando ${_invitationCallbackStack.length} callbacks para invitación ${invitation.id}');

    for (int i = 0; i < _invitationCallbackStack.length; i++) {
      try {
        print('🔐 [CHAT_MANAGER] 📢 Ejecutando callback #$i');
        _invitationCallbackStack[i](invitation);
      } catch (e) {
        print('🔐 [CHAT_MANAGER] ❌ Error en callback #$i: $e');
      }
    }

    // DEPRECATED: Mantener compatibilidad con callback único
    if (onGlobalInvitationReceived != null) {
      try {
        print('🔐 [CHAT_MANAGER] 📢 Ejecutando callback legacy');
        onGlobalInvitationReceived!(invitation);
      } catch (e) {
        print('🔐 [CHAT_MANAGER] ❌ Error en callback legacy: $e');
      }
    }
  }

  /// NUEVO: Inicializar servicio global de invitaciones
  Future<void> initializeGlobalInvitationService(String userId) async {
    if (_globalInvitationService != null && _currentUserId == userId) {
      return;
    }

    // Limpiar servicio anterior si existe
    if (_globalInvitationService != null) {
      _globalInvitationService!.onInvitationReceived = null;
      _globalInvitationService!.dispose();
    }

    _currentUserId = userId;
    _globalInvitationService = EphemeralChatService();

    try {
      await _globalInvitationService!.initialize(userId: userId);

      // Configurar callback solo para invitaciones
      _globalInvitationService!.onInvitationReceived = (invitation) {
        onGlobalInvitationReceived?.call(invitation);
      };
    } catch (e) {}
  }

  /// Obtener todas las sesiones activas
  List<ChatSession> get activeSessions => _activeSessions.values.toList();

  /// Obtener sesión por ID
  ChatSession? getSession(String sessionId) => _activeSessions[sessionId];

  /// Obtener sesión activa actual
  ChatSession? get currentActiveSession {
    if (_currentActiveSessionId == null) return null;
    return _activeSessions[_currentActiveSessionId];
  }

  /// Crear nueva sesión de chat con un usuario
  Future<ChatSession> createChatSession({
    required String targetUserId,
    String? targetUserName,
    required String currentUserId,
  }) async {
    // Verificar límite de sesiones
    if (_activeSessions.length >= MAX_CONCURRENT_SESSIONS) {
      throw Exception(
          'Máximo $MAX_CONCURRENT_SESSIONS salas simultáneas permitidas');
    }

    // CORREGIDO: Verificar si ya existe una sesión ACTIVA y CONECTADA con este usuario
    ChatSession? existingActiveSession;
    try {
      existingActiveSession = _activeSessions.values.firstWhere(
        (session) =>
            session.targetUserId == targetUserId &&
            session.currentRoom != null &&
            session.currentRoom!.id.isNotEmpty,
      );
    } catch (e) {
      // No existe sesión activa, continuamos creando una nueva
      existingActiveSession = null;
    }

    if (existingActiveSession != null) {
      // Forzar actualización de la UI
      _notifySessionsChanged();
      return existingActiveSession;
    }

    // NUEVO: Siempre crear nueva sesión si no hay una ACTIVA
    // Esto permite múltiples invitaciones pendientes al mismo usuario

    // Crear nuevo servicio de chat con aislamiento completo
    final chatService = EphemeralChatService();

    // Crear nueva sesión
    final session = ChatSession.create(
      targetUserId: targetUserId,
      targetUserName: targetUserName,
      chatService: chatService,
    );

    // Configurar callbacks para esta sesión específica
    _setupSessionCallbacks(session);

    // Agregar a sesiones activas
    _activeSessions[session.sessionId] = session;

    // NUEVO: Notificar cambios INMEDIATAMENTE para mostrar pestaña "conectando"
    _notifySessionsChanged();

    // Inicializar el servicio de chat
    try {
      await chatService.initialize(userId: currentUserId);
      await chatService.createChatInvitation(targetUserId);

      session.updateConnectionState(connecting: false);
    } catch (e) {
      session.updateConnectionState(
        connecting: false,
        errorMessage: 'Error creando invitación: $e',
      );
    }

    // Notificar cambios a la UI nuevamente después de la inicialización
    _notifySessionsChanged();

    return session;
  }

  /// Aceptar invitación y crear sesión
  Future<ChatSession> acceptInvitation({
    required String invitationId,
    required String targetUserId,
    String? targetUserName,
    required String currentUserId,
  }) async {
    // Verificar límite de sesiones
    if (_activeSessions.length >= MAX_CONCURRENT_SESSIONS) {
      throw Exception(
          'Máximo $MAX_CONCURRENT_SESSIONS salas simultáneas permitidas');
    }

    // Crear nuevo servicio de chat
    final chatService = EphemeralChatService();

    // Crear sesión desde invitación
    final session = ChatSession.fromInvitation(
      invitationId: invitationId,
      targetUserId: targetUserId,
      targetUserName: targetUserName,
      chatService: chatService,
    );

    // Configurar callbacks
    _setupSessionCallbacks(session);

    // Agregar a sesiones activas
    _activeSessions[session.sessionId] = session;

    // NUEVO: Notificar cambios INMEDIATAMENTE para mostrar pestaña "conectando"
    _notifySessionsChanged();

    // Inicializar y aceptar invitación
    try {
      await chatService.initialize(userId: currentUserId);
      await chatService.acceptInvitation(invitationId);

      session.updateConnectionState(connecting: false);
    } catch (e) {
      session.updateConnectionState(
        connecting: false,
        errorMessage: 'Error aceptando invitación: $e',
      );
    }

    // Notificar cambios nuevamente después de la aceptación
    _notifySessionsChanged();

    return session;
  }

  /// Configurar callbacks específicos para una sesión
  /// NUEVO: Reconfigurar callbacks del servicio global después de destrucción
  void _configureGlobalServiceCallbacks() {
    if (_globalInvitationService == null) {
      print('🔐 [CHAT-MANAGER] ❌ No hay servicio global para reconfigurar');
      return;
    }

    print('🔐 [CHAT-MANAGER] 🔧 Reconfigurando callback de invitaciones...');
    print(
        '🔐 [CHAT-MANAGER] 🔧 onGlobalInvitationReceived existe: ${onGlobalInvitationReceived != null}');

    // Reconfigurar callback de invitaciones
    _globalInvitationService!.onInvitationReceived = (invitation) {
      print(
          '🔐 [CHAT-MANAGER] 📨 Invitación recibida por servicio global: ${invitation.id}');

      // Pasar la invitación al callback global si existe
      if (onGlobalInvitationReceived != null) {
        print('🔐 [CHAT-MANAGER] 📨 Pasando invitación a callback global');
        onGlobalInvitationReceived!(invitation);
      } else {
        print('🔐 [CHAT-MANAGER] ⚠️ No hay callback global configurado');
      }
    };

    print(
        '🔐 [CHAT-MANAGER] ✅ Callback de invitaciones reconfigurado exitosamente');
    print(
        '🔐 [CHAT-MANAGER] ✅ Servicio global tiene callback: ${_globalInvitationService!.onInvitationReceived != null}');
  }

  void _setupSessionCallbacks(ChatSession session) {
    final sessionId = session.sessionId;

    session.chatService.onRoomCreated = (room) {
      // NUEVO: Actualizar displayName basado en participantes reales
      if (room.participants.length >= 2 && session.targetUserId == 'unknown') {
        // Si solo tenemos 2 participantes, el targetUserId debería ser actualizado
        // Nota: En este punto ya sabemos que hay una conexión exitosa
      }

      session.updateConnectionState(room: room);
      onSessionConnected?.call(sessionId);
      _notifySessionsChanged();
    };

    session.chatService.onMessageReceived = (message) {
      // Filtrar mensajes de verificación
      if (message.content.startsWith('VERIFICATION_CODES:')) {
        return;
      }

      session.addMessage(message);
      onMessageReceived?.call(sessionId, message);
      _notifySessionsChanged();
    };

    session.chatService.onError = (error) {
      session.updateConnectionState(errorMessage: error);
      onSessionError?.call(sessionId, error);
      _notifySessionsChanged();
    };

    // CRÍTICO: CONFIGURAR callback de invitaciones EN CADA SERVICIO
    // Esto es lo que faltaba - cada servicio necesita el callback configurado
    session.chatService.onInvitationReceived = (invitation) {
      print(
          '🔐 [CHAT-MANAGER] 📨 Invitación recibida por servicio de sesión: ${invitation.id}');

      // Reenviar al callback global si existe
      if (onGlobalInvitationReceived != null) {
        print('🔐 [CHAT-MANAGER] 🔄 Reenviando a callback global desde sesión');
        onGlobalInvitationReceived!(invitation);
      } else {
        print('🔐 [CHAT-MANAGER] ⚠️ No hay callback global configurado');
      }
    };

    session.chatService.onRoomDestroyed = () {
      print(
          '🔐 [CHAT-MANAGER] 💥 Sala destruida - session: ${session.sessionId}');
      print(
          '🔐 [CHAT-MANAGER] 💥 Servicio compartido: ${session.chatService == _globalInvitationService}');

      // CRÍTICO: Resetear INMEDIATAMENTE y de forma SÍNCRONA
      session.resetForReuse();

      // CRÍTICO: Notificar cambios INMEDIATAMENTE de forma síncrona
      _notifySessionsChanged();

      // NUEVO: Marcar la sesión como "recién reseteada" para evitar carga de mensajes obsoletos
      session.justReset = true;

      // CRÍTICO: RECONFIGURAR callback de invitaciones INMEDIATAMENTE
      // después de destruir la sala para mantener la funcionalidad
      print(
          '🔐 [CHAT-MANAGER] 🔧 Reconfigurando callback de invitaciones post-destrucción...');
      session.chatService.onInvitationReceived = (invitation) {
        print(
            '🔐 [CHAT-MANAGER] 📨 Post-destrucción: Invitación recibida por servicio de sesión: ${invitation.id}');

        // Reenviar al callback global si existe
        if (onGlobalInvitationReceived != null) {
          print(
              '🔐 [CHAT-MANAGER] 🔄 Post-destrucción: Reenviando a callback global');
          onGlobalInvitationReceived!(invitation);
        } else {
          print(
              '🔐 [CHAT-MANAGER] ⚠️ Post-destrucción: No hay callback global configurado');
        }
      };

      // CRÍTICO: SIEMPRE reconfigurar el servicio global después de destruir cualquier sesión
      if (_globalInvitationService != null) {
        print('🔐 [CHAT-MANAGER] 🔧 Reconfigurando servicio global FORZADO...');

        // Reconfigurar inmediatamente el servicio global
        _globalInvitationService!.onInvitationReceived = (invitation) {
          print(
              '🔐 [CHAT-MANAGER] 📨 Invitación recibida por servicio global reconfigurado: ${invitation.id}');

          if (onGlobalInvitationReceived != null) {
            print('🔐 [CHAT-MANAGER] 📨 Pasando a callback global');
            onGlobalInvitationReceived!(invitation);
          } else {
            print('🔐 [CHAT-MANAGER] ⚠️ No hay callback global configurado');
          }
        };

        print('🔐 [CHAT-MANAGER] ✅ Servicio global reconfigurado');
      } else {
        print('🔐 [CHAT-MANAGER] ⚠️ No hay servicio global para reconfigurar');
      }

      // NUEVA: Reconfiguración asíncrona adicional para asegurar consistencia
      Future.delayed(Duration(milliseconds: 100), () {
        print(
            '🔐 [CHAT-MANAGER] 🔧 Reconfigurando callbacks del servicio global (ASYNC)...');
        _configureGlobalServiceCallbacks();
      });
    };
  }

  /// Enviar mensaje en una sesión específica
  Future<void> sendMessage(String sessionId, String content) async {
    final session = _activeSessions[sessionId];
    if (session == null) {
      throw Exception('Sesión no encontrada: $sessionId');
    }

    if (session.currentRoom == null) {
      throw Exception('No hay sala activa en la sesión');
    }

    try {
      await session.chatService.sendMessage(content);

      // Agregar mensaje propio a la sesión
      final myMessage = EphemeralMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        roomId: session.currentRoom!.id,
        senderId: 'me',
        content: content,
        timestamp: DateTime.now(),
        destructionTimeMinutes: session.selectedDestructionMinutes,
        destructionTime: session.selectedDestructionMinutes != null
            ? DateTime.now()
                .add(Duration(minutes: session.selectedDestructionMinutes!))
            : null,
      );

      session.addMessage(myMessage);
      _notifySessionsChanged();
    } catch (e) {
      rethrow;
    }
  }

  /// Establecer sesión activa (usuario está viendo esta pestaña)
  void setActiveSession(String? sessionId) {
    // Desactivar sesión anterior
    if (_currentActiveSessionId != null) {
      _activeSessions[_currentActiveSessionId]?.setActive(false);
    }

    // Activar nueva sesión
    _currentActiveSessionId = sessionId;
    if (sessionId != null) {
      _activeSessions[sessionId]?.setActive(true);
    }

    _notifySessionsChanged();
  }

  /// Cerrar una sesión específica
  void closeSession(String sessionId) {
    final session = _activeSessions[sessionId];
    if (session == null) return;

    // Limpiar callbacks
    session.chatService.onRoomCreated = null;
    session.chatService.onMessageReceived = null;
    session.chatService.onError = null;
    session.chatService.onRoomDestroyed = null;

    // Liberar recursos
    session.dispose();

    // Remover de sesiones activas
    _activeSessions.remove(sessionId);

    // Si era la sesión activa, limpiar referencia
    if (_currentActiveSessionId == sessionId) {
      _currentActiveSessionId = null;
    }

    _notifySessionsChanged();
  }

  /// Cerrar todas las sesiones
  void closeAllSessions() {
    final sessionIds = _activeSessions.keys.toList();
    for (final sessionId in sessionIds) {
      closeSession(sessionId);
    }

    _currentActiveSessionId = null;
  }

  /// Iniciar timer para limpiar mensajes destruidos
  void _startDestructionTimer() {
    _destructionTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      for (final session in _activeSessions.values) {
        session.cleanDestroyedMessages();
      }
    });
  }

  /// Notificar cambios en las sesiones a la UI
  void _notifySessionsChanged() {
    onSessionsChanged?.call(activeSessions);
  }

  /// Obtener estadísticas del manager
  Map<String, dynamic> getStats() {
    return {
      'totalSessions': _activeSessions.length,
      'maxSessions': MAX_CONCURRENT_SESSIONS,
      'activeSessionId': _currentActiveSessionId,
      'totalMessages': _activeSessions.values
          .map((s) => s.messages.length)
          .fold(0, (a, b) => a + b),
      'totalUnreadMessages': _activeSessions.values
          .map((s) => s.unreadCount)
          .fold(0, (a, b) => a + b),
    };
  }

  /// NUEVO: Limpiar callbacks temporales (NO destruir singleton)
  void clearCallbacks() {
    // ADVERTENCIA: Esto puede afectar las notificaciones de MainScreen
    if (onMessageReceived != null) {}

    // Solo limpiar callbacks de UI, mantener sesiones activas
    onSessionsChanged = null;
    onMessageReceived = null;
    onSessionError = null;
    onSessionConnected = null;
    onGlobalInvitationReceived = null;
  }

  /// Liberar todos los recursos (SOLO para cierre completo de app)
  void dispose() {
    // En lugar de destruir todo, solo limpiar callbacks
    clearCallbacks();

    // NO destruir sesiones ni servicio global para mantener estado
  }

  /// NUEVO: Destruir completamente (solo para cierre de app)
  void destroyCompletely() {
    _destructionTimer?.cancel();
    closeAllSessions();

    // Limpiar servicio global de invitaciones
    if (_globalInvitationService != null) {
      _globalInvitationService!.onInvitationReceived = null;
      _globalInvitationService!.dispose();
      _globalInvitationService = null;
    }

    clearCallbacks();

    // Resetear singleton
    _instance = null;
  }
}
