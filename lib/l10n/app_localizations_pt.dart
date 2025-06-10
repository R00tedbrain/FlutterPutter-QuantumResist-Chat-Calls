// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'FlutterPutter';

  @override
  String get loginTitle => 'Inicie sessão para continuar';

  @override
  String get email => 'Email';

  @override
  String get enterEmail => 'Introduza o seu email';

  @override
  String get password => 'Palavra-passe';

  @override
  String get enterPassword => 'Introduza a sua palavra-passe';

  @override
  String get pleaseEnterEmail => 'Por favor, introduza o seu email';

  @override
  String get enterValidEmail => 'Introduza um email válido';

  @override
  String get pleaseEnterPassword => 'Por favor, introduza a sua palavra-passe';

  @override
  String get passwordMinLength =>
      'A palavra-passe deve ter pelo menos 6 caracteres';

  @override
  String get loginButton => 'Iniciar Sessão';

  @override
  String get noAccount => 'Não tem uma conta?';

  @override
  String get register => 'Registe-se';

  @override
  String get oneSessionSecurity =>
      '🔒 Apenas é permitida 1 sessão ativa por utilizador para maior segurança';

  @override
  String get oneSessionMaxSecurity =>
      'Apenas 1 sessão por utilizador (Máxima segurança)';

  @override
  String get privacyAndSecurity => 'Privacidade e Segurança';

  @override
  String get noDataCollection => 'Não recolhemos dados pessoais';

  @override
  String get anonymousConnections => 'Todas as ligações são anónimas';

  @override
  String get ephemeralChatRooms =>
      'Salas de chat efémeras que se destroem automaticamente';

  @override
  String get encryptionInfo =>
      'Cifragem XSalsa20 com chaves aleatórias por sala';

  @override
  String get chats => 'Conversas';

  @override
  String get secureChat => 'Conversa Segura';

  @override
  String get secureChatDescription =>
      'Toque para criar ou juntar-se a conversas efémeras';

  @override
  String get privateVideoCall => 'Videochamada Privada';

  @override
  String get videoCallDescription => 'Chamada terminada';

  @override
  String get multipleChats => 'Conversas Múltiplas';

  @override
  String get newRoom => 'Nova Sala';

  @override
  String get noActiveChats => 'Não há conversas ativas';

  @override
  String get useNewRoomButton =>
      'Use o separador \'Nova Sala\' para criar uma conversa';

  @override
  String get searchUsers => 'Procurar Utilizadores';

  @override
  String get searchByNickname => 'Procurar por nickname';

  @override
  String get calls => 'Chamadas';

  @override
  String get verification => 'Verificação';

  @override
  String get verificationDemo => 'Demo: Verificação de Identidade';

  @override
  String get verificationDemoDescription =>
      'Esta é uma demonstração do sistema de verificação de identidade anónima. Numa implementação real, este widget seria integrado nas salas de chat efémeras.';

  @override
  String get room => 'Sala';

  @override
  String get user => 'Utilizador';

  @override
  String get identityVerification => 'Verificação de Identidade';

  @override
  String get verifyIdentityDescription =>
      'Toque para verificar identidade de forma anónima';

  @override
  String get statusNotVerified => 'Estado: Não Verificado';

  @override
  String get notVerifiedYet => 'A identidade ainda não foi verificada';

  @override
  String get howToTest => 'Como Testar a Verificação';

  @override
  String get step1 => 'Toque em';

  @override
  String get step2 => 'Toque';

  @override
  String get step3 => 'Copie um dos códigos (alfanumérico, numérico ou emoji)';

  @override
  String get step4 => 'Cole o código em';

  @override
  String get step5 => 'Toque';

  @override
  String get showMyCodes => 'Mostrar Meus Códigos';

  @override
  String get verifyPartnerCode => 'VERIFICAR CÓDIGO DO PARCEIRO';

  @override
  String get verify => 'Verificar';

  @override
  String get realUsage =>
      'Em uso real: Os utilizadores partilhariam códigos por WhatsApp, Telegram, etc.';

  @override
  String get securitySettings => 'Definições de Segurança';

  @override
  String get securitySettingsDescription =>
      'Configure um PIN de segurança para proteger a sua privacidade. As notificações continuarão a chegar mesmo que a aplicação esteja bloqueada.';

  @override
  String get configureAppLock => 'Configurar bloqueio da aplicação';

  @override
  String get newPin => 'Novo PIN (4-15 caracteres)';

  @override
  String get confirmPin => 'Confirmar PIN';

  @override
  String get activateLock => 'Ativar bloqueio';

  @override
  String get screenshotSecurity => 'Segurança de capturas de ecrã';

  @override
  String get screenshotSecurityDescription =>
      'Controle se podem ser tiradas capturas de ecrã da aplicação.';

  @override
  String get allowScreenshots => 'Permitir capturas de ecrã';

  @override
  String get screenshotsAllowed => 'As capturas de ecrã estão PERMITIDAS';

  @override
  String get screenshotsDisabled => 'Pode desativá-las para maior segurança';

  @override
  String get autoDestructionDefault => 'Autodestruição por defeito';

  @override
  String get autoDestructionDescription =>
      'Configure um tempo de autodestruição que será aplicado automaticamente ao juntar-se a novas salas de chat:';

  @override
  String get defaultTime => 'Tempo por defeito:';

  @override
  String get noLimit => 'Sem limite';

  @override
  String get selectTime =>
      'Selecione um tempo para ativar a autodestruição por defeito. As mensagens serão eliminadas automaticamente após o tempo configurado.';

  @override
  String get activeSessions => 'Sessões ativas';

  @override
  String get activeSessionsDescription =>
      'Faça a gestão dos dispositivos onde tem sessões abertas. Semelhante ao Signal e WhatsApp.';

  @override
  String get currentState => 'Estado atual';

  @override
  String get noActiveSessionsRegistered => '0 sessões ativas registadas';

  @override
  String get multipleSessions => 'Sessões múltiplas: Desativado';

  @override
  String get configurationLikeSignal => 'e configuração como Signal';

  @override
  String get manageSessions => 'Gerir sessões';

  @override
  String get allowMultipleSessions => 'Permitir sessões múltiplas';

  @override
  String get onlyOneActiveSession =>
      'Apenas uma sessão ativa de cada vez (como Signal)';

  @override
  String get searchByName => 'Procurar por nome...';

  @override
  String get writeAtLeast2Characters =>
      'Escreva pelo menos 2 caracteres para procurar utilizadores';

  @override
  String get connecting => 'A ligar...';

  @override
  String get error => 'Erro';

  @override
  String get secureMultimediaChat => 'Conversa Multimédia Segura';

  @override
  String get sendEncryptedMessages =>
      'Envie mensagens e imagens\\cifradas com XChaCha20-Poly1305';

  @override
  String get encryptedMessage => 'Mensagem cifrada...';

  @override
  String get sendEncryptedImage => 'Enviar imagem cifrada';

  @override
  String get takePhoto => 'Tirar Foto';

  @override
  String get useCamera => 'Usar câmara';

  @override
  String get gallery => 'Galeria';

  @override
  String get selectImage => 'Selecionar imagem';

  @override
  String get capturesBlocked => 'Capturas de ecrã bloqueadas';

  @override
  String get capturesAllowed => 'Capturas de ecrã permitidas';

  @override
  String get e2eEncryptionSecurity => 'Cifragem E2E + Segurança';

  @override
  String get encryptionDescription =>
      'Todas as mensagens, imagens e áudio são cifrados localmente com XChaCha20-Poly1305.\\n\\nO servidor apenas vê blobs cifrados opacos.\\n\\nÁudio com gravação real implementada.';

  @override
  String get screenshotsStatus => 'Capturas de ecrã:';

  @override
  String get screenshotsBlocked => 'BLOQUEADAS';

  @override
  String get screenshotsPermitted => 'PERMITIDAS';

  @override
  String get likeWhatsAppTelegram =>
      'Como WhatsApp/Telegram - ecrã preto em capturas';

  @override
  String get understood => 'Entendido';

  @override
  String get destroyRoom => 'Destruir Sala';

  @override
  String get warningDestroyRoom =>
      'Esta ação destruirá permanentemente a sala de chat para ambos os utilizadores.\\n\\nSerá iniciado um contador de 10 segundos visível para ambos os participantes.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get audioNote => 'Nota de áudio';

  @override
  String get recordedAudioNote => 'Nota de áudio (gravada)';

  @override
  String get playing => 'A reproduzir...';

  @override
  String get tapToStop => 'Toque para parar';

  @override
  String get tapToPlay => 'Toque para reproduzir';

  @override
  String get image => 'Imagem';

  @override
  String get backToMultipleChats => 'Voltar para conversas múltiplas';

  @override
  String get backToChat => 'Voltar para conversa';

  @override
  String get screenshotsBlockedAutomatically => 'Capturas de ecrã BLOQUEADAS';

  @override
  String get screenshotsEnabled => 'Capturas de ecrã ATIVADAS';

  @override
  String get identityVerifiedCorrectly =>
      'Identidade do parceiro verificada corretamente';

  @override
  String get createAccount => 'Criar Conta';

  @override
  String get registerSubtitle =>
      'Registe-se para começar a usar o FlutterPutter';

  @override
  String get nickname => 'Nickname';

  @override
  String get chooseUniqueNickname => 'Escolha um nickname único';

  @override
  String get createSecurePassword => 'Crie uma palavra-passe segura';

  @override
  String get confirmPassword => 'Confirmar Palavra-passe';

  @override
  String get repeatPassword => 'Repita a sua palavra-passe';

  @override
  String get invitationCode => 'Código de Convite';

  @override
  String get enterInvitationCode => 'Introduza o seu código de convite';

  @override
  String get registerButton => 'Registar';

  @override
  String get pleaseConfirmPassword => 'Por favor, confirme a sua palavra-passe';

  @override
  String get passwordsDoNotMatch => 'As palavras-passe não coincidem';

  @override
  String get pleaseEnterNickname => 'Por favor, introduza um nickname';

  @override
  String get nicknameMinLength => 'O nickname deve ter pelo menos 3 caracteres';

  @override
  String get pleaseEnterInvitationCode =>
      'Por favor, introduza um código de convite';

  @override
  String get invitationCodeLength => 'O código deve ter 8 caracteres';

  @override
  String get newChatInvitationReceived => '📩 Novo convite de chat recebido';

  @override
  String get view => 'Ver';

  @override
  String get chatInvitations => 'Convites de Chat';

  @override
  String get securitySettingsTooltip => 'Definições de Segurança';

  @override
  String helloUser(String nickname) {
    return 'Olá, $nickname';
  }

  @override
  String get searchUsersToVideoCall =>
      'Procure utilizadores para iniciar uma videochamada';

  @override
  String get searchUsersButton => 'Procurar Utilizadores';

  @override
  String get testIdentityVerification => 'Testar verificação de identidade';

  @override
  String get ephemeralChat => '💬 Chat Efémero';

  @override
  String get multipleSimultaneousRooms =>
      'Múltiplas salas simultâneas (máx. 10)';

  @override
  String get logout => 'Terminar Sessão';

  @override
  String get logoutConfirmTitle => 'Terminar Sessão';

  @override
  String get logoutConfirmMessage =>
      'Tem a certeza de que quer terminar sessão?';

  @override
  String get helpSection => 'Ajuda e Suporte';

  @override
  String get supportCenter => 'Centro de assistência';

  @override
  String get supportCenterDescription =>
      'Obtenha ajuda e consulte as perguntas frequentes';

  @override
  String get contactUs => 'Contacte-nos';

  @override
  String get contactUsDescription =>
      'Envie-nos um email para resolver as suas dúvidas';

  @override
  String get contactEmail => 'FlutterPutter@Proton.me';

  @override
  String get appVersion => 'Versão';

  @override
  String get versionNumber => 'Versão 1.0 Beta';

  @override
  String get termsAndConditions => 'Termos e condições';

  @override
  String get termsDescription => 'Leia os nossos termos de serviço';

  @override
  String get privacyPolicy => 'Política de privacidade';

  @override
  String get privacyPolicyDescription =>
      'Consulte como protegemos a sua informação';

  @override
  String get emailCopied => 'Email copiado para a área de transferência';

  @override
  String get openingWebPage => 'A abrir página web...';

  @override
  String get errorOpeningWebPage => 'Erro ao abrir a página web';

  @override
  String get pinLengthError => 'O PIN deve ter entre 4 e 15 caracteres';

  @override
  String get pinMismatch => 'Os PINs não coincidem';

  @override
  String get appLockSetupSuccess =>
      '🔒 Bloqueio da aplicação configurado com sucesso';

  @override
  String get pinSetupError => 'Erro ao configurar o PIN';

  @override
  String get pinChangeSuccess => '🔒 PIN alterado com sucesso';

  @override
  String get currentPinIncorrect => 'PIN atual incorreto';

  @override
  String get disableAppLockTitle => 'Desativar bloqueio';

  @override
  String get disableAppLockMessage =>
      'Tem a certeza de que quer desativar o bloqueio da aplicação?';

  @override
  String get appLockDisabled => '🔓 Bloqueio da aplicação desativado';

  @override
  String get confirm => 'Confirmar';

  @override
  String get changePin => 'Alterar PIN:';

  @override
  String get currentPin => 'PIN atual';

  @override
  String get confirmNewPin => 'Confirmar novo PIN';

  @override
  String get changePinButton => 'Alterar PIN';

  @override
  String get biometricUnlock =>
      'Desbloqueie a aplicação com biometria além do PIN';

  @override
  String get screenshotsAllowedMessage => '🔓 Capturas de ecrã PERMITIDAS';

  @override
  String get screenshotsBlockedMessage => '🔒 Capturas de ecrã BLOQUEADAS';

  @override
  String get screenshotConfigError =>
      'Erro ao atualizar configuração de capturas de ecrã';

  @override
  String get protectionActive => 'Proteção ativa';

  @override
  String get nativeProtectionFeatures =>
      '• Bloqueio nativo em iOS e Android\n• Alerta ao detetar tentativas de captura\n• Proteção no seletor de aplicações';

  @override
  String get autoDestructionDefaultDisabled =>
      '🔥 Autodestruição por defeito desativada';

  @override
  String get autoDestructionError =>
      'Erro ao atualizar configuração de autodestruição';

  @override
  String get protectYourApp => 'Proteja a sua aplicação';

  @override
  String get securityPinDescription =>
      'Configure um PIN de segurança para proteger a sua privacidade. As notificações continuarão a chegar mesmo que a aplicação esteja bloqueada.';

  @override
  String get lockActivated => 'Bloqueio ativado';

  @override
  String get disable => 'Desativar';

  @override
  String get errorCopyingEmail => 'Erro ao copiar o email';

  @override
  String get automaticLockTimeout => 'Tempo de bloqueio automático';

  @override
  String get appWillLockAfter =>
      'A aplicação será bloqueada automaticamente após:';

  @override
  String get biometricAuthentication => 'Autenticação biométrica';

  @override
  String get enableBiometric => 'Ativar impressão digital/Face ID';

  @override
  String get autoApplyDefault => 'Aplicar automaticamente';

  @override
  String get autoApplyEnabled => 'Será aplicado ao juntar-se a novas salas';

  @override
  String get autoApplyDisabled => 'Apenas aplicar manualmente em cada sala';

  @override
  String get currentConfiguration => 'Configuração atual';

  @override
  String get sessionActive => 'sessão ativa';

  @override
  String get sessionsActive => 'sessões ativas';

  @override
  String get noActiveSessionsMessage => 'Sem sessões ativas registadas';

  @override
  String get helpAndSupport =>
      'Obtenha ajuda, contacte-nos ou consulte as nossas políticas';

  @override
  String get autoDestructionDefaultEnabled => '🔥 Autodestruição por defeito: ';

  @override
  String get verificationDemonstration => 'Demonstração de Verificação';

  @override
  String get roomLabel => 'Sala:';

  @override
  String get userLabel => 'Utilizador:';

  @override
  String get statusVerified => 'Estado: Verificado ✅';

  @override
  String get identityVerifiedCorrect =>
      'A identidade foi verificada corretamente';

  @override
  String get identityVerifiedFull => '✅ Identidade Verificada';

  @override
  String get bothUsersVerified =>
      'Ambos os utilizadores verificaram a sua identidade';

  @override
  String get yourVerificationCodes => 'OS SEUS CÓDIGOS DE VERIFICAÇÃO';

  @override
  String get shareCodeMessage =>
      'Partilhe UM destes códigos por outro canal (WhatsApp, Telegram, etc.)';

  @override
  String get hideCodesBut => '🙈 Ocultar Códigos';

  @override
  String get alphanumericCode => '🔤 Alfanumérico';

  @override
  String get numericCode => '🔢 Numérico';

  @override
  String get emojiCode => '😀 Emoji';

  @override
  String get enterCodeToVerify => '❌ Introduza um código para verificar';

  @override
  String get invalidCodeFormat => '❌ Formato de código inválido';

  @override
  String get identityVerifiedSuccess => '✅ Identidade verificada corretamente!';

  @override
  String get incorrectCode => '❌ Código incorreto';

  @override
  String get codesRegenerated => '🔄 Códigos regenerados';

  @override
  String get codeCopied => '📋 Código copiado para a área de transferência';

  @override
  String get partnerCodesReceived => '📥 Códigos do parceiro recebidos';

  @override
  String get codesSentToPartner => '📤 Códigos enviados ao parceiro';

  @override
  String get resendingCodes => '🔄 A reenviar códigos ao parceiro...';

  @override
  String get stepExpandVerification =>
      'Toque em \"🔐 Verificação de Identidade\" para expandir';

  @override
  String get stepShowCodes =>
      'Toque em \"👁️ Mostrar Meus Códigos\" para ver os seus códigos únicos';

  @override
  String get stepPasteCode =>
      'Cole o código em \"VERIFICAR CÓDIGO DO PARCEIRO\"';

  @override
  String get stepVerifyCode =>
      'Toque em \"✅ Verificar\" para simular a verificação';

  @override
  String get enterPartnerCode =>
      'Introduza o código que a outra pessoa partilhou consigo:';

  @override
  String get partnerCodesReceivedWithCode => '✅ Códigos do parceiro recebidos:';

  @override
  String get waitingPartnerCodes => '⏳ A aguardar códigos do parceiro...';

  @override
  String get verificationSuccessMessage =>
      'Identidade verificada corretamente! Ambos os utilizadores são autênticos.';

  @override
  String get chatInvitationsTitle => 'Convites de Chat';

  @override
  String get cleanExpiredInvitations => 'Limpar convites expirados';

  @override
  String get refreshInvitations => 'Atualizar convites';

  @override
  String errorInitializing(String error) {
    return 'Erro ao inicializar: $error';
  }

  @override
  String expiredInvitationsDeleted(int count) {
    return '$count convites expirados eliminados definitivamente';
  }

  @override
  String get noExpiredInvitationsToClean =>
      'Não há convites expirados para limpar';

  @override
  String errorAcceptingInvitation(String error) {
    return 'Erro ao aceitar convite: $error';
  }

  @override
  String errorUpdatingInvitations(String error) {
    return 'Erro ao atualizar convites: $error';
  }

  @override
  String invitationsUpdated(int active, int expired) {
    return 'Atualizado: $active ativos, $expired expirados eliminados';
  }

  @override
  String invitationsUpdatedActive(int active) {
    return 'Atualizado: $active convites ativos';
  }

  @override
  String get noInvitations => 'Não há convites';

  @override
  String get invitationsWillAppearHere => 'Os convites de chat aparecerão aqui';

  @override
  String get chatInvitation => 'Convite de chat';

  @override
  String fromUser(String userId) {
    return 'De: $userId';
  }

  @override
  String get expired => 'Expirado';

  @override
  String get reject => 'Rejeitar';

  @override
  String get accept => 'Aceitar';

  @override
  String get tapToCreateOrJoinEphemeralChats =>
      'Toque para criar ou juntar-se a conversas efémeras';

  @override
  String get now => 'Agora';

  @override
  String get callEnded => 'Chamada terminada';

  @override
  String get videoCallFeatureAvailable =>
      '🎥 Funcionalidade de videochamada disponível';

  @override
  String get pendingInvitations => 'Convites pendentes';

  @override
  String chatInvitationsCount(int count) {
    return '$count convite(s) de chat';
  }

  @override
  String get searching => 'A procurar...';

  @override
  String get noUsersFound => 'Não foram encontrados utilizadores';

  @override
  String get errorSearchingUsers => 'Erro ao procurar utilizadores';

  @override
  String get startVideoCall => 'Iniciar videochamada';

  @override
  String get startAudioCall => 'Iniciar chamada';

  @override
  String confirmVideoCall(String nickname) {
    return 'Quer iniciar uma videochamada com $nickname?';
  }

  @override
  String confirmAudioCall(String nickname) {
    return 'Quer iniciar uma chamada com $nickname?';
  }

  @override
  String get initiatingVideoCall => 'A iniciar videochamada...';

  @override
  String get initiatingAudioCall => 'A iniciar chamada...';

  @override
  String get sendingInvitation => 'A enviar convite...';

  @override
  String get errorInitiatingCall => 'Erro ao iniciar a chamada';

  @override
  String get waitingForResponse => 'A aguardar resposta...';

  @override
  String get invitationSentTo => 'Convite enviado para';

  @override
  String get waitingForAcceptance => 'A aguardar que aceite o convite...';

  @override
  String get ephemeralChatTooltip => 'Chat Efémero';

  @override
  String get audioCallTooltip => 'Chamada';

  @override
  String get videoCallTooltip => 'Vídeo';

  @override
  String get searchUser => 'Procurar Utilizador';

  @override
  String get retry => 'Tentar Novamente';

  @override
  String get searchingUsers => 'A procurar utilizadores...';

  @override
  String noUsersFoundWith(String query) {
    return 'Não foram encontrados utilizadores\\ncom \"$query\"';
  }

  @override
  String errorSearchingUsersDetails(String error) {
    return 'Erro ao procurar utilizadores: $error';
  }

  @override
  String multipleChatsTitle(int count) {
    return 'Conversas Múltiplas ($count/10)';
  }

  @override
  String get backToHome => 'Voltar ao Início';

  @override
  String get closeAllRooms => 'Fechar Todas as Salas';

  @override
  String get closeAllRoomsConfirm =>
      'Tem a certeza de que quer fechar todas as salas de chat?';

  @override
  String get closeAll => 'Fechar Todas';

  @override
  String participants(int count) {
    return '$count participantes';
  }

  @override
  String roomActive(int count) {
    return 'Sala ativa ($count participantes)';
  }

  @override
  String get noConnection => 'Sem ligação';

  @override
  String get createNewRoom => 'Criar Nova Sala';

  @override
  String get addChat => 'Adicionar Conversa';

  @override
  String get statistics => 'Estatísticas';

  @override
  String get chatStatisticsTitle => 'Estatísticas de Chat';

  @override
  String get activeRooms => 'Salas ativas';

  @override
  String get totalMessages => 'Mensagens totais';

  @override
  String get unreadMessages => 'Não lidas';

  @override
  String get initiatingChat => 'A iniciar conversa...';

  @override
  String errorClosingRoom(String error) {
    return 'Erro ao fechar sala: $error';
  }

  @override
  String get invitationAccepted => '✅ Convite aceite';

  @override
  String errorAcceptingInvitationDetails(String error) {
    return 'Erro ao aceitar convite: $error';
  }

  @override
  String errorCreatingRoom(String error) {
    return 'Erro ao criar sala: $error';
  }

  @override
  String get createNewChatRoom => 'Criar nova sala de chat';

  @override
  String get minutes => 'minutos';

  @override
  String get seconds => 'segundos';

  @override
  String get microphonePermissions => '🎵 Permissões de Microfone';

  @override
  String get microphonePermissionsContent =>
      'Para gravar áudio precisa de ativar as permissões de microfone nas definições da aplicação.\n\nVá a Definições > Privacidade > Microfone e ative as permissões para esta aplicação.';

  @override
  String get openSettings => 'Abrir Definições';

  @override
  String errorInitializingAudio(String error) {
    return 'Erro ao inicializar áudio: $error';
  }

  @override
  String get imageTooLarge =>
      'Imagem demasiado grande. Máximo 500KB permitido.';

  @override
  String errorSendingImage(String error) {
    return 'Erro ao enviar imagem: $error';
  }

  @override
  String errorSendingAudio(String error) {
    return 'Erro ao enviar áudio: $error';
  }

  @override
  String get destroyRoomContent =>
      'Esta ação destruirá permanentemente a sala de chat para ambos os utilizadores.\n\nSerá iniciado um contador de 10 segundos visível para ambos os participantes.';

  @override
  String get destroyRoomButton => 'Destruir Sala';

  @override
  String get connectingToSecureChat => 'A ligar à conversa segura...';

  @override
  String get autoDestructionConfigured1Min =>
      'Autodestruição configurada: 1 minuto';

  @override
  String get autoDestructionConfigured5Min =>
      'Autodestruição configurada: 5 minutos';

  @override
  String get autoDestructionConfigured1Hour =>
      'Autodestruição configurada: 1 hora';

  @override
  String screenshotAlert(String user) {
    return '📸 Alerta! $user tirou uma captura de ecrã';
  }

  @override
  String screenshotNotification(String user) {
    return '📸 $user tirou uma captura de ecrã';
  }

  @override
  String get initializingAudioRecorder => 'A inicializar gravador de áudio...';

  @override
  String get audioRecorderNotAvailable =>
      'Gravador de áudio não disponível. Verifique as permissões de microfone.';

  @override
  String errorStartingRecording(String error) {
    return 'Erro ao iniciar gravação: $error';
  }

  @override
  String get audioPlayerNotAvailable => 'Reprodutor de áudio não disponível';

  @override
  String get audioNotAvailable => 'Áudio não disponível';

  @override
  String errorPlayingAudio(String error) {
    return 'Erro ao reproduzir áudio: $error';
  }

  @override
  String get screenshotTestSent => '📸 Teste de captura enviado';

  @override
  String errorSendingTest(String error) {
    return 'Erro ao enviar teste: $error';
  }

  @override
  String get audioTooLong => 'Áudio demasiado longo. Máximo 1MB permitido.';

  @override
  String get errorWebAudioRecording =>
      'Erro: Não foi possível gravar o áudio na web';

  @override
  String get errorWebAudioSaving => 'Erro: Não foi possível guardar o áudio';

  @override
  String errorStoppingRecording(String error) {
    return 'Erro ao parar gravação: $error';
  }

  @override
  String get sendEncryptedImageTooltip => 'Enviar imagem cifrada';

  @override
  String get myProfile => 'Meu Perfil';

  @override
  String get dangerZone => 'Zona Perigosa';

  @override
  String get dangerZoneDescription =>
      'Esta ação eliminará permanentemente a sua conta e todos os seus dados. Não poderá recuperar a sua conta uma vez eliminada.';

  @override
  String get destroyMyAccount => 'Destruir a minha conta';

  @override
  String get warningTitle => 'Aviso!';

  @override
  String get destroyAccountWarning =>
      'Está prestes a destruir permanentemente a sua conta.';

  @override
  String get thisActionWill => 'Esta ação irá:';

  @override
  String get deleteAllData => '• Eliminar todos os seus dados';

  @override
  String get closeAllSessions => '• Fechar todas as suas sessões ativas';

  @override
  String get deleteChatHistory => '• Eliminar o seu histórico de conversas';

  @override
  String get cannotBeUndone => '• Não pode ser desfeita';

  @override
  String get neverAccessAgain =>
      'Uma vez destruída, nunca mais poderá aceder a esta conta.';

  @override
  String get continueButton => 'Continuar';

  @override
  String get finalConfirmation => 'Confirmação Final';

  @override
  String get confirmDestructionText =>
      'Para confirmar a destruição da sua conta, escreva:';

  @override
  String get typeConfirmation => 'Escrever confirmação';

  @override
  String get destroyAccount => 'Destruir Conta';

  @override
  String get functionalityInDevelopment => 'Funcionalidade em desenvolvimento';

  @override
  String get accountDestructionAvailable =>
      'A destruição de conta estará disponível numa próxima atualização. O seu pedido foi registado.';
}
