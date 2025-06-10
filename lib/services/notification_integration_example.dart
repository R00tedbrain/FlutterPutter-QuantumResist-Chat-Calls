import 'package:flutter/material.dart';
import 'notification_manager.dart';

/// Ejemplo de cómo integrar el sistema de notificaciones WebSocket
/// en tu aplicación principal SIN tocar el socket de llamadas existente
class NotificationIntegrationExample {
  /// Inicializar el sistema de notificaciones en main.dart
  static Future<void> initializeInMainApp(String userId, String token,
      GlobalKey<NavigatorState> navigatorKey) async {
    try {
      // Inicializar el gestor de notificaciones
      await NotificationManager.instance
          .initialize(userId, token, navigatorKey);
    } catch (e) {
      // Error inicializando notificaciones
    }
  }

  /// Ejemplo de uso en un Widget
  static Widget buildNotificationStatusWidget() {
    return StreamBuilder<bool>(
      stream: Stream.periodic(const Duration(seconds: 5),
          (_) => NotificationManager.instance.isConnected),
      builder: (context, snapshot) {
        final isConnected = snapshot.data ?? false;

        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isConnected ? Colors.green : Colors.red,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isConnected ? Icons.wifi : Icons.wifi_off,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                isConnected ? 'Notificaciones ON' : 'Notificaciones OFF',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Actualizar estado del usuario
  static void updateUserStatus(String status) {
    NotificationManager.instance.updateUserStatus(status);
  }

  /// Limpiar recursos al cerrar la app
  static Future<void> dispose() async {
    await NotificationManager.instance.dispose();
  }
}

/// Ejemplo de main.dart modificado
class ExampleMainApp extends StatelessWidget {
  // Clave global para navegación desde notificaciones
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  const ExampleMainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterPutter con Notificaciones WebSocket',
      navigatorKey:
          navigatorKey, // IMPORTANTE: Necesario para navegación desde notificaciones
      home: const ExampleHomeScreen(),
    );
  }
}

/// Ejemplo de pantalla principal
class ExampleHomeScreen extends StatefulWidget {
  const ExampleHomeScreen({super.key});

  @override
  _ExampleHomeScreenState createState() => _ExampleHomeScreenState();
}

class _ExampleHomeScreenState extends State<ExampleHomeScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeNotifications();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Inicializar notificaciones después del login
  Future<void> _initializeNotifications() async {
    // Simular datos de usuario logueado
    const userId = 'user123';
    const token = 'jwt_token_here';

    await NotificationIntegrationExample.initializeInMainApp(
        userId, token, ExampleMainApp.navigatorKey);
  }

  /// Manejar cambios de estado de la app
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        NotificationIntegrationExample.updateUserStatus('online');
        break;
      case AppLifecycleState.paused:
        NotificationIntegrationExample.updateUserStatus('away');
        break;
      case AppLifecycleState.detached:
        NotificationIntegrationExample.updateUserStatus('offline');
        NotificationIntegrationExample.dispose();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FlutterPutter'),
        actions: [
          // Indicador de estado de notificaciones
          Padding(
            padding: const EdgeInsets.all(8.0),
            child:
                NotificationIntegrationExample.buildNotificationStatusWidget(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '🔔 Sistema de Notificaciones WebSocket',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              'Las notificaciones de llamadas entrantes funcionarán\nincluso cuando la app esté cerrada',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Simular cambio de estado
                NotificationIntegrationExample.updateUserStatus('busy');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Estado actualizado a: busy')),
                );
              },
              child: const Text('Cambiar Estado a Busy'),
            ),
          ],
        ),
      ),
    );
  }
}
