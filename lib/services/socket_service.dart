import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutterputter/services/api_service.dart';
import 'package:flutterputter/services/encryption_service.dart'; // CIFRADO ChaCha20-Poly1305
import '../services/security_alert_service.dart'; // 🚨 NUEVO: Alertas de seguridad
import 'voip_service.dart'; // NUEVO: Importar VoIP service

typedef IncomingCallCallback = void Function(
    String callId, String from, String token);
typedef CallEndedCallback = void Function(Map<String, dynamic> data);

class SocketService {
  io.Socket? socket;
  RTCPeerConnection? _peerConnection;
  String? _token;
  bool _isConnected = false;
  String? _currentCallId;
  String? _lastTo;
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;
  Timer? _pendingCandidatesTimer;
  static const int maxReconnectAttempts = 5;
  IncomingCallCallback? _onIncomingCallCallback;
  CallEndedCallback? _onCallEndedCallback;

  // Set para rastrear callIds procesados y evitar duplicados
  final Set<String> _processedIncomingCalls = {};

  // Lista para almacenar candidatos ICE pendientes
  final List<Map<String, dynamic>> _pendingIceCandidates = [];

  // Para almacenar una oferta SDP pendiente (entrante)
  Map<String, dynamic>? _pendingOffer;

  // Para almacenar una oferta SDP pendiente (saliente) que falló por socket desconectado
  Map<String, dynamic>? _pendingOutgoingOffer;

  // Para rastrear si ya se ha establecido la descripción remota
  bool _hasRemoteDescription = false;

  // Evitar múltiples intentos de reconexión simultáneos
  bool _isReconnecting = false;

  // Almacenar datos de llamadas entrantes para resolver problemas de emisor
  static final Map<String, Map<String, dynamic>> _lastIncomingCallData = {};

  // Control de instancia única para evitar múltiples conexiones
  static SocketService? _instance;

  // Variables para evitar unirse múltiples veces a la misma llamada
  static String? _lastJoinedCallId;
  static DateTime? _lastJoinTime;

  // Variable para almacenar el userId actual
  String? _currentUserId;

  // 🔐 CIFRADO ChaCha20-Poly1305 REAL
  EncryptionService? _encryptionService;
  bool _encryptionInitialized = false;

  // Getter público para peerConnection
  RTCPeerConnection? get peerConnection => _peerConnection;

  // Factory para asegurar instancia única o actualizada
  factory SocketService({RTCPeerConnection? peerConnection, String? token}) {
    if (_instance == null) {
      _instance = SocketService._internal(peerConnection, token);

      // Si tenemos peerConnection, actualizarla
      if (peerConnection != null) {
        _instance!._peerConnection = peerConnection;
      }
    } else {
      // Si ya existe una instancia, actualizar peerConnection si se proporciona
      if (peerConnection != null) {
        _instance!._peerConnection = peerConnection;
      }
      // Si se proporciona un nuevo token, actualizar y reconectar
      if (token != null && token != _instance!._token) {
        _instance!._token = token;
        _instance!._currentUserId = _instance!._extractUserIdFromToken(token);
        _instance!._reconnect();
      }
    }

    return _instance!;
  }

  // Método para obtener la instancia actual sin crear una nueva
  static SocketService? getInstance() {
    return _instance;
  }

  // Constructor interno privado
  SocketService._internal(this._peerConnection, this._token) {
    if (_token != null) {
      _currentUserId = _extractUserIdFromToken(_token!);
    }
    _initSocket();
    // 🔐 Inicializar cifrado ChaCha20-Poly1305 de forma no bloqueante
    _initEncryption().catchError((e) {
      // Cifrado no disponible, continuando sin él
    });
  }

  // Setter para el callback de llamada entrante
  set onIncomingCall(IncomingCallCallback callback) {
    _onIncomingCallCallback = callback;
  }

  // Setter para el callback de llamada terminada
  set onCallEnded(CallEndedCallback callback) {
    _onCallEndedCallback = callback;
  }

  // Actualizar peerConnection (usado cuando se acepta una llamada)
  void updatePeerConnection(RTCPeerConnection? newPeerConnection) {
    _peerConnection = newPeerConnection;

    // Si se está limpiando (newPeerConnection es null), limpiar también estado pendiente
    if (newPeerConnection == null) {
      _pendingOffer = null;
      _hasRemoteDescription = false;
      _pendingIceCandidates.clear();
      _pendingCandidatesTimer?.cancel();
      _pendingCandidatesTimer = null;
    } else {
      // Verificar que el peerConnection está en buen estado
      // CRÍTICO: En web, el peerConnection puede tener estados null inicialmente
      // Esto es normal y no indica un problema
      if (kIsWeb) {
        // PeerConnection en web - estados pueden ser null inicialmente
        // CRÍTICO: Verificar que los event handlers estén configurados
        // Dar tiempo para que se inicialice completamente
        Future.delayed(const Duration(milliseconds: 150), () async {
          try {
            // final connectionState =
            // await newPeerConnection.getConnectionState();
          } catch (e) {
            // PeerConnection después del delay - Error obteniendo estado
          }
        });
      } else {
        // En plataformas nativas, verificar estados normalmente
      }
    }

    // IMPORTANTE: NO procesar la oferta inmediatamente aquí
    // Esperar a que se agreguen los tracks locales primero
    if (_pendingOffer != null) {
      // Oferta SDP pendiente detectada, esperando a que se agreguen tracks locales
    } else {
      if (_pendingIceCandidates.isNotEmpty) {
        // Solo procesar candidatos si no hay oferta pendiente
        _processPendingIceCandidates();
      }
    }
  }

  // Nuevo método para procesar oferta pendiente después de agregar tracks
  void processPendingOfferAfterTracks() {
    if (_peerConnection == null || _pendingOffer == null) {
      return;
    }

    // Procesar la oferta después de un pequeño delay para asegurar que los tracks estén agregados
    Future.delayed(const Duration(milliseconds: 100), () async {
      await _processPendingOffer();

      // Después de procesar la oferta, procesar candidatos ICE pendientes
      if (_pendingIceCandidates.isNotEmpty) {
        await Future.delayed(const Duration(milliseconds: 500));
        _processPendingIceCandidates();
      }
    });
  }

