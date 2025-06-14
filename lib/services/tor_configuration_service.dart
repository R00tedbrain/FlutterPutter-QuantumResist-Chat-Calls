import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:flutterputter/services/tor_service.dart';

/// ⚙️ TorConfigurationService - Gestión de configuración Tor persistente CIFRADA
///
/// Maneja las preferencias del usuario para la red Tor CON CIFRADO:
/// - Habilitar/deshabilitar Tor (cifrado)
/// - Configuración personalizada de proxy (cifrada)
/// - Persistencia de configuración (cifrada)
/// - Configuración por primera vez
///
/// 🔐 SEGURIDAD: Usa EncryptedSharedPreferences para proteger datos sensibles
/// CRÍTICO: Respeta las decisiones del usuario y no fuerza el uso de Tor
class TorConfigurationService {
  static TorConfigurationService? _instance;
  static EncryptedSharedPreferences? _encryptedPrefs;

  // Claves para EncryptedSharedPreferences
  static const String _keyTorEnabled = 'tor_enabled_encrypted';
  static const String _keyTorHost = 'tor_host_encrypted';
  static const String _keyTorPort = 'tor_port_encrypted';
  static const String _keyTorSetupCompleted = 'tor_setup_completed_encrypted';

  // Valores por defecto
  static const String _defaultHost = '127.0.0.1';
  static const int _defaultPort = 9050;
  static const bool _defaultEnabled =
      true; // 🔒 SIEMPRE HABILITADO para anonimidad total
  static const bool _allowUserToDisable =
      false; // 🚫 NO permitir desactivar Tor

  // 📱 iOS: Tor deshabilitado por restricciones del sistema
  static bool get _isIOSDisabled => !kIsWeb && Platform.isIOS;

  // Debug logs
  static const bool _enableDebugLogs = true;

  /// Factory singleton
  factory TorConfigurationService() {
    _instance ??= TorConfigurationService._internal();
    return _instance!;
  }

  TorConfigurationService._internal();

  /// 🚀 Inicializar servicio de configuración CIFRADA
  static Future<void> initialize() async {
    _logDebug(
        '🚀 [TOR-CONFIG] Inicializando TorConfigurationService CIFRADO...');

    try {
      // Inicializar biblioteca cifrada con clave
      await EncryptedSharedPreferences.initialize(
          '9K8m2N7xP4eQ1wZ5'); // 16 caracteres aleatorios seguros
      _encryptedPrefs = EncryptedSharedPreferences.getInstance();

      // Cargar configuración guardada (cifrada)
      await _loadConfiguration();

      _logDebug('✅ [TOR-CONFIG] TorConfigurationService CIFRADO inicializado');
    } catch (e) {
      _logError('❌ [TOR-CONFIG-INIT] Error inicializando cifrado: $e');
    }
  }

  /// 📥 Cargar configuración desde EncryptedSharedPreferences
  static Future<void> _loadConfiguration() async {
    if (_encryptedPrefs == null) return;

    try {
      // 📱 iOS: Forzar Tor deshabilitado por restricciones del sistema
      final isEnabled = _isIOSDisabled
          ? false
          : (_encryptedPrefs!
                  .getBool(_keyTorEnabled, defaultValue: _defaultEnabled) ??
              _defaultEnabled);

      final host = _encryptedPrefs!.getString(_keyTorHost) ?? _defaultHost;
      final port =
          _encryptedPrefs!.getInt(_keyTorPort, defaultValue: _defaultPort) ??
              _defaultPort;

      _logDebug('📥 [TOR-CONFIG-LOAD] Cargando configuración CIFRADA:');
      if (_isIOSDisabled) {
        _logDebug(
            '   • iOS detectado: Tor DESHABILITADO (restricciones del sistema)');
      }
      _logDebug('   • Tor habilitado: $isEnabled');
      _logDebug('   • Host: $host');
      _logDebug('   • Puerto: $port');

      // Aplicar configuración al TorService
      await TorService.initialize(
        customTorHost: host,
        customTorPort: port,
        enableTor: isEnabled,
      );

      _logDebug(
          '✅ [TOR-CONFIG-LOAD] Configuración CIFRADA aplicada correctamente');
    } catch (e) {
      _logError('❌ [TOR-CONFIG-LOAD] Error cargando configuración cifrada: $e');
    }
  }

  /// ⚙️ Habilitar/deshabilitar Tor (cifrado)
  /// 🔒 CRÍTICO: Por seguridad, Tor NO se puede desactivar una vez habilitado
  static Future<bool> setTorEnabled(bool enabled) async {
    // 🚫 BLOQUEAR desactivación de Tor por seguridad
    if (!enabled && !_allowUserToDisable) {
      _logError(
          '🚫 [TOR-CONFIG-SECURITY] Tor NO se puede desactivar por seguridad');
      _logError(
          '🔒 [TOR-CONFIG-SECURITY] Una vez habilitado, Tor debe permanecer activo');
      return false;
    }

    _logDebug(
        '⚙️ [TOR-CONFIG-TOGGLE] ${enabled ? "Habilitando" : "Deshabilitando"} Tor...');

    try {
      // Aplicar al TorService primero
      await TorService.setTorEnabled(enabled);

      // Guardar en preferencias CIFRADAS
      if (_encryptedPrefs != null) {
        await _encryptedPrefs!.setBool(_keyTorEnabled, enabled);
        _logDebug('💾 [TOR-CONFIG-SAVE] Estado Tor guardado CIFRADO: $enabled');
      }

      return true;
    } catch (e) {
      _logError('❌ [TOR-CONFIG-TOGGLE] Error cambiando estado Tor: $e');
      return false;
    }
  }

