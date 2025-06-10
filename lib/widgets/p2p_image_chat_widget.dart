import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import '../services/p2p_image_service.dart';

/// Widget para demostrar el envío de imágenes P2P encriptadas
/// Con funcionalidad completa de selección de imágenes
class P2PImageChatWidget extends StatefulWidget {
  final String roomId;
  final String userId;
  final String? otherUserId;

  const P2PImageChatWidget({
    super.key,
    required this.roomId,
    required this.userId,
    this.otherUserId,
  });

  @override
  State<P2PImageChatWidget> createState() => _P2PImageChatWidgetState();
}

class _P2PImageChatWidgetState extends State<P2PImageChatWidget>
    with TickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  final List<_ImageMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();

  bool _isServiceReady = false;
  String _statusMessage = 'Inicializando...';
  final Map<String, double> _uploadProgress = {};

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeService();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    _pulseController.repeat(reverse: true);
  }

  void _initializeService() {
    // Configurar callbacks del servicio P2P
    P2PImageService.instance.onImageReceived = _onImageReceived;
    P2PImageService.instance.onTransferProgress = _onTransferProgress;
    P2PImageService.instance.onError = _onError;

    // Verificar si el servicio ya está listo
    _checkServiceStatus();
  }

  void _checkServiceStatus() {
    setState(() {
      _isServiceReady = P2PImageService.instance.isReady;
      if (_isServiceReady) {
        _statusMessage = '✅ Sistema P2P listo - Imágenes encriptadas E2E';
      } else {
        _statusMessage = '⏳ Esperando conexión WebRTC...';
        // Reintentar en 2 segundos
        Future.delayed(const Duration(seconds: 2), _checkServiceStatus);
      }
    });
  }

  void _onImageReceived(
      Uint8List imageData, String senderId, Map<String, dynamic> metadata) {
    setState(() {
      _messages.add(_ImageMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        imageData: imageData,
        senderId: senderId,
        timestamp: DateTime.now(),
        isOutgoing: false,
        metadata: metadata,
      ));
    });

    _scrollToBottom();
    _showImageReceivedNotification(senderId);
    HapticFeedback.lightImpact();
  }

  void _onTransferProgress(String transferId, double progress) {
    setState(() {
      _uploadProgress[transferId] = progress;
    });
  }

  void _onError(String error) {
    _showErrorSnackBar(error);
  }

  void _showImageReceivedNotification(String senderId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.image, color: Colors.white),
            const SizedBox(width: 8),
            Text('📸 Imagen recibida de $senderId'),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text('❌ $error')),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
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

  // Función principal para enviar imagen desde galería o cámara
  Future<void> _pickAndSendImage(ImageSource source) async {
    if (!_isServiceReady) {
      _showErrorSnackBar('Servicio P2P no está listo');
      return;
    }

    if (widget.otherUserId == null) {
      _showErrorSnackBar('No hay usuario destinatario');
      return;
    }

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      final Uint8List imageData = await pickedFile.readAsBytes();
      final String fileName = pickedFile.name;
      final int fileSize = imageData.length;

      // Crear mensaje optimista (se mostrará inmediatamente)
      final messageId = DateTime.now().millisecondsSinceEpoch.toString();
      final message = _ImageMessage(
        id: messageId,
        imageData: imageData,
        senderId: widget.userId,
        timestamp: DateTime.now(),
        isOutgoing: true,
        metadata: {
          'fileName': fileName,
          'fileSize': fileSize,
        },
        status: _ImageMessageStatus.sending,
      );

      setState(() {
        _messages.add(message);
        _uploadProgress[messageId] = 0.0;
      });

      _scrollToBottom();

      // Enviar imagen vía P2P
      final success = await P2PImageService.instance.sendImage(
        imageData: imageData,
        recipientId: widget.otherUserId!,
        metadata: {
          'fileName': fileName,
          'fileSize': fileSize,
          'timestamp': DateTime.now().toIso8601String(),
        },
        maxWidth: 1920,
        maxHeight: 1080,
        quality: 85,
      );

      // Actualizar estado del mensaje
      setState(() {
        final index = _messages.indexWhere((m) => m.id == messageId);
        if (index != -1) {
          _messages[index] = _messages[index].copyWith(
            status:
                success ? _ImageMessageStatus.sent : _ImageMessageStatus.failed,
          );
        }
        _uploadProgress.remove(messageId);
      });

      if (success) {
        HapticFeedback.mediumImpact();
        _showSuccessSnackBar('📤 Imagen enviada de forma segura');
      } else {
        _showErrorSnackBar('Error enviando imagen');
      }
    } catch (e) {
      _showErrorSnackBar('Error seleccionando imagen: $e');
    }
  }

  // Función de prueba para enviar imagen de ejemplo
  Future<void> _sendTestImage() async {
    if (!_isServiceReady) {
      _showErrorSnackBar('Servicio P2P no está listo');
      return;
    }

    if (widget.otherUserId == null) {
      _showErrorSnackBar('No hay usuario destinatario');
      return;
    }

    try {
      // Crear imagen de prueba (pixel rojo simple)
      final testImageData = _createTestImageData();

      // Crear mensaje optimista (se mostrará inmediatamente)
      final messageId = DateTime.now().millisecondsSinceEpoch.toString();
      final message = _ImageMessage(
        id: messageId,
        imageData: testImageData,
        senderId: widget.userId,
        timestamp: DateTime.now(),
        isOutgoing: true,
        metadata: {
          'fileName': 'test_image.png',
          'fileSize': testImageData.length,
          'type': 'test',
        },
        status: _ImageMessageStatus.sending,
      );

      setState(() {
        _messages.add(message);
        _uploadProgress[messageId] = 0.0;
      });

      _scrollToBottom();

      // Enviar imagen vía P2P
      final success = await P2PImageService.instance.sendImage(
        imageData: testImageData,
        recipientId: widget.otherUserId!,
        metadata: {
          'fileName': 'test_image.png',
          'fileSize': testImageData.length,
          'timestamp': DateTime.now().toIso8601String(),
          'type': 'test',
        },
      );

      // Actualizar estado del mensaje
      setState(() {
        final index = _messages.indexWhere((m) => m.id == messageId);
        if (index != -1) {
          _messages[index] = _messages[index].copyWith(
            status:
                success ? _ImageMessageStatus.sent : _ImageMessageStatus.failed,
          );
        }
        _uploadProgress.remove(messageId);
      });

      if (success) {
        HapticFeedback.mediumImpact();
        _showSuccessSnackBar('📤 Imagen de prueba enviada de forma segura');
      } else {
        _showErrorSnackBar('Error enviando imagen de prueba');
      }
    } catch (e) {
      _showErrorSnackBar('Error creando imagen de prueba: $e');
    }
  }

  // Crear imagen de prueba simple (PNG 2x2 píxeles)
  Uint8List _createTestImageData() {
    // PNG simple de 2x2 píxeles rojos
    return Uint8List.fromList([
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // PNG signature
      0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, // IHDR chunk
      0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x02, // width=2, height=2
      0x08, 0x02, 0x00, 0x00, 0x00, 0xA5, 0x55,
      0x6A, // bit depth=8, color type=2
      0x00, 0x00, 0x00, 0x12, 0x49, 0x44, 0x41, 0x54, // IDAT chunk
      0x08, 0x99, 0x01, 0x07, 0x00, 0xF8, 0xFF, 0xFF, // compressed image data
      0x00, 0x00, 0xFF, 0x00, 0x00, 0xFF, 0x00, 0x02, // red pixels
      0x07, 0x01, 0x02, 0x9A, 0x1C, 0x7A,
      0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, // IEND chunk
      0xAE, 0x42, 0x60, 0x82,
    ]);
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
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
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '📸 Enviar Imagen Encriptada P2P',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blue),
              title: const Text('Tomar Foto'),
              subtitle: const Text('Usar cámara del dispositivo'),
              onTap: () {
                Navigator.pop(context);
                _pickAndSendImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.green),
              title: const Text('Galería'),
              subtitle: const Text('Seleccionar de galería'),
              onTap: () {
                Navigator.pop(context);
                _pickAndSendImage(ImageSource.gallery);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.bug_report, color: Colors.orange),
              title: const Text('Imagen de Prueba'),
              subtitle: const Text('Enviar imagen de test'),
              onTap: () {
                Navigator.pop(context);
                _sendTestImage();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.9),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(color: Colors.blue.shade600, width: 1),
      ),
      child: Column(
        children: [
          // Header con estado
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _isServiceReady
                  ? Colors.green.shade900.withOpacity(0.8)
                  : Colors.orange.shade900.withOpacity(0.8),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _isServiceReady ? 1.0 : _pulseAnimation.value,
                      child: Icon(
                        _isServiceReady ? Icons.security : Icons.sync,
                        color: _isServiceReady
                            ? Colors.green.shade400
                            : Colors.orange.shade400,
                        size: 16,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _statusMessage,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _isServiceReady
                          ? Colors.green.shade300
                          : Colors.orange.shade300,
                    ),
                  ),
                ),
                if (_isServiceReady)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.shade600,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '🔐',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Lista de mensajes o estado vacío
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return _buildImageMessage(_messages[index]);
                    },
                  ),
          ),

          // Barra de input con botones más visibles
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              border: Border(
                top: BorderSide(color: Colors.grey.shade700),
              ),
            ),
            child: Row(
              children: [
                // Botón de cámara
                IconButton(
                  onPressed: _isServiceReady
                      ? () => _pickAndSendImage(ImageSource.camera)
                      : null,
                  icon: Icon(
                    Icons.camera_alt,
                    color: _isServiceReady
                        ? Colors.blue.shade400
                        : Colors.grey.shade600,
                    size: 24,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: _isServiceReady
                        ? Colors.blue.shade600.withOpacity(0.2)
                        : Colors.transparent,
                    padding: const EdgeInsets.all(8),
                  ),
                ),
                const SizedBox(width: 8),

                // Botón de galería
                IconButton(
                  onPressed: _isServiceReady
                      ? () => _pickAndSendImage(ImageSource.gallery)
                      : null,
                  icon: Icon(
                    Icons.photo_library,
                    color: _isServiceReady
                        ? Colors.green.shade400
                        : Colors.grey.shade600,
                    size: 24,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: _isServiceReady
                        ? Colors.green.shade600.withOpacity(0.2)
                        : Colors.transparent,
                    padding: const EdgeInsets.all(8),
                  ),
                ),

                const SizedBox(width: 8),

                // Texto informativo
                Expanded(
                  child: Text(
                    _isServiceReady
                        ? 'Imágenes cifradas P2P'
                        : 'Esperando conexión...',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 12,
                    ),
                  ),
                ),

                // Botón principal más visible
                ElevatedButton.icon(
                  onPressed: _isServiceReady ? _showImageSourceDialog : null,
                  icon: const Icon(Icons.add_a_photo, size: 18),
                  label: const Text('Enviar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isServiceReady
                        ? Colors.blue.shade600
                        : Colors.grey.shade600,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_camera,
            size: 40,
            color: Colors.white.withOpacity(0.6),
          ),
          const SizedBox(height: 12),
          Text(
            '📸 Chat de Imágenes P2P',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Envía imágenes cifradas directamente\nentre dispositivos sin pasar por el servidor',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _isServiceReady ? _showImageSourceDialog : null,
            icon: const Icon(Icons.add_a_photo),
            label: const Text('Enviar Primera Imagen'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageMessage(_ImageMessage message) {
    final isOutgoing = message.isOutgoing;
    final progress = _uploadProgress[message.id];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment:
            isOutgoing ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isOutgoing) ...[
            CircleAvatar(
              radius: 12,
              backgroundColor: Colors.blue.shade600,
              child: Text(
                message.senderId.substring(0, 1).toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 180),
              child: Column(
                crossAxisAlignment: isOutgoing
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: isOutgoing
                          ? Colors.blue.shade600
                          : Colors.grey.shade700,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            message.imageData,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 120,
                                height: 120,
                                color: Colors.grey.shade600,
                                child: const Center(
                                  child: Icon(Icons.broken_image,
                                      size: 24, color: Colors.white),
                                ),
                              );
                            },
                          ),
                        ),
                        if (progress != null) _buildProgressIndicator(progress),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.timestamp),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                      if (isOutgoing) ...[
                        const SizedBox(width: 4),
                        _buildStatusIcon(message.status),
                      ],
                      const SizedBox(width: 4),
                      Icon(
                        Icons.lock,
                        size: 10,
                        color: Colors.green.shade400,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isOutgoing) ...[
            const SizedBox(width: 6),
            CircleAvatar(
              radius: 12,
              backgroundColor: Colors.green.shade600,
              child: Text(
                message.senderId.substring(0, 1).toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(double progress) {
    return Container(
      padding: const EdgeInsets.all(6),
      child: LinearProgressIndicator(
        value: progress,
        backgroundColor: Colors.grey.shade400,
        valueColor: AlwaysStoppedAnimation(Colors.blue.shade600),
        minHeight: 3,
      ),
    );
  }

  Widget _buildStatusIcon(_ImageMessageStatus status) {
    switch (status) {
      case _ImageMessageStatus.sending:
        return SizedBox(
          width: 10,
          height: 10,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            valueColor: AlwaysStoppedAnimation(Colors.white.withOpacity(0.6)),
          ),
        );
      case _ImageMessageStatus.sent:
        return Icon(Icons.done, size: 10, color: Colors.green.shade400);
      case _ImageMessageStatus.failed:
        return Icon(Icons.error, size: 10, color: Colors.red.shade400);
    }
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

/// Modelo para mensajes de imagen
class _ImageMessage {
  final String id;
  final Uint8List imageData;
  final String senderId;
  final DateTime timestamp;
  final bool isOutgoing;
  final Map<String, dynamic> metadata;
  final _ImageMessageStatus status;

  _ImageMessage({
    required this.id,
    required this.imageData,
    required this.senderId,
    required this.timestamp,
    required this.isOutgoing,
    required this.metadata,
    this.status = _ImageMessageStatus.sent,
  });

  _ImageMessage copyWith({
    String? id,
    Uint8List? imageData,
    String? senderId,
    DateTime? timestamp,
    bool? isOutgoing,
    Map<String, dynamic>? metadata,
    _ImageMessageStatus? status,
  }) {
    return _ImageMessage(
      id: id ?? this.id,
      imageData: imageData ?? this.imageData,
      senderId: senderId ?? this.senderId,
      timestamp: timestamp ?? this.timestamp,
      isOutgoing: isOutgoing ?? this.isOutgoing,
      metadata: metadata ?? this.metadata,
      status: status ?? this.status,
    );
  }
}

enum _ImageMessageStatus {
  sending,
  sent,
  failed,
}
