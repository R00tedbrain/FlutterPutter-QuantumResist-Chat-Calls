// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'FlutterPutter';

  @override
  String get loginTitle => 'Connectez-vous pour continuer';

  @override
  String get email => 'Email';

  @override
  String get enterEmail => 'Saisissez votre email';

  @override
  String get password => 'Mot de passe';

  @override
  String get enterPassword => 'Saisissez votre mot de passe';

  @override
  String get pleaseEnterEmail => 'Veuillez saisir votre email';

  @override
  String get enterValidEmail => 'Saisissez un email valide';

  @override
  String get pleaseEnterPassword => 'Veuillez saisir votre mot de passe';

  @override
  String get passwordMinLength =>
      'Le mot de passe doit contenir au moins 6 caractères';

  @override
  String get loginButton => 'Se connecter';

  @override
  String get noAccount => 'Vous n\'avez pas de compte ?';

  @override
  String get register => 'S\'inscrire';

  @override
  String get oneSessionSecurity =>
      '🔒 Seule 1 session active par utilisateur est autorisée pour plus de sécurité';

  @override
  String get oneSessionMaxSecurity =>
      '1 seule session par utilisateur (Sécurité maximale)';

  @override
  String get privacyAndSecurity => 'Confidentialité et Sécurité';

  @override
  String get noDataCollection => 'Nous ne collectons aucune donnée personnelle';

  @override
  String get anonymousConnections => 'Toutes les connexions sont anonymes';

  @override
  String get ephemeralChatRooms =>
      'Salons de discussion éphémères qui se détruisent automatiquement';

  @override
  String get encryptionInfo =>
      'Chiffrement XSalsa20 avec clés aléatoires par salon';

  @override
  String get chats => 'Discussions';

  @override
  String get secureChat => 'Discussion Sécurisée';

  @override
  String get secureChatDescription =>
      'Appuyez pour créer ou rejoindre des discussions éphémères';

  @override
  String get privateVideoCall => 'Appel Vidéo Privé';

  @override
  String get videoCallDescription => 'Appel terminé';

  @override
  String get multipleChats => 'Discussions Multiples';

  @override
  String get newRoom => 'Nouveau Salon';

  @override
  String get noActiveChats => 'Aucune discussion active';

  @override
  String get useNewRoomButton =>
      'Utilisez l\'onglet \'Nouveau Salon\' pour créer une discussion';

  @override
  String get searchUsers => 'Rechercher des Utilisateurs';

  @override
  String get searchByNickname => 'Rechercher par pseudo';

  @override
  String get calls => 'Appels';

  @override
  String get verification => 'Vérification';

  @override
  String get verificationDemo => '🔐 Démo Vérification';

  @override
  String get verificationDemoDescription =>
      'Ceci est une démonstration du système de vérification d\'identité anonyme. Dans une implémentation réelle, ce widget serait intégré dans les salons de discussion éphémères.';

  @override
  String get room => 'Salon';

  @override
  String get user => 'Utilisateur';

  @override
  String get identityVerification => 'Vérification d\'Identité';

  @override
  String get verifyIdentityDescription =>
      'Appuyez pour vérifier l\'identité de manière anonyme';

  @override
  String get statusNotVerified => 'Statut : Non vérifié';

  @override
  String get notVerifiedYet => 'L\'identité n\'a pas encore été vérifiée';

  @override
  String get howToTest => 'Comment Tester la Vérification';

  @override
  String get step1 => 'Appuyez sur';

  @override
  String get step2 => 'Appuyez';

  @override
  String get step3 =>
      'Copiez l\'un des codes (alphanumérique, numérique ou emoji)';

  @override
  String get step4 => 'Collez le code dans';

  @override
  String get step5 => 'Appuyez';

  @override
  String get showMyCodes => 'Afficher Mes Codes';

  @override
  String get verifyPartnerCode => 'VÉRIFIER LE CODE DU PARTENAIRE';

  @override
  String get verify => 'Vérifier';

  @override
  String get realUsage =>
      'En utilisation réelle : Les utilisateurs partageraient les codes via WhatsApp, Telegram, etc.';

  @override
  String get securitySettings => 'Paramètres de Sécurité';

  @override
  String get securitySettingsDescription =>
      'Configurez un PIN de sécurité pour protéger votre vie privée. Les notifications continueront d\'arriver même si l\'application est verrouillée.';

  @override
  String get configureAppLock => 'Configurer le verrouillage de l\'application';

  @override
  String get newPin => 'Nouveau PIN (4-15 caractères)';

  @override
  String get confirmPin => 'Confirmer le PIN';

  @override
  String get activateLock => 'Activer le verrouillage';

  @override
  String get screenshotSecurity => 'Sécurité des captures d\'écran';

  @override
  String get screenshotSecurityDescription =>
      'Contrôlez si des captures d\'écran de l\'application peuvent être prises.';

  @override
  String get allowScreenshots => 'Autoriser les captures d\'écran';

  @override
  String get screenshotsAllowed => 'Les captures d\'écran sont AUTORISÉES';

  @override
  String get screenshotsDisabled =>
      'Vous pouvez les désactiver pour plus de sécurité';

  @override
  String get autoDestructionDefault => 'Autodestruction par défaut';

  @override
  String get autoDestructionDescription =>
      'Configurez un délai d\'autodestruction qui s\'appliquera automatiquement en rejoignant de nouveaux salons de discussion :';

  @override
  String get defaultTime => 'Délai par défaut :';

  @override
  String get noLimit => 'Aucune limite';

  @override
  String get selectTime =>
      'Sélectionnez un délai pour activer l\'autodestruction par défaut. Les messages seront automatiquement supprimés après le délai configuré.';

  @override
  String get activeSessions => 'Sessions actives';

  @override
  String get activeSessionsDescription =>
      'Gérez les appareils où vous avez des sessions ouvertes. Similaire à Signal et WhatsApp.';

  @override
  String get currentState => 'État actuel';

  @override
  String get noActiveSessionsRegistered => '0 sessions actives enregistrées';

  @override
  String get multipleSessions => 'Sessions multiples : Désactivé';

  @override
  String get configurationLikeSignal => 'et configuration comme Signal';

  @override
  String get manageSessions => 'Gérer les sessions';

  @override
  String get allowMultipleSessions => 'Autoriser les sessions multiples';

  @override
  String get onlyOneActiveSession =>
      'Une seule session active à la fois (comme Signal)';

  @override
  String get searchByName => 'Rechercher par nom...';

  @override
  String get writeAtLeast2Characters =>
      'Saisissez au moins 2 caractères pour rechercher des utilisateurs';

  @override
  String get connecting => 'Connexion en cours...';

  @override
  String get error => 'Erreur';

  @override
  String get secureMultimediaChat => 'Discussion Multimédia Sécurisée';

  @override
  String get sendEncryptedMessages =>
      'Envoyez des messages et des images\\nchiffrés avec XChaCha20-Poly1305';

  @override
  String get encryptedMessage => 'Message chiffré...';

  @override
  String get sendEncryptedImage => '📷 Envoyer une Image Chiffrée';

  @override
  String get takePhoto => 'Prendre une Photo';

  @override
  String get useCamera => 'Utiliser la caméra';

  @override
  String get gallery => 'Galerie';

  @override
  String get selectImage => 'Sélectionner une image';

  @override
  String get capturesBlocked => 'Captures d\'écran bloquées';

  @override
  String get capturesAllowed => 'Captures d\'écran autorisées';

  @override
  String get e2eEncryptionSecurity => 'Chiffrement E2E + Sécurité';

  @override
  String get encryptionDescription =>
      'Tous les messages, images et audio sont chiffrés localement avec XChaCha20-Poly1305.\\n\\nLe serveur ne voit que des blobs chiffrés opaques.\\n\\nAudio avec enregistrement réel implémenté.';

  @override
  String get screenshotsStatus => 'Captures d\'écran :';

  @override
  String get screenshotsBlocked => 'BLOQUÉES';

  @override
  String get screenshotsPermitted => 'AUTORISÉES';

  @override
  String get likeWhatsAppTelegram =>
      'Comme WhatsApp/Telegram - écran noir lors des captures d\'écran';

  @override
  String get understood => 'Compris';

  @override
  String get destroyRoom => '⚠️ Détruire le Salon';

  @override
  String get warningDestroyRoom =>
      'Cette action détruira définitivement le salon de discussion pour les deux utilisateurs.\\n\\nUn compte à rebours de 10 secondes visible par les deux participants sera lancé.';

  @override
  String get cancel => 'Annuler';

  @override
  String get audioNote => 'Note audio';

  @override
  String get recordedAudioNote => 'Note audio (enregistrée)';

  @override
  String get playing => 'Lecture en cours...';

  @override
  String get tapToStop => 'Appuyez pour arrêter';

  @override
  String get tapToPlay => 'Appuyez pour lire';

  @override
  String get image => 'Image';

  @override
  String get backToMultipleChats => 'Retour aux discussions multiples';

  @override
  String get backToChat => 'Retour à la discussion';

  @override
  String get screenshotsBlockedAutomatically => 'Captures d\'écran BLOQUÉES';

  @override
  String get screenshotsEnabled => 'Captures d\'écran ACTIVÉES';

  @override
  String get identityVerifiedCorrectly =>
      'Identité du partenaire vérifiée correctement';

  @override
  String get createAccount => 'Créer un Compte';

  @override
  String get registerSubtitle =>
      'Inscrivez-vous pour commencer à utiliser FlutterPutter';

  @override
  String get nickname => 'Pseudo';

  @override
  String get chooseUniqueNickname => 'Choisissez un pseudo unique';

  @override
  String get createSecurePassword => 'Créez un mot de passe sécurisé';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get repeatPassword => 'Répétez votre mot de passe';

  @override
  String get invitationCode => 'Code d\'Invitation';

  @override
  String get enterInvitationCode => 'Saisissez votre code d\'invitation';

  @override
  String get registerButton => 'S\'inscrire';

  @override
  String get pleaseConfirmPassword => 'Veuillez confirmer votre mot de passe';

  @override
  String get passwordsDoNotMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get pleaseEnterNickname => 'Veuillez saisir un pseudo';

  @override
  String get nicknameMinLength =>
      'Le pseudo doit contenir au moins 3 caractères';

  @override
  String get pleaseEnterInvitationCode =>
      'Veuillez saisir un code d\'invitation';

  @override
  String get invitationCodeLength => 'Le code doit contenir 8 caractères';

  @override
  String get newChatInvitationReceived =>
      '📩 Nouvelle invitation de discussion reçue';

  @override
  String get view => 'Voir';

  @override
  String get chatInvitations => 'Invitations de Discussion';

  @override
  String get securitySettingsTooltip => 'Paramètres de Sécurité';

  @override
  String helloUser(String nickname) {
    return 'Bonjour, $nickname';
  }

  @override
  String get searchUsersToVideoCall =>
      'Recherchez des utilisateurs pour démarrer un appel vidéo';

  @override
  String get searchUsersButton => 'Rechercher des Utilisateurs';

  @override
  String get testIdentityVerification => 'Tester la vérification d\'identité';

  @override
  String get ephemeralChat => '💬 Discussion Éphémère';

  @override
  String get multipleSimultaneousRooms =>
      'Plusieurs salons simultanés (max. 10)';

  @override
  String get logout => 'Se déconnecter';

  @override
  String get logoutConfirmTitle => 'Se déconnecter';

  @override
  String get logoutConfirmMessage =>
      'Êtes-vous sûr de vouloir vous déconnecter ?';

  @override
  String get helpSection => 'Aide et Assistance';

  @override
  String get supportCenter => 'Centre d\'aide';

  @override
  String get supportCenterDescription =>
      'Obtenez de l\'aide et consultez la FAQ';

  @override
  String get contactUs => 'Contactez-nous';

  @override
  String get contactUsDescription =>
      'Envoyez-nous un email pour résoudre vos doutes';

  @override
  String get contactEmail => 'FlutterPutter@Proton.me';

  @override
  String get appVersion => 'Version';

  @override
  String get versionNumber => 'Version 1.0 Bêta';

  @override
  String get termsAndConditions => 'Termes et conditions';

  @override
  String get termsDescription => 'Lisez nos conditions d\'utilisation';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get privacyPolicyDescription =>
      'Consultez comment nous protégeons vos informations';

  @override
  String get emailCopied => 'Email copié dans le presse-papiers';

  @override
  String get openingWebPage => 'Ouverture de la page web...';

  @override
  String get errorOpeningWebPage =>
      'Erreur lors de l\'ouverture de la page web';

  @override
  String get pinLengthError => 'Le PIN doit contenir entre 4 et 15 caractères';

  @override
  String get pinMismatch => 'Les PIN ne correspondent pas';

  @override
  String get appLockSetupSuccess =>
      '🔒 Verrouillage de l\'application configuré avec succès';

  @override
  String get pinSetupError => 'Erreur lors de la configuration du PIN';

  @override
  String get pinChangeSuccess => '🔒 PIN modifié avec succès';

  @override
  String get currentPinIncorrect => 'PIN actuel incorrect';

  @override
  String get disableAppLockTitle => 'Désactiver le verrouillage';

  @override
  String get disableAppLockMessage =>
      'Êtes-vous sûr de vouloir désactiver le verrouillage de l\'application ?';

  @override
  String get appLockDisabled => '🔓 Verrouillage de l\'application désactivé';

  @override
  String get confirm => 'Confirmer';

  @override
  String get changePin => 'Changer le PIN :';

  @override
  String get currentPin => 'PIN actuel';

  @override
  String get confirmNewPin => 'Confirmer le nouveau PIN';

  @override
  String get changePinButton => 'Changer le PIN';

  @override
  String get biometricUnlock =>
      'Déverrouillez l\'application avec la biométrie en plus du PIN';

  @override
  String get screenshotsAllowedMessage => '🔓 Captures d\'écran AUTORISÉES';

  @override
  String get screenshotsBlockedMessage => '🔒 Captures d\'écran BLOQUÉES';

  @override
  String get screenshotConfigError =>
      'Erreur lors de la mise à jour de la configuration des captures d\'écran';

  @override
  String get protectionActive => 'Protection active';

  @override
  String get nativeProtectionFeatures =>
      '• Verrouillage natif sur iOS et Android\n• Alerte lors de la détection de tentatives de capture\n• Protection dans le sélecteur d\'applications';

  @override
  String get autoDestructionDefaultDisabled =>
      '🔥 Autodestruction par défaut désactivée';

  @override
  String get autoDestructionError =>
      'Erreur lors de la mise à jour de la configuration d\'autodestruction';

  @override
  String get protectYourApp => 'Protégez votre application';

  @override
  String get securityPinDescription =>
      'Configurez un PIN de sécurité pour protéger votre vie privée. Les notifications continueront d\'arriver même si l\'application est verrouillée.';

  @override
  String get lockActivated => 'Verrouillage activé';

  @override
  String get disable => 'Désactiver';

  @override
  String get errorCopyingEmail => 'Erreur lors de la copie de l\'email';

  @override
  String get automaticLockTimeout => 'Délai de verrouillage automatique';

  @override
  String get appWillLockAfter =>
      'L\'application se verrouillera automatiquement après :';

  @override
  String get biometricAuthentication => 'Authentification biométrique';

  @override
  String get enableBiometric => 'Activer empreinte digitale/Face ID';

  @override
  String get autoApplyDefault => 'Appliquer automatiquement';

  @override
  String get autoApplyEnabled =>
      'S\'appliquera en rejoignant de nouveaux salons';

  @override
  String get autoApplyDisabled =>
      'Appliquer manuellement uniquement dans chaque salon';

  @override
  String get currentConfiguration => 'Configuration actuelle';

  @override
  String get sessionActive => 'session active';

  @override
  String get sessionsActive => 'sessions actives';

  @override
  String get noActiveSessionsMessage => 'Aucune session active enregistrée';

  @override
  String get helpAndSupport =>
      'Obtenez de l\'aide, contactez-nous ou consultez nos politiques';

  @override
  String get autoDestructionDefaultEnabled =>
      '🔥 Autodestruction par défaut : ';

  @override
  String get verificationDemonstration => 'Démonstration de Vérification';

  @override
  String get roomLabel => 'Salon :';

  @override
  String get userLabel => 'Utilisateur :';

  @override
  String get statusVerified => 'Statut : Vérifié ✅';

  @override
  String get identityVerifiedCorrect =>
      'L\'identité a été vérifiée correctement';

  @override
  String get identityVerifiedFull => '✅ Identité Vérifiée';

  @override
  String get bothUsersVerified =>
      'Les deux utilisateurs ont vérifié leur identité';

  @override
  String get yourVerificationCodes => 'VOS CODES DE VÉRIFICATION';

  @override
  String get shareCodeMessage =>
      'Partagez UN de ces codes via un autre canal (WhatsApp, Telegram, etc.)';

  @override
  String get hideCodesBut => '🙈 Masquer les Codes';

  @override
  String get alphanumericCode => '🔤 Alphanumérique';

  @override
  String get numericCode => '🔢 Numérique';

  @override
  String get emojiCode => '😀 Emoji';

  @override
  String get enterCodeToVerify => '❌ Saisissez un code pour vérifier';

  @override
  String get invalidCodeFormat => '❌ Format de code invalide';

  @override
  String get identityVerifiedSuccess => '✅ Identité vérifiée correctement !';

  @override
  String get incorrectCode => '❌ Code incorrect';

  @override
  String get codesRegenerated => '🔄 Codes régénérés';

  @override
  String get codeCopied => '📋 Code copié dans le presse-papiers';

  @override
  String get partnerCodesReceived => '📥 Codes du partenaire reçus';

  @override
  String get codesSentToPartner => '📤 Codes envoyés au partenaire';

  @override
  String get resendingCodes => '🔄 Renvoi des codes au partenaire...';

  @override
  String get stepExpandVerification =>
      'Appuyez sur \"🔐 Vérification d\'Identité\" pour développer';

  @override
  String get stepShowCodes =>
      'Appuyez sur \"👁️ Afficher Mes Codes\" pour voir vos codes uniques';

  @override
  String get stepPasteCode =>
      'Collez le code dans \"VÉRIFIER LE CODE DU PARTENAIRE\"';

  @override
  String get stepVerifyCode =>
      'Appuyez sur \"✅ Vérifier\" pour simuler la vérification';

  @override
  String get enterPartnerCode =>
      'Saisissez le code que l\'autre personne a partagé avec vous :';

  @override
  String get partnerCodesReceivedWithCode => '✅ Codes du partenaire reçus :';

  @override
  String get waitingPartnerCodes => '⏳ En attente des codes du partenaire...';

  @override
  String get verificationSuccessMessage =>
      'Identité vérifiée correctement ! Les deux utilisateurs sont authentiques.';

  @override
  String get chatInvitationsTitle => 'Invitations de Discussion';

  @override
  String get cleanExpiredInvitations => 'Nettoyer les invitations expirées';

  @override
  String get refreshInvitations => 'Actualiser les invitations';

  @override
  String errorInitializing(String error) {
    return 'Erreur d\'initialisation : $error';
  }

  @override
  String expiredInvitationsDeleted(int count) {
    return '$count invitations expirées supprimées définitivement';
  }

  @override
  String get noExpiredInvitationsToClean =>
      'Aucune invitation expirée à nettoyer';

  @override
  String errorAcceptingInvitation(String error) {
    return 'Erreur lors de l\'acceptation de l\'invitation : $error';
  }

  @override
  String errorUpdatingInvitations(String error) {
    return 'Erreur lors de la mise à jour des invitations : $error';
  }

  @override
  String invitationsUpdated(int active, int expired) {
    return 'Mis à jour : $active actives, $expired expirées supprimées';
  }

  @override
  String invitationsUpdatedActive(int active) {
    return 'Mis à jour : $active invitations actives';
  }

  @override
  String get noInvitations => 'Aucune invitation';

  @override
  String get invitationsWillAppearHere =>
      'Les invitations de discussion apparaîtront ici';

  @override
  String get chatInvitation => 'Invitation de discussion';

  @override
  String fromUser(String userId) {
    return 'De : $userId';
  }

  @override
  String get expired => 'Expirée';

  @override
  String get reject => 'Rejeter';

  @override
  String get accept => 'Accepter';

  @override
  String get tapToCreateOrJoinEphemeralChats =>
      'Appuyez pour créer ou rejoindre des discussions éphémères';

  @override
  String get now => 'Maintenant';

  @override
  String get callEnded => 'Appel terminé';

  @override
  String get videoCallFeatureAvailable =>
      '🎥 Fonction d\'appel vidéo disponible';

  @override
  String get pendingInvitations => 'Invitations en attente';

  @override
  String chatInvitationsCount(int count) {
    return '$count invitation(s) de discussion';
  }

  @override
  String get searching => 'Recherche en cours...';

  @override
  String get noUsersFound => 'Aucun utilisateur trouvé';

  @override
  String get errorSearchingUsers =>
      'Erreur lors de la recherche d\'utilisateurs';

  @override
  String get startVideoCall => 'Démarrer l\'appel vidéo';

  @override
  String get startAudioCall => 'Démarrer l\'appel audio';

  @override
  String confirmVideoCall(String nickname) {
    return 'Voulez-vous démarrer un appel vidéo avec $nickname ?';
  }

  @override
  String confirmAudioCall(String nickname) {
    return 'Voulez-vous démarrer un appel audio avec $nickname ?';
  }

  @override
  String get initiatingVideoCall => 'Démarrage de l\'appel vidéo...';

  @override
  String get initiatingAudioCall => 'Démarrage de l\'appel audio...';

  @override
  String get sendingInvitation => 'Envoi de l\'invitation...';

  @override
  String get errorInitiatingCall => 'Erreur lors du démarrage de l\'appel';

  @override
  String get waitingForResponse => 'En attente de réponse...';

  @override
  String get invitationSentTo => 'Invitation envoyée à';

  @override
  String get waitingForAcceptance =>
      'En attente de l\'acceptation de l\'invitation...';

  @override
  String get ephemeralChatTooltip => 'Discussion Éphémère';

  @override
  String get audioCallTooltip => 'Appel';

  @override
  String get videoCallTooltip => 'Vidéo';

  @override
  String get searchUser => 'Rechercher un Utilisateur';

  @override
  String get retry => 'Réessayer';

  @override
  String get searchingUsers => 'Recherche d\'utilisateurs en cours...';

  @override
  String noUsersFoundWith(String query) {
    return 'Aucun utilisateur trouvé\\navec \"$query\"';
  }

  @override
  String errorSearchingUsersDetails(String error) {
    return 'Erreur lors de la recherche d\'utilisateurs : $error';
  }

  @override
  String multipleChatsTitle(int count) {
    return 'Discussions Multiples ($count/10)';
  }

  @override
  String get backToHome => 'Retour à l\'accueil';

  @override
  String get closeAllRooms => 'Fermer Tous les Salons';

  @override
  String get closeAllRoomsConfirm =>
      'Êtes-vous sûr de vouloir fermer tous les salons de discussion ?';

  @override
  String get closeAll => 'Tout Fermer';

  @override
  String participants(int count) {
    return '$count participants';
  }

  @override
  String roomActive(int count) {
    return 'Salon actif ($count participants)';
  }

  @override
  String get noConnection => 'Pas de connexion';

  @override
  String get createNewRoom => 'Créer un Nouveau Salon';

  @override
  String get addChat => 'Ajouter une Discussion';

  @override
  String get statistics => 'Statistiques';

  @override
  String get chatStatisticsTitle => 'Statistiques de Discussion';

  @override
  String get activeRooms => 'Salons actifs';

  @override
  String get totalMessages => 'Messages totaux';

  @override
  String get unreadMessages => 'Non lus';

  @override
  String get initiatingChat => 'Démarrage de la discussion...';

  @override
  String errorClosingRoom(String error) {
    return 'Erreur lors de la fermeture du salon : $error';
  }

  @override
  String get invitationAccepted => '✅ Invitation acceptée';

  @override
  String errorAcceptingInvitationDetails(String error) {
    return 'Erreur lors de l\'acceptation de l\'invitation : $error';
  }

  @override
  String errorCreatingRoom(String error) {
    return 'Erreur lors de la création du salon : $error';
  }

  @override
  String get createNewChatRoom => 'Créer un nouveau salon de discussion';

  @override
  String get minutes => 'minutes';

  @override
  String get seconds => 'secondes';

  @override
  String get microphonePermissions => '🎵 Autorisations du Microphone';

  @override
  String get microphonePermissionsContent =>
      'Pour enregistrer de l\'audio, vous devez activer les autorisations du microphone dans les paramètres de l\'application.\n\nAllez dans Paramètres > Confidentialité > Microphone et activez les autorisations pour cette application.';

  @override
  String get openSettings => 'Ouvrir les Paramètres';

  @override
  String errorInitializingAudio(String error) {
    return 'Erreur lors de l\'initialisation de l\'audio : $error';
  }

  @override
  String get imageTooLarge => 'Image trop grande. Maximum 500 Ko autorisé.';

  @override
  String errorSendingImage(String error) {
    return 'Erreur lors de l\'envoi de l\'image : $error';
  }

  @override
  String errorSendingAudio(String error) {
    return 'Erreur lors de l\'envoi de l\'audio : $error';
  }

  @override
  String get destroyRoomContent =>
      'Cette action détruira définitivement le salon de discussion pour les deux utilisateurs.\n\nUn compte à rebours de 10 secondes visible par les deux participants sera lancé.';

  @override
  String get destroyRoomButton => 'Détruire le Salon';

  @override
  String get connectingToSecureChat => 'Connexion à la discussion sécurisée...';

  @override
  String get autoDestructionConfigured1Min =>
      'Autodestruction configurée : 1 minute';

  @override
  String get autoDestructionConfigured5Min =>
      'Autodestruction configurée : 5 minutes';

  @override
  String get autoDestructionConfigured1Hour =>
      'Autodestruction configurée : 1 heure';

  @override
  String screenshotAlert(String user) {
    return '📸 Alerte ! $user a fait une capture d\'écran';
  }

  @override
  String screenshotNotification(String user) {
    return '📸 $user a fait une capture d\'écran';
  }

  @override
  String get initializingAudioRecorder =>
      'Initialisation de l\'enregistreur audio...';

  @override
  String get audioRecorderNotAvailable =>
      'Enregistreur audio non disponible. Vérifiez les autorisations du microphone.';

  @override
  String errorStartingRecording(String error) {
    return 'Erreur lors du démarrage de l\'enregistrement : $error';
  }

  @override
  String get audioPlayerNotAvailable => 'Lecteur audio non disponible';

  @override
  String get audioNotAvailable => 'Audio non disponible';

  @override
  String errorPlayingAudio(String error) {
    return 'Erreur lors de la lecture de l\'audio : $error';
  }

  @override
  String get screenshotTestSent => '📸 Test de capture d\'écran envoyé';

  @override
  String errorSendingTest(String error) {
    return 'Erreur lors de l\'envoi du test : $error';
  }

  @override
  String get audioTooLong => 'Audio trop long. Maximum 1 Mo autorisé.';

  @override
  String get errorWebAudioRecording =>
      'Erreur : Impossible d\'enregistrer l\'audio sur le web';

  @override
  String get errorWebAudioSaving =>
      'Erreur : Impossible de sauvegarder l\'audio';

  @override
  String errorStoppingRecording(String error) {
    return 'Erreur lors de l\'arrêt de l\'enregistrement : $error';
  }

  @override
  String get sendEncryptedImageTooltip => 'Envoyer une image chiffrée';

  @override
  String get myProfile => 'Mon Profil';

  @override
  String get dangerZone => 'Zone Dangereuse';

  @override
  String get dangerZoneDescription =>
      'Cette action supprimera définitivement votre compte et toutes vos données. Vous ne pourrez pas récupérer votre compte une fois qu\'il sera supprimé.';

  @override
  String get destroyMyAccount => 'Détruire mon compte';

  @override
  String get warningTitle => 'Attention !';

  @override
  String get destroyAccountWarning =>
      'Vous êtes sur le point de détruire définitivement votre compte.';

  @override
  String get thisActionWill => 'Cette action va :';

  @override
  String get deleteAllData => '• Supprimer toutes vos données';

  @override
  String get closeAllSessions => '• Fermer toutes vos sessions actives';

  @override
  String get deleteChatHistory => '• Supprimer votre historique de chat';

  @override
  String get cannotBeUndone => '• Ne peut pas être annulé';

  @override
  String get neverAccessAgain =>
      'Une fois détruit, vous ne pourrez plus jamais accéder à ce compte.';

  @override
  String get continueButton => 'Continuer';

  @override
  String get finalConfirmation => 'Confirmation Finale';

  @override
  String get confirmDestructionText =>
      'Pour confirmer la destruction de votre compte, tapez :';

  @override
  String get typeConfirmation => 'Tapez la confirmation';

  @override
  String get destroyAccount => 'Détruire le Compte';

  @override
  String get functionalityInDevelopment => 'Fonctionnalité en développement';

  @override
  String get accountDestructionAvailable =>
      'La destruction de compte sera disponible dans une prochaine mise à jour. Votre demande a été enregistrée.';
}
