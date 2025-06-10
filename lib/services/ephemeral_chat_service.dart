import 'dart:convert';
import 'dart:typed_data';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutterputter/services/encryption_service.dart';
import 'package:flutterputter/models/ephemeral_room.dart';
import 'package:flutterputter/models/ephemeral_message.dart';
import 'package:flutterputter/models/chat_invitation.dart';
import 'dart:async';
import 'package:flutterputter/services/auto_destruction_preferences_service.dart';

class EphemeralChatService {
  IO.Socket? _socket;
  EncryptionService? _encryptionService;
  String? _currentRoomId;
  String? _tempIdentity;
  String? _userId;
  Timer? _participantUpdateTimer; // NUEVO: Timer para actualizar participantes
  int _participantCount = 0; // NUEVO: Contador local de participantes
  Timer? _destructionTimer; // NUEVO: Timer para simulación de destrucción

  // NUEVO: Identificador único para esta instancia
  final String _instanceId =
      'instance_${DateTime.now().millisecondsSinceEpoch}_${(DateTime.now().microsecond % 1000).toString().padLeft(3, '0')}';
  bool _disposed = false; // Flag para verificar si la instancia fue desechada

  // Callbacks para eventos
  Function(ChatInvitation)? onInvitationReceived;
  Function(EphemeralRoom)? onRoomCreated;
  Function(EphemeralMessage)? onMessageReceived;
  Function()? onRoomDestroyed;
  Function(String)? onError;

  // NUEVO: Callbacks para destrucción manual
  Function()? onDestructionCountdownStarted;
  Function()? onDestructionCountdownCancelled;
  Function(int countdown)?
      onDestructionCountdownUpdate; // NUEVO: Para actualizar contador

  // NUEVO: Propiedad para verificar estado de conexión
  bool get isConnected => _socket != null && _socket!.connected && !_disposed;
  String? get currentRoomId => _currentRoomId;
  int get participantCount => _participantCount;
  String get instanceId =>
      _instanceId; // Getter público para el ID de instancia

  Future<void> initialize({String? userId}) async {
    try {
      if (_disposed) {
        return;
      }

      _userId = userId;

      // Inicializar cifrado ChaCha20-Poly1305
      _encryptionService = EncryptionService();
      await _encryptionService!.initialize();

      // NUEVO: Verificar si ya hay un socket conectado
      if (_socket != null && _socket!.connected) {
        // Solo registrar usuario si es necesario
        if (_userId != null) {
          _socket!.emit('register-user', {
            'userId': _userId,
          });
        }

        return;
      }

      // Conectar a servidor de chat efímero - CORREGIDO: usar path correcto
      _socket = IO.io(
          'https://clubprivado.ws',
          IO.OptionBuilder()
              .setPath('/ephemeral-chat/socket.io')
              .setTransports(['websocket', 'polling'])
              .enableAutoConnect()
              .enableForceNew()
              .setTimeout(10000) // NUEVO: Timeout de 10 segundos
              .setQuery({
                'service': 'ephemeral-chat',
                'type': 'flutter-ephemeral',
                'client': 'flutter-web',
                'instance_id': _instanceId, // NUEVO: Incluir ID de instancia
                'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
                'unique_id':
                    'ephemeral_${DateTime.now().millisecondsSinceEpoch}'
              })
              .setExtraHeaders({
                'Origin': 'https://clubprivado.ws',
                'X-Service-Type': 'ephemeral-chat'
              })
              .build());

      _setupSocketListeners();
      _socket!.connect();

      // MEJORADO: Esperar conexión con timeout
      bool connected = false;
      int attempts = 0;
      const maxAttempts = 20; // 10 segundos (500ms * 20)

      while (!connected && attempts < maxAttempts && !_disposed) {
        await Future.delayed(const Duration(milliseconds: 500));
        connected = _socket!.connected;
        attempts++;

        if (attempts % 4 == 0) {
          // Log cada 2 segundos
        }
      }

      if (_disposed) {
        return;
      }

      if (_socket!.connected) {
      } else {
        throw Exception('Timeout de conexión al servidor de chat efímero');
      }
    } catch (e) {
      if (onError != null) {
        onError!('Error inicializando chat efímero: $e');
      }
      rethrow;
    }
  }

