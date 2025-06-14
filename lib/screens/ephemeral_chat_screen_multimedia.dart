import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:async';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/ephemeral_chat_service.dart';
import '../services/encryption_service.dart';
import '../services/screenshot_service.dart';
import '../services/screenshot_notification_service.dart';
import '../models/ephemeral_message.dart';
import '../models/ephemeral_room.dart';
import '../providers/auth_provider.dart';
import '../services/ephemeral_chat_manager.dart';
import '../widgets/destruction_countdown_widget.dart';
import '../widgets/verification_widget.dart'; // NUEVO: Import del widget de verificación
import '../services/static_avatar_service.dart'; // NUEVO: Import del servicio de avatares
import '../l10n/app_localizations.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'fullscreen_media_viewer.dart'; // NUEVO: Import del visor pantalla completa
import '../services/metadata_cleaner_service.dart'; // 🛡️ PARANOIA MÁXIMA: Limpieza de metadatos

/// 🎯 Chat Efímero Multimedia con Cifrado E2E XChaCha20-Poly1305
/// Soporta: Texto, Imágenes, Audio Real - COMPLETO
class EphemeralChatScreenMultimedia extends StatefulWidget {
  final String? targetUserId;
  final String? invitationId;
  final EphemeralChatService? ephemeralChatService;
  final bool isFromMultiRoom;

  const EphemeralChatScreenMultimedia({
    super.key,
    this.targetUserId,
    this.invitationId,
    this.ephemeralChatService,
    this.isFromMultiRoom = false,
  });

  @override
  State<EphemeralChatScreenMultimedia> createState() =>
      _EphemeralChatScreenMultimediaState();
}

