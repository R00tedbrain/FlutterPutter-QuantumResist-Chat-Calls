import 'package:flutter/material.dart';
import 'dart:async';

/// Widget para mostrar contador de destrucción manual de sala DENTRO del chat
class DestructionCountdownWidget extends StatefulWidget {
  final VoidCallback? onDestroy;
  final VoidCallback? onCancel;
  final bool showCancelButton;
  final bool isInChat; // NUEVO: Para mostrar en el chat vs overlay
  final int? initialCountdown; // NUEVO: Contador inicial

  const DestructionCountdownWidget({
    super.key,
    this.onDestroy,
    this.onCancel,
    this.showCancelButton = true,
    this.isInChat = false, // NUEVO: Por defecto es overlay
    this.initialCountdown, // NUEVO: Contador desde el mensaje
  });

  @override
  State<DestructionCountdownWidget> createState() =>
      _DestructionCountdownWidgetState();
}

class _DestructionCountdownWidgetState extends State<DestructionCountdownWidget>
    with TickerProviderStateMixin {
  late int _countdown;
  Timer? _timer;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // NUEVO: Usar countdown inicial si se proporciona
    _countdown = widget.initialCountdown ?? 10;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    // NUEVO: Solo iniciar timer si NO estamos en el chat (modo overlay)
    if (!widget.isInChat) {
      _startCountdown();
    }
  }

  @override
  void didUpdateWidget(DestructionCountdownWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // NUEVO: Actualizar countdown si cambia el valor inicial
    if (widget.initialCountdown != null &&
        widget.initialCountdown != oldWidget.initialCountdown) {
      setState(() {
        _countdown = widget.initialCountdown!;
      });

      // Trigger animation
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
    }
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _countdown--;
      });

      // Animación en cada segundo
      _animationController.forward().then((_) {
        _animationController.reverse();
      });

      if (_countdown <= 0) {
        timer.cancel();
        widget.onDestroy?.call();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // NUEVO: Diseño para mostrar dentro del chat
    if (widget.isInChat) {
      return _buildChatMessage();
    }

    // Diseño original para overlay
    return _buildOverlay();
  }

  /// NUEVO: Widget para mostrar como mensaje en el chat
  Widget _buildChatMessage() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.withOpacity(0.8), Colors.orange.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  '⚠️ DESTRUYENDO SALA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // NUEVO: Contador circular compacto
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.red,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$_countdown',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'La sala será destruida en $_countdown segundos para ambos participantes',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
          if (widget.showCancelButton && widget.onCancel != null) ...[
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                _timer?.cancel();
                widget.onCancel!();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.red,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                minimumSize: const Size(0, 32),
              ),
              child: const Text(
                'CANCELAR',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Diseño original para overlay (mantenido para compatibilidad)
  Widget _buildOverlay() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.9),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.warning,
            color: Colors.white,
            size: 40,
          ),
          const SizedBox(height: 10),
          const Text(
            '⚠️ DESTRUYENDO SALA',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.red,
                      width: 4,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$_countdown',
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 15),
          Text(
            'La sala será destruida en $_countdown segundos',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          if (widget.showCancelButton && widget.onCancel != null)
            ElevatedButton(
              onPressed: () {
                _timer?.cancel();
                widget.onCancel!();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.red,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              child: const Text(
                'CANCELAR',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
