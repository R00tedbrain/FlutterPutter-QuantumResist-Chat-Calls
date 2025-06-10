import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Servicio para mostrar notificaciones nativas del sistema
/// Convierte notificaciones ntfy en notificaciones push nativas
class NativeNotificationService {
  static NativeNotificationService? _instance;
  static NativeNotificationService get instance =>
      _instance ??= NativeNotificationService._internal();

  NativeNotificationService._internal();

  static const String _channelId = 'chat_notifications';
  static const String _channelName = 'Chat Notifications';
  static const String _channelDescription =
      'Notificaciones de chat efímero y llamadas';

  static const String _invitationChannelId = 'invitation_notifications';
  static const String _invitationChannelName = 'Invitaciones de Chat';
  static const String _invitationChannelDescription =
      'Notificaciones de invitaciones de chat';

  static const String _callChannelId = 'call_notifications';
  static const String _callChannelName = 'Llamadas VoIP';
  static const String _callChannelDescription =
      'Notificaciones de llamadas entrantes';

  FlutterLocalNotificationsPlugin? _notifications;
  bool _isInitialized = false;
  bool _permissionsGranted = false;

  /// Inicializar el servicio de notificaciones nativas
  Future<void> initialize() async {
    if (_isInitialized) {
      print('📲 [NATIVE-NOTIF] Ya está inicializado');
      return;
    }

    try {
      print('📲 [NATIVE-NOTIF] === INICIALIZANDO NOTIFICACIONES NATIVAS ===');

      if (kIsWeb) {
        print('📲 [NATIVE-NOTIF] Web: Notificaciones nativas no disponibles');
        return;
      }

      _notifications = FlutterLocalNotificationsPlugin();

      // Configuración para Android
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // Configuración para iOS
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        requestCriticalPermission: false,
        requestProvisionalPermission: false,
        onDidReceiveLocalNotification: null,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
        macOS: iosSettings,
      );

      // Inicializar plugin
      final result = await _notifications!.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
        onDidReceiveBackgroundNotificationResponse:
            _onBackgroundNotificationTapped,
      );

