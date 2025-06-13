import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_invitation.dart';

/// Servicio para persistir invitaciones de chat
/// Permite que las invitaciones sobrevivan al bloqueo/desbloqueo de la app
class InvitationPersistenceService {
  static const String _invitationsKey = 'pending_invitations';
  static const String _rejectedInvitationsKey = 'rejected_invitations';

  static InvitationPersistenceService? _instance;
  static InvitationPersistenceService get instance =>
      _instance ??= InvitationPersistenceService._internal();

  InvitationPersistenceService._internal();

  /// Guardar invitaciones pendientes
  Future<void> savePendingInvitations(List<ChatInvitation> invitations) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Filtrar invitaciones no expiradas
      final validInvitations =
          invitations.where((inv) => !inv.isExpired).toList();

      // Convertir a JSON
      final jsonList = validInvitations.map((inv) => inv.toJson()).toList();
      final jsonString = jsonEncode(jsonList);

      await prefs.setString(_invitationsKey, jsonString);
      print(
          '🔒 [INVITATION-PERSIST] Guardadas ${validInvitations.length} invitaciones');
    } catch (e) {
      print('❌ [INVITATION-PERSIST] Error guardando invitaciones: $e');
    }
  }

  /// Cargar invitaciones pendientes
  Future<List<ChatInvitation>> loadPendingInvitations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_invitationsKey);

      if (jsonString == null || jsonString.isEmpty) {
        print('🔒 [INVITATION-PERSIST] No hay invitaciones guardadas');
        return [];
      }

      final jsonList = jsonDecode(jsonString) as List;
      final invitations = jsonList
          .map((json) => ChatInvitation.fromJson(json))
          .where((inv) => !inv.isExpired) // Filtrar expiradas al cargar
          .toList();

      print(
          '🔒 [INVITATION-PERSIST] Cargadas ${invitations.length} invitaciones válidas');
      return invitations;
    } catch (e) {
      print('❌ [INVITATION-PERSIST] Error cargando invitaciones: $e');
      return [];
    }
  }

  /// Agregar nueva invitación
  Future<void> addInvitation(ChatInvitation invitation) async {
    try {
      final currentInvitations = await loadPendingInvitations();

      // Verificar si ya existe
      final exists = currentInvitations.any((inv) => inv.id == invitation.id);
      if (exists) {
        print('🔒 [INVITATION-PERSIST] Invitación ya existe: ${invitation.id}');
        return;
      }

      currentInvitations.add(invitation);
      await savePendingInvitations(currentInvitations);
      print('🔒 [INVITATION-PERSIST] Invitación agregada: ${invitation.id}');
    } catch (e) {
      print('❌ [INVITATION-PERSIST] Error agregando invitación: $e');
    }
  }

  /// Remover invitación
  Future<void> removeInvitation(String invitationId) async {
    try {
      final currentInvitations = await loadPendingInvitations();
      final initialCount = currentInvitations.length;

      currentInvitations.removeWhere((inv) => inv.id == invitationId);

      if (currentInvitations.length < initialCount) {
        await savePendingInvitations(currentInvitations);
        print('🔒 [INVITATION-PERSIST] Invitación removida: $invitationId');
      }
    } catch (e) {
      print('❌ [INVITATION-PERSIST] Error removiendo invitación: $e');
    }
  }

  /// Limpiar invitaciones expiradas
  Future<void> cleanExpiredInvitations() async {
    try {
      final currentInvitations = await loadPendingInvitations();
      final initialCount = currentInvitations.length;

      final validInvitations =
          currentInvitations.where((inv) => !inv.isExpired).toList();

      if (validInvitations.length < initialCount) {
        await savePendingInvitations(validInvitations);
        final removedCount = initialCount - validInvitations.length;
        print(
            '🔒 [INVITATION-PERSIST] Limpiadas $removedCount invitaciones expiradas');
      }
    } catch (e) {
      print('❌ [INVITATION-PERSIST] Error limpiando invitaciones: $e');
    }
  }

  /// Guardar invitaciones rechazadas
  Future<void> saveRejectedInvitation(String invitationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rejectedList = prefs.getStringList(_rejectedInvitationsKey) ?? [];

      if (!rejectedList.contains(invitationId)) {
        rejectedList.add(invitationId);
        await prefs.setStringList(_rejectedInvitationsKey, rejectedList);
        print(
            '🔒 [INVITATION-PERSIST] Invitación marcada como rechazada: $invitationId');
      }
    } catch (e) {
      print('❌ [INVITATION-PERSIST] Error guardando rechazo: $e');
    }
  }

  /// Verificar si una invitación fue rechazada
  Future<bool> isInvitationRejected(String invitationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rejectedList = prefs.getStringList(_rejectedInvitationsKey) ?? [];
      return rejectedList.contains(invitationId);
    } catch (e) {
      print('❌ [INVITATION-PERSIST] Error verificando rechazo: $e');
      return false;
    }
  }

  /// Limpiar todas las invitaciones (logout)
  Future<void> clearAllInvitations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_invitationsKey);
      await prefs.remove(_rejectedInvitationsKey);
      print('🔒 [INVITATION-PERSIST] Todas las invitaciones limpiadas');
    } catch (e) {
      print('❌ [INVITATION-PERSIST] Error limpiando invitaciones: $e');
    }
  }
}
