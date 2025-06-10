import 'dart:typed_data';
import 'dart:convert';
import '../services/encryption_service.dart';

/// Prueba simple del servicio de cifrado ChaCha20-Poly1305
class EncryptionTest {
  static const String _logPrefix = '🧪 [TEST]';

  /// Prueba básica de cifrado/descifrado
  static Future<bool> testBasicEncryption() async {
    print('$_logPrefix === PRUEBA BÁSICA DE CIFRADO ===');

    final encryptionService = EncryptionService();

    try {
      // 1. Inicializar el servicio
      await encryptionService.initialize();
      print('$_logPrefix ✅ Servicio inicializado');

      // 2. Generar clave de sesión
      final sessionKey = await encryptionService.generateSessionKey();
      print('$_logPrefix ✅ Clave generada: ${sessionKey.length} bytes');

      // 3. Datos de prueba
      const originalMessage =
          '¡Hola! Este es un mensaje secreto de videollamada 🔐';
      final originalData = utf8.encode(originalMessage);
      print('$_logPrefix 📝 Mensaje original: "$originalMessage"');
      print('$_logPrefix 📊 Datos originales: ${originalData.length} bytes');

      // 4. Cifrar datos
      final encryptedData = await encryptionService.encrypt(originalData);
      print('$_logPrefix 🔒 Datos cifrados: ${encryptedData.length} bytes');
      print(
          '$_logPrefix 📈 Overhead: ${encryptedData.length - originalData.length} bytes');

      // 5. Descifrar datos
      final decryptedData = await encryptionService.decrypt(encryptedData);
      final decryptedMessage = utf8.decode(decryptedData);
      print('$_logPrefix 🔓 Mensaje descifrado: "$decryptedMessage"');

      // 6. Verificar que son iguales
      final isEqual = originalMessage == decryptedMessage;
      print(
          '$_logPrefix ${isEqual ? "✅" : "❌"} Verificación: ${isEqual ? "CORRECTA" : "FALLIDA"}');

      // 7. Verificar integridad
      final isValid = await encryptionService.verifyIntegrity(encryptedData);
      print(
          '$_logPrefix ${isValid ? "✅" : "❌"} Integridad: ${isValid ? "VÁLIDA" : "INVÁLIDA"}');

      // 8. Mostrar estadísticas
      final stats = encryptionService.getUsageStats();
      print('$_logPrefix 📊 Nonces usados: ${stats['noncesUsed']}');
      print('$_logPrefix 🔐 Nivel de seguridad: ${stats['securityLevel']}');

      return isEqual && isValid;
    } catch (e) {
      print('$_logPrefix ❌ Error en la prueba: $e');
      return false;
    } finally {
      // 9. Limpiar recursos
      encryptionService.dispose();
      print('$_logPrefix 🗑️ Recursos limpiados');
    }
  }

  /// Prueba de múltiples mensajes
  static Future<bool> testMultipleMessages() async {
    print('$_logPrefix === PRUEBA DE MÚLTIPLES MENSAJES ===');

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
        print(
            '$_logPrefix Mensaje ${i + 1}: ${isEqual ? "✅" : "❌"} "$original"');

        if (!isEqual) allSuccess = false;
      }

      final stats = encryptionService.getUsageStats();
      print('$_logPrefix 📊 Total nonces usados: ${stats['noncesUsed']}');

      return allSuccess;
    } catch (e) {
      print('$_logPrefix ❌ Error en prueba múltiple: $e');
      return false;
    } finally {
      encryptionService.dispose();
    }
  }

  /// Prueba de datos grandes (simulando frame de video)
  static Future<bool> testLargeData() async {
    print('$_logPrefix === PRUEBA DE DATOS GRANDES ===');

    final encryptionService = EncryptionService();

    try {
      await encryptionService.initialize();
      await encryptionService.generateSessionKey();

      // Simular frame de video de 1MB
      final largeData = Uint8List(1024 * 1024); // 1MB
      for (int i = 0; i < largeData.length; i++) {
        largeData[i] = i % 256;
      }

      print('$_logPrefix 📊 Datos de prueba: ${largeData.length} bytes (1MB)');

      // Medir tiempo de cifrado
      final encryptStart = DateTime.now();
      final encrypted = await encryptionService.encrypt(largeData);
      final encryptTime = DateTime.now().difference(encryptStart);

      print(
          '$_logPrefix ⏱️ Tiempo de cifrado: ${encryptTime.inMilliseconds}ms');
      print('$_logPrefix 📊 Datos cifrados: ${encrypted.length} bytes');

      // Medir tiempo de descifrado
      final decryptStart = DateTime.now();
      final decrypted = await encryptionService.decrypt(encrypted);
      final decryptTime = DateTime.now().difference(decryptStart);

      print(
          '$_logPrefix ⏱️ Tiempo de descifrado: ${decryptTime.inMilliseconds}ms');

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

      print(
          '$_logPrefix ${isIdentical ? "✅" : "❌"} Integridad: ${isIdentical ? "CORRECTA" : "FALLIDA"}');

      // Calcular throughput
      final totalTime = encryptTime.inMilliseconds + decryptTime.inMilliseconds;
      final throughputMBps =
          (largeData.length * 2) / (totalTime * 1000); // MB/s
      print(
          '$_logPrefix 🚀 Throughput: ${throughputMBps.toStringAsFixed(2)} MB/s');

      return isIdentical;
    } catch (e) {
      print('$_logPrefix ❌ Error en prueba de datos grandes: $e');
      return false;
    } finally {
      encryptionService.dispose();
    }
  }

  /// Ejecutar todas las pruebas
  static Future<bool> runAllTests() async {
    print('$_logPrefix 🚀 INICIANDO PRUEBAS DE CIFRADO ChaCha20-Poly1305\n');

    final test1 = await testBasicEncryption();
    print('');

    final test2 = await testMultipleMessages();
    print('');

    final test3 = await testLargeData();
    print('');

    final allPassed = test1 && test2 && test3;

    print('$_logPrefix === RESUMEN DE PRUEBAS ===');
    print('$_logPrefix Prueba básica: ${test1 ? "✅ PASÓ" : "❌ FALLÓ"}');
    print('$_logPrefix Múltiples mensajes: ${test2 ? "✅ PASÓ" : "❌ FALLÓ"}');
    print('$_logPrefix Datos grandes: ${test3 ? "✅ PASÓ" : "❌ FALLÓ"}');
    print(_logPrefix);
    print(
        '$_logPrefix ${allPassed ? "🎉 TODAS LAS PRUEBAS PASARON" : "💥 ALGUNAS PRUEBAS FALLARON"}');

    return allPassed;
  }
}
