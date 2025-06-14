import 'package:flutter/material.dart';
import 'package:encrypt_shared_preferences/provider.dart';

class StaticAvatarService {
  static EncryptedSharedPreferences? _encryptedPrefs;
  static const String _selectedAvatarKey = 'selected_static_avatar';

  // Lista de avatares disponibles (tú los agregaste como PNG)
  static const List<String> availableAvatars = [
    'assets/images/avatars/avatar1.png',
    'assets/images/avatars/avatar2.png',
    'assets/images/avatars/avatar3.png',
    'assets/images/avatars/avatar4.png',
    'assets/images/avatars/avatar5.png',
    'assets/images/avatars/avatar6.png',
    'assets/images/avatars/avatar7.png',
    'assets/images/avatars/avatar8.png',
    'assets/images/avatars/avatar9.png',
    'assets/images/avatars/avatar10.png',
  ];

  /// Inicializar el servicio
  static Future<void> initialize() async {
    try {
      await EncryptedSharedPreferences.initialize(
          '3Av8tR2sM9qL1kX7'); // 16 caracteres aleatorios seguros
      _encryptedPrefs = EncryptedSharedPreferences.getInstance();
    } catch (e) {
      // Fallo silencioso para no interrumpir la app
    }
  }

  /// Obtener el avatar seleccionado para un usuario específico
  static Future<String?> getSelectedAvatar({String? userId}) async {
    try {
      if (_encryptedPrefs == null) await initialize();
      final key =
          userId != null ? '${_selectedAvatarKey}_$userId' : _selectedAvatarKey;
      return _encryptedPrefs?.getString(key);
    } catch (e) {
      return null;
    }
  }

  /// Establecer un nuevo avatar para un usuario específico
  static Future<bool> setSelectedAvatar(String avatarPath,
      {String? userId}) async {
    try {
      if (!availableAvatars.contains(avatarPath)) {
        return false; // Avatar no válido
      }

      if (_encryptedPrefs == null) await initialize();
      final key =
          userId != null ? '${_selectedAvatarKey}_$userId' : _selectedAvatarKey;
      await _encryptedPrefs?.setString(key, avatarPath);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Limpiar avatar seleccionado para un usuario específico
  static Future<bool> clearSelectedAvatar({String? userId}) async {
    try {
      if (_encryptedPrefs == null) await initialize();
      final key =
          userId != null ? '${_selectedAvatarKey}_$userId' : _selectedAvatarKey;
      await _encryptedPrefs?.remove(key);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Verificar si hay un avatar seleccionado
  static Future<bool> hasSelectedAvatar({String? userId}) async {
    final avatar = await getSelectedAvatar(userId: userId);
    return avatar != null && avatar.isNotEmpty;
  }

  /// Asignar avatar aleatorio a un usuario desconocido
  static Future<String> getOrAssignRandomAvatar(String userId) async {
    // Primero verificar si ya tiene avatar asignado
    final existingAvatar = await getSelectedAvatar(userId: userId);
    if (existingAvatar != null && existingAvatar.isNotEmpty) {
      return existingAvatar;
    }

    // Si no tiene avatar, asignar uno aleatorio basado en su ID
    final avatarIndex = userId.hashCode.abs() % availableAvatars.length;
    final randomAvatar = availableAvatars[avatarIndex];

    // Guardar para que siempre use el mismo
    await setSelectedAvatar(randomAvatar, userId: userId);

    return randomAvatar;
  }

  /// Widget para mostrar el avatar en UI de chat (miniatura)
  static Widget buildChatAvatar({
    required String name,
    double radius = 16,
    String? selectedAvatar,
  }) {
    if (selectedAvatar != null && selectedAvatar.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: AssetImage(selectedAvatar),
        backgroundColor: Colors.transparent,
      );
    }

    // Fallback a iniciales con color generado
    final initials = _getInitials(name);
    final avatarColor = _getAvatarColor(name);

    return CircleAvatar(
      radius: radius,
      backgroundColor: avatarColor,
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.7,
        ),
      ),
    );
  }

  /// Obtener iniciales del nombre
  static String _getInitials(String name) {
    if (name.isEmpty) return '';

    final nameParts = name.trim().split(' ');
    if (nameParts.length > 1) {
      return nameParts[0][0].toUpperCase() + nameParts[1][0].toUpperCase();
    }

    return name.substring(0, name.length > 1 ? 2 : 1).toUpperCase();
  }

  /// Generar color basado en el nombre
  static Color _getAvatarColor(String name) {
    final colorValue =
        name.codeUnits.fold<int>(0, (prev, element) => prev + element);
    return Color.fromARGB(
      255,
      (colorValue * 33) % 255,
      (colorValue * 73) % 255,
      (colorValue * 153) % 255,
    );
  }
}
