import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/ephemeral_chat_service.dart';
import '../models/ephemeral_message.dart';
import '../models/ephemeral_room.dart';
import '../widgets/destruction_timer_widget.dart';
import '../widgets/destruction_countdown_widget.dart';
import 'dart:async';
import '../services/ephemeral_chat_manager.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/web_utils.dart';

// NUEVO: Helper para obtener información de navegación multiplataforma
String _getCurrentNavigationInfo(BuildContext? context) {
  try {
    if (kIsWeb) {
      // En web: usar WebUtils que maneja dart:html de forma segura
      return WebUtils.getCurrentUrl();
    } else {
      // En iOS/Android: usar información de rutas de Flutter
      if (context != null) {
        final route = ModalRoute.of(context);
        final routeName = route?.settings.name ?? 'unknown-route';
        final arguments = route?.settings.arguments;

        String platformInfo = 'flutter://';
        platformInfo += routeName;

        if (arguments != null) {
          platformInfo += '?args=${arguments.toString()}';
        }

        return platformInfo;
      }
      return 'flutter://ephemeral-chat-screen';
    }
  } catch (e) {
    // Fallback universal
    return kIsWeb ? 'web://error' : 'flutter://error';
  }
}

class EphemeralChatScreen extends StatefulWidget {
  final String? targetUserId;
  final String? invitationId;
  final EphemeralChatService? ephemeralChatService;
  final bool isFromMultiRoom;

  const EphemeralChatScreen({
    super.key,
    this.targetUserId,
    this.invitationId,
    this.ephemeralChatService,
    this.isFromMultiRoom = false,
  });

  @override
  State<EphemeralChatScreen> createState() => _EphemeralChatScreenState();
}

class _EphemeralChatScreenState extends State<EphemeralChatScreen> {
  late EphemeralChatService _chatService;
  final TextEditingController _messageController = TextEditingController();
  List<EphemeralMessage> _messages = [];
  EphemeralRoom? _currentRoom;
  bool _isConnecting = true;
  String? _error;
  int? _selectedDestructionMinutes;
  Timer? _destructionTimer;

  // NUEVO: Variables para destrucción manual
  bool _showDestructionCountdown = false;
  EphemeralMessage? _currentDestructionMessage;

  // NUEVO: Variable para trackear configuración de autodestrucción
  int? _currentAutoDestructionMinutes;
  String? _autoDestructionConfiguredBy;

  // NUEVO: Variable para detectar contexto automáticamente
  bool _isFromMultiRoomDetected = false;

  @override
  void initState() {
    super.initState();
    print('🔐 [CHAT-SCREEN] Inicializando EphemeralChatScreen');
    print('🔐 [CHAT-SCREEN] isFromMultiRoom: ${widget.isFromMultiRoom}');
    print('🔐 [CHAT-SCREEN] targetUserId: ${widget.targetUserId}');
    print('🔐 [CHAT-SCREEN] invitationId: ${widget.invitationId}');

    // NUEVO: Si viene de multi-room, cargar mensajes existentes del servicio
    if (widget.isFromMultiRoom && widget.ephemeralChatService != null) {
      print(
          '🔐 [CHAT-SCREEN] 📥 Cargando mensajes existentes del ChatSession...');
      _loadExistingMessagesFromSession();
    }

    if (widget.ephemeralChatService != null) {
      print('🔐 [CHAT-SCREEN] Usando servicio existente');
      _chatService = widget.ephemeralChatService!;

      // NUEVO: Configurar callbacks inmediatamente
      _setupCallbacks();

      if (widget.targetUserId != null) {
        print('🔐 [CHAT-SCREEN] Enviando invitación con servicio existente');
        _createInvitationWithExistingService();
      } else if (widget.invitationId != null) {
        print('🔐 [CHAT-SCREEN] Aceptando invitación: ${widget.invitationId}');
        _acceptInvitationWithExistingService();
      } else {
        print('🔐 [CHAT-SCREEN] Sin parámetros - asumiendo sala ya activa');

        // NUEVO: Si hay una sala activa, cargar su estado
        if (_chatService.currentRoomId != null) {
          _loadExistingRoomState();
        }

        if (mounted) {
          setState(() {
            _isConnecting = false;
          });
        }
      }
    } else {
      print('🔐 [CHAT-SCREEN] Creando nuevo servicio');
      _chatService = EphemeralChatService();
      _initializeChatService();
    }
  }

