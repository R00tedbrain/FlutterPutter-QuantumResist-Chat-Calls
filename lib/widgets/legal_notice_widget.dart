import 'package:flutter/material.dart';
import 'package:flutterputter/l10n/app_localizations.dart';

class LegalNoticeWidget extends StatelessWidget {
  const LegalNoticeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icono y título
          Row(
            children: [
              Icon(
                Icons.security,
                color: Colors.green[400],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.privacyAndSecurity,
                style: TextStyle(
                  color: Colors.green[400],
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Información de privacidad
          _buildPrivacyPoint(
            icon: Icons.visibility_off,
            text: l10n.noDataCollection,
          ),
          const SizedBox(height: 8),

          _buildPrivacyPoint(
            icon: Icons.vpn_lock,
            text: l10n.anonymousConnections,
          ),
          const SizedBox(height: 8),

          _buildPrivacyPoint(
            icon: Icons.auto_delete,
            text: l10n.ephemeralChatRooms,
          ),
          const SizedBox(height: 8),

          _buildPrivacyPoint(
            icon: Icons.lock,
            text: l10n.encryptionInfo,
          ),

          const SizedBox(height: 16),

          // Términos legales
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.orange.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              'Al iniciar sesión o registrarte, aceptas nuestros Términos de Servicio y Política de Privacidad. FlutterPutter se compromete a mantener tu privacidad y garantizar comunicaciones seguras.',
              style: TextStyle(
                color: Colors.orange[300],
                fontSize: 12,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyPoint({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.8),
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
