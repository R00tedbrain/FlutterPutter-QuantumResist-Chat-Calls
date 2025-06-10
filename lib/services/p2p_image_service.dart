import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:crypto/crypto.dart';
import 'dart:io';
// import 'package:image/image.dart' as img; // Comentado temporalmente - agregar dependencia
import '../services/encryption_service.dart';
import '../services/socket_service.dart';

/// Servicio para envío de imágenes peer-to-peer completamente encriptadas
/// Las imágenes nunca tocan el servidor - solo comunicación directa entre dispositivos
class P2PImageService {
  static P2PImageService? _instance;
  static P2PImageService get instance =>
      _instance ??= P2PImageService._internal();
  P2PImageService._internal();

  // Data channel para comunicación directa
  RTCDataChannel? _dataChannel;
  RTCPeerConnection? _peerConnection;

  // Cifrado end-to-end
  EncryptionService? _encryptionService;
  bool _isInitialized = false;

  // Control de chunks para imágenes grandes
  static const int CHUNK_SIZE = 16384; // 16KB chunks
  final Map<String, _ImageTransfer> _incomingTransfers = {};
  final Map<String, _ImageTransfer> _outgoingTransfers = {};

  // Callbacks
  Function(Uint8List imageData, String senderId, Map<String, dynamic> metadata)?
      onImageReceived;
  Function(String transferId, double progress)? onTransferProgress;
  Function(String error)? onError;

  /// Inicializar el servicio con conexión WebRTC existente
  Future<bool> initialize({
    required RTCPeerConnection peerConnection,
    required String roomId,
    required String userId,
  }) async {
    try {
      _peerConnection = peerConnection;

      // Inicializar cifrado ChaCha20-Poly1305
      await _initializeEncryption(roomId);

      // Configurar data channel para imágenes
      await _setupDataChannel(userId);

      _isInitialized = true;
      return true;
    } catch (e) {
      onError?.call('Error inicializando servicio de imágenes: $e');
      return false;
    }
  }

  /// Configurar cifrado usando el mismo sistema de videollamadas
  Future<void> _initializeEncryption(String roomId) async {
    try {
      _encryptionService = EncryptionService();
      await _encryptionService!.initialize();

      // Derivar clave específica para imágenes usando roomId
      final masterKey = Uint8List(128); // 128 bytes como las salas efímeras
      final random = Random.secure();
      for (int i = 0; i < 128; i++) {
        masterKey[i] = random.nextInt(256);
      }

      // Derivar clave de sesión específica para imágenes
      final imageKey = await _encryptionService!
          .deriveSessionKeyFromShared(masterKey, 'p2p-images-$roomId');

      await _encryptionService!.setSessionKey(imageKey);
    } catch (e) {
      rethrow;
    }
  }

  /// Configurar WebRTC Data Channel para transferencias directas
  Future<void> _setupDataChannel(String userId) async {
    try {
      // Crear data channel confiable y ordenado para imágenes
      _dataChannel = await _peerConnection!.createDataChannel(
          'p2p-images',
          RTCDataChannelInit()
            ..ordered = true
            ..maxRetransmits = 3);

      // Configurar event handlers usando el patrón correcto
      _dataChannel!.stateChangeStream.listen((state) {
        if (state == RTCDataChannelState.RTCDataChannelOpen) {
          // Data channel abierto - Listo para transferencias P2P
        } else if (state == RTCDataChannelState.RTCDataChannelClosed) {
          // Data channel cerrado
        }
      });

      _dataChannel!.messageStream.listen((RTCDataChannelMessage message) {
        _handleIncomingData(message.binary, message.text);
      }, onError: (error) {
        onError?.call('Error en comunicación P2P: $error');
      });

      // También escuchar data channels entrantes
      _peerConnection!.onDataChannel = (RTCDataChannel channel) {
        if (channel.label == 'p2p-images') {
          _dataChannel = channel;
          _setupDataChannelHandlers();
        }
      };
    } catch (e) {
      rethrow;
    }
  }

  /// Configurar handlers para data channel entrante
  void _setupDataChannelHandlers() {
    _dataChannel!.messageStream.listen((RTCDataChannelMessage message) {
      _handleIncomingData(message.binary, message.text);
    }, onError: (error) {
      onError?.call('Error en comunicación P2P: $error');
    });
  }

