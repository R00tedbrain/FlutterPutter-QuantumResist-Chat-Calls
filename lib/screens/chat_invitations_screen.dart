import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/ephemeral_chat_service.dart';
import '../services/invitation_tracking_service.dart';
import '../models/chat_invitation.dart';
import '../l10n/app_localizations.dart';
import 'dart:async';
import 'multi_room_chat_screen.dart';

class ChatInvitationsScreen extends StatefulWidget {
  final EphemeralChatService? ephemeralChatService;
  final List<ChatInvitation>? pendingInvitations;

  const ChatInvitationsScreen({
    super.key,
    this.ephemeralChatService,
    this.pendingInvitations,
  });

  @override
  State<ChatInvitationsScreen> createState() => _ChatInvitationsScreenState();
}

// NOTA: Tracking global movido a InvitationTrackingService

class _ChatInvitationsScreenState extends State<ChatInvitationsScreen> {
  late EphemeralChatService _chatService;
  late List<ChatInvitation> _invitations;
  bool _isLoading = true;
  String? _error;
  Timer? _cleanupTimer;

  // NUEVO: Preservar callback original para no romper MainScreen
  Function(ChatInvitation)? _originalOnInvitationReceived;

  @override
  void initState() {
    super.initState();

    // Usar el servicio existente o crear uno nuevo
    if (widget.ephemeralChatService != null) {
      _chatService = widget.ephemeralChatService!;
      _invitations = List.from(widget.pendingInvitations ?? []);
      _setupCallbacks();
      setState(() {
        _isLoading = false;
      });
    } else {
      _chatService = EphemeralChatService();
      _invitations = [];
      _initializeService();
    }

    _startCleanupTimer();
  }

