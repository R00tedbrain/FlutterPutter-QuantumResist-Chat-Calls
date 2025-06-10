import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:provider/provider.dart';
import 'package:flutterputter/models/user.dart';
import 'package:flutterputter/providers/call_provider.dart';
import 'package:flutterputter/theme/app_theme.dart';
import 'package:flutterputter/widgets/user_avatar.dart';
// Importar servicios y widgets P2P
import 'package:flutterputter/services/p2p_image_service.dart';
import 'package:flutterputter/widgets/p2p_image_chat_widget.dart';

class CallScreen extends StatefulWidget {
  final User remoteUser;
  final bool isVideo;

  const CallScreen({
    super.key,
    required this.remoteUser,
    this.isVideo = true,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  late CallProvider _callProvider;
  // Estado para el widget P2P
  bool _showP2PChat = false;

  @override
  void initState() {
    super.initState();
    _callProvider = Provider.of<CallProvider>(context, listen: false);
    _initRenderers();
    // Inicializar sistema P2P
    _initializeP2PImages();

    // Escuchar cambios en el estado de la llamada para navegación automática
    _callProvider.addListener(_onCallStateChanged);
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();

    if (mounted) {
      setState(() {
        _localRenderer.srcObject = _callProvider.localStream;
        _remoteRenderer.srcObject = _callProvider.remoteStream;
      });
    }

    // Escuchar cambios en los streams con verificación de mounted
    _callProvider.addListener(_updateRenderers);
  }

  void _updateRenderers() {
    if (mounted) {
      setState(() {
        _localRenderer.srcObject = _callProvider.localStream;
        _remoteRenderer.srcObject = _callProvider.remoteStream;
      });
    }
  }

  // Manejar cambios en el estado de la llamada para navegación automática
  void _onCallStateChanged() {
    if (!mounted) return;

    final callState = _callProvider.callState;

    // Si la llamada terminó (idle) o hay error, navegar de vuelta automáticamente
    // SOLO si no estamos ya en proceso de navegación manual
    if (callState == CallState.idle || callState == CallState.disconnected) {
      // Verificar si ya hay un diálogo de navegación abierto
      final hasDialog = ModalRoute.of(context)?.isCurrent != true;

      if (!hasDialog) {
        // Usar un pequeño delay para asegurar que el estado se actualice completamente
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        });
      } else {
        // Ya hay navegación en progreso, omitiendo navegación automática
      }
    }
  }

