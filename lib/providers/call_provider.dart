import 'dart:convert';
import 'dart:async'; // Importar para usar Timer
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutterputter/models/user.dart';
import 'package:flutterputter/services/call_service.dart';
import 'package:flutterputter/services/socket_service.dart';
import 'package:flutterputter/services/api_service.dart';
import 'package:flutterputter/services/permission_service.dart';

enum CallState {
  idle,
  connecting,
  connected,
  disconnected,
  error,
}

class CallProvider extends ChangeNotifier {
  // Estado
  CallState _callState = CallState.idle;
  String? _callId;
  String? _error;
  User? _remoteUser;
  Map<String, dynamic>? _iceServers;
  String? _token;

  // Control para evitar llamadas duplicadas
  bool _isProcessingCall = false;
  Timer? _callCooldownTimer;

  // WebRTC
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  bool _isMicMuted = false;
  bool _isCameraOff = false;
  bool _isSpeakerOn = true;

  // Servicios
  late CallService _callService;
  late SocketService _socketService;

  CallProvider() {
    _callService = CallService();
  }

  // Getters
  CallState get callState => _callState;
  String? get callId => _callId;
  String? get error => _error;
  User? get remoteUser => _remoteUser;
  MediaStream? get localStream => _localStream;
  MediaStream? get remoteStream => _remoteStream;
  bool get isMicMuted => _isMicMuted;
  bool get isCameraOff => _isCameraOff;
  bool get isSpeakerOn => _isSpeakerOn;
  bool get isProcessingCall => _isProcessingCall;
  RTCPeerConnection? get peerConnection => _peerConnection;

  // Iniciar una llamada
  Future<bool> initiateCall(String receiverId, String token,
      {bool isVideo = true}) async {
    // Evitar múltiples llamadas simultáneas o en rápida sucesión
    if (_isProcessingCall) {
      return false;
    }

    if (_callCooldownTimer != null && _callCooldownTimer!.isActive) {
      return false;
    }

    _isProcessingCall = true;
    _startCallCooldown();

    try {
      _callState = CallState.connecting;
      _token = token;
      notifyListeners();

      final data = await _callService.initiateCall(receiverId, token);

      // Validar datos críticos para prevenir errores de tipo
      if (data['callId'] == null) {
        _error = 'Error: respuesta no contiene ID de llamada';
        _callState = CallState.error;
        notifyListeners();
        return false;
      }

      _callId = data['callId'];

      // Validar iceServers antes de asignar
      if (data.containsKey('turnConfig') && data['turnConfig'] != null) {
        _iceServers = data['turnConfig'];
      } else {
        // Usar configuración por defecto
        _iceServers = {
          'iceServers': [
            {'urls': 'stun:stun.clubprivado.ws:3478'}
          ]
        };
      }

      // Validar datos del receptor antes de convertir
      if (data.containsKey('receiver') && data['receiver'] != null) {
        try {
          _remoteUser = User.fromJson(data['receiver']);
        } catch (e) {
          _error = 'Error al procesar datos del usuario';
          _callState = CallState.error;
          notifyListeners();
          return false;
        }
      } else if (data.containsKey('remoteUserId') &&
          data['remoteUserId'] != null) {
        // Obtener datos del usuario remoto usando el ID proporcionado
        try {
          final remoteUserId = data['remoteUserId'];

          final userResponse =
              await ApiService.get('/api/users/$remoteUserId', token);

          if (userResponse.statusCode == 200 && userResponse.body.isNotEmpty) {
            final userData = jsonDecode(userResponse.body);
            _remoteUser = User.fromJson(userData);
          } else {
            _error = 'Error: no se pudo obtener información del receptor';
            _callState = CallState.error;
            notifyListeners();
            return false;
          }
        } catch (e) {
          _error = 'Error: no se pudo obtener información del receptor';
          _callState = CallState.error;
          notifyListeners();
          return false;
        }
      } else {
        _error = 'Error: no se pudo obtener información del receptor';
        _callState = CallState.error;
        notifyListeners();
        return false;
      }

      // Validar token específico de llamada
      if (data.containsKey('token') && data['token'] != null) {
        _token = data['token'];
      } else {
        // Continuamos con el token original
      }

      // Iniciar WebRTC
      await _initializeWebRTC(isVideo: isVideo);

      // Crear oferta
      await _createOffer();

      _callState = CallState.connected;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error de conexión: $e';
      _callState = CallState.error;
      notifyListeners();
      return false;
    } finally {
      _isProcessingCall = false;
    }
  }

