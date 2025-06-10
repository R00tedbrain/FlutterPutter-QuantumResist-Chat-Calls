import 'dart:typed_data';
import 'package:flutter/foundation.dart';

// Solo importar dart:js y dart:html en Web (cuando dart.library.html está disponible)
import 'dart:js' if (dart.library.io) './kyber_web_stub.dart' as js;
import 'dart:html' if (dart.library.io) './kyber_web_stub.dart' as html;

// Solo importar xkyber_crypto en móvil (cuando dart.library.io está disponible)
// ignore: depend_on_referenced_packages
import 'package:xkyber_crypto/xkyber_crypto.dart'
    if (dart.library.html) './kyber_web_stub.dart';

/// Servicio universal de criptografía post-cuántica usando Kyber
///
/// FUNCIONA EN TODAS LAS PLATAFORMAS:
/// - Web: Usa @noble/post-quantum via JavaScript
/// - Móvil: Usa xkyber_crypto nativo
/// - Misma interfaz y algoritmo en ambas plataformas
/// - Compatible con intercambio entre Web ↔ Móvil
class KyberServiceUniversal {
  static const String _logPrefix = '🔐 [KYBER-UNIVERSAL]';

  // Estado del servicio
  static bool _isInitialized = false;
  static bool _isAvailable = false;
  static final bool _isWeb = kIsWeb;

  /// Inicializa el servicio Kyber (detecta plataforma automáticamente)
  static Future<bool> initialize() async {
    try {
      print('$_logPrefix Inicializando servicio post-cuántico universal...');
      print('$_logPrefix 🌐 Plataforma detectada: ${_isWeb ? "Web" : "Móvil"}');

      if (_isWeb) {
        return await _initializeWeb();
      } else {
        return await _initializeMobile();
      }
    } catch (e) {
      print('$_logPrefix ❌ Error inicializando: $e');
      _isAvailable = false;
      _isInitialized = false;
      return false;
    }
  }

  /// Inicialización para plataforma Web
  static Future<bool> _initializeWeb() async {
    try {
      print('$_logPrefix 🌐 Inicializando Kyber para Web...');

      // Verificar que @noble/post-quantum esté disponible
      if (!_isNoblePostQuantumAvailable()) {
        throw Exception('@noble/post-quantum no está disponible');
      }

      // Test básico con noble-post-quantum
      final result = await _testNobleKyber();

      if (result) {
        _isAvailable = true;
        _isInitialized = true;
        print('$_logPrefix ✅ Kyber Web disponible (@noble/post-quantum)');
        print('$_logPrefix 🛡️ Algoritmo: ML-KEM-768 (equivalente a Kyber768)');
        print('$_logPrefix 🔮 Resistencia post-cuántica: ACTIVA');
        return true;
      } else {
        throw Exception('Test de noble-post-quantum falló');
      }
    } catch (e) {
      print('$_logPrefix ⚠️ Kyber Web no disponible: $e');
      print('$_logPrefix 🔄 Fallback a cifrado clásico');
      return false;
    }
  }

  /// Inicialización para plataforma móvil
  static Future<bool> _initializeMobile() async {
    if (_isWeb) return false; // Seguridad extra

    try {
      print('$_logPrefix 📱 Inicializando Kyber para móvil...');

      // Test básico para verificar que Kyber funciona
      final testKeyPair = KyberKeyPair.generate();

      if (testKeyPair.publicKey.isNotEmpty &&
          testKeyPair.secretKey.isNotEmpty) {
        _isAvailable = true;
        _isInitialized = true;

        print('$_logPrefix ✅ Kyber móvil disponible (xkyber_crypto)');
        print(
            '$_logPrefix 📊 Clave pública: ${testKeyPair.publicKey.length} bytes');
        print(
            '$_logPrefix 📊 Clave secreta: ${testKeyPair.secretKey.length} bytes');
        print('$_logPrefix 🛡️ Algoritmo: Kyber768');
        print('$_logPrefix 🔮 Resistencia post-cuántica: ACTIVA');

        return true;
      } else {
        throw Exception('Claves vacías generadas');
      }
    } catch (e) {
      print('$_logPrefix ⚠️ Kyber móvil no disponible: $e');
      print('$_logPrefix 🔄 Fallback a cifrado clásico');
      return false;
    }
  }

  /// Verifica si @noble/post-quantum está disponible en Web
  static bool _isNoblePostQuantumAvailable() {
    if (!_isWeb) return false;

    try {
      // Verificar que el módulo esté cargado
      final module = js.context['mlkem'];
      return module != null;
    } catch (e) {
      return false;
    }
  }

  /// Test básico de noble-post-quantum
  static Future<bool> _testNobleKyber() async {
    if (!_isWeb) return false;

    try {
      // Llamar a JavaScript para test básico
      final result = js.context.callMethod('testNobleKyber');
      return result == true;
    } catch (e) {
      print('$_logPrefix ❌ Error en test noble: $e');
      return false;
    }
  }

  /// Verifica si Kyber está disponible
  static bool get isAvailable => _isAvailable && _isInitialized;

