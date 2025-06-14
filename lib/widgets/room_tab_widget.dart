import 'package:flutter/material.dart';
import '../models/chat_session.dart';
import '../l10n/app_localizations.dart';

/// Widget para mostrar una pestaña individual de sala de chat
/// Incluye indicadores visuales de estado y mensajes no leídos
class RoomTabWidget extends StatefulWidget {
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
  State<RoomTabWidget> createState() => _RoomTabWidgetState();
}

class _RoomTabWidgetState extends State<RoomTabWidget> {
  String? _cachedDisplayName;

  @override
  void initState() {
    super.initState();
    _loadDisplayName();
  }

  Future<void> _loadDisplayName() async {
    final name = await widget.session.getDisplayNameWithNickname();
    if (mounted) {
      setState(() {
        _cachedDisplayName = name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: widget.isActive
            ? Colors.blue.withOpacity(0.1)
            : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.isActive
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
          const SizedBox(width: 6),

          // Nombre del usuario con apodo personalizado
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: const BoxConstraints(maxWidth: 120),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: Text(
                          _cachedDisplayName ?? widget.session.displayName,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: widget.isActive
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color:
                                widget.isActive ? Colors.blue : Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 2),
                      InkWell(
                        onTap: () => _showEditNicknameDialog(context),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.all(1),
                          child: Icon(
                            Icons.edit,
                            size: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.session.currentRoom != null)
                  Text(
                    l10n.participants(
                        widget.session.currentRoom!.participants.length),
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),

          // Badge de mensajes no leídos
          if (widget.session.unreadCount > 0) ...[
            const SizedBox(width: 4),
            _buildUnreadBadge(),
          ],

          // Botón de cerrar mejorado
          if (widget.onClose != null) ...[
            const SizedBox(width: 4),
            InkWell(
              onTap: widget.onClose,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.close,
                  size: 10,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// NUEVO: Mostrar diálogo para editar el apodo de la sala
  void _showEditNicknameDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => _EditNicknameDialog(session: widget.session),
    );

    // Si se guardó exitosamente, recargar el nombre
    if (result == true && mounted) {
      _loadDisplayName();
    }
  }

  /// Construir indicador de estado
  Widget _buildStatusIndicator(BuildContext context) {
    Color color;
    IconData icon;
    String tooltip;

    // MEJORADO: Lógica más clara para el estado
    if (widget.session.currentRoom != null &&
        widget.session.currentRoom!.participants.length > 1) {
      // Sala activa con participantes
      color = Colors.green;
      icon = Icons.circle;
      tooltip = AppLocalizations.of(context)!
          .roomActive(widget.session.currentRoom!.participants.length);
    } else if (widget.session.isConnecting) {
      // Conectando
      color = Colors.orange;
      icon = Icons.sync;
      tooltip = AppLocalizations.of(context)!.connecting;
    } else if (widget.session.error != null) {
      // Error
      color = Colors.red;
      icon = Icons.error;
      tooltip = 'Error: ${widget.session.error}';
    } else if (widget.session.currentRoom != null) {
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
        size: 7,
        color: color,
      ),
    );
  }

  /// Construir badge de mensajes no leídos
  Widget _buildUnreadBadge() {
    final count = widget.session.unreadCount;
    final displayCount = count > 99 ? '99+' : count.toString();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        displayCount,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// NUEVO: Diálogo para editar el apodo de una sala
class _EditNicknameDialog extends StatefulWidget {
  final ChatSession session;

  const _EditNicknameDialog({required this.session});

  @override
  State<_EditNicknameDialog> createState() => _EditNicknameDialogState();
}

class _EditNicknameDialogState extends State<_EditNicknameDialog> {
  late TextEditingController _controller;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _loadCurrentNickname();
  }

  Future<void> _loadCurrentNickname() async {
    final nickname = await widget.session.getDisplayNameWithNickname();
    if (mounted) {
      _controller.text = nickname;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveNickname() async {
    if (_controller.text.trim().isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success =
          await widget.session.setCustomNickname(_controller.text.trim());

      if (mounted) {
        if (success) {
          Navigator.of(context).pop(true); // Indicar que se guardó
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Apodo guardado'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Error guardando apodo'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _clearNickname() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await widget.session.clearCustomNickname();

      if (mounted) {
        if (success) {
          Navigator.of(context).pop(true); // Indicar que se guardó
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🗑️ Apodo eliminado'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Error eliminando apodo'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.edit, color: Colors.blue),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              'Editar nombre de sala',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Nombre personalizado',
                hintText: 'Escribe un apodo para esta sala...',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              maxLength: 30,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 8),
            Text(
              'Este nombre solo se guardará en tu dispositivo',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      actions: [
        Wrap(
          spacing: 8,
          children: [
            TextButton.icon(
              onPressed: _isLoading ? null : _clearNickname,
              icon: const Icon(Icons.delete_outline, size: 16),
              label: const Text('Limpiar'),
            ),
            TextButton(
              onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveNickname,
              child: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Guardar'),
            ),
          ],
        ),
      ],
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
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
              size: 14,
              color: Colors.blue,
            ),
            const SizedBox(width: 4),
            Text(
              l10n.newRoom,
              style: const TextStyle(
                fontSize: 11,
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