      if (result != null && result) {
        print('✅ [NATIVE-NOTIF] Plugin inicializado correctamente');

        // Crear canales de notificación
        await _createNotificationChannels();

        // Solicitar permisos
        await _requestPermissions();

        _isInitialized = true;
        print('✅ [NATIVE-NOTIF] Servicio de notificaciones nativas listo');
      } else {
        print('❌ [NATIVE-NOTIF] Error inicializando plugin');
      }
    } catch (e) {
      print('❌ [NATIVE-NOTIF] Error inicializando: $e');
    }
  }

  /// Crear canales de notificación (Android)
  Future<void> _createNotificationChannels() async {
    if (Platform.isAndroid) {
      // Canal general de chat
      const chatChannel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.high,
        showBadge: true,
        enableVibration: true,
        enableLights: true,
        playSound: true,
      );

      // Canal de invitaciones
      const invitationChannel = AndroidNotificationChannel(
        _invitationChannelId,
        _invitationChannelName,
        description: _invitationChannelDescription,
        importance: Importance.high,
        showBadge: true,
        enableVibration: true,
        enableLights: true,
        playSound: true,
      );

      // Canal de llamadas
      const callChannel = AndroidNotificationChannel(
        _callChannelId,
        _callChannelName,
        description: _callChannelDescription,
        importance: Importance.max,
        showBadge: true,
        enableVibration: true,
        enableLights: true,
        playSound: true,
      );

      final androidPlugin = _notifications!
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(chatChannel);
        await androidPlugin.createNotificationChannel(invitationChannel);
        await androidPlugin.createNotificationChannel(callChannel);
        print('✅ [NATIVE-NOTIF] Canales de Android creados');
      }
    }
  }

  /// Solicitar permisos de notificación
  Future<void> _requestPermissions() async {
    try {
      if (Platform.isIOS) {
        final result = await _notifications!
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
              critical: false,
              provisional: false,
            );

        _permissionsGranted = result ?? false;
        print(
            '📲 [NATIVE-NOTIF] Permisos iOS: ${_permissionsGranted ? 'Concedidos' : 'Denegados'}');
      } else if (Platform.isAndroid) {
        final androidPlugin = _notifications!
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

        if (androidPlugin != null) {
          final result = await androidPlugin.requestNotificationsPermission();
          _permissionsGranted = result ?? false;
          print(
              '📲 [NATIVE-NOTIF] Permisos Android: ${_permissionsGranted ? 'Concedidos' : 'Denegados'}');
        }
      }
    } catch (e) {
      print('❌ [NATIVE-NOTIF] Error solicitando permisos: $e');
      _permissionsGranted = false;
    }
  }

  /// Mostrar notificación de invitación de chat
  Future<void> showChatInvitation({
    required String fromUserId,
    required String invitationId,
    String? customMessage,
  }) async {
    if (!_canShowNotifications()) return;

    try {
      final androidDetails = AndroidNotificationDetails(
        _invitationChannelId,
        _invitationChannelName,
        channelDescription: _invitationChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        autoCancel: true,
        enableVibration: true,
        enableLights: true,
        playSound: true,
        icon: '@mipmap/ic_launcher',
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        styleInformation: BigTextStyleInformation(
          customMessage ?? '$fromUserId te invita a un chat efímero',
          htmlFormatBigText: false,
          contentTitle: 'Invitación de Chat',
          htmlFormatContentTitle: false,
          summaryText: 'Chat Efímero',
          htmlFormatSummaryText: false,
        ),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
        badgeNumber: 1,
        subtitle: 'Chat Efímero',
        threadIdentifier: 'chat_invitations',
        categoryIdentifier: 'chat_invitation',
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications!.show(
        invitationId.hashCode,
        'Invitación de Chat',
        customMessage ?? '$fromUserId te invita a un chat efímero',
        details,
        payload: 'invitation:$invitationId:$fromUserId',
      );

      print('✅ [NATIVE-NOTIF] Notificación de invitación mostrada');
    } catch (e) {
      print('❌ [NATIVE-NOTIF] Error mostrando invitación: $e');
    }
  }

  /// Mostrar notificación de mensaje de chat
  Future<void> showChatMessage({
    required String fromUserId,
    required String messageId,
    required String roomId,
    String? messageContent,
  }) async {
    if (!_canShowNotifications()) return;

    try {
      final androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        autoCancel: true,
        enableVibration: true,
        enableLights: true,
        playSound: true,
        icon: '@mipmap/ic_launcher',
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        styleInformation: BigTextStyleInformation(
          messageContent ?? 'Nuevo mensaje cifrado',
          htmlFormatBigText: false,
          contentTitle: 'Mensaje de $fromUserId',
          htmlFormatContentTitle: false,
          summaryText: 'Chat Efímero',
          htmlFormatSummaryText: false,
        ),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
        badgeNumber: 1,
        subtitle: 'Chat Efímero',
        threadIdentifier: 'chat_messages',
        categoryIdentifier: 'chat_message',
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications!.show(
        messageId.hashCode,
        'Mensaje de $fromUserId',
        messageContent ?? 'Nuevo mensaje cifrado',
        details,
        payload: 'message:$messageId:$roomId:$fromUserId',
      );

      print('✅ [NATIVE-NOTIF] Notificación de mensaje mostrada');
    } catch (e) {
      print('❌ [NATIVE-NOTIF] Error mostrando mensaje: $e');
    }
  }

  /// Mostrar notificación de llamada VoIP
  Future<void> showIncomingCall({
    required String fromUserId,
    required String callId,
    String? callerName,
  }) async {
    if (!_canShowNotifications()) return;

    try {
      final androidDetails = AndroidNotificationDetails(
        _callChannelId,
        _callChannelName,
        channelDescription: _callChannelDescription,
        importance: Importance.max,
        priority: Priority.max,
        showWhen: true,
        autoCancel: false,
        ongoing: true,
        enableVibration: true,
        enableLights: true,
        playSound: true,
        icon: '@mipmap/ic_launcher',
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        styleInformation: BigTextStyleInformation(
          'Llamada entrante de ${callerName ?? fromUserId}',
          htmlFormatBigText: false,
          contentTitle: 'Llamada VoIP',
          htmlFormatContentTitle: false,
          summaryText: 'Videollamada',
          htmlFormatSummaryText: false,
        ),
        fullScreenIntent: true,
        category: AndroidNotificationCategory.call,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
        badgeNumber: 1,
        subtitle: 'Videollamada',
        threadIdentifier: 'voip_calls',
        categoryIdentifier: 'voip_call',
        interruptionLevel: InterruptionLevel.critical,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications!.show(
        callId.hashCode,
        'Llamada VoIP',
        'Llamada entrante de ${callerName ?? fromUserId}',
        details,
        payload: 'call:$callId:$fromUserId',
      );

      print('✅ [NATIVE-NOTIF] Notificación de llamada mostrada');
    } catch (e) {
      print('❌ [NATIVE-NOTIF] Error mostrando llamada: $e');
    }
  }

  /// Verificar si se pueden mostrar notificaciones
  bool _canShowNotifications() {
    if (kIsWeb) {
      print('❌ [NATIVE-NOTIF] Web: Notificaciones nativas no soportadas');
      return false;
    }

    if (!_isInitialized) {
      print('❌ [NATIVE-NOTIF] Servicio no inicializado');
      return false;
    }

    if (!_permissionsGranted) {
      print('❌ [NATIVE-NOTIF] Permisos no concedidos');
      return false;
    }

    return true;
  }

  /// Manejar tap en notificación (foreground)
  static void _onNotificationTapped(NotificationResponse response) {
    print('📲 [NATIVE-NOTIF] Notificación tocada: ${response.payload}');
    _handleNotificationAction(response.payload);
  }

  /// Manejar tap en notificación (background)
  @pragma('vm:entry-point')
  static void _onBackgroundNotificationTapped(NotificationResponse response) {
    print(
        '📲 [NATIVE-NOTIF] Notificación background tocada: ${response.payload}');
    _handleNotificationAction(response.payload);
  }

  /// Procesar acción de notificación
  static void _handleNotificationAction(String? payload) {
    if (payload == null) return;

    try {
      final parts = payload.split(':');
      if (parts.length < 2) return;

      final type = parts[0];
      final id = parts[1];

      print('📲 [NATIVE-NOTIF] Procesando acción: $type - ID: $id');

      switch (type) {
        case 'invitation':
          // Navegar a pantalla de invitaciones
          print('📲 [NATIVE-NOTIF] Abriendo invitación: $id');
          break;
        case 'message':
          // Navegar a chat
          if (parts.length >= 3) {
            final roomId = parts[2];
            print('📲 [NATIVE-NOTIF] Abriendo chat: $roomId');
          }
          break;
        case 'call':
          // Manejar llamada
          print('📲 [NATIVE-NOTIF] Procesando llamada: $id');
          break;
      }
    } catch (e) {
      print('❌ [NATIVE-NOTIF] Error procesando acción: $e');
    }
  }

  /// Cancelar notificación específica
  Future<void> cancelNotification(int id) async {
    if (_notifications != null) {
      await _notifications!.cancel(id);
      print('📲 [NATIVE-NOTIF] Notificación cancelada: $id');
    }
  }

  /// Cancelar todas las notificaciones
  Future<void> cancelAllNotifications() async {
    if (_notifications != null) {
      await _notifications!.cancelAll();
      print('📲 [NATIVE-NOTIF] Todas las notificaciones canceladas');
    }
  }

  /// Obtener estado del servicio
  Map<String, dynamic> getServiceInfo() {
    return {
      'isInitialized': _isInitialized,
      'permissionsGranted': _permissionsGranted,
      'platform': Platform.operatingSystem,
      'canShowNotifications': _canShowNotifications(),
    };
  }

  /// Limpiar recursos
  void dispose() {
    _isInitialized = false;
    _permissionsGranted = false;
    _notifications = null;
    print('📲 [NATIVE-NOTIF] Servicio limpiado');
  }
}
