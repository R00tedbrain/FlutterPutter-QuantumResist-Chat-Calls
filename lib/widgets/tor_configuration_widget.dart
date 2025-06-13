import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:flutterputter/services/tor_configuration_service.dart';
import 'package:flutterputter/services/tor_api_integration.dart';

/// 🌐 TorConfigurationWidget - Widget para configurar la red Tor
///
/// CARACTERÍSTICAS:
/// - 🔒 Tor FORZADO para máxima anonimidad (no se puede desactivar)
/// - 📱 Solo funciona en iOS/Android (mensaje informativo en web)
/// - Test de conectividad en tiempo real
/// - Configuración avanzada opcional
/// - Logs en tiempo real para debug
/// - Diseño que respeta el AppTheme existente
///
/// CRÍTICO: Tor está SIEMPRE habilitado para proteger la identidad del usuario
class TorConfigurationWidget extends StatefulWidget {
  final bool showAdvancedOptions;
  final bool showDebugLogs;
  final VoidCallback? onConfigurationChanged;

  const TorConfigurationWidget({
    Key? key,
    this.showAdvancedOptions = false,
    this.showDebugLogs = true,
    this.onConfigurationChanged,
  }) : super(key: key);

  @override
  State<TorConfigurationWidget> createState() => _TorConfigurationWidgetState();
}

class _TorConfigurationWidgetState extends State<TorConfigurationWidget> {
  bool _isTorEnabled = false;
  bool _isLoading = false;
  bool _isTestingConnection = false;
  String _torHost = '127.0.0.1';
  int _torPort = 9050;
  String? _lastError;
  String? _connectionStatus;

  // Controllers para campos de texto
  final _hostController = TextEditingController();
  final _portController = TextEditingController();

  // Debug logs
  final List<String> _debugLogs = [];
  final int _maxLogEntries = 50;

  @override
  void initState() {
    super.initState();
    _loadConfiguration();
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    super.dispose();
  }

  /// 📥 Cargar configuración actual
  Future<void> _loadConfiguration() async {
    setState(() {
      _isLoading = true;
      _lastError = null;
    });

    try {
      final config = await TorConfigurationService.getConfiguration();

      setState(() {
        _isTorEnabled = config['enabled'] ?? false;
        _torHost = config['host'] ?? '127.0.0.1';
        _torPort = config['port'] ?? 9050;
        _hostController.text = _torHost;
        _portController.text = _torPort.toString();
        _isLoading = false;
      });

      _addDebugLog(
          '✅ Configuración cargada: Tor ${_isTorEnabled ? "HABILITADO" : "DESHABILITADO"}');

      if (_isTorEnabled) {
        await _testConnection(showInUI: false);
      }
    } catch (e) {
      setState(() {
        _lastError = 'Error cargando configuración: $e';
        _isLoading = false;
      });
      _addDebugLog('❌ Error cargando configuración: $e');
    }
  }

  /// ⚙️ Cambiar estado Tor
  Future<void> _toggleTor(bool enabled) async {
    setState(() {
      _isLoading = true;
      _lastError = null;
    });

    _addDebugLog('🔧 ${enabled ? "Habilitando" : "Deshabilitando"} Tor...');

    try {
      final success = await TorConfigurationService.setTorEnabled(enabled);

      if (success) {
        setState(() {
          _isTorEnabled = enabled;
          _isLoading = false;
        });

        _addDebugLog(
            '✅ Tor ${enabled ? "habilitado" : "deshabilitado"} correctamente');

        if (enabled) {
          await _testConnection(showInUI: false);
        } else {
          setState(() {
            _connectionStatus = null;
          });
        }

        // Notificar cambio de configuración
        widget.onConfigurationChanged?.call();
      } else {
        setState(() {
          _lastError = 'Error cambiando estado de Tor';
          _isLoading = false;
        });
        _addDebugLog('❌ Error cambiando estado de Tor');
      }
    } catch (e) {
      setState(() {
        _lastError = 'Error: $e';
        _isLoading = false;
      });
      _addDebugLog('❌ Excepción cambiando estado Tor: $e');
    }
  }

  /// 🧪 Test de conectividad
  Future<void> _testConnection({bool showInUI = true}) async {
    if (showInUI) {
      setState(() {
        _isTestingConnection = true;
        _connectionStatus = null;
        _lastError = null;
      });
    }

    _addDebugLog('🧪 Iniciando test de conectividad Tor...');

    try {
      final stopwatch = Stopwatch()..start();
      final success = await TorApiIntegration.testTorConnectivity();
      stopwatch.stop();

      final duration = stopwatch.elapsedMilliseconds;

      if (success) {
        setState(() {
          _connectionStatus = '✅ Conectado (${duration}ms)';
          _isTestingConnection = false;
        });
        _addDebugLog('✅ Test exitoso: ${duration}ms');
      } else {
        setState(() {
          _connectionStatus = '❌ No conectado';
          _isTestingConnection = false;
        });
        _addDebugLog('❌ Test falló');
      }
    } catch (e) {
      setState(() {
        _connectionStatus = '❌ Error: $e';
        _isTestingConnection = false;
      });
      _addDebugLog('❌ Error en test: $e');
    }
  }

