import 'dart:io';

void main() async {
  final dartFiles = [
    'lib/screens/main_screen.dart',
    'lib/screens/ephemeral_chat_screen_multimedia.dart',
    'lib/services/ephemeral_chat_service.dart',
    'lib/screens/multi_room_chat_screen.dart',
    'lib/widgets/tor_configuration_widget.dart',
    'lib/screens/incoming_call_screen.dart',
    'lib/screens/call_screen.dart',
    'lib/services/tor_api_integration.dart',
    'lib/screens/chat_invitations_screen.dart',
    'lib/providers/call_provider.dart',
  ];

  for (final filePath in dartFiles) {
    final file = File(filePath);
    if (await file.exists()) {
      print('Limpiando prints en: $filePath');
      String content = await file.readAsString();

      // Remover prints que contienen información sensible
      content = content.replaceAllMapped(
        RegExp(r'print\([^)]+\);', multiLine: true),
        (match) => '// Logging removido para producción',
      );

      await file.writeAsString(content);
      print('✅ Limpiado: $filePath');
    }
  }

  print('🎉 Limpieza de prints completada');
}
