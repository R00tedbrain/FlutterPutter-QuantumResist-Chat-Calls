import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:crypto/crypto.dart';

class AppLockService extends ChangeNotifier {
  static final AppLockService _instance = AppLockService._internal();
  factory AppLockService() => _instance;
  AppLockService._internal();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static const String _pinKey = 'app_lock_pin';
  static const String _lockTimeoutKey = 'app_lock_timeout';
  static const String _isEnabledKey = 'app_lock_enabled';
  static const String _lastActiveKey = 'app_last_active';
  static const String _biometricEnabledKey = 'biometric_enabled';

  bool _isLocked = false;
  bool _isEnabled = false;
  bool _biometricEnabled = false;
  int _lockTimeoutMinutes = 5; // Por defecto 5 minutos
  Timer? _lockTimer;

  // Valores de timeout disponibles (en minutos)
  static const List<int> timeoutOptions = [1, 2, 5, 30, 60];
  static const Map<int, String> timeoutLabels = {
    1: '1 minuto',
    2: '2 minutos',
    5: '5 minutos',
    30: '30 minutos',
    60: '1 hora',
  };

  bool get isLocked => _isLocked;
  bool get isEnabled => _isEnabled;
  bool get biometricEnabled => _biometricEnabled;
  int get lockTimeoutMinutes => _lockTimeoutMinutes;

  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Inicializar el servicio
  Future<void> initialize() async {
    await _loadSettings();
    await _checkIfShouldBeLocked();

    // Configurar callback para cuando la app vuelve del background
    WidgetsBinding.instance.addObserver(_AppLifecycleObserver(this));
  }

  /// Cargar configuraciones guardadas
  Future<void> _loadSettings() async {
    try {
      final isEnabledStr = await _storage.read(key: _isEnabledKey);
      final timeoutStr = await _storage.read(key: _lockTimeoutKey);
      final biometricStr = await _storage.read(key: _biometricEnabledKey);

      _isEnabled = isEnabledStr == 'true';
      _lockTimeoutMinutes = int.tryParse(timeoutStr ?? '5') ?? 5;
      _biometricEnabled = biometricStr == 'true';

      print(
          '🔒 Configuración cargada: enabled=$_isEnabled, timeout=$_lockTimeoutMinutes min, biometric=$_biometricEnabled');
    } catch (e) {
      print('❌ Error cargando configuración de bloqueo: $e');
    }
  }

  /// Verificar si la app debería estar bloqueada
  Future<void> _checkIfShouldBeLocked() async {
    if (!_isEnabled) return;

    try {
      final lastActiveStr = await _storage.read(key: _lastActiveKey);
      if (lastActiveStr == null) {
        _isLocked = true;
        notifyListeners();
        return;
      }

      final lastActive =
          DateTime.fromMillisecondsSinceEpoch(int.parse(lastActiveStr));
      final now = DateTime.now();
      final difference = now.difference(lastActive);

      if (difference.inMinutes >= _lockTimeoutMinutes) {
        _isLocked = true;
        print(
            '🔒 App bloqueada: ${difference.inMinutes} minutos de inactividad');
      }
    } catch (e) {
      print('❌ Error verificando bloqueo: $e');
      _isLocked = _isEnabled; // Por seguridad, bloquear si hay error
    }

    notifyListeners();
  }

  /// Configurar PIN de bloqueo
  Future<bool> setupPin(String pin) async {
    if (pin.length < 4 || pin.length > 15) {
      return false;
    }

    try {
      // Hashear el PIN antes de guardarlo
      final hashedPin = _hashPin(pin);
      await _storage.write(key: _pinKey, value: hashedPin);
      await _storage.write(key: _isEnabledKey, value: 'true');

      _isEnabled = true;
      _isLocked = false;

      await _updateLastActiveTime();
      notifyListeners();

      print('🔒 PIN configurado exitosamente');
      return true;
    } catch (e) {
      print('❌ Error configurando PIN: $e');
      return false;
    }
  }

  /// Verificar PIN
  Future<bool> verifyPin(String pin) async {
    try {
      final storedHash = await _storage.read(key: _pinKey);
      if (storedHash == null) return false;

      final hashedPin = _hashPin(pin);

      if (hashedPin == storedHash) {
        _isLocked = false;
        await _updateLastActiveTime();
        _startLockTimer();
        notifyListeners();
        print('🔓 PIN verificado correctamente');
        return true;
      }

      print('❌ PIN incorrecto');
      return false;
    } catch (e) {
      print('❌ Error verificando PIN: $e');
      return false;
    }
  }

