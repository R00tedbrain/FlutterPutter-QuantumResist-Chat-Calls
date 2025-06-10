// Utilidades multiplataforma sin dart:html para compatibilidad iOS
import 'package:flutter/foundation.dart' show kIsWeb;

class WebUtils {
  static String getCurrentUrl() {
    if (kIsWeb) {
      // En web: información básica sin dart:html
      return 'web://flutter-app';
    }
    return 'mobile://flutter-app';
  }
}
