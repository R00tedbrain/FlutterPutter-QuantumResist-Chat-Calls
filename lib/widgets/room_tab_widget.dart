import 'package:flutter/material.dart';
import '../models/chat_session.dart';
import '../l10n/app_localizations.dart';

/// Widget para mostrar una pestaña individual de sala de chat
/// Incluye indicadores visuales de estado y mensajes no leídos
class RoomTabWidget extends StatelessWidget {
  final ChatSession session;
  final bool isActive;
  final VoidCallback? onClose;

  const RoomTabWidget({
    super.key,
    required this.session,
    this.isActive = false,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.blue.withOpacity(0.1)
            : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? Colors.blue.withOpacity(0.3)
              : Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Indicador de estado
          _buildStatusIndicator(context),
          const SizedBox(width: 8),

          // Nombre del usuario
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.displayName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                    color: isActive ? Colors.blue : Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                if (session.currentRoom != null)
                  Text(
                    l10n.participants(session.currentRoom!.participants.length),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),

          // Badge de mensajes no leídos
          if (session.unreadCount > 0) ...[
            const SizedBox(width: 8),
            _buildUnreadBadge(),
          ],

          // Botón de cerrar mejorado
          if (onClose != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onClose,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Construir indicador de estado de la conexión
  Widget _buildStatusIndicator(BuildContext context) {
    Color color;
    IconData icon;
    String tooltip;

    // MEJORADO: Lógica más clara para el estado
    if (session.currentRoom != null &&
        session.currentRoom!.participants.length > 1) {
      // Sala activa con participantes
      color = Colors.green;
      icon = Icons.circle;
      tooltip = AppLocalizations.of(context)!
          .roomActive(session.currentRoom!.participants.length);
    } else if (session.isConnecting) {
      // Conectando
      color = Colors.orange;
      icon = Icons.sync;
      tooltip = AppLocalizations.of(context)!.connecting;
    } else if (session.error != null) {
      // Error
      color = Colors.red;
      icon = Icons.error;
      tooltip = 'Error: ${session.error}';
    } else if (session.currentRoom != null) {
      // Sala creada pero esperando participantes
      color = Colors.blue;
      icon = Icons.hourglass_empty;
      tooltip = AppLocalizations.of(context)!.waitingForResponse;
    } else {
      // Desconectado o sin sala
      color = Colors.grey;
      icon = Icons.circle_outlined;
      tooltip = AppLocalizations.of(context)!.noConnection;
    }

    return Tooltip(
      message: tooltip,
      child: Icon(
        icon,
        size: 8,
        color: color,
      ),
    );
  }

  /// Construir badge de mensajes no leídos
  Widget _buildUnreadBadge() {
    final count = session.unreadCount;
    final displayCount = count > 99 ? '99+' : count.toString();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        displayCount,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Widget para el botón de agregar nueva sala
class AddRoomTabWidget extends StatelessWidget {
  final VoidCallback onTap;

  const AddRoomTabWidget({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.blue.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.add,
              size: 16,
              color: Colors.blue,
            ),
            const SizedBox(width: 4),
            Text(
              l10n.newRoom,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget para mostrar estadísticas del manager
class ChatStatsWidget extends StatelessWidget {
  final Map<String, dynamic> stats;

  const ChatStatsWidget({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.chatStatisticsTitle,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          _buildStatRow(l10n.activeRooms,
              '${stats['totalSessions']}/${stats['maxSessions']}'),
          _buildStatRow(l10n.totalMessages, '${stats['totalMessages']}'),
          if (stats['totalUnreadMessages'] > 0)
            _buildStatRow(
                l10n.unreadMessages, '${stats['totalUnreadMessages']}',
                color: Colors.red),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color ?? Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}
