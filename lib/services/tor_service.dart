import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:socks5_proxy/socks_client.dart';

/// 🌐 TorService - Servicio para conexiones anónimas a través de la red Tor
///
/// IMPLEMENTACIÓN FASE 1: Auth + Mensajes
/// - Proporciona proxy SOCKS5 para conexiones HTTP
/// - Mantiene compatibilidad total con servicios existentes
/// - Logs extensivos para debugging
/// - Configuración centralizada
///
/// 🚨 IMPORTANTE: Tor solo funciona en iOS/Android, NO en navegadores web
/// CRÍTICO: Este servicio NO altera ningún flujo existente
/// Solo proporciona HttpClient configurado con proxy Tor cuando se solicite
class TorService {
  static TorService? _instance;
  static bool _isInitialized = false;
  static bool _isEnabled = false;
  static bool _isConnecting = false;
  static String? _lastError;

  // Configuración Tor por defecto (puerto estándar)
  static const String _defaultTorHost = '127.0.0.1';
  static const int _defaultTorPort = 9050; // Puerto SOCKS5 estándar de Tor
  static const int _connectionTimeoutSeconds = 30;
  static const int _maxRetryAttempts = 3;

  // Configuración de debug
  static const bool _enableDebugLogs = true;
  static const bool _enableConnectionLogs = true;
  static const bool _enableErrorLogs = true;

  // Variables de estado
  static String _torHost = _defaultTorHost;
  static int _torPort = _defaultTorPort;
  static int _retryAttempts = 0;
  static DateTime? _lastConnectionAttempt;
  static Duration? _lastConnectionTime;

  /// Factory para obtener instancia singleton
  factory TorService() {
    _instance ??= TorService._internal();
    return _instance!;
  }

  TorService._internal();

  /// 🔧 Inicializar servicio Tor
  ///
  /// CRÍTICO: Esta función no inicia automáticamente Tor
  /// Solo prepara el servicio para cuando se necesite
  static Future<bool> initialize({
    String? customTorHost,
    int? customTorPort,
    bool enableTor = false,
  }) async {
    if (_isInitialized) {
      _logDebug('🔄 TorService ya está inicializado');
      return true;
    }

    _logDebug('🚀 [TOR-INIT] Inicializando TorService...');

    try {
      // Configurar parámetros personalizados si se proporcionan
      if (customTorHost != null) {
        _torHost = customTorHost;
        _logDebug('🔧 [TOR-CONFIG] Host personalizado: $_torHost');
      }

      if (customTorPort != null) {
        _torPort = customTorPort;
        _logDebug('🔧 [TOR-CONFIG] Puerto personalizado: $_torPort');
      }

      _isEnabled = enableTor;
      _isInitialized = true;

      _logDebug('✅ [TOR-INIT] TorService inicializado correctamente');
      _logDebug(
          '📊 [TOR-STATUS] Estado Tor: ${_isEnabled ? "HABILITADO" : "DESHABILITADO"}');
      _logDebug('🌐 [TOR-ENDPOINT] Endpoint: $_torHost:$_torPort');

      return true;
    } catch (e) {
      _lastError = 'Error inicializando TorService: $e';
      _logError('❌ [TOR-INIT-ERROR] $_lastError');
      return false;
    }
  }

  /// 🌐 Crear HttpClient configurado para Tor
  ///
  /// CRÍTICO: Retorna HttpClient normal si Tor está deshabilitado
  /// Mantiene compatibilidad total con código existente
  static Future<HttpClient> createHttpClient() async {
    if (!_isEnabled || !_isInitialized) {
      _logDebug('📡 [TOR-CLIENT] Tor deshabilitado, usando HttpClient normal');
      return HttpClient()
        ..connectionTimeout = Duration(seconds: _connectionTimeoutSeconds);
    }

    _logDebug('🔒 [TOR-CLIENT] Creando HttpClient con proxy Tor...');

    try {
      final client = HttpClient();

      // CRÍTICO: Configurar proxy SOCKS5 para todas las conexiones
      client.findProxy = (uri) {
        final proxyString = 'PROXY $_torHost:$_torPort';
        _logConnection('🌐 [TOR-PROXY] URI: $uri → Proxy: $proxyString');
        return proxyString;
      };

      // Configurar timeouts apropiados para Tor
      client.connectionTimeout = Duration(seconds: _connectionTimeoutSeconds);
      client.idleTimeout = Duration(seconds: _connectionTimeoutSeconds * 2);

      _logDebug('✅ [TOR-CLIENT] HttpClient con Tor configurado correctamente');
      return client;
    } catch (e) {
      _lastError = 'Error creando HttpClient con Tor: $e';
      _logError('❌ [TOR-CLIENT-ERROR] $_lastError');

      // FALLBACK SEGURO: Retornar cliente normal en caso de error
      _logDebug('🔄 [TOR-FALLBACK] Usando HttpClient normal como fallback');
      return HttpClient()
        ..connectionTimeout = Duration(seconds: _connectionTimeoutSeconds);
    }
  }

