import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutterputter/models/user.dart';
import 'package:flutterputter/providers/auth_provider.dart';
import 'package:flutterputter/providers/call_provider.dart';
import 'package:flutterputter/screens/call_screen.dart';
import 'package:flutterputter/theme/app_theme.dart';
import 'package:flutterputter/widgets/user_avatar.dart';
import 'package:flutterputter/services/socket_service.dart';

class IncomingCallScreen extends StatefulWidget {
  final String callId;
  final User caller;
  final bool isVideo;

  const IncomingCallScreen({
    super.key,
    required this.callId,
    required this.caller,
    this.isVideo = true,
  });

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen> {
  @override
  void initState() {
    super.initState();
    // Asegurar que el CallProvider tenga el SocketService correcto
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final callProvider = Provider.of<CallProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Obtener la instancia singleton de SocketService
      final socketService = SocketService.getInstance();
      if (socketService != null) {
        callProvider.setSocketService(socketService);
      } else {}
    });
  }

  // Aceptar llamada
  Future<void> _acceptCall() async {
    final callProvider = Provider.of<CallProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // IMPORTANTE: Establecer el SocketService ANTES de aceptar la llamada
    final socketService = SocketService.getInstance();
    if (socketService != null) {
      callProvider.setSocketService(socketService);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error interno: servicio de conexión no disponible'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pop(context);
      return;
    }

    // Mostrar diálogo de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Conectando...'),
          ],
        ),
      ),
    );

    // Aceptar llamada
    try {
      final success = await callProvider.acceptCall(
        widget.callId,
        authProvider.token!,
        isVideo: widget.isVideo,
      );

      if (success && mounted) {
        // Cerrar diálogo de carga
        Navigator.pop(context);

        // Ir a pantalla de llamada
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => CallScreen(
              remoteUser: widget.caller,
              isVideo: widget.isVideo,
            ),
          ),
        );
      } else if (mounted) {
        // Cerrar diálogo de carga
        Navigator.pop(context);

        // Mostrar error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(callProvider.error ?? 'Error al aceptar la llamada'),
            backgroundColor: Colors.red,
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        // Cerrar diálogo de carga
        Navigator.pop(context);

        // Mostrar error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al aceptar la llamada: $e'),
            backgroundColor: Colors.red,
          ),
        );

        Navigator.pop(context);
      }
    }
  }

  // Rechazar llamada
  Future<void> _rejectCall() async {
    final callProvider = Provider.of<CallProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      await callProvider.rejectCall(
        widget.callId,
        authProvider.token!,
      );
    } finally {
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),

            // Estado de llamada
            Text(
              widget.isVideo ? 'Videollamada entrante' : 'Llamada entrante',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),

            // Avatar del llamante
            UserAvatar(
              name: widget.caller.nickname,
              radius: 70,
            ),
            const SizedBox(height: 20),

            // Nombre del llamante
            Text(
              widget.caller.nickname,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Información adicional
            Text(
              widget.caller.email,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),

            const Spacer(),

            // Botones de acción
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Rechazar
                CircleAvatar(
                  backgroundColor: AppTheme.callRejectColor,
                  radius: 40,
                  child: IconButton(
                    icon: const Icon(
                      Icons.call_end,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: _rejectCall,
                  ),
                ),

                // Aceptar
                CircleAvatar(
                  backgroundColor: AppTheme.callAcceptColor,
                  radius: 40,
                  child: IconButton(
                    icon: Icon(
                      widget.isVideo ? Icons.videocam : Icons.call,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: _acceptCall,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
