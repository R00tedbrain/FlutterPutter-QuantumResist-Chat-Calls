import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  final String url;
  final String title;

  const WebViewScreen({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  bool _isLoading = true;
  WebViewController? _controller;

  @override
  void initState() {
    super.initState();

    if (kIsWeb) {
      // En Web: Abrir en nueva pestaña y cerrar esta pantalla
      _openUrlWeb();
    } else {
      // En iOS/Android: Usar WebView integrado
      _initializeWebView();
    }
  }

  Future<void> _initializeWebView() async {
    try {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..enableZoom(true) // Habilitar zoom para mejor navegación
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              if (progress == 100) {
                setState(() {
                  _isLoading = false;
                });
              }
            },
            onPageStarted: (String url) {
              setState(() {
                _isLoading = true;
              });
            },
            onPageFinished: (String url) {
              setState(() {
                _isLoading = false;
              });
            },
            onWebResourceError: (WebResourceError error) {
              setState(() {
                _isLoading = false;
              });
              _showError('Error cargando la página: ${error.description}');
            },
          ),
        )
        ..loadRequest(Uri.parse(widget.url));

      print('🌐 [WEBVIEW] Cargando URL en WebView: ${widget.url}');
    } catch (e) {
      print('❌ [WEBVIEW] Error inicializando WebView: $e');
      _showError('Error inicializando WebView');
    }
  }

  Future<void> _openUrlWeb() async {
    try {
      // Pequeña pausa para mostrar la pantalla de carga
      await Future.delayed(const Duration(milliseconds: 500));

      final Uri uri = Uri.parse(widget.url);
      if (await canLaunchUrl(uri)) {
        print('🌐 [WEB] Abriendo URL en nueva pestaña: ${widget.url}');
        await launchUrl(uri, mode: LaunchMode.externalApplication);

        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        _showError('No se puede abrir la URL');
      }
    } catch (e) {
      print('❌ [WEB] Error abriendo URL: $e');
      _showError('Error al abrir la página web');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // En Web: Pantalla de carga mientras abre la URL externa
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
              ),
              SizedBox(height: 16),
              Text('Abriendo página web en nueva pestaña...'),
            ],
          ),
        ),
      );
    }

    // En iOS/Android: WebView integrado
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          if (_controller != null) ...[
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _controller!.reload(),
              tooltip: 'Recargar',
            ),
            IconButton(
              icon: const Icon(Icons.open_in_browser),
              onPressed: () async {
                final Uri uri = Uri.parse(widget.url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              tooltip: 'Abrir en navegador',
            ),
          ],
        ],
      ),
      body: Stack(
        children: [
          if (_controller != null)
            // WebView con scroll habilitado para móvil
            WebViewWidget(
              controller: _controller!,
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                Factory<VerticalDragGestureRecognizer>(
                  () => VerticalDragGestureRecognizer(),
                ),
                Factory<PanGestureRecognizer>(
                  () => PanGestureRecognizer(),
                ),
                Factory<TapGestureRecognizer>(
                  () => TapGestureRecognizer(),
                ),
              },
            )
          else
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Error inicializando WebView',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),

          // Indicador de carga
          if (_isLoading)
            Container(
              color: Colors.white,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                    ),
                    SizedBox(height: 16),
                    Text('Cargando página web...'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
