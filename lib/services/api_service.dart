import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // URL base de la API - ACTUALIZADA PARA VPS CON NGINX Y SESIONES ACTIVAS
  // static const String baseUrl = 'http://10.0.2.2:3000'; // Para emulador Android
  // static const String baseUrl = 'http://localhost:3000'; // Para iOS simulator
  // static const String baseUrl = 'http://192.142.10.106:3001'; // VPS directo (sin nginx)

  // ✅ CONFIGURACIÓN CORRECTA CON NGINX
  static const String baseUrl =
      'https://clubprivado.ws'; // Nginx proxy a backend-api-1 (puerto 3001)

  // 🔍 CONFIGURACIÓN DE DEBUG
  static const bool enableDebugLogs = false;
  static const bool enableSessionsDebug = false;

  // Nginx maneja el proxy:
  // /api/* → localhost:3001 (backend-api-1 con sesiones activas)
  // Los endpoints de sesiones están disponibles en /api/sessions/*

  // Cabeceras HTTP por defecto
  static Map<String, String> _getHeaders(String? token) {
    final headers = {
      'Content-Type': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      // ACTUALIZADO: Usar Authorization Bearer en lugar de x-auth-token para sesiones
      headers['Authorization'] = 'Bearer $token';
      if (enableSessionsDebug) {
        print('🔐 [API-DEBUG] Token configurado: ${token.substring(0, 20)}...');
      }
    }

    if (enableDebugLogs) {
      print('🌐 [API-DEBUG] Headers configurados: $headers');
    }

    return headers;
  }

  // Validar y procesar respuesta JSON
  static dynamic _parseResponse(http.Response response) {
    if (enableDebugLogs) {
      print('🌐 [API-DEBUG] Status: ${response.statusCode}');
      print('🌐 [API-DEBUG] Response body: ${response.body}');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      print('❌ [API-ERROR] HTTP ${response.statusCode}: ${response.body}');
      throw Exception('Error HTTP: ${response.statusCode}');
    }

    // Manejar respuestas vacías explícitamente
    if (response.body.isEmpty) {
      print('⚠️ [API-WARNING] Respuesta vacía del servidor');
      // Devuelve un mapa vacío en lugar de lanzar una excepción
      return {};
    }

    try {
      final data = jsonDecode(response.body);
      if (enableDebugLogs) {
        print('✅ [API-DEBUG] JSON decodificado correctamente');
      }
      return data;
    } catch (e) {
      print(
          '❌ [API-ERROR] Error al decodificar respuesta JSON: $e. Contenido: ${response.body}');
      throw Exception('Error al decodificar respuesta JSON: $e');
    }
  }

  // GET request
  static Future<http.Response> get(String endpoint, [String? token]) async {
    if (endpoint.isEmpty) {
      throw Exception('Endpoint no puede ser nulo o vacío');
    }

    // 🔍 MEJORADO: Procesar endpoints de sesiones activas
    if (endpoint.startsWith('/sessions/') || endpoint.startsWith('sessions/')) {
      endpoint =
          endpoint.replaceFirst(RegExp('^/?sessions/'), '/api/sessions/');
      if (enableSessionsDebug) {
        print('🔐 [SESSIONS-DEBUG] Endpoint de sesiones corregido: $endpoint');
      }
    }

    // Asegurar que los endpoints de auth tengan el prefijo /api si no lo tienen
    if (endpoint.startsWith('/auth/') || endpoint.startsWith('auth/')) {
      endpoint = endpoint.replaceFirst(RegExp('^/?auth/'), '/api/auth/');
    }

    final url = Uri.parse('$baseUrl$endpoint');

    if (enableDebugLogs) {
      print('🌐 [API-DEBUG] GET Request: $url');
    }

    try {
      final response = await http.get(
        url,
        headers: _getHeaders(token),
      );

      if (enableSessionsDebug && endpoint.contains('/api/sessions/')) {
        print(
            '🔐 [SESSIONS-DEBUG] GET Response Status: ${response.statusCode}');
        print('🔐 [SESSIONS-DEBUG] GET Response Body: ${response.body}');
      }

      return response;
    } catch (e) {
      print('❌ [API-ERROR] Error de conexión en GET $endpoint: $e');
      throw Exception('Error de conexión en GET $endpoint: $e');
    }
  }

  // POST request
  static Future<http.Response> post(String endpoint, dynamic data,
      [String? token]) async {
    if (endpoint.isEmpty) {
      throw Exception('Endpoint no puede ser nulo o vacío');
    }

    if (data == null) {
      throw Exception('Datos no pueden ser nulos');
    }

    // 🔍 MEJORADO: Procesar endpoints de sesiones activas
    if (endpoint.startsWith('/sessions/') || endpoint.startsWith('sessions/')) {
      endpoint =
          endpoint.replaceFirst(RegExp('^/?sessions/'), '/api/sessions/');
      if (enableSessionsDebug) {
        print('🔐 [SESSIONS-DEBUG] Endpoint de sesiones corregido: $endpoint');
      }
    }

    // Asegurar que los endpoints de auth tengan el prefijo /api si no lo tienen
    if (endpoint.startsWith('/auth/') || endpoint.startsWith('auth/')) {
      endpoint = endpoint.replaceFirst(RegExp('^/?auth/'), '/api/auth/');
    }

    final url = Uri.parse('$baseUrl$endpoint');

    if (enableDebugLogs) {
      print('🌐 [API-DEBUG] POST Request: $url');
      print('🌐 [API-DEBUG] POST Data: $data');
    }

    try {
      final jsonData = jsonEncode(data);
      final response = await http.post(
        url,
        headers: _getHeaders(token),
        body: jsonData,
      );

      if (enableSessionsDebug && endpoint.contains('/api/sessions/')) {
        print(
            '🔐 [SESSIONS-DEBUG] POST Response Status: ${response.statusCode}');
        print('🔐 [SESSIONS-DEBUG] POST Response Body: ${response.body}');
      }

      return response;
    } catch (e) {
      if (e is FormatException) {
        print('❌ [API-ERROR] Error de formato JSON: $e');
        throw Exception('Error de formato JSON: $e');
      }
      print('❌ [API-ERROR] Error de conexión en POST $endpoint: $e');
      throw Exception('Error de conexión en POST $endpoint: $e');
    }
  }

  // PUT request
  static Future<http.Response> put(String endpoint, dynamic data,
      [String? token]) async {
    if (endpoint.isEmpty) {
      throw Exception('Endpoint no puede ser nulo o vacío');
    }

    if (data == null) {
      throw Exception('Datos no pueden ser nulos');
    }

    // 🔍 MEJORADO: Procesar endpoints de sesiones activas
    if (endpoint.startsWith('/sessions/') || endpoint.startsWith('sessions/')) {
      endpoint =
          endpoint.replaceFirst(RegExp('^/?sessions/'), '/api/sessions/');
      if (enableSessionsDebug) {
        print('🔐 [SESSIONS-DEBUG] Endpoint de sesiones corregido: $endpoint');
      }
    }

    // Asegurar que los endpoints de auth tengan el prefijo /api si no lo tienen
    if (endpoint.startsWith('/auth/') || endpoint.startsWith('auth/')) {
      endpoint = endpoint.replaceFirst(RegExp('^/?auth/'), '/api/auth/');
    }

    final url = Uri.parse('$baseUrl$endpoint');

    if (enableDebugLogs) {
      print('🌐 [API-DEBUG] PUT Request: $url');
      print('🌐 [API-DEBUG] PUT Data: $data');
    }

    try {
      final jsonData = jsonEncode(data);
      final response = await http.put(
        url,
        headers: _getHeaders(token),
        body: jsonData,
      );

      if (enableSessionsDebug && endpoint.contains('/api/sessions/')) {
        print(
            '🔐 [SESSIONS-DEBUG] PUT Response Status: ${response.statusCode}');
        print('🔐 [SESSIONS-DEBUG] PUT Response Body: ${response.body}');
      }

      return response;
    } catch (e) {
      if (e is FormatException) {
        print('❌ [API-ERROR] Error de formato JSON: $e');
        throw Exception('Error de formato JSON: $e');
      }
      print('❌ [API-ERROR] Error de conexión en PUT $endpoint: $e');
      throw Exception('Error de conexión en PUT $endpoint: $e');
    }
  }

  // DELETE request
  static Future<http.Response> delete(String endpoint, [String? token]) async {
    if (endpoint.isEmpty) {
      throw Exception('Endpoint no puede ser nulo o vacío');
    }

    // 🔍 MEJORADO: Procesar endpoints de sesiones activas
    if (endpoint.startsWith('/sessions/') || endpoint.startsWith('sessions/')) {
      endpoint =
          endpoint.replaceFirst(RegExp('^/?sessions/'), '/api/sessions/');
      if (enableSessionsDebug) {
        print('🔐 [SESSIONS-DEBUG] Endpoint de sesiones corregido: $endpoint');
      }
    }

    // Asegurar que los endpoints de auth tengan el prefijo /api si no lo tienen
    if (endpoint.startsWith('/auth/') || endpoint.startsWith('auth/')) {
      endpoint = endpoint.replaceFirst(RegExp('^/?auth/'), '/api/auth/');
    }

    final url = Uri.parse('$baseUrl$endpoint');

    if (enableDebugLogs) {
      print('🌐 [API-DEBUG] DELETE Request: $url');
    }

    try {
      final response = await http.delete(
        url,
        headers: _getHeaders(token),
      );

      if (enableSessionsDebug && endpoint.contains('/api/sessions/')) {
        print(
            '🔐 [SESSIONS-DEBUG] DELETE Response Status: ${response.statusCode}');
        print('🔐 [SESSIONS-DEBUG] DELETE Response Body: ${response.body}');
      }

      return response;
    } catch (e) {
      print('❌ [API-ERROR] Error de conexión en DELETE $endpoint: $e');
      throw Exception('Error de conexión en DELETE $endpoint: $e');
    }
  }

  // Método para obtener directamente datos procesados como Map (para llamadas)
  static Future<Map<String, dynamic>> postAndGetMap(
      String endpoint, dynamic data,
      [String? token]) async {
    final response = await post(endpoint, data, token);

    // Validar el código de estado HTTP
    if (response.statusCode < 200 || response.statusCode >= 300) {
      print(
          '❌ [API-ERROR] postAndGetMap ${response.statusCode}: ${response.body}');
      throw Exception('API ${response.statusCode}: ${response.body}');
    }

    // Manejar respuestas de estado éxito sin contenido (204, 205)
    if (response.statusCode == 204 || response.statusCode == 205) {
      print(
          '✅ [API-DEBUG] Respuesta con código ${response.statusCode} sin contenido');
      return {'success': true};
    }

    // Verificar si la respuesta está vacía
    if (response.body.isEmpty) {
      print('⚠️ [API-WARNING] Respuesta vacía del servidor');
      return {'success': true};
    }

    try {
      // Imprimir contenido para depuración
      if (enableDebugLogs) {
        print('✅ [API-DEBUG] Contenido respuesta API: ${response.body}');
      }

      final jsonData = jsonDecode(response.body);

      // Validar explícitamente que el resultado sea un Map<String, dynamic>
      if (jsonData == null) {
        print('⚠️ [API-WARNING] La respuesta se decodificó como null');
        return {'success': true};
      } else if (jsonData is! Map<String, dynamic>) {
        print(
            '⚠️ [API-WARNING] Respuesta no es Map<String,dynamic> sino ${jsonData.runtimeType}');
        // Convertir cualquier tipo de respuesta a un Map seguro
        if (jsonData is Map) {
          // Intentar convertir un Map genérico a Map<String, dynamic>
          final Map<String, dynamic> safeMap = {};
          jsonData.forEach((key, value) {
            if (key is String) {
              safeMap[key] = value;
            }
          });
          return safeMap;
        } else {
          // Si no es un Map, devolvemos un mapa con la respuesta original
          return {'data': jsonData, 'success': true};
        }
      }

      return jsonData;
    } catch (e) {
      if (e is FormatException) {
        print(
            '❌ [API-ERROR] Error al decodificar respuesta JSON: $e. Contenido: ${response.body}');
        throw Exception('Error al decodificar respuesta JSON: $e');
      }
      rethrow;
    }
  }

  // 🔍 NUEVO: Método específico para endpoints de sesiones activas
  static Future<Map<String, dynamic>> sessionsRequest(
    String method,
    String sessionEndpoint, {
    Map<String, dynamic>? data,
    String? token,
    String? sessionId,
  }) async {
    if (enableSessionsDebug) {
      print('🔐 [SESSIONS-API] === SESSIONS REQUEST ===');
      print('🔐 [SESSIONS-API] Método: $method');
      print('🔐 [SESSIONS-API] Endpoint: $sessionEndpoint');
      print('🔐 [SESSIONS-API] Data: $data');
      print('🔐 [SESSIONS-API] Base URL: $baseUrl');
      if (sessionId != null) {
        print('🔐 [SESSIONS-API] Session ID: ${sessionId.substring(0, 8)}...');
      }
    }

    final fullEndpoint = '/api/sessions$sessionEndpoint';

    try {
      http.Response response;

      Map<String, String> headers = _getHeaders(token);
      if (sessionId != null) {
        headers['X-Session-ID'] = sessionId;
      }

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(
            Uri.parse('$baseUrl$fullEndpoint'),
            headers: headers,
          );
          break;
        case 'POST':
          response = await http.post(
            Uri.parse('$baseUrl$fullEndpoint'),
            headers: headers,
            body: jsonEncode(data ?? {}),
          );
          break;
        case 'PUT':
          response = await http.put(
            Uri.parse('$baseUrl$fullEndpoint'),
            headers: headers,
            body: jsonEncode(data ?? {}),
          );
          break;
        case 'DELETE':
          response = await http.delete(
            Uri.parse('$baseUrl$fullEndpoint'),
            headers: headers,
          );
          break;
        default:
          throw Exception('Método HTTP no soportado: $method');
      }

      if (enableSessionsDebug) {
        print('🔐 [SESSIONS-API] Status: ${response.statusCode}');
        print('🔐 [SESSIONS-API] Response: ${response.body}');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) {
          return {'success': true};
        }
        final jsonData = jsonDecode(response.body);
        return jsonData is Map<String, dynamic>
            ? jsonData
            : {'data': jsonData, 'success': true};
      } else {
        throw Exception('Error HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ [SESSIONS-API] Error en sessionsRequest: $e');
      rethrow;
    }
  }
}