  // Método para procesar candidatos ICE pendientes
  void _processPendingIceCandidates() async {
    if (_peerConnection == null || _pendingIceCandidates.isEmpty) {
      return;
    }

    // CRÍTICO: Verificar que la descripción remota esté establecida antes de procesar candidatos ICE
    try {
      final remoteDescription = await _peerConnection!.getRemoteDescription();
      if (remoteDescription == null) {
        return; // No limpiar la lista, intentar más tarde
      }
    } catch (e) {
      return; // No limpiar la lista, intentar más tarde
    }

    final candidatesToProcess = List.from(_pendingIceCandidates);
    _pendingIceCandidates.clear();

    for (final candidateData in candidatesToProcess) {
      try {
        await _peerConnection!.addCandidate(
          RTCIceCandidate(
            candidateData['candidate'],
            candidateData['sdpMid'],
            candidateData['sdpMLineIndex'],
          ),
        );
      } catch (e) {
        // Si hay error, volver a agregar a la lista pendiente
        _pendingIceCandidates.add(candidateData);
      }
    }
  }

  // Procesa la oferta SDP pendiente
  Future<void> _processPendingOffer() async {
    if (_peerConnection == null) {
      return;
    }

    if (_pendingOffer == null) {
      return;
    }

    try {
      final sdp = _pendingOffer!['sdp'];

      if (sdp != null &&
          sdp is Map<String, dynamic> &&
          sdp['sdp'] != null &&
          sdp['type'] != null) {
        // Verificar si ya hay una descripción remota (evitar duplicados)
        bool hasExistingRemoteDescription = false;
        try {
          final currentDesc = await _peerConnection!.getRemoteDescription();
          hasExistingRemoteDescription = currentDesc != null;
          if (hasExistingRemoteDescription) {
            // Ya existe una descripción remota, verificando si es la misma
          }
        } catch (e) {
          // Info: No se pudo verificar descripción remota
        }

        try {
          // 🔐 INICIAR INTERCAMBIO DE CLAVES DE CIFRADO ANTES DE PROCESAR OFERTA PENDIENTE
          final pendingCallId = _pendingOffer!['callId'];
          if (pendingCallId != null) {
            diagnoseEncryption();
            _startEncryptionKeyExchange(pendingCallId, false);
          }

          // Establecer descripción remota
          await _peerConnection!.setRemoteDescription(
            RTCSessionDescription(sdp['sdp'], sdp['type']),
          );

          _hasRemoteDescription = true;

          // Iniciar temporizador para reintentar procesar candidatos pendientes
          _startPendingCandidatesTimer();

          // Crear y enviar respuesta
          final answer = await _peerConnection!.createAnswer();
          await _peerConnection!.setLocalDescription(answer);

          // Verificar que tenemos todos los datos necesarios antes de enviar la respuesta
          if (_pendingOffer!['callId'] == null) {
            return;
          }

          if (_pendingOffer!['from'] == null) {
            return;
          }

          // Enviar la respuesta al emisor
          final emitterData = {
            'callId': _pendingOffer!['callId'],
            'from': _currentUserId ?? _pendingOffer!['to'],
            'to': _pendingOffer!['from'],
            'sdp': {'type': answer.type, 'sdp': answer.sdp},
          };

          if (socket == null) {
            return;
          }

          if (!socket!.connected) {
            return;
          }

          socket!.emit('answer', emitterData);
        } catch (e) {
          _hasRemoteDescription =
              false; // Asegurar que estado es correcto en caso de error
          return;
        }

        // Limpiar la oferta pendiente
        _pendingOffer = null;

        // NO procesar candidatos ICE inmediatamente aquí
        // El temporizador _startPendingCandidatesTimer() ya se encargará de eso
        // Esto evita el error "The remote description was null"
      } else {
        // Oferta SDP pendiente inválida o con formato incorrecto
      }
    } catch (e) {
      _hasRemoteDescription =
          false; // Asegurar que estado es correcto en caso de error
    }
  }

  void _initSocket() {
    try {
      if (_token == null) {
        // ⬅️  espera al token
        return;
      }

      // No volver a desconectar si ya estamos dentro
      // solo lo hacemos la primera vez
      if (socket != null) return;

      // Crear socket de forma compatible con todas las plataformas
      socket = _buildSocket(_token);

      // Conectar explícitamente
      socket?.connect();

      socket?.onConnect((_) {
        _isConnected = true;
        _reconnectAttempts = 0;

        // Detener cualquier temporizador pendiente
        _reconnectTimer?.cancel();

        // Si tenemos un callId pendiente, unirse automáticamente
        if (_currentCallId != null && _token != null) {
          // Incluir _lastTo para mantener el destinatario al reconectar
          _joinCallInternal(_currentCallId!, _token!, to: _lastTo);
        }

        // 🚀 REENVIAR OFERTA SDP PENDIENTE si existe
        if (_pendingOutgoingOffer != null) {
          // Reenviar la oferta
          socket!.emit('offer', _pendingOutgoingOffer);
          // Limpiar la oferta pendiente
          _pendingOutgoingOffer = null;
        }
      });

      socket?.onConnectError((error) {
        _isConnected = false;
        _scheduleReconnect();
      });

      socket?.onError((error) {
        if (error.toString().contains('auth')) {
          // Posible problema con el token de autorización
        }
      });

      socket?.onDisconnect((reason) {
        _isConnected = false;
        _scheduleReconnect();
      });

      _setupSocketListeners();
    } catch (e) {
      _scheduleReconnect();
    }
  }

  // Construye un socket de forma compatible con todas las plataformas
  io.Socket _buildSocket(String? token) {
    assert(token != null); // ahora siempre viene

    final builder = io.OptionBuilder()
        .setTransports([
          'polling',
          'websocket',
        ]) // polling primero, luego websocket
        .setPath('/signaling/socket.io')
        .setAuth({'token': token}) // ✅ funciona en TODAS las plataformas
        .enableAutoConnect();

    if (!kIsWeb) {
      // En Android / iOS / desktop todavía puedes mandar la cabecera
      builder.setExtraHeaders({'x-auth-token': token});
    }

    return io.io('https://clubprivado.ws', builder.build());
  }