  // Iniciar temporizador para evitar llamadas consecutivas rápidas
  void _startCallCooldown() {
    _callCooldownTimer?.cancel();
    _callCooldownTimer = Timer(const Duration(seconds: 3), () {
      // Este temporizador evita que se inicien múltiples llamadas rápidamente
    });
  }

  // Aceptar una llamada entrante
  Future<bool> acceptCall(String callId, String token,
      {bool isVideo = true}) async {
    // Evitar múltiples llamadas simultáneas
    if (_isProcessingCall) {
      return false;
    }

    _isProcessingCall = true;

    try {
      // IMPORTANTE: Verificar si ya tenemos un SocketService establecido

      _callState = CallState.connecting;
      _callId = callId;
      _token = token;
      notifyListeners();

      // Obtener información del llamante antes de proceder
      final socketCallData = SocketService.getIncomingCallData(callId);
      final callerId = socketCallData?['initiatorId'];
      if (callerId != null) {
        // Información del llamante
      }

      final data = await _callService.acceptCall(callId, token);

      // Validar iceServers antes de asignar
      if (data.containsKey('turnConfig') && data['turnConfig'] != null) {
        _iceServers = data['turnConfig'];
      } else {
        // Usar configuración por defecto
        _iceServers = {
          'iceServers': [
            {'urls': 'stun:stun.clubprivado.ws:3478'}
          ]
        };
      }

      // Validar datos del emisor antes de convertir
      if (data.containsKey('caller') && data['caller'] != null) {
        try {
          _remoteUser = User.fromJson(data['caller']);
        } catch (e) {
          _error = 'Error al procesar datos del usuario';
          _callState = CallState.error;
          notifyListeners();
          return false;
        }
      } else if (data.containsKey('initiatorId') &&
          data['initiatorId'] != null) {
        // Obtener datos del usuario emisor usando el ID proporcionado
        try {
          final initiatorId = data['initiatorId'];

          final userResponse =
              await ApiService.get('/api/users/$initiatorId', token);

          if (userResponse.statusCode == 200 && userResponse.body.isNotEmpty) {
            final userData = jsonDecode(userResponse.body);
            _remoteUser = User.fromJson(userData);
          } else {
            _error = 'Error: no se pudo obtener información del emisor';
            _callState = CallState.error;
            notifyListeners();
            return false;
          }
        } catch (e) {
          _error = 'Error: no se pudo obtener información del emisor';
          _callState = CallState.error;
          notifyListeners();
          return false;
        }
      } else {
        // Intentar obtener el ID del iniciador del callId
        try {
          // Primero verificar si hay datos disponibles en SocketService
          final socketCallData = SocketService.getIncomingCallData(callId);
          if (socketCallData != null &&
              socketCallData.containsKey('initiatorId')) {
            final initiatorId = socketCallData['initiatorId'];

            final userResponse =
                await ApiService.get('/api/users/$initiatorId', token);

            if (userResponse.statusCode == 200 &&
                userResponse.body.isNotEmpty) {
              final userData = jsonDecode(userResponse.body);
              _remoteUser = User.fromJson(userData);
              // Continuar con WebRTC - ya tenemos el usuario
            } else {
              _error = 'Error: no se pudo obtener información del emisor';
              _callState = CallState.error;
              notifyListeners();
              return false;
            }
          } else {
            _error = 'Error: no se pudo obtener información del emisor';
            _callState = CallState.error;
            notifyListeners();
            return false;
          }
        } catch (e) {
          _error = 'Error: no se pudo obtener información del emisor';
          _callState = CallState.error;
          notifyListeners();
          return false;
        }
      }

      // Validar token específico de llamada
      if (data.containsKey('token') && data['token'] != null) {
        _token = data['token'];
      } else {
        // Continuamos con el token original
      }

      // Iniciar WebRTC
      await _initializeWebRTC(isVideo: isVideo);

      _callState = CallState.connected;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error de conexión: $e';
      _callState = CallState.error;
      notifyListeners();
      return false;
    } finally {
      _isProcessingCall = false;
    }
  }

  // Rechazar una llamada entrante
  Future<bool> rejectCall(String callId, String token) async {
    try {
      return await _callService.rejectCall(callId, token);
    } catch (e) {
      _error = 'Error al rechazar llamada: $e';
      notifyListeners();
      return false;
    }
  }