  /// NUEVO: Cargar mensajes existentes del ChatSession para evitar perderlos
  void _loadExistingMessagesFromSession() {
    if (widget.isFromMultiRoom) {
      try {
        // Buscar el ChatSession correspondiente en el manager
        final chatManager = EphemeralChatManager.instance;
        final sessions = chatManager.activeSessions;

        // Encontrar la sesión que corresponde a este servicio
        final session = sessions.firstWhere(
          (s) => s.chatService == widget.ephemeralChatService,
          orElse: () => throw Exception('Sesión no encontrada'),
        );

        // CORREGIDO: Solo limpiar mensajes si la sesión fue destruida completamente
        // NO borrar mensajes solo porque currentRoom es null o justReset es true
        if (session.justReset) {
          print(
              '🔐 [CHAT-SCREEN] ⚠️ Sesión recién reseteada - Limpiando mensajes obsoletos');
          setState(() {
            _messages = []; // Solo limpiar si fue un reset real
          });
          return;
        }

        // CORREGIDO: Siempre cargar mensajes existentes de la sesión
        // Los mensajes deben persistir aunque currentRoom sea null temporalmente
        setState(() {
          _messages = List<EphemeralMessage>.from(session.messages);
        });

        print(
            '🔐 [CHAT-SCREEN] ✅ Cargados ${_messages.length} mensajes de sesión');
        print(
            '🔐 [CHAT-SCREEN] ✅ Sala activa: ${session.currentRoom?.id ?? "ninguna"}');

        // Imprimir mensajes para debug solo si hay mensajes
        if (_messages.isNotEmpty) {
          for (int i = 0; i < _messages.length; i++) {
            print(
                '🔐 [CHAT-SCREEN] - Mensaje $i: "${_messages[i].content}" (${_messages[i].senderId})');
          }
        }

        // También cargar estado de la sala si existe
        if (session.currentRoom != null) {
          _currentRoom = session.currentRoom;
          print(
              '🔐 [CHAT-SCREEN] ✅ Estado de sala cargado: ${_currentRoom!.id}');
        }
      } catch (e) {
        print(
            '🔐 [CHAT-SCREEN] ⚠️ No se pudieron cargar mensajes existentes: $e');
        // En caso de error, mantener mensajes existentes si los hay
        print(
            '🔐 [CHAT-SCREEN] ✅ Manteniendo ${_messages.length} mensajes existentes');
      }
    }
  }

  /// NUEVO: Cargar estado de sala existente
  void _loadExistingRoomState() {
    if (_chatService.currentRoomId != null) {
      print(
          '🔐 [CHAT-SCREEN] 🏠 Cargando estado de sala existente: ${_chatService.currentRoomId}');

      final now = DateTime.now();
      _currentRoom = EphemeralRoom(
        id: _chatService.currentRoomId!,
        participants: List.generate(
            _chatService.participantCount, (index) => 'participant_$index'),
        encryptionKey: '',
        createdAt: now,
        lastActivity: now,
      );

      print(
          '🔐 [CHAT-SCREEN] ✅ Estado de sala cargado con ${_chatService.participantCount} participantes');

      // NUEVO: Iniciar timer de destrucción para sala existente
      _startDestructionTimer();
      print(
          '🔐 [CHAT-SCREEN] ⏰ Timer de destrucción iniciado para sala existente');
    }
  }

