import 'dart:typed_data';

/// Stub para xkyber_crypto en Web
/// Estas clases nunca se usan en Web, solo existen para compilación

class KyberKeyPair {
  final Uint8List publicKey;
  final Uint8List secretKey;

  KyberKeyPair(this.publicKey, this.secretKey);

  static KyberKeyPair generate() {
    throw UnimplementedError('KyberKeyPair no disponible en Web');
  }
}

class KyberEncapsulationResult {
  final Uint8List ciphertextKEM;
  final Uint8List sharedSecret;

  KyberEncapsulationResult(this.ciphertextKEM, this.sharedSecret);
}

class KyberKEM {
  static KyberEncapsulationResult encapsulate(Uint8List publicKey) {
    throw UnimplementedError('KyberKEM.encapsulate no disponible en Web');
  }

  static Uint8List decapsulate(Uint8List ciphertext, Uint8List secretKey) {
    throw UnimplementedError('KyberKEM.decapsulate no disponible en Web');
  }
}

/// Stubs para dart:js (solo para compilación en móvil)
class _JsContext {
  dynamic operator [](String key) {
    throw UnimplementedError('js.context no disponible en móvil');
  }

  dynamic callMethod(String method, [List? args]) {
    throw UnimplementedError('js.context.callMethod no disponible en móvil');
  }
}

final context = _JsContext();