  /// 🔧 Aplicar configuración avanzada
  Future<void> _applyAdvancedConfiguration() async {
    final host = _hostController.text.trim();
    final portStr = _portController.text.trim();

    if (host.isEmpty) {
      setState(() {
        _lastError = 'Host no puede estar vacío';
      });
      return;
    }

    final port = int.tryParse(portStr);
    if (port == null || port <= 0 || port > 65535) {
      setState(() {
        _lastError = 'Puerto debe ser un número entre 1 y 65535';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _lastError = null;
    });

    _addDebugLog('🔧 Aplicando configuración: $host:$port');

    try {
      final success = await TorConfigurationService.setTorProxy(
        host: host,
        port: port,
      );

      if (success) {
        setState(() {
          _torHost = host;
          _torPort = port;
          _isLoading = false;
        });

        _addDebugLog('✅ Configuración aplicada correctamente');

        if (_isTorEnabled) {
          await _testConnection(showInUI: false);
        }

        widget.onConfigurationChanged?.call();
      } else {
        setState(() {
          _lastError = 'Error aplicando configuración';
          _isLoading = false;
        });
        _addDebugLog('❌ Error aplicando configuración');
      }
    } catch (e) {
      setState(() {
        _lastError = 'Error: $e';
        _isLoading = false;
      });
      _addDebugLog('❌ Excepción aplicando configuración: $e');
    }
  }

  /// 📝 Agregar entrada al log de debug
  void _addDebugLog(String message) {
    if (!widget.showDebugLogs) return;

    final timestamp = DateTime.now().toLocal().toString().substring(11, 19);
    final logEntry = '[$timestamp] $message';

    setState(() {
      _debugLogs.insert(0, logEntry);
      if (_debugLogs.length > _maxLogEntries) {
        _debugLogs.removeRange(_maxLogEntries, _debugLogs.length);
      }
    });

    if (kDebugMode) {
      print('🌐 [TOR-WIDGET] $message');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.security,
                  color: _isTorEnabled ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  'Red Tor',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Toggle principal - FORZADO SIEMPRE ACTIVO
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kIsWeb
                    ? Colors.orange.withOpacity(0.1)
                    : Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: kIsWeb
                      ? Colors.orange.withOpacity(0.3)
                      : Colors.green.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  if (kIsWeb) ...[
                    // Mensaje para plataforma web
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.orange, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '🌐 Tor solo está disponible en iOS/Android',
                            style: TextStyle(
                              color: Colors.orange[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'En navegadores web se usan conexiones HTTPS seguras. Para máxima anonimidad, use la app móvil.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange[600],
                      ),
                    ),
                  ] else if (!kIsWeb && Platform.isIOS) ...[
                    // Mensaje específico para iOS
                    Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '📱 iOS: Tor nativo no disponible',
                            style: TextStyle(
                              color: Colors.orange[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'iOS no permite daemons Tor nativos. Se usan conexiones HTTPS directas. Para Tor real: instale Orbot o use VPN con Tor.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.lightbulb, color: Colors.blue, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '💡 Alternativas: 1) App Orbot, 2) VPN+Tor, 3) Proxy externo',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.blue[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Toggle para Android - SIEMPRE ACTIVO
                    Row(
                      children: [
                        Icon(
                          Icons.security,
                          color: _isTorEnabled ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '🔒 Red Tor (FORZADO)',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _isTorEnabled
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                              ),
                              Text(
                                _isTorEnabled
                                    ? '✅ Conexiones anónimas ACTIVAS'
                                    : '⚠️ Activando conexiones anónimas...',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _isTorEnabled
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Switch deshabilitado con explicación
                        Tooltip(
                          message:
                              'Tor está forzado para máxima seguridad y no se puede desactivar',
                          child: Switch(
                            value: true, // Siempre true
                            onChanged: null, // Deshabilitado
                            activeColor: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info, color: Colors.blue, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '🔒 Tor está SIEMPRE activo para proteger tu identidad. No se puede desactivar por seguridad.',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.blue[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Estado de conexión
            if (_connectionStatus != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.network_check,
                      size: 16,
                      color: _connectionStatus!.startsWith('✅')
                          ? Colors.green
                          : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_connectionStatus!)),
                  ],
                ),
              ),
            ],

            // Test de conectividad
            if (_isTorEnabled) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: (_isLoading || _isTestingConnection)
                    ? null
                    : () => _testConnection(),
                icon: _isTestingConnection
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.network_ping),
                label: Text(
                    _isTestingConnection ? 'Probando...' : 'Probar Conexión'),
              ),
            ],

            // Configuración avanzada
            if (widget.showAdvancedOptions) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'Configuración Avanzada',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _hostController,
                      decoration: InputDecoration(
                        labelText: 'Host Tor',
                        hintText: '127.0.0.1',
                        border: OutlineInputBorder(),
                      ),
                      enabled: !_isLoading,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _portController,
                      decoration: InputDecoration(
                        labelText: 'Puerto',
                        hintText: '9050',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      enabled: !_isLoading,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _applyAdvancedConfiguration,
                icon: const Icon(Icons.save),
                label: const Text('Aplicar Configuración'),
              ),
            ],

            // Error display
            if (_lastError != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _lastError!,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Debug logs
            if (widget.showDebugLogs && _debugLogs.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'Logs de Debug',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _debugLogs.clear();
                      });
                    },
                    child: const Text('Limpiar'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                ),
                child: ListView.builder(
                  itemCount: _debugLogs.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 2,
                      ),
                      child: Text(
                        _debugLogs[index],
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