  /// Genera un par de claves Kyber (universal)
  static Future<Map<String, Uint8List>> generateKeyPair() async {
    if (!isAvailable) {
      throw Exception(
          'Kyber no está disponible. Llama a initialize() primero.');
    }

    try {
      print('$_logPrefix Generando par de claves post-cuánticas...');

      if (_isWeb) {
        return await _generateKeyPairWeb();
      } else {
        return _generateKeyPairMobile();
      }
    } catch (e) {
      print('$_logPrefix ❌ Error generando claves: $e');
      rethrow;
    }
  }

  /// Genera par de claves en Web
  static Future<Map<String, Uint8List>> _generateKeyPairWeb() async {
    if (!_isWeb) throw Exception('Método solo para Web');

    try {
      // Llamar a JavaScript para generar claves
      final jsResult = js.context.callMethod('generateKyberKeyPair');

      final publicKey =
          Uint8List.fromList(List<int>.from(jsResult['publicKey']));
      final secretKey =
          Uint8List.fromList(List<int>.from(jsResult['secretKey']));

      print('$_logPrefix ✅ Claves Web generadas');
      print('$_logPrefix 📊 Clave pública: ${publicKey.length} bytes');
      print('$_logPrefix 📊 Clave secreta: ${secretKey.length} bytes');

      return {
        'publicKey': publicKey,
        'secretKey': secretKey,
      };
    } catch (e) {
      print('$_logPrefix ❌ Error generando claves Web: $e');
      rethrow;
    }
  }

  /// Genera par de claves en móvil
  static Map<String, Uint8List> _generateKeyPairMobile() {
    if (_isWeb) throw Exception('Método solo para móvil');

    try {
      final keyPair = KyberKeyPair.generate();

      print('$_logPrefix ✅ Claves móvil generadas');
      print('$_logPrefix 📊 Clave pública: ${keyPair.publicKey.length} bytes');
      print('$_logPrefix 📊 Clave secreta: ${keyPair.secretKey.length} bytes');

      return {
        'publicKey': keyPair.publicKey,
        'secretKey': keyPair.secretKey,
      };
    } catch (e) {
      print('$_logPrefix ❌ Error generando claves móvil: $e');
      rethrow;
    }
  }

  /// Encapsula una clave maestra de 64 bytes usando Kyber (universal)
  static Future<Uint8List> encapsulateMasterKey(
      Uint8List masterKey, Uint8List publicKey) async {
    if (!isAvailable) {
      throw Exception('Kyber no está disponible');
    }

    if (masterKey.length != 64) {
      throw Exception(
          'Clave maestra debe ser de 64 bytes, recibida: ${masterKey.length}');
    }

    try {
      print('$_logPrefix Encapsulando clave maestra...');

      if (_isWeb) {
        return await _encapsulateWeb(masterKey, publicKey);
      } else {
        return await _encapsulateMobile(masterKey, publicKey);
      }
    } catch (e) {
      print('$_logPrefix ❌ Error encapsulando: $e');
      rethrow;
    }
  }

  /// Encapsula en Web
  static Future<Uint8List> _encapsulateWeb(
      Uint8List masterKey, Uint8List publicKey) async {
    if (!_isWeb) throw Exception('Método solo para Web');

    try {
      // Llamar a JavaScript para encapsular
      final jsResult = js.context.callMethod('encapsulateKyberKey', [
        masterKey,
        publicKey,
      ]);

      final result = Uint8List.fromList(List<int>.from(jsResult));

      print('$_logPrefix ✅ Clave encapsulada (Web): ${result.length} bytes');
      return result;
    } catch (e) {
      print('$_logPrefix ❌ Error encapsulando Web: $e');
      rethrow;
    }
  }

  /// Encapsula en móvil
  static Future<Uint8List> _encapsulateMobile(
      Uint8List masterKey, Uint8List publicKey) async {
    if (_isWeb) throw Exception('Método solo para móvil');

    try {
      // Usar Kyber para encapsular un secreto compartido
      final encapsulationResult = KyberKEM.encapsulate(publicKey);
      final sharedSecret = encapsulationResult.sharedSecret; // 32 bytes
      final ciphertext = encapsulationResult.ciphertextKEM;

      // Concatenar ciphertext + master key cifrada con shared secret
      final result = Uint8List(ciphertext.length + masterKey.length);
      result.setRange(0, ciphertext.length, ciphertext);

      // XOR con el shared secret (repetido)
      for (int i = 0; i < masterKey.length; i++) {
        result[ciphertext.length + i] =
            masterKey[i] ^ sharedSecret[i % sharedSecret.length];
      }

      print('$_logPrefix ✅ Clave encapsulada (móvil): ${result.length} bytes');
      print('$_logPrefix 🔐 Ciphertext Kyber: ${ciphertext.length} bytes');

      return result;
    } catch (e) {
      print('$_logPrefix ❌ Error encapsulando móvil: $e');
      rethrow;
    }
  }

