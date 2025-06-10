import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_lock_service.dart';

class AppLockScreen extends StatefulWidget {
  const AppLockScreen({super.key});

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen>
    with TickerProviderStateMixin {
  final TextEditingController _pinController = TextEditingController();
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  bool _obscurePin = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));
  }

  @override
  void dispose() {
    _pinController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _verifyPin() async {
    if (_pinController.text.isEmpty) return;

    setState(() => _isLoading = true);

    final appLockService = Provider.of<AppLockService>(context, listen: false);
    final isValid = await appLockService.verifyPin(_pinController.text);

    setState(() => _isLoading = false);

    if (isValid) {
      // PIN correcto - la pantalla se cerrará automáticamente
      // porque el AppLockService notificará el cambio
    } else {
      // PIN incorrecto - mostrar animación de error
      _shakeController.forward().then((_) {
        _shakeController.reset();
      });
      _pinController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔒 PIN incorrecto'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    setState(() => _isLoading = true);

    final appLockService = Provider.of<AppLockService>(context, listen: false);
    final success = await appLockService.authenticateWithBiometrics();

    setState(() => _isLoading = false);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔐 Autenticación biométrica fallida'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildNumberPad() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 1.2,
        ),
        itemCount: 12,
        itemBuilder: (context, index) {
          if (index == 9) {
            // Botón de biometría (si está disponible)
            return Consumer<AppLockService>(
              builder: (context, appLockService, child) {
                if (!appLockService.biometricEnabled) {
                  return const SizedBox();
                }

                return _NumberPadButton(
                  onTap: _authenticateWithBiometrics,
                  child: const Icon(
                    Icons.fingerprint,
                    size: 32,
                    color: Colors.white,
                  ),
                );
              },
            );
          } else if (index == 10) {
            // Número 0
            return _NumberPadButton(
              onTap: () => _addDigit('0'),
              child: const Text(
                '0',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            );
          } else if (index == 11) {
            // Botón borrar
            return _NumberPadButton(
              onTap: _removeLastDigit,
              child: const Icon(
                Icons.backspace_outlined,
                size: 28,
                color: Colors.white,
              ),
            );
          } else {
            // Números 1-9
            final number = (index + 1).toString();
            return _NumberPadButton(
              onTap: () => _addDigit(number),
              child: Text(
                number,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            );
          }
        },
      ),
    );
  }

  void _addDigit(String digit) {
    if (_pinController.text.length < 15) {
      setState(() {
        _pinController.text += digit;
      });
    }
  }

  void _removeLastDigit() {
    if (_pinController.text.isNotEmpty) {
      setState(() {
        _pinController.text =
            _pinController.text.substring(0, _pinController.text.length - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1e3c72),
              Color(0xFF2a5298),
              Color(0xFF6a85b6),
              Color(0xFFbac8e0),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo o icono de la app
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.lock_rounded,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Título
                  const Text(
                    'FlutterPutter',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: Offset(2, 2),
                          blurRadius: 4,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Subtítulo
                  const Text(
                    'Ingresa tu PIN para desbloquear',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      shadows: [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 2,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Campo PIN con animación de shake
                  AnimatedBuilder(
                    animation: _shakeAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(
                          _shakeAnimation.value *
                              10 *
                              ((_shakeController.value * 4).round() % 2 == 0
                                  ? 1
                                  : -1),
                          0,
                        ),
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 300),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: TextField(
                            controller: _pinController,
                            obscureText: _obscurePin,
                            readOnly: true,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 4,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'PIN',
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 18,
                              ),
                              suffixIcon: _pinController.text.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(
                                        _obscurePin
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: Colors.white70,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePin = !_obscurePin;
                                        });
                                      },
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 48),

                  // Teclado numérico
                  _buildNumberPad(),
                  const SizedBox(height: 32),

                  // Botón de desbloquear
                  if (_pinController.text.isNotEmpty)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: SizedBox(
                        width: 200,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _verifyPin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.withOpacity(0.9),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.lock_open, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'Desbloquear',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NumberPadButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const _NumberPadButton({
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.1),
      borderRadius: BorderRadius.circular(50),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}