  @override
  void dispose() {
    _callProvider.removeListener(_updateRenderers);
    _callProvider.removeListener(_onCallStateChanged);
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  // Finalizar llamada
  void _endCall() async {
    try {
      // Mostrar indicador de carga mientras se procesa
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        );
      }

      await _callProvider.endCall();

      // Cerrar diálogo de carga si está abierto
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context); // Cerrar diálogo de carga
      }

      // Navegar de vuelta a HomeScreen SIEMPRE, independientemente del resultado
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      // Cerrar diálogo de carga si está abierto
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context); // Cerrar diálogo de carga
      }

      // Navegar de vuelta INCLUSO si hay error
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }

  // Cambiar estado del micrófono
  void _toggleMicrophone() {
    _callProvider.toggleMic();
  }

  // Cambiar estado de la cámara
  void _toggleCamera() {
    _callProvider.toggleCamera();
  }

  // Cambiar salida de audio
  void _toggleSpeaker() {
    _callProvider.toggleSpeaker();
  }

  // Inicializar sistema P2P de imágenes (NO altera funcionamiento de videollamada)
  Future<void> _initializeP2PImages() async {
    // Esperar a que la conexión WebRTC esté lista
    Future.delayed(const Duration(seconds: 3), () async {
      if (_callProvider.peerConnection != null &&
          _callProvider.callId != null) {
        try {
          await P2PImageService.instance.initialize(
            peerConnection: _callProvider.peerConnection!,
            roomId: _callProvider.callId!,
            userId: 'current_user_id', // Obtener del contexto real
          );
        } catch (e) {
          // Error inicializando P2P de imágenes
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            return Stack(
              children: [
                // Fondo diferente según tipo de llamada
                if (widget.isVideo)
                  // Video remoto para videollamada
                  _callProvider.remoteStream != null
                      ? RTCVideoView(
                          _remoteRenderer,
                          objectFit:
                              RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                        )
                      : const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(color: Colors.white),
                              SizedBox(height: 16),
                              Text(
                                'Esperando conexión...',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        )
                else
                  // Pantalla para llamada de audio
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        UserAvatar(
                          name: widget.remoteUser.nickname,
                          radius: 80,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          widget.remoteUser.nickname,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _callProvider.callState == CallState.connected
                              ? 'Llamada en curso'
                              : 'Conectando...',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 30),
                        if (_callProvider.callState == CallState.connected)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.timer, color: Colors.white60),
                              const SizedBox(width: 5),
                              StreamBuilder(
                                stream:
                                    Stream.periodic(const Duration(seconds: 1)),
                                builder: (context, snapshot) {
                                  return Text(
                                    _formatDuration(DateTime.now().difference(
                                        DateTime.now().subtract(
                                            const Duration(minutes: 2)))),
                                    style:
                                        const TextStyle(color: Colors.white60),
                                  );
                                },
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),

                // Información del usuario remoto (solo para videollamada)
                if (widget.isVideo)
                  Positioned(
                    top: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.remoteUser.nickname,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                // Video local (solo para videollamada)
                if (widget.isVideo)
                  Positioned(
                    right: 20,
                    top: 60,
                    width: orientation == Orientation.portrait ? 100 : 150,
                    height: orientation == Orientation.portrait ? 150 : 100,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _callProvider.localStream != null
                            ? RTCVideoView(
                                _localRenderer,
                                mirror: true,
                                objectFit: RTCVideoViewObjectFit
                                    .RTCVideoViewObjectFitCover,
                              )
                            : const Center(
                                child: CircularProgressIndicator(),
                              ),
                      ),
                    ),
                  ),

                // Controles
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Consumer<CallProvider>(
                    builder: (context, callProvider, _) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Micrófono
                          CircleAvatar(
                            backgroundColor: Colors.white30,
                            radius: 25,
                            child: IconButton(
                              icon: Icon(
                                callProvider.isMicMuted
                                    ? Icons.mic_off
                                    : Icons.mic,
                                color: Colors.white,
                              ),
                              onPressed: _toggleMicrophone,
                            ),
                          ),

                          // P2P Images (NUEVO - no altera funcionalidad existente)
                          CircleAvatar(
                            backgroundColor: _showP2PChat
                                ? Colors.blue.shade600
                                : Colors.white30,
                            radius: 20,
                            child: IconButton(
                              icon: Icon(
                                Icons.photo_camera,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _showP2PChat = !_showP2PChat;
                                });
                              },
                            ),
                          ),

                          // Finalizar llamada
                          CircleAvatar(
                            backgroundColor: AppTheme.callEndColor,
                            radius: 30,
                            child: IconButton(
                              icon: const Icon(
                                Icons.call_end,
                                color: Colors.white,
                                size: 30,
                              ),
                              onPressed: _endCall,
                            ),
                          ),

                          // Cámara (solo si es videollamada)
                          if (widget.isVideo)
                            CircleAvatar(
                              backgroundColor: Colors.white30,
                              radius: 25,
                              child: IconButton(
                                icon: Icon(
                                  callProvider.isCameraOff
                                      ? Icons.videocam_off
                                      : Icons.videocam,
                                  color: Colors.white,
                                ),
                                onPressed: _toggleCamera,
                              ),
                            ),

                          // Altavoz
                          CircleAvatar(
                            backgroundColor: Colors.white30,
                            radius: 25,
                            child: IconButton(
                              icon: Icon(
                                callProvider.isSpeakerOn
                                    ? Icons.volume_up
                                    : Icons.volume_off,
                                color: Colors.white,
                              ),
                              onPressed: _toggleSpeaker,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // Widget P2P flotante (NUEVO - no interfiere con videollamada)
                if (_showP2PChat)
                  Positioned(
                    bottom: 140,
                    left: 20,
                    right: 20,
                    child: P2PImageChatWidget(
                      roomId: _callProvider.callId ?? 'room_id',
                      userId: 'current_user_id', // Obtener del contexto real
                      otherUserId: widget.remoteUser.id.toString(),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Formatear duración para mostrar contador de tiempo
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}