  void _setupSocketListeners() {
    _socket!.onConnect((_) {
      if (_disposed) return;

      // NUEVO: Registrar usuario para recibir invitaciones
      if (_userId != null) {
        _socket!.emit('register-user', {
          'userId': _userId,
        });
      } else {}
    });

    _socket!.onDisconnect((reason) {
      if (_disposed) return;
      print('🔐 [CHAT-SERVICE] ⚠️ Socket desconectado: $reason');
      print('🔐 [CHAT-SERVICE] ⚠️ UserId afectado: $_userId');
    });

    _socket!.onConnectError((error) {
      if (_disposed) return;

      if (onError != null) {
        onError!('Error de conexión: $error');
      }
    });

    // Agregar listener para eventos de debug
    _socket!.onAny((event, data) {
      if (_disposed) return;
    });

    _socket!.on('chat-invitation-received', (data) {
      print('🔐 [CHAT-SERVICE] 📨 Invitación recibida del servidor');
      print('🔐 [CHAT-SERVICE] 📨 Para userId: ${data['targetUserId']}');
      print('🔐 [CHAT-SERVICE] 📨 Mi userId: $_userId');
      print(
          '🔐 [CHAT-SERVICE] 📨 Estado cifrado: ${_encryptionService != null ? 'DISPONIBLE' : 'NULL'}');

      // Verificar si la invitación es para este usuario
      if (data['targetUserId'] == _userId) {
        if (onInvitationReceived != null) {
          print('🔐 [CHAT-SERVICE] ✅ Procesando invitación para mi usuario');
          final invitation =
              ChatInvitation.fromJson(Map<String, dynamic>.from(data));
          onInvitationReceived!(invitation);
        } else {
          print('🔐 [CHAT-SERVICE] ⚠️ No hay callback onInvitationReceived');
        }
      } else {
        print('🔐 [CHAT-SERVICE] ⚠️ Invitación no es para mi usuario');
      }
    });

    _socket!.on('invitation-created', (data) {});

    _socket!.on('invitation-rejected', (data) {
      print(
          '🔐 [CHAT-SERVICE] 📥 Servidor respondió invitation-rejected: $data');
      // TODO: Procesar respuesta del servidor si es necesario
    });

    _socket!.on('room-created', (data) async {
      // CORREGIDO: Establecer roomId con múltiples verificaciones
      String? newRoomId = data['roomId'] ?? data['id'];

      if (newRoomId == null || newRoomId.isEmpty) {
        // Intentar extraer de otros campos posibles
        newRoomId = data['room']?['id'] ??
            data['room']?['roomId'] ??
            'emergency_room_${DateTime.now().millisecondsSinceEpoch}';
      }

      _currentRoomId = newRoomId;

      // NUEVO: Extraer y guardar el contador de participantes
      if (data['participantCount'] != null) {
        _participantCount = data['participantCount'];
      } else {
        // Si no viene en los datos, asumir 2 participantes por defecto
        _participantCount = 2;
      }

      // CORREGIDO: Verificar que el cifrado esté disponible antes de procesar clave
      if (_encryptionService == null) {
        try {
          _encryptionService = EncryptionService();
          await _encryptionService!.initialize();
        } catch (e) {
          if (onError != null) {
            onError!('Error inicializando cifrado: $e');
          }
          return;
        }
      }

      // Establecer clave de cifrado para la sala (128 bytes = 1024 bits)
      if (data['encryptionKey'] != null) {
        try {
          final masterKeyBytes = base64Decode(data['encryptionKey']);
          // Derivar clave de sesión ChaCha20 (32 bytes) desde la clave maestra (128 bytes)
          // usando HKDF para máxima seguridad
          final sessionKey = await _encryptionService!
              .deriveSessionKeyFromShared(Uint8List.fromList(masterKeyBytes),
                  'ephemeral-chat-$_currentRoomId');

          await _encryptionService!.setSessionKey(sessionKey);
        } catch (e) {
          if (onError != null) {
            onError!('Error estableciendo cifrado: $e');
          }
        }
      }

      if (onRoomCreated != null) {
        // CORREGIDO: Crear sala con el roomId correcto
        final roomData = Map<String, dynamic>.from(data);
        roomData['participantCount'] = _participantCount;
        roomData['id'] =
            _currentRoomId; // CORREGIDO: Asegurar que 'id' esté presente
        roomData['roomId'] = _currentRoomId; // CORREGIDO: Mantener ambos campos

        final room = EphemeralRoom.fromJson(roomData);
        onRoomCreated!(room);
      }

      // NUEVO: APLICAR AUTO-CONFIGURACIÓN POR DEFECTO AQUÍ
      _autoApplyDefaultDestruction();

      // NUEVO: Solicitar información actualizada de la sala después de crearla
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (_currentRoomId != null && _socket != null && _socket!.connected) {
          _socket!.emit('get-room-info', {'roomId': _currentRoomId});
        }
      });

      // NUEVO: Iniciar polling para mantener actualizado el contador
      _startParticipantPolling();
    });

    // NUEVO: Escuchar actualizaciones de participantes
    _socket!.on('room-updated', (data) {
      if (onRoomCreated != null && data['roomId'] == _currentRoomId) {
        final room = EphemeralRoom.fromJson(Map<String, dynamic>.from(data));
        onRoomCreated!(room); // Reutilizar el callback para actualizar la UI
      }
    });

    _socket!.on('user-joined', (data) {
      // Solicitar estadísticas actualizadas de la sala
      if (_currentRoomId != null) {
        _socket!.emit('get-room-info', {'roomId': _currentRoomId});
      }
    });

    _socket!.on('user-left', (data) {
      // Solicitar estadísticas actualizadas de la sala
      if (_currentRoomId != null) {
        _socket!.emit('get-room-info', {'roomId': _currentRoomId});
      }
    });

    _socket!.on('room-info', (data) {
      if (onRoomCreated != null && data['roomId'] == _currentRoomId) {
        final room = EphemeralRoom.fromJson(Map<String, dynamic>.from(data));
        onRoomCreated!(room); // Actualizar la UI con la nueva info
      }
    });

    _socket!.on('encrypted-message-received', (data) async {
      try {
        // CORREGIDO: Verificar que el mensaje es para la sala correcta
        if (data['roomId'] != _currentRoomId) {
          return;
        }

        // Descifrar mensaje
        final encryptedBytes = base64Decode(data['encryptedMessage']);
        final decryptedBytes =
            await _encryptionService!.decrypt(encryptedBytes);
        final message = utf8.decode(decryptedBytes);
        final decryptedData = {
          ...Map<String, dynamic>.from(data),
          'message': message,
          'content': message, // CORREGIDO: Agregar campo 'content' también
          // NUEVO: Preservar destructionTimeMinutes para sincronización
          if (data['destructionTimeMinutes'] != null)
            'destructionTimeMinutes': data['destructionTimeMinutes'],
        };

        if (onMessageReceived != null) {
          final messageObj = EphemeralMessage.fromJson(decryptedData);
          onMessageReceived!(messageObj);
        } else {}
      } catch (e) {
        if (onError != null) {
          onError!('Error descifrando mensaje: $e');
        }
      }
    });

    _socket!.on('room-destroyed', (data) {
      // CORREGIDO: Limpiar estado local INMEDIATAMENTE
      final destroyedRoomId = _currentRoomId;

      print('🔐 [CHAT-SERVICE] 💥 SALA DESTRUIDA - Iniciando limpieza...');
      print('🔐 [CHAT-SERVICE] 💥 Sala destruida: $destroyedRoomId');
      print('🔐 [CHAT-SERVICE] 💥 UserId afectado: $_userId');
      _currentRoomId = null;
      _participantCount = 0;

      // CORREGIDO: Cancelar polling inmediatamente
      _participantUpdateTimer?.cancel();
      _participantUpdateTimer = null;

      // NUEVO: LIMPIAR INVITACIONES FANTASMA cuando sala se destruye
      // Esto es crucial para evitar que invitaciones "aceptadas" se reenvíen
      if (_userId != null && _socket != null && _socket!.connected) {
        _socket!.emit('mark-user-invitations-completed', {
          'userId': _userId,
          'roomId': destroyedRoomId,
          'reason': 'room_destroyed_cleanup',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
      }

      // CORREGIDO: Limpiar cifrado
      print('🔐 [CHAT-SERVICE] 💥 Limpiando cifrado...');
      try {
        _encryptionService?.dispose();
        _encryptionService = null;
        print('🔐 [CHAT-SERVICE] ✅ Cifrado limpiado');
      } catch (e) {
        print('🔐 [CHAT-SERVICE] ❌ Error limpiando cifrado: $e');
      }

      if (onRoomDestroyed != null) {
        try {
          print('🔐 [CHAT-SERVICE] 💥 Llamando callback onRoomDestroyed...');
          onRoomDestroyed!();
          print('🔐 [CHAT-SERVICE] ✅ Callback onRoomDestroyed ejecutado');
        } catch (e) {
          print('🔐 [CHAT-SERVICE] ❌ Error en callback onRoomDestroyed: $e');
        }
      } else {
        print('🔐 [CHAT-SERVICE] ⚠️ No hay callback onRoomDestroyed');
      }

      // CRÍTICO: Reinicializar cifrado SÍNCRONAMENTE para evitar estado inconsistente
      print('🔐 [CHAT-SERVICE] 💥 Reinicializando cifrado...');
      Future.delayed(const Duration(milliseconds: 100), () async {
        try {
          _encryptionService = EncryptionService();
          await _encryptionService!.initialize();
          print(
              '🔐 [CHAT-SERVICE] ✅ Cifrado reinicializado - LISTO para nuevas invitaciones');
        } catch (e) {
          print('🔐 [CHAT-SERVICE] ❌ Error reinicializando cifrado: $e');
        }
      });
    });

    _socket!.on('error', (data) {
      if (onError != null) {
        onError!(data['message'] ?? 'Error desconocido');
      }
    });

    // CORREGIDO: También aplicar cuando alguien acepta una invitación y se une a la sala
    _socket!.on('invitation-accepted', (data) {
      // NUEVO: APLICAR AUTO-CONFIGURACIÓN POR DEFECTO AQUÍ TAMBIÉN
      _autoApplyDefaultDestruction();

      // Solicitar información actualizada de la sala
      if (_currentRoomId != null) {
        _socket!.emit('get-room-info', {'roomId': _currentRoomId});
      }
    });

    // NUEVO: Listener para destrucción manual
    _socket!.on('destruction-countdown-started', (data) {
      if (onDestructionCountdownStarted != null) {
        onDestructionCountdownStarted!();
      }

      // Crear mensaje de destrucción para mostrar en el chat
      if (onMessageReceived != null && _currentRoomId != null) {
        final destructionMessage = EphemeralMessage.destructionCountdown(
          roomId: _currentRoomId!,
          senderId: data['initiatedBy'] ?? 'system',
          countdown: data['countdown'] ?? 10,
        );
        onMessageReceived!(destructionMessage);
      }
    });

    _socket!.on('destruction-countdown-update', (data) {
      if (onDestructionCountdownUpdate != null) {
        onDestructionCountdownUpdate!(data['countdown'] ?? 0);
      }
    });

    _socket!.on('destruction-countdown-cancelled', (data) {
      if (onDestructionCountdownCancelled != null) {
        onDestructionCountdownCancelled!();
      }
    });

    // NUEVO: Listener para autodestrucción automática de mensajes desde servidor
    _socket!.on('auto-destroy-messages', (data) {
      if (onMessageReceived != null) {
        // Crear evento especial para que la UI limpie mensajes
        final cleanupMessage = EphemeralMessage(
          id: 'cleanup_${DateTime.now().millisecondsSinceEpoch}',
          roomId: _currentRoomId ?? '',
          senderId: 'server',
          content: 'CLEANUP_MESSAGES:${data['destructionMinutes']}',
          timestamp: DateTime.now(),
          isEncrypted: false,
          type: MessageType.normal,
        );
        onMessageReceived!(cleanupMessage);
      }
    });

    // NUEVO: Listener para confirmación de configuración de autodestrucción
    _socket!.on('auto-destruction-configured', (data) {
      if (onMessageReceived != null && _currentRoomId != null) {
        // Crear mensaje visible para ambos usuarios
        final configMessage = EphemeralMessage(
          id: 'autoconfig_${DateTime.now().millisecondsSinceEpoch}',
          roomId: _currentRoomId!,
          senderId: 'system',
          content:
              'AUTOCONFIG_DESTRUCTION:${data['destructionMinutes']}:${data['configuredBy'] ?? 'usuario'}',
          timestamp: DateTime.now(),
          isEncrypted: false,
          type: MessageType.normal,
        );
        onMessageReceived!(configMessage);
      }
    });
  }

  Future<void> createChatInvitation(String targetUserId) async {
    // NUEVO: Verificar y asegurar conexión antes de proceder
    if (!await ensureConnection()) {
      throw Exception('No se pudo conectar al servidor de chat efímero');
    }

    // NUEVO: Verificar que el cifrado esté listo
    if (_encryptionService == null) {
      throw Exception('Servicio de cifrado no disponible');
    }

    // Enviar evento al servidor
    _socket!.emit('create-chat-invitation', {
      'targetUserId': targetUserId,
    });

    // NUEVO: Iniciar polling de participantes después de crear invitación
    _startParticipantPolling();
  }

  // NUEVO: Método para iniciar polling de participantes
  void _startParticipantPolling() {
    if (_disposed) {
      return;
    }

    // Cancelar timer anterior si existe
    _participantUpdateTimer?.cancel();

    // NUEVO: Timer para simular actualizaciones de participantes cada 10 segundos
    _participantUpdateTimer =
        Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_disposed) {
        timer.cancel();
        _participantUpdateTimer = null;
        return;
      }

      // CORREGIDO: Solo hacer polling si hay sala activa Y no estamos en proceso de destrucción
      if (_currentRoomId != null &&
          _socket != null &&
          _socket!.connected &&
          _participantCount > 0) {
        // CORREGIDO: Solo actualizar cada 10 segundos, no cada 5
        if (onRoomCreated != null) {
          // CORREGIDO: Crear lista de participantes falsos para que el modelo funcione
          final fakeParticipants =
              List.generate(_participantCount, (index) => 'participant_$index');

          final roomData = {
            'roomId': _currentRoomId,
            'participantCount': _participantCount,
            'participants':
                fakeParticipants, // CORREGIDO: Lista con el número correcto
            'encryptionKey': '', // Ya está establecida
            'createdAt': DateTime.now().toIso8601String(),
            'lastActivity': DateTime.now().toIso8601String(),
          };
          final room = EphemeralRoom.fromJson(roomData);
          onRoomCreated!(room);
        }
      } else {
        timer.cancel();
        _participantUpdateTimer = null;
      }
    });

    // NUEVO: Solicitar información inicial de la sala después de un breve delay
    if (_currentRoomId == null) {
      // Solo si no hay sala activa aún
      Future.delayed(const Duration(seconds: 2), () {
        if (_disposed) return; // Verificar antes de continuar

        if (_socket != null && _socket!.connected && _currentRoomId != null) {
          _socket!.emit('get-room-info', {'roomId': _currentRoomId});
        }
      });
    }
  }

  Future<void> acceptInvitation(String invitationId) async {
    if (_socket == null || !_socket!.connected) {
      throw Exception('No conectado al servidor de chat efímero');
    }

    _socket!.emit('accept-chat-invitation', {
      'invitationId': invitationId,
    });

    // NUEVO: Iniciar polling después de aceptar invitación
    _startParticipantPolling();
  }

  // NUEVO: Método para rechazar invitación informando al servidor
  Future<void> rejectInvitation(String invitationId) async {
    print('🔐 [CHAT-SERVICE] 🚫 Rechazando invitación: $invitationId');
    print('🔐 [CHAT-SERVICE] 🚫 Socket conectado: ${_socket?.connected}');
    print('🔐 [CHAT-SERVICE] 🚫 UserId: $_userId');

    if (_socket == null || !_socket!.connected) {
      print('🔐 [CHAT-SERVICE] ❌ No hay conexión para rechazar');
      throw Exception('No conectado al servidor de chat efímero');
    }

    _socket!.emit('reject-chat-invitation', {
      'invitationId': invitationId,
      'userId': _userId,
      'reason': 'declined_by_user',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    print('🔐 [CHAT-SERVICE] ✅ Evento de rechazo enviado');

    // NUEVO: Verificar estado del socket después del rechazo
    Future.delayed(const Duration(seconds: 1), () {
      if (_socket != null) {
        print(
            '🔐 [CHAT-SERVICE] 🔍 Estado post-rechazo - Conectado: ${_socket!.connected}');
        print('🔐 [CHAT-SERVICE] 🔍 Estado post-rechazo - ID: ${_socket!.id}');
      } else {
        print('🔐 [CHAT-SERVICE] ❌ Estado post-rechazo - Socket es null');
      }
    });
  }

  Future<void> sendMessage(String message,
      {int? destructionTimeMinutes}) async {
    // CORREGIDO: Verificación más robusta del estado
    if (_currentRoomId == null || _currentRoomId!.isEmpty) {
      throw Exception('No hay sala activa para enviar mensaje');
    }

    if (_encryptionService == null) {
      throw Exception('Cifrado no disponible');
    }

    try {
      // 🔐 CIFRADO HÍBRIDO: KYBER + XSalsa20-Poly1305
      Uint8List? encryptedBytes;
      bool kyberUsed = false;

      // Intentar usar Kyber para encapsular claves XSalsa20
      try {
        final encryptionStatus = _encryptionService!.getStatus();
        final kyberInfo = _encryptionService!.getKyberInfo();

        if (kyberInfo['kyberAvailable'] == true &&
            kyberInfo['postQuantumReady'] == true) {
          // 1. Generar clave maestra Kyber de 128 bytes (NO 8 bytes dummy!)
          final masterKey =
              await _encryptionService!.generateMasterKeyForKyber();
          // 2. Generar par de claves Kyber
          final kyberKeyPair = await _encryptionService!.generateKyberKeyPair();
          // 3. Encapsular clave maestra con Kyber (resistencia post-cuántica)
          final encapsulatedKey = await _encryptionService!
              .encapsulateWithKyber(masterKey, kyberKeyPair['publicKey']);
          // 4. Derivar clave XSalsa20 desde clave maestra Kyber
          await _encryptionService!.deriveSessionKeyFromShared(
              masterKey, 'ephemeral-chat-kyber-$_currentRoomId');
          // 5. Cifrar mensaje con XSalsa20 usando clave derivada de Kyber
          final messageBytes = utf8.encode(message);
          encryptedBytes = await _encryptionService!.encrypt(messageBytes);
          kyberUsed = true;
        } else {}
      } catch (kyberError) {
        kyberUsed = false;
      }

      // Fallback: XSalsa20 clásico si Kyber falla
      if (!kyberUsed) {
        final messageBytes = utf8.encode(message);
        encryptedBytes = await _encryptionService!.encrypt(messageBytes);
      }

      // 🔒 VALIDACIÓN CRÍTICA: "fallo mensaje sin Encriptar, no se puede enviar"
      if (encryptedBytes == null || encryptedBytes.isEmpty) {
        throw Exception('fallo mensaje sin Encriptar, no se puede enviar');
      }

      // Verificar que está realmente cifrado
      final originalBytes = utf8.encode(message);
      bool isEncrypted = encryptedBytes.length != originalBytes.length;
      if (!isEncrypted) {
        for (int i = 0;
            i < originalBytes.length && i < encryptedBytes.length;
            i++) {
          if (originalBytes[i] != encryptedBytes[i]) {
            isEncrypted = true;
            break;
          }
        }
      }

      if (!isEncrypted) {
        throw Exception('fallo mensaje sin Encriptar, no se puede enviar');
      }

      final encryptedMessage = base64Encode(encryptedBytes);

      final messageData = {
        'roomId': _currentRoomId,
        'encryptedMessage': encryptedMessage,
        'nonce': base64Encode(_generateNonce()),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'kyberUsed': kyberUsed,
        if (destructionTimeMinutes != null)
          'destructionTimeMinutes': destructionTimeMinutes,
      };

      _socket!.emit('send-encrypted-message', messageData);
    } catch (e) {
      if (onError != null) {
        onError!('Error enviando mensaje: $e');
      }
      rethrow;
    }
  }

  // 🎯 NUEVO: Método para enviar mensajes multimedia cifrados
  Future<void> sendEncryptedMessage({
    required String roomId,
    required String encryptedMessage,
    required String messageType,
    double? duration,
    Map<String, dynamic>? fileInfo,
    int? destructionTimeMinutes,
  }) async {
    if (_socket == null || !_socket!.connected) {
      throw Exception('No conectado al servidor de chat efímero');
    }

    try {
      final messageData = {
        'roomId': roomId,
        'encryptedMessage': encryptedMessage,
        'messageType': messageType,
        'nonce': base64Encode(_generateNonce()),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        if (duration != null) 'duration': duration,
        if (fileInfo != null) 'fileInfo': fileInfo,
        if (destructionTimeMinutes != null)
          'destructionTimeMinutes': destructionTimeMinutes,
      };

      // Usar evento específico según el tipo de mensaje
      String eventName;
      switch (messageType) {
        case 'audio':
          eventName = 'send-encrypted-audio';
          break;
        case 'image':
          eventName = 'send-encrypted-image';
          break;
        default:
          eventName = 'send-encrypted-message';
      }

      _socket!.emit(eventName, messageData);
    } catch (e) {
      if (onError != null) {
        onError!('Error enviando mensaje multimedia: $e');
      }
      rethrow;
    }
  }

  void leaveRoom() {
    if (_currentRoomId != null) {
      _socket!.emit('leave-room', {
        'roomId': _currentRoomId,
      });

      _currentRoomId = null;
      _encryptionService?.dispose();

      // NUEVO: Cancelar polling al salir de la sala
      _participantUpdateTimer?.cancel();
      _participantUpdateTimer = null;
    }
  }

  /// NUEVO: Destruir sala manualmente con contador
  void destroyRoomManually() {
    if (_currentRoomId != null) {
      _socket!.emit('destroy-room-manual', {
        'roomId': _currentRoomId,
        'reason': 'manual-destruction',
      });
    }
  }

  /// NUEVO: Iniciar contador de destrucción (envía notificación a ambos usuarios)
  void startDestructionCountdown() {
    if (_currentRoomId != null && _socket != null && _socket!.connected) {
      // CORREGIDO: Enviar comando real al servidor
      _socket!.emit('start-destruction-countdown', {
        'roomId': _currentRoomId,
        'countdown': 10,
        'initiatedBy': _userId ?? _tempIdentity,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      // CORREGIDO: NO simular - esperar respuesta real del servidor
      // El servidor debe enviar eventos 'destruction-countdown-started' y 'destruction-countdown-update'
    } else {
      if (onError != null) {
        onError!('No hay conexión activa para iniciar la destrucción');
      }
    }
  }

  /// NUEVO: Cancelar contador de destrucción
  void cancelDestructionCountdown() {
    if (_currentRoomId != null && _socket != null && _socket!.connected) {
      _socket!.emit('cancel-destruction-countdown', {
        'roomId': _currentRoomId,
        'cancelledBy': _userId ?? _tempIdentity,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    } else {}
  }

  /// NUEVO: Configurar autodestrucción automática de mensajes en el servidor
  void configureAutoDestruction(int destructionMinutes) {
    if (_currentRoomId != null && _socket != null && _socket!.connected) {
      // Determinar nombre de usuario para mostrar
      String userDisplayName = 'usuario';
      if (_userId != null && _userId!.isNotEmpty) {
        userDisplayName = _userId!;
      } else if (_tempIdentity != null && _tempIdentity!.isNotEmpty) {
        userDisplayName = _tempIdentity!;
      }

      _socket!.emit('configure-room-auto-destruction', {
        'roomId': _currentRoomId,
        'destructionMinutes': destructionMinutes,
        'configuredBy': userDisplayName,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    } else {}
  }

  Future<Map<String, dynamic>?> getRoomStats() async {
    if (_currentRoomId == null) return null;

    _socket!.emit('get-room-stats', {
      'roomId': _currentRoomId,
    });

    // En una implementación real, esperarías la respuesta
    return null;
  }

  Uint8List _generateNonce() {
    // Generar nonce de 12 bytes para ChaCha20-Poly1305
    final nonce = Uint8List(12);
    final now = DateTime.now().millisecondsSinceEpoch;

    for (int i = 0; i < 12; i++) {
      nonce[i] = (now >> (i * 8)) & 0xFF;
    }

    return nonce;
  }

  void dispose() {
    _disposed = true; // NUEVO: Marcar instancia como desechada
    // CORREGIDO: Limpiar TODOS los timers, incluyendo polling
    _participantUpdateTimer?.cancel();
    _participantUpdateTimer = null;

    // NUEVO: También limpiar timer de destrucción si existe
    _destructionTimer?.cancel();
    _destructionTimer = null;

    // CRÍTICO: NO limpiar onInvitationReceived si puede estar siendo usado por MainScreen
    // Solo limpiar si es una instancia de sesión temporal, no el servicio principal
    // onInvitationReceived = null; // COMENTADO: Causa problemas de callbacks perdidos
    onError = null;

    // MANTENER callbacks de destrucción activos solo si no se está desechando completamente:
    // - onDestructionCountdownStarted
    // - onDestructionCountdownUpdate
    // - onDestructionCountdownCancelled
    // - onRoomDestroyed
    // - onMessageReceived (para mensajes de destrucción)
    // - onRoomCreated
  }

  /// NUEVO: Método para desconectar completamente (solo para destrucción manual)
  void disconnectCompletely() {
    // Salir de la sala
    leaveRoom();

    // Desconectar socket
    if (_socket != null) {
      _socket!.disconnect();
      _socket = null;
    }

    // Limpiar cifrado
    _encryptionService?.dispose();
    _encryptionService = null;
  }

  // Getters para estado
  bool get hasActiveRoom => _currentRoomId != null && _participantCount > 0;
  String? get tempIdentity => _tempIdentity;

  /// NUEVO: Verificar si está listo para nueva sala
  bool get isReadyForNewRoom =>
      _socket != null && _socket!.connected && _encryptionService != null;

  // NUEVO: Método público para forzar actualización de participantes
  void forceUpdateParticipants() {
    if (_currentRoomId != null && _socket != null && _socket!.connected) {
      // NUEVO: Crear evento de sala actualizada con el contador local CORRECTO
      if (onRoomCreated != null && _participantCount > 0) {
        // CORREGIDO: Crear lista de participantes falsos para que el modelo funcione
        final fakeParticipants =
            List.generate(_participantCount, (index) => 'participant_$index');

        final roomData = {
          'roomId': _currentRoomId,
          'participantCount': _participantCount,
          'participants':
              fakeParticipants, // CORREGIDO: Lista con el número correcto
          'encryptionKey': '', // Ya está establecida
          'createdAt': DateTime.now().toIso8601String(),
          'lastActivity': DateTime.now().toIso8601String(),
        };
        final room = EphemeralRoom.fromJson(roomData);
        onRoomCreated!(room);
      } else {}

      // También intentar solicitar al servidor (por si acaso)
      _socket!.emit('get-room-info', {'roomId': _currentRoomId});
    }
  }

  /// NUEVO: Método para reinicializar el servicio después de desconexión
  Future<void> reinitialize({String? userId}) async {
    // Limpiar estado anterior
    _currentRoomId = null;
    _tempIdentity = null;
    _participantCount = 0;
    _participantUpdateTimer?.cancel();
    _participantUpdateTimer = null;

    // Desconectar socket anterior si existe
    if (_socket != null) {
      _socket!.disconnect();
      _socket = null;
    }

    // Reinicializar cifrado
    _encryptionService?.dispose();
    _encryptionService = EncryptionService();
    await _encryptionService!.initialize();

    // Reinicializar completamente
    await initialize(userId: userId);
  }

  /// NUEVO: Limpiar completamente el estado después de destrucción
  void _cleanupAfterDestruction() {
    // Cancelar timers
    _participantUpdateTimer?.cancel();
    _participantUpdateTimer = null;

    // Limpiar sala actual
    _currentRoomId = null;
    _participantCount = 0;

    // NUEVO: Desconectar socket para evitar reconexiones automáticas
    if (_socket != null) {
      _socket!.disconnect();
      _socket = null;
    }

    // Limpiar cifrado
    _encryptionService?.dispose();
    _encryptionService = null;
  }

  /// NUEVO: Verificar y reconectar si es necesario
  Future<bool> ensureConnection() async {
    if (_socket != null && _socket!.connected) {
      return true;
    }

    try {
      if (_socket != null) {
        _socket!.connect();

        // Esperar reconexión con timeout corto
        bool connected = false;
        int attempts = 0;
        const maxAttempts = 10; // 5 segundos

        while (!connected && attempts < maxAttempts) {
          await Future.delayed(const Duration(milliseconds: 500));
          connected = _socket!.connected;
          attempts++;
        }

        if (connected) {
          // Re-registrar usuario si es necesario
          if (_userId != null) {
            _socket!.emit('register-user', {'userId': _userId});
          }

          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// NUEVO: Aplicar automáticamente configuración por defecto cuando se une a nueva sala
  Future<void> _autoApplyDefaultDestruction() async {
    try {
      // Obtener servicio de preferencias
      final preferencesService = AutoDestructionPreferencesService();
      await preferencesService.initialize();

      // Verificar si debe auto-aplicar
      if (preferencesService.shouldAutoApplyDefault) {
        final defaultMinutes = preferencesService.defaultDestructionMinutes;

        if (defaultMinutes != null) {
          // Aplicar configuración después de un breve delay para asegurar que la sala esté lista
          Future.delayed(const Duration(milliseconds: 2000), () {
            if (_currentRoomId != null && !_disposed) {
              configureAutoDestruction(defaultMinutes);
            }
          });
        } else {}
      } else {}
    } catch (e) {}
  }

  /// NUEVO: Notificar que una sala fue destruida para limpiar invitaciones fantasma
  /// Esto previene que aparezcan invitaciones "fantasma" al volver al home
  void notifyRoomDestroyed(String targetUserId) {
    try {
      // Emitir evento al servidor para limpiar invitaciones pendientes de este usuario
      if (_socket != null && _socket!.connected && _userId != null) {
        _socket!.emit('cleanup-user-invitations', {
          'userId': _userId,
          'targetUserId': targetUserId,
          'reason': 'room_destroyed',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
      }
    } catch (e) {
      // Error silencioso - no queremos interrumpir el flujo de destrucción
    }
  }
}
