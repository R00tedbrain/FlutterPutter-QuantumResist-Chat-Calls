import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../models/active_session.dart';
import '../services/session_management_service.dart';

class ActiveSessionsScreen extends StatefulWidget {
  const ActiveSessionsScreen({super.key});

  @override
  State<ActiveSessionsScreen> createState() => _ActiveSessionsScreenState();
}

class _ActiveSessionsScreenState extends State<ActiveSessionsScreen> {
  final SessionManagementService _sessionService = SessionManagementService();
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasAuthError = false;

  // ✅ NUEVO: Estado específico por sesión y debouncing
  final Set<String> _sessionsBeingTerminated = <String>{};
  Timer? _debounceTimer;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadActiveSessions();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadActiveSessions() async {
    // ✅ NUEVO: Evitar múltiples cargas simultáneas
    if (_isRefreshing) {
      print('🔄 [UI] Ya hay una carga en progreso, saltando...');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _hasAuthError = false;
      _isRefreshing = true;
    });

    try {
      // ✅ NUEVO: Timeout para evitar congelamientos
      await _sessionService
          .refreshActiveSessions()
          .timeout(const Duration(seconds: 10));

      if (mounted) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    } catch (e) {
      print('🔄 [UI] Error cargando sesiones: $e');

      if (mounted) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;

          if (e.toString().contains('necesita autenticación') ||
              e.toString().contains('No autorizado')) {
            _hasAuthError = true;
            _errorMessage =
                'Necesitas iniciar sesión para ver las sesiones activas';
          } else if (e.toString().contains('TimeoutException')) {
            _errorMessage = 'Tiempo de espera agotado. Verifica tu conexión.';
          } else {
            _errorMessage = 'Error de conexión. Usando datos locales.';
          }
        });
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('❌ $message'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ $message'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showWarning(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('⚠️ $message'),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _terminateSession(ActiveSession session) async {
    // ✅ NUEVO: Evitar múltiples terminaciones simultáneas
    if (_sessionsBeingTerminated.contains(session.sessionId)) {
      print(
          '🔄 [UI] Sesión ya está siendo cerrada: ${session.sessionId.substring(0, 8)}...');
      return;
    }

    // Confirmar acción
    final confirmed = await _showConfirmDialog(
      'Cerrar sesión',
      '¿Estás seguro de que quieres cerrar la sesión en ${session.deviceInfo.displayName}?',
      'Cerrar',
      Colors.red,
    );

    if (!confirmed) return;

    // ✅ NUEVO: Debouncing para evitar múltiples clicks
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      await _performSessionTermination(session);
    });
  }

  Future<void> _performSessionTermination(ActiveSession session) async {
    // Mostrar loading específico para esta sesión
    setState(() {
      _sessionsBeingTerminated.add(session.sessionId);
    });

    try {
      // ✅ NUEVO: Timeout para evitar congelamientos
      final success = await _sessionService
          .terminateSession(session.sessionId)
          .timeout(const Duration(seconds: 5));

      if (mounted) {
        if (success) {
          _showSuccess('Sesión cerrada exitosamente');
        } else {
          _showWarning(
              'Sesión cerrada localmente. Puede persistir en el servidor.');
        }
      }
    } catch (e) {
      print('🔄 [UI] Error cerrando sesión: $e');

      if (mounted) {
        if (e.toString().contains('TimeoutException')) {
          _showError('Tiempo agotado. La sesión se cerró localmente.');
        } else {
          _showError('Error de conexión. Sesión cerrada localmente.');
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _sessionsBeingTerminated.remove(session.sessionId);
        });

        // ✅ NUEVO: Refrescar con delay para evitar sobrecarga
        Timer(const Duration(milliseconds: 500), () {
          if (mounted && !_isRefreshing) {
            _loadActiveSessions();
          }
        });
      }
    }
  }

  Future<void> _terminateAllOtherSessions() async {
    final otherSessions = _sessionService.activeSessions
        .where((s) => !s.isCurrentSession)
        .toList();

    if (otherSessions.isEmpty) {
      _showError('No hay otras sesiones activas');
      return;
    }

    // Confirmar acción
    final confirmed = await _showConfirmDialog(
      'Cerrar todas las sesiones',
      '¿Estás seguro de que quieres cerrar todas las otras ${otherSessions.length} sesiones activas?',
      'Cerrar todas',
      Colors.red,
    );

    if (!confirmed) return;

    try {
      final success = await _sessionService.terminateAllOtherSessions();
      if (success) {
        _showSuccess('${otherSessions.length} sesiones cerradas exitosamente');
        await _loadActiveSessions(); // Refrescar lista
      } else {
        _showError('Error cerrando las sesiones');
      }
    } catch (e) {
      _showError('Error: $e');
    }
  }

  Future<void> _linkNewDevice() async {
    // ✅ BLOQUEADO: Solo 1 sesión por usuario
    _showError(
        '🔒 Solo se permite 1 sesión activa por usuario para máxima seguridad');
    return;

    // Código anterior comentado
    /*
    try {
      // Verificar autenticación antes de vincular
      if (_sessionService.authToken == null) {
        _showError('Debes iniciar sesión primero');
        return;
      }

      // Navegar a pantalla de QR linking
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const QRLinkingScreen(),
        ),
      );

      if (result == true) {
        _showSuccess('Dispositivo vinculado exitosamente');
        await _loadActiveSessions();
      }
    } catch (e) {
      _showError('Error vinculando dispositivo: $e');
    }
    */
  }

  Future<bool> _showConfirmDialog(
    String title,
    String message,
    String confirmText,
    Color confirmColor,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: confirmColor),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Widget _buildSessionCard(ActiveSession session) {
    final isCurrentSession =
        session.sessionId == _sessionService.currentSessionId;
    final isBeingTerminated =
        _sessionsBeingTerminated.contains(session.sessionId);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(
            session.deviceInfo.type == 'web'
                ? Icons.web
                : session.deviceInfo.type == 'ios'
                    ? Icons.phone_iphone
                    : session.deviceInfo.type == 'android'
                        ? Icons.android
                        : Icons.devices,
          ),
        ),
        title: Text(session.deviceInfo.displayName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${session.deviceInfo.os} • ${session.deviceInfo.browser}'),
            Text('Activa ${_formatTimeAgo(session.lastActivity)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            if (isCurrentSession)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Sesión actual',
                  style: TextStyle(color: Colors.green, fontSize: 11),
                ),
              ),
          ],
        ),
        trailing: isCurrentSession
            ? null
            : isBeingTerminated
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : IconButton(
                    onPressed: () => _terminateSession(session),
                    icon: const Icon(Icons.close, color: Colors.red),
                    tooltip: 'Cerrar sesión',
                  ),
      ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'hoy';
    } else if (difference.inDays == 1) {
      return 'ayer';
    } else if (difference.inDays < 7) {
      return 'hace ${difference.inDays}d';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.devices,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Sin sesiones activas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vincula un dispositivo para empezar',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _hasAuthError ? null : _linkNewDevice,
              icon: const Icon(Icons.qr_code),
              label: const Text('Vincular dispositivo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _hasAuthError ? Icons.lock_outline : Icons.error_outline,
              size: 64,
              color: _hasAuthError ? Colors.orange : Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              _hasAuthError ? 'Sesión requerida' : 'Error de conexión',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _hasAuthError ? Colors.orange[700] : Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Error desconocido',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_hasAuthError) ...[
                  ElevatedButton.icon(
                    onPressed: _loadActiveSessions,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: Text(_hasAuthError ? 'Volver' : 'Cerrar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return ChangeNotifierProvider.value(
      value: _sessionService,
      child: Consumer<SessionManagementService>(
        builder: (context, service, child) {
          return Card(
            elevation: 2,
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.settings, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Configuración de sesiones',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Permitir múltiples sesiones'),
                    subtitle: Text(
                      service.allowMultipleSessions
                          ? 'Puedes usar la app en varios dispositivos'
                          : 'Solo una sesión activa a la vez (como Signal)',
                      style: const TextStyle(fontSize: 12),
                    ),
                    value: service.allowMultipleSessions,
                    onChanged: _hasAuthError
                        ? null
                        : (value) {
                            service.updateSessionSettings(allowMultiple: value);
                          },
                    contentPadding: EdgeInsets.zero,
                  ),
                  if (service.allowMultipleSessions) ...[
                    const Divider(),
                    ListTile(
                      title: const Text('Máximo de sesiones'),
                      subtitle:
                          Text('Hasta ${service.maxSessions} dispositivos'),
                      trailing: Text(
                        '${service.maxSessions}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sesiones activas'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          if (!_hasAuthError &&
              !_isLoading &&
              _sessionService.hasActiveSessions) ...[
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'refresh') {
                  _loadActiveSessions();
                } else if (value == 'terminate_all') {
                  _terminateAllOtherSessions();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'refresh',
                  child: Row(
                    children: [
                      Icon(Icons.refresh),
                      SizedBox(width: 8),
                      Text('Actualizar'),
                    ],
                  ),
                ),
                if (_sessionService.activeSessions
                    .any((s) => !s.isCurrentSession)) ...[
                  const PopupMenuItem(
                    value: 'terminate_all',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red),
                        SizedBox(width: 8),
                        Text(
                          'Cerrar otras sesiones',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorState()
              : RefreshIndicator(
                  onRefresh: _loadActiveSessions,
                  child: ChangeNotifierProvider.value(
                    value: _sessionService,
                    child: Consumer<SessionManagementService>(
                      builder: (context, service, child) {
                        if (!service.hasActiveSessions) {
                          return _buildEmptyState();
                        }

                        return Column(
                          children: [
                            // Información general
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.blue.withOpacity(0.3)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.info,
                                          color: Colors.blue, size: 20),
                                      SizedBox(width: 8),
                                      Text(
                                        'Información de sesiones',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '• ${service.activeSessions.length} ${service.activeSessions.length == 1 ? 'sesión activa' : 'sesiones activas'}\n'
                                    '• ${service.activeSessions.where((s) => s.isActive).length} en línea ahora\n'
                                    '• Configuración: ${service.allowMultipleSessions ? 'Múltiples dispositivos' : 'Solo un dispositivo'}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Lista de sesiones
                            Expanded(
                              child: ListView.builder(
                                itemCount: service.activeSessions.length,
                                itemBuilder: (context, index) {
                                  final session = service.activeSessions[index];
                                  return _buildSessionCard(session);
                                },
                              ),
                            ),

                            // Configuraciones
                            _buildSettingsSection(),
                          ],
                        );
                      },
                    ),
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Mostrar dialog informativo sobre política de 1 sesión
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.security, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('Política de Seguridad'),
                ],
              ),
              content: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🔒 Solo se permite 1 sesión activa por usuario',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Text('Beneficios de seguridad:'),
                  SizedBox(height: 8),
                  Text('• Previene suplantación de identidad'),
                  Text('• Elimina accesos no autorizados'),
                  Text('• Garantiza control total de la cuenta'),
                  Text('• Simplicidad de gestión'),
                  SizedBox(height: 12),
                  Text(
                    'Al iniciar sesión desde otro dispositivo, todas las sesiones anteriores se cerrarán automáticamente.',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Entendido'),
                ),
              ],
            ),
          );
        },
        icon: const Icon(Icons.security),
        label: const Text('Política de seguridad'),
        backgroundColor: Colors.orange.withOpacity(0.1),
        foregroundColor: Colors.orange,
      ),
    );
  }
}