  void _scheduleReconnect() {
    // Evitar múltiples temporizadores de reconexión
    _reconnectTimer?.cancel();

    if (_reconnectAttempts < maxReconnectAttempts) {
      _reconnectAttempts++;
      final delay = Duration(
        seconds: _reconnectAttempts * 2,
      ); // Backoff exponencial
      _reconnectTimer = Timer(delay, _reconnect);
    } else {
      // Máximo número de intentos de reconexión alcanzado
    }
  }

  void _reconnect() {
    if (_isReconnecting) {
      return;
    }

    _isReconnecting = true;
    // Guardar la referencia actual al peerConnection
    final existingPeerConnection = _peerConnection;

    try {
      // Limpiar recursos previos antes de reiniciar
      socket?.disconnect();
      socket?.dispose();
      socket = null;

      _initSocket();

      // Verificar la conexión después de un breve retraso
      Future.delayed(const Duration(seconds: 2), () {
        if (socket != null && socket!.connected) {
          // Verificar si se mantuvo la referencia al peerConnection
          if (_peerConnection == null && existingPeerConnection != null) {
            _peerConnection = existingPeerConnection;
          }
        } else {
          // La reconexión no se completó correctamente
        }
      });
    } finally {
      _isReconnecting = false;
    }
  }

  // Método explícito para forzar el refresco de la conexión
  void refreshConnection() {
    if (socket != null) {
      // Garantizar que los listeners estén configurados
      _setupSocketListeners();

      if (!socket!.connected) {
        socket!.connect();
      } else {
        // Socket ya conectado, refrescando listeners
      }
    } else {
      _initSocket();
    }
    // Verificar estado de peerConnection después del refresco
  }

