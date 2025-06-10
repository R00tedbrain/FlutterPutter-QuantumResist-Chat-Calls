import 'dart:typed_data';
import 'dart:convert';
import '../services/encryption_service.dart';

/// Prueba simple del servicio de cifrado ChaCha20-Poly1305
class EncryptionTest {
  static const String _logPrefix = '🧪 [TEST]';

  /// Prueba básica de cifrado/descifrado
  static Future<bool> testBasicEncryption() async {
    final encryptionService = EncryptionService();

    try {
      // 1. Inicializar el servicio
      await encryptionService.initialize();

      // 2. Generar clave de sesión
      final sessionKey = await encryptionService.generateSessionKey();

      // 3. Datos de prueba
      const originalMessage =
          '¡Hola! Este es un mensaje secreto de videollamada 🔐';
      final originalData = utf8.encode(originalMessage);

      // 4. Cifrar datos
      final encryptedData = await encryptionService.encrypt(originalData);

      // 5. Descifrar datos
      final decryptedData = await encryptionService.decrypt(encryptedData);
      final decryptedMessage = utf8.decode(decryptedData);

      // 6. Verificar que son iguales
      final isEqual = originalMessage == decryptedMessage;

      // 7. Verificar integridad
      final isValid = await encryptionService.verifyIntegrity(encryptedData);

      // 8. Mostrar estadísticas
      final stats = encryptionService.getUsageStats();

      return isEqual && isValid;
    } catch (e) {
      return false;
    } finally {
      // 9. Limpiar recursos
      encryptionService.dispose();
    }
  }

  /// Prueba de múltiples mensajes
  static Future<bool> testMultipleMessages() async {
    final encryptionService = EncryptionService();

    try {
      await encryptionService.initialize();
      await encryptionService.generateSessionKey();

      final messages = [
        'Primer mensaje secreto',
        'Segundo mensaje con emojis 🚀🔐',
        'Tercer mensaje más largo con muchos caracteres para probar el rendimiento del cifrado',
        'Cuarto mensaje con caracteres especiales: áéíóú ñ ¿¡',
        'Quinto y último mensaje de prueba'
      ];

      bool allSuccess = true;

      for (int i = 0; i < messages.length; i++) {
        final original = messages[i];
        final originalData = utf8.encode(original);

        final encrypted = await encryptionService.encrypt(originalData);
        final decrypted = await encryptionService.decrypt(encrypted);
        final decryptedMessage = utf8.decode(decrypted);

        final isEqual = original == decryptedMessage;

        if (!isEqual) allSuccess = false;
      }

      // final stats = encryptionService.getUsageStats();

      return allSuccess;
    } catch (e) {
      return false;
    } finally {
      encryptionService.dispose();
    }
  }

  /// Prueba de datos grandes (simulando frame de video)
  static Future<bool> testLargeData() async {
    final encryptionService = EncryptionService();

    try {
      await encryptionService.initialize();
      await encryptionService.generateSessionKey();

      // Simular frame de video de 1MB
      final largeData = Uint8List(1024 * 1024); // 1MB
      for (int i = 0; i < largeData.length; i++) {
        largeData[i] = i % 256;
      }

      // Medir tiempo de cifrado
      final encryptStart = DateTime.now();
      final encrypted = await encryptionService.encrypt(largeData);
      final encryptTime = DateTime.now().difference(encryptStart);

      // Medir tiempo de descifrado
      final decryptStart = DateTime.now();
      final decrypted = await encryptionService.decrypt(encrypted);
      final decryptTime = DateTime.now().difference(decryptStart);

      // Verificar integridad
      bool isIdentical = true;
      if (largeData.length == decrypted.length) {
        for (int i = 0; i < largeData.length; i++) {
          if (largeData[i] != decrypted[i]) {
            isIdentical = false;
            break;
          }
        }
      } else {
        isIdentical = false;
      }

      // Calcular throughput
      // final totalTime = encryptTime.inMilliseconds + decryptTime.inMilliseconds;
      // final throughputMBps =
      //     (largeData.length * 2) / (totalTime * 1000); // MB/s

      return isIdentical;
    } catch (e) {
      return false;
    } finally {
      encryptionService.dispose();
    }
  }

  /// Ejecutar todas las pruebas
  static Future<bool> runAllTests() async {
    final test1 = await testBasicEncryption();

    final test2 = await testMultipleMessages();

    final test3 = await testLargeData();

    final allPassed = test1 && test2 && test3;

    return allPassed;
  }
}
