import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'ntfy_subscription_service.dart';

/// Implementación específica para móvil usando polling HTTP optimizado
class NtfySubscriptionMobile implements NtfySubscriptionPlatform {
  String? _serverUrl;
  Function(String topicType, Map<String, dynamic> data)?
      _onNotificationReceived;

  // Timer único para polling secuencial
  Timer? _pollingTimer;
  final Map<String, String> _lastMessageIds = {};

  // Configuración de polling optimizada
  static const Duration _basePollingInterval =
      Duration(seconds: 15); // Reducido de 5s a 15s
  static const Duration _maxPollingInterval = Duration(minutes: 5);
  Duration _currentInterval = _basePollingInterval;

  // Platform channel para iOS background tasks
  static const _backgroundChannel = MethodChannel('background_ntfy');

  // Topics a consultar secuencialmente
  List<MapEntry<String, String>> _topicsToCheck = [];
  int _currentTopicIndex = 0;

  // Control de errores y backoff
  int _consecutiveErrors = 0;
  bool _disposed = false;
  bool _isPolling = false;

  @override
  Future<void> initialize({
    required String serverUrl,
    required Function(String topicType, Map<String, dynamic> data)
        onNotificationReceived,
  }) async {
    _serverUrl = serverUrl;
    _onNotificationReceived = onNotificationReceived;
    _disposed = false;
    _consecutiveErrors = 0;
    _currentInterval = _basePollingInterval;
  }

  @override
  Future<void> subscribeToTopics(Map<String, String> topics) async {
    // Almacenar topics para polling secuencial
    _topicsToCheck = topics.entries.toList();
    _currentTopicIndex = 0;

    // Inicializar IDs de último mensaje
    for (final entry in topics.entries) {
      _lastMessageIds[entry.key] = '';
    }

    // Iniciar polling secuencial optimizado
    _startOptimizedPolling();
  }

  /// Iniciar polling secuencial optimizado
  void _startOptimizedPolling() {
    _pollingTimer?.cancel();

    if (_disposed || _topicsToCheck.isEmpty) return;

    // En iOS, usar Background App Refresh para mejor confiabilidad
    if (Platform.isIOS) {
      _startIOSBackgroundPolling();
    } else {
      // Android: usar Timer normal
      _pollingTimer = Timer.periodic(_currentInterval, (timer) {
        if (_disposed) {
          timer.cancel();
          return;
        }
        _pollNextTopic();
      });
    }

    // Hacer primera consulta inmediatamente
    _pollNextTopic();
  }

  /// Iniciar polling usando Background App Refresh en iOS
  void _startIOSBackgroundPolling() {
    try {
      // Registrar background task
      _backgroundChannel.invokeMethod('startBackgroundPolling', {
        'interval': _currentInterval.inSeconds,
        'topics': _topicsToCheck.map((e) => e.value).toList(),
      });

      // Configurar listener para cuando el background task se ejecute
      _backgroundChannel.setMethodCallHandler((call) async {
        if (call.method == 'performBackgroundPoll' && !_disposed) {
          await _pollNextTopic();
        }
      });

      // Mantener también un timer ligero como fallback
      _pollingTimer = Timer.periodic(_currentInterval, (timer) {
        if (_disposed) {
          timer.cancel();
          return;
        }
        _pollNextTopic();
      });
    } catch (e) {
      // Fallback a timer normal si falla
      _pollingTimer = Timer.periodic(_currentInterval, (timer) {
        if (_disposed) {
          timer.cancel();
          return;
        }
        _pollNextTopic();
      });
    }
  }

  /// Hacer polling al siguiente topic en la secuencia
  Future<void> _pollNextTopic() async {
    if (_disposed || _topicsToCheck.isEmpty || _isPolling) return;

    _isPolling = true;

    try {
      final entry = _topicsToCheck[_currentTopicIndex];
      final topicType = entry.key;
      final topicName = entry.value;

      await _pollTopic(topicType, topicName);

      // Avanzar al siguiente topic
      _currentTopicIndex = (_currentTopicIndex + 1) % _topicsToCheck.length;
    } finally {
      _isPolling = false;
    }
  }