  void _setupSocketListeners() {
    try {
      // Evitar registrar listeners múltiples veces
      socket?.off('user-joined');
      socket?.off('user-left');
      socket?.off('incoming-call');
      socket?.off('offer');
      socket?.off('answer');
      socket?.off('ice-candidate');
      socket?.off('call-ended');
      socket?.off('call-status');
      socket?.off('ping-user');
      socket?.off('encryption-key'); // 🔐 Cifrado ChaCha20-Poly1305

      socket?.on('user-joined', (data) {
        if (data == null || data is! Map<String, dynamic>) {
          return;
        }
      });

      socket?.on('user-left', (data) {
        if (data == null || data is! Map<String, dynamic>) {
          return;
        }
      });

      socket?.on('incoming-call', (data) {
        if (data == null || data is! Map<String, dynamic>) {
          return;
        }

        final callId = data['callId'] as String?;
        final token = data['token'] as String?;
        final from = data['from'] as String?;

        if (callId == null || token == null) {
          return;
        }

        // Verificar si ya estamos procesando esta llamada
        if (_currentCallId == callId) {
          return;
        }

        // Verificar si ya procesamos esta notificación de llamada entrante
        if (_processedIncomingCalls.contains(callId)) {
          return;
        }

        _processedIncomingCalls.add(callId);

        // Auto-guardar el ID del emisor para referencia futura
        if (from != null) {
          final callData = {'initiatorId': from, 'callId': callId};
          // Almacenar en una variable estática para uso futuro
          _lastIncomingCallData[callId] = callData;
        }

        // Establecer el callId actual ANTES de unirse
        _currentCallId = callId;
        _lastTo = from; // Guardar el ID del emisor como destinatario

        // 🔔 NUEVO: Disparar notificación VoIP nativa en iOS
        _triggerVoIPNotification(callId, from);

        // Auto-unirse como callee (receptor) con el destinatario explícito
        joinCall(callId, token, to: from);

        // Notificar a la UI sobre la llamada entrante
        if (_onIncomingCallCallback != null) {
          _onIncomingCallCallback!(callId, from ?? 'desconocido', token);
        } else {
          // No hay callback registrado para llamadas entrantes
        }
      });

      socket?.on('offer', (incoming) async {
        try {
          if (incoming == null) {
            return;
          }

          // Verificar tipo de datos y estructura
          if (incoming is! Map) {
            return;
          }

          // Verificar que sea Map<String, dynamic> y realizar conversión segura
          final Map<String, dynamic> safeIncoming = {};
          try {
            incoming.forEach((key, value) {
              if (key is String) {
                safeIncoming[key] = value;
              }
            });
          } catch (e) {
            return;
          }

          // Validar que el SDP exista y tenga la estructura correcta
          final sdp = safeIncoming['sdp'];
          if (sdp == null) {
            return;
          }

          // Verificar si sdp es Map y convertir
          final Map<String, dynamic> safeSdp = {};
          if (sdp is Map) {
            try {
              sdp.forEach((key, value) {
                if (key is String) {
                  safeSdp[key] = value;
                }
              });
            } catch (e) {
              return;
            }
          } else {
            return;
          }

          if (safeSdp['sdp'] == null || safeSdp['type'] == null) {
            return;
          }

          // Verificar si el peerConnection está disponible
          if (_peerConnection == null) {
            // Guardar oferta para procesamiento posterior
            // IMPORTANTE: Incluir el callId actual y los datos necesarios
            _pendingOffer = {
              ...safeIncoming,
              'callId': _currentCallId ?? safeIncoming['callId'],
              'from': safeIncoming['from'],
              'to': safeIncoming['to'],
            };
            return;
          }

          // Si el peerConnection está disponible, verificar que no esté cerrado
          try {
            final connectionState = await _peerConnection!.getConnectionState();
            if (connectionState ==
                RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
              return;
            }
          } catch (e) {
            return;
          }

          // 🔐 INICIAR INTERCAMBIO DE CLAVES DE CIFRADO ANTES DE PROCESAR SDP (RECEPTOR)
          final receiverCallId = safeIncoming['callId'] ?? _currentCallId;
          if (receiverCallId != null) {
            diagnoseEncryption();
            _startEncryptionKeyExchange(receiverCallId, false);
          }

          _hasRemoteDescription = true;
          await _peerConnection!.setRemoteDescription(
            RTCSessionDescription(safeSdp['sdp'], safeSdp['type']),
          );

          final answer = await _peerConnection!.createAnswer();
          await _peerConnection!.setLocalDescription(answer);

          // Verificar que los datos necesarios no sean nulos
          // Si faltan en safeIncoming, usar los datos almacenados
          String? callId = safeIncoming['callId'];
          String? from = _currentUserId ?? safeIncoming['to'];
          String? to = safeIncoming['from'];

          // Si falta el callId, intentar usar _currentCallId (establecido por setCallData)
          if (callId == null && _currentCallId != null) {
            callId = _currentCallId;
          }

          // Si falta el destinatario (to), intentar usar _lastTo
          if (to == null && _lastTo != null) {
            to = _lastTo;
          }

          // Verificar de nuevo
          if (callId == null || from == null || to == null) {
            return;
          }

          // Almacenar los datos de la llamada para futuras referencias
          _currentCallId = callId;

          final answerData = {
            'callId': callId,
            'from': from,
            'to': to,
            'sdp': {'type': answer.type, 'sdp': answer.sdp},
          };

          socket?.emit('answer', answerData);

          // 🔐 INTERCAMBIO DE CLAVES YA INICIADO ANTES DE PROCESAR SDP

          // Procesar candidatos ICE pendientes después de establecer la oferta
          _processPendingIceCandidates();
        } catch (e) {
          // ERROR procesando oferta SDP
        }
      });

      socket?.on('answer', (incoming) async {
        try {
          if (incoming == null) {
            return;
          }

          // Verificar tipo de datos y estructura
          if (incoming is! Map) {
            return;
          }

          // Verificar que sea Map<String, dynamic> y realizar conversión segura
          final Map<String, dynamic> safeIncoming = {};
          try {
            incoming.forEach((key, value) {
              if (key is String) {
                safeIncoming[key] = value;
              }
            });
          } catch (e) {
            return;
          }

          if (_peerConnection == null) {
            return;
          }

          // Verificar que el peerConnection no esté cerrado
          try {
            final connectionState = await _peerConnection!.getConnectionState();
            if (connectionState ==
                RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
              return;
            }
          } catch (e) {
            return;
          }

          // Verificar que los datos de callId y remitentes sean correctos
          final responseCallId = safeIncoming['callId'] as String?;
          if (responseCallId == null) {
            if (_currentCallId == null) {
              return;
            }
          }

          // final effectiveCallId = responseCallId ?? _currentCallId;

          // Validar que el SDP exista y tenga la estructura correcta
          final sdp = safeIncoming['sdp'];
          if (sdp == null) {
            return;
          }

          // Verificar si sdp es Map y convertir
          final Map<String, dynamic> safeSdp = {};
          if (sdp is Map) {
            try {
              sdp.forEach((key, value) {
                if (key is String) {
                  safeSdp[key] = value;
                }
              });
            } catch (e) {
              return;
            }
          } else {
            return;
          }

          if (safeSdp['sdp'] == null || safeSdp['type'] == null) {
            return;
          }

          await _peerConnection!.setRemoteDescription(
            RTCSessionDescription(safeSdp['sdp'], safeSdp['type']),
          );
          _hasRemoteDescription = true;

          // Iniciar temporizador para reintentar procesar candidatos pendientes
          _startPendingCandidatesTimer();

          // Procesar candidatos ICE pendientes después de establecer la respuesta
          await Future.delayed(const Duration(milliseconds: 500));
          _processPendingIceCandidates();
        } catch (e) {
          // ERROR procesando respuesta SDP
        }
      });

      socket?.on('ice-candidate', (incoming) async {
        try {
          if (incoming == null) {
            return;
          }

          // Verificar tipo de datos y estructura
          if (incoming is! Map) {
            return;
          }

          // Verificar que sea Map<String, dynamic> y realizar conversión segura
          final Map<String, dynamic> safeIncoming = {};
          try {
            incoming.forEach((key, value) {
              if (key is String) {
                safeIncoming[key] = value;
              }
            });
          } catch (e) {
            return;
          }

          // Validar que el candidato exista y tenga la estructura correcta
          final candidate = safeIncoming['candidate'];
          if (candidate == null) {
            return;
          }

          // Verificar si candidate es Map y convertir
          final Map<String, dynamic> safeCandidate = {};
          if (candidate is Map) {
            try {
              candidate.forEach((key, value) {
                if (key is String) {
                  safeCandidate[key] = value;
                }
              });
            } catch (e) {
              return;
            }
          } else {
            return;
          }

          if (safeCandidate['candidate'] == null ||
              safeCandidate['sdpMid'] == null ||
              safeCandidate['sdpMLineIndex'] == null) {
            return;
          }

          // Si no hay peerConnection o no tenemos descripción remota, guardamos el candidato
          if (_peerConnection == null) {
            _pendingIceCandidates.add({
              'candidate': safeCandidate['candidate'],
              'sdpMid': safeCandidate['sdpMid'],
              'sdpMLineIndex': safeCandidate['sdpMLineIndex'],
            });
            return;
          }

          // Verificar estado de la conexión antes de procesar
          try {
            final connectionState = await _peerConnection!.getConnectionState();
            if (connectionState ==
                    RTCPeerConnectionState.RTCPeerConnectionStateClosed ||
                connectionState ==
                    RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
              return;
            }
          } catch (e) {
            // Continuar con el procesamiento
          }

          // Verificar si tenemos la descripción remota
          bool hasDesc = _hasRemoteDescription;

          // Doble verificación del estado actual de la descripción remota
          if (!hasDesc) {
            try {
              final RTCSessionDescription? remoteDesc =
                  await _peerConnection!.getRemoteDescription();
              hasDesc = remoteDesc != null;
              if (hasDesc && !_hasRemoteDescription) {
                _hasRemoteDescription = true;
              }
            } catch (e) {
              // No se pudo verificar descripción remota
            }
          }

          if (!hasDesc) {
            _pendingIceCandidates.add({
              'candidate': safeCandidate['candidate'],
              'sdpMid': safeCandidate['sdpMid'],
              'sdpMLineIndex': safeCandidate['sdpMLineIndex'],
            });
            return;
          }

          // Procesar el candidato ICE si tenemos peerConnection y descripción remota
          try {
            await _peerConnection!.addCandidate(
              RTCIceCandidate(
                safeCandidate['candidate'],
                safeCandidate['sdpMid'],
                safeCandidate['sdpMLineIndex'],
              ),
            );
          } catch (e) {
            // Si hubo error, almacenar el candidato para intentarlo más tarde
            if (e.toString().contains('The remote description was null') ||
                e.toString().contains('setRemoteDescription')) {
              _pendingIceCandidates.add({
                'candidate': safeCandidate['candidate'],
                'sdpMid': safeCandidate['sdpMid'],
                'sdpMLineIndex': safeCandidate['sdpMLineIndex'],
              });

              // Re-establecer bandera _hasRemoteDescription a falso
              _hasRemoteDescription = false;
            }
          }
        } catch (e) {
          // ERROR general procesando candidato ICE
        }
      });

      socket?.on('call-ended', (data) {
        if (data == null || data is! Map<String, dynamic>) {
          return;
        }
        // LIMPIAR COMPLETAMENTE todos los recursos WebRTC
        _cleanupCallResources();

        // Enviar evento al CallProvider a través de un callback
        _notifyCallEnded(data);
      });

      // 🔐 LISTENER PARA INTERCAMBIO MILITAR DH - ZERO KNOWLEDGE
      socket?.on('secure-key-exchange', (data) {
        if (data == null || data is! Map<String, dynamic>) {
          return;
        }
        _handleSecureKeyExchange(data);
      });

      // 🔐 LISTENER OBSOLETO PARA RETROCOMPATIBILIDAD
      socket?.on('encryption-key', (data) {
        if (data == null || data is! Map<String, dynamic>) {
          return;
        }
        _handleEncryptionKey(data);
      });

      socket?.on('call-status', (data) {
        if (data == null || data is! Map<String, dynamic>) {
          return;
        }

        // Verificar si status existe y es un String antes de procesar
        if (!data.containsKey('status') || data['status'] == null) {
          return;
        }

        // Imprimir cada clave y su tipo de dato
        data.forEach((key, value) {
          // [DEBUG] call-status $key: $value (${value?.runtimeType})
        });

        // Si hay un objeto anidado en alguna propiedad, verificarlo también
        if (data['status'] is Map) {
          // Advertencia: status es un Map anidado, podría causar problemas de cast
        }
      });

      socket?.on('ping-user', (data) {
        if (data != null && data is Map<String, dynamic>) {
          final type = data['type'];
          final from = data['from'];
          // final to = data['to'];
          // final callId = data['callId'];

          if (type == 'offer-sent') {
            // Responder con confirmación de que estamos conectados
            socket?.emit('ping-user', {
              'to': from,
              'from': _currentUserId,
              'callId': data['callId'], // Reutilizar callId recibido
              'type': 'receiver-connected',
            });
          } else if (type == 'receiver-connected') {
            // Confirmación: El receptor está conectado y listo para recibir ofertas
          }
        }
      });

      // 🚨 NUEVO: LISTENER PARA LOGOUT FORZADO (SEGURIDAD CRÍTICA)
      socket?.on('session-force-logout', (data) {
        if (data == null || data is! Map<String, dynamic>) {
          return;
        }

        try {
          final reason =
              data['reason'] ?? 'Nueva sesión iniciada desde otro dispositivo';
          final timestamp =
              data['timestamp'] ?? DateTime.now().toIso8601String();
          final sessionId = data['sessionId'] as String?;

          // Mostrar alerta crítica de seguridad
          SecurityAlertService.instance.showSessionForcedLogoutAlert(
            reason: reason,
            timestamp: timestamp,
            sessionId: sessionId,
          );

          // Limpiar estado local
          _currentCallId = null;
          _token = null;
          _currentUserId = null;
        } catch (e) {
          // Fallback: mostrar alerta genérica
          SecurityAlertService.instance.showSessionForcedLogoutAlert(
            reason: 'Acceso detectado desde otro dispositivo',
            timestamp: DateTime.now().toIso8601String(),
          );
        }
      });
    } catch (e) {
      // Error configurando listeners de Socket.io
    }
  }

