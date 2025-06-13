import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutterputter/services/tor_service.dart';

/// 🏭 TorHttpClientFactory - Factory para HttpClient con soporte Tor
///
/// Este factory permite integrar Tor con el sistema existente sin modificar
/// ApiService o cualquier otro código existente
///
/// CRÍTICO: Mantiene compatibilidad 100% con código existente
class TorHttpClientFactory {
  static bool _enableDebugLogs = true;

  /// 🌐 Crear HttpClient configurado según configuración Tor
  ///
  /// Retorna:
  /// - HttpClient con proxy Tor si está habilitado
  /// - HttpClient normal si Tor está deshabilitado
  /// - HttpClient normal como fallback en caso de error
  static Future<HttpClient> createClient() async {
    _logDebug('🏭 [TOR-FACTORY] Creando HttpClient...');

    try {
      final client = await TorService.createHttpClient();
      _logDebug('✅ [TOR-FACTORY] HttpClient creado exitosamente');
      return client;
    } catch (e) {
      _logError('❌ [TOR-FACTORY-ERROR] Error creando HttpClient: $e');

      // FALLBACK SEGURO: Siempre retornar un cliente funcional
      _logDebug('🔄 [TOR-FACTORY-FALLBACK] Usando HttpClient estándar');
      return HttpClient()..connectionTimeout = Duration(seconds: 30);
    }
  }

  /// 🧪 Verificar si Tor está disponible y funcionando
  static Future<bool> isTorAvailable() async {
    try {
      return await TorService.testTorConnectivity();
    } catch (e) {
      _logError('❌ [TOR-FACTORY-AVAILABILITY] Error verificando Tor: $e');
      return false;
    }
  }

  /// 📊 Obtener información del estado actual
  static Map<String, dynamic> getStatus() {
    return {
      'factory': 'TorHttpClientFactory',
      'torService': TorService.getStatus(),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  // 📝 Métodos de logging privados
  static void _logDebug(String message) {
    if (_enableDebugLogs && kDebugMode) {
      print('🏭 [TOR-FACTORY] $message');
    }
  }

  static void _logError(String message) {
    if (kDebugMode) {
      print('❌ [TOR-FACTORY-ERROR] $message');
    }
  }
}
