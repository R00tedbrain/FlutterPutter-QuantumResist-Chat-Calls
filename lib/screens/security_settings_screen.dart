import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';
import '../services/app_lock_service.dart';
import '../services/screenshot_security_service.dart';
import '../services/auto_destruction_preferences_service.dart';
import '../services/session_management_service.dart';
import '../l10n/app_localizations.dart';
import 'active_sessions_screen.dart';
import 'webview_screen.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  final TextEditingController _currentPinController = TextEditingController();
  bool _isSettingUpPin = false;
  bool _isChangingPin = false;
  bool _biometricAvailable = false;

  // NUEVO: Servicio de capturas de pantalla
  final ScreenshotSecurityService _screenshotService =
      ScreenshotSecurityService();
  bool _screenshotEnabled = true;
  bool _screenshotLoading = false;

  // NUEVO: Servicio de auto-destrucción por defecto
  final AutoDestructionPreferencesService _autoDestructionService =
      AutoDestructionPreferencesService();
  int? _defaultDestructionMinutes;
  bool _autoApplyDefault = false;
  bool _autoDestructionLoading = false;

  // NUEVO: Servicio de sesiones activas
  final SessionManagementService _sessionService = SessionManagementService();
  bool _sessionLoading = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
    _initializeScreenshotService(); // NUEVO: Inicializar servicio de capturas
    _initializeAutoDestructionService(); // NUEVO: Inicializar servicio de auto-destrucción
    _initializeSessionService(); // NUEVO: Inicializar servicio de sesiones
  }

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    _currentPinController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometricAvailability() async {
    final appLockService = Provider.of<AppLockService>(context, listen: false);
    final available = await appLockService.isBiometricAvailable();
    setState(() {
      _biometricAvailable = available;
    });
  }

  Future<void> _setupPin() async {
    final l10n = AppLocalizations.of(context)!;
    if (_pinController.text.length < 4 || _pinController.text.length > 15) {
      _showError(l10n.pinLengthError);
      return;
    }

    if (_pinController.text != _confirmPinController.text) {
      _showError(l10n.pinMismatch);
      return;
    }

    setState(() => _isSettingUpPin = true);

    try {
      final appLockService =
          Provider.of<AppLockService>(context, listen: false);
      final success = await appLockService.setupPin(_pinController.text);

      setState(() => _isSettingUpPin = false);

      if (success) {
        _pinController.clear();
        _confirmPinController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.appLockSetupSuccess),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        _showError(l10n.pinSetupError);
      }
    } catch (e) {
      setState(() => _isSettingUpPin = false);
      _showError('Error: $e');
    }
  }

  Future<void> _changePin() async {
    final l10n = AppLocalizations.of(context)!;
    if (_pinController.text.length < 4 || _pinController.text.length > 15) {
      _showError(l10n.pinLengthError);
      return;
    }

    if (_pinController.text != _confirmPinController.text) {
      _showError(l10n.pinMismatch);
      return;
    }

    setState(() => _isChangingPin = true);

    try {
      final appLockService =
          Provider.of<AppLockService>(context, listen: false);
      final success = await appLockService.changePin(
        _currentPinController.text,
        _pinController.text,
      );

      setState(() => _isChangingPin = false);

      if (success) {
        _pinController.clear();
        _confirmPinController.clear();
        _currentPinController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.pinChangeSuccess),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        _showError(l10n.currentPinIncorrect);
      }
    } catch (e) {
      setState(() => _isChangingPin = false);
      _showError('Error: $e');
    }
  }

  Future<void> _disableAppLock() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await _showConfirmDialog(
      l10n.disableAppLockTitle,
      l10n.disableAppLockMessage,
    );

    if (!confirmed) return;

    try {
      final appLockService =
          Provider.of<AppLockService>(context, listen: false);
      await appLockService.disableAppLock();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.appLockDisabled),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      _showError('Error: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('❌ $message'),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<bool> _showConfirmDialog(String title, String message) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Widget _buildPinSetupSection() {
    return Consumer<AppLockService>(
      builder: (context, appLockService, child) {
        if (appLockService.isEnabled) {
          return _buildChangePin();
        } else {
          return _buildInitialSetup();
        }
      },
    );
  }

  Widget _buildInitialSetup() {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lock_outline, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  l10n.configureAppLock,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 15,
              decoration: InputDecoration(
                labelText: l10n.newPin,
                prefixIcon: const Icon(Icons.lock),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 15,
              decoration: InputDecoration(
                labelText: l10n.confirmPin,
                prefixIcon: const Icon(Icons.lock_outline),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSettingUpPin ? null : _setupPin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: _isSettingUpPin
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(l10n.activateLock),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChangePin() {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lock, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  l10n.lockActivated,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              l10n.changePin,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _currentPinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.currentPin,
                prefixIcon: const Icon(Icons.lock),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 15,
              decoration: InputDecoration(
                labelText: l10n.newPin,
                prefixIcon: const Icon(Icons.lock_outline),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirmPinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 15,
              decoration: InputDecoration(
                labelText: l10n.confirmNewPin,
                prefixIcon: const Icon(Icons.lock_outline),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isChangingPin ? null : _changePin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: _isChangingPin
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(l10n.changePinButton),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _disableAppLock,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(l10n.disable),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeoutSettings() {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<AppLockService>(
      builder: (context, appLockService, child) {
        if (!appLockService.isEnabled) return const SizedBox();

        return Card(
          elevation: 4,
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.timer, color: Colors.orange),
                    const SizedBox(width: 8),
                    Text(
                      l10n.automaticLockTimeout,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.appWillLockAfter,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                ...AppLockService.timeoutOptions.map(
                  (minutes) => RadioListTile<int>(
                    title: Text(AppLockService.timeoutLabels[minutes]!),
                    value: minutes,
                    groupValue: appLockService.lockTimeoutMinutes,
                    onChanged: (value) {
                      if (value != null) {
                        appLockService.setLockTimeout(value);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBiometricSettings() {
    final l10n = AppLocalizations.of(context)!;
    if (!_biometricAvailable) return const SizedBox();

    return Consumer<AppLockService>(
      builder: (context, appLockService, child) {
        if (!appLockService.isEnabled) return const SizedBox();

        return Card(
          elevation: 4,
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.fingerprint, color: Colors.purple),
                    const SizedBox(width: 8),
                    Text(
                      l10n.biometricAuthentication,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: Text(l10n.enableBiometric),
                  subtitle: Text(l10n.biometricUnlock),
                  value: appLockService.biometricEnabled,
                  onChanged: (value) {
                    appLockService.setBiometricEnabled(value);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // NUEVO: Inicializar servicio de capturas de pantalla
  Future<void> _initializeScreenshotService() async {
    setState(() => _screenshotLoading = true);

    try {
      await _screenshotService.initialize();
      setState(() {
        _screenshotEnabled = _screenshotService.isScreenshotEnabled;
        _screenshotLoading = false;
      });
    } catch (e) {
      setState(() => _screenshotLoading = false);
    }
  }

  // NUEVO: Manejar cambio en configuración de capturas
  Future<void> _toggleScreenshotSecurity(bool enabled) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _screenshotLoading = true);

    try {
      final success = await _screenshotService.setScreenshotEnabled(enabled);

      if (success) {
        setState(() {
          _screenshotEnabled = enabled;
          _screenshotLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              enabled
                  ? l10n.screenshotsAllowedMessage
                  : l10n.screenshotsBlockedMessage,
            ),
            backgroundColor: enabled ? Colors.green : Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        setState(() => _screenshotLoading = false);
        _showError(l10n.screenshotConfigError);
      }
    } catch (e) {
      setState(() => _screenshotLoading = false);
      _showError('Error: $e');
    }
  }

  Widget _buildScreenshotSettings() {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.screenshot, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  l10n.screenshotSecurity,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              l10n.screenshotSecurityDescription,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text(l10n.allowScreenshots),
              subtitle: Text(
                _screenshotEnabled
                    ? l10n.screenshotsAllowed
                    : l10n.screenshotsBlocked,
                style: TextStyle(
                  color: _screenshotEnabled ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
              value: _screenshotEnabled,
              onChanged: _screenshotLoading ? null : _toggleScreenshotSecurity,
              secondary: _screenshotLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      _screenshotEnabled ? Icons.photo_camera : Icons.block,
                      color: _screenshotEnabled ? Colors.green : Colors.red,
                    ),
            ),
            if (!_screenshotEnabled) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.security, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.protectionActive,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.nativeProtectionFeatures,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (_screenshotEnabled) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.screenshotsDisabled,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // NUEVO: Inicializar servicio de auto-destrucción
  Future<void> _initializeAutoDestructionService() async {
    setState(() => _autoDestructionLoading = true);

    try {
      await _autoDestructionService.initialize();
      setState(() {
        _defaultDestructionMinutes =
            _autoDestructionService.defaultDestructionMinutes;
        _autoApplyDefault = _autoDestructionService.shouldAutoApplyDefault;
        _autoDestructionLoading = false;
      });
    } catch (e) {
      setState(() => _autoDestructionLoading = false);
    }
  }

  // NUEVO: Inicializar servicio de sesiones activas
  Future<void> _initializeSessionService() async {
    setState(() => _sessionLoading = true);

    try {
      await _sessionService.initialize();
      setState(() => _sessionLoading = false);
    } catch (e) {
      setState(() => _sessionLoading = false);
    }
  }

  // NUEVO: Manejar cambio en tiempo por defecto
  Future<void> _setDefaultDestructionTime(int? minutes) async {
    setState(() => _autoDestructionLoading = true);

    try {
      final success =
          await _autoDestructionService.setDefaultDestructionMinutes(minutes);

      if (success) {
        setState(() {
          _defaultDestructionMinutes = minutes;
          _autoDestructionLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              minutes != null
                  ? '🔥 Auto-destrucción por defecto: ${_autoDestructionService.getTimeLabel(minutes)}'
                  : '🔥 Auto-destrucción por defecto deshabilitada',
            ),
            backgroundColor: minutes != null ? Colors.orange : Colors.grey,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        setState(() => _autoDestructionLoading = false);
        _showError('Error actualizando configuración de auto-destrucción');
      }
    } catch (e) {
      setState(() => _autoDestructionLoading = false);
      _showError('Error: $e');
    }
  }

  // NUEVO: Manejar cambio en auto-aplicar
  Future<void> _toggleAutoApplyDefault(bool enabled) async {
    setState(() => _autoDestructionLoading = true);

    try {
      final success =
          await _autoDestructionService.setAutoApplyDefault(enabled);

      if (success) {
        setState(() {
          _autoApplyDefault = enabled;
          _autoDestructionLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              enabled
                  ? '🔥 Auto-aplicar HABILITADO - Se aplicará al unirse a salas'
                  : '🔥 Auto-aplicar DESHABILITADO',
            ),
            backgroundColor: enabled ? Colors.orange : Colors.grey,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        setState(() => _autoDestructionLoading = false);
        _showError('Error actualizando auto-aplicar');
      }
    } catch (e) {
      setState(() => _autoDestructionLoading = false);
      _showError('Error: $e');
    }
  }

  Widget _buildAutoDestructionSettings() {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_delete, color: Colors.deepOrange),
                const SizedBox(width: 8),
                Text(
                  l10n.autoDestructionDefault,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              l10n.autoDestructionDescription,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),

            // Selector de tiempo por defecto
            Row(
              children: [
                const Icon(Icons.timer, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Text(
                  l10n.defaultTime,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int?>(
                        value: _defaultDestructionMinutes,
                        icon: _autoDestructionLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.keyboard_arrow_down, size: 16),
                        isDense: true,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black87),
                        onChanged: _autoDestructionLoading
                            ? null
                            : _setDefaultDestructionTime,
                        items: AutoDestructionPreferencesService
                            .destructionOptions
                            .map((option) {
                          final minutes = option['minutes'] as int?;
                          return DropdownMenuItem<int?>(
                            value: minutes,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  option['icon'],
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _autoDestructionService
                                      .getShortTimeLabel(minutes),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            if (_defaultDestructionMinutes != null) ...[
              const SizedBox(height: 16),

              // Switch para auto-aplicar
              SwitchListTile(
                title: Text(l10n.autoApplyDefault),
                subtitle: Text(
                  _autoApplyDefault
                      ? l10n.autoApplyEnabled
                      : l10n.autoApplyDisabled,
                  style: TextStyle(
                    color: _autoApplyDefault ? Colors.green : Colors.grey,
                    fontSize: 12,
                  ),
                ),
                value: _autoApplyDefault,
                onChanged:
                    _autoDestructionLoading ? null : _toggleAutoApplyDefault,
                secondary: Icon(
                  _autoApplyDefault ? Icons.auto_awesome : Icons.touch_app,
                  color: _autoApplyDefault ? Colors.green : Colors.grey,
                ),
                contentPadding: EdgeInsets.zero,
              ),

              const SizedBox(height: 8),

              // Información sobre la configuración actual
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Text(
                      _autoDestructionService
                          .getTimeIcon(_defaultDestructionMinutes),
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.currentConfiguration,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[800],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '• Tiempo: ${_autoDestructionService.getTimeLabel(_defaultDestructionMinutes)}\n'
                            '• Auto-aplicar: ${_autoApplyDefault ? 'SÍ' : 'NO'}\n'
                            '• Similar a Signal y Telegram',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (_defaultDestructionMinutes == null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.selectTime,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSessionsSection() {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.devices, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  l10n.activeSessions,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              l10n.activeSessionsDescription,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),

            // Estado actual de manera más segura
            if (_sessionLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else
              _buildSessionStatusSafe(),

            const SizedBox(height: 16),

            // Botón principal
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  try {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ActiveSessionsScreen(),
                      ),
                    );

                    // Actualizar estado si es necesario
                    if (result == true && mounted) {
                      setState(() => _sessionLoading = true);
                      try {
                        await _sessionService.refreshActiveSessions();
                      } catch (e) {
                        // Error refrescando sesiones
                      }
                      if (mounted) {
                        setState(() => _sessionLoading = false);
                      }
                    }
                  } catch (e) {
                    // Error navegando a sesiones activas
                  }
                },
                icon: const Icon(Icons.devices),
                label: Text(l10n.manageSessions),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Configuración rápida de manera más segura
            _buildMultipleSessionsToggleSafe(),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionStatusSafe() {
    final l10n = AppLocalizations.of(context)!;
    try {
      bool hasActiveSessions = false;
      int activeCount = 0;
      int onlineCount = 0;
      bool allowMultiple = false;

      // Obtener información de manera segura
      try {
        hasActiveSessions = _sessionService.hasActiveSessions;
        activeCount = _sessionService.activeSessions.length;
        onlineCount =
            _sessionService.activeSessions.where((s) => s.isActive).length;
        allowMultiple = _sessionService.allowMultipleSessions;
      } catch (e) {
        // Usar valores por defecto seguros
        hasActiveSessions = false;
        activeCount = 0;
        onlineCount = 0;
        allowMultiple = false;
      }

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.purple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.purple.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.info, color: Colors.purple, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.currentState,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasActiveSessions
                        ? '• $activeCount ${activeCount == 1 ? l10n.sessionActive : l10n.sessionsActive}\n'
                            '• $onlineCount en línea ahora\n'
                            '• ${l10n.multipleSessions}: ${allowMultiple ? 'Habilitado' : 'Deshabilitado'}'
                        : '• ${l10n.noActiveSessionsMessage}\n'
                            '• ${l10n.multipleSessions}: ${allowMultiple ? 'Habilitado' : 'Deshabilitado'}\n'
                            '• ${l10n.configurationLikeSignal}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.purple[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      // Widget de fallback
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        child: const Row(
          children: [
            Icon(Icons.info, color: Colors.grey, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Estado de sesiones temporalmente no disponible',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildMultipleSessionsToggleSafe() {
    final l10n = AppLocalizations.of(context)!;
    try {
      bool allowMultiple = false;

      try {
        allowMultiple = _sessionService.allowMultipleSessions;
      } catch (e) {
        allowMultiple = false; // Valor por defecto seguro
      }

      return SwitchListTile(
        title: Text(l10n.allowMultipleSessions),
        subtitle: Text(
          allowMultiple
              ? 'Puedes usar varios dispositivos simultáneamente'
              : l10n.onlyOneActiveSession,
          style: const TextStyle(fontSize: 12),
        ),
        value: allowMultiple,
        onChanged: (value) {
          try {
            _sessionService.updateSessionSettings(allowMultiple: value);
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Error actualizando configuración'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
        secondary: Icon(
          allowMultiple ? Icons.devices : Icons.smartphone,
          color: Colors.purple,
        ),
        contentPadding: EdgeInsets.zero,
      );
    } catch (e) {
      // Widget de fallback
      return const ListTile(
        leading: Icon(Icons.smartphone, color: Colors.grey),
        title: Text('Configuración de sesiones'),
        subtitle: Text('Temporalmente no disponible'),
        contentPadding: EdgeInsets.zero,
      );
    }
  }

  Widget _buildHelpSection() {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.help_outline, color: Colors.teal),
                const SizedBox(width: 8),
                Text(
                  l10n.helpSection,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              l10n.helpAndSupport,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),

            // Centro de asistencia
            _buildHelpOption(
              icon: Icons.support_agent,
              title: l10n.supportCenter,
              subtitle: l10n.supportCenterDescription,
              onTap: () => _openUrl(
                  'https://r00tedbrain.github.io/Flutter-Putter-Support/'),
            ),

            const SizedBox(height: 12),

            // Contacta con nosotros
            _buildHelpOption(
              icon: Icons.email,
              title: l10n.contactUs,
              subtitle: l10n.contactEmail,
              onTap: () => _copyEmailToClipboard(),
            ),

            const SizedBox(height: 12),

            // Versión
            _buildHelpOption(
              icon: Icons.info,
              title: l10n.appVersion,
              subtitle: l10n.versionNumber,
              onTap: null,
            ),

            const SizedBox(height: 12),

            // Términos y condiciones
            _buildHelpOption(
              icon: Icons.description,
              title: l10n.termsAndConditions,
              subtitle: l10n.termsDescription,
              onTap: () => _openUrl(
                  'https://r00tedbrain.github.io/Flutter-Putter-TemsOfService/'),
            ),

            const SizedBox(height: 12),

            // Política de privacidad - Con log final para iOS
            _buildHelpOption(
              icon: Icons.privacy_tip,
              title: l10n.privacyPolicy,
              subtitle: l10n.privacyPolicyDescription,
              onTap: () => _openUrl(
                  'https://r00tedbrain.github.io/Flutter-Putter-PrivacyPolicy/'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpOption({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.teal, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    try {
      // Determinar el título basado en la URL
      String title = 'FlutterPutter';
      if (url.contains('Support')) {
        title = 'Centro de Asistencia';
      } else if (url.contains('TemsOfService')) {
        title = 'Términos y Condiciones';
      } else if (url.contains('PrivacyPolicy')) {
        title = 'Política de Privacidad';
      }

      if (kIsWeb) {
        // En Web: Abrir directamente en nueva pestaña
        final Uri uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          throw 'No se puede abrir la URL en Web';
        }
      } else {
        // En iOS/Android: Usar WebView integrado
        if (!mounted) return;

        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => WebViewScreen(
              url: url,
              title: title,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al abrir la página web: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _copyEmailToClipboard() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await Clipboard.setData(
          const ClipboardData(text: 'FlutterPutter@Proton.me'));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.emailCopied),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorCopyingEmail),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Lista de widgets - SIN CONDICIONALES PROBLEMÁTICAS
    final List<Widget> allWidgets = [
      // Información general
      Card(
        elevation: 4,
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Icon(
                Icons.security,
                size: 48,
                color: Colors.blue,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.protectYourApp,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.securityPinDescription,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),

      // Sección de configuración de PIN
      _buildPinSetupSection(),

      // Configuración de tiempo
      _buildTimeoutSettings(),

      // Configuración biométrica
      _buildBiometricSettings(),

      // Configuración de seguridad de capturas
      _buildScreenshotSettings(),

      // Configuración de auto-destrucción
      _buildAutoDestructionSettings(),

      // Configuración de sesiones activas
      _buildSessionsSection(),

      // ✅ SECCIÓN: Ayuda y Soporte - SIN CONDICIONALES
      _buildHelpSection(),

      // Espacio final
      const SizedBox(height: 32),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.securitySettings),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      // ✅ SOLUCIÓN: UN SOLO SCROLL VIEW PARA TODAS LAS PLATAFORMAS
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: allWidgets,
        ),
      ),
    );
  }
}