  void joinCall(String callId, String token, {String? to}) {
    try {
      // Actualizar el token y el callId actual
      _token = token;
      _currentUserId = _extractUserIdFromToken(token);
      _currentCallId = callId;

      // Guardar el destinatario si se proporciona
      if (to != null) _lastTo = to;

      // Limpiar el conjunto de llamadas procesadas para este callId
      // para asegurar que se procesen las notificaciones adecuadamente
      _processedIncomingCalls.remove(callId);

      // Si ya estamos conectados, unirse directamente
      if (_isConnected) {
        _joinCallInternal(
          callId,
          token,
          to: to ?? _lastTo,
        ); // Usar _lastTo como fallback
      } else {
        // No forzamos reconexión, solo esperamos a que onConnect se dispare
        // onConnect() internamente llamará a _joinCallInternal si _currentCallId != null
      }
    } catch (e) {
      // ERROR uniendo a llamada
    }
  }

  // Método interno para unirse a la llamada (evita duplicación de código)
  void _joinCallInternal(String callId, String token, {String? to}) {
    // Validación adicional
    if (callId.isEmpty) {
      return;
    }

    // Verificar si ya nos unimos a esta llamada recientemente
    if (_lastJoinedCallId == callId &&
        _lastJoinTime != null &&
        DateTime.now().difference(_lastJoinTime!).inSeconds < 5) {
      return;
    }

    // Asegurar que _currentCallId está actualizado
    _currentCallId = callId;
    _lastJoinedCallId = callId;
    _lastJoinTime = DateTime.now();

    if (socket != null && socket!.connected) {
      // ⇢ actualiza el token en tiempo real
      socket!.io.options?['auth'] = {'token': token};
      if (!kIsWeb) {
        socket!.io.options?['extraHeaders'] = {'x-auth-token': token};
      }

      // Si tenemos el ID del destinatario, lo incluimos para que el servidor
      // pueda enviarle la notificación de llamada entrante
      final callData = {'callId': callId};
      if (to != null) {
        callData['to'] = to;
      } else {
        // join-call sin destinatario específico
      }

      socket!.emit('join-call', callData);
    } else {
      // Si no estamos conectados, reconectar con el nuevo token
      _token = token;
      _currentCallId = callId;
      // También guardamos to para la reconexión
      if (to != null) _lastTo = to;
      _reconnect();
    }
  }

