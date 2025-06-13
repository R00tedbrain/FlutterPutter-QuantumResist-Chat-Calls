import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutterputter/services/tor_service.dart';
import 'package:flutterputter/services/tor_configuration_service.dart';
import 'package:flutterputter/services/tor_http_client_factory.dart';

/// 🔗 TorApiIntegration - Integración transparente de Tor con ApiService
///
/// Este servicio proporciona métodos que pueden usarse como reemplazo
/// directo de las llamadas HTTP del ApiService cuando se necesite Tor
///
/// CRÍTICO:
/// - NO modifica el ApiService existente
/// - Mantiene 100% compatibilidad con la API actual
/// - Proporciona fallback automático en caso de error
/// - Logs extensivos para debugging
class TorApiIntegration {
  static bool _enableDebugLogs = true;

  // URL base - debe coincidir con ApiService
  static const String baseUrl = 'https://clubprivado.ws';

  /// 🌐 GET request con soporte Tor
  ///
  /// Funciona exactamente igual que ApiService.get() pero con Tor
  /// Retorna la misma respuesta para mantener compatibilidad
  static Future<http.Response> get(String endpoint, [String? token]) async {
    _logDebug('🌐 [TOR-API-GET] Endpoint: $endpoint');

    try {
      // 🚨 VERIFICAR PLATAFORMA WEB
      if (kIsWeb) {
        _logDebug(
            '📡 [TOR-API-GET] Tor deshabilitado, usando http estándar (web)');
        return await _standardHttpGet(endpoint, token);
      }

      // 🚨 VERIFICAR PLATAFORMA iOS
      if (!kIsWeb && Platform.isIOS) {
        _logDebug('📱 [TOR-API-GET] iOS detectado - Tor nativo no disponible');
        _logDebug(
            '🔒 [TOR-API-GET] Usando HTTPS directo (iOS no permite daemons Tor)');
        return await _standardHttpGet(endpoint, token);
      }

      // Verificar si Tor está habilitado
      final isTorEnabled = await TorConfigurationService.isTorEnabled();

      if (!isTorEnabled) {
        _logDebug('📡 [TOR-API-GET] Tor deshabilitado, usando http estándar');
        return await _standardHttpGet(endpoint, token);
      }

      _logDebug('🔒 [TOR-API-GET] Usando conexión Tor para máxima anonimidad');
      return await _torHttpGet(endpoint, token);
    } catch (e) {
      _logError('❌ [TOR-API-GET] Error: $e');

      // FALLBACK SEGURO: Usar HTTP estándar en caso de error
      _logDebug('🔄 [TOR-API-GET] Fallback a HTTP estándar');
      return await _standardHttpGet(endpoint, token);
    }
  }

  /// 🌐 POST request con soporte Tor
  static Future<http.Response> post(String endpoint, dynamic data,
      [String? token]) async {
    _logDebug('🌐 [TOR-API-POST] Endpoint: $endpoint');

    try {
      // 🚨 VERIFICAR PLATAFORMA WEB
      if (kIsWeb) {
        _logDebug(
            '📡 [TOR-API-POST] Tor deshabilitado, usando http estándar (web)');
        return await _standardHttpPost(endpoint, data, token);
      }

      // 🚨 VERIFICAR PLATAFORMA iOS
      if (!kIsWeb && Platform.isIOS) {
        _logDebug('📱 [TOR-API-POST] iOS detectado - Tor nativo no disponible');
        _logDebug(
            '🔒 [TOR-API-POST] Usando HTTPS directo (iOS no permite daemons Tor)');
        return await _standardHttpPost(endpoint, data, token);
      }

      final isTorEnabled = await TorConfigurationService.isTorEnabled();

      if (!isTorEnabled) {
        _logDebug('📡 [TOR-API-POST] Tor deshabilitado, usando http estándar');
        return await _standardHttpPost(endpoint, data, token);
      }

      _logDebug('🔒 [TOR-API-POST] Usando conexión Tor para máxima anonimidad');
      return await _torHttpPost(endpoint, data, token);
    } catch (e) {
      _logError('❌ [TOR-API-POST] Error: $e');

      // FALLBACK SEGURO
      _logDebug('🔄 [TOR-API-POST] Fallback a HTTP estándar');
      return await _standardHttpPost(endpoint, data, token);
    }
  }

