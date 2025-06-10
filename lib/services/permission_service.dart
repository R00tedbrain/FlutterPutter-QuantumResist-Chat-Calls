import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_webrtc/flutter_webrtc.dart';

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  /// Almacena si los permisos ya fueron solicitados
  bool _permissionsRequested = false;

  /// Solicita permisos de medios (cámara y micrófono) para WebRTC
  /// Devuelve un mapa con los resultados de los permisos
  Future<Map<String, bool>> requestMediaPermissions({bool video = true}) async {
    // Evitar solicitar permisos múltiples veces
    if (_permissionsRequested) {
      print('📝 Permisos ya solicitados previamente');
      return {'audio': true, 'video': video};
    }

    final result = {'audio': false, 'video': false};

    try {
      print('🔄 Solicitando permisos de medios (video: $video)');

      // Primero intenta obtener audio+video
      if (video) {
        try {
          final stream = await navigator.mediaDevices.getUserMedia({
            'audio': true,
            'video': true,
          });

          // Verificar qué tracks se obtuvieron realmente
          result['audio'] = stream.getAudioTracks().isNotEmpty;
          result['video'] = stream.getVideoTracks().isNotEmpty;

          // Liberar recursos
          stream.getTracks().forEach((track) => track.stop());

          print(
              '✅ Permisos obtenidos: audio=${result['audio']}, video=${result['video']}');
        } catch (e) {
          print('⚠️ No se pudo obtener audio+video: $e');

          // Si falla, intentar solo audio
          try {
            final audioStream = await navigator.mediaDevices.getUserMedia({
              'audio': true,
              'video': false,
            });

            result['audio'] = audioStream.getAudioTracks().isNotEmpty;

            // Liberar recursos
            audioStream.getTracks().forEach((track) => track.stop());

            print('✅ Solo se obtuvo permiso de audio');
          } catch (audioError) {
            print('❌ No se pudo obtener ni siquiera audio: $audioError');
            result['audio'] = false;
          }
        }
      } else {
        // Si solo se solicita audio
        try {
          final audioStream = await navigator.mediaDevices.getUserMedia({
            'audio': true,
            'video': false,
          });

          result['audio'] = audioStream.getAudioTracks().isNotEmpty;

          // Liberar recursos
          audioStream.getTracks().forEach((track) => track.stop());

          print('✅ Permiso de audio obtenido correctamente');
        } catch (e) {
          print('❌ No se pudo obtener permiso de audio: $e');
          result['audio'] = false;
        }
      }
    } catch (e) {
      print('❌ Error al solicitar permisos de medios: $e');
    }

    _permissionsRequested = true;
    return result;
  }

  /// Verifica si los permisos de medios ya están concedidos
  /// Esta función es útil para verificar permisos sin solicitarlos
  Future<Map<String, bool>> checkMediaPermissions() async {
    final result = {'audio': false, 'video': false};

    if (kIsWeb) {
      // En la web, no hay una API estándar para verificar permisos sin solicitarlos
      // En algunos navegadores, podemos usar navigator.permissions si está disponible
      try {
        // Esta verificación solo funcionará en navegadores que soporten la API permissions
        // como Chrome y Edge. No funciona en Safari.
        const js = """
        (async function() {
            if (!navigator.permissions) return {"audio": "unknown", "video": "unknown"};
            const micPermission = await navigator.permissions.query({name: 'microphone'});
            const camPermission = await navigator.permissions.query({name: 'camera'});
            return {
                "audio": micPermission.state,
                "video": camPermission.state
            };
        })();
        """;

        print('📝 Verificando permisos en navegador web (API experimental)');

        // Usar función nativa para ejecutar JS
        // Nota: Esta es una función hipotética, en Flutter real necesitarías
        // usar un plugin como js o js_interop

        // Como no podemos ejecutar JS directamente, devolvemos un resultado por defecto
        print(
            '⚠️ No se pueden verificar permisos sin solicitarlos en todos los navegadores');
        return {'audio': false, 'video': false};
      } catch (e) {
        print('⚠️ Error al verificar permisos: $e');
        return result;
      }
    } else {
      // En plataformas nativas, usar alguna biblioteca de permisos
      // pero como estamos enfocados en web, dejamos esto como un stub
      print(
          '📝 Verificación de permisos no implementada para plataforma nativa');
      return result;
    }
  }
}
