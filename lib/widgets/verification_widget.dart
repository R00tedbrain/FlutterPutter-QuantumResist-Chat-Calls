import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import '../services/verification_service.dart';
import '../services/ephemeral_chat_service.dart';
import '../l10n/app_localizations.dart';

/// Widget de verificación de identidad anónima
/// Se puede agregar a cualquier pantalla sin modificar código existente
class VerificationWidget extends StatefulWidget {
  final String roomId;
  final String userId;
  final Function(bool isVerified)? onVerificationChanged;
  final EphemeralChatService? chatService;

  const VerificationWidget({
    super.key,
    required this.roomId,
    required this.userId,
    this.onVerificationChanged,
    this.chatService,
  });

  @override
  _VerificationWidgetState createState() => _VerificationWidgetState();
}

class _VerificationWidgetState extends State<VerificationWidget> {
  final VerificationService _verificationService = VerificationService();
  final TextEditingController _codeController = TextEditingController();

  String? _alphanumericCode;
  String? _numericCode;
  String? _emojiCode;
  bool _isVerified = false;
  bool _showCodes = false;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    print('🔑 [VERIFICATION] Inicializando widget de verificación');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_alphanumericCode == null) {
      _generateVerificationCodes();
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _setupChatListener() {
    if (widget.chatService != null) {
      print('🔑 [VERIFICATION] Chat service disponible para sincronización');

      // CORREGIDO: No sobrescribir el callback principal, sino agregar un listener adicional
      // Esto evita conflictos cuando hay múltiples widgets de verificación

      // Guardar referencia al callback original si existe
      final originalCallback = widget.chatService!.onMessageReceived;

      // Crear un nuevo callback que maneje tanto mensajes normales como de verificación
      widget.chatService!.onMessageReceived = (message) {
        // IMPORTANTE: Siempre ejecutar el callback original primero
        if (originalCallback != null) {
          originalCallback(message);
        }

        // NUEVO: Solo procesar mensajes de verificación aquí
        if (message.content.startsWith('VERIFICATION_CODES:')) {
          final codes = message.content.substring('VERIFICATION_CODES:'.length);
          print('🔑 [VERIFICATION] 📥 Mensaje de códigos recibido: $codes');
          print(
              '🔑 [VERIFICATION] 📥 Código actual del partner: ${_verificationService.partnerCode}');

          // Establecer el código del partner
          _verificationService.setPartnerCode(codes);

          print(
              '🔑 [VERIFICATION] 📥 Códigos del partner establecidos: $codes');

          // Mostrar notificación después del build
          if (mounted) {
            SchedulerBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('📥 Códigos del partner recibidos'),
                    backgroundColor: Colors.blue,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            });

            setState(() {
              // Forzar actualización de la UI
            });
          }
        }
      };

      // NUEVO: También enviar códigos cuando se establece la conexión
      if (_alphanumericCode != null) {
        print('🔑 [VERIFICATION] Enviando códigos existentes al partner');
        _sendCodesToPartner();
      }
    } else {
      print('🔑 [VERIFICATION] ❌ No hay código del partner para verificar');
    }
  }

  void _generateVerificationCodes() {
    final codes = _verificationService.generateVerificationCodes(
      widget.roomId,
      widget.userId,
    );
    setState(() {
      _alphanumericCode = codes['alphanumeric'];
      _numericCode = codes['numeric'];
      _emojiCode = codes['emoji'];
      _isVerified = _verificationService.isVerified;
    });

    print('🔑 [VERIFICATION] Códigos generados para sala ${widget.roomId}');
    print('🔑 [VERIFICATION] Alfanumérico: $_alphanumericCode');
    print('🔑 [VERIFICATION] Numérico: $_numericCode');
    print('🔑 [VERIFICATION] Emoji: $_emojiCode');

    // NUEVO: Configurar listener solo una vez
    _setupChatListener();

    // Enviar códigos al partner automáticamente con un pequeño delay
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted && _alphanumericCode != null) {
        _sendCodesToPartner();
      }
    });
  }

  void _sendCodesToPartner() {
    if (widget.chatService != null && _alphanumericCode != null) {
      // CORREGIDO: Solo enviar código alfanumérico como en la versión que funcionaba
      final codesMessage = 'VERIFICATION_CODES:${_alphanumericCode!}';

      try {
        widget.chatService!.sendMessage(codesMessage);
        print(
            '🔑 [VERIFICATION] 📤 Códigos enviados al partner: ${_alphanumericCode!}');

        // CORREGIDO: Mostrar confirmación de envío después del build
        if (mounted) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('📤 Códigos enviados al partner'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 1),
                ),
              );
            }
          });
        }
      } catch (e) {
        print('🔑 [VERIFICATION] ❌ Error enviando códigos: $e');

        // Reintentar después de un delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted &&
              widget.chatService != null &&
              _alphanumericCode != null) {
            print('🔑 [VERIFICATION] 🔄 Reintentando envío de códigos...');
            try {
              widget.chatService!.sendMessage(codesMessage);
              print('🔑 [VERIFICATION] ✅ Códigos enviados en reintento');
            } catch (e2) {
              print('🔑 [VERIFICATION] ❌ Error en reintento: $e2');
            }
          }
        });
      }
    } else {
      print('🔑 [VERIFICATION] ❌ No se pueden enviar códigos - faltan datos');
      print('🔑 [VERIFICATION] - Chat service: ${widget.chatService != null}');
      print('🔑 [VERIFICATION] - Alfanumérico: ${_alphanumericCode != null}');
    }
  }

  void _verifyCode() {
    final l10n = AppLocalizations.of(context)!;
    final inputCode = _codeController.text.trim();

    if (inputCode.isEmpty) {
      _showSnackBar(l10n.enterCodeToVerify, Colors.orange);
      return;
    }

    if (!_verificationService.isValidCodeFormat(inputCode)) {
      _showSnackBar(l10n.invalidCodeFormat, Colors.red);
      return;
    }

    final isValid = _verificationService.verifyPartnerCode(inputCode);

    setState(() {
      _isVerified = isValid;
    });

    if (isValid) {
      _showSnackBar(l10n.identityVerifiedSuccess, Colors.green);
      widget.onVerificationChanged?.call(true);
    } else {
      _showSnackBar(l10n.incorrectCode, Colors.red);
      widget.onVerificationChanged?.call(false);
    }
  }

  void _regenerateCodes() {
    final l10n = AppLocalizations.of(context)!;
    final codes = _verificationService.regenerateCodes(
      widget.roomId,
      widget.userId,
    );
    setState(() {
      _alphanumericCode = codes['alphanumeric'];
      _numericCode = codes['numeric'];
      _emojiCode = codes['emoji'];
      _isVerified = false;
      _showCodes = false;
    });
    _showSnackBar(l10n.codesRegenerated, Colors.blue);
    widget.onVerificationChanged?.call(false);

    // Enviar nuevos códigos al partner
    _sendCodesToPartner();
  }

  void _copyToClipboard(String text) {
    final l10n = AppLocalizations.of(context)!;
    Clipboard.setData(ClipboardData(text: text));
    _showSnackBar(l10n.codeCopied, Colors.blue);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 4,
      child: Column(
        children: [
          // Header con estado de verificación
          _buildHeader(),

          // Contenido expandible con ScrollView
          if (_isExpanded) ...[
            const Divider(height: 1),
            // NUEVO: Container con altura máxima y scroll para móvil
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height *
                    0.4, // Máximo 40% de la pantalla
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMyCodesSection(),
                      const SizedBox(height: 16),
                      _buildVerificationSection(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icono de estado
            Icon(
              _isVerified ? Icons.verified_user : Icons.security,
              color: _isVerified ? Colors.green : Colors.orange,
              size: 24,
            ),

            const SizedBox(width: 12),

            // Texto de estado
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isVerified
                        ? l10n.identityVerifiedFull
                        : l10n.identityVerification,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _isVerified ? Colors.green : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _isVerified
                        ? l10n.bothUsersVerified
                        : l10n.verifyIdentityDescription,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Icono de expansión
            Icon(
              _isExpanded ? Icons.expand_less : Icons.expand_more,
              color: Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyCodesSection() {
    final l10n = AppLocalizations.of(context)!;

    if (_alphanumericCode == null &&
        _numericCode == null &&
        _emojiCode == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.key, color: Colors.blue, size: 20),
            const SizedBox(width: 8),
            Text(
              l10n.yourVerificationCodes,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.send, size: 18, color: Colors.green),
              onPressed: () {
                // CORREGIDO: Reenvío directo sin flags restrictivos
                _sendCodesToPartner();
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.resendingCodes),
                        backgroundColor: Colors.orange,
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }
                });
              },
              tooltip: 'Reenviar códigos al partner',
            ),
            IconButton(
              icon: const Icon(Icons.refresh, size: 20),
              onPressed: _regenerateCodes,
              tooltip: 'Regenerar códigos',
            ),
          ],
        ),

        Text(
          l10n.shareCodeMessage,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),

        const SizedBox(height: 12),

        // Mostrar/ocultar códigos
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon:
                    Icon(_showCodes ? Icons.visibility_off : Icons.visibility),
                label: Text(_showCodes ? l10n.hideCodesBut : l10n.showMyCodes),
                onPressed: () => setState(() => _showCodes = !_showCodes),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  foregroundColor: Colors.blue,
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),

        if (_showCodes) ...[
          const SizedBox(height: 12),

          // Código alfanumérico
          _buildCodeCard(
            l10n.alphanumericCode,
            _alphanumericCode!,
            Colors.blue,
          ),

          const SizedBox(height: 8),

          // Código numérico
          _buildCodeCard(
            l10n.numericCode,
            _numericCode!,
            Colors.green,
          ),

          const SizedBox(height: 8),

          // Código emoji
          _buildCodeCard(
            l10n.emojiCode,
            _emojiCode!,
            Colors.orange,
          ),
        ],
      ],
    );
  }

  Widget _buildCodeCard(String title, String code, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  code,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.copy, color: color),
            onPressed: () => _copyToClipboard(code),
            tooltip: 'Copiar código',
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationSection() {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.verified_user, color: Colors.green, size: 20),
            const SizedBox(width: 8),
            Text(
              l10n.verifyPartnerCode,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          l10n.enterPartnerCode,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),

        // NUEVO: Mostrar estado de códigos del partner
        if (_verificationService.partnerCode != null)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.blue, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${l10n.partnerCodesReceivedWithCode} ${_verificationService.partnerCode}',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.hourglass_empty,
                    color: Colors.orange, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.waitingPartnerCodes,
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _codeController,
                decoration: InputDecoration(
                  hintText: 'Ej: A7B9C2D1 o 123456 o 🐱🐶🦊🐻',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.lock),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                textCapitalization: TextCapitalization.characters,
                onSubmitted: (_) => _verifyCode(),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _verifyCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              child: Text('✅ ${l10n.verify}'),
            ),
          ],
        ),
        if (_isVerified) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.verificationSuccessMessage,
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