  Future<void> _initializeService() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _error = null;
        });
      }

      // Obtener userId del AuthProvider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.id;

      await _chatService.initialize(userId: userId);
      _setupCallbacks();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        setState(() {
          _isLoading = false;
          _error = l10n.errorInitializing(e.toString());
        });
      }
    }
  }

  void _setupCallbacks() {
    // NUEVO: Preservar callback original ANTES de sobrescribir
    _originalOnInvitationReceived = _chatService.onInvitationReceived;
    print(
        '🔐 [INVITATIONS] 💾 Preservando callback original: ${_originalOnInvitationReceived != null ? "EXISTS" : "NULL"}');

    _chatService.onInvitationReceived = (invitation) {
      print(
          '🔐 [INVITATIONS] 📥 Callback combinado ejecutado para: ${invitation.id}');

      // PRIMERO: Ejecutar callback original (MainScreen) si existe
      if (_originalOnInvitationReceived != null) {
        print(
            '🔐 [INVITATIONS] 🔄 Ejecutando callback original (MainScreen)...');
        try {
          _originalOnInvitationReceived!(invitation);
          print('🔐 [INVITATIONS] ✅ Callback original ejecutado exitosamente');
        } catch (e) {
          print('🔐 [INVITATIONS] ❌ Error en callback original: $e');
        }
      } else {
        print('🔐 [INVITATIONS] ⚠️ No hay callback original para ejecutar');
      }

      // SEGUNDO: Ejecutar lógica propia de ChatInvitationsScreen
      if (mounted) {
        print(
            '🔐 [INVITATIONS] 📥 Procesando invitación en screen: ${invitation.id}');

        // NUEVO: Verificar si la invitación ya fue rechazada o ya existe
        if (InvitationTrackingService.instance.isRejected(invitation.id)) {
          print(
              '🔐 [INVITATIONS] ⚠️ Ignorando invitación ya rechazada: ${invitation.id}');
          return;
        }

        // Verificar si ya existe en la lista
        final exists = _invitations.any((inv) => inv.id == invitation.id);
        if (exists) {
          print(
              '🔐 [INVITATIONS] ⚠️ Invitación ya existe en la lista: ${invitation.id}');
          return;
        }

        print(
            '🔐 [INVITATIONS] ➕ Añadiendo invitación a la UI: ${invitation.id}');
        setState(() {
          _invitations.add(invitation);
        });
        print(
            '🔐 [INVITATIONS] ✅ Nueva invitación añadida: ${invitation.id} (Total: ${_invitations.length})');
      }
    };

    _chatService.onError = (error) {
      if (mounted) {
        setState(() {
          _error = error;
        });
      }
    };
  }

  Future<void> _acceptInvitation(ChatInvitation invitation) async {
    final l10n = AppLocalizations.of(context)!;

    try {
      print('🔐 [INVITATIONS] Aceptando invitación: ${invitation.id}');
      print('🔐 [INVITATIONS] NAVEGANDO A MÚLTIPLES SALAS para unificar UI');

      // CRÍTICO: Remover la invitación de la lista ANTES de navegar
      if (mounted) {
        setState(() {
          _invitations.remove(invitation);
        });
        print(
            '🔐 [INVITATIONS] ✅ Invitación removida de la lista: ${invitation.id}');
      }

      // CORREGIDO: SIEMPRE navegar a múltiples salas para unificar la UI
      // Esto garantiza que ambos usuarios (el que envía y el que acepta) tengan la misma interfaz
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MultiRoomChatScreen(
            initialInvitationId: invitation.id,
          ),
        ),
      );

      print('🔐 [INVITATIONS] ✅ Navegación completada');
    } catch (e) {
      print('🔐 [INVITATIONS] ❌ Error aceptando invitación: $e');
      if (mounted) {
        setState(() {
          _error = l10n.errorAcceptingInvitation(e.toString());
        });
      }
    }
  }

  void _rejectInvitation(ChatInvitation invitation) async {
    print(
        '🔐 [INVITATIONS] 🔍 Intentando rechazar invitación: ${invitation.id}');
    print(
        '🔐 [INVITATIONS] 🔍 Lista actual: ${_invitations.map((inv) => inv.id).toList()}');

    // NUEVO: Verificar si ya fue rechazada para evitar bucle infinito
    if (InvitationTrackingService.instance.isRejected(invitation.id)) {
      print(
          '🔐 [INVITATIONS] ⚠️ Invitación ya rechazada previamente: ${invitation.id}');

      // CRÍTICO: Si está rechazada pero sigue en la lista, eliminarla
      if (_invitations.any((inv) => inv.id == invitation.id)) {
        print(
            '🔐 [INVITATIONS] 🧹 Eliminando invitación rechazada de la lista: ${invitation.id}');
        setState(() {
          _invitations.removeWhere((inv) => inv.id == invitation.id);
        });

        // CRÍTICO: También eliminar de la lista del MainScreen (si existe)
        if (widget.pendingInvitations != null) {
          widget.pendingInvitations!
              .removeWhere((inv) => inv.id == invitation.id);
          print(
              '🔐 [INVITATIONS] 🧹 Invitación rechazada eliminada también de MainScreen: ${invitation.id}');
        }
      }
      return;
    }

    try {
      print('🔐 [INVITATIONS] 🚫 Rechazando invitación: ${invitation.id}');

      // NUEVO: Marcar como rechazada ANTES de enviar al servidor
      InvitationTrackingService.instance.markAsRejected(invitation.id);
      print(
          '🔐 [INVITATIONS] 📝 Invitación marcada como rechazada: ${invitation.id}');

      // Eliminar de la UI inmediatamente para prevenir doble rechazo
      if (mounted) {
        setState(() {
          _invitations.remove(invitation);
        });
        print(
            '🔐 [INVITATIONS] 🗑️ Invitación removida de UI: ${invitation.id}');
      }

      // CRÍTICO: También eliminar de la lista del MainScreen (si existe)
      if (widget.pendingInvitations != null && mounted) {
        widget.pendingInvitations!
            .removeWhere((inv) => inv.id == invitation.id);
        print(
            '🔐 [INVITATIONS] 🗑️ Invitación removida también de MainScreen: ${invitation.id}');
      }

      // Enviar rechazo al servidor
      await _chatService.rejectInvitation(invitation.id);
      print(
          '🔐 [INVITATIONS] 📡 Rechazo enviado al servidor: ${invitation.id}');

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invitación rechazada'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      print(
          '🔐 [INVITATIONS] ✅ Invitación rechazada completamente: ${invitation.id}');
    } catch (e) {
      print('🔐 [INVITATIONS] ❌ Error rechazando invitación: $e');

      // Si hay error, remover del tracking para permitir reintento
      InvitationTrackingService.instance.unmarkAsRejected(invitation.id);
      print(
          '🔐 [INVITATIONS] 🔄 Invitación removida del tracking por error: ${invitation.id}');

      // Volver a añadir a la lista si había error
      if (mounted && !_invitations.any((inv) => inv.id == invitation.id)) {
        setState(() {
          _invitations.add(invitation);
        });
        print(
            '🔐 [INVITATIONS] ↩️ Invitación re-añadida por error: ${invitation.id}');
      }

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error rechazando invitación: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _startCleanupTimer() {
    _cleanupTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        _cleanExpiredInvitations();
      } else {
        timer.cancel();
      }
    });
  }

  void _cleanExpiredInvitations() {
    final l10n = AppLocalizations.of(context)!;
    final expiredInvitations =
        _invitations.where((inv) => inv.isExpired).toList();

    if (expiredInvitations.isNotEmpty) {
      print(
          '🔐 [INVITATIONS] 🧹 Limpiando ${expiredInvitations.length} invitaciones expiradas');

      // NUEVO: Log de invitaciones que se van a eliminar
      for (final expiredInv in expiredInvitations) {
        print(
            '🔐 [INVITATIONS] 🗑️ Eliminando localmente: ${expiredInv.id} (expirada)');
      }

      setState(() {
        _invitations.removeWhere((inv) => inv.isExpired);
      });

      print(
          '🔐 [INVITATIONS] ✅ ${expiredInvitations.length} invitaciones eliminadas completamente');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(l10n.expiredInvitationsDeleted(expiredInvitations.length)),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _manualCleanExpired() {
    final l10n = AppLocalizations.of(context)!;
    final expiredInvitations =
        _invitations.where((inv) => inv.isExpired).toList();

    if (expiredInvitations.isNotEmpty) {
      print(
          '🔐 [INVITATIONS] 🧹 Limpieza manual de ${expiredInvitations.length} invitaciones');

      // NUEVO: Log detallado de limpieza manual
      for (final expiredInv in expiredInvitations) {
        print(
            '🔐 [INVITATIONS] 🗑️ Eliminando manualmente: ${expiredInv.id} (expirada)');
      }

      setState(() {
        _invitations.removeWhere((inv) => inv.isExpired);
      });

      print(
          '🔐 [INVITATIONS] ✅ Limpieza manual completada - ${expiredInvitations.length} eliminadas');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(l10n.expiredInvitationsDeleted(expiredInvitations.length)),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.noExpiredInvitationsToClean),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  @override
  void dispose() {
    // NUEVO: Cancelar timer de limpieza
    _cleanupTimer?.cancel();

    // CRÍTICO: Restaurar callback original antes de limpiar
    print('🔐 [INVITATIONS] 🔄 Restaurando callback original en dispose...');
    if (_originalOnInvitationReceived != null) {
      _chatService.onInvitationReceived = _originalOnInvitationReceived;
      print('🔐 [INVITATIONS] ✅ Callback original restaurado (MainScreen)');
    } else {
      _chatService.onInvitationReceived = null;
      print('🔐 [INVITATIONS] ⚠️ No había callback original - limpiando');
    }

    _chatService.onError = null;

    // Solo dispose si creamos el servicio nosotros mismos
    if (widget.ephemeralChatService == null) {
      _chatService.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // NUEVO: Contar invitaciones expiradas
    final expiredCount = _invitations.where((inv) => inv.isExpired).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.chatInvitationsTitle),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[900]
            : Colors.blue,
        foregroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Volver',
        ),
        actions: [
          // NUEVO: Botón para limpiar invitaciones expiradas
          if (expiredCount > 0)
            IconButton(
              icon: Badge(
                label: Text('$expiredCount'),
                child: const Icon(Icons.cleaning_services),
              ),
              onPressed: _manualCleanExpired,
              tooltip: l10n.cleanExpiredInvitations,
            ),
          // NUEVO: Botón de actualizar
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              print(
                  '🔐 [INVITATIONS] 🔄 Actualizando invitaciones manualmente...');

              setState(() {
                _isLoading = true;
                _error = null;
              });

              try {
                // NUEVO: Limpiar invitaciones expiradas automáticamente
                final beforeCount = _invitations.length;
                _invitations.removeWhere((inv) => inv.isExpired);
                final afterCount = _invitations.length;
                final removedCount = beforeCount - afterCount;

                setState(() {
                  _isLoading = false;
                });

                print(
                    '🔐 [INVITATIONS] ✅ Invitaciones actualizadas: ${_invitations.length} activas, $removedCount expiradas eliminadas');

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(removedCount > 0
                        ? l10n.invitationsUpdated(
                            _invitations.length, removedCount)
                        : l10n.invitationsUpdatedActive(_invitations.length)),
                    backgroundColor:
                        removedCount > 0 ? Colors.orange : Colors.green,
                    duration: const Duration(seconds: 2),
                  ),
                );
              } catch (e) {
                print('🔐 [INVITATIONS] ❌ Error actualizando: $e');
                setState(() {
                  _error = l10n.errorUpdatingInvitations(e.toString());
                  _isLoading = false;
                });
              }
            },
            tooltip: l10n.refreshInvitations,
          ),
        ],
      ),
      body: Column(
        children: [
          // Error
          if (_error != null)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.red.withOpacity(0.1),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 16),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () {
                      if (mounted) {
                        setState(() => _error = null);
                      }
                    },
                  ),
                ],
              ),
            ),

          // Loading
          if (_isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          // Lista de invitaciones
          else if (_invitations.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.chat_bubble_outline,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.noInvitations,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.invitationsWillAppearHere,
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _invitations.length,
                itemBuilder: (context, index) {
                  final invitation = _invitations[index];
                  final isExpired = invitation.isExpired;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.blue,
                                child: Text(
                                  invitation.fromUserId
                                      .substring(0, 1)
                                      .toUpperCase(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.chatInvitation,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      l10n.fromUser(invitation.fromUserId),
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isExpired)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    l10n.expired,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    invitation.timeLeftFormatted,
                                    style: const TextStyle(
                                      color: Colors.orange,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: isExpired
                                      ? null
                                      : () => _rejectInvitation(invitation),
                                  child: Text(l10n.reject),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: isExpired
                                      ? null
                                      : () => _acceptInvitation(invitation),
                                  child: Text(l10n.accept),
                                ),
                              ),
                            ],
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
