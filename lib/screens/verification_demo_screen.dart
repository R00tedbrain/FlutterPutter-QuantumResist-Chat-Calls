import 'package:flutter/material.dart';
import '../widgets/verification_widget.dart';
import '../l10n/app_localizations.dart';

/// Pantalla de demostración para probar la verificación de identidad
/// Esta pantalla es completamente independiente y no afecta el código existente
class VerificationDemoScreen extends StatefulWidget {
  const VerificationDemoScreen({super.key});

  @override
  _VerificationDemoScreenState createState() => _VerificationDemoScreenState();
}

class _VerificationDemoScreenState extends State<VerificationDemoScreen> {
  bool _isVerified = false;

  // Datos simulados para la demo
  final String _demoRoomId =
      'demo_room_${DateTime.now().millisecondsSinceEpoch}';
  final String _demoUserId =
      'demo_user_${DateTime.now().millisecondsSinceEpoch}';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.verificationDemo),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información de la demo
            _buildInfoCard(),

            const SizedBox(height: 16),

            // Widget de verificación
            VerificationWidget(
              roomId: _demoRoomId,
              userId: _demoUserId,
              onVerificationChanged: (isVerified) {
                setState(() {
                  _isVerified = isVerified;
                });
              },
            ),

            const SizedBox(height: 16),

            // Estado actual
            _buildStatusCard(),

            const SizedBox(height: 16),

            // Instrucciones
            _buildInstructionsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Colors.blue[600]),
                const SizedBox(width: 8),
                Text(
                  l10n.verificationDemonstration,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blue[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.verificationDemoDescription,
              style: TextStyle(
                color: Colors.blue[700],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.room, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${l10n.roomLabel} ${_demoRoomId.substring(0, 20)}...',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.person, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${l10n.userLabel} ${_demoUserId.substring(0, 20)}...',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      color: _isVerified ? Colors.green[50] : Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              _isVerified ? Icons.check_circle : Icons.warning,
              color: _isVerified ? Colors.green[600] : Colors.orange[600],
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isVerified ? l10n.statusVerified : l10n.statusNotVerified,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color:
                          _isVerified ? Colors.green[800] : Colors.orange[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isVerified
                        ? l10n.identityVerifiedCorrect
                        : l10n.notVerifiedYet,
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          _isVerified ? Colors.green[700] : Colors.orange[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionsCard() {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.help_outline, color: Colors.purple[600]),
                const SizedBox(width: 8),
                Text(
                  l10n.howToTest,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.purple[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInstructionStep(
              '1.',
              l10n.stepExpandVerification,
              Icons.touch_app,
            ),
            _buildInstructionStep(
              '2.',
              l10n.stepShowCodes,
              Icons.visibility,
            ),
            _buildInstructionStep(
              '3.',
              l10n.step3,
              Icons.copy,
            ),
            _buildInstructionStep(
              '4.',
              l10n.stepPasteCode,
              Icons.paste,
            ),
            _buildInstructionStep(
              '5.',
              l10n.stepVerifyCode,
              Icons.check,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                border: Border.all(color: Colors.amber[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb, color: Colors.amber[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.realUsage,
                      style: TextStyle(
                        color: Colors.amber[800],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionStep(String number, String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.purple[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple[800],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