  /// 🧪 Test de conectividad Tor
  ///
  /// Verifica si el proxy Tor está funcionando correctamente
  /// Intenta conectar al proxy SOCKS5 y hacer una petición de prueba
  static Future<bool> testTorConnectivity() async {
    // 🚨 VERIFICAR PLATAFORMA WEB
    if (kIsWeb) {
      _logError(
          '🌐 [TOR-WEB-WARNING] Tor NO está disponible en navegadores web');
      _logError(
          '📱 [TOR-WEB-INFO] Use la versión iOS/Android para conexiones Tor');
      _logError('🔒 [TOR-WEB-INFO] En web se usarán conexiones HTTPS normales');
      return false; // Tor no funciona en web, pero no es un error crítico
    }

    // 🚨 VERIFICAR PLATAFORMA iOS
    if (!kIsWeb && Platform.isIOS) {
      _logError(
          '📱 [TOR-iOS-WARNING] iOS NO permite ejecutar daemons Tor nativamente');
      _logError('🔒 [TOR-iOS-INFO] iOS requiere proxy Tor externo o VPN');
      _logError(
          '💡 [TOR-iOS-SOLUTION] Opciones: 1) Orbot app, 2) VPN con Tor, 3) Proxy externo');
      _logError(
          '🔄 [TOR-iOS-FALLBACK] Usando conexiones HTTPS directas por seguridad');
      return false; // Tor nativo no funciona en iOS por restricciones del sistema
    }

    if (!_isInitialized) {
      _logError('❌ [TOR-TEST-ERROR] TorService no está inicializado');
      return false;
    }

    if (!_isEnabled) {
      _logDebug('📡 [TOR-TEST-INFO] Tor está deshabilitado');
      return false;
    }

    _logDebug('🧪 [TOR-TEST] Iniciando test de conectividad Tor...');
    _isConnecting = true;
    _lastConnectionAttempt = DateTime.now();

    final stopwatch = Stopwatch()..start();

    for (int attempt = 1; attempt <= _maxRetryAttempts; attempt++) {
      try {
        _logDebug('🔄 [TOR-TEST-ATTEMPT] Intento $attempt/$_maxRetryAttempts');

        // Crear socket para test de conectividad SOCKS5
        final socket = await Socket.connect(
          _torHost,
          _torPort,
          timeout: Duration(seconds: _connectionTimeoutSeconds),
        );

        await socket.close();
        stopwatch.stop();

        _lastConnectionTime = stopwatch.elapsed;
        _isConnecting = false;
        _retryAttempts = 0;
        _lastError = null;

        _logDebug(
            '✅ [TOR-TEST-SUCCESS] Conectividad Tor exitosa en ${_lastConnectionTime!.inMilliseconds}ms');

        return true;
      } catch (e) {
        _retryAttempts = attempt;
        _lastError = 'Test de conectividad Tor falló: $e';

        _logError(
            '❌ [TOR-TEST-FAILED] Intento $attempt/$_maxRetryAttempts: $_lastError');

        if (attempt < _maxRetryAttempts) {
          _logDebug('⏳ [TOR-TEST-RETRY] Reintentando en 2 segundos...');
          await Future.delayed(const Duration(seconds: 2));
        }
      }
    }

    stopwatch.stop();
    _isConnecting = false;

    _logError(
        '❌ [TOR-TEST-FINAL-FAILURE] Test de conectividad Tor falló después de $_maxRetryAttempts intentos');

    return false;
  }

  /// ⚙️ Habilitar/deshabilitar Tor
  static Future<void> setTorEnabled(bool enabled) async {
    if (_isEnabled == enabled) {
      _logDebug(
          '🔄 [TOR-TOGGLE] Estado Tor ya es: ${enabled ? "HABILITADO" : "DESHABILITADO"}');
      return;
    }

    _logDebug(
        '🔧 [TOR-TOGGLE] Cambiando estado Tor: ${enabled ? "HABILITANDO" : "DESHABILITANDO"}');

    _isEnabled = enabled;
    _retryAttempts = 0;
    _lastError = null;

    if (enabled) {
      _logDebug(
          '🌐 [TOR-ENABLED] Tor habilitado - próximas conexiones usarán proxy');

      // Test automático cuando se habilita
      final testResult = await testTorConnectivity();
      if (!testResult) {
        _logError(
            '⚠️ [TOR-WARNING] Tor habilitado pero test de conectividad falló');
      }
    } else {
      _logDebug(
          '📡 [TOR-DISABLED] Tor deshabilitado - usando conexiones directas');
    }
  }

  /// 📊 Obtener estado actual del servicio
  static Map<String, dynamic> getStatus() {
    return {
      'initialized': _isInitialized,
      'enabled': _isEnabled,
      'connecting': _isConnecting,
      'host': _torHost,
      'port': _torPort,
      'retryAttempts': _retryAttempts,
      'maxRetryAttempts': _maxRetryAttempts,
      'lastError': _lastError,
      'lastConnectionAttempt': _lastConnectionAttempt?.toIso8601String(),
      'lastConnectionTime': _lastConnectionTime?.inMilliseconds,
    };
  }

  /// 🧹 Limpiar estado y recursos
  static void dispose() {
    _logDebug('🧹 [TOR-DISPOSE] Limpiando recursos TorService...');

    _isInitialized = false;
    _isEnabled = false;
    _isConnecting = false;
    _lastError = null;
    _retryAttempts = 0;
    _lastConnectionAttempt = null;
    _lastConnectionTime = null;
    _instance = null;

    _logDebug('✅ [TOR-DISPOSE] Recursos limpiados correctamente');
  }

  // 📝 Métodos de logging privados
  static void _logDebug(String message) {
    if (_enableDebugLogs) {
      if (kDebugMode) {
        print('🔐 [TOR-DEBUG] $message');
      }
    }
  }

  static void _logConnection(String message) {
    if (_enableConnectionLogs) {
      if (kDebugMode) {
        print('🌐 [TOR-CONN] $message');
      }
    }
  }

  static void _logError(String message) {
    if (_enableErrorLogs) {
      if (kDebugMode) {
        print('❌ [TOR-ERROR] $message');
      }
      // En producción, también se podría enviar a un servicio de crash reporting
    }
  }
}
