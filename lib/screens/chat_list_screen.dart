import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../providers/auth_provider.dart';
import '../services/ephemeral_chat_service.dart';
import '../models/chat_invitation.dart';
import '../l10n/app_localizations.dart';
import 'multi_room_chat_screen.dart';
import 'chat_invitations_screen.dart';
import 'search_users_screen.dart';

class ChatListScreen extends StatefulWidget {
  final EphemeralChatService ephemeralChatService;
  final List<ChatInvitation> pendingInvitations;
  final bool isMobile;
  final bool isTablet;

  const ChatListScreen({
    super.key,
    required this.ephemeralChatService,
    required this.pendingInvitations,
    required this.isMobile,
    required this.isTablet,
  });

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _videoController =
          VideoPlayerController.asset('assets/images/flutterputterchat.mp4');

      await _videoController!.initialize();

      // Configurar para reproducción en bucle infinito
      _videoController!.setLooping(true);

      setState(() {
        _isVideoInitialized = true;
      });

      // Reproducir automáticamente
      _videoController!.play();
    } catch (e) {
      print('❌ Error inicializando video de logo: $e');
      // Si hay error, no mostrar video
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    // 📱 Responsive: Obtener dimensiones adicionales
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = widget.isMobile ? 12.0 : 16.0;
    final listTilePadding = widget.isMobile ? 8.0 : 12.0;

    return Container(
      color: Color(0xFF000000),
      child: Column(
        children: [
          // Lista de chats activos - responsiva
          Expanded(
            child: _buildResponsiveChatsList(listTilePadding),
          ),
        ],
      ),
    );
  }

  // 📱 Lista de chats responsiva
  Widget _buildResponsiveChatsList(double padding) {
    final l10n = AppLocalizations.of(context)!;

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: padding / 2),
      children: [
        // Chat principal que funciona - cambiar nombre y quitar notificaciones
        _buildResponsiveChatTile(
          name: l10n.secureChat,
          lastMessage: l10n.tapToCreateOrJoinEphemeralChats,
          time: l10n.now,
          isOnline: true,
          unreadCount: 0, // Sin notificaciones placeholder
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MultiRoomChatScreen(),
              ),
            );
          },
        ),

        _buildResponsiveChatTile(
          name: l10n.privateVideoCall,
          lastMessage: l10n.callEnded,
          time: '11:45',
          isOnline: false,
          unreadCount: 0,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SearchUsersScreen(
                  ephemeralChatService: widget.ephemeralChatService,
                ),
              ),
            );
          },
        ),

        if (widget.pendingInvitations.isNotEmpty) ...[
          Divider(
            color: Colors.grey.withOpacity(0.3),
            height: widget.isMobile ? 0.5 : 1,
            indent: widget.isMobile ? 65 : 70,
            endIndent: widget.isMobile ? 16 : 20,
          ),
          _buildResponsiveInvitationsTile(),
        ],

        // Logo de FlutterPutter en el espacio vacío
        SizedBox(height: widget.isMobile ? 40 : 60),
        _buildFlutterPutterLogo(),
      ],
    );
  }

  // Widget del logo FlutterPutter con video
  Widget _buildFlutterPutterLogo() {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: widget.isMobile ? 20 : 40,
          vertical: widget.isMobile ? 20 : 30,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo principal - Video en bucle infinito (más grande)
            Container(
              constraints: BoxConstraints(
                maxWidth: widget.isMobile ? 384 : 768,
                maxHeight: widget.isMobile ? 384 : 768,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(widget.isMobile ? 20 : 25),
                child: _isVideoInitialized && _videoController != null
                    ? AspectRatio(
                        aspectRatio: _videoController!.value.aspectRatio,
                        child: VideoPlayer(_videoController!),
                      )
                    : Container(
                        width: widget.isMobile ? 384 : 768,
                        height: widget.isMobile ? 384 : 768,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius:
                              BorderRadius.circular(widget.isMobile ? 20 : 25),
                        ),
                        child: _videoController == null
                            ? Icon(
                                Icons.play_circle_fill,
                                color: Colors.grey[600],
                                size: widget.isMobile ? 72 : 144,
                              )
                            : const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                      ),
              ),
            ),
            SizedBox(height: widget.isMobile ? 12 : 16),
            // Texto opcional debajo del logo
            Text(
              'FlutterPutter',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: widget.isMobile ? 16 : 18,
                fontWeight: FontWeight.w300,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 📱 Chat tile completamente responsivo
  Widget _buildResponsiveChatTile({
    required String name,
    required String lastMessage,
    required String time,
    required bool isOnline,
    required int unreadCount,
    required VoidCallback onTap,
  }) {
    final avatarSize = widget.isMobile ? 45.0 : 50.0;
    final personIconSize = widget.isMobile ? 26.0 : 30.0;
    final onlineIndicatorSize = widget.isMobile ? 12.0 : 14.0;

    return ListTile(
      dense: widget.isMobile,
      contentPadding: EdgeInsets.symmetric(
        horizontal: widget.isMobile ? 12 : 16,
        vertical: widget.isMobile ? 4 : 8,
      ),
      leading: Stack(
        children: [
          Container(
            width: avatarSize,
            height: avatarSize,
            decoration: BoxDecoration(
              color: Colors.grey[700],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.lock, color: Colors.white, size: personIconSize),
          ),
          if (isOnline)
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                width: onlineIndicatorSize,
                height: onlineIndicatorSize,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Colors.black, width: widget.isMobile ? 1.5 : 2),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        name,
        style: TextStyle(
          color: Colors.white,
          fontSize: widget.isMobile ? 15 : 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        lastMessage,
        style: TextStyle(
          color: Colors.grey,
          fontSize: widget.isMobile ? 12 : 14,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      trailing: _buildResponsiveTrailing(time, unreadCount),
      onTap: onTap,
    );
  }

  // 📱 Trailing de chat responsivo
  Widget _buildResponsiveTrailing(String time, int unreadCount) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          time,
          style: TextStyle(
            color: unreadCount > 0 ? Color(0xFF007AFF) : Colors.grey,
            fontSize: widget.isMobile ? 11 : 12,
          ),
        ),
        if (unreadCount > 0) ...[
          SizedBox(height: widget.isMobile ? 2 : 4),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: widget.isMobile ? 5 : 6,
              vertical: widget.isMobile ? 1 : 2,
            ),
            decoration: BoxDecoration(
              color: Color(0xFF007AFF),
              borderRadius: BorderRadius.circular(widget.isMobile ? 8 : 10),
            ),
            constraints: BoxConstraints(
              minWidth: widget.isMobile ? 16 : 18,
              minHeight: widget.isMobile ? 16 : 18,
            ),
            child: Text(
              unreadCount.toString(),
              style: TextStyle(
                color: Colors.white,
                fontSize: widget.isMobile ? 10 : 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    );
  }

  // 📱 Invitaciones tile responsivo
  Widget _buildResponsiveInvitationsTile() {
    final l10n = AppLocalizations.of(context)!;
    final avatarSize = widget.isMobile ? 45.0 : 50.0;
    final iconSize = widget.isMobile ? 20.0 : 24.0;

    return ListTile(
      dense: widget.isMobile,
      contentPadding: EdgeInsets.symmetric(
        horizontal: widget.isMobile ? 12 : 16,
        vertical: widget.isMobile ? 4 : 8,
      ),
      leading: Container(
        width: avatarSize,
        height: avatarSize,
        decoration: BoxDecoration(
          color: Colors.orange,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.mail, color: Colors.white, size: iconSize),
      ),
      title: Text(
        l10n.pendingInvitations,
        style: TextStyle(
          color: Colors.white,
          fontSize: widget.isMobile ? 15 : 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        l10n.chatInvitationsCount(widget.pendingInvitations.length),
        style: TextStyle(
          color: Colors.grey,
          fontSize: widget.isMobile ? 12 : 14,
        ),
      ),
      trailing: Container(
        padding: EdgeInsets.symmetric(
          horizontal: widget.isMobile ? 6 : 8,
          vertical: widget.isMobile ? 2 : 4,
        ),
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(widget.isMobile ? 10 : 12),
        ),
        child: Text(
          widget.pendingInvitations.length.toString(),
          style: TextStyle(
            color: Colors.white,
            fontSize: widget.isMobile ? 10 : 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatInvitationsScreen(
              ephemeralChatService: widget.ephemeralChatService,
              pendingInvitations: widget.pendingInvitations,
            ),
          ),
        );
      },
    );
  }
}