  /// 🌐 PUT request con soporte Tor
  static Future<http.Response> put(String endpoint, dynamic data,
      [String? token]) async {
    _logDebug('🌐 [TOR-API-PUT] Endpoint: $endpoint');

    try {
      final isTorEnabled = await TorConfigurationService.isTorEnabled();

      if (!isTorEnabled) {
        _logDebug('📡 [TOR-API-PUT] Tor deshabilitado, usando http estándar');
        return await _standardHttpPut(endpoint, data, token);
      }

      return await _torHttpPut(endpoint, data, token);
    } catch (e) {
      _logError('❌ [TOR-API-PUT] Error: $e');

      // FALLBACK SEGURO
      _logDebug('🔄 [TOR-API-PUT] Fallback a HTTP estándar');
      return await _standardHttpPut(endpoint, data, token);
    }
  }

  /// 🌐 DELETE request con soporte Tor
  static Future<http.Response> delete(String endpoint, [String? token]) async {
    _logDebug('🌐 [TOR-API-DELETE] Endpoint: $endpoint');

    try {
      final isTorEnabled = await TorConfigurationService.isTorEnabled();

      if (!isTorEnabled) {
        _logDebug(
            '📡 [TOR-API-DELETE] Tor deshabilitado, usando http estándar');
        return await _standardHttpDelete(endpoint, token);
      }

      return await _torHttpDelete(endpoint, token);
    } catch (e) {
      _logError('❌ [TOR-API-DELETE] Error: $e');

      // FALLBACK SEGURO
      _logDebug('🔄 [TOR-API-DELETE] Fallback a HTTP estándar');
      return await _standardHttpDelete(endpoint, token);
    }
  }

  // 🔒 Métodos HTTP con Tor (privados)

  static Future<http.Response> _torHttpGet(
      String endpoint, String? token) async {
    _logDebug('🔒 [TOR-HTTP-GET] Usando Tor para: $endpoint');

    final client = await TorHttpClientFactory.createClient();

    try {
      final headers = _getHeaders(token);
      final url = Uri.parse('$baseUrl${_processEndpoint(endpoint)}');

      _logDebug('🌐 [TOR-HTTP-GET] URL: $url');

      final request = await client.getUrl(url);

      // Agregar headers
      headers.forEach((key, value) {
        request.headers.add(key, value);
      });

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      // Convertir HttpClientResponse a http.Response para compatibilidad
      final Map<String, String> responseHeaders = {};
      response.headers.forEach((name, values) {
        responseHeaders[name] = values.join(', ');
      });

      return http.Response(
        responseBody,
        response.statusCode,
        headers: responseHeaders,
      );
    } finally {
      client.close();
    }
  }

  static Future<http.Response> _torHttpPost(
      String endpoint, dynamic data, String? token) async {
    _logDebug('🔒 [TOR-HTTP-POST] Usando Tor para: $endpoint');

    final client = await TorHttpClientFactory.createClient();

    try {
      final headers = _getHeaders(token);
      final url = Uri.parse('$baseUrl${_processEndpoint(endpoint)}');
      final jsonData = jsonEncode(data);

      _logDebug('🌐 [TOR-HTTP-POST] URL: $url');

      final request = await client.postUrl(url);

      // Agregar headers
      headers.forEach((key, value) {
        request.headers.add(key, value);
      });

      // Agregar body
      request.write(jsonData);

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      final Map<String, String> responseHeaders = {};
      response.headers.forEach((name, values) {
        responseHeaders[name] = values.join(', ');
      });

      return http.Response(
        responseBody,
        response.statusCode,
        headers: responseHeaders,
      );
    } finally {
      client.close();
    }
  }

