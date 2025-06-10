import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutterputter/providers/auth_provider.dart';
import 'package:flutterputter/widgets/auth_text_field.dart';
import 'package:flutterputter/widgets/legal_notice_widget.dart';
import 'package:flutterputter/l10n/app_localizations.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _invitationCodeController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nicknameController.dispose();
    _invitationCodeController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    });
  }

  String? _validateEmail(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return l10n.pleaseEnterEmail;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return l10n.enterValidEmail;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return l10n.pleaseEnterPassword;
    }
    if (value.length < 6) {
      return l10n.passwordMinLength;
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return l10n.pleaseConfirmPassword;
    }
    if (value != _passwordController.text) {
      return l10n.passwordsDoNotMatch;
    }
    return null;
  }

  String? _validateNickname(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return l10n.pleaseEnterNickname;
    }
    if (value.length < 3) {
      return l10n.nicknameMinLength;
    }
    return null;
  }

  String? _validateInvitationCode(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return l10n.pleaseEnterInvitationCode;
    }
    if (value.length != 8) {
      return l10n.invitationCodeLength;
    }
    return null;
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.register(
        _emailController.text.trim(),
        _passwordController.text,
        _nicknameController.text.trim(),
        _invitationCodeController.text.trim(),
      );

      if (success && mounted) {
        Navigator.pushReplacementNamed(context, '/encrypting');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/fondoflutterputter.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar personalizada
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Contenido principal
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Título
                            Text(
                              l10n.createAccount,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Subtítulo
                            Text(
                              l10n.registerSubtitle,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),

                            // Campo de email
                            AuthTextField(
                              controller: _emailController,
                              labelText: l10n.email,
                              hintText: l10n.enterEmail,
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: _validateEmail,
                            ),
                            const SizedBox(height: 16),

                            // Campo de nickname
                            AuthTextField(
                              controller: _nicknameController,
                              labelText: l10n.nickname,
                              hintText: l10n.chooseUniqueNickname,
                              icon: Icons.person_outline,
                              validator: _validateNickname,
                            ),
                            const SizedBox(height: 16),

                            // Campo de contraseña
                            AuthTextField(
                              controller: _passwordController,
                              labelText: l10n.password,
                              hintText: l10n.createSecurePassword,
                              icon: Icons.lock_outline,
                              obscureText: !_isPasswordVisible,
                              validator: _validatePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey,
                                ),
                                onPressed: _togglePasswordVisibility,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Campo de confirmar contraseña
                            AuthTextField(
                              controller: _confirmPasswordController,
                              labelText: l10n.confirmPassword,
                              hintText: l10n.repeatPassword,
                              icon: Icons.lock_outline,
                              obscureText: !_isConfirmPasswordVisible,
                              validator: _validateConfirmPassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isConfirmPasswordVisible
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey,
                                ),
                                onPressed: _toggleConfirmPasswordVisibility,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Campo de código de invitación
                            AuthTextField(
                              controller: _invitationCodeController,
                              labelText: l10n.invitationCode,
                              hintText: l10n.enterInvitationCode,
                              icon: Icons.card_giftcard_outlined,
                              validator: _validateInvitationCode,
                            ),
                            const SizedBox(height: 24),

                            // Mostrar error si existe
                            if (authProvider.error != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Text(
                                  authProvider.error!,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                  ),
                                ),
                              ),

                            // Aviso legal y de privacidad
                            const LegalNoticeWidget(),
                            const SizedBox(height: 16),

                            // Botón de registro
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed:
                                    authProvider.isLoading ? null : _submitForm,
                                child: authProvider.isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white)
                                    : Text(
                                        l10n.registerButton,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
