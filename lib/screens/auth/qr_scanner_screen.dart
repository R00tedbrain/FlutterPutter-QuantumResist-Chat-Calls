import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

/// Pantalla de scanner QR con cámara real (ACTUALIZADA a mobile_scanner)
class QRScannerScreen extends StatefulWidget {
  final String title;
  final String? subtitle;
  final Function(String) onQRScanned;

  const QRScannerScreen({
    super.key,
    required this.title,
    this.subtitle,
    required this.onQRScanned,
  });

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen>
    with WidgetsBindingObserver {
  MobileScannerController controller = MobileScannerController();
  bool _isFlashOn = false;
  bool _hasPermission = false;
  bool _isScanning = true;
  String? _scannedData;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkCameraPermission();
  }

  /// Verificar y solicitar permisos de cámara
  Future<void> _checkCameraPermission() async {
    try {
      final status = await Permission.camera.status;

      if (status.isGranted) {
        setState(() => _hasPermission = true);
      } else if (status.isDenied) {
        final result = await Permission.camera.request();
        setState(() => _hasPermission = result.isGranted);

        if (!result.isGranted) {}
      } else if (status.isPermanentlyDenied) {
        _showPermissionDialog();
      } else {
        // Intentar solicitar de todos modos
        final result = await Permission.camera.request();
        setState(() => _hasPermission = result.isGranted);
      }
    } catch (e) {
      setState(() => _hasPermission = false);
    }
  }

  /// Mostrar dialog para abrir configuración
  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.camera_alt, color: Colors.orange),
            SizedBox(width: 8),
            Text('Permiso de cámara'),
          ],
        ),
        content: const Text(
          'FlutterPutter necesita acceso a la cámara para escanear códigos QR.\n\n'
          'Ve a Configuración > Privacidad > Cámara y habilita el acceso para FlutterPutter.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Abrir configuración'),
          ),
        ],
      ),
    );
  }

  /// Callback cuando se detecta un QR (NUEVO con mobile_scanner)
  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;

    for (final barcode in barcodes) {
      final String? code = barcode.rawValue;

      if (_isScanning && code != null && code.isNotEmpty) {
        setState(() {
          _isScanning = false;
          _scannedData = code;
        });

        // Vibrar (si está disponible)
        _vibrate();

        // Procesar QR escaneado
        widget.onQRScanned(code);
        break; // Solo procesar el primer código válido
      } else {}
    }
  }

  /// Vibración al escanear
  void _vibrate() {
    try {
      // En implementación real usarías vibration: ^3.1.0
    } catch (e) {}
  }

  /// Toggle flash
  Future<void> _toggleFlash() async {
    try {
      await controller.toggleTorch();
      setState(() => _isFlashOn = !_isFlashOn);
    } catch (e) {}
  }

  /// Reiniciar scanner
  void _restartScanner() {
    setState(() {
      _isScanning = true;
      _scannedData = null;
    });
    controller.start();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      controller.stop();
    } else if (state == AppLifecycleState.resumed && _hasPermission) {
      controller.start();
    }
  }

  Widget _buildPermissionDenied() {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.camera_alt_outlined,
                size: 80,
                color: Colors.grey,
              ),
              const SizedBox(height: 24),
              const Text(
                'Permiso de cámara requerido',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'FlutterPutter necesita acceso a la cámara para escanear códigos QR.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _checkCameraPermission,
                icon: const Icon(Icons.refresh),
                label: const Text('Verificar permisos'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () => openAppSettings(),
                icon: const Icon(Icons.settings, color: Colors.orange),
                label: const Text(
                  'Abrir configuración',
                  style: TextStyle(color: Colors.orange),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScannerView() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Scanner de QR
          MobileScanner(
            controller: controller,
            onDetect: _onDetect,
          ),

          // Overlay con UI personalizada
          _buildScannerOverlay(),

          // AppBar personalizada
          SafeArea(
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (widget.subtitle != null)
                          Text(
                            widget.subtitle!,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isFlashOn ? Icons.flash_on : Icons.flash_off,
                      color: Colors.white,
                    ),
                    onPressed: _toggleFlash,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerOverlay() {
    return Column(
      children: [
        Expanded(flex: 1, child: Container(color: Colors.black54)),
        Expanded(
          flex: 3,
          child: Row(
            children: [
              Expanded(flex: 1, child: Container(color: Colors.black54)),
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _isScanning ? Colors.green : Colors.orange,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _scannedData != null
                      ? Container(
                          color: Colors.green.withOpacity(0.2),
                          child: const Center(
                            child: Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 48,
                            ),
                          ),
                        )
                      : null,
                ),
              ),
              Expanded(flex: 1, child: Container(color: Colors.black54)),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            color: Colors.black54,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_scannedData != null) ...[
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '¡QR escaneado exitosamente!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _restartScanner,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Escanear otro'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ] else ...[
                    const Text(
                      'Apunta la cámara hacia el código QR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Icon(
                      Icons.qr_code_scanner,
                      color: Colors.white54,
                      size: 32,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasPermission) {
      return _buildPermissionDenied();
    }

    return _buildScannerView();
  }
}
