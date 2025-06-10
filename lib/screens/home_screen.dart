import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/call_provider.dart';
import '../services/socket_service.dart';
import '../services/ephemeral_chat_service.dart';
import '../models/user.dart';
import '../models/chat_invitation.dart';
import '../services/api_service.dart';
import 'package:flutterputter/widgets/user_avatar.dart';
import 'dart:convert';
import 'incoming_call_screen.dart';
import 'profile_screen.dart';
import 'search_users_screen.dart';
import 'chat_invitations_screen.dart';
import 'verification_demo_screen.dart';
import 'multi_room_chat_screen.dart';
import 'security_settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late SocketService _socketService;
  late EphemeralChatService _ephemeralChatService;
  final List<ChatInvitation> _pendingInvitations = [];

  @override
  void initState() {
    super.initState();
    _setupSocketService();
    _setupEphemeralChatService();
  }

  void _setupSocketService() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final callProvider = Provider.of<CallProvider>(context, listen: false);

    if (authProvider.token == null) {
      print('⚠️ No hay token disponible para configurar SocketService');
      return;
    }

    // Crear instancia de SocketService
    _socketService = SocketService(token: authProvider.token);

    // Pasar el SocketService al CallProvider
    callProvider.setSocketService(_socketService);

    // Configurar callback para llamadas entrantes
    _socketService.onIncomingCall = _handleIncomingCall;

    // Configurar callback para llamadas terminadas
    _socketService.onCallEnded = _handleCallEnded;

    print('✅ Callbacks de llamada registrados en HomeScreen');
  }

  void _setupEphemeralChatService() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.id;

    if (userId == null) {
      print('⚠️ No hay userId disponible para configurar EphemeralChatService');
      return;
    }

    _ephemeralChatService = EphemeralChatService();

    // Inicializar el servicio
    _ephemeralChatService.initialize(userId: userId).then((_) {
      print('✅ EphemeralChatService inicializado en HomeScreen');

      // Configurar callback para invitaciones recibidas
      _ephemeralChatService.onInvitationReceived = (invitation) {
        setState(() {
          _pendingInvitations.add(invitation);
        });

        // Mostrar notificación
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('📩 Nueva invitación de chat recibida'),
            backgroundColor: Colors.orange,
            action: SnackBarAction(
              label: 'Ver',
              textColor: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatInvitationsScreen(
                      ephemeralChatService: _ephemeralChatService,
                      pendingInvitations: _pendingInvitations,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      };

      _ephemeralChatService.onError = (error) {
        print('❌ Error en EphemeralChatService: $error');
      };
    }).catchError((error) {
      print('❌ Error inicializando EphemeralChatService: $error');
    });
  }

  void _handleIncomingCall(String callId, String from, String token) async {
    print('📞 Llamada entrante recibida en UI: callId=$callId, from=$from');

    // Obtener información del llamante
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (authProvider.token == null) {
        print('⚠️ No hay token disponible para obtener detalles del llamante');
        return;
      }

      // Obtener datos del usuario y parsear la respuesta
      final response = await ApiService.get(
        '/api/users/$from',
        authProvider.token!,
      );

      if (response.statusCode != 200) {
        print('⚠️ Error al obtener datos del llamante: ${response.statusCode}');
        return;
      }

      // Verificar si la respuesta está vacía
      if (response.body.isEmpty) {
        print('⚠️ Respuesta vacía al obtener datos del llamante');
        return;
      }

      try {
        final dynamic userData = jsonDecode(response.body);

        // Verificar que userData sea un Map antes de intentar crear un User
        if (userData == null) {
          print('⚠️ Datos del llamante son null después de decodificar');
          return;
        }

        if (userData is! Map<String, dynamic>) {
          print(
              '⚠️ Datos del llamante no son un objeto Map: ${userData.runtimeType}');
          // Intentar convertir si es un Map genérico
          if (userData is Map) {
            final Map<String, dynamic> safeUserData = {};
            userData.forEach((key, value) {
              if (key is String) {
                safeUserData[key] = value;
              }
            });

            if (safeUserData.isEmpty) {
              print(
                  '⚠️ No se pudieron convertir los datos del llamante a Map<String, dynamic>');
              return;
            }

            final caller = User.fromJson(safeUserData);

            if (!mounted) return;

            // Mostrar pantalla de llamada entrante
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => IncomingCallScreen(
                  callId: callId,
                  caller: caller,
                  isVideo: true,
                ),
              ),
            );
            return;
          }
          return;
        }

        final caller = User.fromJson(userData);

        if (!mounted) return;

        // Mostrar pantalla de llamada entrante
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => IncomingCallScreen(
              callId: callId,
              caller: caller,
              isVideo: true,
            ),
          ),
        );
      } catch (e) {
        print('❌ Error al decodificar o procesar datos del llamante: $e');
      }
    } catch (e) {
      print('❌ Error al procesar llamada entrante: $e');
    }
  }

  void _handleCallEnded(Map<String, dynamic> data) {
    print('🔚 Llamada terminada recibida en HomeScreen: $data');

    // Notificar al CallProvider que la llamada terminó
    final callProvider = Provider.of<CallProvider>(context, listen: false);
    callProvider.endCall();

    // FORZAR navegación de vuelta a HomeScreen desde cualquier pantalla de llamada
    if (mounted) {
      // Verificar si estamos en una pantalla de llamada
      final currentRoute = ModalRoute.of(context);
      if (currentRoute != null) {
        final routeName = currentRoute.settings.name;
        print('🔍 Ruta actual: $routeName');

        // Si estamos en CallScreen o IncomingCallScreen, volver a HomeScreen
        if (routeName == '/call' ||
            currentRoute.settings.arguments is Map &&
                (currentRoute.settings.arguments as Map)
                    .containsKey('callId')) {
          print(
              '🔄 Navegando de vuelta a HomeScreen desde pantalla de llamada');
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else {
          // Si no podemos determinar la ruta, intentar pop hasta llegar a home
          print('🔄 Intentando navegación alternativa a HomeScreen');
          try {
            Navigator.of(context).popUntil((route) => route.isFirst);
          } catch (e) {
            print('⚠️ Error en navegación alternativa: $e');
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('FlutterPutter'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.security, color: Colors.orange),
                if (_pendingInvitations.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${_pendingInvitations.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            tooltip: 'Invitaciones de Chat',
            onPressed: () {
              // CORREGIDO: El escudo SIEMPRE va a invitaciones (no a chats múltiples)
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatInvitationsScreen(
                    ephemeralChatService: _ephemeralChatService,
                    pendingInvitations: _pendingInvitations,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfileScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            tooltip: 'Configuraciones de Seguridad',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SecuritySettingsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await authProvider.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/fondoflutterputter.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Avatar del usuario
                if (user != null)
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: UserAvatar(
                      name: user.nickname,
                      radius: 50,
                    ),
                  ),
                const SizedBox(height: 16),

                // Información de usuario
                if (user != null)
                  Text(
                    'Hola, ${user.nickname}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: Offset(2, 2),
                          blurRadius: 4,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),

                const Text(
                  'Busca usuarios para iniciar una videollamada',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 3,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Botón de búsqueda
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: 200,
                    height: 50,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.search),
                      label: const Text('Buscar Usuarios'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.withOpacity(0.9),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SearchUsersScreen(
                              ephemeralChatService: _ephemeralChatService,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Botón de Demo de Verificación
                _buildMenuButton(
                  context,
                  icon: Icons.security,
                  title: '🔐 Demo Verificación',
                  subtitle: 'Probar verificación de identidad',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VerificationDemoScreen(),
                      ),
                    );
                  },
                ),

                // NUEVO: Botón de Chat Múltiple
                _buildMenuButton(
                  context,
                  icon: Icons.chat_bubble_outline,
                  title: '💬 Chat Efímero',
                  subtitle: 'Múltiples salas simultáneas (máx. 10)',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MultiRoomChatScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ephemeralChatService.dispose();
    super.dispose();
  }

  /// Construir botón de menú con estilo consistente
  Widget _buildMenuButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: SizedBox(
        width: 250,
        height: 60,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple.withOpacity(0.9),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          onPressed: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white70,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