  /// 🔧 Configurar host y puerto Tor personalizado (cifrado)
  static Future<bool> setTorProxy({
    required String host,
    required int port,
  }) async {
    _logDebug('🔧 [TOR-CONFIG-PROXY] Configurando proxy CIFRADO: $host:$port');

    try {
      // Validar parámetros
      if (host.isEmpty || port <= 0 || port > 65535) {
        _logError('❌ [TOR-CONFIG-PROXY] Parámetros inválidos: $host:$port');
        return false;
      }

      // Guardar en preferencias CIFRADAS
      if (_encryptedPrefs != null) {
        await _encryptedPrefs!.setString(_keyTorHost, host);
        await _encryptedPrefs!.setInt(_keyTorPort, port);

        _logDebug('💾 [TOR-CONFIG-PROXY] Configuración proxy guardada CIFRADA');

        // Reinicializar TorService con nueva configuración
        final currentlyEnabled = await isTorEnabled();
        await TorService.initialize(
          customTorHost: host,
          customTorPort: port,
          enableTor: currentlyEnabled,
        );

        _logDebug(
            '🔄 [TOR-CONFIG-PROXY] TorService reinicializado con nueva configuración');
      }

      return true;
    } catch (e) {
      _logError('❌ [TOR-CONFIG-PROXY] Error configurando proxy: $e');
      return false;
    }
  }

  /// 📋 Marcar setup inicial como completado (cifrado)
  static Future<void> markSetupCompleted() async {
    if (_encryptedPrefs != null) {
      await _encryptedPrefs!.setBool(_keyTorSetupCompleted, true);
      _logDebug(
          '✅ [TOR-CONFIG-SETUP] Setup inicial marcado como completado CIFRADO');
    }
  }

  /// ❓ Verificar si es la primera vez que se configura Tor
  static Future<bool> isFirstTimeSetup() async {
    if (_encryptedPrefs == null) return true;

    final isCompleted =
        _encryptedPrefs!.getBool(_keyTorSetupCompleted, defaultValue: false) ??
            false;
    return !isCompleted;
  }

  /// 📊 Obtener estado actual de configuración (cifrado)
  static Future<bool> isTorEnabled() async {
    // 📱 iOS: Siempre deshabilitado por restricciones del sistema
    if (_isIOSDisabled) return false;

    if (_encryptedPrefs == null) return _defaultEnabled;
    return _encryptedPrefs!
            .getBool(_keyTorEnabled, defaultValue: _defaultEnabled) ??
        _defaultEnabled;
  }

  static Future<String> getTorHost() async {
    if (_encryptedPrefs == null) return _defaultHost;
    return _encryptedPrefs!.getString(_keyTorHost) ?? _defaultHost;
  }

  static Future<int> getTorPort() async {
    if (_encryptedPrefs == null) return _defaultPort;
    return _encryptedPrefs!.getInt(_keyTorPort, defaultValue: _defaultPort) ??
        _defaultPort;
  }

  /// 📊 Obtener toda la configuración actual (desde almacenamiento cifrado)
  static Future<Map<String, dynamic>> getConfiguration() async {
    return {
      'enabled': await isTorEnabled(),
      'host': await getTorHost(),
      'port': await getTorPort(),
      'firstTimeSetup': await isFirstTimeSetup(),
      'torServiceStatus': TorService.getStatus(),
    };
  }

  /// 🧹 Resetear configuración a valores por defecto (cifrado)
  static Future<void> resetToDefaults() async {
    _logDebug(
        '🧹 [TOR-CONFIG-RESET] Reseteando configuración a valores por defecto...');

    try {
      if (_encryptedPrefs != null) {
        await _encryptedPrefs!.setBool(_keyTorEnabled, _defaultEnabled);
        await _encryptedPrefs!.setString(_keyTorHost, _defaultHost);
        await _encryptedPrefs!.setInt(_keyTorPort, _defaultPort);
        await _encryptedPrefs!.remove(_keyTorSetupCompleted);

        _logDebug('✅ [TOR-CONFIG-RESET] Configuración reseteada CIFRADA');

        // Reinicializar TorService con valores por defecto
        await TorService.initialize(
          customTorHost: _defaultHost,
          customTorPort: _defaultPort,
          enableTor: _defaultEnabled,
        );
      }
    } catch (e) {
      _logError('❌ [TOR-CONFIG-RESET] Error reseteando configuración: $e');
    }
  }

  /// 🧪 Test de conectividad Tor
  static Future<bool> testTorConnection() async {
    _logDebug('🧪 [TOR-CONFIG-TEST] Iniciando test de conectividad...');

    try {
      final result = await TorService.testTorConnectivity();

      if (result) {
        _logDebug('✅ [TOR-CONFIG-TEST] Test de conectividad exitoso');
      } else {
        _logDebug('❌ [TOR-CONFIG-TEST] Test de conectividad falló');
      }

      return result;
    } catch (e) {
      _logError('❌ [TOR-CONFIG-TEST] Error en test de conectividad: $e');
      return false;
    }
  }

  // 📝 Métodos de logging privados
  static void _logDebug(String message) {
    if (_enableDebugLogs && kDebugMode) {
      print('⚙️ [TOR-CONFIG] $message');
    }
  }

  static void _logError(String message) {
    if (kDebugMode) {
      print('❌ [TOR-CONFIG-ERROR] $message');
    }
  }
}
