import 'ephemeral_message.dart';
import 'ephemeral_room.dart';
import '../services/ephemeral_chat_service.dart';

/// Modelo que representa una sesión de chat individual
/// Cada sesión mantiene su propio estado, mensajes y conexión
class ChatSession {
  final String sessionId;
  final String targetUserId;
  final String? targetUserName;
  final EphemeralChatService chatService;
  final List<EphemeralMessage> messages;

  EphemeralRoom? currentRoom;
  bool isConnecting;
  String? error;
  int unreadCount;
  DateTime lastActivity;
  bool isActive;

  // Estado de autodestrucción
  int? selectedDestructionMinutes;

  // NUEVO: Flag para evitar carga de mensajes obsoletos después de reset
  bool justReset = false;

  ChatSession({
    required this.sessionId,
    required this.targetUserId,
    this.targetUserName,
    required this.chatService,
    List<EphemeralMessage>? messages,
    this.currentRoom,
    this.isConnecting = true,
    this.error,
    this.unreadCount = 0,
    DateTime? lastActivity,
    this.isActive = false,
    this.selectedDestructionMinutes,
  })  : messages = messages ?? [],
        lastActivity = lastActivity ?? DateTime.now();

  /// Crear una nueva sesión con un usuario objetivo
  factory ChatSession.create({
    required String targetUserId,
    String? targetUserName,
    required EphemeralChatService chatService,
  }) {
    // CORREGIDO: Verificar longitud antes de hacer substring
    final userIdSuffix =
        targetUserId.length >= 8 ? targetUserId.substring(0, 8) : targetUserId;

    final sessionId =
        'session_${DateTime.now().millisecondsSinceEpoch}_$userIdSuffix';

    return ChatSession(
      sessionId: sessionId,
      targetUserId: targetUserId,
      targetUserName: targetUserName,
      chatService: chatService,
      isConnecting: true,
      lastActivity: DateTime.now(),
    );
  }

  /// Crear sesión desde una invitación
  factory ChatSession.fromInvitation({
    required String invitationId,
    required String targetUserId,
    String? targetUserName,
    required EphemeralChatService chatService,
  }) {
    // CORREGIDO: Verificar longitud antes de hacer substring
    final invitationSuffix =
        invitationId.length >= 8 ? invitationId.substring(0, 8) : invitationId;

    final sessionId =
        'session_inv_${DateTime.now().millisecondsSinceEpoch}_$invitationSuffix';

    return ChatSession(
      sessionId: sessionId,
      targetUserId: targetUserId,
      targetUserName: targetUserName,
      chatService: chatService,
      isConnecting: true,
      lastActivity: DateTime.now(),
    );
  }

  /// Agregar mensaje a la sesión
  void addMessage(EphemeralMessage message) {
    messages.add(message);
    lastActivity = DateTime.now();

    // Incrementar contador de no leídos si no está activa
    if (!isActive && !message.isFromMe) {
      unreadCount++;
    }
  }

  /// Marcar como leída (resetear contador)
  void markAsRead() {
    unreadCount = 0;
  }

  /// Activar sesión (usuario está viendo esta pestaña)
  void setActive(bool active) {
    isActive = active;
    if (active) {
      markAsRead();
    }
  }

  /// Actualizar estado de conexión
  void updateConnectionState({
    bool? connecting,
    String? errorMessage,
    EphemeralRoom? room,
  }) {
    if (connecting != null) isConnecting = connecting;
    if (errorMessage != null) error = errorMessage;
    if (room != null) {
      currentRoom = room;
      isConnecting = false;
      error = null;
    }
    lastActivity = DateTime.now();
  }

  /// NUEVO: Reiniciar sesión para reuso después de destrucción
  void resetForReuse() {
    currentRoom = null;
    isConnecting = false;
    error = null;
    messages.clear();
    unreadCount = 0;
    isActive = false;
    justReset = true;
    lastActivity = DateTime.now();

    print('📱 [CHAT-SESSION] ✅ Sesión reiniciada para reuso: $sessionId');
    print('📱 [CHAT-SESSION] - Estado: $connectionStatus');
    print('📱 [CHAT-SESSION] - Mensajes: ${messages.length}');
    print('📱 [CHAT-SESSION] - JustReset: $justReset');
    print(
        '📱 [CHAT-SESSION] - Disponible para conexión: $isAvailableForNewConnection');

    // NUEVO: El servicio debe mantenerse conectado para reutilización
    print('📱 [CHAT-SESSION] - Servicio conectado: ${chatService.isConnected}');
  }

  /// NUEVO: Verificar si la sesión está disponible para nueva conexión
  bool get isAvailableForNewConnection {
    return currentRoom == null && !isConnecting && error == null;
  }

  /// Limpiar mensajes destruidos
  void cleanDestroyedMessages() {
    messages.removeWhere((message) => message.shouldBeDestroyed);
  }

  /// Obtener último mensaje
  EphemeralMessage? get lastMessage {
    return messages.isNotEmpty ? messages.last : null;
  }

  /// Obtener nombre para mostrar en la pestaña
  String get displayName {
    if (targetUserName != null && targetUserName!.isNotEmpty) {
      return targetUserName!;
    }

    // CORREGIDO: Manejo inteligente de IDs desconocidos
    if (targetUserId == 'unknown') {
      // Si tenemos una sala con participantes, usar esa información
      if (currentRoom != null && currentRoom!.participants.length >= 2) {
        return 'Chat (${currentRoom!.participants.length} usuarios)';
      }
      // Si estamos conectando, mostrar estado útil
      if (isConnecting) {
        return 'Conectando...';
      }
      // Por defecto, mostrar algo útil
      return 'Usuario invitado';
    }

    // Verificar longitud antes de hacer substring
    if (targetUserId.length >= 8) {
      return 'Usuario ${targetUserId.substring(0, 8)}';
    } else {
      return 'Usuario $targetUserId';
    }
  }

  /// Estado de la conexión para mostrar en UI
  String get connectionStatus {
    if (error != null) return 'Error';
    if (isConnecting) return 'Conectando...';
    if (currentRoom != null) return 'Conectado';
    return 'Desconectado';
  }

  /// Color del indicador de estado
  String get statusColor {
    if (error != null) return 'red';
    if (isConnecting) return 'yellow';
    if (currentRoom != null) return 'green';
    return 'grey';
  }

  /// Liberar recursos de la sesión
  void dispose() {
    chatService.dispose();
    messages.clear();
  }

  @override
  String toString() {
    return 'ChatSession(id: $sessionId, target: $targetUserId, messages: ${messages.length}, unread: $unreadCount)';
  }
}
