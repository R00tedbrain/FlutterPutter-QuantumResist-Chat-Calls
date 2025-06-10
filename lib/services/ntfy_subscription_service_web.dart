import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'ntfy_subscription_service.dart';

/// Implementación específica para web usando EventSource
class NtfySubscriptionWeb implements NtfySubscriptionPlatform {
  String? _serverUrl;
  Function(String topicType, Map<String, dynamic> data)?
      _onNotificationReceived;

  // EventSource connections para cada topic
  final Map<String, html.EventSource> _eventSources = {};

  @override
  Future<void> initialize({
    required String serverUrl,
    required Function(String topicType, Map<String, dynamic> data)
        onNotificationReceived,
  }) async {
    _serverUrl = serverUrl;
    _onNotificationReceived = onNotificationReceived;
  }

  @override
  Future<void> subscribeToTopics(Map<String, String> topics) async {
    for (final entry in topics.entries) {
      final topicType = entry.key;
      final topicName = entry.value;
      await _subscribeToTopic(topicType, topicName);
    }
  }

  /// Suscribirse a un topic específico
  Future<void> _subscribeToTopic(String topicType, String topicName) async {
    try {
      final url = '$_serverUrl/$topicName/json';

      final eventSource = html.EventSource(url);
      _eventSources[topicType] = eventSource;

      // Configurar listeners
      eventSource.onOpen.listen((event) {});

      eventSource.onMessage.listen((html.MessageEvent event) {
        try {
          final data = jsonDecode(event.data as String);
          _onNotificationReceived?.call(topicType, data);
        } catch (e) {}
      });

      eventSource.onError.listen((event) {
        // Reintentar suscripción tras 5 segundos
        Timer(const Duration(seconds: 5), () {
          _subscribeToTopic(topicType, topicName);
        });
      });
    } catch (e) {}
  }

  @override
  Future<void> unsubscribeFromAllTopics() async {
    for (final entry in _eventSources.entries) {
      final topicType = entry.key;
      final eventSource = entry.value;

      try {
        eventSource.close();
      } catch (e) {}
    }

    _eventSources.clear();
  }

  @override
  bool isSubscribedToTopic(String topicType) {
    return _eventSources.containsKey(topicType);
  }

  @override
  Map<String, dynamic> getServiceInfo() {
    return {
      'implementation': 'web',
      'activeTopics': _eventSources.keys.toList(),
      'connectionCount': _eventSources.length,
      'method': 'EventSource (SSE)',
    };
  }

  @override
  void dispose() {
    unsubscribeFromAllTopics();
    _serverUrl = null;
    _onNotificationReceived = null;
  }
}

/// Factory function para crear la implementación web
NtfySubscriptionPlatform createNtfySubscriptionPlatform() {
  return NtfySubscriptionWeb();
}
