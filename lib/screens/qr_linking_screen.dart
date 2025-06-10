import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/active_session.dart';
import '../services/session_management_service.dart';

class QRLinkingScreen extends StatefulWidget {
  const QRLinkingScreen({super.key});

  @override
  State<QRLinkingScreen> createState() => _QRLinkingScreenState();
}

class _QRLinkingScreenState extends State<QRLinkingScreen>
    with TickerProviderStateMixin {
  final SessionManagementService _sessionService = SessionManagementService();

  QRLinkingData? _qrData;
  Timer? _countdownTimer;
  Timer? _refreshTimer;
  int _secondsRemaining = 300; // 5 minutos
  bool _isGenerating = false;
  bool _isScanning = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final TextEditingController _qrTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _generateQR();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
  }

  Future<void> _generateQR() async {
    setState(() => _isGenerating = true);

    try {
      final qrData = await _sessionService.generateQRForLinking();

      if (qrData != null) {
        setState(() {
          _qrData = qrData;
          _secondsRemaining = qrData.secondsRemaining;
          _isGenerating = false;
        });

        _startCountdown();
        _startRefreshTimer();

        _showSuccess('QR generado exitosamente');
      } else {
        throw Exception('Error generando QR');
      }
    } catch (e) {
      setState(() => _isGenerating = false);
      _showError('Error generando QR: $e');
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _secondsRemaining = _qrData?.secondsRemaining ?? 0;

          if (_secondsRemaining <= 0) {
            timer.cancel();
            _countdownTimer = null;
            _qrData = null;
            _showError('QR expirado. Generando uno nuevo...');
            _generateQR();
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    // Refrescar cada 30 segundos para mantener actualizado
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted && _qrData != null && !_qrData!.isExpired) {
        // En implementación real, verificar con servidor si hay nuevas sesiones
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _scanQRCode() async {
    // Mostrar dialog para pegar código QR manualmente (simulación)
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Escanear código QR'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'En una implementación real, aquí abriríamos la cámara para escanear.\n\n'
              'Por ahora, pega el código QR manualmente:',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _qrTextController,
              decoration: const InputDecoration(
                labelText: 'Código QR',
                border: OutlineInputBorder(),
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
          TextButton(
            onPressed: () => Navigator.pop(context, _qrTextController.text),
            child: const Text('Vincular'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      await _linkWithQR(result);
    }
  }

  Future<void> _linkWithQR(String qrData) async {
    setState(() => _isScanning = true);

    try {
      final success = await _sessionService.linkSessionWithQR(qrData);

      if (success) {
        _showSuccess('¡Dispositivo vinculado exitosamente!');
        // Esperar un momento y regresar
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        _showError('Error vinculando dispositivo. Verifica el código QR.');
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() => _isScanning = false);
    }
  }

  void _copyQRToClipboard() {
    if (_qrData != null) {
      Clipboard.setData(ClipboardData(text: _qrData!.qrCodeData));
      _showSuccess('Código QR copiado al portapapeles');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('❌ $message'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ $message'),
        backgroundColor: Colors.green,
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Widget _buildQRDisplay() {
    if (_isGenerating) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Generando código QR...'),
          ],
        ),
      );
    }

    if (_qrData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.qr_code,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Error generando QR',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _generateQR,
              child: const Text('Intentar nuevamente'),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ✅ QR Code REAL usando qr_flutter
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 270,
                  height: 270,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[300]!, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: QrImageView(
                      data: _qrData!.qrCodeData, // ✅ DATOS REALES DEL QR
                      version: QrVersions.auto,
                      size: 230,
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      errorCorrectionLevel: QrErrorCorrectLevel.M,
                      embeddedImage:
                          null, // Puedes añadir un logo aquí si quieres
                      embeddedImageStyle: const QrEmbeddedImageStyle(
                        size: Size(40, 40),
                      ),
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Colors.black,
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Colors.black,
                      ),
                      gapless: false,
                      semanticsLabel: 'QR Code para vincular dispositivo',
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 32),

          // Tiempo restante
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _secondsRemaining < 60
                  ? Colors.red.withOpacity(0.1)
                  : Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _secondsRemaining < 60 ? Colors.red : Colors.blue,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.timer,
                  size: 20,
                  color: _secondsRemaining < 60 ? Colors.red : Colors.blue,
                ),
                const SizedBox(width: 8),
                Text(
                  'Expira en ${_formatTime(_secondsRemaining)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _secondsRemaining < 60 ? Colors.red : Colors.blue,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Botones de acción
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _copyQRToClipboard,
                icon: const Icon(Icons.copy),
                label: const Text('Copiar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _generateQR,
                icon: const Icon(Icons.refresh),
                label: const Text('Nuevo QR'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info, color: Colors.blue, size: 20),
              SizedBox(width: 8),
              Text(
                'Cómo vincular un dispositivo',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '1. Abre la app en el nuevo dispositivo\n'
            '2. Ve a Configuración > Sesiones activas\n'
            '3. Toca "Vincular dispositivo"\n'
            '4. Escanea este código QR\n'
            '5. ¡Listo! Ambos dispositivos estarán conectados',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.security, color: Colors.orange, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Este código expira en 5 minutos por seguridad',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _refreshTimer?.cancel();
    _pulseController.dispose();
    _qrTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vincular dispositivo'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _scanQRCode,
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Escanear QR',
          ),
        ],
      ),
      body: _isScanning
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Vinculando dispositivo...'),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Instrucciones
                  _buildInstructions(),

                  const SizedBox(height: 20),

                  // QR Display
                  SizedBox(
                    height: 400,
                    child: _buildQRDisplay(),
                  ),

                  const SizedBox(height: 20),

                  // Información adicional
                  if (_qrData != null) ...[
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: Colors.green.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.devices,
                                  color: Colors.green, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Información de vinculación',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '• Dispositivo origen: ${_qrData!.fromDevice ?? 'Este dispositivo'}\n'
                            '• Token: ${_qrData!.linkingToken.substring(0, 8)}...\n'
                            '• Expira: ${_formatTime(_secondsRemaining)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}