  static Future<http.Response> _torHttpPut(
      String endpoint, dynamic data, String? token) async {
    _logDebug('🔒 [TOR-HTTP-PUT] Usando Tor para: $endpoint');

    final client = await TorHttpClientFactory.createClient();

    try {
      final headers = _getHeaders(token);
      final url = Uri.parse('$baseUrl${_processEndpoint(endpoint)}');
      final jsonData = jsonEncode(data);

      final request = await client.putUrl(url);

      headers.forEach((key, value) {
        request.headers.add(key, value);
      });

      request.write(jsonData);

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      final Map<String, String> responseHeaders = {};
      response.headers.forEach((name, values) {
        responseHeaders[name] = values.join(', ');
      });

      return http.Response(
        responseBody,
        response.statusCode,
        headers: responseHeaders,
      );
    } finally {
      client.close();
    }
  }

  static Future<http.Response> _torHttpDelete(
      String endpoint, String? token) async {
    _logDebug('🔒 [TOR-HTTP-DELETE] Usando Tor para: $endpoint');

    final client = await TorHttpClientFactory.createClient();

    try {
      final headers = _getHeaders(token);
      final url = Uri.parse('$baseUrl${_processEndpoint(endpoint)}');

      final request = await client.deleteUrl(url);

      headers.forEach((key, value) {
        request.headers.add(key, value);
      });

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      final Map<String, String> responseHeaders = {};
      response.headers.forEach((name, values) {
        responseHeaders[name] = values.join(', ');
      });

      return http.Response(
        responseBody,
        response.statusCode,
        headers: responseHeaders,
      );
    } finally {
      client.close();
    }
  }

  // 📡 Métodos HTTP estándar (fallback)

  static Future<http.Response> _standardHttpGet(
      String endpoint, String? token) async {
    final url = Uri.parse('$baseUrl${_processEndpoint(endpoint)}');
    return await http.get(url, headers: _getHeaders(token));
  }

  static Future<http.Response> _standardHttpPost(
      String endpoint, dynamic data, String? token) async {
    final url = Uri.parse('$baseUrl${_processEndpoint(endpoint)}');
    return await http.post(
      url,
      headers: _getHeaders(token),
      body: jsonEncode(data),
    );
  }

  static Future<http.Response> _standardHttpPut(
      String endpoint, dynamic data, String? token) async {
    final url = Uri.parse('$baseUrl${_processEndpoint(endpoint)}');
    return await http.put(
      url,
      headers: _getHeaders(token),
      body: jsonEncode(data),
    );
  }

  static Future<http.Response> _standardHttpDelete(
      String endpoint, String? token) async {
    final url = Uri.parse('$baseUrl${_processEndpoint(endpoint)}');
    return await http.delete(url, headers: _getHeaders(token));
  }

  // 🛠️ Métodos auxiliares (copiados de ApiService para compatibilidad)

  static Map<String, String> _getHeaders(String? token) {
    final headers = {
      'Content-Type': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  static String _processEndpoint(String endpoint) {
    // Procesar endpoints de sesiones activas
    if (endpoint.startsWith('/sessions/') || endpoint.startsWith('sessions/')) {
      return endpoint.replaceFirst(RegExp('^/?sessions/'), '/api/sessions/');
    }

    // Procesar endpoints de auth
    if (endpoint.startsWith('/auth/') || endpoint.startsWith('auth/')) {
      return endpoint.replaceFirst(RegExp('^/?auth/'), '/api/auth/');
    }

    return endpoint;
  }

  /// 📊 Método de utilidad para verificar estado Tor
  static Future<Map<String, dynamic>> getTorStatus() async {
    return {
      'torConfiguration': await TorConfigurationService.getConfiguration(),
      'torService': TorService.getStatus(),
      'httpFactory': TorHttpClientFactory.getStatus(),
    };
  }

  /// 🧪 Método de utilidad para test de conectividad
  static Future<bool> testTorConnectivity() async {
    return await TorConfigurationService.testTorConnection();
  }

  // 📝 Métodos de logging privados
  static void _logDebug(String message) {
    if (_enableDebugLogs && kDebugMode) {
      print('🔗 [TOR-API] $message');
    }
  }

  static void _logError(String message) {
    if (kDebugMode) {
      print('❌ [TOR-API-ERROR] $message');
    }
  }
}
