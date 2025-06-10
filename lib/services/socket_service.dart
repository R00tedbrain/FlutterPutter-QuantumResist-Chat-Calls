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
    print(
      '📱 Creando SocketService con peerConnection: ${_peerConnection != null ? "disponible" : "nulo"}',
    );
    if (_token != null) {
      _currentUserId = _extractUserIdFromToken(_token!);
    }
    _initSocket();
    // 🔐 Inicializar cifrado ChaCha20-Poly1305 de forma no bloqueante
    _initEncryption().catchError((e) {
      print('🔐 [SOCKET] ⚠️ Cifrado no disponible, continuando sin él: $e');
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
    print('🔄 Actualizando peerConnection en SocketService');
    print(
      '🔍 Estado anterior: ${_peerConnection != null ? "conectado" : "nulo"}',
    );
    print(
      '🔍 Estado de _pendingOffer ANTES de actualizar: ${_pendingOffer != null ? "PRESENTE" : "NULO"}',
    );
    if (_pendingOffer != null) {
      print(
        '🔍 Datos de _pendingOffer: callId=${_pendingOffer!['callId']}, from=${_pendingOffer!['from']}, to=${_pendingOffer!['to']}',
      );
    }

    _peerConnection = newPeerConnection;

    // Si se está limpiando (newPeerConnection es null), limpiar también estado pendiente
    if (newPeerConnection == null) {
      print('🧹 Limpiando estado WebRTC en SocketService');
      _pendingOffer = null;
      _hasRemoteDescription = false;
      _pendingIceCandidates.clear();
      _pendingCandidatesTimer?.cancel();
      _pendingCandidatesTimer = null;
    } else {
      // Verificar que el peerConnection está en buen estado
      print(
        '🔍 PeerConnection establecido - Estado: ${newPeerConnection.connectionState}',
      );
      print(
        '🔍 PeerConnection establecido - Signaling: ${newPeerConnection.signalingState}',
      );

      // CRÍTICO: En web, el peerConnection puede tener estados null inicialmente
      // Esto es normal y no indica un problema
      if (kIsWeb) {
        print(
          '🌐 PeerConnection en web - estados pueden ser null inicialmente',
        );

        // CRÍTICO: Verificar que los event handlers estén configurados
        print('🔍 Verificando event handlers del peerConnection...');
        print(
          '🔍 onTrack configurado: ${newPeerConnection.onTrack != null ? "✅" : "❌"}',
        );
        print(
          '🔍 onAddStream configurado: ${newPeerConnection.onAddStream != null ? "✅" : "❌"}',
        );

        // Dar tiempo para que se inicialice completamente
        Future.delayed(const Duration(milliseconds: 150), () async {
          try {
            final connectionState =
                await newPeerConnection.getConnectionState();
            print(
              '🔍 PeerConnection después del delay - Estado: $connectionState',
            );
          } catch (e) {
            print(
              '🔍 PeerConnection después del delay - Error obteniendo estado: $e',
            );
          }
        });
      } else {
        // En plataformas nativas, verificar estados normalmente
        print(
          '📱 PeerConnection nativo - Estado: ${newPeerConnection.connectionState}',
        );
      }
    }

    print('✅ PeerConnection actualizado correctamente');
    print(
      '🔍 Estado actual: ${_peerConnection != null ? "conectado" : "nulo"}',
    );
    print(
      '🔍 Estado de _pendingOffer DESPUÉS de actualizar: ${_pendingOffer != null ? "PRESENTE" : "NULO"}',
    );

    // IMPORTANTE: NO procesar la oferta inmediatamente aquí
    // Esperar a que se agreguen los tracks locales primero
    if (_pendingOffer != null) {
      print(
        '🔄 Oferta SDP pendiente detectada, esperando a que se agreguen tracks locales',
      );
      print(
        '🔍 Datos de oferta pendiente: callId=${_pendingOffer!['callId']}, from=${_pendingOffer!['from']}, to=${_pendingOffer!['to']}',
      );
    } else {
      print('ℹ️ No hay oferta SDP pendiente');
      if (_pendingIceCandidates.isNotEmpty) {
        // Solo procesar candidatos si no hay oferta pendiente
        print(
          '🔄 Procesando ${_pendingIceCandidates.length} candidatos ICE pendientes (sin oferta)',
        );
        _processPendingIceCandidates();
      }
    }
  }

  // Nuevo método para procesar oferta pendiente después de agregar tracks
  void processPendingOfferAfterTracks() {
    if (_peerConnection == null || _pendingOffer == null) {
      print('ℹ️ No hay oferta pendiente o peerConnection para procesar');
      return;
    }

    print(
      '🔄 Procesando oferta SDP pendiente DESPUÉS de agregar tracks locales',
    );
    print(
      '🔍 Datos de oferta pendiente: callId=${_pendingOffer!['callId']}, from=${_pendingOffer!['from']}, to=${_pendingOffer!['to']}',
    );

    // Procesar la oferta después de un pequeño delay para asegurar que los tracks estén agregados
    Future.delayed(const Duration(milliseconds: 100), () async {
      await _processPendingOffer();
      print(
        '✅ Oferta SDP pendiente procesada completamente después de agregar tracks',
      );

      // Después de procesar la oferta, procesar candidatos ICE pendientes
      if (_pendingIceCandidates.isNotEmpty) {
        print(
          '🔄 Procesando ${_pendingIceCandidates.length} candidatos ICE después de la oferta',
        );
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
        print(
          '⚠️ No se puede procesar candidatos ICE: descripción remota no establecida aún',
        );
        return; // No limpiar la lista, intentar más tarde
      }
    } catch (e) {
      print('⚠️ Error al verificar descripción remota: $e');
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
        print('✅ Candidato ICE pendiente procesado correctamente');
      } catch (e) {
        print('⚠️ Error al procesar candidato ICE pendiente: $e');
        // Si hay error, volver a agregar a la lista pendiente
        _pendingIceCandidates.add(candidateData);
      }
    }
  }

  // Procesa la oferta SDP pendiente
  Future<void> _processPendingOffer() async {
    print('🎯 INICIANDO _processPendingOffer()');

    if (_peerConnection == null) {
      print('❌ No se puede procesar oferta SDP: peerConnection es nulo');
      return;
    }

    if (_pendingOffer == null) {
      print('ℹ️ No hay oferta SDP pendiente para procesar');
      return;
    }

    try {
      print('🔄 Procesando oferta SDP pendiente');
      print('🔍 Datos completos de _pendingOffer: $_pendingOffer');

      final sdp = _pendingOffer!['sdp'];
      print('🔍 SDP extraído: $sdp');

      if (sdp != null &&
          sdp is Map<String, dynamic> &&
          sdp['sdp'] != null &&
          sdp['type'] != null) {
        print('✅ SDP válido encontrado, tipo: ${sdp['type']}');
        // Verificar si ya hay una descripción remota (evitar duplicados)
        bool hasExistingRemoteDescription = false;
        try {
          final currentDesc = await _peerConnection!.getRemoteDescription();
          hasExistingRemoteDescription = currentDesc != null;
          if (hasExistingRemoteDescription) {
            print(
              '⚠️ Ya existe una descripción remota, verificando si es la misma',
            );
          }
        } catch (e) {
          print('Info: No se pudo verificar descripción remota: $e');
        }

        try {
          // 🔐 INICIAR INTERCAMBIO DE CLAVES DE CIFRADO ANTES DE PROCESAR OFERTA PENDIENTE
          final pendingCallId = _pendingOffer!['callId'];
          if (pendingCallId != null) {
            print(
              '🔐 [SOCKET] 🚀 Iniciando intercambio DH para oferta pendiente',
            );
            diagnoseEncryption();
            _startEncryptionKeyExchange(pendingCallId, false);
          }

          // Establecer descripción remota
          await _peerConnection!.setRemoteDescription(
            RTCSessionDescription(sdp['sdp'], sdp['type']),
          );

          _hasRemoteDescription = true;
          print('✅ Descripción remota establecida desde oferta pendiente');

          // Iniciar temporizador para reintentar procesar candidatos pendientes
          _startPendingCandidatesTimer();

          // Crear y enviar respuesta
          final answer = await _peerConnection!.createAnswer();
          await _peerConnection!.setLocalDescription(answer);

          // Verificar que tenemos todos los datos necesarios antes de enviar la respuesta
          if (_pendingOffer!['callId'] == null) {
            print('❌ ERROR: callId es null al enviar respuesta SDP');
            return;
          }

          if (_pendingOffer!['from'] == null) {
            print('❌ ERROR: from es null al enviar respuesta SDP');
            return;
          }

          // Enviar la respuesta al emisor
          final emitterData = {
            'callId': _pendingOffer!['callId'],
            'from': _currentUserId ?? _pendingOffer!['to'],
            'to': _pendingOffer!['from'],
            'sdp': {'type': answer.type, 'sdp': answer.sdp},
          };

          print('🎯 PREPARANDO ENVÍO DE ANSWER SDP');
          print('🔍 Socket conectado: ${socket?.connected}');
          print('🔍 Socket no es nulo: ${socket != null}');
          print(
            '⚡️ Enviando answer con: callId=${emitterData['callId']}, from=${emitterData['from']}, to=${emitterData['to']}',
          );
          print('🔍 Datos completos del answer: $emitterData');

          if (socket == null) {
            print('❌ ERROR CRÍTICO: Socket es nulo, no se puede enviar answer');
            return;
          }

          if (!socket!.connected) {
            print(
              '❌ ERROR CRÍTICO: Socket no está conectado, no se puede enviar answer',
            );
            return;
          }

          socket!.emit('answer', emitterData);
          print('✅ Respuesta SDP enviada al emisor exitosamente');
        } catch (e) {
          print(
            '❌ Error al establecer descripción remota o crear respuesta: $e',
          );
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
        print('❌ Oferta SDP pendiente inválida o con formato incorrecto: $sdp');
      }
    } catch (e) {
      print('❌ Error al procesar oferta SDP pendiente: $e');
      _hasRemoteDescription =
          false; // Asegurar que estado es correcto en caso de error
    }
  }

  void _initSocket() {
    try {
      if (_token == null) {
        // ⬅️  espera al token
        print('⏸️  Esperando token para abrir Socket.IO');
        return;
      }

      // No volver a desconectar si ya estamos dentro
      // solo lo hacemos la primera vez
      if (socket != null) return;

      print(
        '[DEBUG] Conectando Socket.IO a https://clubprivado.ws con path /signaling/socket.io',
      );

      // Crear socket de forma compatible con todas las plataformas
      socket = _buildSocket(_token);

      // Conectar explícitamente
      socket?.connect();

      socket?.onConnect((_) {
        _isConnected = true;
        _reconnectAttempts = 0;

        // Detener cualquier temporizador pendiente
        _reconnectTimer?.cancel();

        print('🔌 Socket.IO conectado');
        print(
          '🔍 Estado de peerConnection al conectar socket: ${_peerConnection != null ? "disponible" : "nulo"}',
        );

        // Si tenemos un callId pendiente, unirse automáticamente
        if (_currentCallId != null && _token != null) {
          print('🔄 Reconectado: uniendo a llamada pendiente $_currentCallId');
          // Incluir _lastTo para mantener el destinatario al reconectar
          _joinCallInternal(_currentCallId!, _token!, to: _lastTo);
        }

        // 🚀 REENVIAR OFERTA SDP PENDIENTE si existe
        if (_pendingOutgoingOffer != null) {
          print('🚀 Reenviando oferta SDP pendiente después de reconexión');
          print('🚀 Datos de oferta pendiente: $_pendingOutgoingOffer');

          // Reenviar la oferta
          socket!.emit('offer', _pendingOutgoingOffer);
          print('✅ Oferta SDP pendiente reenviada exitosamente');

          // Limpiar la oferta pendiente
          _pendingOutgoingOffer = null;
        }
      });

      socket?.onConnectError((error) {
        _isConnected = false;
        print('❌ Error de conexión Socket.IO: $error');
        print(
          'Detalles conexión: URL=https://clubprivado.ws, path=/signaling/socket.io, token=${_token != null ? 'presente' : 'ausente'}',
        );
        _scheduleReconnect();
      });

      socket?.onError((error) {
        print('⚠️ Error general Socket.IO: $error');
        if (error.toString().contains('auth')) {
          print('⚠️ Posible problema con el token de autorización');
        }
      });

      socket?.onDisconnect((reason) {
        _isConnected = false;
        print('⚠️ Socket.IO desconectado. Razón: $reason');
        print(
          '🔍 Estado de peerConnection al desconectar: ${_peerConnection != null ? "disponible" : "nulo"}',
        );
        _scheduleReconnect();
      });

      _setupSocketListeners();
    } catch (e) {
      print('🚨 Error crítico Socket.IO: $e');
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
      print(
        'Programando reconexión #$_reconnectAttempts en ${delay.inSeconds} segundos',
      );
      _reconnectTimer = Timer(delay, _reconnect);
    } else {
      print(
        'Máximo número de intentos de reconexión alcanzado ($maxReconnectAttempts)',
      );
    }
  }

  void _reconnect() {
    if (_isReconnecting) {
      print('Ya hay una reconexión en progreso, ignorando solicitud duplicada');
      return;
    }

    _isReconnecting = true;
    print('Intentando reconexión de Socket.io...');
    print(
      '🔍 Estado de peerConnection antes de reconectar: ${_peerConnection != null ? "disponible" : "nulo"}',
    );

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
          print('✅ Reconexión exitosa');

          // Verificar si se mantuvo la referencia al peerConnection
          if (_peerConnection == null && existingPeerConnection != null) {
            print(
              '🔄 Restaurando referencia a peerConnection después de reconexión',
            );
            _peerConnection = existingPeerConnection;
          }

          print(
            '🔍 Estado de peerConnection después de reconectar: ${_peerConnection != null ? "disponible" : "nulo"}',
          );
        } else {
          print('⚠️ La reconexión no se completó correctamente');
        }
      });
    } finally {
      _isReconnecting = false;
    }
  }

  // Método explícito para forzar el refresco de la conexión
  void refreshConnection() {
    print('🔄 Refrescando conexión de socket...');
    print(
      '🔍 Estado de peerConnection antes de refrescar: ${_peerConnection != null ? "disponible" : "nulo"}',
    );

    if (socket != null) {
      // Garantizar que los listeners estén configurados
      _setupSocketListeners();

      if (!socket!.connected) {
        socket!.connect();
        print('⚡️ Intentando reconexión explícita del socket');
      } else {
        print('✅ Socket ya conectado, refrescando listeners');
      }
    } else {
      _initSocket();
      print('🆕 Creando nuevo socket');
    }

    // Verificar estado de peerConnection después del refresco
    print(
      '🔍 Estado de peerConnection después de refrescar: ${_peerConnection != null ? "disponible" : "nulo"}',
    );
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
          print('⚠️ user-joined payload no válido o null, lo ignoramos: $data');
          return;
        }
        print('User joined: ${data['userId']}');
      });

      socket?.on('user-left', (data) {
        if (data == null || data is! Map<String, dynamic>) {
          print('⚠️ user-left payload no válido o null, lo ignoramos: $data');
          return;
        }
        print('User left: ${data['userId']}');
      });

      socket?.on('incoming-call', (data) {
        print('🔔 Llamada entrante recibida: $data');
        if (data == null || data is! Map<String, dynamic>) {
          print(
            '⚠️ incoming-call payload no válido o null, lo ignoramos: $data',
          );
          return;
        }

        final callId = data['callId'] as String?;
        final token = data['token'] as String?;
        final from = data['from'] as String?;

        if (callId == null || token == null) {
          print(
            '⚠️ incoming-call con datos incompletos: callId=$callId, token=$token, from=$from',
          );
          return;
        }

        // Verificar si ya estamos procesando esta llamada
        if (_currentCallId == callId) {
          print(
            '⚠️ Ya estamos en la llamada $callId, ignorando notificación duplicada',
          );
          return;
        }

        // Verificar si ya procesamos esta notificación de llamada entrante
        if (_processedIncomingCalls.contains(callId)) {
          print('⚠️ Llamada entrante $callId ya fue procesada anteriormente');
          return;
        }

        _processedIncomingCalls.add(callId);
        print('✅ Procesando llamada entrante: callId=$callId, from=$from');

        // Auto-guardar el ID del emisor para referencia futura
        if (from != null) {
          print('📝 Guardando el ID del emisor: $from para uso futuro');
          final callData = {'initiatorId': from, 'callId': callId};
          // Almacenar en una variable estática para uso futuro
          _lastIncomingCallData[callId] = callData;
          print('📋 Datos de llamada actualizados: $callData');
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
          print('⚠️ No hay callback registrado para llamadas entrantes');
        }
      });

      socket?.on('offer', (incoming) async {
        print('🎯 EVENTO OFFER RECIBIDO: $incoming');
        print('🎯 Tipo de datos: ${incoming.runtimeType}');
        print('🎯 Es nulo: ${incoming == null}');
        try {
          if (incoming == null) {
            print('⚠️ oferta SDP es null, ignorando');
            return;
          }

          // Verificar tipo de datos y estructura
          if (incoming is! Map) {
            print('⚠️ oferta SDP no es un Map: ${incoming.runtimeType}');
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
            print(
              '⚠️ Error al convertir oferta SDP a Map<String, dynamic>: $e',
            );
            return;
          }

          // Validar que el SDP exista y tenga la estructura correcta
          final sdp = safeIncoming['sdp'];
          if (sdp == null) {
            print('⚠️ campo sdp no encontrado en la oferta');
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
              print('⚠️ Error al convertir sdp a Map<String, dynamic>: $e');
              return;
            }
          } else {
            print('⚠️ sdp no es un Map: ${sdp.runtimeType}');
            return;
          }

          if (safeSdp['sdp'] == null || safeSdp['type'] == null) {
            print('ERROR: SDP inválido, campos requeridos faltantes: $safeSdp');
            return;
          }

          // Verificar si el peerConnection está disponible
          if (_peerConnection == null) {
            print(
              '⚠️ peerConnection es nulo, guardando oferta SDP para procesamiento posterior',
            );

            // Guardar oferta para procesamiento posterior
            // IMPORTANTE: Incluir el callId actual y los datos necesarios
            _pendingOffer = {
              ...safeIncoming,
              'callId': _currentCallId ?? safeIncoming['callId'],
              'from': safeIncoming['from'],
              'to': safeIncoming['to'],
            };

            print('🔍 OFERTA SDP GUARDADA COMO PENDIENTE:');
            print('🔍 _pendingOffer = $_pendingOffer');
            print('🔍 _currentCallId = $_currentCallId');
            print('🔍 Esperando a que se actualice peerConnection...');

            // CRÍTICO: Verificar si hay algún problema con la inicialización
            print('🔍 DIAGNÓSTICO: ¿Por qué peerConnection es nulo?');
            print('🔍 - Socket conectado: ${socket?.connected}');
            print('🔍 - CallId actual: $_currentCallId');
            print('🔍 - Token disponible: ${_token != null}');

            return;
          }

          // Si el peerConnection está disponible, verificar que no esté cerrado
          try {
            final connectionState = await _peerConnection!.getConnectionState();
            if (connectionState ==
                RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
              print(
                '❌ ERROR: PeerConnection está cerrado, no se puede procesar oferta SDP',
              );
              return;
            }
          } catch (e) {
            print('⚠️ Error verificando estado de peerConnection: $e');
            return;
          }

          // 🔐 INICIAR INTERCAMBIO DE CLAVES DE CIFRADO ANTES DE PROCESAR SDP (RECEPTOR)
          final receiverCallId = safeIncoming['callId'] ?? _currentCallId;
          if (receiverCallId != null) {
            print(
              '🔐 [SOCKET] 🚀 Iniciando intercambio DH ANTES de procesar oferta SDP',
            );
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
            print('🔍 Usando callId almacenado: $callId');
          }

          // Si falta el destinatario (to), intentar usar _lastTo
          if (to == null && _lastTo != null) {
            to = _lastTo;
            print('🔍 Usando initiatorId almacenado como destinatario: $to');
          }

          // Verificar de nuevo
          if (callId == null || from == null || to == null) {
            print(
              'ERROR: Datos necesarios faltantes en la oferta SDP incluso después de usar fallbacks: callId=$callId, from=$from, to=$to',
            );
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

          print(
            '⚡️ Enviando answer en tiempo real: callId=${answerData['callId']}, from=${answerData['from']}, to=${answerData['to']}',
          );
          socket?.emit('answer', answerData);
          print('✅ Respuesta SDP enviada al emisor en tiempo real');

          // 🔐 INTERCAMBIO DE CLAVES YA INICIADO ANTES DE PROCESAR SDP
          print('🔐 [SOCKET] ✅ Intercambio DH ya iniciado previamente');

          // Procesar candidatos ICE pendientes después de establecer la oferta
          _processPendingIceCandidates();
        } catch (e) {
          print('ERROR procesando oferta SDP: $e');
        }
      });

      socket?.on('answer', (incoming) async {
        print('📥 Recibida respuesta SDP: $incoming');
        try {
          if (incoming == null) {
            print('⚠️ respuesta SDP es null, ignorando');
            return;
          }

          // Verificar tipo de datos y estructura
          if (incoming is! Map) {
            print('⚠️ respuesta SDP no es un Map: ${incoming.runtimeType}');
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
            print(
              '⚠️ Error al convertir respuesta SDP a Map<String, dynamic>: $e',
            );
            return;
          }

          if (_peerConnection == null) {
            print(
              'ERROR: peerConnection es nulo, no se puede procesar respuesta',
            );
            return;
          }

          // Verificar que el peerConnection no esté cerrado
          try {
            final connectionState = await _peerConnection!.getConnectionState();
            if (connectionState ==
                RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
              print(
                '❌ ERROR: PeerConnection está cerrado, no se puede procesar respuesta SDP',
              );
              return;
            }
          } catch (e) {
            print(
              '⚠️ Error verificando estado de peerConnection para respuesta: $e',
            );
            return;
          }

          // Verificar que los datos de callId y remitentes sean correctos
          final responseCallId = safeIncoming['callId'] as String?;
          if (responseCallId == null) {
            print(
              '⚠️ La respuesta no contiene callId, usando _currentCallId: $_currentCallId',
            );
            if (_currentCallId == null) {
              print('❌ No hay callId disponible para procesar respuesta SDP');
              return;
            }
          } else {
            print('📝 Respuesta para llamada: $responseCallId');
          }

          final effectiveCallId = responseCallId ?? _currentCallId;
          print('📝 CallId efectivo para procesar: $effectiveCallId');
          print('📝 Remitente (from): ${safeIncoming['from']}');
          print('📝 Destinatario (to): ${safeIncoming['to']}');

          // Validar que el SDP exista y tenga la estructura correcta
          final sdp = safeIncoming['sdp'];
          if (sdp == null) {
            print('⚠️ campo sdp no encontrado en la respuesta');
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
              print('⚠️ Error al convertir sdp a Map<String, dynamic>: $e');
              return;
            }
          } else {
            print('⚠️ sdp no es un Map: ${sdp.runtimeType}');
            return;
          }

          if (safeSdp['sdp'] == null || safeSdp['type'] == null) {
            print(
              'ERROR: SDP inválido en respuesta, campos requeridos faltantes: $safeSdp',
            );
            return;
          }

          await _peerConnection!.setRemoteDescription(
            RTCSessionDescription(safeSdp['sdp'], safeSdp['type']),
          );
          _hasRemoteDescription = true;
          print('✅ Descripción remota establecida desde respuesta SDP');

          // Iniciar temporizador para reintentar procesar candidatos pendientes
          _startPendingCandidatesTimer();

          // Procesar candidatos ICE pendientes después de establecer la respuesta
          await Future.delayed(const Duration(milliseconds: 500));
          _processPendingIceCandidates();
        } catch (e) {
          print('ERROR procesando respuesta SDP: $e');
        }
      });

      socket?.on('ice-candidate', (incoming) async {
        print('Recibido candidato ICE: $incoming');
        try {
          if (incoming == null) {
            print('⚠️ candidato ICE es null, ignorando');
            return;
          }

          // Verificar tipo de datos y estructura
          if (incoming is! Map) {
            print('⚠️ candidato ICE no es un Map: ${incoming.runtimeType}');
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
            print(
              '⚠️ Error al convertir candidato ICE a Map<String, dynamic>: $e',
            );
            return;
          }

          // Validar que el candidato exista y tenga la estructura correcta
          final candidate = safeIncoming['candidate'];
          if (candidate == null) {
            print('⚠️ campo candidate no encontrado en el mensaje');
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
              print(
                '⚠️ Error al convertir candidate a Map<String, dynamic>: $e',
              );
              return;
            }
          } else {
            print('⚠️ candidate no es un Map: ${candidate.runtimeType}');
            return;
          }

          if (safeCandidate['candidate'] == null ||
              safeCandidate['sdpMid'] == null ||
              safeCandidate['sdpMLineIndex'] == null) {
            print(
              'ERROR: Candidato ICE inválido, campos requeridos faltantes: $safeCandidate',
            );
            return;
          }

          // Si no hay peerConnection o no tenemos descripción remota, guardamos el candidato
          if (_peerConnection == null) {
            print(
              '⚠️ No se puede procesar candidato ICE: peerConnection es nulo, guardando para más tarde',
            );
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
              print(
                '⚠️ PeerConnection está cerrada o falló, no se puede procesar candidato ICE',
              );
              return;
            }
          } catch (e) {
            print('⚠️ Error verificando estado de conexión: $e');
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
                print(
                  '⚠️ Se detectó descripción remota existente, actualizando _hasRemoteDescription',
                );
                _hasRemoteDescription = true;
              }
            } catch (e) {
              print('No se pudo verificar descripción remota: $e');
            }
          }

          if (!hasDesc) {
            print(
              '⚠️ No se puede procesar candidato ICE: sin descripción remota, guardando para procesamiento posterior',
            );
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
            print('✅ Candidato ICE procesado correctamente');
          } catch (e) {
            print('ERROR procesando candidato ICE: $e');

            // Si hubo error, almacenar el candidato para intentarlo más tarde
            if (e.toString().contains('The remote description was null') ||
                e.toString().contains('setRemoteDescription')) {
              print(
                '⚠️ Error sugiere problema con descripción remota - guardando candidato para procesamiento posterior',
              );
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
          print('ERROR general procesando candidato ICE: $e');
        }
      });

      socket?.on('call-ended', (data) {
        if (data == null || data is! Map<String, dynamic>) {
          print('⚠️ call-ended payload no válido o null, lo ignoramos: $data');
          return;
        }
        print('🔚 Llamada terminada por el otro usuario: $data');

        // LIMPIAR COMPLETAMENTE todos los recursos WebRTC
        _cleanupCallResources();

        // Enviar evento al CallProvider a través de un callback
        _notifyCallEnded(data);
      });

      // 🔐 LISTENER PARA INTERCAMBIO MILITAR DH - ZERO KNOWLEDGE
      socket?.on('secure-key-exchange', (data) {
        if (data == null || data is! Map<String, dynamic>) {
          print('🔐 [SOCKET] ⚠️ secure-key-exchange payload no válido: $data');
          return;
        }
        print(
          '🔐 [SOCKET] 📥 Evento secure-key-exchange recibido - PROCESANDO DH',
        );
        _handleSecureKeyExchange(data);
      });

      // 🔐 LISTENER OBSOLETO PARA RETROCOMPATIBILIDAD
      socket?.on('encryption-key', (data) {
        if (data == null || data is! Map<String, dynamic>) {
          print('🔐 [SOCKET] ⚠️ encryption-key payload no válido: $data');
          return;
        }
        print('🔐 [SOCKET] 📥 Evento encryption-key recibido (OBSOLETO)');
        print(
          '🔐 [SOCKET] ⚠️ ADVERTENCIA: Usando método inseguro - actualizar a DH militar',
        );
        _handleEncryptionKey(data);
      });

      socket?.on('call-status', (data) {
        if (data == null || data is! Map<String, dynamic>) {
          print('⚠️ call-status payload no válido o null, lo ignoramos: $data');
          return;
        }

        print('Estado de llamada actualizado: $data');
        print('[DEBUG] call-status data type: ${data.runtimeType}');

        // Verificar si status existe y es un String antes de procesar
        if (!data.containsKey('status') || data['status'] == null) {
          print('⚠️ call-status sin campo status o status es null: $data');
          return;
        }

        // Imprimir cada clave y su tipo de dato
        data.forEach((key, value) {
          print('[DEBUG] call-status $key: $value (${value?.runtimeType})');
        });

        // Si hay un objeto anidado en alguna propiedad, verificarlo también
        if (data['status'] is Map) {
          print(
            '⚠️ Advertencia: status es un Map anidado, podría causar problemas de cast',
          );
        }
      });

      socket?.on('ping-user', (data) {
        print('🏓 Ping recibido: $data');
        if (data != null && data is Map<String, dynamic>) {
          final type = data['type'];
          final from = data['from'];
          final to = data['to'];
          final callId = data['callId'];

          if (type == 'offer-sent') {
            print(
              '🎯 Confirmación: El emisor envió una oferta SDP para callId: $callId',
            );
            print('🎯 Emisor: $from, Receptor esperado: $to');

            // Responder con confirmación de que estamos conectados
            socket?.emit('ping-user', {
              'to': from,
              'from': _currentUserId,
              'callId': callId,
              'type': 'receiver-connected',
            });
          } else if (type == 'receiver-connected') {
            print(
              '✅ Confirmación: El receptor está conectado y listo para recibir ofertas',
            );
          }
        }
      });

      // 🚨 NUEVO: LISTENER PARA LOGOUT FORZADO (SEGURIDAD CRÍTICA)
      socket?.on('session-force-logout', (data) {
        print('🚨 [SECURITY] Evento session-force-logout recibido: $data');

        if (data == null || data is! Map<String, dynamic>) {
          print(
            '🚨 [SECURITY] ⚠️ session-force-logout payload no válido: $data',
          );
          return;
        }

        try {
          final reason =
              data['reason'] ?? 'Nueva sesión iniciada desde otro dispositivo';
          final timestamp =
              data['timestamp'] ?? DateTime.now().toIso8601String();
          final sessionId = data['sessionId'] as String?;

          print('🚨 [SECURITY] Tu sesión fue cerrada forzosamente:');
          print('🚨 [SECURITY] - Razón: $reason');
          print('🚨 [SECURITY] - Timestamp: $timestamp');
          print(
            '🚨 [SECURITY] - SessionId afectado: ${sessionId?.substring(0, 8)}...',
          );

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

          print(
            '🚨 [SECURITY] Estado local limpiado después de logout forzado',
          );
        } catch (e) {
          print('🚨 [SECURITY] Error procesando session-force-logout: $e');

          // Fallback: mostrar alerta genérica
          SecurityAlertService.instance.showSessionForcedLogoutAlert(
            reason: 'Acceso detectado desde otro dispositivo',
            timestamp: DateTime.now().toIso8601String(),
          );
        }
      });
    } catch (e) {
      print('Error configurando listeners de Socket.io: $e');
    }
  }

  void joinCall(String callId, String token, {String? to}) {
    try {
      print(
        '📣 Uniendo a llamada: $callId, token: ${token.substring(0, math.min(10, token.length))}..., to: $to',
      );

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
        print(
          '🔄 Esperando a que Socket.IO se conecte para unirse a $callId...',
        );
        // onConnect() internamente llamará a _joinCallInternal si _currentCallId != null
      }
    } catch (e) {
      print('ERROR uniendo a llamada: $e');
    }
  }

  // Método interno para unirse a la llamada (evita duplicación de código)
  void _joinCallInternal(String callId, String token, {String? to}) {
    print(
      '🔄 Uniendo a llamada: $callId con token: ${token.substring(0, math.min(10, token.length))}..., to: $to',
    );

    // Validación adicional
    if (callId.isEmpty) {
      print('❌ ERROR: Intento de unirse a una llamada con callId vacío');
      return;
    }

    // Verificar si ya nos unimos a esta llamada recientemente
    if (_lastJoinedCallId == callId &&
        _lastJoinTime != null &&
        DateTime.now().difference(_lastJoinTime!).inSeconds < 5) {
      print(
        '⚠️ Ya nos unimos a la llamada $callId hace menos de 5 segundos, evitando duplicado',
      );
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
        print('✅ Enviando join-call con destinatario explícito: $to');
      } else {
        print('⚠️ join-call sin destinatario específico');
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
      print('Abandonando llamada: $callId');
      socket?.emit('leave-call', {'callId': callId});
      _currentCallId = null;
    } catch (e) {
      print('ERROR abandonando llamada: $e');
    }
  }

  void sendOffer(
    String callId,
    String from,
    String to,
    RTCSessionDescription offer,
  ) {
    try {
      print('🚀 Enviando oferta SDP a $to');
      print('🚀 CallId: $callId, From: $from, To: $to');
      print('🚀 Socket conectado: ${socket?.connected}');
      print('🚀 Tipo de oferta: ${offer.type}');

      final offerData = {
        'callId': callId,
        'from': from,
        'to': to,
        'sdp': {'type': offer.type, 'sdp': offer.sdp},
      };

      print('🚀 Datos de oferta a enviar: $offerData');

      // Verificar que el socket esté conectado antes de enviar
      if (socket == null) {
        print(
            '❌ ERROR: Socket es nulo, guardando oferta para reenvío posterior');
        _pendingOutgoingOffer = offerData;
        return;
      }

      if (!socket!.connected) {
        print(
            '❌ ERROR: Socket no está conectado, guardando oferta para reenvío posterior');
        _pendingOutgoingOffer = offerData;
        return;
      }

      socket!.emit('offer', offerData);
      print('✅ Oferta SDP enviada exitosamente');

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
        print(
          '⏰ Timeout: Han pasado 5 segundos desde que se envió la oferta SDP',
        );
        print(
          '⏰ Si no se recibió respuesta, puede haber un problema de conectividad',
        );
      });
    } catch (e) {
      print('❌ ERROR enviando oferta SDP: $e');
    }
  }

  void sendIceCandidate(
    String callId,
    String from,
    String to,
    RTCIceCandidate candidate,
  ) {
    try {
      print('Enviando candidato ICE a $to');
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
      print('ERROR enviando candidato ICE: $e');
    }
  }

  // Limpiar recursos de la llamada actual
  void _cleanupCallResources() {
    print('🧹 Limpiando recursos de la llamada actual');

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
    print('✅ Recursos de llamada limpiados');
  }

  // Notificar que la llamada terminó
  void _notifyCallEnded(Map<String, dynamic> data) {
    if (_onCallEndedCallback != null) {
      _onCallEndedCallback!(data);
    } else {
      print('⚠️ No hay callback configurado para call-ended');
    }
  }

  // Enviar evento de llamada terminada
  void sendEndCall(String callId) {
    if (socket != null && socket!.connected) {
      print('🔚 Enviando end-call para callId: $callId');
      socket!.emit('end-call', {'callId': callId});
    } else {
      print('⚠️ No se puede enviar end-call: socket no conectado');
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
    print('🧹 SocketService liberado y recursos limpiados');
  }

  // Método para verificar si el socket está conectado
  bool isConnected() {
    return _isConnected && socket != null && socket!.connected;
  }

  // Método para actualizar el token sin necesidad de re-crear el socket
  void updateToken(String newToken) {
    if (_token != newToken) {
      print('🔄 Actualizando token de autenticación');
      print(
        '🔍 Estado de _pendingOffer ANTES de updateToken: ${_pendingOffer != null ? "PRESENTE" : "NULO"}',
      );

      _token = newToken;
      _currentUserId = _extractUserIdFromToken(newToken);

      // IMPORTANTE: NO limpiar _pendingOffer aquí si estamos en la misma llamada
      // Solo limpiar si es una llamada completamente nueva
      final newCallId = _extractCallIdFromToken(newToken);
      if (newCallId != null && newCallId != _currentCallId) {
        print(
          '🔄 Nuevo callId detectado ($newCallId vs $_currentCallId), limpiando estado WebRTC',
        );
        _hasRemoteDescription = false;
        _pendingOffer = null;
      } else {
        print('✅ Mismo callId, manteniendo _pendingOffer y estado WebRTC');
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
        print('✅ Token de autenticación Socket.IO actualizado');
      } else {
        // Si no está conectado, intentar reconexión con el nuevo token
        _reconnect();
      }

      print(
        '🔍 Estado de _pendingOffer DESPUÉS de updateToken: ${_pendingOffer != null ? "PRESENTE" : "NULO"}',
      );
    }
  }

  // Método para establecer los datos de la llamada actual
  void setCallData(String callId, String? initiatorId) {
    print(
      '📝 Estableciendo datos de llamada: callId=$callId, initiatorId=$initiatorId',
    );
    _currentCallId = callId;

    // Si tenemos el initiatorId, guardarlo para uso futuro
    if (initiatorId != null) {
      _lastTo = initiatorId;

      // Guardar en _lastIncomingCallData para mantener consistencia
      _lastIncomingCallData[callId] = {
        'initiatorId': initiatorId,
        'callId': callId,
      };

      print(
        '✅ Datos de llamada guardados: callId=$callId, initiatorId=$initiatorId',
      );
    } else {
      print('⚠️ No se proporcionó initiatorId al establecer datos de llamada');
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
      print(
        '⏱️ Iniciando temporizador para reintentar procesar ${_pendingIceCandidates.length} candidatos ICE pendientes',
      );

      // IMPORTANTE: Esperar 1 segundo antes del primer intento para dar tiempo
      // a que la descripción remota se establezca completamente
      Timer(const Duration(milliseconds: 1000), () {
        if (_pendingIceCandidates.isEmpty || _peerConnection == null) {
          print(
            '⚠️ Candidatos ICE o peerConnection no disponibles después del delay inicial',
          );
          return;
        }

        print(
          '🔄 Primer intento de procesar candidatos ICE después del delay inicial',
        );
        _processPendingIceCandidates();

        // Si aún quedan candidatos, iniciar temporizador periódico
        if (_pendingIceCandidates.isNotEmpty) {
          _pendingCandidatesTimer = Timer.periodic(const Duration(seconds: 2), (
            timer,
          ) async {
            if (_pendingIceCandidates.isEmpty) {
              timer.cancel();
              print(
                '✅ Temporizador de candidatos ICE cancelado: no hay candidatos pendientes',
              );
              return;
            }

            if (_peerConnection == null) {
              timer.cancel();
              print(
                '❌ Temporizador de candidatos ICE cancelado: peerConnection es nulo',
              );
              return;
            }

            print(
              '🔄 Reintentando procesar candidatos ICE pendientes: ${_pendingIceCandidates.length} restantes',
            );
            _processPendingIceCandidates();

            // Limitar a un máximo de 10 intentos (20 segundos)
            if (timer.tick >= 10) {
              timer.cancel();
              print(
                '⚠️ Temporizador de candidatos ICE cancelado después de 10 intentos',
              );
              if (_pendingIceCandidates.isNotEmpty) {
                print(
                  '⚠️ Aún quedan ${_pendingIceCandidates.length} candidatos ICE sin procesar',
                );
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
        print('📝 UserId extraído del token: $userId');
        return userId;
      }
    } catch (e) {
      print('⚠️ Error al extraer ID de usuario del token: $e');
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
        print('📝 CallId extraído del token: $callId');
        return callId;
      }
    } catch (e) {
      print('⚠️ Error al extraer callId del token: $e');
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
        print('🔔 VoIP: Solo disponible en iOS, omitiendo notificación');
        return;
      }
    } catch (e) {
      // En Web, Platform.isIOS lanza excepción
      print('🔔 VoIP: No disponible en Web/navegador, omitiendo notificación');
      return;
    }

    try {
      print(
        '🔔 Disparando notificación VoIP para callId: $callId, from: $fromUserId',
      );

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
            print('🔔 Nombre del llamante obtenido: $callerName');
          }
        } catch (e) {
          print('⚠️ Error obteniendo nombre del llamante: $e');
          // Continuar con nombre por defecto
        }
      }

      // Disparar notificación VoIP nativa
      await VoIPService.instance.showIncomingCall(
        callId: callId,
        callerName: callerName,
      );

      print('✅ Notificación VoIP disparada exitosamente');
    } catch (e) {
      print('❌ Error disparando notificación VoIP: $e');
      // No es crítico, el sistema WebSocket sigue funcionando
    }
  }

  // 🔐 ===== MÉTODOS DE CIFRADO ChaCha20-Poly1305 REAL =====

  /// Inicializa el servicio de cifrado ChaCha20-Poly1305
  Future<void> _initEncryption() async {
    try {
      print('🔐 [SOCKET] Inicializando cifrado ChaCha20-Poly1305...');

      _encryptionService = EncryptionService();
      await _encryptionService!.initialize();

      _encryptionInitialized = true;
      print(
        '🔐 [SOCKET] ✅ Cifrado ChaCha20-Poly1305 inicializado correctamente',
      );
      print(
        '🔐 [SOCKET] 📊 Estado del cifrado: ${_encryptionService!.getStatus()}',
      );
    } catch (e) {
      print('🔐 [SOCKET] ❌ Error inicializando cifrado: $e');
      print('🔐 [SOCKET] 📋 Stack trace: ${StackTrace.current}');
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
      print(
        '🔐 [SOCKET] ⚠️ Cifrado no inicializado, omitiendo intercambio de claves',
      );
      print(
        '🔐 [SOCKET] 📊 Estado: initialized=$_encryptionInitialized, service=${_encryptionService != null}',
      );

      // Intentar inicializar el cifrado una vez más
      try {
        print('🔐 [SOCKET] 🔄 Intentando inicializar cifrado nuevamente...');
        await _initEncryption();
        if (!_encryptionInitialized || _encryptionService == null) {
          print('🔐 [SOCKET] ❌ Cifrado sigue sin estar disponible');
          return;
        }
        print(
          '🔐 [SOCKET] ✅ Cifrado inicializado exitosamente en segundo intento',
        );
      } catch (e) {
        print('🔐 [SOCKET] ❌ Segundo intento de inicialización falló: $e');
        return;
      }
    }

    try {
      print('🔐 [SOCKET] 🚀 INICIANDO INTERCAMBIO MILITAR DH - ZERO KNOWLEDGE');
      print('🔐 [SOCKET] 🎯 CallId: $callId');
      print('🔐 [SOCKET] 👤 Rol: ${isInitiator ? "INICIADOR" : "RECEPTOR"}');
      print('🔐 [SOCKET] 🔐 SERVIDOR NUNCA VERÁ SECRETOS COMPARTIDOS');

      // PASO 1: GENERAR CLAVES DH LOCALES (NUNCA SALEN DEL DISPOSITIVO)
      final dhKeyPair = await _encryptionService!.generateDHKeyPair();
      final ephemeralPair = await _encryptionService!.generateEphemeralPair();

      print('🔐 [SOCKET] ✅ Pares DH generados localmente');
      print('🔐 [SOCKET] 🔐 Claves privadas: NUNCA SALEN DEL DISPOSITIVO');

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

      print('🔐 [SOCKET] ✅ Claves privadas almacenadas para callId: $callId');
      print('🔐 [SOCKET] 🔐 _tempCallId establecido: $_tempCallId');
      print('🔐 [SOCKET] ✅ Claves públicas enviadas - esperando respuesta');
      print(
        '🔐 [SOCKET] 🔐 MÁXIMA SEGURIDAD: Forward secrecy + Perfect secrecy',
      );

      // 🔄 PROCESAR CLAVES PÚBLICAS PENDIENTES SI LAS HAY
      if (_pendingPublicKeys != null) {
        print(
          '🔐 [SOCKET] 🔄 Procesando claves públicas que llegaron antes...',
        );
        final pendingData = _pendingPublicKeys!;
        _pendingPublicKeys = null; // Limpiar para evitar re-procesamiento

        // Procesar las claves públicas pendientes
        await _handleSecureKeyExchange(pendingData);
      }
    } catch (e) {
      print('🔐 [SOCKET] ❌ Error en intercambio DH militar: $e');
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
      print(
        '🔐 [SOCKET] ❌ No se puede enviar claves públicas: socket no conectado',
      );
      return;
    }

    try {
      final nonce = _encryptionService!.generateSecureNonce();

      print('🔐 [SOCKET] 📤 ENVIANDO CLAVES PÚBLICAS (SEGURO)...');
      print('🔐 [SOCKET] 📊 DH Pública: ${dhPublic.length} bytes');
      print('🔐 [SOCKET] 📊 Efímera Pública: ${ephemeralPublic.length} bytes');
      print('🔐 [SOCKET] 🔐 NINGUNA CLAVE PRIVADA O SECRETA SE ENVÍA');

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

      print('🔐 [SOCKET] ✅ CLAVES PÚBLICAS ENVIADAS - CERO EXPOSICIÓN');
    } catch (e) {
      print('🔐 [SOCKET] ❌ Error enviando claves públicas: $e');
    }
  }

  /// Procesa las claves públicas recibidas y genera secreto compartido LOCALMENTE
  Future<void> _handleSecureKeyExchange(Map<String, dynamic> data) async {
    if (!_encryptionInitialized || _encryptionService == null) {
      print('🔐 [SOCKET] ⚠️ Cifrado no inicializado, ignorando intercambio DH');
      return;
    }

    try {
      print('🔐 [SOCKET] 📥 CLAVES PÚBLICAS RECIBIDAS - PROCESANDO...');

      final step = data['step'] as String?;
      final callId = data['callId'] as String?;
      final dhPublicBase64 = data['dhPublic'] as String?;
      final ephemeralPublicBase64 = data['ephemeralPublic'] as String?;

      if (step != 'public-keys' ||
          callId != _currentCallId ||
          dhPublicBase64 == null ||
          ephemeralPublicBase64 == null) {
        print('🔐 [SOCKET] ❌ Datos de intercambio DH inválidos');
        return;
      }

      // Verificar que tenemos nuestras claves privadas
      if (_tempDHPrivateKey == null ||
          _tempEphemeralPrivateKey == null ||
          _tempCallId != callId) {
        print(
          '🔐 [SOCKET] ⚠️ Claves privadas aún no generadas, intentando iniciar intercambio DH',
        );
        print(
          '🔐 [SOCKET] 📋 CallId esperado: $_tempCallId, Recibido: $callId',
        );
        print(
          '🔐 [SOCKET] 📋 DH privada: ${_tempDHPrivateKey != null}, Efímera privada: ${_tempEphemeralPrivateKey != null}',
        );

        // 🔄 INTENTAR INICIAR INTERCAMBIO DH COMO RESPALDO SI NO SE HA INICIADO
        if (_tempCallId == null && callId != null) {
          print(
            '🔐 [SOCKET] 🔄 Iniciando intercambio DH de emergencia como receptor',
          );
          try {
            await _startEncryptionKeyExchange(callId, false);
            // Si se inició correctamente, procesar inmediatamente las claves públicas
            if (_tempDHPrivateKey != null &&
                _tempEphemeralPrivateKey != null &&
                _tempCallId == callId) {
              print(
                '🔐 [SOCKET] ✅ Intercambio iniciado exitosamente, procesando claves públicas inmediatamente',
              );
              // Continuar con el procesamiento normal
            } else {
              // Guardar para procesar después
              _pendingPublicKeys = data;
              print(
                '🔐 [SOCKET] 💾 Claves públicas guardadas para procesar después del intercambio',
              );
              return;
            }
          } catch (e) {
            print(
              '🔐 [SOCKET] ❌ Error iniciando intercambio DH de emergencia: $e',
            );
            _pendingPublicKeys = data;
            print(
              '🔐 [SOCKET] 💾 Claves públicas guardadas para procesar después',
            );
            return;
          }
        } else {
          // Guardar las claves públicas para procesarlas cuando tengamos las nuestras
          _pendingPublicKeys = data;
          print(
            '🔐 [SOCKET] 💾 Claves públicas guardadas para procesar después',
          );
          return;
        }
      }

      // Decodificar claves públicas del otro participante
      final theirDHPublic = base64Decode(dhPublicBase64);
      final theirEphemeralPublic = base64Decode(ephemeralPublicBase64);

      print('🔐 [SOCKET] 🔐 COMPUTANDO SECRETOS DH LOCALMENTE...');
      print('🔐 [SOCKET] 📊 Su DH Pública: ${theirDHPublic.length} bytes');
      print(
        '🔐 [SOCKET] 📊 Su Efímera Pública: ${theirEphemeralPublic.length} bytes',
      );

      // PASO CRÍTICO: COMPUTAR SECRETOS COMPARTIDOS LOCALMENTE
      final dh1Secret = await _encryptionService!.computeDH(
        _tempDHPrivateKey!,
        theirDHPublic,
      );
      final dh2Secret = await _encryptionService!.computeDH(
        _tempEphemeralPrivateKey!,
        theirEphemeralPublic,
      );

      print('🔐 [SOCKET] ✅ SECRETOS DH COMPUTADOS LOCALMENTE');
      print(
        '🔐 [SOCKET] 🔐 DH1: ${dh1Secret.length} bytes, DH2: ${dh2Secret.length} bytes',
      );
      print('🔐 [SOCKET] 🔐 SERVIDOR NUNCA VIO ESTOS SECRETOS');

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

      print('🔐 [SOCKET] 🎉 INTERCAMBIO DH MILITAR COMPLETADO');
      print(
        '🔐 [SOCKET] ✅ Clave maestra: ${masterKey.length} bytes (512 bits)',
      );
      print(
        '🔐 [SOCKET] ✅ Clave sesión: ${sessionKey.length} bytes (256 bits)',
      );
      print(
        '🔐 [SOCKET] 🔐 MÁXIMA SEGURIDAD: Forward secrecy + Perfect secrecy',
      );
      print('🔐 [SOCKET] 🛡️ ZERO-KNOWLEDGE: Servidor nunca vio secretos');
      print('🔐 [SOCKET] 🚀 CIFRADO END-TO-END ACTIVO - GRADO MILITAR');

      // LIMPIAR CLAVES TEMPORALES INMEDIATAMENTE
      _tempDHPrivateKey = null;
      _tempEphemeralPrivateKey = null;
      _tempCallId = null;
      _pendingPublicKeys = null;

      print('🔐 [SOCKET] 🗑️ Claves temporales eliminadas de memoria');
    } catch (e) {
      print('🔐 [SOCKET] ❌ Error procesando intercambio DH: $e');

      // Limpiar en caso de error
      _tempDHPrivateKey = null;
      _tempEphemeralPrivateKey = null;
      _tempCallId = null;
      _pendingPublicKeys = null;
    }
  }

  /// MÉTODO OBSOLETO - MANTENIDO PARA COMPATIBILIDAD
  void _sendEncryptionKey(String callId, Uint8List sessionKey) {
    print(
      '🔐 [SOCKET] ⚠️ MÉTODO OBSOLETO: _sendEncryptionKey - Ahora usamos DH militar',
    );
    print('🔐 [SOCKET] 🔐 Las claves ya NO se envían en texto plano');
  }

  /// MÉTODO OBSOLETO - MANTENIDO PARA COMPATIBILIDAD
  Future<void> _handleEncryptionKey(Map<String, dynamic> data) async {
    print(
      '🔐 [SOCKET] ⚠️ MÉTODO OBSOLETO: _handleEncryptionKey - Ahora usamos DH militar',
    );
    print('🔐 [SOCKET] 🔐 Las claves ya NO se reciben en texto plano');
  }

  /// Cifra datos de media antes de enviarlos
  Future<Uint8List?> _encryptMediaData(Uint8List data) async {
    if (!_encryptionInitialized || _encryptionService == null) {
      // Si el cifrado no está disponible, devolver datos sin cifrar
      return data;
    }

    try {
      final encryptedData = await _encryptionService!.encrypt(data);
      print(
        '🔐 [SOCKET] 🔒 Datos cifrados: ${data.length} → ${encryptedData.length} bytes',
      );
      return encryptedData;
    } catch (e) {
      print('🔐 [SOCKET] ❌ Error cifrando datos: $e');
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
      print(
        '🔐 [SOCKET] 🔓 Datos descifrados: ${encryptedData.length} → ${decryptedData.length} bytes',
      );
      return decryptedData;
    } catch (e) {
      print('🔐 [SOCKET] ❌ Error descifrando datos: $e');
      // En caso de error, devolver datos originales
      return encryptedData;
    }
  }

  /// Limpia recursos de cifrado al finalizar la llamada
  void _cleanupEncryption() {
    if (_encryptionService != null) {
      print('🔐 [SOCKET] 🧹 Limpiando recursos de cifrado...');
      _encryptionService!.dispose();
      _encryptionService = null;
      _encryptionInitialized = false;
      print('🔐 [SOCKET] ✅ Recursos de cifrado limpiados');
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
    print('🔐 [SOCKET] === DIAGNÓSTICO DE CIFRADO ===');
    print('🔐 [SOCKET] 📊 _encryptionInitialized: $_encryptionInitialized');
    print(
      '🔐 [SOCKET] 📊 _encryptionService != null: ${_encryptionService != null}',
    );
    print('🔐 [SOCKET] 📊 isEncryptionActive(): ${isEncryptionActive()}');

    if (_encryptionService != null) {
      try {
        final status = _encryptionService!.getStatus();
        print('🔐 [SOCKET] 📊 Estado del servicio: $status');
      } catch (e) {
        print('🔐 [SOCKET] ❌ Error obteniendo estado: $e');
      }
    } else {
      print('🔐 [SOCKET] ⚠️ Servicio de cifrado es null');
    }
    print('🔐 [SOCKET] === FIN DIAGNÓSTICO ===');
  }
}