  /// Desencapsula una clave maestra usando Kyber (universal)
  static Future<Uint8List> decapsulateMasterKey(
      Uint8List encapsulatedData, Uint8List secretKey) async {
    if (!isAvailable) {
      throw Exception('Kyber no está disponible');
    }

    try {
      print('$_logPrefix Desencapsulando clave maestra...');

      if (_isWeb) {
        return await _decapsulateWeb(encapsulatedData, secretKey);
      } else {
        return await _decapsulateMobile(encapsulatedData, secretKey);
      }
    } catch (e) {
      print('$_logPrefix ❌ Error desencapsulando: $e');
      rethrow;
    }
  }

  /// Desencapsula en Web
  static Future<Uint8List> _decapsulateWeb(
      Uint8List encapsulatedData, Uint8List secretKey) async {
    if (!_isWeb) throw Exception('Método solo para Web');

    try {
      // Llamar a JavaScript para desencapsular
      final jsResult = js.context.callMethod('decapsulateKyberKey', [
        encapsulatedData,
        secretKey,
      ]);

      final result = Uint8List.fromList(List<int>.from(jsResult));

      print('$_logPrefix ✅ Clave desencapsulada (Web): ${result.length} bytes');
      return result;
    } catch (e) {
      print('$_logPrefix ❌ Error desencapsulando Web: $e');
      rethrow;
    }
  }

  /// Desencapsula en móvil
  static Future<Uint8List> _decapsulateMobile(
      Uint8List encapsulatedData, Uint8List secretKey) async {
    if (_isWeb) throw Exception('Método solo para móvil');

    try {
      // Determinar el tamaño del ciphertext Kyber
      final testKeyPair = KyberKeyPair.generate();
      final testEncap = KyberKEM.encapsulate(testKeyPair.publicKey);
      final ciphertextSize = testEncap.ciphertextKEM.length;

      if (encapsulatedData.length < ciphertextSize + 128) {
        throw Exception(
            'Datos encapsulados muy pequeños: ${encapsulatedData.length}');
      }

      // Extraer componentes
      final ciphertext = encapsulatedData.sublist(0, ciphertextSize);
      final encryptedMasterKey = encapsulatedData.sublist(ciphertextSize);

      // Desencapsular para obtener el shared secret
      final sharedSecret = KyberKEM.decapsulate(ciphertext, secretKey);

      // Descifrar la clave maestra
      final masterKey = Uint8List(encryptedMasterKey.length);
      for (int i = 0; i < encryptedMasterKey.length; i++) {
        masterKey[i] =
            encryptedMasterKey[i] ^ sharedSecret[i % sharedSecret.length];
      }

      print(
          '$_logPrefix ✅ Clave desencapsulada (móvil): ${masterKey.length} bytes');
      return masterKey;
    } catch (e) {
      print('$_logPrefix ❌ Error desencapsulando móvil: $e');
      rethrow;
    }
  }

  /// Ejecuta un auto-test de integridad (universal)
  static Future<bool> selfTest() async {
    if (!isAvailable) {
      return false;
    }

    try {
      print('$_logPrefix Ejecutando auto-test universal...');

      // Generar par de claves
      final keyPair = await generateKeyPair();

      // Crear clave maestra de prueba
      final originalKey = Uint8List(128);
      for (int i = 0; i < 128; i++) {
        originalKey[i] = i % 256;
      }

      // Encapsular
      final encapsulated =
          await encapsulateMasterKey(originalKey, keyPair['publicKey']!);

      // Desencapsular
      final decrypted =
          await decapsulateMasterKey(encapsulated, keyPair['secretKey']!);

      // Verificar
      if (decrypted.length != originalKey.length) {
        print('$_logPrefix ❌ Auto-test falló: tamaños diferentes');
        return false;
      }

      for (int i = 0; i < originalKey.length; i++) {
        if (decrypted[i] != originalKey[i]) {
          print('$_logPrefix ❌ Auto-test falló: byte $i diferente');
          return false;
        }
      }

      print('$_logPrefix ✅ Auto-test universal exitoso');
      return true;
    } catch (e) {
      print('$_logPrefix ❌ Auto-test falló: $e');
      return false;
    }
  }

  /// Obtiene información del estado del servicio
  static Map<String, dynamic> getStatus() {
    return {
      'available': _isAvailable,
      'initialized': _isInitialized,
      'platform': _isWeb ? 'Web' : 'Mobile',
      'algorithm': _isWeb ? 'ML-KEM-768' : 'Kyber768',
      'implementation': _isWeb ? '@noble/post-quantum' : 'xkyber_crypto v1.0.8',
      'securityLevel': 'NIST Level 3 (AES-192 equivalent)',
      'postQuantumResistant': true,
      'keyExchangeMechanism': 'KEM (Key Encapsulation Mechanism)',
      'crossPlatformCompatible': true,
    };
  }

  /// Reinicia el servicio
  static void reset() {
    print('$_logPrefix Reiniciando servicio universal...');
    _isInitialized = false;
    _isAvailable = false;
  }
}
