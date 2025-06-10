import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static LocalNotificationService? _instance;
  static LocalNotificationService get instance =>
      _instance ??= LocalNotificationService._internal();

  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Callback para cuando se toca una notificación
  Function(String?)? onNotificationTapped;

  Future<void> initialize() async {
    // Configuración para Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configuración para iOS
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
      defaultPresentAlert: true,
      defaultPresentSound: true,
      defaultPresentBadge: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (onNotificationTapped != null) {
          onNotificationTapped!(response.payload);
        }
      },
    );

    // Solicitar permisos en iOS
    await _requestIOSPermissions();

    // Crear canales de notificación para Android
    await _createNotificationChannels();
  }

  Future<void> _requestIOSPermissions() async {
    final IOSFlutterLocalNotificationsPlugin? iosPlugin =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    if (iosPlugin != null) {
      // Solicitar permisos
      await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
        critical:
            true, // NUEVO: Permisos críticos para notificaciones importantes
      );

      // NUEVO: Configurar categorías de notificación para iOS
      await _configureIOSNotificationCategories(iosPlugin);
    } else {
      // No se pudo obtener el plugin de iOS
    }
  }

  Future<void> _configureIOSNotificationCategories(
      IOSFlutterLocalNotificationsPlugin iosPlugin) async {
    // Categoría para invitaciones de chat
    final DarwinNotificationCategory chatInvitationCategory =
        DarwinNotificationCategory(
      'CHAT_INVITATION',
      actions: <DarwinNotificationAction>[
        DarwinNotificationAction.plain(
          'accept_invitation',
          'Aceptar',
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.foreground,
          },
        ),
        DarwinNotificationAction.plain(
          'decline_invitation',
          'Rechazar',
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.destructive,
          },
        ),
      ],
    );

    // Categoría para llamadas entrantes
    final DarwinNotificationCategory incomingCallCategory =
        DarwinNotificationCategory(
      'INCOMING_CALL',
      actions: <DarwinNotificationAction>[
        DarwinNotificationAction.plain(
          'accept_call',
          'Aceptar',
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.foreground,
          },
        ),
        DarwinNotificationAction.plain(
          'decline_call',
          'Rechazar',
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.destructive,
          },
        ),
      ],
    );

    await iosPlugin.initialize(
      DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
        requestCriticalPermission: true, // NUEVO: Permisos críticos
        defaultPresentAlert: true,
        defaultPresentSound: true,
        defaultPresentBadge: true,
        notificationCategories: [
          chatInvitationCategory,
          incomingCallCategory,
        ],
      ),
    );
  }

  Future<void> _checkNotificationPermissions() async {
    final IOSFlutterLocalNotificationsPlugin? iosPlugin =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    if (iosPlugin != null) {
      try {
        // Verificar permisos actuales
        await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      } catch (e) {
        // Error verificando permisos
      }
    } else {
      // No es iOS o plugin no disponible
    }
  }

  Future<void> _createNotificationChannels() async {
    // Canal para llamadas entrantes (alta prioridad)
    const AndroidNotificationChannel callChannel = AndroidNotificationChannel(
      'incoming_calls',
      'Llamadas Entrantes',
      description: 'Notificaciones de llamadas entrantes',
      importance: Importance.max,
      enableVibration: true,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('call_ringtone'),
    );

    // Canal para mensajes
    const AndroidNotificationChannel messageChannel =
        AndroidNotificationChannel(
      'messages',
      'Mensajes',
      description: 'Notificaciones de mensajes',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    // Canal para notificaciones generales
    const AndroidNotificationChannel generalChannel =
        AndroidNotificationChannel(
      'general',
      'General',
      description: 'Notificaciones generales',
      importance: Importance.defaultImportance,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(callChannel);

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(messageChannel);

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(generalChannel);
  }

  // Mostrar notificación de llamada entrante
  Future<void> showIncomingCallNotification({
    required String callId,
    required String callerName,
    required String callerAvatar,
    String? token,
  }) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'incoming_calls',
      'Llamadas Entrantes',
      channelDescription: 'Notificaciones de llamadas entrantes',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.call,
      visibility: NotificationVisibility.public,
      ongoing: true,
      autoCancel: false,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('call_ringtone'),
      actions: <AndroidNotificationAction>[
        const AndroidNotificationAction(
          'accept_call',
          'Aceptar',
          icon: DrawableResourceAndroidBitmap('ic_call_accept'),
          contextual: true,
        ),
        const AndroidNotificationAction(
          'decline_call',
          'Rechazar',
          icon: DrawableResourceAndroidBitmap('ic_call_decline'),
          contextual: true,
        ),
      ],
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'call_ringtone.caf',
      categoryIdentifier: 'INCOMING_CALL',
      interruptionLevel: InterruptionLevel.critical,
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    final payload = jsonEncode({
      'type': 'incoming_call',
      'callId': callId,
      'callerName': callerName,
      'callerAvatar': callerAvatar,
      'token': token,
    });

    await _flutterLocalNotificationsPlugin.show(
      callId.hashCode, // ID único basado en callId
      'Llamada entrante',
      'Llamada de $callerName',
      platformChannelSpecifics,
      payload: payload,
    );
  }

  // Mostrar notificación de invitación de chat
  Future<void> showChatInvitationNotification({
    required String invitationId,
    required String senderName,
    required String message,
    String? senderAvatar,
  }) async {
    // Verificar si hay permisos primero
    await _checkNotificationPermissions();

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'messages',
      'Mensajes',
      channelDescription: 'Notificaciones de mensajes',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: BigTextStyleInformation(
        'Invitación de chat efímero',
        htmlFormatBigText: false,
        contentTitle: 'Invitación de $senderName',
        htmlFormatContentTitle: false,
        summaryText: 'Chat Efímero',
        htmlFormatSummaryText: false,
      ),
      actions: const <AndroidNotificationAction>[
        AndroidNotificationAction(
          'accept_invitation',
          'Aceptar',
          icon: DrawableResourceAndroidBitmap('ic_check'),
          contextual: true,
        ),
        AndroidNotificationAction(
          'decline_invitation',
          'Rechazar',
          icon: DrawableResourceAndroidBitmap('ic_close'),
          contextual: true,
        ),
      ],
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
      categoryIdentifier: 'CHAT_INVITATION',
      interruptionLevel: InterruptionLevel.active,
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    final payload = jsonEncode({
      'type': 'chat_invitation',
      'invitationId': invitationId,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'message': message,
    });

    try {
      await _flutterLocalNotificationsPlugin.show(
        invitationId.hashCode, // ID único basado en invitationId
        'Invitación de chat',
        '$senderName $message',
        platformChannelSpecifics,
        payload: payload,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Mostrar notificación de mensaje
  Future<void> showMessageNotification({
    required String messageId,
    required String senderName,
    required String messageText,
    String? senderAvatar,
  }) async {
    // Verificar si hay permisos primero
    await _checkNotificationPermissions();

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'messages',
      'Mensajes',
      channelDescription: 'Notificaciones de mensajes',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: BigTextStyleInformation(
        'Nuevo mensaje cifrado',
        htmlFormatBigText: false,
        contentTitle: 'Mensaje de $senderName',
        htmlFormatContentTitle: false,
        summaryText: 'Chat Efímero',
        htmlFormatSummaryText: false,
      ),
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
      interruptionLevel: InterruptionLevel.active,
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    final payload = jsonEncode({
      'type': 'message',
      'messageId': messageId,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
    });

    try {
      await _flutterLocalNotificationsPlugin.show(
        messageId.hashCode, // ID único basado en messageId
        'Mensaje de $senderName',
        'Tienes un mensaje', // Sin mostrar contenido por privacidad
        platformChannelSpecifics,
        payload: payload,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Mostrar notificación general
  Future<void> showGeneralNotification({
    required String id,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'general',
      'General',
      channelDescription: 'Notificaciones generales',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    final payload = jsonEncode({
      'type': 'general',
      'id': id,
      'title': title,
      'body': body,
      'data': data,
    });

    await _flutterLocalNotificationsPlugin.show(
      id.hashCode,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  // Cancelar notificación específica
  Future<void> cancelNotification(String id) async {
    await _flutterLocalNotificationsPlugin.cancel(id.hashCode);
  }

  // Cancelar todas las notificaciones
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  // Configurar callback para cuando se toca una notificación
  void setOnNotificationTapped(Function(String?) callback) {
    onNotificationTapped = callback;
  }

  // Verificar si las notificaciones están habilitadas
  Future<bool> areNotificationsEnabled() async {
    final androidImplementation =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      return await androidImplementation.areNotificationsEnabled() ?? false;
    }

    return true; // En iOS asumimos que están habilitadas si llegamos aquí
  }
}
