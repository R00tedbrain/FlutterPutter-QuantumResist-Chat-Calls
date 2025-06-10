import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_lock_service.dart';
import '../screens/app_lock_screen.dart';

class AppLockWrapper extends StatefulWidget {
  final Widget child;

  const AppLockWrapper({
    super.key,
    required this.child,
  });

  @override
  State<AppLockWrapper> createState() => _AppLockWrapperState();
}

class _AppLockWrapperState extends State<AppLockWrapper>
    with WidgetsBindingObserver {
  late AppLockService _appLockService;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _appLockService = AppLockService();
    _initializeAppLock();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _initializeAppLock() async {
    try {
      await _appLockService.initialize();
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      print('❌ Error inicializando AppLockService: $e');
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        // La app vuelve del background
        _appLockService.onAppResumed();
        break;
      case AppLifecycleState.paused:
        // La app pasa a background
        _appLockService.onAppPaused();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return ChangeNotifierProvider.value(
      value: _appLockService,
      child: Consumer<AppLockService>(
        builder: (context, appLockService, child) {
          // Si el bloqueo está habilitado y la app está bloqueada
          if (appLockService.isEnabled && appLockService.isLocked) {
            return const AppLockScreen();
          }

          // Sino, mostrar la aplicación normal
          return GestureDetector(
            onTap: () => appLockService.notifyActivity(),
            onPanDown: (_) => appLockService.notifyActivity(),
            onScaleStart: (_) => appLockService.notifyActivity(),
            child: widget.child,
          );
        },
      ),
    );
  }
}
