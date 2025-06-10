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
      print(
          '🔐 [EPHEMERAL-$_instanceId] === INICIANDO DIAGNÓSTICO COMPLETO ===');
      print(
          '🔐 [EPHEMERAL-$_instanceId] Inicializando servicio de chat efímero...');
      print('🔐 [EPHEMERAL-$_instanceId] UserId recibido: $userId');

      if (_disposed) {
        print(
            '🔐 [EPHEMERAL-$_instanceId] ⚠️ Instancia desechada, abortando inicialización');
        return;
      }

      _userId = userId;

      // Inicializar cifrado ChaCha20-Poly1305
      print('🔐 [EPHEMERAL-$_instanceId] Inicializando servicio de cifrado...');
      _encryptionService = EncryptionService();
      await _encryptionService!.initialize();
      print('🔐 [EPHEMERAL-$_instanceId] ✅ Servicio de cifrado inicializado');

      // NUEVO: Verificar si ya hay un socket conectado
      if (_socket != null && _socket!.connected) {
        print(
            '🔐 [EPHEMERAL-$_instanceId] ✅ Socket ya conectado, reutilizando conexión');

        // Solo registrar usuario si es necesario
        if (_userId != null) {
          print(
              '🔐 [EPHEMERAL-$_instanceId] Registrando usuario en socket existente: $_userId');
          _socket!.emit('register-user', {
            'userId': _userId,
          });
        }

        print(
            '🔐 [EPHEMERAL-$_instanceId] ✅ Servicio inicializado con socket existente');
        return;
      }

      // Conectar a servidor de chat efímero - CORREGIDO: usar path correcto
      print(
          '🔐 [EPHEMERAL-$_instanceId] Configurando conexión a: https://clubprivado.ws');
      print('🔐 [EPHEMERAL-$_instanceId] Path: /ephemeral-chat/socket.io');
      print('🔐 [EPHEMERAL-$_instanceId] Transports: [websocket, polling]');

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

      print('🔐 [EPHEMERAL-$_instanceId] ✅ Socket creado con configuración');
      print(
          '🔐 [EPHEMERAL-$_instanceId] Socket inicial conectado: ${_socket!.connected}');
      print('🔐 [EPHEMERAL-$_instanceId] Socket ID inicial: ${_socket!.id}');

      _setupSocketListeners();
      print('🔐 [EPHEMERAL-$_instanceId] ✅ Listeners configurados');

      print('🔐 [EPHEMERAL-$_instanceId] Intentando conectar al socket...');
      _socket!.connect();
      print('🔐 [EPHEMERAL-$_instanceId] ✅ Comando connect() ejecutado');

      // MEJORADO: Esperar conexión con timeout
      print(
          '🔐 [EPHEMERAL-$_instanceId] Esperando conexión con timeout de 10 segundos...');

      bool connected = false;
      int attempts = 0;
      const maxAttempts = 20; // 10 segundos (500ms * 20)

      while (!connected && attempts < maxAttempts && !_disposed) {
        await Future.delayed(const Duration(milliseconds: 500));
        connected = _socket!.connected;
        attempts++;

        if (attempts % 4 == 0) {
          // Log cada 2 segundos
          print(
              '🔐 [EPHEMERAL-$_instanceId] Intento ${attempts ~/ 4}/5 - Conectado: $connected');
        }
      }

      if (_disposed) {
        print(
            '🔐 [EPHEMERAL-$_instanceId] ⚠️ Instancia desechada durante conexión');
        return;
      }

      print('🔐 [EPHEMERAL-$_instanceId] === ESTADO DESPUÉS DE ESPERA ===');
      print('🔐 [EPHEMERAL-$_instanceId] - Socket existe: ${_socket != null}');
      print(
          '🔐 [EPHEMERAL-$_instanceId] - Socket conectado: ${_socket!.connected}');
      print('🔐 [EPHEMERAL-$_instanceId] - Socket ID: ${_socket!.id}');
      print('🔐 [EPHEMERAL-$_instanceId] - UserId configurado: $_userId');

      if (_socket!.connected) {
        print('🔐 [EPHEMERAL-$_instanceId] ✅ CONEXIÓN EXITOSA');
      } else {
        print(
            '🔐 [EPHEMERAL-$_instanceId] ❌ TIMEOUT DE CONEXIÓN - Socket no conectado después de 10 segundos');
        throw Exception('Timeout de conexión al servidor de chat efímero');
      }

      print(
          '🔐 [EPHEMERAL-$_instanceId] ✅ Servicio inicializado correctamente');
    } catch (e) {
      print('🔐 [EPHEMERAL-$_instanceId] ❌ Error inicializando: $e');
      print('🔐 [EPHEMERAL-$_instanceId] ❌ Stack trace: ${StackTrace.current}');
      if (onError != null) {
        onError!('Error inicializando chat efímero: $e');
      }
      rethrow;
    }
  }

  void _setupSocketListeners() {
    print('🔐 [EPHEMERAL-$_instanceId] === CONFIGURANDO LISTENERS ===');
    print('🔐 [EPHEMERAL-$_instanceId] Configurando listeners del socket...');

    _socket!.onConnect((_) {
      if (_disposed) return;

      print('🔐 [EPHEMERAL-$_instanceId] 🎉 ¡¡¡EVENTO CONNECT RECIBIDO!!!');
      print(
          '🔐 [EPHEMERAL-$_instanceId] ✅ Conectado al servidor de chat efímero');
      print('🔐 [EPHEMERAL-$_instanceId] Socket ID: ${_socket!.id}');
      print(
          '🔐 [EPHEMERAL-$_instanceId] Socket conectado: ${_socket!.connected}');

      // NUEVO: Registrar usuario para recibir invitaciones
      if (_userId != null) {
        print(
            '🔐 [EPHEMERAL-$_instanceId] Registrando usuario para invitaciones: $_userId');
        _socket!.emit('register-user', {
          'userId': _userId,
        });
        print(
            '🔐 [EPHEMERAL-$_instanceId] ✅ Evento register-user emitido al servidor');
        print(
            '🔐 [EPHEMERAL-$_instanceId] Usuario $_userId registrado para invitaciones');
      } else {
        print(
            '🔐 [EPHEMERAL-$_instanceId] ⚠️ No hay userId disponible para registrar');
      }

      print(
          '🔐 [EPHEMERAL-$_instanceId] Esperando asignación de identidad temporal del servidor...');
    });

    _socket!.onDisconnect((reason) {
      if (_disposed) return;

      print('🔐 [EPHEMERAL-$_instanceId] 💔 EVENTO DISCONNECT RECIBIDO');
      print('🔐 [EPHEMERAL-$_instanceId] ❌ Desconectado del servidor: $reason');
    });

    _socket!.onConnectError((error) {
      if (_disposed) return;

      print('🔐 [EPHEMERAL-$_instanceId] 🚨 EVENTO CONNECT_ERROR RECIBIDO');
      print('🔐 [EPHEMERAL-$_instanceId] ❌ Error de conexión: $error');
      print(
          '🔐 [EPHEMERAL-$_instanceId] ❌ Tipo de error: ${error.runtimeType}');
      print(
          '🔐 [EPHEMERAL-$_instanceId] ❌ Detalles del error: ${error.toString()}');
      if (onError != null) {
        onError!('Error de conexión: $error');
      }
    });

    // Agregar listener para eventos de debug
    _socket!.onAny((event, data) {
      if (_disposed) return;

      print('🔐 [EPHEMERAL-$_instanceId] 📡 EVENTO RECIBIDO: $event');
      print('🔐 [EPHEMERAL-$_instanceId] 📡 Datos: $data');
    });

    print('🔐 [EPHEMERAL-$_instanceId] ✅ Listener onConnect configurado');
    print('🔐 [EPHEMERAL-$_instanceId] ✅ Listener onDisconnect configurado');
    print('🔐 [EPHEMERAL-$_instanceId] ✅ Listener onConnectError configurado');
    print('🔐 [EPHEMERAL-$_instanceId] ✅ Listener onAny configurado');

    _socket!.on('chat-invitation-received', (data) {
      print('🔐 [EPHEMERAL-$_instanceId] Invitación de chat recibida: $data');

      // Verificar si la invitación es para este usuario
      if (data['targetUserId'] == _userId) {
        print(
            '🔐 [EPHEMERAL-$_instanceId] ✅ Invitación dirigida a este usuario');
        if (onInvitationReceived != null) {
          final invitation =
              ChatInvitation.fromJson(Map<String, dynamic>.from(data));
          onInvitationReceived!(invitation);
        }
      } else {
        print(
            '🔐 [EPHEMERAL-$_instanceId] ⚠️ Invitación no dirigida a este usuario (${data['targetUserId']} != $_userId)');
      }
    });

    _socket!.on('invitation-created', (data) {
      print(
          '🔐 [EPHEMERAL-$_instanceId] ✅ Invitación creada exitosamente: ${data['invitationId']}');
      print('🔐 [EPHEMERAL-$_instanceId] Expira en: ${data['expiresAt']}');
    });

    _socket!.on('invitation-rejected', (data) {
      print(
          '🔐 [EPHEMERAL-$_instanceId] ✅ Invitación rechazada confirmada: ${data['invitationId']}');
      print('🔐 [EPHEMERAL-$_instanceId] Razón: ${data['reason']}');
    });

    _socket!.on('room-created', (data) async {
      print('🔐 [EPHEMERAL-$_instanceId] === SALA CREADA - DEBUG COMPLETO ===');
      print('🔐 [EPHEMERAL-$_instanceId] Datos recibidos: $data');
      print('🔐 [EPHEMERAL-$_instanceId] roomId en datos: ${data['roomId']}');
      print('🔐 [EPHEMERAL-$_instanceId] id en datos: ${data['id']}');

      // CORREGIDO: Establecer roomId con múltiples verificaciones
      String? newRoomId = data['roomId'] ?? data['id'];

      if (newRoomId == null || newRoomId.isEmpty) {
        print(
            '🔐 [EPHEMERAL-$_instanceId] ❌ ERROR CRÍTICO: No se pudo obtener roomId de los datos');
        print('🔐 [EPHEMERAL-$_instanceId] Datos completos: $data');

        // Intentar extraer de otros campos posibles
        newRoomId = data['room']?['id'] ??
            data['room']?['roomId'] ??
            'emergency_room_${DateTime.now().millisecondsSinceEpoch}';
        print(
            '🔐 [EPHEMERAL-$_instanceId] ⚠️ Usando roomId de emergencia: $newRoomId');
      }

      _currentRoomId = newRoomId;
      print(
          '🔐 [EPHEMERAL-$_instanceId] ✅ _currentRoomId establecido: $_currentRoomId');

      // NUEVO: Extraer y guardar el contador de participantes
      if (data['participantCount'] != null) {
        _participantCount = data['participantCount'];
        print(
            '🔐 [EPHEMERAL-$_instanceId] ✅ Participantes detectados: $_participantCount');
      } else {
        // Si no viene en los datos, asumir 2 participantes por defecto
        _participantCount = 2;
        print(
            '🔐 [EPHEMERAL-$_instanceId] ⚠️ participantCount no encontrado, asumiendo 2');
      }

      // CORREGIDO: Verificar que el cifrado esté disponible antes de procesar clave
      if (_encryptionService == null) {
        print(
            '🔐 [EPHEMERAL-$_instanceId] ⚠️ Cifrado no disponible, reinicializando...');
        try {
          _encryptionService = EncryptionService();
          await _encryptionService!.initialize();
          print('🔐 [EPHEMERAL-$_instanceId] ✅ Cifrado reinicializado');
        } catch (e) {
          print(
              '🔐 [EPHEMERAL-$_instanceId] ❌ Error reinicializando cifrado: $e');
          if (onError != null) {
            onError!('Error inicializando cifrado: $e');
          }
          return;
        }
      }

      // Establecer clave de cifrado para la sala (128 bytes = 1024 bits)
      if (data['encryptionKey'] != null) {
        try {
          print(
              '🔐 [EPHEMERAL-$_instanceId] Procesando clave de 128 bytes (1024 bits)...');
          final masterKeyBytes = base64Decode(data['encryptionKey']);
          print(
              '🔐 [EPHEMERAL-$_instanceId] Clave maestra recibida: ${masterKeyBytes.length} bytes');

          // Derivar clave de sesión ChaCha20 (32 bytes) desde la clave maestra (128 bytes)
          // usando HKDF para máxima seguridad
          final sessionKey = await _encryptionService!
              .deriveSessionKeyFromShared(Uint8List.fromList(masterKeyBytes),
                  'ephemeral-chat-$_currentRoomId');

          await _encryptionService!.setSessionKey(sessionKey);
          print(
              '🔐 [EPHEMERAL-$_instanceId] ✅ Clave de sesión derivada y establecida (${sessionKey.length} bytes)');
          print(
              '🔐 [EPHEMERAL-$_instanceId] ✅ MÁXIMA SEGURIDAD: 1024 bits → 256 bits usando HKDF');
        } catch (e) {
          print('🔐 [EPHEMERAL-$_instanceId] ❌ Error estableciendo clave: $e');
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

        print('🔐 [EPHEMERAL-$_instanceId] === DEBUG ROOM DATA FINAL ===');
        print('🔐 [EPHEMERAL-$_instanceId] roomData[id]: ${roomData['id']}');
        print(
            '🔐 [EPHEMERAL-$_instanceId] roomData[roomId]: ${roomData['roomId']}');
        print('🔐 [EPHEMERAL-$_instanceId] _currentRoomId: $_currentRoomId');

        final room = EphemeralRoom.fromJson(roomData);
        print('🔐 [EPHEMERAL-$_instanceId] ✅ Sala creada con ID: ${room.id}');
        onRoomCreated!(room);
      }

      // NUEVO: APLICAR AUTO-CONFIGURACIÓN POR DEFECTO AQUÍ
      print(
          '🔐 [EPHEMERAL-$_instanceId] 🔥 Verificando auto-aplicar configuración por defecto después de crear sala...');
      _autoApplyDefaultDestruction();

      // NUEVO: Solicitar información actualizada de la sala después de crearla
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (_currentRoomId != null && _socket != null && _socket!.connected) {
          print(
              '🔐 [EPHEMERAL-$_instanceId] Solicitando info actualizada de sala recién creada');
          _socket!.emit('get-room-info', {'roomId': _currentRoomId});
        }
      });

      // NUEVO: Iniciar polling para mantener actualizado el contador
      _startParticipantPolling();

      print('🔐 [EPHEMERAL-$_instanceId] === FIN SALA CREADA ===');
    });

    // NUEVO: Escuchar actualizaciones de participantes
    _socket!.on('room-updated', (data) {
      print('🔐 [EPHEMERAL-$_instanceId] Sala actualizada: $data');
      if (onRoomCreated != null && data['roomId'] == _currentRoomId) {
        final room = EphemeralRoom.fromJson(Map<String, dynamic>.from(data));
        onRoomCreated!(room); // Reutilizar el callback para actualizar la UI
      }
    });

    _socket!.on('user-joined', (data) {
      print('🔐 [EPHEMERAL-$_instanceId] Usuario se unió a la sala: $data');
      // Solicitar estadísticas actualizadas de la sala
      if (_currentRoomId != null) {
        _socket!.emit('get-room-info', {'roomId': _currentRoomId});
      }
    });

    _socket!.on('user-left', (data) {
      print('🔐 [EPHEMERAL-$_instanceId] Usuario salió de la sala: $data');
      // Solicitar estadísticas actualizadas de la sala
      if (_currentRoomId != null) {
        _socket!.emit('get-room-info', {'roomId': _currentRoomId});
      }
    });

    _socket!.on('room-info', (data) {
      print('🔐 [EPHEMERAL-$_instanceId] Info de sala recibida: $data');
      if (onRoomCreated != null && data['roomId'] == _currentRoomId) {
        final room = EphemeralRoom.fromJson(Map<String, dynamic>.from(data));
        onRoomCreated!(room); // Actualizar la UI con la nueva info
      }
    });

    _socket!.on('encrypted-message-received', (data) async {
      try {
        print('🔐 [EPHEMERAL-$_instanceId] === MENSAJE CIFRADO RECIBIDO ===');
        print('🔐 [EPHEMERAL-$_instanceId] Datos completos: $data');
        print(
            '🔐 [EPHEMERAL-$_instanceId] RoomId del mensaje: ${data['roomId']}');
        print('🔐 [EPHEMERAL-$_instanceId] RoomId actual: $_currentRoomId');
        print('🔐 [EPHEMERAL-$_instanceId] SenderId: ${data['senderId']}');
        print(
            '🔐 [EPHEMERAL-$_instanceId] DestructionTimeMinutes: ${data['destructionTimeMinutes']}');

        // CORREGIDO: Verificar que el mensaje es para la sala correcta
        if (data['roomId'] != _currentRoomId) {
          print(
              '🔐 [EPHEMERAL-$_instanceId] ⚠️ Mensaje para sala diferente - ignorando');
          print(
              '🔐 [EPHEMERAL-$_instanceId] Esperado: $_currentRoomId, Recibido: ${data['roomId']}');
          return;
        }

        // Descifrar mensaje
        final encryptedBytes = base64Decode(data['encryptedMessage']);
        print(
            '🔐 [EPHEMERAL-$_instanceId] Descifrando ${encryptedBytes.length} bytes...');

        final decryptedBytes =
            await _encryptionService!.decrypt(encryptedBytes);
        final message = utf8.decode(decryptedBytes);

        print('🔐 [EPHEMERAL-$_instanceId] ✅ Mensaje descifrado: "$message"');

        final decryptedData = {
          ...Map<String, dynamic>.from(data),
          'message': message,
          'content': message, // CORREGIDO: Agregar campo 'content' también
          // NUEVO: Preservar destructionTimeMinutes para sincronización
          if (data['destructionTimeMinutes'] != null)
            'destructionTimeMinutes': data['destructionTimeMinutes'],
        };

        print(
            '🔐 [EPHEMERAL-$_instanceId] Datos del mensaje procesado: $decryptedData');

        if (onMessageReceived != null) {
          final messageObj = EphemeralMessage.fromJson(decryptedData);
          print(
              '🔐 [EPHEMERAL-$_instanceId] ✅ Objeto mensaje creado - ejecutando callback');
          print(
              '🔐 [EPHEMERAL-$_instanceId] ⏰ Destrucción sincronizada: ${messageObj.destructionTime}');
          onMessageReceived!(messageObj);
        } else {
          print(
              '🔐 [EPHEMERAL-$_instanceId] ❌ onMessageReceived callback es null');
        }
      } catch (e) {
        print('🔐 [EPHEMERAL-$_instanceId] ❌ Error descifrando mensaje: $e');
        print(
            '🔐 [EPHEMERAL-$_instanceId] ❌ Stack trace: ${StackTrace.current}');
        if (onError != null) {
          onError!('Error descifrando mensaje: $e');
        }
      }
    });

    _socket!.on('room-destroyed', (data) {
      print('🔐 [EPHEMERAL-$_instanceId] 🎯 EVENTO: room-destroyed');
      print('🔐 [EPHEMERAL-$_instanceId] Datos recibidos: $data');
      print('🔐 [EPHEMERAL-$_instanceId] Sala destruida: ${data['roomId']}');
      print('🔐 [EPHEMERAL-$_instanceId] Razón: ${data['reason']}');
      print(
          '🔐 [EPHEMERAL-$_instanceId] onRoomDestroyed callback existe: ${onRoomDestroyed != null}');

      // CORREGIDO: Limpiar estado local INMEDIATAMENTE
      final destroyedRoomId = _currentRoomId;
      _currentRoomId = null;
      _participantCount = 0;

      // CORREGIDO: Cancelar polling inmediatamente
      _participantUpdateTimer?.cancel();
      _participantUpdateTimer = null;

      // CORREGIDO: Limpiar cifrado
      try {
        _encryptionService?.dispose();
        _encryptionService = null;
      } catch (e) {
        print('🔐 [EPHEMERAL-$_instanceId] ⚠️ Error limpiando cifrado: $e');
      }

      print(
          '🔐 [EPHEMERAL-$_instanceId] Estado limpiado - sala $destroyedRoomId destruida');

      if (onRoomDestroyed != null) {
        print(
            '🔐 [EPHEMERAL-$_instanceId] ✅ Ejecutando callback onRoomDestroyed...');
        try {
          onRoomDestroyed!();
          print(
              '🔐 [EPHEMERAL-$_instanceId] ✅ Callback onRoomDestroyed ejecutado exitosamente');
        } catch (e) {
          print(
              '🔐 [EPHEMERAL-$_instanceId] ❌ Error ejecutando callback onRoomDestroyed: $e');
        }
      } else {
        print(
            '🔐 [EPHEMERAL-$_instanceId] ⚠️ onRoomDestroyed callback es null - no se puede ejecutar');
      }

      // CORREGIDO: Reinicializar cifrado para próxima sala
      Future.delayed(const Duration(milliseconds: 500), () async {
        try {
          print(
              '🔐 [EPHEMERAL-$_instanceId] 🔄 Reinicializando cifrado para próxima sala...');
          _encryptionService = EncryptionService();
          await _encryptionService!.initialize();
          print(
              '🔐 [EPHEMERAL-$_instanceId] ✅ Cifrado reinicializado correctamente');
        } catch (e) {
          print(
              '🔐 [EPHEMERAL-$_instanceId] ❌ Error reinicializando cifrado: $e');
        }
      });
    });

    _socket!.on('error', (data) {
      print('🔐 [EPHEMERAL-$_instanceId] Error del servidor: $data');
      if (onError != null) {
        onError!(data['message'] ?? 'Error desconocido');
      }
    });

    // CORREGIDO: También aplicar cuando alguien acepta una invitación y se une a la sala
    _socket!.on('invitation-accepted', (data) {
      print('🔐 [EPHEMERAL-$_instanceId] Invitación aceptada: $data');

      // NUEVO: APLICAR AUTO-CONFIGURACIÓN POR DEFECTO AQUÍ TAMBIÉN
      print(
          '🔐 [EPHEMERAL-$_instanceId] 🔥 Verificando auto-aplicar configuración por defecto después de aceptar invitación...');
      _autoApplyDefaultDestruction();

      // Solicitar información actualizada de la sala
      if (_currentRoomId != null) {
        print(
            '🔐 [EPHEMERAL-$_instanceId] Solicitando info actualizada después de aceptar invitación');
        _socket!.emit('get-room-info', {'roomId': _currentRoomId});
      }
    });

    // NUEVO: Listener para destrucción manual
    _socket!.on('destruction-countdown-started', (data) {
      print(
          '🔐 [EPHEMERAL-$_instanceId] 🎯 EVENTO: destruction-countdown-started');
      print('🔐 [EPHEMERAL-$_instanceId] Datos: $data');

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
      print(
          '🔐 [EPHEMERAL-$_instanceId] 🎯 EVENTO: destruction-countdown-update');
      print('🔐 [EPHEMERAL-$_instanceId] Countdown: ${data['countdown']}');

      if (onDestructionCountdownUpdate != null) {
        onDestructionCountdownUpdate!(data['countdown'] ?? 0);
      }
    });

    _socket!.on('destruction-countdown-cancelled', (data) {
      print(
          '🔐 [EPHEMERAL-$_instanceId] 🎯 EVENTO: destruction-countdown-cancelled');
      print('🔐 [EPHEMERAL-$_instanceId] Datos: $data');

      if (onDestructionCountdownCancelled != null) {
        onDestructionCountdownCancelled!();
      }
    });

    // NUEVO: Listener para autodestrucción automática de mensajes desde servidor
    _socket!.on('auto-destroy-messages', (data) {
      print(
          '🔐 [EPHEMERAL-$_instanceId] 🧹 EVENTO: auto-destroy-messages desde servidor');
      print(
          '🔐 [EPHEMERAL-$_instanceId] Configuración: ${data['destructionMinutes']} minutos');

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
      print(
          '🔐 [EPHEMERAL-$_instanceId] ⚙️ EVENTO: auto-destruction-configured');
      print(
          '🔐 [EPHEMERAL-$_instanceId] Configuración: ${data['destructionMinutes']} minutos');
      print(
          '🔐 [EPHEMERAL-$_instanceId] Configurado por: ${data['configuredBy']}');

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
    print(
        '🔐 [EPHEMERAL-$_instanceId] === DIAGNÓSTICO COMPLETO DE INVITACIÓN ===');
    print('🔐 [EPHEMERAL-$_instanceId] Método createChatInvitation llamado');
    print('🔐 [EPHEMERAL-$_instanceId] Target UserId: $targetUserId');
    print('🔐 [EPHEMERAL-$_instanceId] Socket existe: ${_socket != null}');
    print(
        '🔐 [EPHEMERAL-$_instanceId] Socket conectado: ${_socket?.connected ?? false}');
    print('🔐 [EPHEMERAL-$_instanceId] Socket ID: ${_socket?.id}');
    print('🔐 [EPHEMERAL-$_instanceId] UserId actual: $_userId');
    print(
        '🔐 [EPHEMERAL-$_instanceId] Cifrado listo: ${_encryptionService != null}');
    print('🔐 [EPHEMERAL-$_instanceId] Servicio listo: $isReadyForNewRoom');

    // NUEVO: Verificar y asegurar conexión antes de proceder
    if (!await ensureConnection()) {
      print(
          '❌ [EPHEMERAL-$_instanceId] FALLO CRÍTICO: No se pudo establecer conexión');
      throw Exception('No se pudo conectar al servidor de chat efímero');
    }

    // NUEVO: Verificar que el cifrado esté listo
    if (_encryptionService == null) {
      print(
          '❌ [EPHEMERAL-$_instanceId] FALLO CRÍTICO: Cifrado no inicializado');
      throw Exception('Servicio de cifrado no disponible');
    }

    print(
        '🔐 [EPHEMERAL-$_instanceId] ✅ Validaciones pasadas - procediendo a crear invitación');
    print(
        '🔐 [EPHEMERAL-$_instanceId] Creando invitación para usuario: $targetUserId');

    // Enviar evento al servidor
    print(
        '🔐 [EPHEMERAL-$_instanceId] Emitiendo evento create-chat-invitation...');
    _socket!.emit('create-chat-invitation', {
      'targetUserId': targetUserId,
    });

    print(
        '🔐 [EPHEMERAL-$_instanceId] ✅ Evento create-chat-invitation emitido al servidor');
    print(
        '🔐 [EPHEMERAL-$_instanceId] Datos enviados: {targetUserId: $targetUserId}');

    // NUEVO: Iniciar polling de participantes después de crear invitación
    _startParticipantPolling();

    print('🔐 [EPHEMERAL-$_instanceId] === FIN DIAGNÓSTICO DE INVITACIÓN ===');
  }

  // NUEVO: Método para iniciar polling de participantes
  void _startParticipantPolling() {
    if (_disposed) {
      print(
          '🔐 [EPHEMERAL-$_instanceId] ⚠️ Instancia desechada, no iniciar polling');
      return;
    }

    print(
        '🔐 [EPHEMERAL-$_instanceId] 🔄 Iniciando polling de participantes...');

    // Cancelar timer anterior si existe
    _participantUpdateTimer?.cancel();

    // NUEVO: Timer para simular actualizaciones de participantes cada 10 segundos
    _participantUpdateTimer =
        Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_disposed) {
        print(
            '🔐 [EPHEMERAL-$_instanceId] ⚠️ Instancia desechada, deteniendo polling');
        timer.cancel();
        _participantUpdateTimer = null;
        return;
      }

      // NUEVO: Debug completo del estado
      print('🔐 [EPHEMERAL-$_instanceId] === DEBUG POLLING ===');
      print('🔐 [EPHEMERAL-$_instanceId] _currentRoomId: $_currentRoomId');
      print(
          '🔐 [EPHEMERAL-$_instanceId] _participantCount: $_participantCount');
      print(
          '🔐 [EPHEMERAL-$_instanceId] Socket conectado: ${_socket?.connected}');
      print(
          '🔐 [EPHEMERAL-$_instanceId] onRoomCreated != null: ${onRoomCreated != null}');

      // CORREGIDO: Solo hacer polling si hay sala activa Y no estamos en proceso de destrucción
      if (_currentRoomId != null &&
          _socket != null &&
          _socket!.connected &&
          _participantCount > 0) {
        // CORREGIDO: Solo actualizar cada 10 segundos, no cada 5
        print(
            '🔐 [EPHEMERAL-$_instanceId] 📊 Actualizando con contador local: $_participantCount participantes');

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
        print(
            '🔐 [EPHEMERAL-$_instanceId] ⏹️ Deteniendo polling - no hay sala activa');
        print(
            '🔐 [EPHEMERAL-$_instanceId] Razón: _currentRoomId=$_currentRoomId, connected=${_socket?.connected}, participantCount=$_participantCount');
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
          print(
              '🔐 [EPHEMERAL-$_instanceId] 📊 Solicitud inicial al servidor...');
          _socket!.emit('get-room-info', {'roomId': _currentRoomId});
        }
      });
    }
  }

  Future<void> acceptInvitation(String invitationId) async {
    if (_socket == null || !_socket!.connected) {
      throw Exception('No conectado al servidor de chat efímero');
    }

    print('🔐 [EPHEMERAL-$_instanceId] Aceptando invitación: $invitationId');

    _socket!.emit('accept-chat-invitation', {
      'invitationId': invitationId,
    });

    // NUEVO: Iniciar polling después de aceptar invitación
    _startParticipantPolling();
  }

  // NUEVO: Método para rechazar invitación informando al servidor
  Future<void> rejectInvitation(String invitationId) async {
    if (_socket == null || !_socket!.connected) {
      throw Exception('No conectado al servidor de chat efímero');
    }

    print('🔐 [EPHEMERAL-$_instanceId] Rechazando invitación: $invitationId');

    _socket!.emit('reject-chat-invitation', {
      'invitationId': invitationId,
      'userId': _userId,
      'reason': 'declined_by_user',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    print(
        '🔐 [EPHEMERAL-$_instanceId] ✅ Invitación rechazada en servidor: $invitationId');
  }

  Future<void> sendMessage(String message,
      {int? destructionTimeMinutes}) async {
    // CORREGIDO: Verificación más robusta del estado
    if (_currentRoomId == null || _currentRoomId!.isEmpty) {
      print(
          '🔐 [EPHEMERAL-$_instanceId] ❌ ERROR CRÍTICO: No hay sala activa para enviar mensaje');
      print('🔐 [EPHEMERAL-$_instanceId] _currentRoomId: $_currentRoomId');
      throw Exception('No hay sala activa para enviar mensaje');
    }

    if (_encryptionService == null) {
      print(
          '🔐 [EPHEMERAL-$_instanceId] ❌ ERROR CRÍTICO: Cifrado no disponible');
      throw Exception('Cifrado no disponible');
    }

    try {
      print('🔐 [EPHEMERAL-$_instanceId] === ENVIANDO MENSAJE ===');
      print('🔐 [EPHEMERAL-$_instanceId] Mensaje: "$message"');
      print(
          '🔐 [EPHEMERAL-$_instanceId] Destrucción en: ${destructionTimeMinutes ?? "sin límite"} minutos');
      print('🔐 [EPHEMERAL-$_instanceId] Sala: $_currentRoomId');
      print(
          '🔐 [EPHEMERAL-$_instanceId] Socket conectado: ${_socket?.connected}');

      // 🔐 CIFRADO HÍBRIDO: KYBER + XSalsa20-Poly1305
      print('🔐 [EPHEMERAL-$_instanceId] === INICIANDO CIFRADO HÍBRIDO ===');

      Uint8List? encryptedBytes;
      bool kyberUsed = false;

      // Intentar usar Kyber para encapsular claves XSalsa20
      try {
        final encryptionStatus = _encryptionService!.getStatus();
        final kyberInfo = _encryptionService!.getKyberInfo();

        print(
            '🔐 [EPHEMERAL-$_instanceId] 📊 Estado cifrado: ${encryptionStatus['initialized']}');
        print(
            '🔐 [EPHEMERAL-$_instanceId] 🔮 Kyber disponible: ${kyberInfo['kyberAvailable']}');

        if (kyberInfo['kyberAvailable'] == true &&
            kyberInfo['postQuantumReady'] == true) {
          print(
              '🔐 [EPHEMERAL-$_instanceId] 🔮 === USANDO KYBER PARA ENCAPSULAR CLAVES XSalsa20 ===');

          // 1. Generar clave maestra Kyber de 128 bytes (NO 8 bytes dummy!)
          final masterKey =
              await _encryptionService!.generateMasterKeyForKyber();
          print(
              '🔐 [EPHEMERAL-$_instanceId] 🔑 Clave maestra Kyber generada: ${masterKey.length} bytes');

          // 2. Generar par de claves Kyber
          final kyberKeyPair = await _encryptionService!.generateKyberKeyPair();
          print('🔐 [EPHEMERAL-$_instanceId] 🔑 Par Kyber generado');

          // 3. Encapsular clave maestra con Kyber (resistencia post-cuántica)
          print(
              '🔐 [EPHEMERAL-$_instanceId] 🔮 === ENCAPSULANDO CLAVE XSalsa20 CON KYBER ===');
          final encapsulatedKey = await _encryptionService!
              .encapsulateWithKyber(masterKey, kyberKeyPair['publicKey']);
          print(
              '🔐 [EPHEMERAL-$_instanceId] ✅ CLAVE XSalsa20 ENCAPSULADA CON KYBER');

          // 4. Derivar clave XSalsa20 desde clave maestra Kyber
          await _encryptionService!.deriveSessionKeyFromShared(
              masterKey, 'ephemeral-chat-kyber-$_currentRoomId');
          print(
              '🔐 [EPHEMERAL-$_instanceId] 🔐 Clave XSalsa20 derivada desde Kyber');

          // 5. Cifrar mensaje con XSalsa20 usando clave derivada de Kyber
          final messageBytes = utf8.encode(message);
          encryptedBytes = await _encryptionService!.encrypt(messageBytes);
          kyberUsed = true;

          print(
              '🔐 [EPHEMERAL-$_instanceId] ✅ MENSAJE CIFRADO: KYBER+XSalsa20');
          print(
              '🔐 [EPHEMERAL-$_instanceId] 🛡️ RESISTENCIA POST-CUÁNTICA: ACTIVA');
        } else {
          print(
              '🔐 [EPHEMERAL-$_instanceId] ℹ️ Kyber no disponible - usando XSalsa20 solo');
        }
      } catch (kyberError) {
        print('🔐 [EPHEMERAL-$_instanceId] ⚠️ Error Kyber: $kyberError');
        kyberUsed = false;
      }

      // Fallback: XSalsa20 clásico si Kyber falla
      if (!kyberUsed) {
        print(
            '🔐 [EPHEMERAL-$_instanceId] 🔐 === CIFRADO XSalsa20 CLÁSICO ===');
        final messageBytes = utf8.encode(message);
        encryptedBytes = await _encryptionService!.encrypt(messageBytes);
        print('🔐 [EPHEMERAL-$_instanceId] ✅ Cifrado clásico aplicado');
      }

      // 🔒 VALIDACIÓN CRÍTICA: "fallo mensaje sin Encriptar, no se puede enviar"
      if (encryptedBytes == null || encryptedBytes.isEmpty) {
        print(
            '🔐 [EPHEMERAL-$_instanceId] ❌ fallo mensaje sin Encriptar, no se puede enviar');
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
        print(
            '🔐 [EPHEMERAL-$_instanceId] ❌ fallo mensaje sin Encriptar, no se puede enviar');
        throw Exception('fallo mensaje sin Encriptar, no se puede enviar');
      }

      print(
          '🔐 [EPHEMERAL-$_instanceId] ✅ MENSAJE VALIDADO Y CIFRADO CORRECTAMENTE');
      print(
          '🔐 [EPHEMERAL-$_instanceId] 🔮 Protección post-cuántica: ${kyberUsed ? "ACTIVA" : "CLÁSICA"}');

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

      print(
          '🔐 [EPHEMERAL-$_instanceId] Datos del mensaje a enviar: $messageData');

      _socket!.emit('send-encrypted-message', messageData);

      print(
          '🔐 [EPHEMERAL-$_instanceId] ✅ Mensaje enviado y cifrado correctamente');
    } catch (e) {
      print('🔐 [EPHEMERAL-$_instanceId] ❌ Error enviando mensaje: $e');
      print('🔐 [EPHEMERAL-$_instanceId] ❌ Stack trace: ${StackTrace.current}');
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
      print('🎯 [EPHEMERAL-$_instanceId] === ENVIANDO MENSAJE MULTIMEDIA ===');
      print('🎯 [EPHEMERAL-$_instanceId] Tipo: $messageType');
      print('🎯 [EPHEMERAL-$_instanceId] Sala: $roomId');
      print('🎯 [EPHEMERAL-$_instanceId] Duración: ${duration ?? "N/A"}s');

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

      print('🎯 [EPHEMERAL-$_instanceId] Evento: $eventName');
      _socket!.emit(eventName, messageData);

      print(
          '🎯 [EPHEMERAL-$_instanceId] ✅ Mensaje multimedia enviado correctamente');
    } catch (e) {
      print(
          '🎯 [EPHEMERAL-$_instanceId] ❌ Error enviando mensaje multimedia: $e');
      if (onError != null) {
        onError!('Error enviando mensaje multimedia: $e');
      }
      rethrow;
    }
  }

  void leaveRoom() {
    if (_currentRoomId != null) {
      print('🔐 [EPHEMERAL-$_instanceId] Saliendo de la sala: $_currentRoomId');

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
      print(
          '🔐 [EPHEMERAL-$_instanceId] 🗑️ Destruyendo sala manualmente: $_currentRoomId');

      _socket!.emit('destroy-room-manual', {
        'roomId': _currentRoomId,
        'reason': 'manual-destruction',
      });

      print(
          '🔐 [EPHEMERAL-$_instanceId] ✅ Comando de destrucción manual enviado al servidor');
    }
  }

  /// NUEVO: Iniciar contador de destrucción (envía notificación a ambos usuarios)
  void startDestructionCountdown() {
    if (_currentRoomId != null && _socket != null && _socket!.connected) {
      print(
          '🔐 [EPHEMERAL-$_instanceId] ⏰ Iniciando contador de destrucción para sala: $_currentRoomId');

      // CORREGIDO: Enviar comando real al servidor
      _socket!.emit('start-destruction-countdown', {
        'roomId': _currentRoomId,
        'countdown': 10,
        'initiatedBy': _userId ?? _tempIdentity,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      print(
          '🔐 [EPHEMERAL-$_instanceId] ✅ Comando de destrucción enviado al servidor');
      print('🔐 [EPHEMERAL-$_instanceId] - Sala: $_currentRoomId');
      print(
          '🔐 [EPHEMERAL-$_instanceId] - Iniciado por: ${_userId ?? _tempIdentity}');

      // CORREGIDO: NO simular - esperar respuesta real del servidor
      // El servidor debe enviar eventos 'destruction-countdown-started' y 'destruction-countdown-update'
    } else {
      print(
          '🔐 [EPHEMERAL-$_instanceId] ❌ No se puede iniciar destrucción - sin conexión o sala');
      if (onError != null) {
        onError!('No hay conexión activa para iniciar la destrucción');
      }
    }
  }

  /// NUEVO: Cancelar contador de destrucción
  void cancelDestructionCountdown() {
    if (_currentRoomId != null && _socket != null && _socket!.connected) {
      print('🔐 [EPHEMERAL-$_instanceId] ❌ Cancelando contador de destrucción');

      _socket!.emit('cancel-destruction-countdown', {
        'roomId': _currentRoomId,
        'cancelledBy': _userId ?? _tempIdentity,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      print(
          '🔐 [EPHEMERAL-$_instanceId] ✅ Comando de cancelación enviado al servidor');
    } else {
      print(
          '🔐 [EPHEMERAL-$_instanceId] ❌ No se puede cancelar destrucción - sin conexión o sala');
    }
  }

  /// NUEVO: Configurar autodestrucción automática de mensajes en el servidor
  void configureAutoDestruction(int destructionMinutes) {
    if (_currentRoomId != null && _socket != null && _socket!.connected) {
      print(
          '🔐 [EPHEMERAL-$_instanceId] ⚙️ Configurando autodestrucción automática: $destructionMinutes minutos');

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

      print(
          '🔐 [EPHEMERAL-$_instanceId] ✅ Configuración de autodestrucción enviada al servidor');
      print('🔐 [EPHEMERAL-$_instanceId] - Sala: $_currentRoomId');
      print('🔐 [EPHEMERAL-$_instanceId] - Configurado por: $userDisplayName');
      print(
          '🔐 [EPHEMERAL-$_instanceId] - Destrucción cada: $destructionMinutes minutos');
    } else {
      print(
          '🔐 [EPHEMERAL-$_instanceId] ❌ No se puede configurar autodestrucción - sin conexión o sala');
    }
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
    print('🔐 [EPHEMERAL-$_instanceId] Limpiando recursos...');

    // CORREGIDO: Limpiar TODOS los timers, incluyendo polling
    _participantUpdateTimer?.cancel();
    _participantUpdateTimer = null;

    // NUEVO: También limpiar timer de destrucción si existe
    _destructionTimer?.cancel();
    _destructionTimer = null;

    print('🔐 [EPHEMERAL-$_instanceId] ⚠️ Instancia marcada como DESECHADA');
    print('🔐 [EPHEMERAL-$_instanceId] ✅ Todos los timers cancelados');

    // CRÍTICO: NO limpiar onInvitationReceived si puede estar siendo usado por MainScreen
    // Solo limpiar si es una instancia de sesión temporal, no el servicio principal
    print(
        '🔐 [EPHEMERAL-$_instanceId] ⚠️ DISPOSE: Preservando onInvitationReceived para MainScreen');
    // onInvitationReceived = null; // COMENTADO: Causa problemas de callbacks perdidos
    onError = null;

    // MANTENER callbacks de destrucción activos solo si no se está desechando completamente:
    // - onDestructionCountdownStarted
    // - onDestructionCountdownUpdate
    // - onDestructionCountdownCancelled
    // - onRoomDestroyed
    // - onMessageReceived (para mensajes de destrucción)
    // - onRoomCreated

    print(
        '🔐 [EPHEMERAL-$_instanceId] ✅ Recursos locales limpiados - instancia DESECHADA');
  }

  /// NUEVO: Método para desconectar completamente (solo para destrucción manual)
  void disconnectCompletely() {
    print('🔐 [EPHEMERAL-$_instanceId] 🗑️ Desconectando completamente...');

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

    print('🔐 [EPHEMERAL-$_instanceId] ✅ Desconexión completa realizada');
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
      print(
          '🔐 [EPHEMERAL-$_instanceId] 🔄 Forzando actualización de participantes desde UI...');

      // NUEVO: Crear evento de sala actualizada con el contador local CORRECTO
      if (onRoomCreated != null && _participantCount > 0) {
        print(
            '🔐 [EPHEMERAL-$_instanceId] ✅ Usando contador local: $_participantCount participantes');

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
      } else {
        print(
            '🔐 [EPHEMERAL-$_instanceId] ⚠️ No hay participantes o sala para actualizar');
      }

      // También intentar solicitar al servidor (por si acaso)
      _socket!.emit('get-room-info', {'roomId': _currentRoomId});
    }
  }

  /// NUEVO: Método para reinicializar el servicio después de desconexión
  Future<void> reinitialize({String? userId}) async {
    print(
        '🔐 [EPHEMERAL-$_instanceId] 🔄 Reinicializando servicio después de desconexión...');

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

    print(
        '🔐 [EPHEMERAL-$_instanceId] ✅ Servicio reinicializado correctamente');
  }

  /// NUEVO: Limpiar completamente el estado después de destrucción
  void _cleanupAfterDestruction() {
    print(
        '🔐 [EPHEMERAL-$_instanceId] 🧹 Limpiando estado después de destrucción...');

    // Cancelar timers
    _participantUpdateTimer?.cancel();
    _participantUpdateTimer = null;

    // Limpiar sala actual
    _currentRoomId = null;
    _participantCount = 0;

    // NUEVO: Desconectar socket para evitar reconexiones automáticas
    if (_socket != null) {
      print(
          '🔐 [EPHEMERAL-$_instanceId] 🔌 Desconectando socket después de destrucción');
      _socket!.disconnect();
      _socket = null;
    }

    // Limpiar cifrado
    _encryptionService?.dispose();
    _encryptionService = null;

    print(
        '🔐 [EPHEMERAL-$_instanceId] ✅ Estado limpiado completamente - sala destruida');
  }

  /// NUEVO: Verificar y reconectar si es necesario
  Future<bool> ensureConnection() async {
    if (_socket != null && _socket!.connected) {
      print(
          '🔐 [EPHEMERAL-$_instanceId] ✅ Conexión verificada - socket activo');
      return true;
    }

    print(
        '🔐 [EPHEMERAL-$_instanceId] ⚠️ Socket desconectado, intentando reconectar...');

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
          print('🔐 [EPHEMERAL-$_instanceId] ✅ Reconexión exitosa');

          // Re-registrar usuario si es necesario
          if (_userId != null) {
            _socket!.emit('register-user', {'userId': _userId});
          }

          return true;
        } else {
          print('🔐 [EPHEMERAL-$_instanceId] ❌ Timeout en reconexión');
          return false;
        }
      } else {
        print(
            '🔐 [EPHEMERAL-$_instanceId] ❌ Socket es null, requiere reinicialización completa');
        return false;
      }
    } catch (e) {
      print('🔐 [EPHEMERAL-$_instanceId] ❌ Error en reconexión: $e');
      return false;
    }
  }

  /// NUEVO: Aplicar automáticamente configuración por defecto cuando se une a nueva sala
  Future<void> _autoApplyDefaultDestruction() async {
    try {
      print(
          '🔐 [EPHEMERAL-$_instanceId] 🔥 Verificando auto-aplicar configuración por defecto...');

      // Obtener servicio de preferencias
      final preferencesService = AutoDestructionPreferencesService();
      await preferencesService.initialize();

      // Verificar si debe auto-aplicar
      if (preferencesService.shouldAutoApplyDefault) {
        final defaultMinutes = preferencesService.defaultDestructionMinutes;

        if (defaultMinutes != null) {
          print(
              '🔐 [EPHEMERAL-$_instanceId] 🔥 AUTO-APLICANDO configuración por defecto: $defaultMinutes minutos');

          // Aplicar configuración después de un breve delay para asegurar que la sala esté lista
          Future.delayed(const Duration(milliseconds: 2000), () {
            if (_currentRoomId != null && !_disposed) {
              configureAutoDestruction(defaultMinutes);
              print(
                  '🔐 [EPHEMERAL-$_instanceId] ✅ Configuración por defecto aplicada automáticamente');
            }
          });
        } else {
          print(
              '🔐 [EPHEMERAL-$_instanceId] ⚠️ Auto-aplicar habilitado pero sin tiempo configurado');
        }
      } else {
        print(
            '🔐 [EPHEMERAL-$_instanceId] ℹ️ Auto-aplicar deshabilitado - no se aplica configuración por defecto');
      }
    } catch (e) {
      print(
          '🔐 [EPHEMERAL-$_instanceId] ❌ Error aplicando configuración por defecto: $e');
    }
  }
}
