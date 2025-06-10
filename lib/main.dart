import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:flutterputter/providers/auth_provider.dart';
import 'package:flutterputter/providers/call_provider.dart';
import 'package:flutterputter/screens/auth/login_screen.dart';
import 'package:flutterputter/screens/splash_screen.dart';
import 'package:flutterputter/screens/main_screen.dart';
import 'package:flutterputter/screens/multi_room_chat_screen.dart';
import 'package:flutterputter/screens/encrypting_animation_screen.dart';
import 'package:flutterputter/theme/app_theme.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutterputter/widgets/app_lock_wrapper.dart';
import 'package:flutterputter/services/screenshot_security_service.dart';
import 'package:flutterputter/services/session_management_service.dart';
import 'package:flutterputter/services/security_alert_service.dart';
import 'package:flutterputter/l10n/app_localizations.dart';

void main() async {
  // 1️⃣ Siempre primero
  WidgetsFlutterBinding.ensureInitialized();

  // 2️⃣ Ajustes específicos SOLO en móvil
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  // NUEVO: Inicializar servicio de seguridad de capturas de pantalla
  try {
    await ScreenshotSecurityService().initialize();
  } catch (e) {
    // Error inicializando servicio de capturas
  }

  // NUEVO: Inicializar servicio de sesiones activas
  try {
    await SessionManagementService().initialize();
  } catch (e) {
    // Error inicializando servicio de sesiones
  }

  // 3️⃣ Handler de errores de Flutter
  FlutterError.onError = (FlutterErrorDetails details) {
    // ①  imprime la traza en consola de Chrome
    FlutterError.dumpErrorToConsole(details);
    // ②  muestra el link al archivo ↴  (¡no lo comentes!)
    FlutterError.presentError(details);

    // Además imprime con print para Chrome
    // print('### STACK FROM FlutterError ###');
    // print(details.stack);
  };

  // ③  atrapa errores fuera del árbol de widgets
  PlatformDispatcher.instance.onError = (e, s) {
    // print('### UNCAUGHT JS EXCEPTION ###');
    // print(e);
    debugPrintStack(stackTrace: s);
    return true; // evita cerrar la app
  };

  // 4️⃣ runApp SIN cambiar de Zone
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔔 NavigatorKey para las notificaciones
    final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) {
          final authProvider = AuthProvider();
          // Configurar el navigatorKey para las notificaciones
          authProvider.setNavigatorKey(navigatorKey);
          return authProvider;
        }),
        ChangeNotifierProvider(create: (_) => CallProvider()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey, // 🔔 Configurar navigatorKey
        title: 'FlutterPutter',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/encrypting': (context) => const EncryptingAnimationScreen(),
          '/home': (context) => const MainScreen(),
          '/multi-room-chat': (context) => const MultiRoomChatScreen(),
        },
        builder: (context, child) {
          // 🚨 NUEVO: Configurar contexto del SecurityAlertService
          WidgetsBinding.instance.addPostFrameCallback((_) {
            SecurityAlertService.instance.setContext(context);
          });

          // Envolver con AppLockWrapper para manejar bloqueo de aplicación
          return AppLockWrapper(child: child ?? const SizedBox());
        },
      ),
    );
  }
}
