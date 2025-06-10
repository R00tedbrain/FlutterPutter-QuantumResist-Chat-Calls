import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutterputter/models/user.dart';
import 'package:flutterputter/providers/auth_provider.dart';
import 'package:flutterputter/providers/call_provider.dart';
import 'package:flutterputter/screens/call_screen.dart';
import 'package:flutterputter/theme/app_theme.dart';
import 'package:flutterputter/widgets/user_avatar.dart';
import 'package:flutterputter/services/ephemeral_chat_service.dart';
import 'package:flutterputter/l10n/app_localizations.dart';
import 'ephemeral_chat_screen_multimedia.dart';

class SearchUsersScreen extends StatefulWidget {
  final EphemeralChatService? ephemeralChatService;

  const SearchUsersScreen({
    super.key,
    this.ephemeralChatService,
  });

  @override
  State<SearchUsersScreen> createState() => _SearchUsersScreenState();
}

class _SearchUsersScreenState extends State<SearchUsersScreen> {
  final _searchController = TextEditingController();
  List<User> _searchResults = [];
  bool _isSearching = false;
  String? _error;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Buscar usuarios
  Future<void> _searchUsers() async {
    final callProvider = Provider.of<CallProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (_searchController.text.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _error = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _error = null;
    });

    try {
      final results = await callProvider.searchUsers(
        _searchController.text.trim(),
        authProvider.token!,
      );

      setState(() {
        _searchResults = results;
        _isSearching = false;
        if (results.isEmpty) {
          final l10n = AppLocalizations.of(context)!;
          _error = l10n.noUsersFound;
        }
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
        final l10n = AppLocalizations.of(context)!;
        _error = l10n.errorSearchingUsers;
      });
    }
  }

  // Iniciar chat efímero con un usuario
  Future<void> _initiateEphemeralChat(User user) async {
    final l10n = AppLocalizations.of(context)!;

    print('🔐 [SEARCH] === INICIANDO CHAT EFÍMERO ===');
    print('🔐 [SEARCH] Usuario objetivo: ${user.nickname} (${user.id})');
    print(
        '🔐 [SEARCH] Servicio disponible: ${widget.ephemeralChatService != null}');

    // Mostrar diálogo de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(l10n.sendingInvitation),
          ],
        ),
      ),
    );

    try {
      print('🔐 [SEARCH] Enviando invitación usando servicio existente...');
      await widget.ephemeralChatService!.createChatInvitation(user.id);
      print('🔐 [SEARCH] ✅ Invitación enviada exitosamente');

      // Cerrar diálogo de carga
      if (mounted) {
        Navigator.pop(context);
        print('🔐 [SEARCH] ✅ Diálogo de carga cerrado');
      }

      // Mostrar pantalla de espera (el callback se configurará allí)
      if (mounted) {
        print('🔐 [SEARCH] Navegando a pantalla de espera...');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => _WaitingForResponseScreen(
              targetUser: user,
              ephemeralChatService: widget.ephemeralChatService!,
            ),
          ),
        );
        print('🔐 [SEARCH] ✅ Navegación a pantalla de espera iniciada');
      }
    } catch (e) {
      print('❌ [SEARCH] Error enviando invitación: $e');

      // Cerrar diálogo de carga si está abierto
      if (mounted) {
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error enviando invitación: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Iniciar llamada con un usuario
  Future<void> _initiateCall(User user, bool isVideo) async {
    final callProvider = Provider.of<CallProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

    // Mostrar diálogo de confirmación
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isVideo ? l10n.startVideoCall : l10n.startAudioCall),
        content: Text(isVideo
            ? l10n.confirmVideoCall(user.nickname)
            : l10n.confirmAudioCall(user.nickname)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.calls),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    // Mostrar diálogo de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(isVideo ? l10n.initiatingVideoCall : l10n.initiatingAudioCall),
          ],
        ),
      ),
    );

    // Iniciar llamada
    try {
      final success = await callProvider.initiateCall(
        user.id,
        authProvider.token!,
        isVideo: isVideo,
      );

      if (success && mounted) {
        // Cerrar diálogo de carga
        Navigator.pop(context);

        // Ir a pantalla de llamada
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CallScreen(remoteUser: user, isVideo: isVideo),
          ),
        );
      } else if (mounted) {
        // Cerrar diálogo de carga
        Navigator.pop(context);

        // Mostrar error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorInitiatingCall),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Cerrar diálogo de carga
        Navigator.pop(context);

        // Mostrar error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al iniciar la llamada'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.searchUsers),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Volver',
        ),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[900]
            : Colors.blue,
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      body: Column(
        children: [
          // Barra de búsqueda más compacta
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: l10n.searchByNickname,
                      hintStyle: const TextStyle(fontSize: 14),
                      prefixIcon: const Icon(Icons.search, size: 18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                    onSubmitted: (_) => _searchUsers(),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 40,
                  height: 40,
                  child: IconButton(
                    icon: const Icon(Icons.search, size: 20),
                    onPressed: _searchUsers,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),

          // Estados de carga/error más compactos
          if (_isSearching)
            Container(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Text(l10n.searching, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),

          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
            ),

          // Resultados con scroll optimizado
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final user = _searchResults[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 2, horizontal: 12),
                  child: ListTile(
                    dense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    leading: UserAvatar(name: user.nickname),
                    title: Text(
                      user.nickname,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      user.email,
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Botón de chat efímero
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: IconButton(
                            icon: const Icon(Icons.security, size: 16),
                            color: Colors.orange,
                            tooltip: l10n.ephemeralChatTooltip,
                            onPressed: () => _initiateEphemeralChat(user),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                        // Botón de llamada de audio
                        Consumer<CallProvider>(
                          builder: (context, callProvider, _) => SizedBox(
                            width: 32,
                            height: 32,
                            child: IconButton(
                              icon: const Icon(Icons.call, size: 16),
                              color: Colors.green,
                              tooltip: l10n.audioCallTooltip,
                              onPressed: callProvider.isProcessingCall
                                  ? null
                                  : () => _initiateCall(user, false),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        // Botón de videollamada
                        Consumer<CallProvider>(
                          builder: (context, callProvider, _) => SizedBox(
                            width: 32,
                            height: 32,
                            child: IconButton(
                              icon: const Icon(Icons.video_call, size: 16),
                              color: AppTheme.primaryColor,
                              tooltip: l10n.videoCallTooltip,
                              onPressed: callProvider.isProcessingCall
                                  ? null
                                  : () => _initiateCall(user, true),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Pantalla de espera para respuesta de invitación
class _WaitingForResponseScreen extends StatefulWidget {
  final User targetUser;
  final EphemeralChatService ephemeralChatService;

  const _WaitingForResponseScreen({
    required this.targetUser,
    required this.ephemeralChatService,
  });

  @override
  State<_WaitingForResponseScreen> createState() =>
      _WaitingForResponseScreenState();
}

class _WaitingForResponseScreenState extends State<_WaitingForResponseScreen> {
  @override
  void initState() {
    super.initState();

    print('🔐 [WAITING] Configurando callbacks en pantalla de espera...');

    // Configurar callbacks
    widget.ephemeralChatService.onRoomCreated = (room) {
      print('🔐 [WAITING] ¡¡¡CALLBACK onRoomCreated EJECUTADO!!!');
      print('🔐 [WAITING] Room ID: ${room.id}');
      print('🔐 [WAITING] Participantes: ${room.participants.length}');
      print('🔐 [WAITING] Mounted: $mounted');

      if (mounted) {
        print('🔐 [WAITING] Navegando a EphemeralChatScreenMultimedia...');
        // Navegar a la pantalla de chat multimedia
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => EphemeralChatScreenMultimedia(
              ephemeralChatService: widget.ephemeralChatService,
            ),
          ),
        );
        print('🔐 [WAITING] ✅ Navegación iniciada');
      } else {
        print('🔐 [WAITING] ❌ Widget no está mounted, no se puede navegar');
      }
    };

    widget.ephemeralChatService.onError = (error) {
      print('🔐 [WAITING] ¡¡¡CALLBACK onError EJECUTADO!!!');
      print('🔐 [WAITING] Error: $error');
      print('🔐 [WAITING] Mounted: $mounted');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $error'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    };

    print('🔐 [WAITING] ✅ Callbacks configurados en pantalla de espera');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.waitingForResponse),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              Text(
                l10n.invitationSentTo,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                widget.targetUser.nickname,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.waitingForAcceptance,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                ),
                child: Text(l10n.cancel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
