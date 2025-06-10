import 'package:flutter/material.dart';
import '../../services/session_management_service.dart';
import 'qr_scanner_screen.dart';

/// Pantalla para escanear QR y auto-login como WhatsApp/Telegram
class QRLoginScreen extends StatefulWidget {
  const QRLoginScreen({super.key});

  @override
  State<QRLoginScreen> createState() => _QRLoginScreenState();
}

class _QRLoginScreenState extends State<QRLoginScreen> {
  final SessionManagementService _sessionService = SessionManagementService();
  final TextEditingController _qrTextController = TextEditingController();
  bool _isScanning = false;

  @override
  void dispose() {
    _qrTextController.dispose();
    super.dispose();
  }

  /// Escanear código QR y hacer auto-login
  Future<void> _scanQRAndLogin() async {
    // Navegar al scanner con cámara real
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => QRScannerScreen(
          title: 'Escanear para vincular dispositivo',
          subtitle:
              'Apunta la cámara al código QR generado en tu otro dispositivo',
          onQRScanned: (qrData) async {
            // Procesar QR y cerrar scanner
            Navigator.pop(context, qrData);
          },
        ),
      ),
    );

    if (result != null && result.isNotEmpty) {
      await _processQRLogin(result);
    }
  }

  /// Mostrar dialog para introducir QR manualmente
  Future<String?> _showQRInputDialog() async {
    _qrTextController.clear();

    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.qr_code_scanner, color: Colors.blue),
            SizedBox(width: 8),
            Text('Escanear código QR'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Escanea el código QR desde otro dispositivo donde ya tengas la sesión iniciada.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            const Text(
              'Para obtener el QR:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const Text(
              '• Ve a Configuración > Sesiones activas\n'
              '• Toca "Vincular dispositivo"\n'
              '• Copia el código QR y pégalo aquí',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _qrTextController,
              decoration: const InputDecoration(
                labelText: 'Código QR',
                hintText: 'Pega el código QR aquí...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.qr_code),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, _qrTextController.text),
            child: const Text('Vincular dispositivo'),
          ),
        ],
      ),
    );
  }

  /// Procesar QR y hacer auto-login
  Future<void> _processQRLogin(String qrData) async {
    setState(() => _isScanning = true);

    try {
      print('🔍 [QR-LOGIN] Procesando código QR para auto-login...');

      // Intentar vincular con el QR usando SessionManagementService
      final success = await _sessionService.linkSessionWithQR(qrData);

      if (success) {
        _showSuccess('¡Dispositivo vinculado exitosamente!');

        // Esperar un momento para mostrar el mensaje
        await Future.delayed(const Duration(seconds: 1));

        if (mounted) {
          // Auto-login exitoso, navegar a home
          Navigator.pushReplacementNamed(context, '/encrypting');
        }
      } else {
        _showError(
            'Código QR inválido o expirado. Verifica que el código sea correcto.');
      }
    } catch (e) {
      print('🔍 [QR-LOGIN] Error en auto-login: $e');
      _showError('Error vinculando dispositivo: $e');
    } finally {
      if (mounted) {
        setState(() => _isScanning = false);
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ $message'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _showSuccess(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ $message'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/fondoflutterputter.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Botón de regreso
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.white),
                        ),
                        const Expanded(
                          child: Text(
                            'Vincular dispositivo',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 48), // Para centrar el título
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Icono principal
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(60),
                        border: Border.all(color: Colors.blue, width: 2),
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner,
                        size: 60,
                        color: Colors.blue,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Título
                    const Text(
                      'Vincular con código QR',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 16),

                    // Descripción
                    const Text(
                      'Escanea el código QR desde otro dispositivo donde ya tengas FlutterPutter iniciado.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 32),

                    // Instrucciones paso a paso
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pasos para vincular:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            '1. En tu otro dispositivo, ve a Configuración\n'
                            '2. Toca "Sesiones activas"\n'
                            '3. Selecciona "Vincular dispositivo"\n'
                            '4. Toca "Escanear QR" en esta pantalla\n'
                            '5. Pega el código QR generado',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Botón principal
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _isScanning ? null : _scanQRAndLogin,
                        icon: _isScanning
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.qr_code_scanner),
                        label: Text(
                          _isScanning
                              ? 'Vinculando...'
                              : 'Abrir cámara y escanear',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Aviso de seguridad
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.security, color: Colors.orange, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Los códigos QR expiran en 5 minutos por seguridad',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