  Future<void> _createInvitationWithExistingService() async {
    try {
      await _chatService.createChatInvitation(widget.targetUserId!);
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isConnecting = false;
          _error = 'Error creando invitación: $e';
        });
      }
    }
  }

  Future<void> _acceptInvitationWithExistingService() async {
    try {
      await _chatService.acceptInvitation(widget.invitationId!);
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isConnecting = false;
          _error = 'Error aceptando invitación: $e';
        });
      }
    }
  }

  Future<void> _initializeChatService() async {
    try {
      if (mounted) {
        setState(() {
          _isConnecting = true;
          _error = null;
        });
      }

      // Obtener userId del AuthProvider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.id;

      await _chatService.initialize(userId: userId);
      _setupCallbacks();

      // Si tenemos una invitación, aceptarla automáticamente
      if (widget.invitationId != null) {
        await _chatService.acceptInvitation(widget.invitationId!);
      }
      // Si tenemos un usuario objetivo, crear invitación
      else if (widget.targetUserId != null) {
        await _chatService.createChatInvitation(widget.targetUserId!);
      }

      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isConnecting = false;
          _error = 'Error conectando: $e';
        });
      }
    }
  }

  void _setupCallbacks() {
    print('🔐 [CHAT-SCREEN] === CONFIGURANDO CALLBACKS ===');
    print('🔐 [CHAT-SCREEN] Sala actual antes de callbacks: $_currentRoom');
    print(
        '🔐 [CHAT-SCREEN] RoomId del servicio: ${_chatService.currentRoomId}');

    // Si ya hay una sala activa pero no tenemos _currentRoom, crearla
    if (_chatService.currentRoomId != null && _currentRoom == null) {
      print('🔐 [CHAT-SCREEN] 🔧 Creando _currentRoom para sala existente');
      final now = DateTime.now();

      // NUEVO: Crear lista de participantes falsos basada en el contador del servicio
      final fakeParticipants = List.generate(
          _chatService.participantCount, (index) => 'participant_$index');

      _currentRoom = EphemeralRoom(
        id: _chatService.currentRoomId!,
        participants: fakeParticipants, // Usar lista con el número correcto
        encryptionKey: '', // Ya está configurada en el servicio
        createdAt: now,
        lastActivity: now,
      );
      _isConnecting = false;
      print(
          '🔐 [CHAT-SCREEN] ✅ _currentRoom creada con ${_chatService.participantCount} participantes');

      // Actualizar estado para mostrar el teclado
      if (mounted) {
        setState(() {
          // _currentRoom y _isConnecting ya están establecidos arriba
        });
        print('🔐 [CHAT-SCREEN] ✅ Estado actualizado para mostrar teclado');
      }
    }

    // CORREGIDO: Verificar si ya hay callbacks configurados para evitar sobrescribir
    if (_chatService.onMessageReceived == null) {
      print(
          '🔐 [CHAT-SCREEN] 🆕 Configurando callback onMessageReceived por primera vez');
    } else {
      print(
          '🔐 [CHAT-SCREEN] ⚠️ Callback onMessageReceived ya existe - sobrescribiendo');
    }

    _chatService.onRoomCreated = (room) {
      print(
          '🔐 [CHAT-SCREEN] ¡¡¡CALLBACK onRoomCreated EJECUTADO EN CHAT SCREEN!!!');
      print('🔐 [CHAT-SCREEN] Room ID: ${room.id}');
      print('🔐 [CHAT-SCREEN] Participantes: ${room.participants.length}');
      print('🔐 [CHAT-SCREEN] Mounted: $mounted');

      if (mounted) {
        setState(() {
          _currentRoom = room;
          _isConnecting = false;
        });
        print('🔐 [CHAT-SCREEN] ✅ Estado actualizado - sala establecida');

        // NUEVO: Iniciar timer de destrucción de mensajes
        _startDestructionTimer();
        print('🔐 [CHAT-SCREEN] ⏰ Timer de destrucción de mensajes iniciado');

        // NUEVO: Pequeño delay para asegurar que el cifrado esté completamente listo
        Future.delayed(const Duration(milliseconds: 500), () {
          print(
              '🔐 [CHAT-SCREEN] 🔐 Cifrado completamente inicializado - listo para mensajes');
        });
      }
    };

    _chatService.onMessageReceived = (message) {
      print('🔐 [CHAT-SCREEN] ¡¡¡CALLBACK onMessageReceived EJECUTADO!!!');
      print('🔐 [CHAT-SCREEN] Mensaje: ${message.content}');
      print('🔐 [CHAT-SCREEN] Tipo: ${message.type}');
      print('🔐 [CHAT-SCREEN] SenderId: ${message.senderId}');
      print('🔐 [CHAT-SCREEN] RoomId: ${message.roomId}');
      print('🔐 [CHAT-SCREEN] Mounted: $mounted');
      print('🔐 [CHAT-SCREEN] Lista actual de mensajes: ${_messages.length}');

      // CORREGIDO: Verificar que el mensaje es para la sala correcta
      if (_currentRoom != null && message.roomId != _currentRoom!.id) {
        print('🔐 [CHAT-SCREEN] ⚠️ Mensaje para sala diferente - ignorando');
        print(
            '🔐 [CHAT-SCREEN] Esperado: ${_currentRoom!.id}, Recibido: ${message.roomId}');
        return;
      }

      // Filtrar mensajes de verificación para que no aparezcan en el chat
      if (message.content.startsWith('VERIFICATION_CODES:')) {
        print(
            '🔐 [CHAT-SCREEN] Mensaje de verificación filtrado, no se muestra en chat');
        return; // No agregar a la lista de mensajes
      }

      // NUEVO: Procesar eventos de limpieza enviados desde el servidor
      if (message.content.startsWith('CLEANUP_MESSAGES:')) {
        print('🔐 [CHAT-SCREEN] 🧹 Evento de limpieza recibido desde servidor');
        try {
          final parts = message.content.split(':');
          if (parts.length >= 2) {
            final destructionMinutes = int.parse(parts[1]);
            print(
                '🔐 [CHAT-SCREEN] Limpiando mensajes con $destructionMinutes minutos de antigüedad');

            // Filtrar mensajes que deben ser eliminados
            final cutoffTime =
                DateTime.now().subtract(Duration(minutes: destructionMinutes));
            final messagesToKeep = _messages
                .where((msg) =>
                    msg.timestamp.isAfter(cutoffTime) &&
                    !msg.content.startsWith('CLEANUP_MESSAGES:'))
                .toList();

            if (messagesToKeep.length != _messages.length) {
              setState(() {
                _messages.clear();
                _messages.addAll(messagesToKeep);
              });
              print(
                  '🔐 [CHAT-SCREEN] ✅ Mensajes limpiados: ${_messages.length} restantes');
            }
          }
        } catch (e) {
          print('🔐 [CHAT-SCREEN] ❌ Error procesando limpieza: $e');
        }
        return; // No mostrar el mensaje de limpieza en el chat
      }

      // NUEVO: Procesar mensajes de configuración de autodestrucción
      if (message.content.startsWith('AUTOCONFIG_DESTRUCTION:')) {
        print(
            '🔐 [CHAT-SCREEN] ⚙️ Mensaje de configuración de autodestrucción recibido');
        try {
          final parts = message.content.split(':');
          if (parts.length >= 3) {
            final destructionMinutes = int.parse(parts[1]);
            final configuredBy = parts[2];

            // NUEVO: Guardar configuración actual
            setState(() {
              _currentAutoDestructionMinutes = destructionMinutes;
              _autoDestructionConfiguredBy = configuredBy;
            });

            // Crear mensaje visible en el chat
            String timeText;
            if (destructionMinutes >= 60) {
              final hours = destructionMinutes ~/ 60;
              final remainingMinutes = destructionMinutes % 60;
              if (remainingMinutes == 0) {
                timeText = remainingMinutes == 0
                    ? '$hours hora${hours > 1 ? 's' : ''}'
                    : '$hours hora${hours > 1 ? 's' : ''} y $remainingMinutes minuto${remainingMinutes > 1 ? 's' : ''}';
              } else {
                timeText =
                    '$hours hora${hours > 1 ? 's' : ''} y $remainingMinutes minuto${remainingMinutes > 1 ? 's' : ''}';
              }
            } else {
              timeText =
                  '$destructionMinutes minuto${destructionMinutes > 1 ? 's' : ''}';
            }

            final displayMessage = EphemeralMessage(
              id: message.id,
              roomId: message.roomId,
              senderId: 'system',
              content:
                  '⚙️ AUTODESTRUCCIÓN DE MENSAJES ESTABLECIDA EN $timeText por $configuredBy',
              timestamp: message.timestamp,
              isEncrypted: false,
              type: MessageType.normal,
            );

            setState(() {
              _messages.add(displayMessage);
            });

            print(
                '🔐 [CHAT-SCREEN] ✅ Mensaje de configuración mostrado: $timeText');
            print(
                '🔐 [CHAT-SCREEN] ✅ Estado guardado: ${_currentAutoDestructionMinutes}min por $_autoDestructionConfiguredBy');
          }
        } catch (e) {
          print('🔐 [CHAT-SCREEN] ❌ Error procesando configuración: $e');
        }
        return; // No procesar más este mensaje
      }

      // NUEVO: Manejar mensajes de destrucción
      if (message.isDestructionCountdown) {
        print('🔐 [CHAT-SCREEN] 💥 Mensaje de destrucción recibido');
        if (mounted) {
          setState(() {
            _currentDestructionMessage = message;
            _showDestructionCountdown = true;
            // Agregar mensaje de destrucción al chat
            _messages.add(message);
          });
          print(
              '🔐 [CHAT-SCREEN] ✅ Mensaje de destrucción agregado - total: ${_messages.length}');
        }
        return;
      }

      // NUEVO: Log detallado antes de agregar mensaje normal
      print('🔐 [CHAT-SCREEN] 📝 Agregando mensaje normal al chat...');
      print('🔐 [CHAT-SCREEN] - Contenido: "${message.content}"');
      print(
          '🔐 [CHAT-SCREEN] - Es de verificación: ${message.content.startsWith('VERIFICATION_CODES:')}');
      print(
          '🔐 [CHAT-SCREEN] - Es de destrucción: ${message.isDestructionCountdown}');

      if (mounted) {
        setState(() {
          _messages.add(message);
        });

        // NUEVO: Sincronizar mensaje recibido con ChatSession para persistencia
        _syncMessageWithSession(message);

        print(
            '🔐 [CHAT-SCREEN] ✅ Mensaje agregado a la lista - total: ${_messages.length}');
        print('🔐 [CHAT-SCREEN] ✅ Estado actualizado - UI debería refrescarse');

        // NUEVO: Forzar rebuild del widget para asegurar que se muestre
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            setState(() {
              // Forzar rebuild
            });
            print('🔐 [CHAT-SCREEN] ✅ Rebuild forzado para mostrar mensaje');
          }
        });
      } else {
        print('🔐 [CHAT-SCREEN] ❌ Widget no montado - mensaje no agregado');
      }
    };

    _chatService.onRoomDestroyed = () {
      print('🔐 [CHAT-SCREEN] ¡¡¡CALLBACK onRoomDestroyed EJECUTADO!!!');
      print(
          '🔐 [CHAT-SCREEN] - Widget.isFromMultiRoom: ${widget.isFromMultiRoom}');

      if (mounted) {
        // CORREGIDO: Limpiar estado local siempre
        setState(() {
          _currentRoom = null;
          _showDestructionCountdown = false;
          _currentDestructionMessage = null;
          // NUEVO: Limpiar TODOS los mensajes para evitar estado zombie
          _messages.clear();
        });

        print('🔐 [CHAT-SCREEN] ✅ Estado local limpiado');

        // NUEVO: Estrategia de navegación inteligente basada en sesiones restantes
        if (widget.isFromMultiRoom) {
          print('🔐 [CHAT-SCREEN] 🔄 Iniciando navegación inteligente...');
          print(
              '🔐 [CHAT-SCREEN] 📍 URL actual: ${_getCurrentNavigationInfo(context)}');

          // Verificar cuántas sesiones activas quedan después de esta destrucción
          final chatManager = EphemeralChatManager.instance;
          final totalSessions = chatManager.activeSessions.length;
          final activeSessionsWithRooms = chatManager.activeSessions
              .where((s) => s.currentRoom != null && !s.justReset)
              .length;

          print('🔐 [CHAT-SCREEN] 📊 Sesiones totales: $totalSessions');
          print(
              '🔐 [CHAT-SCREEN] 📊 Sesiones con salas activas: $activeSessionsWithRooms');

          try {
            if (activeSessionsWithRooms > 0) {
              // HAY OTRAS SALAS ACTIVAS - volver a chats múltiples
              print(
                  '🔐 [CHAT-SCREEN] ✅ Hay salas activas - volviendo a chats múltiples');
              Navigator.of(context).pop();
            } else {
              // NO HAY SALAS ACTIVAS - ir al home para empezar limpio
              print('🔐 [CHAT-SCREEN] ✅ No hay salas activas - yendo al home');
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/home', (route) => false);
            }

            print('🔐 [CHAT-SCREEN] ✅ Navegación inteligente ejecutada');

            // IMPORTANTE: Dar tiempo para que se actualice el estado
            Future.delayed(const Duration(milliseconds: 1500), () {
              if (activeSessionsWithRooms > 0) {
                print(
                    '🔐 [CHAT-SCREEN] 🔄 Forzando actualización de chats múltiples...');
                // Forzar actualización del MultiRoomChatScreen si existe
              }
            });
          } catch (e) {
            print('🔐 [CHAT-SCREEN] ❌ Error en navegación inteligente: $e');

            // RESPALDO: Siempre ir al home si hay error
            try {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/home', (route) => false);
              print(
                  '🔐 [CHAT-SCREEN] ✅ Navegación de respaldo al home ejecutada');
            } catch (e2) {
              print('🔐 [CHAT-SCREEN] ❌ Error crítico en navegación: $e2');
            }
          }
        } else {
          print('🔐 [CHAT-SCREEN] 🔄 Navegando - pantalla individual');
          _navigateAfterDestruction();
        }
      }
    };

    // NUEVO: Callbacks para destrucción manual
    _chatService.onDestructionCountdownStarted = () {
      print('🔐 [CHAT-SCREEN] ⏰ Contador de destrucción iniciado');

      // CORREGIDO: Solo crear mensaje si NO existe ningún mensaje de destrucción
      final hasDestructionMessage =
          _messages.any((msg) => msg.isDestructionCountdown);

      if (_currentRoom != null && mounted && !hasDestructionMessage) {
        final destructionMessage = EphemeralMessage.destructionCountdown(
          roomId: _currentRoom!.id,
          senderId: 'system', // Sistema para ambos usuarios
          countdown: 10,
        );

        setState(() {
          _currentDestructionMessage = destructionMessage;
          _showDestructionCountdown = true;
          _messages.add(destructionMessage);
        });

        print('🔐 [CHAT-SCREEN] ✅ Mensaje de destrucción creado único');
      } else {
        print(
            '🔐 [CHAT-SCREEN] ⚠️ Mensaje de destrucción NO creado - ya existe: $hasDestructionMessage');
      }
    };

    _chatService.onDestructionCountdownCancelled = () {
      print('🔐 [CHAT-SCREEN] ✅ Contador de destrucción cancelado');
      if (mounted) {
        setState(() {
          _showDestructionCountdown = false;
          _currentDestructionMessage = null;
          // Remover mensaje de destrucción del chat
          _messages.removeWhere((msg) => msg.isDestructionCountdown);
        });
      }
    };

    // CORREGIDO: Callback para actualizar contador - funciona para AMBOS usuarios
    _chatService.onDestructionCountdownUpdate = (countdown) {
      print('🔐 [CHAT-SCREEN] ⏰ Actualizando contador: $countdown');

      if (mounted) {
        // CORREGIDO: Si no hay mensaje de destrucción, crearlo (para el usuario que no lo inició)
        if (_currentDestructionMessage == null && _currentRoom != null) {
          print(
              '🔐 [CHAT-SCREEN] 🆕 Creando mensaje de destrucción para usuario receptor');
          final destructionMessage = EphemeralMessage.destructionCountdown(
            roomId: _currentRoom!.id,
            senderId: 'system',
            countdown: countdown,
          );

          setState(() {
            _currentDestructionMessage = destructionMessage;
            _showDestructionCountdown = true;
            _messages.add(destructionMessage);
          });
        } else if (_currentDestructionMessage != null) {
          // Actualizar mensaje existente
          setState(() {
            final updatedMessage = EphemeralMessage.destructionCountdown(
              roomId: _currentDestructionMessage!.roomId,
              senderId: _currentDestructionMessage!.senderId,
              countdown: countdown,
            );

            // Reemplazar el mensaje en la lista
            final index =
                _messages.indexWhere((msg) => msg.isDestructionCountdown);
            if (index != -1) {
              _messages[index] = updatedMessage;
              _currentDestructionMessage = updatedMessage;
            }
          });
        }

        // CORREGIDO: Si el contador llega a 0, navegar apropiadamente
        if (countdown <= 0) {
          print(
              '🔐 [CHAT-SCREEN] 💥 Contador terminado - la navegación se manejará en onRoomDestroyed');

          // NUEVO: Solo limpiar estado local, dejar que onRoomDestroyed maneje la navegación
          setState(() {
            _showDestructionCountdown = false;
            _currentDestructionMessage = null;
          });

          // ELIMINADO: Ya no necesitamos navegación de respaldo conflictiva
          // La navegación se maneja completamente en onRoomDestroyed
        }
      }
    };

    _chatService.onError = (error) {
      print('🔐 [CHAT-SCREEN] ¡¡¡CALLBACK onError EJECUTADO!!!');
      print('🔐 [CHAT-SCREEN] Error: $error');
      print('🔐 [CHAT-SCREEN] Mounted: $mounted');

      if (mounted) {
        setState(() {
          _error = error;
        });
        print('🔐 [CHAT-SCREEN] ✅ Error establecido en estado');
      }
    };

    print('🔐 [CHAT-SCREEN] ✅ Todos los callbacks configurados');

    // NUEVO: Verificar que los callbacks están realmente configurados
    print('🔐 [CHAT-SCREEN] 🔍 Verificación de callbacks:');
    print(
        '🔐 [CHAT-SCREEN] - onRoomCreated: ${_chatService.onRoomCreated != null}');
    print(
        '🔐 [CHAT-SCREEN] - onMessageReceived: ${_chatService.onMessageReceived != null}');
    print(
        '🔐 [CHAT-SCREEN] - onRoomDestroyed: ${_chatService.onRoomDestroyed != null}');
    print('🔐 [CHAT-SCREEN] - onError: ${_chatService.onError != null}');
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _currentRoom == null) return;

    print('🔐 [CHAT-SCREEN] 📤 Enviando mensaje: "$text"');
    print('🔐 [CHAT-SCREEN] - Sala actual: ${_currentRoom?.id}');
    print(
        '🔐 [CHAT-SCREEN] - Destrucción en: ${_selectedDestructionMinutes ?? "sin límite"} minutos');
    print('🔐 [CHAT-SCREEN] - Mensajes antes de enviar: ${_messages.length}');

    try {
      // CORREGIDO: Pasar destructionTimeMinutes al servicio para sincronización
      await _chatService.sendMessage(text,
          destructionTimeMinutes: _selectedDestructionMinutes);
      _messageController.clear();

      // Agregar mensaje propio a la lista con tiempo de destrucción
      final myMessage = EphemeralMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        roomId: _currentRoom!.id,
        senderId: 'me',
        content: text,
        timestamp: DateTime.now(),
        destructionTimeMinutes: _selectedDestructionMinutes,
        destructionTime: _selectedDestructionMinutes != null
            ? DateTime.now()
                .add(Duration(minutes: _selectedDestructionMinutes!))
            : null,
      );

      print('🔐 [CHAT-SCREEN] 📝 Creando mensaje propio...');
      print('🔐 [CHAT-SCREEN] - ID: ${myMessage.id}');
      print('🔐 [CHAT-SCREEN] - Contenido: "${myMessage.content}"');
      print('🔐 [CHAT-SCREEN] - SenderId: ${myMessage.senderId}');
      print('🔐 [CHAT-SCREEN] - Destrucción: ${myMessage.destructionTime}');

      if (mounted) {
        setState(() {
          _messages.add(myMessage);
        });

        // NUEVO: Sincronizar con ChatSession del manager para persistencia
        _syncMessageWithSession(myMessage);

        print(
            '🔐 [CHAT-SCREEN] ✅ Mensaje propio agregado - total: ${_messages.length}');
        print(
            '🔐 [CHAT-SCREEN] ✅ Estado actualizado - UI debería mostrar el mensaje');
      } else {
        print(
            '🔐 [CHAT-SCREEN] ❌ Widget no montado - mensaje propio no agregado');
      }
    } catch (e) {
      print('🔐 [CHAT-SCREEN] ❌ Error enviando mensaje: $e');
      if (mounted) {
        setState(() {
          _error = 'Error enviando mensaje: $e';
        });
      }
    }
  }

  /// NUEVO: Sincronizar mensaje con ChatSession para persistencia
  void _syncMessageWithSession(EphemeralMessage message) {
    if (widget.isFromMultiRoom && widget.ephemeralChatService != null) {
      try {
        final chatManager = EphemeralChatManager.instance;
        final sessions = chatManager.activeSessions;

        // Encontrar la sesión correspondiente
        final session = sessions.firstWhere(
          (s) => s.chatService == widget.ephemeralChatService,
          orElse: () => throw Exception('Sesión no encontrada'),
        );

        // Agregar mensaje al ChatSession
        session.addMessage(message);
        print(
            '🔐 [CHAT-SCREEN] ✅ Mensaje sincronizado con ChatSession: ${session.sessionId}');
      } catch (e) {
        print('🔐 [CHAT-SCREEN] ⚠️ Error sincronizando mensaje con sesión: $e');
      }
    }
  }

  // NUEVO: Iniciar timer de destrucción de mensajes
  void _startDestructionTimer() {
    _destructionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      // Filtrar mensajes que deben ser destruidos
      final messagesToKeep =
          _messages.where((message) => !message.shouldBeDestroyed).toList();

      if (messagesToKeep.length != _messages.length) {
        setState(() {
          _messages.clear();
          _messages.addAll(messagesToKeep);
        });
      }
    });
  }

  // NUEVO: Limpiar mensajes destruidos manualmente
  void _cleanDestroyedMessages() {
    final messagesToKeep =
        _messages.where((message) => !message.shouldBeDestroyed).toList();
    setState(() {
      _messages.clear();
      _messages.addAll(messagesToKeep);
    });
  }

  void _leaveRoom() {
    _chatService.leaveRoom();
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    // MEJORADO: Gestión inteligente de dispose basada en el contexto
    if (widget.ephemeralChatService == null) {
      // Servicio propio - limpiar todo
      print('🔐 [CHAT-SCREEN] 🗑️ Limpiando servicio propio');
      _chatService.onRoomCreated = null;
      _chatService.onMessageReceived = null;
      _chatService.onRoomDestroyed = null;
      _chatService.onError = null;
      _chatService.onDestructionCountdownStarted = null;
      _chatService.onDestructionCountdownCancelled = null;
      _chatService.onDestructionCountdownUpdate = null;
      _chatService.dispose();
    } else {
      // Servicio externo - mantener activo para múltiples salas
      print(
          '🔐 [CHAT-SCREEN] 🔄 Manteniendo servicio activo para múltiples salas');

      // NUEVO: Solo limpiar callbacks si no estamos navegando dentro de TabBarView
      if (_isFromMultiRoomContext()) {
        print(
            '🔐 [CHAT-SCREEN] 🔄 Navegación desde múltiples salas - manteniendo en TabBarView');
        // NO limpiar callbacks para mantener funcionalidad en TabBarView
      } else {
        // Navegación fuera de TabBarView - limpiar callbacks locales
        _chatService.onRoomCreated = null;
        _chatService.onMessageReceived = null;
        _chatService.onRoomDestroyed = null;
        _chatService.onError = null;
        _chatService.onDestructionCountdownStarted = null;
        _chatService.onDestructionCountdownCancelled = null;
        _chatService.onDestructionCountdownUpdate = null;
      }
    }

    // Cancelar timer de destrucción local
    _destructionTimer?.cancel();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUserId =
        authProvider.user?.id; // Obtener ID del usuario actual

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentRoom != null ? 'Chat Efímero' : 'Conectando...'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _isFromMultiRoomContext()
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  print('🔐 [CHAT-SCREEN] 🔄 Volviendo a chats múltiples');
                  Navigator.of(context).pop();
                },
                tooltip: 'Volver a chats múltiples',
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  print(
                      '🔐 [CHAT-SCREEN] 🔄 Volviendo a chat efímero individual');
                  Navigator.of(context).pop();
                },
                tooltip: 'Volver a chat efímero',
              ),
        actions: [
          // Botón para destruir sala manualmente
          if (_currentRoom != null && !_showDestructionCountdown)
            IconButton(
              icon: const Icon(Icons.delete_forever, color: Colors.red),
              onPressed: _showDestructionDialog,
              tooltip: 'Destruir Sala',
            ),
        ],
      ),
      body: Column(
        children: [
          // Header info (solo cuando hay contenido importante)
          if (_isConnecting ||
              _error != null ||
              _showDestructionCountdown && _currentDestructionMessage != null)
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.3,
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Estado de conexión
                    if (_isConnecting)
                      Container(
                        padding: const EdgeInsets.all(12),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 12),
                            Text('Conectando...',
                                style: TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),

                    // Error
                    if (_error != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.red[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error,
                                color: Colors.red, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _error!,
                                style: const TextStyle(
                                    color: Colors.red, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Widget de destrucción si está activo
                    if (_showDestructionCountdown &&
                        _currentDestructionMessage != null)
                      Container(
                        margin: const EdgeInsets.all(12),
                        child: DestructionCountdownWidget(
                          isInChat: false,
                          initialCountdown: _currentDestructionMessage!
                                  .destructionCountdownValue ??
                              10,
                          showCancelButton:
                              _currentDestructionMessage!.senderId == 'me',
                          onCancel: _currentDestructionMessage!.senderId == 'me'
                              ? () {
                                  _cancelDestructionCountdown();
                                }
                              : null,
                        ),
                      ),
                  ],
                ),
              ),
            ),

          // Lista de mensajes - Área principal con scroll
          Expanded(
            child: Builder(builder: (context) {
              print('🔐 [CHAT-SCREEN] 🎨 Construyendo lista de mensajes...');
              print('🔐 [CHAT-SCREEN] - Total mensajes: ${_messages.length}');

              if (_messages.isEmpty) {
                return const Center(
                  child: Text(
                    'No hay mensajes aún.\nEscribe algo para comenzar.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];

                  // Mostrar mensaje de destrucción de forma especial
                  if (message.isDestructionCountdown) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: DestructionCountdownWidget(
                        isInChat: true,
                        initialCountdown: message.destructionCountdownValue,
                        showCancelButton: message.senderId == 'me',
                        onCancel: message.senderId == 'me'
                            ? () {
                                _cancelDestructionCountdown();
                              }
                            : null,
                      ),
                    );
                  }

                  // Determinar si el mensaje es del usuario actual
                  final isMe = message.senderId == 'me' ||
                      message.senderId == currentUserId;

                  return Align(
                    alignment:
                        isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isMe ? Colors.blue : Colors.grey[300],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message.content,
                            style: TextStyle(
                              color: isMe ? Colors.white : Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                message.timeAgo,
                                style: TextStyle(
                                  color:
                                      isMe ? Colors.white70 : Colors.grey[600],
                                  fontSize: 10,
                                ),
                              ),
                              if (message.destructionCountdown.isNotEmpty) ...[
                                const SizedBox(width: 6),
                                Text(
                                  message.destructionCountdown,
                                  style: TextStyle(
                                    color: isMe
                                        ? Colors.white70
                                        : Colors.orange[700],
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),

          // Campo de entrada de mensaje - Fijo en la parte inferior
          if (_currentRoom != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Selector de tiempo de autodestrucción (más compacto)
                  Row(
                    children: [
                      const Icon(Icons.auto_delete,
                          size: 14, color: Colors.orange),
                      const SizedBox(width: 6),
                      const Text(
                        'Autodestrucción:',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: DestructionTimerWidget(
                          selectedMinutes: _selectedDestructionMinutes,
                          onChanged: (minutes) {
                            setState(() {
                              _selectedDestructionMinutes = minutes;
                            });

                            // Enviar automáticamente la configuración al VPS
                            if (minutes != null) {
                              _configureAutoDestruction(minutes);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'Escribe un mensaje...',
                            hintStyle: const TextStyle(fontSize: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: FloatingActionButton(
                          heroTag:
                              "ephemeral_chat_fab_${_currentRoom?.id ?? 'default'}",
                          onPressed: _sendMessage,
                          backgroundColor: Colors.blue,
                          mini: true,
                          child: const Icon(Icons.send,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// NUEVO: Mostrar diálogo de confirmación para destruir sala
  void _showDestructionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 10),
            Text('⚠️ Destruir Sala'),
          ],
        ),
        content: const Text(
          'Esta acción destruirá permanentemente la sala de chat para ambos usuarios.\n\n'
          'Se iniciará un contador de 10 segundos visible para ambos participantes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startDestructionCountdown();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Destruir Sala'),
          ),
        ],
      ),
    );
  }

  /// NUEVO: Iniciar contador de destrucción
  void _startDestructionCountdown() {
    // NUEVO: Crear mensaje de destrucción local inmediatamente
    if (_currentRoom != null) {
      final destructionMessage = EphemeralMessage.destructionCountdown(
        roomId: _currentRoom!.id,
        senderId: 'me', // Quien inicia la destrucción
        countdown: 10,
      );

      setState(() {
        _currentDestructionMessage = destructionMessage;
        _showDestructionCountdown = true;
        _messages.add(destructionMessage);
      });
    }

    // Enviar comando al servidor para notificar al otro usuario
    _chatService.startDestructionCountdown();
  }

  /// NUEVO: Cancelar contador de destrucción
  void _cancelDestructionCountdown() {
    // NUEVO: Enviar cancelación al servidor
    if (_currentRoom != null) {
      _chatService.cancelDestructionCountdown();
    }

    setState(() {
      _showDestructionCountdown = false;
      _currentDestructionMessage = null;
      // Remover mensaje de destrucción del chat
      _messages.removeWhere((msg) => msg.isDestructionCountdown);
    });
  }

  // NUEVO: Detectar automáticamente si venimos de múltiples salas
  void _detectMultiRoomContext() {
    // CORREGIDO: Detectar contexto basado en múltiples factores
    bool isFromMulti = false;

    // 1. Si tenemos un servicio existente, probablemente venimos de múltiples salas
    if (widget.ephemeralChatService != null) {
      isFromMulti = true;
      print(
          '🔐 [CHAT-SCREEN] ✅ Contexto detectado: MÚLTIPLES SALAS (servicio existente)');
    }

    // 2. Si el flag explícito está activado
    if (widget.isFromMultiRoom) {
      isFromMulti = true;
      print(
          '🔐 [CHAT-SCREEN] ✅ Contexto detectado: MÚLTIPLES SALAS (flag explícito)');
    }

    // 3. Si tenemos invitationId, probablemente venimos de invitaciones (múltiples salas)
    if (widget.invitationId != null) {
      isFromMulti = true;
      print(
          '🔐 [CHAT-SCREEN] ✅ Contexto detectado: MÚLTIPLES SALAS (invitación recibida)');
    }

    _isFromMultiRoomDetected = isFromMulti;

    if (!isFromMulti) {
      print('🔐 [CHAT-SCREEN] ✅ Contexto detectado: CHAT INDIVIDUAL');
    }

    print(
        '🔐 [CHAT-SCREEN] isFromMultiRoom final: ${_isFromMultiRoomContext()}');
  }

  // NUEVO: Método para obtener el contexto final (explícito o detectado)
  bool _isFromMultiRoomContext() {
    return widget.isFromMultiRoom || _isFromMultiRoomDetected;
  }

  /// NUEVO: Navegar apropiadamente después de la destrucción
  void _navigateAfterDestruction() {
    print('🔐 [CHAT-SCREEN] 🔄 Navegando después de la destrucción');
    print(
        '🔐 [CHAT-SCREEN] Contexto: ${_isFromMultiRoomContext() ? "MÚLTIPLES SALAS" : "CHAT INDIVIDUAL"}');
    print('🔐 [CHAT-SCREEN] Widget montado: $mounted');

    if (!mounted) {
      print('🔐 [CHAT-SCREEN] ❌ Widget no montado - cancelando navegación');
      return;
    }

    // CORREGIDO: Limpiar el servicio antes de navegar
    try {
      if (_currentRoom != null) {
        print('🔐 [CHAT-SCREEN] 🧹 Limpiando sala actual: ${_currentRoom!.id}');
        _chatService.leaveRoom();
      }
    } catch (e) {
      print('🔐 [CHAT-SCREEN] ⚠️ Error limpiando sala: $e');
    }

    // CORREGIDO: Navegación más robusta
    try {
      if (_isFromMultiRoomContext()) {
        // Venimos de múltiples salas - volver a la lista de chats múltiples
        print('🔐 [CHAT-SCREEN] ↩️ Volviendo a chats múltiples');
        Navigator.of(context).pushReplacementNamed('/multi-room-chat');
      } else {
        // Venimos de chat individual - volver al home
        print('🔐 [CHAT-SCREEN] ↩️ Volviendo al home');
        Navigator.of(context).pushReplacementNamed('/home');
      }

      print('🔐 [CHAT-SCREEN] ✅ Navegación completada exitosamente');
    } catch (e) {
      print('🔐 [CHAT-SCREEN] ❌ Error en navegación: $e');

      // RESPALDO: Si falla la navegación, intentar ir al home
      try {
        Navigator.of(context).pushReplacementNamed('/home');
        print('🔐 [CHAT-SCREEN] ✅ Navegación de respaldo al home exitosa');
      } catch (e2) {
        print(
            '🔐 [CHAT-SCREEN] ❌ Error crítico en navegación de respaldo: $e2');
      }
    }
  }

  /// NUEVO: Configurar autodestrucción automática
  void _configureAutoDestruction(int minutes) {
    _chatService.configureAutoDestruction(minutes);

    // Mostrar feedback inmediato al usuario que configura
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('⚙️ Configurando autodestrucción: $minutes minutos...'),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );

    print(
        '🔐 [CHAT-SCREEN] ✅ Configuración de autodestrucción enviada: $minutes minutos');
  }
}