  /// Autenticación biométrica
  Future<bool> authenticateWithBiometrics() async {
    if (!_biometricEnabled) return false;

    try {
      // Verificar disponibilidad de biometría
      final isAvailable = await _localAuth.canCheckBiometrics;
      if (!isAvailable) return false;

      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Desbloquea FlutterPutter con tu huella o Face ID',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (didAuthenticate) {
        _isLocked = false;
        await _updateLastActiveTime();
        _startLockTimer();
        notifyListeners();
        print('🔓 Autenticación biométrica exitosa');
        return true;
      }

      return false;
    } catch (e) {
      print('❌ Error en autenticación biométrica: $e');
      return false;
    }
  }

  /// Verificar si la biometría está disponible
  Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      return isAvailable && availableBiometrics.isNotEmpty;
    } catch (e) {
      print('❌ Error verificando biometría: $e');
      return false;
    }
  }

  /// Configurar timeout de bloqueo
  Future<void> setLockTimeout(int minutes) async {
    try {
      await _storage.write(key: _lockTimeoutKey, value: minutes.toString());
      _lockTimeoutMinutes = minutes;

      // Reiniciar timer con nuevo timeout
      if (!_isLocked) {
        _startLockTimer();
      }

      notifyListeners();
      print('🔒 Timeout configurado a $_lockTimeoutMinutes minutos');
    } catch (e) {
      print('❌ Error configurando timeout: $e');
    }
  }

  /// Habilitar/deshabilitar biometría
  Future<void> setBiometricEnabled(bool enabled) async {
    try {
      await _storage.write(
          key: _biometricEnabledKey, value: enabled.toString());
      _biometricEnabled = enabled;
      notifyListeners();
      print('🔒 Biometría ${enabled ? 'habilitada' : 'deshabilitada'}');
    } catch (e) {
      print('❌ Error configurando biometría: $e');
    }
  }

  /// Deshabilitar bloqueo completamente
  Future<void> disableAppLock() async {
    try {
      await _storage.deleteAll();
      _isEnabled = false;
      _isLocked = false;
      _biometricEnabled = false;
      _lockTimeoutMinutes = 5;
      _lockTimer?.cancel();
      notifyListeners();
      print('🔓 Bloqueo de aplicación deshabilitado');
    } catch (e) {
      print('❌ Error deshabilitando bloqueo: $e');
    }
  }

  /// Cambiar PIN existente
  Future<bool> changePin(String currentPin, String newPin) async {
    if (!(await verifyPin(currentPin))) {
      return false;
    }

    return await setupPin(newPin);
  }

  /// Bloquear manualmente la aplicación
  void lockApp() {
    if (_isEnabled) {
      _isLocked = true;
      _lockTimer?.cancel();
      notifyListeners();
      print('🔒 App bloqueada manualmente');
    }
  }

  /// Actualizar tiempo de última actividad
  Future<void> _updateLastActiveTime() async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch.toString();
      await _storage.write(key: _lastActiveKey, value: now);
    } catch (e) {
      print('❌ Error actualizando tiempo activo: $e');
    }
  }

  /// Iniciar timer de bloqueo automático
  void _startLockTimer() {
    _lockTimer?.cancel();

    if (!_isEnabled) return;

    _lockTimer = Timer(Duration(minutes: _lockTimeoutMinutes), () {
      _isLocked = true;
      notifyListeners();
      print('🔒 App bloqueada automáticamente por inactividad');
    });
  }

  /// Hashear PIN con salt
  String _hashPin(String pin) {
    const salt = 'flutterputter_app_lock_salt_2024';
    final bytes = utf8.encode(pin + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Notificar actividad (resetear timer)
  void notifyActivity() {
    if (_isEnabled && !_isLocked) {
      _updateLastActiveTime();
      _startLockTimer();
    }
  }

  /// Manejar cuando la app pasa a background/foreground
  void onAppResumed() {
    if (_isEnabled) {
      _checkIfShouldBeLocked();
    }
  }

  void onAppPaused() {
    if (_isEnabled && !_isLocked) {
      _updateLastActiveTime();
    }
  }

  @override
  void dispose() {
    _lockTimer?.cancel();
    super.dispose();
  }
}

/// Observer para detectar cambios en el lifecycle de la app
class _AppLifecycleObserver extends WidgetsBindingObserver {
  final AppLockService _appLockService;

  _AppLifecycleObserver(this._appLockService);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _appLockService.onAppResumed();
        break;
      case AppLifecycleState.paused:
        _appLockService.onAppPaused();
        break;
      default:
        break;
    }
  }
}
