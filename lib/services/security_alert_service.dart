import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

/// Servicio para manejar alertas críticas de seguridad
class SecurityAlertService {
  static SecurityAlertService? _instance;
  static SecurityAlertService get instance =>
      _instance ??= SecurityAlertService._internal();
  SecurityAlertService._internal();

  BuildContext? _context;
  bool _isAlertShowing = false;

  /// Registrar contexto para mostrar alertas
  void setContext(BuildContext context) {
    _context = context;
  }

  /// 🚨 ALERTA CRÍTICA: Sesión cerrada por otro dispositivo
  Future<void> showSessionForcedLogoutAlert({
    required String reason,
    required String timestamp,
    String? sessionId,
  }) async {
    if (_context == null || _isAlertShowing) return;

    _isAlertShowing = true;

    // Vibración fuerte para alertar
    HapticFeedback.heavyImpact();

    // Esperar un momento para asegurar que la UI esté lista
    await Future.delayed(const Duration(milliseconds: 500));

    if (_context != null && _context!.mounted) {
      await showDialog(
        context: _context!,
        barrierDismissible: false, // No se puede cerrar tocando fuera
        builder: (context) => _buildCriticalSecurityAlert(
          context,
          reason,
          timestamp,
          sessionId,
        ),
      );
    }

    _isAlertShowing = false;
  }

  /// 🚨 ALERTA: Desconexión detectada
  Future<void> showDisconnectionAlert({
    required String reason,
  }) async {
    if (_context == null || _isAlertShowing) return;

    _isAlertShowing = true;

    // Vibración suave
    HapticFeedback.mediumImpact();

    if (_context != null && _context!.mounted) {
      await showDialog(
        context: _context!,
        barrierDismissible: true,
        builder: (context) => _buildDisconnectionAlert(context, reason),
      );
    }

    _isAlertShowing = false;
  }

  /// Widget de alerta crítica de seguridad
  Widget _buildCriticalSecurityAlert(
    BuildContext context,
    String reason,
    String timestamp,
    String? sessionId,
  ) {
    return WillPopScope(
      onWillPop: () async => false, // Prevenir cierre con botón back
      child: AlertDialog(
        backgroundColor: Colors.red.shade50,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.red.shade300, width: 2),
        ),
        title: Row(
          children: [
            Icon(
              Icons.security,
              color: Colors.red.shade700,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '🚨 ALERTA DE SEGURIDAD',
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TU SESIÓN FUE CERRADA',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Alguien accedió a tu cuenta desde otro dispositivo.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Solo se permite UNA sesión activa por usuario para tu seguridad.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.red.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Información técnica
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detalles:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '• Hora: ${_formatTimestamp(timestamp)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    '• Motivo: $reason',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (sessionId != null)
                    Text(
                      '• Sesión: ${sessionId.substring(0, 8)}...',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Mensaje de acción
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '⚠️ SI NO FUISTE TÚ:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '1. Tu cuenta está COMPROMETIDA\n2. Cambia tu contraseña INMEDIATAMENTE\n3. Contacta a los administradores\n4. Revisa tus dispositivos',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade700,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Botón secundario
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Ir a pantalla de cambio de contraseña o configuración
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.orange.shade700,
            ),
            child: const Text('Cambiar Contraseña'),
          ),

          // Botón principal
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Cerrar la aplicación o ir al login
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  /// Widget de alerta de desconexión
  Widget _buildDisconnectionAlert(BuildContext context, String reason) {
    return AlertDialog(
      backgroundColor: Colors.orange.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.orange.shade300, width: 2),
      ),
      title: Row(
        children: [
          Icon(
            Icons.wifi_off,
            color: Colors.orange.shade700,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            'Conexión Perdida',
            style: TextStyle(
              color: Colors.orange.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Se perdió la conexión con el servidor.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.orange.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Motivo: $reason',
            style: TextStyle(
              fontSize: 12,
              color: Colors.orange.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Verifica tu conexión a internet y vuelve a intentar.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            // Intentar reconectar
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange.shade600,
            foregroundColor: Colors.white,
          ),
          child: const Text('Reintentar'),
        ),
      ],
    );
  }

  /// Formatear timestamp para mostrar
  String _formatTimestamp(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 1) {
        return 'Hace ${diff.inSeconds} segundos';
      } else if (diff.inHours < 1) {
        return 'Hace ${diff.inMinutes} minutos';
      } else {
        return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      return 'Ahora mismo';
    }
  }
}