  // Finalizar una llamada en curso
  Future<bool> endCall() async {
    if (_callId == null || _token == null) {
      // Aún así, actualizar estado para que la UI se actualice
      _callState = CallState.idle;
      notifyListeners();
      return false;
    }

    try {
      // IMPORTANTE: Actualizar estado INMEDIATAMENTE para que la UI responda
      _callState = CallState.disconnected;
      notifyListeners();

      // IMPORTANTE: Enviar evento end-call a través del socket ANTES de limpiar
      _socketService.sendEndCall(_callId!);

      // Cerrar conexión WebRTC
      await _disposeWebRTC();

      // Finalizar llamada con el servicio
      await _callService.endCall(_callId!, _token!);

      // Actualizar estado final
      _callState = CallState.idle;
      notifyListeners(); // IMPORTANTE: Notificar el estado final

      // Limpiar variables después de notificar
      _callId = null;
      _remoteUser = null;
      _error = null;

      return true;
    } catch (e) {
      _error = 'Error al finalizar llamada: $e';
      _callState = CallState.idle; // Cambiar a idle incluso con error
      notifyListeners();
      return false;
    }
  }

  // Inicializar WebRTC
  Future<void> _initializeWebRTC({bool isVideo = true}) async {
    try {
      // Verificar que tengamos todos los datos necesarios
      if (_token == null) {
        _error = 'Error: token no disponible para inicializar WebRTC';
        _callState = CallState.error;
        notifyListeners();
        return;
      }

      if (_remoteUser == null) {
        _error = 'Error: información del usuario remoto no disponible';
        _callState = CallState.error;
        notifyListeners();
        return;
      }

      // Solicitar permisos de manera proactiva, especialmente importante en web
      if (kIsWeb) {
        final permisos =
            await PermissionService().requestMediaPermissions(video: isVideo);

        if (!permisos['audio']! && !permisos['video']!) {
          _error =
              'Error: No se otorgaron permisos de cámara ni micrófono. Verifique la configuración de su navegador.';
          _callState = CallState.error;
          notifyListeners();
          return;
        }

        // Si se solicitó video pero solo se obtuvo audio, ajustar el modo
        if (isVideo && !permisos['video']!) {
          isVideo = false;
        }
      }

      // Configurar conexión WebRTC
      final config = <String, dynamic>{
        'iceServers': _iceServers?['iceServers'] ??
            [
              {'urls': 'stun:stun.clubprivado.ws:3478'}
            ],
      };

      _peerConnection = await createPeerConnection(config);

      if (_peerConnection == null) {
        _error = 'Error: No se pudo crear la conexión WebRTC';
        _callState = CallState.error;
        notifyListeners();
        return;
      }

      // CRÍTICO: En web, esperar a que el peerConnection se inicialice completamente
      if (kIsWeb) {
        await Future.delayed(const Duration(milliseconds: 100));

        // En web, verificar que el peerConnection esté realmente funcional
        // intentando acceder a sus métodos básicos
        try {
          // Intentar obtener estado de conexión - esto fuerza la inicialización
          // final state = await _peerConnection!.getConnectionState();
        } catch (e) {
          // Esperar un poco más para la inicialización
          await Future.delayed(const Duration(milliseconds: 300));
        }
      }

      // IMPORTANTE: Usar el SocketService existente si ya fue establecido

      _socketService.updatePeerConnection(_peerConnection!);

      // Configurar eventos de WebRTC
      _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
        if (candidate.candidate == null) {
          return;
        }

        if (_callId == null || _token == null || _remoteUser == null) {
          return;
        }

        // Obtener el ID de usuario del token JWT
        String userId = _extractUserIdFromToken(_token!);

        _socketService.sendIceCandidate(
          _callId!,
          userId, // Usamos el ID de usuario extraído del token
          _remoteUser!.id, // ID del usuario remoto
          candidate,
        );
      };

      // CRÍTICO: Configurar onTrack ANTES de añadir tracks locales
      _peerConnection!.onTrack = (RTCTrackEvent event) {
        if (event.streams.isNotEmpty) {
          _remoteStream = event.streams[0];
          notifyListeners();
        } else {
          // En algunos casos, el stream puede estar vacío pero el track es válido
          // Crear un stream artificial para el track
          if (_remoteStream == null) {
            // El track se manejará automáticamente por el navegador
          }
        }
      };

      // CRÍTICO: También configurar onAddStream como fallback para navegadores que no soportan onTrack correctamente
      _peerConnection!.onAddStream = (MediaStream stream) {
        _remoteStream = stream;
        notifyListeners();
      };

      // Obtener media local con manejo mejorado de errores

      // Lista de estrategias de obtención de medios para probar en orden
      final List<Future<MediaStream> Function()> strategies = [];

      // Estrategia 1: Video y audio con configuración específica
      if (isVideo) {
        strategies.add(() async {
          return await navigator.mediaDevices.getUserMedia({
            'audio': true,
            'video': {
              'facingMode': 'user',
              'width': {'ideal': 640},
              'height': {'ideal': 480}
            },
          });
        });
      }

      // Estrategia 2: Video y audio con configuración básica
      if (isVideo) {
        strategies.add(() async {
          return await navigator.mediaDevices.getUserMedia({
            'audio': true,
            'video': true,
          });
        });
      }

      // Estrategia 3: Solo audio como fallback
      strategies.add(() async {
        return await navigator.mediaDevices.getUserMedia({
          'audio': true,
          'video': false,
        });
      });

      // Intentar cada estrategia en secuencia
      MediaStream? stream;
      String errorDetails = '';

      for (final strategy in strategies) {
        try {
          stream = await strategy();
          break; // Salir del bucle si tenemos un stream
        } catch (e) {
          // Acumular detalles del error
          final errorType = e.toString().contains('NotAllowedError')
              ? 'Permisos denegados'
              : e.toString();

          errorDetails += '$errorType, ';

          // Continuar con la siguiente estrategia
          continue;
        }
      }

      // Verificar si obtuvimos un stream
      if (stream != null) {
        _localStream = stream;

        // Actualizar el estado de video según lo que obtuvimos
        final hasVideo = stream.getVideoTracks().isNotEmpty;
        if (!hasVideo && isVideo) {
          isVideo = false;
        }
      } else {
        // No se pudo obtener ningún tipo de stream
        _error =
            'Error: No se pudo acceder a la cámara ni al micrófono. Por favor, verifique los permisos en su navegador.';
        _callState = CallState.error;
        notifyListeners();
        return;
      }

      if (_localStream == null) {
        _error = 'Error: No se pudo obtener acceso a la cámara/micrófono';
        _callState = CallState.error;
        notifyListeners();
        return;
      }

      // Agregar tracks a la conexión
      _localStream!.getTracks().forEach((track) {
        // final sender = _peerConnection!.addTrack(track, _localStream!);
        _peerConnection!.addTrack(track, _localStream!);
      });

      // CRÍTICO: En web, verificar que los transceivers estén configurados correctamente
      if (kIsWeb) {
        try {
          // final transceivers = await _peerConnection!.getTransceivers();
        } catch (e) {
          // Error obteniendo transceivers
        }
      }

      // IMPORTANTE: Procesar oferta pendiente DESPUÉS de agregar tracks locales
      _socketService.processPendingOfferAfterTracks();

      notifyListeners();
    } catch (e) {
      _error = 'Error al inicializar WebRTC: $e';
      _callState = CallState.error;
      notifyListeners();
    }
  }

  // Crear oferta SDP
  Future<void> _createOffer() async {
    try {
      if (_peerConnection == null) {
        _error = 'Error: peerConnection es nulo al crear oferta';
        _callState = CallState.error;
        notifyListeners();
        return;
      }

      if (_callId == null || _token == null || _remoteUser == null) {
        _error = 'Error: datos de llamada incompletos al crear oferta';
        _callState = CallState.error;
        notifyListeners();
        return;
      }

      final offer = await _peerConnection!.createOffer();
      if (offer.sdp == null || offer.type == null) {
        _error = 'Error: oferta SDP inválida creada';
        _callState = CallState.error;
        notifyListeners();
        return;
      }

      await _peerConnection!.setLocalDescription(offer);

      // Obtener el ID de usuario del token JWT
      String userId = _extractUserIdFromToken(_token!);

      // Asegurarse de que estamos enviando los identificadores correctos

      _socketService.sendOffer(
        _callId!,
        userId, // Usamos el ID de usuario extraído del token
        _remoteUser!.id, // ID del usuario remoto
        offer,
      );
    } catch (e) {
      _error = 'Error al crear oferta: $e';
      _callState = CallState.error;
      notifyListeners();
    }
  }

  // Liberar recursos WebRTC
  Future<void> _disposeWebRTC() async {
    try {
      // Detener todos los tracks locales
      _localStream?.getTracks().forEach((track) {
        track.stop();
      });
      await _localStream?.dispose();
      _localStream = null;

      // Detener todos los tracks remotos
      _remoteStream?.getTracks().forEach((track) {
        track.stop();
      });
      _remoteStream = null;

      // Cerrar la conexión peer
      if (_peerConnection != null) {
        await _peerConnection!.close();
        _peerConnection = null;

        // IMPORTANTE: Limpiar referencia en SocketService para evitar usar peerConnection cerrado
        _socketService.updatePeerConnection(null);
      }
    } catch (e) {
      // Error al liberar recursos WebRTC
    }
  }

  // Silenciar/activar micrófono
  void toggleMic() {
    if (_localStream != null && _localStream!.getAudioTracks().isNotEmpty) {
      final audioTrack = _localStream!.getAudioTracks()[0];
      _isMicMuted = !_isMicMuted;
      audioTrack.enabled = !_isMicMuted;
      notifyListeners();
    }
  }

  // Método para establecer el SocketService existente
  void setSocketService(SocketService socketService) {
    _socketService = socketService;

    // Configurar callback para cuando la llamada termine desde el socket
    _socketService.onCallEnded = _handleCallEndedFromSocket;
  }

  // Manejar cuando la llamada termina desde el socket (otro usuario colgó)
  void _handleCallEndedFromSocket(Map<String, dynamic> data) {
    // Actualizar estado inmediatamente
    _callState = CallState.idle;
    notifyListeners(); // IMPORTANTE: Notificar inmediatamente

    // Limpiar recursos WebRTC de forma asíncrona
    _disposeWebRTC().then((_) {
      // Limpiar variables después de liberar recursos
      _callId = null;
      _remoteUser = null;
      _error = null;
    }).catchError((e) {
      // Error al limpiar recursos WebRTC después de call-ended
    });
  }

  // Activar/desactivar cámara
  void toggleCamera() {
    if (_localStream != null && _localStream!.getVideoTracks().isNotEmpty) {
      final videoTrack = _localStream!.getVideoTracks()[0];
      _isCameraOff = !_isCameraOff;
      videoTrack.enabled = !_isCameraOff;
      notifyListeners();
    }
  }

  // Cambiar salida de audio (altavoz/auricular)
  void toggleSpeaker() {
    _isSpeakerOn = !_isSpeakerOn;
    Helper.setSpeakerphoneOn(_isSpeakerOn);
    notifyListeners();
  }

  // Verificar si el usuario tiene permiso premium para videollamadas
  Future<bool> checkPremiumStatus(String token) async {
    try {
      return await _callService.checkPremiumStatus(token);
    } catch (e) {
      _error = 'Error al verificar estado premium: $e';
      notifyListeners();
      return false;
    }
  }

  // Búsqueda de usuarios por nickname
  Future<List<User>> searchUsers(String nickname, String token) async {
    try {
      final response = await ApiService.get(
        '/api/users/search?nickname=$nickname',
        token,
      );

      // Manejar respuestas vacías o códigos 204/205
      if (response.body.isEmpty ||
          response.statusCode == 204 ||
          response.statusCode == 205) {
        return [];
      }

      if (response.statusCode == 200) {
        try {
          final dynamic decodedData = jsonDecode(response.body);

          // Verificar si es una lista
          if (decodedData is! List) {
            _error = 'Formato de respuesta inesperado en búsqueda de usuarios';
            notifyListeners();
            return [];
          }

          final List<User> users = [];

          // Procesar cada elemento con manejo de errores
          for (final item in decodedData) {
            try {
              if (item is Map<String, dynamic>) {
                users.add(User.fromJson(item));
              } else {
                // Advertencia: se omite elemento no válido en la lista de usuarios
              }
            } catch (e) {
              // Continuamos con el siguiente elemento
            }
          }

          return users;
        } catch (e) {
          _error = 'Error al procesar datos de usuarios';
          notifyListeners();
          return [];
        }
      } else {
        _error = 'Error al buscar usuarios';
        notifyListeners();
        return [];
      }
    } catch (e) {
      _error = 'Error de conexión: $e';
      notifyListeners();
      return [];
    }
  }

  // Extraer ID de usuario de un token JWT
  String _extractUserIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length >= 2) {
        final payload = parts[1];
        final normalized = base64Url.normalize(payload);
        final decodedPayload = utf8.decode(base64Url.decode(normalized));
        final data = jsonDecode(decodedPayload);

        // Intentar extraer userId o id del token
        final userId = data['userId'] ?? data['id'] ?? '';
        return userId;
      }
    } catch (e) {
      // Error al extraer ID de usuario del token
    }
    return token; // Fallback al token completo si no se puede extraer
  }

  @override
  void dispose() {
    _disposeWebRTC();
    _callService.dispose();
    _callCooldownTimer?.cancel();
    super.dispose();
  }
}