  /// Enviar imagen de forma completamente peer-to-peer
  Future<bool> sendImage({
    required Uint8List imageData,
    required String recipientId,
    Map<String, dynamic>? metadata,
    int? maxWidth,
    int? maxHeight,
    int? quality,
  }) async {
    if (!_isInitialized || _dataChannel == null || _encryptionService == null) {
      onError?.call('Servicio de imágenes no inicializado');
      return false;
    }

    if (_dataChannel!.state != RTCDataChannelState.RTCDataChannelOpen) {
      onError?.call('Conexión P2P no disponible');
      return false;
    }

    try {
      // Optimizar imagen si es necesario (simplificado sin image package)
      Uint8List processedImage = imageData;
      if (maxWidth != null || maxHeight != null || quality != null) {
        // Optimización de imagen no disponible - usando imagen original
      }

      // Cifrar imagen completa
      final encryptedImage = await _encryptionService!.encrypt(processedImage);

      // Generar ID único para la transferencia
      final transferId = _generateTransferId();

      // Crear metadata de transferencia
      final transferMetadata = {
        'transferId': transferId,
        'totalSize': encryptedImage.length,
        'chunkSize': CHUNK_SIZE,
        'totalChunks': (encryptedImage.length / CHUNK_SIZE).ceil(),
        'senderId': recipientId, // ID del remitente
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'metadata': metadata ?? {},
      };

      // Enviar metadata de inicio
      await _sendControlMessage('transfer-start', transferMetadata);

      // Dividir en chunks y enviar
      await _sendImageChunks(transferId, encryptedImage);

      // Enviar mensaje de finalización
      await _sendControlMessage(
          'transfer-complete', {'transferId': transferId});

      return true;
    } catch (e) {
      onError?.call('Error enviando imagen: $e');
      return false;
    }
  }

  /// Enviar imagen dividida en chunks
  Future<void> _sendImageChunks(
      String transferId, Uint8List encryptedData) async {
    final totalChunks = (encryptedData.length / CHUNK_SIZE).ceil();

    for (int i = 0; i < totalChunks; i++) {
      final start = i * CHUNK_SIZE;
      final end = (start + CHUNK_SIZE).clamp(0, encryptedData.length);
      final chunk = encryptedData.sublist(start, end);

      final chunkMessage = {
        'type': 'image-chunk',
        'transferId': transferId,
        'chunkIndex': i,
        'totalChunks': totalChunks,
        'data': base64Encode(chunk),
      };

      await _sendDataChannelMessage(jsonEncode(chunkMessage));

      // Actualizar progreso
      final progress = (i + 1) / totalChunks;
      onTransferProgress?.call(transferId, progress);

      // Pequeño delay para no saturar la conexión
      if (i % 10 == 0) {
        await Future.delayed(const Duration(milliseconds: 10));
      }
    }
  }

  /// Manejar datos entrantes del data channel
  void _handleIncomingData(Uint8List? binaryData, String? textData) {
    try {
      if (textData != null) {
        final message = jsonDecode(textData) as Map<String, dynamic>;
        _handleControlMessage(message);
      }
    } catch (e) {
      // Error procesando datos entrantes
    }
  }

  /// Manejar mensajes de control
  void _handleControlMessage(Map<String, dynamic> message) async {
    final type = message['type'] as String?;

    switch (type) {
      case 'transfer-start':
        await _handleTransferStart(message);
        break;
      case 'image-chunk':
        await _handleImageChunk(message);
        break;
      case 'transfer-complete':
        await _handleTransferComplete(message);
        break;
      default:
        // Tipo de mensaje desconocido
        break;
    }
  }

  /// Manejar inicio de transferencia
  Future<void> _handleTransferStart(Map<String, dynamic> message) async {
    final transferId = message['transferId'] as String;
    final totalSize = message['totalSize'] as int;
    final totalChunks = message['totalChunks'] as int;
    final senderId = message['senderId'] as String;
    final metadata = message['metadata'] as Map<String, dynamic>?;

    _incomingTransfers[transferId] = _ImageTransfer(
      transferId: transferId,
      totalSize: totalSize,
      totalChunks: totalChunks,
      senderId: senderId,
      metadata: metadata,
    );
  }

