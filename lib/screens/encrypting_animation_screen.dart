import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class EncryptingAnimationScreen extends StatefulWidget {
  const EncryptingAnimationScreen({super.key});

  @override
  State<EncryptingAnimationScreen> createState() =>
      _EncryptingAnimationScreenState();
}

class _EncryptingAnimationScreenState extends State<EncryptingAnimationScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller =
          VideoPlayerController.asset('assets/images/encriptando.mp4');

      await _controller.initialize();

      setState(() {
        _isInitialized = true;
      });

      // Reproducir la animación una vez
      await _controller.play();

      // Escuchar cuando termine la animación
      _controller.addListener(() {
        if (_controller.value.position >= _controller.value.duration) {
          _navigateToHome();
        }
      });
    } catch (e) {
      print('❌ Error inicializando video: $e');
      // Si hay error, navegar directamente al home
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isInitialized
          ? SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller!.value.size.width,
                  height: _controller!.value.size.height,
                  child: VideoPlayer(_controller!),
                ),
              ),
            )
          : const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Inicializando...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