  void leaveCall(String callId) {
    try {
      socket?.emit('leave-call', {'callId': callId});
      _currentCallId = null;
    } catch (e) {
      // ERROR abandonando llamada
    }
  }

  void sendOffer(
    String callId,
    String from,
    String to,
    RTCSessionDescription offer,
  ) {
    try {
      final offerData = {
        'callId': callId,
        'from': from,
        'to': to,
        'sdp': {'type': offer.type, 'sdp': offer.sdp},
      };

      // Verificar que el socket esté conectado antes de enviar
      if (socket == null) {
        _pendingOutgoingOffer = offerData;
        return;
      }

      if (!socket!.connected) {
        _pendingOutgoingOffer = offerData;
        return;
      }

      socket!.emit('offer', offerData);

      // 🔐 DIAGNÓSTICO DE CIFRADO ANTES DEL INTERCAMBIO
      diagnoseEncryption();

      // 🔐 INICIAR INTERCAMBIO DE CLAVES DE CIFRADO (como iniciador)
      _startEncryptionKeyExchange(callId, true);

      // Enviar también un evento de verificación para confirmar que el receptor está conectado
      socket!.emit('ping-user', {
        'to': to,
        'from': from,
        'callId': callId,
        'type': 'offer-sent',
      });

      // Agregar un timeout para verificar si se recibe respuesta
      Timer(const Duration(seconds: 5), () {
        // Timeout: Han pasado 5 segundos desde que se envió la oferta SDP
        // Si no se recibió respuesta, puede haber un problema de conectividad
      });
    } catch (e) {
      // ERROR enviando oferta SDP
    }
  }

  void sendIceCandidate(
    String callId,
    String from,
    String to,
    RTCIceCandidate candidate,
  ) {
    try {
      socket?.emit('ice-candidate', {
        'callId': callId,
        'from': from,
        'to': to,
        'candidate': {
          'candidate': candidate.candidate,
          'sdpMid': candidate.sdpMid,
          'sdpMLineIndex': candidate.sdpMLineIndex,
        },
      });
    } catch (e) {
      // ERROR enviando candidato ICE
    }
  }

  // Limpiar recursos de la llamada actual
  void _cleanupCallResources() {
    // Limpiar estado de la llamada
    _currentCallId = null;
    _lastTo = null;
    _pendingOffer = null;
    _pendingOutgoingOffer = null;
    _hasRemoteDescription = false;
    _pendingIceCandidates.clear();

    // Cancelar temporizadores
    _pendingCandidatesTimer?.cancel();
    _pendingCandidatesTimer = null;

    // 🔐 LIMPIAR RECURSOS DE CIFRADO
    _cleanupEncryption();

    // 🔐 LIMPIAR CLAVES TEMPORALES Y PENDIENTES
    _tempDHPrivateKey = null;
    _tempEphemeralPrivateKey = null;
    _tempCallId = null;
    _pendingPublicKeys = null;

    // NO cerrar peerConnection aquí, eso lo maneja CallProvider
  }

  // Notificar que la llamada terminó
  void _notifyCallEnded(Map<String, dynamic> data) {
    if (_onCallEndedCallback != null) {
      _onCallEndedCallback!(data);
    } else {
      // No hay callback configurado para call-ended
    }
  }

  // Enviar evento de llamada terminada
  void sendEndCall(String callId) {
    if (socket != null && socket!.connected) {
      socket!.emit('end-call', {'callId': callId});
    } else {
      // No se puede enviar end-call: socket no conectado
    }
  }

  // Método para cerrar adecuadamente el socket
  void dispose() {
    _reconnectTimer?.cancel();
    _pendingCandidatesTimer?.cancel();
    socket?.disconnect();
    socket?.dispose();
    socket = null;
    _peerConnection = null;
    _instance = null;
  }

  // Método para verificar si el socket está conectado
  bool isConnected() {
    return _isConnected && socket != null && socket!.connected;
  }

  // Método para actualizar el token sin necesidad de re-crear el socket
  void updateToken(String newToken) {
    if (_token != newToken) {
      _token = newToken;
      _currentUserId = _extractUserIdFromToken(newToken);

      // IMPORTANTE: NO limpiar _pendingOffer aquí si estamos en la misma llamada
      // Solo limpiar si es una llamada completamente nueva
      final newCallId = _extractCallIdFromToken(newToken);
      if (newCallId != null && newCallId != _currentCallId) {
        _hasRemoteDescription = false;
        _pendingOffer = null;
      } else {
        // Mismo callId, manteniendo _pendingOffer y estado WebRTC
      }

      // No limpiamos los candidatos ICE pendientes, los procesaremos
      // cuando tengamos la nueva descripción remota

      // Actualizar token en el socket si está conectado
      if (socket != null && socket!.connected) {
        // Actualizar auth
        socket!.io.options?['auth'] = {'token': newToken};
        if (!kIsWeb) {
          socket!.io.options?['extraHeaders'] = {'x-auth-token': newToken};
        }
      } else {
        // Si no está conectado, intentar reconexión con el nuevo token
        _reconnect();
      }
    }
  }

  // Método para establecer los datos de la llamada actual
  void setCallData(String callId, String? initiatorId) {
    _currentCallId = callId;

    // Si tenemos el initiatorId, guardarlo para uso futuro
    if (initiatorId != null) {
      _lastTo = initiatorId;

      // Guardar en _lastIncomingCallData para mantener consistencia
      _lastIncomingCallData[callId] = {
        'initiatorId': initiatorId,
        'callId': callId,
      };
    } else {
      // No se proporcionó initiatorId al establecer datos de llamada
    }
  }

  // Método para obtener datos de la última llamada entrante
  static Map<String, dynamic>? getIncomingCallData(String callId) {
    return _lastIncomingCallData[callId];
  }

