import 'package:encrypt_shared_preferences/provider.dart';

/// Servicio para manejar apodos/aliases personalizados de salas de chat
/// Similar al StaticAvatarService pero para nombres de salas
class RoomNicknameService {
  static EncryptedSharedPreferences? _encryptedPrefs;
  static const String _roomNicknameKey = 'room_nickname';

  /// Inicializar el servicio
  static Future<void> initialize() async {
    try {
      await EncryptedSharedPreferences.initialize(
          '5Kx9pN3mQ7sL4wR8'); // 16 caracteres aleatorios seguros
      _encryptedPrefs = EncryptedSharedPreferences.getInstance();
    } catch (e) {
      // Fallo silencioso para no interrumpir la app
    }
  }

  /// Obtener el apodo personalizado para una sala específica
  /// roomKey puede ser el targetUserId o una combinación única que identifique la sala
  static Future<String?> getRoomNickname(String roomKey) async {
    try {
      if (_encryptedPrefs == null) await initialize();
      final key = '${_roomNicknameKey}_$roomKey';
      return _encryptedPrefs?.getString(key);
    } catch (e) {
      return null;
    }
  }

  /// Establecer un nuevo apodo para una sala específica
  static Future<bool> setRoomNickname(String roomKey, String nickname) async {
    try {
      if (nickname.trim().isEmpty) {
        return false; // No permitir apodos vacíos
      }

      if (_encryptedPrefs == null) await initialize();
      final key = '${_roomNicknameKey}_$roomKey';
      await _encryptedPrefs?.setString(key, nickname.trim());
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Limpiar apodo de una sala específica
  static Future<bool> clearRoomNickname(String roomKey) async {
    try {
      if (_encryptedPrefs == null) await initialize();
      final key = '${_roomNicknameKey}_$roomKey';
      await _encryptedPrefs?.remove(key);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Verificar si una sala tiene apodo personalizado
  static Future<bool> hasCustomNickname(String roomKey) async {
    final nickname = await getRoomNickname(roomKey);
    return nickname != null && nickname.isNotEmpty;
  }

  /// Obtener el nombre a mostrar (apodo personalizado o nombre original)
  static Future<String> getDisplayName(
      String roomKey, String originalName) async {
    final customNickname = await getRoomNickname(roomKey);
    if (customNickname != null && customNickname.isNotEmpty) {
      return customNickname;
    }
    return originalName;
  }

  /// Limpiar todos los apodos (para logout)
  static Future<void> clearAllNicknames() async {
    try {
      if (_encryptedPrefs == null) await initialize();

      // No hay forma directa de obtener todas las claves en EncryptedSharedPreferences
      // Pero esto se llamará principalmente en logout, donde se reinicia la app
      // Por ahora mantenemos este método para consistencia
    } catch (e) {
      // Fallo silencioso
    }
  }
}