class _EphemeralChatScreenMultimediaState
    extends State<EphemeralChatScreenMultimedia> with TickerProviderStateMixin {
  // 🔐 Servicios principales
  late EphemeralChatService _chatService;
  late EncryptionService _encryptionService;
  late ScreenshotService _screenshotService;
  late MetadataCleanerService _metadataCleaner; // 🛡️ PARANOIA MÁXIMA

  // NUEVO: Rastrear si el servicio es compartido o propio
  bool _isSharedChatService = false;

  // 📝 Controladores de UI
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // 📱 Estado del chat
  List<EphemeralMessage> _messages = [];
  EphemeralRoom? _currentRoom;
  bool _isConnecting = true;
  String? _error;
  bool _encryptionConfigured = false;

  // 📷 Image picker
  final ImagePicker _imagePicker = ImagePicker();

  // 🎨 Animaciones
  late AnimationController _sendButtonController;
  late Animation<double> _sendButtonAnimation;

  // 📅 Seleccion de autodestrucción
  int? _selectedDestructionMinutes;

  // NUEVO: Variables para destrucción manual de sala
  bool _showDestructionCountdown = false;
  EphemeralMessage? _currentDestructionMessage;
  bool _isFromMultiRoomDetected = false;

  Timer?
      _callbackCheckTimer; // NUEVO: Timer para verificar callbacks periódicamente

  // NUEVO: Grabación de audio real
  FlutterSoundRecorder? _audioRecorder;
  FlutterSoundPlayer? _audioPlayer; // NUEVO: Reproductor de audio
  bool _isRecording = false;
  bool _isAudioInitialized = false;
  bool _isPlayerInitialized = false; // NUEVO: Estado del reproductor
  String? _currentAudioPath;
  String?
      _currentlyPlayingMessageId; // NUEVO: ID del mensaje que se está reproduciendo

  // NUEVO: Animación para botón de audio
  late AnimationController _audioButtonController;
  late Animation<double> _audioButtonAnimation;

  // NUEVO: Variables para adaptación dinámica del teclado
  final bool _isKeyboardVisible = false;
  final double _keyboardHeight = 0.0;

  @override
  void initState() {
    super.initState();

    // NUEVO: Si viene de multi-room, cargar mensajes existentes del servicio
    if (widget.isFromMultiRoom && widget.ephemeralChatService != null) {
      _loadExistingMessagesFromSession();
    }

    _initializeServices();
    _setupAnimations();
    _detectMultiRoomContext();
    _initializeAudio();

    // NUEVO: Configurar timer para verificar callbacks periódicamente (iOS fix)
    _startCallbackMonitoring();
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

        // Imprimir mensajes para debug solo si hay mensajes
        if (_messages.isNotEmpty) {
          for (int i = 0; i < _messages.length; i++) {
            // Mensaje $i: "${_messages[i].content}" (${_messages[i].senderId})
          }
        }

        // También cargar estado de la sala si existe
        if (session.currentRoom != null) {
          _currentRoom = session.currentRoom;
        }
      } catch (e) {
        // En caso de error, mantener mensajes existentes si los hay
      }
    }
  }

  void _setupAnimations() {
    _sendButtonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _sendButtonAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _sendButtonController,
      curve: Curves.easeInOut,
    ));

    // NUEVO: Animación para botón de audio
    _audioButtonController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _audioButtonAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _audioButtonController,
      curve: Curves.elasticInOut,
    ));
  }

  // NUEVO: Detectar contexto de múltiples salas (igual que original)
  void _detectMultiRoomContext() {
    bool isFromMulti = false;

    if (widget.ephemeralChatService != null) {
      isFromMulti = true;
    }

    if (widget.isFromMultiRoom) {
      isFromMulti = true;
    }

    if (widget.invitationId != null) {
      isFromMulti = true;
    }

    _isFromMultiRoomDetected = isFromMulti;

    if (!isFromMulti) {
      // Contexto detectado: CHAT INDIVIDUAL
    }
  }

  bool _isFromMultiRoomContext() {
    return widget.isFromMultiRoom || _isFromMultiRoomDetected;
  }

  // NUEVO: Inicializar grabación de audio real
  Future<void> _initializeAudio() async {
    try {
      _audioRecorder = FlutterSoundRecorder();
      _audioPlayer = FlutterSoundPlayer(); // NUEVO: Inicializar reproductor

      // En web, flutter_sound tiene limitaciones, usar implementación simplificada
      if (kIsWeb) {
        try {
          await _audioRecorder!.openRecorder();
          await _audioPlayer!.openPlayer(); // NUEVO: Abrir reproductor
          _isAudioInitialized = true;
          _isPlayerInitialized =
              true; // NUEVO: Marcar reproductor como iniciado
        } catch (e) {
          _isAudioInitialized = false;
          _isPlayerInitialized = false;
        }
        return;
      }

      // Para iOS/móvil, proceso más robusto

      // PASO 1: Verificar y solicitar permisos de micrófono

      final currentPermission = await Permission.microphone.status;

      PermissionStatus microphonePermission;

      if (currentPermission.isDenied || currentPermission.isPermanentlyDenied) {
        microphonePermission = await Permission.microphone.request();
      } else {
        microphonePermission = currentPermission;
      }

      if (microphonePermission != PermissionStatus.granted) {
        if (microphonePermission.isPermanentlyDenied) {
          _showMicrophonePermissionDialog();
        }

        _isAudioInitialized = false;
        _isPlayerInitialized = false;
        return;
      }

      // PASO 2: Abrir sesión de grabación con reintentos

      int attempts = 0;
      const maxAttempts = 3;
      bool opened = false;

      while (!opened && attempts < maxAttempts) {
        attempts++;

        try {
          await _audioRecorder!.openRecorder();
          opened = true;
        } catch (e) {
          if (attempts < maxAttempts) {
            await Future.delayed(const Duration(seconds: 1));
          }
        }
      }

      if (!opened) {
        _isAudioInitialized = false;
        _isPlayerInitialized = false;
        return;
      }

      // PASO 3: Abrir reproductor de audio
      try {
        await _audioPlayer!.openPlayer();

        // NUEVO: Configurar para iOS - usar altavoz principal como WhatsApp
        if (!kIsWeb) {
          await _audioPlayer!
              .setSubscriptionDuration(const Duration(milliseconds: 100));
        }

        _isPlayerInitialized = true;
      } catch (e) {
        _isPlayerInitialized = false;
      }

      // PASO 4: Verificar estado final
      _isAudioInitialized = true;
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAudioInitialized = false;
        });
        _showError(
            AppLocalizations.of(context)!.errorInitializingAudio(e.toString()));
      }
    }
  }

  // NUEVO: Mostrar diálogo de permisos de micrófono
  void _showMicrophonePermissionDialog() {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(l10n.microphonePermissions,
            style: const TextStyle(color: Colors.white)),
        content: Text(
          l10n.microphonePermissionsContent,
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.understood),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings(); // Abrir configuración de la app
            },
            child: Text(l10n.openSettings),
          ),
        ],
      ),
    );
  }

  void _initializeServices() {
    // Usar servicio existente o crear nuevo
    _chatService = widget.ephemeralChatService ?? EphemeralChatService();
    _encryptionService = EncryptionService();
    _screenshotService = ScreenshotService();
    _metadataCleaner = MetadataCleanerService(); // 🛡️ PARANOIA MÁXIMA

    // IMPORTANTE: Marcar si el servicio es compartido o propio
    _isSharedChatService = widget.ephemeralChatService != null;

    // CRÍTICO: Configurar callbacks SIEMPRE y PRIMERO
    _setupCallbacks();

    // Inicializar servicios de cifrado y capturas
    _initializeEncryption();
    _initializeScreenshotSecurity();

    // CORREGIDO: Manejar inicialización según el tipo de servicio
    if (!_isSharedChatService) {
      // Servicio nuevo - inicializar completamente
      _connectToChat();
    } else {
      // Servicio compartido - verificar si hay parámetros para procesar
      if (widget.invitationId != null) {
        _acceptInvitationWithExistingService();
      } else if (widget.targetUserId != null) {
        _createInvitationWithExistingService();
      } else {
        _loadExistingRoomState();
        setState(() {
          _isConnecting = false;
        });
      }
    }
  }

  // NUEVO: Verificar y reconfigurar callbacks si se pierden (para iOS)
  void _ensureCallbacksAreSet() {
    bool needsReconfiguration = false;

    if (_chatService.onMessageReceived == null) {
      needsReconfiguration = true;
    }

    if (_chatService.onRoomCreated == null) {
      needsReconfiguration = true;
    }

    if (needsReconfiguration) {
      _setupCallbacks();
    }
  }

  // NUEVO: Iniciar monitoreo periódico de callbacks (para iOS)
  void _startCallbackMonitoring() {
    // Solo en iOS donde es necesario
    if (!kIsWeb && Platform.isIOS) {
      _callbackCheckTimer =
          Timer.periodic(const Duration(seconds: 30), (timer) {
        if (mounted) {
          _ensureCallbacksAreSet();
        } else {
          timer.cancel();
        }
      });
    } else {
      // Plataforma Web o Android - sin monitoreo de callbacks
    }
  }

  // NUEVO: Configurar TODOS los callbacks (igual que versión original)
  void _setupCallbacks() {
    // CRÍTICO: Configurar callbacks principales SIEMPRE
    _chatService.onRoomCreated = (data) => _onRoomCreated(data);
    _chatService.onMessageReceived = (message) => _onMessageReceived(message);

    // NUEVO: PRESERVAR callback original del ChatManager antes de sobrescribir
    final originalOnRoomDestroyed = _chatService.onRoomDestroyed;
    _chatService.onRoomDestroyed = () {
      print('🔐 [MULTIMEDIA] 💥 Sala destruida - llamando callbacks...');

      // PRIMERO: Ejecutar mi limpieza local
      _onRoomDestroyed();

      // SEGUNDO: Llamar al callback original del ChatManager si existe
      if (originalOnRoomDestroyed != null) {
        print(
            '🔐 [MULTIMEDIA] 🔄 Ejecutando callback original del ChatManager...');
        originalOnRoomDestroyed();
      } else {
        print('🔐 [MULTIMEDIA] ⚠️ No hay callback original del ChatManager');
      }
    };

    _chatService.onError = _onError;

    // Si ya hay una sala activa pero no tenemos _currentRoom, crearla
    if (_chatService.currentRoomId != null && _currentRoom == null) {
      final now = DateTime.now();

      final fakeParticipants = List.generate(
          _chatService.participantCount, (index) => 'participant_$index');

      _currentRoom = EphemeralRoom(
        id: _chatService.currentRoomId!,
        participants: fakeParticipants,
        encryptionKey: '',
        createdAt: now,
        lastActivity: now,
      );
      _isConnecting = false;

      if (mounted) {
        setState(() {
          // _currentRoom y _isConnecting ya están establecidos arriba
        });
      }
    }

    // NUEVO: Configurar callbacks de destrucción manual (FALTABAN!)
    _chatService.onDestructionCountdownStarted = () {
      // Solo crear mensaje si NO existe ningún mensaje de destrucción
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
      } else {
        // Mensaje de destrucción NO creado - ya existe
      }
    };

    _chatService.onDestructionCountdownCancelled = () {
      if (mounted) {
        setState(() {
          _showDestructionCountdown = false;
          _currentDestructionMessage = null;
          // Remover mensaje de destrucción del chat
          _messages.removeWhere((msg) => msg.isDestructionCountdown);
        });
      }
    };

    _chatService.onDestructionCountdownUpdate = (countdown) {
      if (mounted) {
        // Si no hay mensaje de destrucción, crearlo (para el usuario que no lo inició)
        if (_currentDestructionMessage == null && _currentRoom != null) {
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

        // Si el contador llega a 0, limpiar estado local
        if (countdown <= 0) {
          setState(() {
            _showDestructionCountdown = false;
            _currentDestructionMessage = null;
          });
        }
      }
    };
  }

  // NUEVO: Métodos para servicio compartido (copiados de original)
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

  // NUEVO: Cargar estado de sala existente (copiado de original)
  void _loadExistingRoomState() {
    if (_chatService.currentRoomId != null) {
      final now = DateTime.now();
      _currentRoom = EphemeralRoom(
        id: _chatService.currentRoomId!,
        participants: List.generate(
            _chatService.participantCount, (index) => 'participant_$index'),
        encryptionKey: '',
        createdAt: now,
        lastActivity: now,
      );

      // NUEVO: Iniciar timer de destrucción para sala existente
      _startDestructionTimer();
    }
  }

  // NUEVO: Iniciar timer de destrucción de mensajes (copiado de original)
  void _startDestructionTimer() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
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

  Future<void> _initializeEncryption() async {
    try {
      await _encryptionService.initialize();
    } catch (e) {
      setState(() {
        _error = 'Error inicializando cifrado: $e';
      });
    }
  }

  Future<void> _initializeScreenshotSecurity() async {
    try {
      await _screenshotService.initialize();

      // AUTOMÁTICO: Bloquear capturas al entrar al chat multimedia
      await _screenshotService.blockScreenshots();

      // NUEVO: Inicializar servicio de notificaciones de capturas
      await _initializeScreenshotNotification();
    } catch (e) {
      // Error inicializando ScreenshotService
    }
  }

  Future<void> _initializeScreenshotNotification() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.id ?? '';
      final nickname = authProvider.user?.nickname ?? 'Usuario';

      final notificationService = ScreenshotNotificationService.instance;
      await notificationService.initialize(
        chatService: _chatService,
        userId: userId,
        nickname: nickname,
      );

      // Iniciar detección automáticamente
      await notificationService.startDetection();
    } catch (e) {
      // Error inicializando ScreenshotNotificationService
    }
  }

  Future<void> _connectToChat() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.id;

      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      await _chatService.initialize(userId: userId);

      if (widget.invitationId != null) {
        await _chatService.acceptInvitation(widget.invitationId!);
      } else if (widget.targetUserId != null) {
        await _chatService.createChatInvitation(widget.targetUserId!);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isConnecting = false;
      });
    }
  }

  // 🔐 Callbacks del servicio de chat
  Future<void> _onRoomCreated(dynamic data) async {
    EphemeralRoom? room;
    Map<String, dynamic>? roomData;

    // Manejar diferentes tipos de data
    if (data is EphemeralRoom) {
      room = data;

      // IMPORTANTE: Solo intentar configurar cifrado si no está ya configurado
      // y si es la primera vez que recibimos la sala (no un update de polling)
      if (!_encryptionConfigured && room.encryptionKey.isNotEmpty) {
        roomData = data.toJson();
      }
    } else if (data is Map<String, dynamic>) {
      roomData = data;
      room = EphemeralRoom.fromJson(roomData);
    } else {
      return;
    }

    setState(() {
      _currentRoom = room;
      _isConnecting = false;
      _error = null;
    });

    // SOLO configurar clave de cifrado si no está ya configurada
    if (!_encryptionConfigured && roomData != null) {
      String? encryptionKeyBase64;

      if (roomData['encryptionKey'] != null) {
        encryptionKeyBase64 = roomData['encryptionKey'];
      }

      if (encryptionKeyBase64 != null && encryptionKeyBase64.isNotEmpty) {
        try {
          final masterKeyBytes = base64Decode(encryptionKeyBase64);

          if (masterKeyBytes.length == 128) {
            // Derivar clave de sesión ChaCha20 (32 bytes) desde la clave maestra (128 bytes)
            // usando HKDF para máxima seguridad (igual que el servicio original)
            final sessionKey =
                await _encryptionService.deriveSessionKeyFromShared(
                    Uint8List.fromList(masterKeyBytes),
                    'ephemeral-chat-${room.id}');

            await _encryptionService.setSessionKey(sessionKey);
            _encryptionConfigured = true; // Marcar como configurado
          } else if (masterKeyBytes.length == 32) {
            // Clave ya es de 32 bytes, usar directamente
            await _encryptionService
                .setSessionKey(Uint8List.fromList(masterKeyBytes));
            _encryptionConfigured = true; // Marcar como configurado
          } else {
            throw Exception(
                'Tamaño de clave inválido: ${masterKeyBytes.length} bytes (esperado: 32 o 128)');
          }
        } catch (e) {
          setState(() {
            _error = 'Error configurando cifrado: $e';
          });
        }
      }
    } else if (_encryptionConfigured) {
      // Cifrado ya configurado, omitiendo reconfiguración
    } else {
      // Update de polling recibido, no hay clave para configurar
    }
  }

  // 📨 Callback para mensajes recibidos
  void _onMessageReceived(EphemeralMessage message) {
    // NUEVO: Verificar que los callbacks siguen configurados (para iOS)
    _ensureCallbacksAreSet();

    // CORREGIDO: Verificar que el mensaje es para la sala correcta
    if (_currentRoom != null && message.roomId != _currentRoom!.id) {
      return;
    }

    // Filtrar mensajes de verificación para que no aparezcan en el chat
    if (message.content.startsWith('VERIFICATION_CODES:')) {
      return; // No agregar a la lista de mensajes
    }

    // Procesar eventos de limpieza enviados desde el servidor
    if (message.content.startsWith('CLEANUP_MESSAGES:')) {
      try {
        final parts = message.content.split(':');
        if (parts.length >= 2) {
          final destructionMinutes = int.parse(parts[1]);

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
          }
        }
      } catch (e) {
        // Error procesando limpieza
      }
      return; // No mostrar el mensaje de limpieza en el chat
    }

    // Procesar mensajes de configuración de autodestrucción
    if (message.content.startsWith('AUTOCONFIG_DESTRUCTION:')) {
      try {
        final parts = message.content.split(':');
        if (parts.length >= 3) {
          final destructionMinutes = int.parse(parts[1]);
          final configuredBy = parts[2];

          // Crear mensaje visible en el chat
          String timeText;
          if (destructionMinutes >= 60) {
            final hours = destructionMinutes ~/ 60;
            final remainingMinutes = destructionMinutes % 60;
            if (remainingMinutes == 0) {
              timeText = '$hours hora${hours > 1 ? 's' : ''}';
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
        }
      } catch (e) {
        // Error procesando configuración
      }
      return; // No procesar más este mensaje
    }

    // NUEVO: Procesar notificaciones de capturas de pantalla
    if (message.content.startsWith('SCREENSHOT_NOTIFICATION:')) {
      try {
        final parts = message.content.split(':');
        if (parts.length >= 2) {
          final screenshotUser = parts[1];

          // Crear mensaje visible en el chat
          final screenshotMessage = EphemeralMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            roomId: _currentRoom!.id,
            senderId: 'system',
            content: AppLocalizations.of(context)!
                .screenshotNotification(screenshotUser),
            timestamp: DateTime.now(),
            messageType: 'system',
          );

          setState(() {
            _messages.add(screenshotMessage);
          });

          // NUEVO: Mostrar snackbar adicional
          _showSnackBar(
              AppLocalizations.of(context)!.screenshotAlert(screenshotUser));
        }
      } catch (e) {
        // Error procesando notificación de captura
      }
      return; // No procesar más este mensaje
    }

    // NUEVO: Detectar y procesar mensajes de imagen
    if (message.content.startsWith('IMAGE_DATA:')) {
      try {
        final imageBase64 =
            message.content.substring(11); // Remover "IMAGE_DATA:"
        final imageBytes = base64Decode(imageBase64);

        // Crear mensaje de imagen con datos decodificados
        final imageMessage = EphemeralMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          roomId: message.roomId,
          senderId: message.senderId,
          content:
              AppLocalizations.of(context)!.image, // Texto simple para mostrar
          timestamp: message.timestamp,
          destructionTimeMinutes: message.destructionTimeMinutes,
          destructionTime: message.destructionTime,
          messageType: 'image',
          mediaData: imageBytes,
        );

        if (mounted) {
          setState(() {
            _messages.add(imageMessage);
          });
          _syncMessageWithSession(imageMessage);
        }
        return; // No procesar como mensaje de texto normal
      } catch (e) {
        // Si falla, procesar como mensaje de texto normal
      }
    }

    // NUEVO: Detectar y procesar mensajes de audio real
    if (message.content.startsWith('AUDIO_DATA:')) {
      try {
        final audioBase64 =
            message.content.substring(11); // Remover "AUDIO_DATA:"
        final audioBytes = base64Decode(audioBase64);

        // Verificar tamaño máximo (1MB)
        if (audioBytes.length > 1000000) {
          _showError(AppLocalizations.of(context)!.audioTooLong);
          return;
        }

        // Crear mensaje de audio con datos decodificados
        final audioMessage = EphemeralMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          roomId: message.roomId,
          senderId: message.senderId,
          content: AppLocalizations.of(context)!
              .audioNote, // Texto simple para mostrar
          timestamp: message.timestamp,
          destructionTimeMinutes: message.destructionTimeMinutes,
          destructionTime: message.destructionTime,
          messageType: 'audio',
          mediaData: audioBytes,
          duration: 5.0, // Duración estimada
        );

        if (mounted) {
          setState(() {
            _messages.add(audioMessage);
          });
          _syncMessageWithSession(audioMessage);

          // NUEVO: Autoreproducir audio recibido
          _autoPlayReceivedAudio(audioMessage);
        }
        return; // No procesar como mensaje de texto normal
      } catch (e) {
        // Si falla, procesar como mensaje de texto normal
      }
    }

    // Manejar mensajes de destrucción
    if (message.isDestructionCountdown) {
      if (mounted) {
        setState(() {
          // Agregar mensaje de destrucción al chat
          _messages.add(message);
          _showDestructionCountdown = true;
          _currentDestructionMessage = message;
        });
      }
      return;
    }

    // Log detallado antes de agregar mensaje normal
    if (mounted) {
      setState(() {
        _messages.add(message);
      });

      // Sincronizar mensaje recibido con ChatSession para persistencia
      _syncMessageWithSession(message);

      // Forzar rebuild del widget para asegurar que se muestre
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() {
            // Forzar rebuild
          });
        }
      });
    } else {
      // Widget no montado - mensaje no agregado
    }
  }

  void _onRoomDestroyed() {
    setState(() {
      _currentRoom = null;
      _messages.clear();
    });
  }

  void _onError(String error) {
    setState(() {
      _error = error;
    });
  }

  // 📝 Enviar mensaje de texto
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _currentRoom == null) return;

    // NUEVO: Verificar que los callbacks siguen configurados antes de enviar
    _ensureCallbacksAreSet();

    try {
      // 🛡️ PARANOIA MÁXIMA: Limpiar metadatos del texto antes de enviar
      final cleanedText = _metadataCleaner.cleanTextMetadataParanoid(text);
      print(
          '🛡️ [METADATA_CLEANER] Texto limpiado: "${text}" -> "${cleanedText}"');

      // USAR EXACTAMENTE EL MISMO MÉTODO QUE LA PANTALLA ORIGINAL
      await _chatService.sendMessage(cleanedText,
          destructionTimeMinutes: _selectedDestructionMinutes);
      _messageController.clear();

      // Agregar mensaje propio a la lista con tiempo de destrucción (IGUAL QUE ORIGINAL)
      final myMessage = EphemeralMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        roomId: _currentRoom!.id,
        senderId: 'me',
        content: cleanedText, // Usar texto limpio también en UI
        timestamp: DateTime.now(),
        destructionTimeMinutes: _selectedDestructionMinutes,
        destructionTime: _selectedDestructionMinutes != null
            ? DateTime.now()
                .add(Duration(minutes: _selectedDestructionMinutes!))
            : null,
      );

      if (mounted) {
        setState(() {
          _messages.add(myMessage);
        });

        // Sincronizar con ChatSession del manager para persistencia
        _syncMessageWithSession(myMessage);
      } else {
        // Widget no montado - mensaje propio no agregado
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error enviando mensaje: $e';
        });
      }
    }
  }

  /// Sincronizar mensaje con ChatSession para persistencia
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

        // CRÍTICO: También disparar manualmente el callback del ChatManager para notificaciones
        if (chatManager.onMessageReceived != null) {
          chatManager.onMessageReceived!(session.sessionId, message);
        } else {
          // Callback de ChatManager es null - sin notificaciones
        }
      } catch (e) {
        // Error sincronizando mensaje con sesión
      }
    }
  }

  // 📷 Seleccionar y enviar imagen
  Future<void> _pickAndSendImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 800, // Reducido de 1920 a 800
        maxHeight: 600, // Reducido de 1080 a 600
        imageQuality: 70, // Reducido de 85 a 70
      );

      if (image == null) return;

      // Leer imagen
      final imageBytes = await image.readAsBytes();

      // 🛡️ PARANOIA MÁXIMA: Limpiar TODOS los metadatos antes de procesar
      Uint8List cleanedImageBytes;
      try {
        cleanedImageBytes =
            await _metadataCleaner.cleanImageMetadataParanoid(imageBytes);
        print(
            '🛡️ [METADATA_CLEANER] Imagen limpiada: ${imageBytes.length} -> ${cleanedImageBytes.length} bytes');
      } catch (e) {
        print('🛡️ [METADATA_CLEANER] Error limpiando imagen: $e');
        // Fallback: usar imagen original pero con warning
        cleanedImageBytes = imageBytes;
        _showError(
            '⚠️ Advertencia: No se pudieron limpiar completamente los metadatos');
      }

      // Verificar tamaño máximo (500KB) DESPUÉS de limpieza
      if (cleanedImageBytes.length > 500000) {
        _showError(AppLocalizations.of(context)!.imageTooLarge);
        return;
      }

      // Convertir a base64 para envío como texto (igual que la pantalla original)
      final imageBase64 = base64Encode(cleanedImageBytes);
      final messageContent = 'IMAGE_DATA:$imageBase64';

      // USAR EL MISMO MÉTODO QUE FUNCIONA PARA TEXTO
      await _chatService.sendMessage(messageContent,
          destructionTimeMinutes: _selectedDestructionMinutes);

      // Agregar a UI local (igual que mensaje de texto)
      final message = EphemeralMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        roomId: _currentRoom!.id,
        senderId: 'me',
        content: messageContent, // Guardar el contenido completo
        timestamp: DateTime.now(),
        destructionTimeMinutes: _selectedDestructionMinutes,
        destructionTime: _selectedDestructionMinutes != null
            ? DateTime.now()
                .add(Duration(minutes: _selectedDestructionMinutes!))
            : null,
        messageType: 'image',
        mediaData: cleanedImageBytes, // Para mostrar en UI - LIMPIO
      );

      setState(() {
        _messages.add(message);
      });

      // Sincronizar con ChatSession
      _syncMessageWithSession(message);

      _scrollToBottom();
    } catch (e) {
      _showError(AppLocalizations.of(context)!.errorSendingImage(e.toString()));
    }
  }

  // 🎵 Simular envío de audio (pendiente de dependencias)
  Future<void> _simulateAudioMessage() async {
    if (_currentRoom == null) return;

    try {
      // Simular mensaje de audio simple
      final audioContent =
          '🎵 Nota de audio simulada (${DateTime.now().second}s)';

      // USAR EL MISMO MÉTODO QUE FUNCIONA PARA TEXTO
      await _chatService.sendMessage(audioContent,
          destructionTimeMinutes: _selectedDestructionMinutes);

      // Agregar a UI local (igual que mensaje de texto)
      final message = EphemeralMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        roomId: _currentRoom!.id,
        senderId: 'me',
        content: audioContent,
        timestamp: DateTime.now(),
        destructionTimeMinutes: _selectedDestructionMinutes,
        destructionTime: _selectedDestructionMinutes != null
            ? DateTime.now()
                .add(Duration(minutes: _selectedDestructionMinutes!))
            : null,
        messageType: 'audio',
        duration: 3.0,
      );

      setState(() {
        _messages.add(message);
      });

      // Sincronizar con ChatSession
      _syncMessageWithSession(message);

      _scrollToBottom();
    } catch (e) {
      _showError(AppLocalizations.of(context)!.errorSendingAudio(e.toString()));
    }
  }

  // NUEVO: Grabación de audio REAL
  Future<void> _toggleAudioRecording() async {
    if (!_isAudioInitialized || _audioRecorder == null) {
      // Mostrar feedback al usuario
      _showError(AppLocalizations.of(context)!.initializingAudioRecorder);

      // Intentar reinicializar
      await _initializeAudio();

      // Verificar si ahora está inicializado
      if (!_isAudioInitialized || _audioRecorder == null) {
        _showError(AppLocalizations.of(context)!.audioRecorderNotAvailable);
        return;
      }
    }

    if (_isRecording) {
      await _stopAudioRecording();
    } else {
      await _startAudioRecording();
    }
  }

  Future<void> _startAudioRecording() async {
    try {
      if (_currentRoom == null) {
        return;
      }

      // Para web, usar grabación en memoria sin path_provider
      if (kIsWeb) {
        await _audioRecorder!.startRecorder(
          codec: Codec.opusWebM, // Codec mejor soportado en web
        );
      } else {
        // Para móvil/iOS, usar archivo temporal con codec apropiado
        final tempDir = await getTemporaryDirectory();
        _currentAudioPath =
            '${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.aac';

        // NUEVO: Verificar estado del grabador antes de iniciar
        if (!_audioRecorder!.isRecording) {
          await _audioRecorder!.startRecorder(
            toFile: _currentAudioPath,
            codec: Codec.aacADTS,
            bitRate: 16000, // NUEVO: Bitrate optimizado para iOS
            sampleRate: 16000, // NUEVO: Sample rate estándar
          );
        } else {
          // Grabador ya está grabando
        }
      }

      setState(() {
        _isRecording = true;
      });

      // Iniciar animación de pulsación
      _audioButtonController.repeat(reverse: true);
    } catch (e) {
      // Resetear estado en caso de error
      setState(() {
        _isRecording = false;
      });
      _audioButtonController.stop();
      _audioButtonController.reset();

      _showError(
          AppLocalizations.of(context)!.errorStartingRecording(e.toString()));
    }
  }

  Future<void> _stopAudioRecording() async {
    try {
      if (!_isRecording) return;

      // Detener grabación
      final recordedPath = await _audioRecorder!.stopRecorder();

      setState(() {
        _isRecording = false;
      });

      // Detener animación
      _audioButtonController.stop();
      _audioButtonController.reset();

      if (kIsWeb) {
        // En web, flutter_sound devuelve los datos directamente
        if (recordedPath != null) {
          await _sendAudioMessageWeb(recordedPath);
        } else {
          _showError(AppLocalizations.of(context)!.errorWebAudioRecording);
        }
      } else {
        // En móvil, verificar archivo
        if (recordedPath != null && File(recordedPath).existsSync()) {
          await _sendAudioMessage(recordedPath);
        } else {
          _showError(AppLocalizations.of(context)!.errorWebAudioSaving);
        }
      }
    } catch (e) {
      _showError(
          AppLocalizations.of(context)!.errorStoppingRecording(e.toString()));
      setState(() {
        _isRecording = false;
      });
      _audioButtonController.stop();
      _audioButtonController.reset();
    }
  }

  // NUEVO: Enviar audio desde web (sin archivo)
  Future<void> _sendAudioMessageWeb(String audioData) async {
    try {
      if (_currentRoom == null) return;

      // En web, crear un audio simulado ya que flutter_sound web tiene limitaciones
      const audioContent = '🎵 Nota de audio web (grabada)';

      // Enviar usando el mismo método que funciona para texto
      await _chatService.sendMessage(audioContent,
          destructionTimeMinutes: _selectedDestructionMinutes);

      // Agregar a UI local
      final message = EphemeralMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        roomId: _currentRoom!.id,
        senderId: 'me',
        content: audioContent,
        timestamp: DateTime.now(),
        destructionTimeMinutes: _selectedDestructionMinutes,
        destructionTime: _selectedDestructionMinutes != null
            ? DateTime.now()
                .add(Duration(minutes: _selectedDestructionMinutes!))
            : null,
        messageType: 'audio',
        duration: 3.0,
      );

      setState(() {
        _messages.add(message);
      });

      // Sincronizar con ChatSession
      _syncMessageWithSession(message);

      _scrollToBottom();
    } catch (e) {
      _showError(AppLocalizations.of(context)!.errorSendingAudio(e.toString()));
    }
  }

  // ORIGINAL: Enviar audio desde móvil (con archivo)
  Future<void> _sendAudioMessage(String audioPath) async {
    try {
      if (_currentRoom == null) return;

      // Leer archivo de audio como bytes
      final audioFile = File(audioPath);
      final audioBytes = await audioFile.readAsBytes();

      // 🛡️ PARANOIA MÁXIMA: Limpiar metadatos de audio
      Uint8List cleanedAudioBytes;
      try {
        cleanedAudioBytes =
            await _metadataCleaner.cleanAudioMetadataParanoid(audioBytes);
        print(
            '🛡️ [METADATA_CLEANER] Audio limpiado: ${audioBytes.length} -> ${cleanedAudioBytes.length} bytes');
      } catch (e) {
        print('🛡️ [METADATA_CLEANER] Error limpiando audio: $e');
        // Fallback: usar audio original pero con warning
        cleanedAudioBytes = audioBytes;
        _showError(
            '⚠️ Advertencia: No se pudieron limpiar completamente los metadatos de audio');
      }

      // Verificar tamaño máximo (1MB) DESPUÉS de limpieza
      if (cleanedAudioBytes.length > 1000000) {
        _showError(AppLocalizations.of(context)!.audioTooLong);
        return;
      }

      // Convertir a base64 para envío
      final audioBase64 = base64Encode(cleanedAudioBytes);
      final messageContent = 'AUDIO_DATA:$audioBase64';

      // Enviar usando el mismo método que funciona para texto
      await _chatService.sendMessage(messageContent,
          destructionTimeMinutes: _selectedDestructionMinutes);

      // Agregar a UI local
      final message = EphemeralMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        roomId: _currentRoom!.id,
        senderId: 'me',
        content: messageContent,
        timestamp: DateTime.now(),
        destructionTimeMinutes: _selectedDestructionMinutes,
        destructionTime: _selectedDestructionMinutes != null
            ? DateTime.now()
                .add(Duration(minutes: _selectedDestructionMinutes!))
            : null,
        messageType: 'audio',
        mediaData: cleanedAudioBytes, // Audio limpio de metadatos
        duration: 5.0, // Duración estimada
      );

      setState(() {
        _messages.add(message);
      });

      // Sincronizar con ChatSession
      _syncMessageWithSession(message);

      // Limpiar archivo temporal
      try {
        await audioFile.delete();
      } catch (e) {
        // No se pudo eliminar archivo temporal
      }

      _scrollToBottom();
    } catch (e) {
      _showError(AppLocalizations.of(context)!.errorSendingAudio(e.toString()));
    }
  }

  // NUEVO: Mostrar diálogo de destrucción de sala (igual que original)
  void _showDestructionDialog() {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.red),
            const SizedBox(width: 10),
            Text(l10n.destroyRoom, style: const TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(
          l10n.destroyRoomContent,
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
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
            child: Text(l10n.destroyRoomButton),
          ),
        ],
      ),
    );
  }

  // NUEVO: Iniciar contador de destrucción de sala
  void _startDestructionCountdown() {
    if (_currentRoom != null) {
      final destructionMessage = EphemeralMessage.destructionCountdown(
        roomId: _currentRoom!.id,
        senderId: 'me',
        countdown: 10,
      );

      setState(() {
        _currentDestructionMessage = destructionMessage;
        _showDestructionCountdown = true;
        _messages.add(destructionMessage);
      });
    }

    // Enviar comando al servidor
    _chatService.startDestructionCountdown();
  }

  // NUEVO: Cancelar contador de destrucción
  void _cancelDestructionCountdown() {
    if (_currentRoom != null) {
      _chatService.cancelDestructionCountdown();
    }

    setState(() {
      _showDestructionCountdown = false;
      _currentDestructionMessage = null;
      _messages.removeWhere((msg) => msg.isDestructionCountdown);
    });
  }

  // NUEVO: Navegar después de destrucción
  void _navigateAfterDestruction() {
    if (!mounted) {
      return;
    }

    try {
      if (_currentRoom != null) {
        _chatService.leaveRoom();
      }
    } catch (e) {
      // Error limpiando sala
    }

    try {
      if (_isFromMultiRoomContext()) {
        Navigator.of(context).pushReplacementNamed('/multi-room-chat');
      } else {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      try {
        Navigator.of(context).pushReplacementNamed('/home');
      } catch (e2) {
        // Error crítico en navegación de respaldo
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showImageSourceDialog() {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade600,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.sendEncryptedImage,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blue),
              title: Text(l10n.takePhoto,
                  style: const TextStyle(color: Colors.white)),
              subtitle: Text(l10n.useCamera,
                  style: const TextStyle(color: Colors.grey)),
              onTap: () {
                Navigator.pop(context);
                _pickAndSendImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.green),
              title: Text(l10n.gallery,
                  style: const TextStyle(color: Colors.white)),
              subtitle: Text(l10n.selectImage,
                  style: const TextStyle(color: Colors.grey)),
              onTap: () {
                Navigator.pop(context);
                _pickAndSendImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // NUEVO: Función para abrir imagen en pantalla completa
  void _openFullscreenImage(Uint8List imageData, String messageId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullscreenMediaViewer(
          imageData: imageData,
          heroTag: 'image_$messageId',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.security, color: Colors.orange, size: 20),
            const SizedBox(width: 8),
            Text(_currentRoom != null ? 'E2E' : 'Conectando...'),
          ],
        ),
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        leading: _isFromMultiRoomContext()
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                tooltip: AppLocalizations.of(context)!.backToMultipleChats,
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                tooltip: AppLocalizations.of(context)!.backToChat,
              ),
        actions: [
          if (_currentRoom != null && !_showDestructionCountdown)
            IconButton(
              icon: const Icon(Icons.delete_forever, color: Colors.red),
              onPressed: _showDestructionDialog,
              tooltip: AppLocalizations.of(context)!.destroyRoom,
            ),
          IconButton(
            icon: Icon(
              _screenshotService.isBlocked
                  ? Icons.security
                  : Icons.security_outlined,
              color:
                  _screenshotService.isBlocked ? Colors.green : Colors.orange,
            ),
            onPressed: () async {
              final success = await _screenshotService.toggleScreenshots();
              if (success && mounted) {
                setState(() {}); // Refrescar UI
                final status = _screenshotService.isBlocked
                    ? AppLocalizations.of(context)!.screenshotsBlocked
                    : AppLocalizations.of(context)!.screenshotsPermitted;
                _showSnackBar(
                    '${AppLocalizations.of(context)!.screenshotsStatus} $status');
              }
            },
            tooltip: _screenshotService.isBlocked
                ? AppLocalizations.of(context)!.capturesBlocked
                : AppLocalizations.of(context)!.capturesAllowed,
          ),
          // NUEVO: Icono verde para mostrar detección de capturas activa
          if (_currentRoom != null &&
              ScreenshotNotificationService.instance.isActive)
            const Icon(
              Icons.monitor_outlined,
              color: Colors.green,
              size: 24,
            ),
          if (_currentRoom != null)
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                // final captureStatus = _screenshotService.isBlocked
                //     ? 'BLOQUEADAS 🔒'
                //     : 'PERMITIDAS ⚠️';

                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: const Color(0xFF1E1E1E),
                    title: Text(
                        AppLocalizations.of(context)!.e2eEncryptionSecurity,
                        style: const TextStyle(color: Colors.white)),
                    content: Text(
                      AppLocalizations.of(context)!.encryptionDescription,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(AppLocalizations.of(context)!.understood),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  kToolbarHeight -
                  16 * 2, // Restar padding top/bottom
            ),
            child: Column(
              children: [
                if (_isConnecting ||
                    _error != null ||
                    (_showDestructionCountdown &&
                        _currentDestructionMessage != null))
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      children: [
                        if (_isConnecting)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                    AppLocalizations.of(context)!
                                        .connectingToSecureChat,
                                    style:
                                        const TextStyle(color: Colors.orange)),
                              ],
                            ),
                          ),
                        if (_error != null)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error,
                                    color: Colors.red, size: 16),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text('Error: $_error',
                                      style:
                                          const TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          ),
                        if (_showDestructionCountdown &&
                            _currentDestructionMessage != null)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            child: DestructionCountdownWidget(
                              isInChat: false,
                              initialCountdown: _currentDestructionMessage!
                                      .destructionCountdownValue ??
                                  10,
                              showCancelButton:
                                  _currentDestructionMessage!.senderId == 'me',
                              onCancel:
                                  _currentDestructionMessage!.senderId == 'me'
                                      ? () => _cancelDestructionCountdown()
                                      : null,
                              onDestroy: () => _navigateAfterDestruction(),
                            ),
                          ),
                      ],
                    ),
                  ),

                // Widget de verificación
                if (_currentRoom != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: VerificationWidget(
                      roomId: _currentRoom!.id,
                      userId: Provider.of<AuthProvider>(context, listen: false)
                              .user
                              ?.id ??
                          '',
                      chatService: _chatService,
                      onVerificationChanged: (isVerified) {
                        if (isVerified) {
                          _showSnackBar(
                              '✅ Identidad del partner verificada correctamente');
                        }
                      },
                    ),
                  ),

                // Área de mensajes
                Container(
                  height: 400, // Altura fija para el área de mensajes
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF2E2E2E)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _messages.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final message = _messages[index];

                            if (message.isDestructionCountdown) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                child: DestructionCountdownWidget(
                                  isInChat: true,
                                  initialCountdown:
                                      message.destructionCountdownValue,
                                  showCancelButton: message.senderId == 'me',
                                  onCancel: message.senderId == 'me'
                                      ? () => _cancelDestructionCountdown()
                                      : null,
                                ),
                              );
                            }

                            return _buildMessageBubble(message);
                          },
                        ),
                ),

                const SizedBox(height: 16),

                // Barra de entrada multimedia
                _buildMultimediaInputBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.security, size: 64, color: Colors.orange),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.secureMultimediaChat,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.sendEncryptedMessages,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(EphemeralMessage message) {
    final isMe = message.senderId == 'me';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar para mensajes de otros (no míos)
          if (!isMe) ...[
            FutureBuilder<String>(
              future:
                  StaticAvatarService.getOrAssignRandomAvatar(message.senderId),
              builder: (context, snapshot) {
                return StaticAvatarService.buildChatAvatar(
                  name: message.senderId == 'me' ? 'Yo' : 'Usuario',
                  radius: 16,
                  selectedAvatar: snapshot.data,
                );
              },
            ),
            const SizedBox(width: 8),
          ],

          // Burbuja del mensaje
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isMe ? Colors.blue : const Color(0xFF2E2E2E),
                borderRadius: BorderRadius.circular(20),
              ),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.65,
              ),
              child: _buildMessageContent(message),
            ),
          ),

          // Avatar para mis mensajes (opcional)
          if (isMe) ...[
            const SizedBox(width: 8),
            FutureBuilder<String?>(
              future: StaticAvatarService
                  .getSelectedAvatar(), // Sin userId = mi avatar
              builder: (context, snapshot) {
                return StaticAvatarService.buildChatAvatar(
                  name: 'Yo',
                  radius: 16,
                  selectedAvatar: snapshot.data,
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageContent(EphemeralMessage message) {
    switch (message.messageType) {
      case 'text':
        return Text(
          message.content,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        );

      case 'audio':
        final isPlaying = _currentlyPlayingMessageId == message.id;

        return GestureDetector(
          onTap: () {
            if (isPlaying) {
              _stopAudioPlayback();
            } else {
              _playAudioMessage(message);
            }
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isPlaying
                      ? Colors.red.withOpacity(0.2)
                      : Colors.blue.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: isPlaying ? Colors.red : Colors.blue, width: 1),
                ),
                child: isPlaying
                    ? const Icon(Icons.stop, color: Colors.red, size: 28)
                    : const Icon(Icons.play_arrow,
                        color: Colors.blue, size: 28),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content.startsWith('AUDIO_DATA:')
                        ? AppLocalizations.of(context)!.recordedAudioNote
                        : message.content.startsWith('🎵')
                            ? message.content
                            : AppLocalizations.of(context)!.audioNote,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isPlaying
                        ? '${AppLocalizations.of(context)!.playing} • ${AppLocalizations.of(context)!.tapToStop}'
                        : '${message.duration?.toInt() ?? 5}s • ${AppLocalizations.of(context)!.tapToPlay}',
                    style: TextStyle(
                        color: isPlaying ? Colors.red : Colors.grey,
                        fontSize: 13),
                  ),
                  if (message.mediaData != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${(message.mediaData!.length / 1024).toStringAsFixed(1)} KB',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );

      case 'image':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.mediaData != null)
              GestureDetector(
                onTap: () =>
                    _openFullscreenImage(message.mediaData!, message.id),
                child: Hero(
                  tag: 'image_${message.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      message.mediaData!,
                      width: 240,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              )
            else
              Text(AppLocalizations.of(context)!.image,
                  style: const TextStyle(color: Colors.white, fontSize: 16)),
          ],
        );

      default:
        return Text(
          message.content,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        );
    }
  }

  Widget _buildMultimediaInputBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        border: Border(
          top: BorderSide(color: Color(0xFF2E2E2E)),
        ),
      ),
      child: SafeArea(
        bottom: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Botones de destrucción - siempre visibles
            SizedBox(
              height: 36,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildDestructionButton('1m', Colors.orange, () {
                      if (_currentRoom != null) {
                        _chatService.configureAutoDestruction(1);
                        _showSnackBar(AppLocalizations.of(context)!
                            .autoDestructionConfigured1Min);
                      }
                    }),
                    const SizedBox(width: 8),
                    _buildDestructionButton('5m', Colors.yellow, () {
                      if (_currentRoom != null) {
                        _chatService.configureAutoDestruction(5);
                        _showSnackBar(AppLocalizations.of(context)!
                            .autoDestructionConfigured5Min);
                      }
                    }),
                    const SizedBox(width: 8),
                    _buildDestructionButton('1h', Colors.green, () {
                      if (_currentRoom != null) {
                        _chatService.configureAutoDestruction(60);
                        _showSnackBar(AppLocalizations.of(context)!
                            .autoDestructionConfigured1Hour);
                      }
                    }),
                    const SizedBox(width: 8),
                    _buildDestructionButton('💥', Colors.red, () {
                      if (_currentRoom != null) {
                        _showDestructionDialog();
                      }
                    }),
                    const SizedBox(width: 8),
                    // NUEVO: Botón de test de capturas
                    _buildDestructionButton('📸', Colors.purple, () {
                      if (_currentRoom != null) {
                        _testScreenshotNotification();
                      }
                    }),
                    const SizedBox(width: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Barra de entrada principal
            Row(
              children: [
                // Botón de imagen
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.green, width: 1),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon:
                        const Icon(Icons.image, color: Colors.green, size: 20),
                    onPressed:
                        _currentRoom != null ? _showImageSourceDialog : null,
                    tooltip:
                        AppLocalizations.of(context)!.sendEncryptedImageTooltip,
                  ),
                ),
                const SizedBox(width: 10),
                // Botón de audio
                AnimatedBuilder(
                  animation: _audioButtonAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _audioButtonAnimation.value,
                      child: GestureDetector(
                        onTap:
                            _currentRoom != null ? _toggleAudioRecording : null,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: _isRecording ? Colors.red : Colors.blue,
                            shape: BoxShape.circle,
                            boxShadow: _isRecording
                                ? [
                                    BoxShadow(
                                      color: Colors.red.withOpacity(0.3),
                                      blurRadius: 6,
                                      spreadRadius: 2,
                                    )
                                  ]
                                : null,
                          ),
                          child: Icon(
                            _isRecording ? Icons.stop : Icons.mic,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 10),
                // Campo de texto
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(
                      minHeight: 44,
                      maxHeight: 120,
                    ),
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText:
                            AppLocalizations.of(context)!.encryptedMessage,
                        hintStyle:
                            const TextStyle(color: Colors.grey, fontSize: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: const Color(0xFF2E2E2E),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        isDense: false,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Botón de envío
                AnimatedBuilder(
                  animation: _sendButtonAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _sendButtonAnimation.value,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: _currentRoom != null ? _sendMessage : null,
                          icon: const Icon(Icons.send,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDestructionButton(
      String label, Color color, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        constraints: const BoxConstraints(
          minWidth: 36,
          maxWidth: 55,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          border: Border.all(color: color, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    // PRIMERO: Desbloquear capturas automáticamente al salir
    _screenshotService.enableScreenshots().then((_) {
      // Capturas de pantalla desbloqueadas al salir
    }).catchError((error) {
      // Error desbloqueando capturas
    });

    // SEGUNDO: Limpiar timer de monitoreo de callbacks
    if (_callbackCheckTimer != null) {
      _callbackCheckTimer!.cancel();
      _callbackCheckTimer = null;
    }

    // TERCERO: Detener grabación si está activa
    if (_isRecording && _audioRecorder != null) {
      try {
        _audioRecorder!.stopRecorder();
        _isRecording = false;
      } catch (e) {
        // Error deteniendo grabación
      }
    }

    // CUARTO: Limpiar controladores UI
    try {
      _messageController.dispose();
      _scrollController.dispose();
      _sendButtonController.dispose();
      _audioButtonController.dispose();
    } catch (e) {
      // Error limpiando controladores
    }

    // QUINTO: Cerrar grabador de audio de forma segura
    if (_audioRecorder != null) {
      try {
        _audioRecorder!.closeRecorder().then((_) {
          // Grabador cerrado correctamente
        }).catchError((error) {
          // Error cerrando grabador
        });
      } catch (e) {
        // Error en dispose del grabador
      }
    }

    // NUEVO: Cerrar reproductor de audio de forma segura
    if (_audioPlayer != null) {
      try {
        _stopAudioPlayback(); // Detener cualquier reproducción activa
        _audioPlayer!.closePlayer().then((_) {
          // Reproductor cerrado correctamente
        }).catchError((error) {
          // Error cerrando reproductor
        });
      } catch (e) {
        // Error en dispose del reproductor
      }
    }

    // SEXTO: Limpiar servicios de forma inteligente
    try {
      // IMPORTANTE: Solo cerrar el servicio de chat si NO es compartido
      if (!_isSharedChatService) {
        _chatService.dispose();
      } else {
        // Solo limpiar callbacks pero no cerrar el servicio
        _chatService.onRoomCreated = null;
        _chatService.onMessageReceived = null;
        _chatService.onRoomDestroyed = null;
        _chatService.onError = null;
      }

      // Siempre cerrar servicios locales (no compartidos)
      _encryptionService.dispose();
      _screenshotService.dispose();

      // NUEVO: Limpiar servicio de notificaciones de capturas
      ScreenshotNotificationService.instance.dispose();
    } catch (e) {
      // Error limpiando servicios
    }

    super.dispose();
  }

  // NUEVO: Reproducir mensaje de audio
  Future<void> _playAudioMessage(EphemeralMessage message) async {
    if (!_isPlayerInitialized || _audioPlayer == null) {
      _showError(AppLocalizations.of(context)!.audioPlayerNotAvailable);
      return;
    }

    if (message.mediaData == null) {
      _showError(AppLocalizations.of(context)!.audioNotAvailable);
      return;
    }

    try {
      // Si ya está reproduciendo algo, detenerlo
      if (_currentlyPlayingMessageId != null) {
        await _stopAudioPlayback();
      }

      setState(() {
        _currentlyPlayingMessageId = message.id;
      });

      // NUEVO: Configurar audio session antes de reproducir (especialmente importante en iOS)
      await _configureAudioSessioniOS();

      if (kIsWeb) {
        // En web, usar reproducción desde bytes
        await _audioPlayer!.startPlayer(
          fromDataBuffer: message.mediaData!,
          codec: Codec.opusWebM,
          whenFinished: () {
            setState(() {
              _currentlyPlayingMessageId = null;
            });
          },
        );
      } else {
        // En móvil, crear archivo temporal y reproducir
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/temp_audio_${message.id}.aac');

        // Escribir datos de audio al archivo temporal
        await tempFile.writeAsBytes(message.mediaData!);

        // NUEVO: Configurar volumen y altavoz para iOS como WhatsApp
        await _audioPlayer!.setVolume(1.0); // Volumen máximo

        // Reproducir desde archivo
        await _audioPlayer!.startPlayer(
          fromURI: tempFile.path,
          codec: Codec.aacADTS,
          whenFinished: () {
            setState(() {
              _currentlyPlayingMessageId = null;
            });

            // Limpiar archivo temporal
            try {
              tempFile.deleteSync();
            } catch (e) {
              // Error limpiando archivo temporal
            }
          },
        );
      }
    } catch (e) {
      setState(() {
        _currentlyPlayingMessageId = null;
      });
      _showError(AppLocalizations.of(context)!.errorPlayingAudio(e.toString()));
    }
  }

  // NUEVO: Detener reproducción de audio
  Future<void> _stopAudioPlayback() async {
    if (_audioPlayer != null && _currentlyPlayingMessageId != null) {
      try {
        await _audioPlayer!.stopPlayer();
      } catch (e) {
        // Error deteniendo reproducción
      }

      setState(() {
        _currentlyPlayingMessageId = null;
      });
    }
  }

  // NUEVO: Autoreproducir audio al recibir mensaje
  Future<void> _autoPlayReceivedAudio(EphemeralMessage message) async {
    // Solo autoreproducir audios que no sean míos
    if (message.senderId != 'me' && message.messageType == 'audio') {
      // Esperar un poco para que la UI se actualice
      await Future.delayed(const Duration(milliseconds: 500));

      await _playAudioMessage(message);
    }
  }

  // NUEVO: Configurar audio session para iOS (como WhatsApp)
  Future<void> _configureAudioSessioniOS() async {
    if (kIsWeb) return;

    try {
      // Configurar volumen alto para asegurar que se escuche bien
      await _audioPlayer!.setVolume(1.0); // Volumen máximo
    } catch (e) {
      // Error configurando audio session
    }
  }

  // NUEVO: Test de notificaciones de capturas
  void _testScreenshotNotification() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final nickname = authProvider.user?.nickname ?? 'Usuario';

      // Enviar mensaje de test directamente
      final testMessage = 'SCREENSHOT_NOTIFICATION:$nickname';
      await _chatService.sendMessage(testMessage);

      _showSnackBar(AppLocalizations.of(context)!.screenshotTestSent);
    } catch (e) {
      _showError(AppLocalizations.of(context)!.errorSendingTest(e.toString()));
    }
  }
}