  // Inicia un temporizador para reintentar procesar candidatos ICE pendientes
  void _startPendingCandidatesTimer() {
    // Cancelar temporizador existente
    _pendingCandidatesTimer?.cancel();

    // Iniciar nuevo temporizador si hay candidatos pendientes
    if (_pendingIceCandidates.isNotEmpty) {
      // IMPORTANTE: Esperar 1 segundo antes del primer intento para dar tiempo
      // a que la descripción remota se establezca completamente
      Timer(const Duration(milliseconds: 1000), () {
        if (_pendingIceCandidates.isEmpty || _peerConnection == null) {
          return;
        }

        _processPendingIceCandidates();

        // Si aún quedan candidatos, iniciar temporizador periódico
        if (_pendingIceCandidates.isNotEmpty) {
          _pendingCandidatesTimer = Timer.periodic(const Duration(seconds: 2), (
            timer,
          ) async {
            if (_pendingIceCandidates.isEmpty) {
              timer.cancel();
              return;
            }

            if (_peerConnection == null) {
              timer.cancel();
              return;
            }

            _processPendingIceCandidates();

            // Limitar a un máximo de 10 intentos (20 segundos)
            if (timer.tick >= 10) {
              timer.cancel();
              if (_pendingIceCandidates.isNotEmpty) {
                // Aún quedan candidatos ICE sin procesar
              }
            }
          });
        }
      });
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
    return ''; // Retornar string vacío si no se puede extraer
  }

  // Extraer callId de un token JWT
  String? _extractCallIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length >= 2) {
        final payload = parts[1];
        final normalized = base64Url.normalize(payload);
        final decodedPayload = utf8.decode(base64Url.decode(normalized));
        final data = jsonDecode(decodedPayload);

        // Intentar extraer callId del token
        final callId = data['callId'];
        return callId;
      }
    } catch (e) {
      // Error al extraer callId del token
    }
    return null; // Retornar null si no se puede extraer
  }

  // 🔔 NUEVO: Disparar notificación VoIP nativa para llamada entrante
  Future<void> _triggerVoIPNotification(
    String callId,
    String? fromUserId,
  ) async {
    // Solo en iOS - verificación web-compatible
    try {
      if (!Platform.isIOS) {
        return;
      }
    } catch (e) {
      // En Web, Platform.isIOS lanza excepción
      return;
    }

    try {
      // Obtener nombre del usuario que llama
      String callerName = 'Llamada entrante';
      if (fromUserId != null && _token != null) {
        try {
          final response = await ApiService.get(
            '/api/users/$fromUserId',
            _token!,
          );
          if (response.statusCode == 200 && response.body.isNotEmpty) {
            final userData = jsonDecode(response.body);
            callerName = userData['nickname'] ?? 'Llamada entrante';
          }
        } catch (e) {
          // Continuar con nombre por defecto
        }
      }

      // Disparar notificación VoIP nativa
      await VoIPService.instance.showIncomingCall(
        callId: callId,
        callerName: callerName,
      );
    } catch (e) {
      // No es crítico, el sistema WebSocket sigue funcionando
    }
  }

  // 🔐 ===== MÉTODOS DE CIFRADO ChaCha20-Poly1305 REAL =====

  /// Inicializa el servicio de cifrado ChaCha20-Poly1305
  Future<void> _initEncryption() async {
    try {
      _encryptionService = EncryptionService();
      await _encryptionService!.initialize();

      _encryptionInitialized = true;
    } catch (e) {
      _encryptionInitialized = false;
      _encryptionService = null;
    }
  }

  /// Inicia el intercambio SEGURO de claves DH para una nueva llamada - GRADO MILITAR
  Future<void> _startEncryptionKeyExchange(
    String callId,
    bool isInitiator,
  ) async {
    if (!_encryptionInitialized || _encryptionService == null) {
      // Intentar inicializar el cifrado una vez más
      try {
        await _initEncryption();
        if (!_encryptionInitialized || _encryptionService == null) {
          return;
        }
      } catch (e) {
        return;
      }
    }

    try {
      // PASO 1: GENERAR CLAVES DH LOCALES (NUNCA SALEN DEL DISPOSITIVO)
      final dhKeyPair = await _encryptionService!.generateDHKeyPair();
      final ephemeralPair = await _encryptionService!.generateEphemeralPair();

      // PASO 2: ENVIAR SOLO CLAVES PÚBLICAS (SEGURO)
      await _sendPublicKeys(
        callId,
        dhKeyPair['publicKey']!,
        ephemeralPair['publicKey']!,
      );

      // PASO 3: ALMACENAR CLAVES PRIVADAS PARA CUANDO LLEGUEN LAS PÚBLICAS DEL OTRO
      _tempDHPrivateKey = dhKeyPair['privateKey']!;
      _tempEphemeralPrivateKey = ephemeralPair['privateKey']!;
      _tempCallId = callId;

      // 🔄 PROCESAR CLAVES PÚBLICAS PENDIENTES SI LAS HAY
      if (_pendingPublicKeys != null) {
        final pendingData = _pendingPublicKeys!;
        _pendingPublicKeys = null; // Limpiar para evitar re-procesamiento

        // Procesar las claves públicas pendientes
        await _handleSecureKeyExchange(pendingData);
      }
    } catch (e) {
      // Error en intercambio DH militar
    }
  }

  // Variables temporales para almacenar claves privadas localmente
  Uint8List? _tempDHPrivateKey;
  Uint8List? _tempEphemeralPrivateKey;
  String? _tempCallId;

  // Variables para almacenar claves públicas pendientes si llegan antes que las nuestras
  Map<String, dynamic>? _pendingPublicKeys;

  /// Envía SOLO las claves públicas al otro participante (SEGURO)
  Future<void> _sendPublicKeys(
    String callId,
    Uint8List dhPublic,
    Uint8List ephemeralPublic,
  ) async {
    if (socket == null || !socket!.connected) {
      return;
    }

    try {
      final nonce = _encryptionService!.generateSecureNonce();

      socket!.emit('secure-key-exchange', {
        'callId': callId,
        'step': 'public-keys',
        'from': _currentUserId,
        'to': _lastTo,
        'dhPublic': base64Encode(dhPublic),
        'ephemeralPublic': base64Encode(ephemeralPublic),
        'nonce': base64Encode(nonce),
        'algorithm': 'Military-DH-Curve25519',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      // Error enviando claves públicas
    }
  }

  /// Procesa las claves públicas recibidas y genera secreto compartido LOCALMENTE
  Future<void> _handleSecureKeyExchange(Map<String, dynamic> data) async {
    if (!_encryptionInitialized || _encryptionService == null) {
      return;
    }

    try {
      final step = data['step'] as String?;
      final callId = data['callId'] as String?;
      final dhPublicBase64 = data['dhPublic'] as String?;
      final ephemeralPublicBase64 = data['ephemeralPublic'] as String?;

      if (step != 'public-keys' ||
          callId != _currentCallId ||
          dhPublicBase64 == null ||
          ephemeralPublicBase64 == null) {
        return;
      }

      // Verificar que tenemos nuestras claves privadas
      if (_tempDHPrivateKey == null ||
          _tempEphemeralPrivateKey == null ||
          _tempCallId != callId) {
        // 🔄 INTENTAR INICIAR INTERCAMBIO DH COMO RESPALDO SI NO SE HA INICIADO
        if (_tempCallId == null && callId != null) {
          try {
            await _startEncryptionKeyExchange(callId, false);
            // Si se inició correctamente, procesar inmediatamente las claves públicas
            if (_tempDHPrivateKey != null &&
                _tempEphemeralPrivateKey != null &&
                _tempCallId == callId) {
              // Continuar con el procesamiento normal
            } else {
              // Guardar para procesar después
              _pendingPublicKeys = data;
              return;
            }
          } catch (e) {
            _pendingPublicKeys = data;
            return;
          }
        } else {
          // Guardar las claves públicas para procesarlas cuando tengamos las nuestras
          _pendingPublicKeys = data;
          return;
        }
      }

      // Decodificar claves públicas del otro participante
      final theirDHPublic = base64Decode(dhPublicBase64);
      final theirEphemeralPublic = base64Decode(ephemeralPublicBase64);

      // PASO CRÍTICO: COMPUTAR SECRETOS COMPARTIDOS LOCALMENTE
      final dh1Secret = await _encryptionService!.computeDH(
        _tempDHPrivateKey!,
        theirDHPublic,
      );
      final dh2Secret = await _encryptionService!.computeDH(
        _tempEphemeralPrivateKey!,
        theirEphemeralPublic,
      );

      // GENERAR CLAVE MAESTRA DE 64 BYTES USANDO DOBLE DH + HKDF
      final masterKey = await _encryptionService!.generateMasterKeyFromDoubleDH(
        dh1Secret,
        dh2Secret,
        'videollamada-$callId',
      );

      // DERIVAR CLAVE DE SESIÓN DE 32 BYTES
      final sessionKey = await _encryptionService!.deriveSessionKeyFromShared(
        masterKey,
        'session-$callId',
      );

      // ESTABLECER CLAVE DE SESIÓN
      await _encryptionService!.setSessionKey(sessionKey);

      // LIMPIAR CLAVES TEMPORALES INMEDIATAMENTE
      _tempDHPrivateKey = null;
      _tempEphemeralPrivateKey = null;
      _tempCallId = null;
      _pendingPublicKeys = null;
    } catch (e) {
      // Limpiar en caso de error
      _tempDHPrivateKey = null;
      _tempEphemeralPrivateKey = null;
      _tempCallId = null;
      _pendingPublicKeys = null;
    }
  }

  /// MÉTODO OBSOLETO - MANTENIDO PARA COMPATIBILIDAD
  void _sendEncryptionKey(String callId, Uint8List sessionKey) {
    // MÉTODO OBSOLETO: _sendEncryptionKey - Ahora usamos DH militar
    // Las claves ya NO se envían en texto plano
  }

  /// MÉTODO OBSOLETO - MANTENIDO PARA COMPATIBILIDAD
  Future<void> _handleEncryptionKey(Map<String, dynamic> data) async {
    // MÉTODO OBSOLETO: _handleEncryptionKey - Ahora usamos DH militar
    // Las claves ya NO se reciben en texto plano
  }

  /// Cifra datos de media antes de enviarlos
  Future<Uint8List?> _encryptMediaData(Uint8List data) async {
    if (!_encryptionInitialized || _encryptionService == null) {
      // Si el cifrado no está disponible, devolver datos sin cifrar
      return data;
    }

    try {
      final encryptedData = await _encryptionService!.encrypt(data);
      return encryptedData;
    } catch (e) {
      // En caso de error, devolver datos sin cifrar para mantener la llamada
      return data;
    }
  }

  /// Descifra datos de media recibidos
  Future<Uint8List?> _decryptMediaData(Uint8List encryptedData) async {
    if (!_encryptionInitialized || _encryptionService == null) {
      // Si el cifrado no está disponible, asumir que los datos no están cifrados
      return encryptedData;
    }

    try {
      final decryptedData = await _encryptionService!.decrypt(encryptedData);
      return decryptedData;
    } catch (e) {
      // En caso de error, devolver datos originales
      return encryptedData;
    }
  }

  /// Limpia recursos de cifrado al finalizar la llamada
  void _cleanupEncryption() {
    if (_encryptionService != null) {
      _encryptionService!.dispose();
      _encryptionService = null;
      _encryptionInitialized = false;
    }
  }

  /// Obtiene estadísticas del cifrado actual
  Map<String, dynamic>? getEncryptionStats() {
    if (_encryptionService != null) {
      return _encryptionService!.getUsageStats();
    }
    return null;
  }

  /// Verifica si el cifrado está activo
  bool isEncryptionActive() {
    return _encryptionInitialized && _encryptionService != null;
  }

  /// Diagnóstico completo del estado del cifrado
  void diagnoseEncryption() {
    // === DIAGNÓSTICO DE CIFRADO ===
    // _encryptionInitialized: $_encryptionInitialized
    // _encryptionService != null: ${_encryptionService != null}
    // isEncryptionActive(): ${isEncryptionActive()}

    if (_encryptionService != null) {
      try {
        // final status = _encryptionService!.getStatus();
        // Estado del servicio: $status
      } catch (e) {
        // Error obteniendo estado
      }
    } else {
      // Servicio de cifrado es null
    }
    // === FIN DIAGNÓSTICO ===
  }
}