  /// Manejar chunk de imagen
  Future<void> _handleImageChunk(Map<String, dynamic> message) async {
    final transferId = message['transferId'] as String;
    final chunkIndex = message['chunkIndex'] as int;
    final chunkData = base64Decode(message['data'] as String);

    final transfer = _incomingTransfers[transferId];
    if (transfer == null) {
      return;
    }

    // Agregar chunk
    transfer.addChunk(chunkIndex, chunkData);

    // Actualizar progreso
    final progress = transfer.receivedChunks.length / transfer.totalChunks;
    onTransferProgress?.call(transferId, progress);
  }

  /// Manejar finalización de transferencia
  Future<void> _handleTransferComplete(Map<String, dynamic> message) async {
    final transferId = message['transferId'] as String;

    final transfer = _incomingTransfers[transferId];
    if (transfer == null) {
      return;
    }

    try {
      // Ensamblar imagen completa
      final encryptedImage = transfer.assembleImage();

      // Descifrar imagen
      final decryptedImage = await _encryptionService!.decrypt(encryptedImage);

      // Notificar imagen recibida
      onImageReceived?.call(
          decryptedImage, transfer.senderId, transfer.metadata ?? {});

      // Limpiar transferencia
      _incomingTransfers.remove(transferId);
    } catch (e) {
      onError?.call('Error procesando imagen recibida: $e');
    }
  }

  /// Enviar mensaje de control
  Future<void> _sendControlMessage(
      String type, Map<String, dynamic> data) async {
    final message = {
      'type': type,
      ...data,
    };
    await _sendDataChannelMessage(jsonEncode(message));
  }

  /// Enviar mensaje por data channel
  Future<void> _sendDataChannelMessage(String message) async {
    if (_dataChannel != null &&
        _dataChannel!.state == RTCDataChannelState.RTCDataChannelOpen) {
      _dataChannel!.send(RTCDataChannelMessage(message));
    } else {
      throw Exception('Data channel no disponible');
    }
  }

  /// Generar ID único para transferencia
  String _generateTransferId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999999)}';
  }

  /// Limpiar recursos
  void dispose() {
    _dataChannel?.close();
    _dataChannel = null;

    _encryptionService?.dispose();
    _encryptionService = null;

    _incomingTransfers.clear();
    _outgoingTransfers.clear();

    _isInitialized = false;
  }

  /// Verificar si el servicio está listo
  bool get isReady =>
      _isInitialized &&
      _dataChannel != null &&
      _dataChannel!.state == RTCDataChannelState.RTCDataChannelOpen;

  /// Obtener estadísticas del servicio
  Map<String, dynamic> getStats() {
    return {
      'isInitialized': _isInitialized,
      'dataChannelState': _dataChannel?.state.toString(),
      'encryptionActive': _encryptionService != null,
      'activeIncomingTransfers': _incomingTransfers.length,
      'activeOutgoingTransfers': _outgoingTransfers.length,
    };
  }
}

/// Clase para manejar transferencias de imágenes
class _ImageTransfer {
  final String transferId;
  final int totalSize;
  final int totalChunks;
  final String senderId;
  final Map<String, dynamic>? metadata;
  final Map<int, Uint8List> receivedChunks = {};

  _ImageTransfer({
    required this.transferId,
    required this.totalSize,
    required this.totalChunks,
    required this.senderId,
    this.metadata,
  });

  void addChunk(int index, Uint8List data) {
    receivedChunks[index] = data;
  }

  bool get isComplete => receivedChunks.length == totalChunks;

  Uint8List assembleImage() {
    if (!isComplete) {
      throw Exception(
          'Transferencia incompleta: ${receivedChunks.length}/$totalChunks chunks');
    }

    // Ensamblar chunks en orden
    final result = <int>[];
    for (int i = 0; i < totalChunks; i++) {
      final chunk = receivedChunks[i];
      if (chunk == null) {
        throw Exception('Chunk faltante: $i');
      }
      result.addAll(chunk);
    }

    return Uint8List.fromList(result);
  }
}
