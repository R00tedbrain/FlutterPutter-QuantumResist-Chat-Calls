import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Servicio de verificación de identidad anónima
/// NO modifica ningún sistema existente, solo genera códigos localmente
class VerificationService {
  static final VerificationService _instance = VerificationService._internal();
  factory VerificationService() => _instance;
  VerificationService._internal();

  String? _myVerificationCode;
  String? _partnerVerificationCode;
  bool _isVerified = false;
  String? _currentRoomId;

  // Emojis para códigos visuales
  static const List<String> _emojis = [
    '🐱',
    '🐶',
    '🦊',
    '🐻',
    '🐼',
    '🦁',
    '🐯',
    '🐸',
    '🌟',
    '⭐',
    '✨',
    '🎯',
    '🔥',
    '💎',
    '🎪',
    '🎨',
    '🚀',
    '🎭',
    '🎪',
    '🎨',
    '🎯',
    '🎲',
    '🎮',
    '🎸'
  ];

  /// Generar códigos de verificación únicos para la sala
  Map<String, String> generateVerificationCodes(String roomId, String userId) {
    _currentRoomId = roomId;

    // Crear semilla única basada en sala, usuario y timestamp
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final seed = '$roomId-$userId-$timestamp';

    // Generar hash SHA-256
    final bytes = utf8.encode(seed);
    final digest = sha256.convert(bytes);
    final hash = digest.toString();

    // Extraer diferentes tipos de códigos del hash
    final alphanumeric = hash.substring(0, 8).toUpperCase();
    final numericValue = int.parse(hash.substring(8, 14), radix: 16) % 1000000;
    final numeric = numericValue.toString().padLeft(6, '0');
    final emoji = _generateEmojiCode(hash);

    _myVerificationCode = alphanumeric;

    print('🔑 [VERIFICATION] Códigos generados para sala $roomId');
    print('🔑 [VERIFICATION] Alfanumérico: $alphanumeric');
    print('🔑 [VERIFICATION] Numérico: $numeric');
    print('🔑 [VERIFICATION] Emoji: $emoji');

    return {
      'alphanumeric': alphanumeric,
      'numeric': numeric,
      'emoji': emoji,
      'timestamp': timestamp.toString(),
    };
  }

  /// Generar código de emojis desde hash
  String _generateEmojiCode(String hash) {
    String emojiCode = '';
    for (int i = 0; i < 4; i++) {
      final hexPair = hash.substring(i * 2, i * 2 + 2);
      final index = int.parse(hexPair, radix: 16) % _emojis.length;
      emojiCode += _emojis[index];
    }
    return emojiCode;
  }

  /// Verificar código proporcionado por el partner
  bool verifyPartnerCode(String providedCode) {
    if (_partnerVerificationCode == null) {
      print('🔑 [VERIFICATION] ❌ No hay código del partner para verificar');
      return false;
    }

    final normalizedProvided = providedCode.trim().toUpperCase();
    final normalizedPartner = _partnerVerificationCode!.trim().toUpperCase();

    _isVerified = normalizedProvided == normalizedPartner;

    if (_isVerified) {
      print('🔑 [VERIFICATION] ✅ Código verificado correctamente');
    } else {
      print('🔑 [VERIFICATION] ❌ Código incorrecto');
      print('🔑 [VERIFICATION] Esperado: $normalizedPartner');
      print('🔑 [VERIFICATION] Recibido: $normalizedProvided');
    }

    return _isVerified;
  }

  /// Establecer código del partner (cuando se recibe)
  void setPartnerCode(String code) {
    _partnerVerificationCode = code.trim();
    print('🔑 [VERIFICATION] 📥 Código del partner recibido: $code');
  }

  /// Regenerar códigos (útil si se quiere cambiar)
  Map<String, String> regenerateCodes(String roomId, String userId) {
    print('🔑 [VERIFICATION] 🔄 Regenerando códigos...');
    _myVerificationCode = null;
    _partnerVerificationCode = null;
    _isVerified = false;

    return generateVerificationCodes(roomId, userId);
  }

  /// Limpiar estado al salir de la sala
  void clearVerification() {
    print('🔑 [VERIFICATION] 🧹 Limpiando estado de verificación');
    _myVerificationCode = null;
    _partnerVerificationCode = null;
    _isVerified = false;
    _currentRoomId = null;
  }

  // Getters para el estado actual
  String? get myCode => _myVerificationCode;
  String? get partnerCode => _partnerVerificationCode;
  bool get isVerified => _isVerified;
  String? get currentRoomId => _currentRoomId;

  /// Generar código QR-friendly (solo números y letras)
  String generateQRCode(String roomId, String userId) {
    final codes = generateVerificationCodes(roomId, userId);
    return codes['alphanumeric']!;
  }

  /// Validar formato de código
  bool isValidCodeFormat(String code) {
    final trimmed = code.trim();

    // Alfanumérico (8 caracteres)
    if (RegExp(r'^[A-Z0-9]{8}$').hasMatch(trimmed.toUpperCase())) {
      return true;
    }

    // Numérico (6 dígitos)
    if (RegExp(r'^\d{6}$').hasMatch(trimmed)) {
      return true;
    }

    // Emoji (4 emojis)
    if (trimmed.length >= 4 && _containsOnlyEmojis(trimmed)) {
      return true;
    }

    return false;
  }

  /// Verificar si string contiene solo emojis válidos
  bool _containsOnlyEmojis(String text) {
    final runes = text.runes.toList();
    if (runes.length != 4) return false;

    for (final rune in runes) {
      final emoji = String.fromCharCode(rune);
      if (!_emojis.contains(emoji)) return false;
    }

    return true;
  }

  /// Obtener estadísticas de verificación
  Map<String, dynamic> getVerificationStats() {
    return {
      'hasMyCode': _myVerificationCode != null,
      'hasPartnerCode': _partnerVerificationCode != null,
      'isVerified': _isVerified,
      'currentRoom': _currentRoomId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }
}
