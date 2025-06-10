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
    print('🏢 [CHAT-MANAGER] 🌟 SINGLETON ROBUSTO INICIALIZADO');
  }

  // Getter estático para obtener la instancia única
  static EphemeralChatManager get instance {
    if (_instance == null) {
      print('🏢 [CHAT-MANAGER] 🆕 Creando nueva instancia singleton');
      _instance = EphemeralChatManager._internal();
    } else {
      print('🏢 [CHAT-MANAGER] ♻️ Reutilizando instancia singleton existente');
    }
    return _instance!;
  }

  // DEPRECATED: Constructor factory (redirige al singleton)
  factory EphemeralChatManager() {
    print(
        '🏢 [CHAT-MANAGER] ⚠️ Factory constructor llamado - redirigiendo a singleton');
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

  /// NUEVO: Verificar si el servicio global está inicializado
  bool get hasGlobalInvitationService => _globalInvitationService != null;

  /// NUEVO: Inicializar servicio global de invitaciones
  Future<void> initializeGlobalInvitationService(String userId) async {
    if (_globalInvitationService != null && _currentUserId == userId) {
      print(
          '🏢 [CHAT-MANAGER] ✅ Servicio global ya inicializado para usuario: $userId');
      return;
    }

    print(
        '🏢 [CHAT-MANAGER] 🌐 Inicializando servicio global para usuario: $userId');

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
        print(
            '🏢 [CHAT-MANAGER] 📨 Invitación global recibida: ${invitation.id}');
        onGlobalInvitationReceived?.call(invitation);
      };

      print('🏢 [CHAT-MANAGER] ✅ Servicio global de invitaciones activo');
    } catch (e) {
      print('🏢 [CHAT-MANAGER] ❌ Error inicializando servicio global: $e');
    }
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
    print('🏢 [CHAT-MANAGER] Creando nueva sesión con $targetUserId');

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
      print(
          '🏢 [CHAT-MANAGER] ✅ Sesión activa existente encontrada: ${existingActiveSession.sessionId}');
      print('🏢 [CHAT-MANAGER] ✅ Reutilizando sesión con sala activa');

      // Forzar actualización de la UI
      _notifySessionsChanged();
      return existingActiveSession;
    }

    // NUEVO: Siempre crear nueva sesión si no hay una ACTIVA
    // Esto permite múltiples invitaciones pendientes al mismo usuario
    print(
        '🏢 [CHAT-MANAGER] 🆕 Creando nueva sesión (no hay sesión activa con sala)');

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

    print('🏢 [CHAT-MANAGER] ✅ Nueva sesión creada: ${session.sessionId}');
    print(
        '🏢 [CHAT-MANAGER] 📊 Total sesiones activas: ${_activeSessions.length}');

    // NUEVO: Notificar cambios INMEDIATAMENTE para mostrar pestaña "conectando"
    _notifySessionsChanged();
    print(
        '🏢 [CHAT-MANAGER] 📢 UI notificada - nueva pestaña debería aparecer');

    // Inicializar el servicio de chat
    try {
      await chatService.initialize(userId: currentUserId);
      await chatService.createChatInvitation(targetUserId);

      session.updateConnectionState(connecting: false);
      print(
          '🏢 [CHAT-MANAGER] ✅ Sesión ${session.sessionId} inicializada correctamente');
    } catch (e) {
      session.updateConnectionState(
        connecting: false,
        errorMessage: 'Error creando invitación: $e',
      );
      print(
          '🏢 [CHAT-MANAGER] ❌ Error inicializando sesión ${session.sessionId}: $e');
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
    print('🏢 [CHAT-MANAGER] Aceptando invitación: $invitationId');

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

    print(
        '🏢 [CHAT-MANAGER] ✅ Sesión de invitación creada: ${session.sessionId}');

    // NUEVO: Notificar cambios INMEDIATAMENTE para mostrar pestaña "conectando"
    _notifySessionsChanged();
    print(
        '🏢 [CHAT-MANAGER] 📢 UI notificada - nueva pestaña de invitación debería aparecer');

    // Inicializar y aceptar invitación
    try {
      await chatService.initialize(userId: currentUserId);
      await chatService.acceptInvitation(invitationId);

      session.updateConnectionState(connecting: false);
      print(
          '🏢 [CHAT-MANAGER] ✅ Invitación aceptada para sesión ${session.sessionId}');
    } catch (e) {
      session.updateConnectionState(
        connecting: false,
        errorMessage: 'Error aceptando invitación: $e',
      );
      print(
          '🏢 [CHAT-MANAGER] ❌ Error aceptando invitación ${session.sessionId}: $e');
    }

    // Notificar cambios nuevamente después de la aceptación
    _notifySessionsChanged();

    return session;
  }

  /// Configurar callbacks específicos para una sesión
  void _setupSessionCallbacks(ChatSession session) {
    final sessionId = session.sessionId;
    print('🏢 [CHAT-MANAGER] Configurando callbacks para sesión: $sessionId');

    session.chatService.onRoomCreated = (room) {
      print(
          '🏢 [CHAT-MANAGER] 🏠 Sala creada para sesión $sessionId: ${room.id}');

      // NUEVO: Actualizar displayName basado en participantes reales
      if (room.participants.length >= 2 && session.targetUserId == 'unknown') {
        print(
            '🏢 [CHAT-MANAGER] 🆔 Detectado targetUserId "unknown", sala con ${room.participants.length} participantes');
        print(
            '🏢 [CHAT-MANAGER] 🆔 Participantes: ${room.participants.join(", ")}');

        // Si solo tenemos 2 participantes, el targetUserId debería ser actualizado
        // Nota: En este punto ya sabemos que hay una conexión exitosa
        print(
            '🏢 [CHAT-MANAGER] ✅ Sala conectada - displayName se basará en participantes reales');
      }

      session.updateConnectionState(room: room);
      onSessionConnected?.call(sessionId);
      _notifySessionsChanged();
    };

    session.chatService.onMessageReceived = (message) {
      print('🏢 [CHAT-MANAGER] 💬 Mensaje recibido en sesión $sessionId');

      // Filtrar mensajes de verificación
      if (message.content.startsWith('VERIFICATION_CODES:')) {
        return;
      }

      session.addMessage(message);
      onMessageReceived?.call(sessionId, message);
      _notifySessionsChanged();
    };

    session.chatService.onError = (error) {
      print('🏢 [CHAT-MANAGER] ❌ Error en sesión $sessionId: $error');
      session.updateConnectionState(errorMessage: error);
      onSessionError?.call(sessionId, error);
      _notifySessionsChanged();
    };

    session.chatService.onRoomDestroyed = () {
      print('🏢 [CHAT-MANAGER] 🗑️ Sala destruida para sesión $sessionId');

      // CRÍTICO: Resetear INMEDIATAMENTE y de forma SÍNCRONA
      session.resetForReuse();

      print('🏢 [CHAT-MANAGER] ✅ Sesión completamente reiniciada: $sessionId');
      print(
          '🏢 [CHAT-MANAGER] - Disponible para nueva conexión: ${session.isAvailableForNewConnection}');
      print(
          '🏢 [CHAT-MANAGER] - Mensajes después del reset: ${session.messages.length}');

      // CRÍTICO: Notificar cambios INMEDIATAMENTE de forma síncrona
      _notifySessionsChanged();

      // NUEVO: Marcar la sesión como "recién reseteada" para evitar carga de mensajes obsoletos
      session.justReset = true;

      print(
          '🏢 [CHAT-MANAGER] ✅ Sesión marcada como recién reseteada: $sessionId');

      // NUEVO: Notificaciones más lentas para mejor sincronización
      Future.delayed(const Duration(milliseconds: 200), () {
        _notifySessionsChanged();
        print('🏢 [CHAT-MANAGER] 🔄 Actualización 1 enviada (200ms)');
      });

      Future.delayed(const Duration(milliseconds: 500), () {
        session.justReset = false; // Quitar marca después de más tiempo
        _notifySessionsChanged();
        print('🏢 [CHAT-MANAGER] 🔄 Actualización 2 enviada (500ms)');
      });

      Future.delayed(const Duration(milliseconds: 1000), () {
        _notifySessionsChanged();
        print('🏢 [CHAT-MANAGER] 🔄 Actualización final enviada (1000ms)');
      });

      print(
          '🏢 [CHAT-MANAGER] ✅ Reset completo y notificaciones enviadas: $sessionId');
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

      print('🏢 [CHAT-MANAGER] ✅ Mensaje enviado en sesión $sessionId');
    } catch (e) {
      print(
          '🏢 [CHAT-MANAGER] ❌ Error enviando mensaje en sesión $sessionId: $e');
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

    print('🏢 [CHAT-MANAGER] 👁️ Sesión activa cambiada a: $sessionId');
    _notifySessionsChanged();
  }

  /// Cerrar una sesión específica
  void closeSession(String sessionId) {
    final session = _activeSessions[sessionId];
    if (session == null) return;

    print('🏢 [CHAT-MANAGER] 🗑️ Cerrando sesión: $sessionId');

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

    print('🏢 [CHAT-MANAGER] ✅ Sesión cerrada: $sessionId');
    print('🏢 [CHAT-MANAGER] 📊 Sesiones restantes: ${_activeSessions.length}');

    _notifySessionsChanged();
  }

  /// Cerrar todas las sesiones
  void closeAllSessions() {
    print('🏢 [CHAT-MANAGER] 🗑️ Cerrando todas las sesiones...');

    final sessionIds = _activeSessions.keys.toList();
    for (final sessionId in sessionIds) {
      closeSession(sessionId);
    }

    _currentActiveSessionId = null;
    print('🏢 [CHAT-MANAGER] ✅ Todas las sesiones cerradas');
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
    print('🏢 [CHAT-MANAGER] 🧹 Limpiando callbacks temporales...');

    // ADVERTENCIA: Esto puede afectar las notificaciones de MainScreen
    if (onMessageReceived != null) {
      print(
          '🏢 [CHAT-MANAGER] ⚠️ ADVERTENCIA: Limpiando callback onMessageReceived - esto puede afectar notificaciones');
    }

    // Solo limpiar callbacks de UI, mantener sesiones activas
    onSessionsChanged = null;
    onMessageReceived = null;
    onSessionError = null;
    onSessionConnected = null;
    onGlobalInvitationReceived = null;

    print(
        '🏢 [CHAT-MANAGER] ✅ Callbacks temporales limpiados - singleton preservado');
    print(
        '🏢 [CHAT-MANAGER] ℹ️ MainScreen debería reconfigurar callbacks en didChangeDependencies()');
  }

  /// Liberar todos los recursos (SOLO para cierre completo de app)
  void dispose() {
    print(
        '🏢 [CHAT-MANAGER] ⚠️ DISPOSE LLAMADO - Esto NO debería pasar en navegación normal');
    print('🏢 [CHAT-MANAGER] 🔄 Usando clearCallbacks() en su lugar...');

    // En lugar de destruir todo, solo limpiar callbacks
    clearCallbacks();

    // NO destruir sesiones ni servicio global para mantener estado
    print('🏢 [CHAT-MANAGER] ✅ Singleton preservado para navegación');
  }

  /// NUEVO: Destruir completamente (solo para cierre de app)
  void destroyCompletely() {
    print('🏢 [CHAT-MANAGER] 💥 DESTRUCCIÓN COMPLETA DEL SINGLETON');

    _destructionTimer?.cancel();
    closeAllSessions();

    // Limpiar servicio global de invitaciones
    if (_globalInvitationService != null) {
      print(
          '🏢 [CHAT-MANAGER] 🌐 Limpiando servicio global de invitaciones...');
      _globalInvitationService!.onInvitationReceived = null;
      _globalInvitationService!.dispose();
      _globalInvitationService = null;
    }

    clearCallbacks();

    // Resetear singleton
    _instance = null;

    print('🏢 [CHAT-MANAGER] ✅ Singleton completamente destruido');
  }
}