  /// Hacer polling a un topic específico
  Future<void> _pollTopic(String topicType, String topicName) async {
    try {
      final url = '$_serverUrl/$topicName/json?poll=1';
      final client = HttpClient();

      // Configurar timeout del cliente
      client.connectionTimeout = const Duration(seconds: 15);

      final request = await client.getUrl(Uri.parse(url));

      // Configurar headers
      request.headers.add('Accept', 'application/json');
      request.headers.add('User-Agent', 'FlutterApp/1.0');

      final response = await request.close();

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        await _processPollingResponse(topicType, responseBody);

        // Reset error counter en éxito
        _onPollingSuccess();
      } else if (response.statusCode == 429) {
        _onRateLimitError();
      } else {
        _onPollingError();
      }

      client.close();
    } catch (e) {
      _onPollingError();
    }
  }

  /// Manejar éxito en polling
  void _onPollingSuccess() {
    if (_consecutiveErrors > 0) {
      _consecutiveErrors = 0;
      _currentInterval = _basePollingInterval;
      _restartPollingWithNewInterval();
    }
  }

  /// Manejar error de rate limit (429)
  void _onRateLimitError() {
    _consecutiveErrors++;

    // Backoff exponencial para rate limiting
    final backoffSeconds =
        min(300, 30 * pow(2, _consecutiveErrors - 1)); // Max 5 minutos
    _currentInterval = Duration(seconds: backoffSeconds.toInt());

    _restartPollingWithNewInterval();
  }

  /// Manejar otros errores de polling
  void _onPollingError() {
    _consecutiveErrors++;

    // Backoff lineal para otros errores
    final backoffSeconds =
        min(120, 15 + (_consecutiveErrors * 10)); // Max 2 minutos
    _currentInterval = Duration(seconds: backoffSeconds);

    _restartPollingWithNewInterval();
  }

  /// Reiniciar polling con nuevo intervalo
  void _restartPollingWithNewInterval() {
    _pollingTimer?.cancel();

    if (!_disposed) {
      _startOptimizedPolling();
    }
  }

  /// Procesar respuesta del polling
  Future<void> _processPollingResponse(
      String topicType, String responseBody) async {
    try {
      // ntfy puede devolver múltiples líneas JSON
      final lines = responseBody.trim().split('\n');

      for (final line in lines) {
        if (line.isEmpty) continue;

        try {
          final data = jsonDecode(line);
          final messageId = data['id']?.toString() ?? '';

          // Solo procesar mensajes nuevos
          if (messageId.isNotEmpty && messageId != _lastMessageIds[topicType]) {
            _lastMessageIds[topicType] = messageId;
            _onNotificationReceived?.call(topicType, data);
          }
        } catch (e) {
          // Error parseando línea JSON
        }
      }
    } catch (e) {
      // Error procesando respuesta de polling
    }
  }

  @override
  Future<void> unsubscribeFromAllTopics() async {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _topicsToCheck.clear();
    _lastMessageIds.clear();
    _currentTopicIndex = 0;
    _consecutiveErrors = 0;
    _currentInterval = _basePollingInterval;
  }

  @override
  bool isSubscribedToTopic(String topicType) {
    return _topicsToCheck.any((entry) => entry.key == topicType) &&
        _pollingTimer != null &&
        _pollingTimer!.isActive;
  }

  @override
  Map<String, dynamic> getServiceInfo() {
    return {
      'implementation': 'mobile',
      'activeTopics': _topicsToCheck.map((e) => e.key).toList(),
      'connectionCount': _topicsToCheck.length,
      'method': 'Sequential HTTP Polling',
      'currentInterval': '${_currentInterval.inSeconds}s',
      'consecutiveErrors': _consecutiveErrors,
      'currentTopicIndex': _currentTopicIndex,
      'lastMessageIds': Map.from(_lastMessageIds),
      'isPolling': _isPolling,
    };
  }

  @override
  void dispose() {
    _disposed = true;
    unsubscribeFromAllTopics();
    _serverUrl = null;
    _onNotificationReceived = null;
  }
}

/// Factory function para crear la implementación móvil
NtfySubscriptionPlatform createNtfySubscriptionPlatform() {
  return NtfySubscriptionMobile();
}
