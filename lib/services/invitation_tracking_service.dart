/// Servicio global para tracking de invitaciones rechazadas
/// Evita bucles infinitos y duplicación de invitaciones
class InvitationTrackingService {
  static final InvitationTrackingService _instance =
      InvitationTrackingService._internal();
  static InvitationTrackingService get instance => _instance;
  InvitationTrackingService._internal();

  // Tracking global de invitaciones rechazadas
  final Set<String> _rejectedInvitations = <String>{};
  // NUEVO: Tracking de tiempo de rechazo para limpieza automática
  final Map<String, DateTime> _rejectionTime = <String, DateTime>{};

  /// Verificar si una invitación ya fue rechazada
  bool isRejected(String invitationId) {
    // NUEVO: Limpiar invitaciones rechazadas después de 5 minutos
    _cleanOldRejections();

    final result = _rejectedInvitations.contains(invitationId);
    if (result) {
      print('🔐 [TRACKING] ⚠️ Invitación ya rechazada: $invitationId');
      final rejectedTime = _rejectionTime[invitationId];
      if (rejectedTime != null) {
        final elapsed = DateTime.now().difference(rejectedTime);
        print('🔐 [TRACKING] ⏰ Rechazada hace: ${elapsed.inMinutes} minutos');
      }
    }
    return result;
  }

  /// Marcar una invitación como rechazada
  void markAsRejected(String invitationId) {
    _rejectedInvitations.add(invitationId);
    _rejectionTime[invitationId] = DateTime.now();
    print('🔐 [TRACKING] 📝 Invitación marcada como rechazada: $invitationId');
    print('🔐 [TRACKING] 📊 Total rechazadas: ${_rejectedInvitations.length}');
  }

  /// Desmarcar una invitación como rechazada (para reintentos en caso de error)
  void unmarkAsRejected(String invitationId) {
    final removed = _rejectedInvitations.remove(invitationId);
    _rejectionTime.remove(invitationId);
    if (removed) {
      print('🔐 [TRACKING] 🔄 Invitación removida del tracking: $invitationId');
    }
  }

  /// NUEVO: Limpiar invitaciones rechazadas después de 5 minutos
  void _cleanOldRejections() {
    final now = DateTime.now();
    final toRemove = <String>[];

    for (final entry in _rejectionTime.entries) {
      final elapsed = now.difference(entry.value);
      if (elapsed.inMinutes >= 5) {
        toRemove.add(entry.key);
      }
    }

    if (toRemove.isNotEmpty) {
      print('🔐 [TRACKING] 🧹 Limpiando ${toRemove.length} rechazos antiguos');
      for (final id in toRemove) {
        _rejectedInvitations.remove(id);
        _rejectionTime.remove(id);
        print('🔐 [TRACKING] 🗑️ Limpiado rechazo antiguo: $id');
      }
    }
  }

  /// Limpiar todas las invitaciones rechazadas
  void clearAll() {
    final count = _rejectedInvitations.length;
    _rejectedInvitations.clear();
    _rejectionTime.clear();
    print('🔐 [TRACKING] 🧹 Tracking limpiado: $count invitaciones removidas');
  }

  /// NUEVO: Limpiar invitaciones rechazadas por un usuario específico
  void clearRejectedByUser(String userId) {
    final toRemove = <String>[];

    // Buscar invitaciones que contengan el userId
    for (final invitationId in _rejectedInvitations) {
      if (invitationId.contains(userId)) {
        toRemove.add(invitationId);
      }
    }

    if (toRemove.isNotEmpty) {
      print(
          '🔐 [TRACKING] 🧹 Limpiando ${toRemove.length} rechazos del usuario: $userId');
      for (final id in toRemove) {
        _rejectedInvitations.remove(id);
        _rejectionTime.remove(id);
        print('🔐 [TRACKING] 🗑️ Limpiado rechazo del usuario: $id');
      }
    }
  }

  /// Obtener estadísticas de tracking
  Map<String, dynamic> getStats() {
    _cleanOldRejections(); // Limpiar antes de dar estadísticas
    return {
      'rejectedCount': _rejectedInvitations.length,
      'rejectedIds': _rejectedInvitations.toList(),
      'rejectionTimes': _rejectionTime
          .map((key, value) => MapEntry(key, value.toIso8601String())),
    };
  }

  /// Verificar si una invitación debe ser procesada
  /// Combina verificación de rechazo con otras validaciones
  bool shouldProcessInvitation(String invitationId) {
    if (isRejected(invitationId)) {
      print(
          '🔐 [TRACKING] 🚫 Invitación ignorada (ya rechazada): $invitationId');
      return false;
    }

    print('🔐 [TRACKING] ✅ Invitación puede ser procesada: $invitationId');
    return true;
  }
}
