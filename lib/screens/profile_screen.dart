import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutterputter/providers/auth_provider.dart';
import 'package:flutterputter/widgets/auth_text_field.dart';
import 'package:flutterputter/widgets/user_avatar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nicknameController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    _nicknameController = TextEditingController(text: user?.nickname);
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  String? _validateNickname(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, ingresa un nickname';
    }
    if (value.length < 3) {
      return 'El nickname debe tener al menos 3 caracteres';
    }
    return null;
  }

  // Actualizar nickname
  Future<void> _updateNickname() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.updateNickname(
      _nicknameController.text.trim(),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nickname actualizado correctamente')),
      );
      setState(() {
        _isEditing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar
            Center(
              child: UserAvatar(
                name: user.nickname,
                radius: 60,
              ),
            ),
            const SizedBox(height: 24),

            // Información del usuario
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Email
                    const Text(
                      'Email',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Nickname
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Nickname',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        if (!_isEditing)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isEditing = true;
                              });
                            },
                            child: const Text('Editar'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    if (_isEditing)
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            AuthTextField(
                              controller: _nicknameController,
                              labelText: 'Nickname',
                              hintText: 'Ingresa tu nickname',
                              icon: Icons.person_outline,
                              validator: _validateNickname,
                            ),
                            const SizedBox(height: 16),

                            // Botones
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _nicknameController.text = user.nickname;
                                      _isEditing = false;
                                    });
                                  },
                                  child: const Text('Cancelar'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: authProvider.isLoading
                                      ? null
                                      : _updateNickname,
                                  child: authProvider.isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text('Guardar'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    else
                      Text(
                        user.nickname,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Mostrar error si existe
            if (authProvider.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  authProvider.error!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Cuenta creada el
            Text(
              'Cuenta creada el ${_formatDate(user.createdAt)}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
