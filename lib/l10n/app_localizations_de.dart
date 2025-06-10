// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'FlutterPutter';

  @override
  String get loginTitle => 'Melden Sie sich an, um fortzufahren';

  @override
  String get email => 'E-Mail';

  @override
  String get enterEmail => 'Geben Sie Ihre E-Mail-Adresse ein';

  @override
  String get password => 'Passwort';

  @override
  String get enterPassword => 'Geben Sie Ihr Passwort ein';

  @override
  String get pleaseEnterEmail => 'Bitte geben Sie Ihre E-Mail-Adresse ein';

  @override
  String get enterValidEmail => 'Geben Sie eine gültige E-Mail-Adresse ein';

  @override
  String get pleaseEnterPassword => 'Bitte geben Sie Ihr Passwort ein';

  @override
  String get passwordMinLength =>
      'Das Passwort muss mindestens 6 Zeichen lang sein';

  @override
  String get loginButton => 'Anmelden';

  @override
  String get noAccount => 'Sie haben noch kein Konto?';

  @override
  String get register => 'Registrieren';

  @override
  String get oneSessionSecurity =>
      '🔒 Nur 1 aktive Sitzung pro Benutzer für erhöhte Sicherheit erlaubt';

  @override
  String get oneSessionMaxSecurity =>
      'Nur 1 Sitzung pro Benutzer (Maximale Sicherheit)';

  @override
  String get privacyAndSecurity => 'Datenschutz und Sicherheit';

  @override
  String get noDataCollection => 'Wir sammeln keine personenbezogenen Daten';

  @override
  String get anonymousConnections => 'Alle Verbindungen sind anonym';

  @override
  String get ephemeralChatRooms =>
      'Temporäre Chaträume, die automatisch zerstört werden';

  @override
  String get encryptionInfo =>
      'XSalsa20-Verschlüsselung mit zufälligen Schlüsseln pro Raum';

  @override
  String get chats => 'Chats';

  @override
  String get secureChat => 'Sicherer Chat';

  @override
  String get secureChatDescription =>
      'Tippen, um temporäre Chats zu erstellen oder beizutreten';

  @override
  String get privateVideoCall => 'Privater Videoanruf';

  @override
  String get videoCallDescription => 'Anruf beendet';

  @override
  String get multipleChats => 'Mehrere Chats';

  @override
  String get newRoom => 'Neuer Raum';

  @override
  String get noActiveChats => 'Keine aktiven Chats';

  @override
  String get useNewRoomButton =>
      'Verwenden Sie die Registerkarte \'Neuer Raum\', um einen Chat zu erstellen';

  @override
  String get searchUsers => 'Benutzer suchen';

  @override
  String get searchByNickname => 'Nach Nickname suchen';

  @override
  String get calls => 'Anrufe';

  @override
  String get verification => 'Verifizierung';

  @override
  String get verificationDemo => '🔐 Demo Verifizierung';

  @override
  String get verificationDemoDescription =>
      'Dies ist eine Demonstration des anonymen Identitätsverifizierungssystems. In einer realen Implementierung würde dieses Widget in die temporären Chaträume integriert.';

  @override
  String get room => 'Raum';

  @override
  String get user => 'Benutzer';

  @override
  String get identityVerification => 'Identitätsverifizierung';

  @override
  String get verifyIdentityDescription =>
      'Tippen, um die Identität anonym zu verifizieren';

  @override
  String get statusNotVerified => 'Status: Nicht verifiziert';

  @override
  String get notVerifiedYet => 'Die Identität wurde noch nicht verifiziert';

  @override
  String get howToTest => 'Wie man die Verifizierung testet';

  @override
  String get step1 => 'Tippen Sie auf';

  @override
  String get step2 => 'Tippen';

  @override
  String get step3 =>
      'Kopieren Sie einen der Codes (alphanumerisch, numerisch oder Emoji)';

  @override
  String get step4 => 'Fügen Sie den Code in';

  @override
  String get step5 => 'Tippen';

  @override
  String get showMyCodes => 'Meine Codes anzeigen';

  @override
  String get verifyPartnerCode => 'PARTNERCODE VERIFIZIEREN';

  @override
  String get verify => 'Verifizieren';

  @override
  String get realUsage =>
      'In der realen Anwendung: Benutzer würden Codes über WhatsApp, Telegram usw. teilen.';

  @override
  String get securitySettings => 'Sicherheitseinstellungen';

  @override
  String get securitySettingsDescription =>
      'Richten Sie eine Sicherheits-PIN ein, um Ihre Privatsphäre zu schützen. Benachrichtigungen werden weiterhin empfangen, auch wenn die App gesperrt ist.';

  @override
  String get configureAppLock => 'App-Sperre konfigurieren';

  @override
  String get newPin => 'Neue PIN (4-15 Zeichen)';

  @override
  String get confirmPin => 'PIN bestätigen';

  @override
  String get activateLock => 'Sperre aktivieren';

  @override
  String get screenshotSecurity => 'Screenshot-Sicherheit';

  @override
  String get screenshotSecurityDescription =>
      'Kontrollieren Sie, ob Screenshots der Anwendung erstellt werden können.';

  @override
  String get allowScreenshots => 'Screenshots erlauben';

  @override
  String get screenshotsAllowed => 'Screenshots sind ERLAUBT';

  @override
  String get screenshotsDisabled =>
      'Sie können sie für mehr Sicherheit deaktivieren';

  @override
  String get autoDestructionDefault => 'Standard-Selbstzerstörung';

  @override
  String get autoDestructionDescription =>
      'Konfigurieren Sie eine Selbstzerstörungszeit, die automatisch angewendet wird, wenn Sie neuen Chaträumen beitreten:';

  @override
  String get defaultTime => 'Standardzeit:';

  @override
  String get noLimit => 'Kein Limit';

  @override
  String get selectTime =>
      'Wählen Sie eine Zeit aus, um die Standard-Selbstzerstörung zu aktivieren. Nachrichten werden nach der konfigurierten Zeit automatisch gelöscht.';

  @override
  String get activeSessions => 'Aktive Sitzungen';

  @override
  String get activeSessionsDescription =>
      'Verwalten Sie die Geräte, auf denen Sie aktive Sitzungen haben. Ähnlich wie Signal und WhatsApp.';

  @override
  String get currentState => 'Aktueller Status';

  @override
  String get noActiveSessionsRegistered => '0 aktive Sitzungen registriert';

  @override
  String get multipleSessions => 'Mehrere Sitzungen: Deaktiviert';

  @override
  String get configurationLikeSignal => 'und Konfiguration wie Signal';

  @override
  String get manageSessions => 'Sitzungen verwalten';

  @override
  String get allowMultipleSessions => 'Mehrere Sitzungen erlauben';

  @override
  String get onlyOneActiveSession =>
      'Nur eine aktive Sitzung gleichzeitig (wie Signal)';

  @override
  String get searchByName => 'Nach Name suchen...';

  @override
  String get writeAtLeast2Characters =>
      'Geben Sie mindestens 2 Zeichen ein, um Benutzer zu suchen';

  @override
  String get connecting => 'Verbinden...';

  @override
  String get error => 'Fehler';

  @override
  String get secureMultimediaChat => 'Sicherer Multimedia-Chat';

  @override
  String get sendEncryptedMessages =>
      'Senden Sie Nachrichten und Bilder\\nverschlüsselt mit XChaCha20-Poly1305';

  @override
  String get encryptedMessage => 'Verschlüsselte Nachricht...';

  @override
  String get sendEncryptedImage => '📷 Verschlüsseltes Bild senden';

  @override
  String get takePhoto => 'Foto aufnehmen';

  @override
  String get useCamera => 'Kamera verwenden';

  @override
  String get gallery => 'Galerie';

  @override
  String get selectImage => 'Bild auswählen';

  @override
  String get capturesBlocked => 'Aufnahmen blockiert';

  @override
  String get capturesAllowed => 'Aufnahmen erlaubt';

  @override
  String get e2eEncryptionSecurity => 'E2E-Verschlüsselung + Sicherheit';

  @override
  String get encryptionDescription =>
      'Alle Nachrichten, Bilder und Audiodateien sind lokal mit XChaCha20-Poly1305 verschlüsselt.\\n\\nDer Server sieht nur undurchsichtige verschlüsselte Blobs.\\n\\nAudio mit realer Aufnahme implementiert.';

  @override
  String get screenshotsStatus => 'Screenshots:';

  @override
  String get screenshotsBlocked => 'BLOCKIERT';

  @override
  String get screenshotsPermitted => 'ERLAUBT';

  @override
  String get likeWhatsAppTelegram =>
      'Wie WhatsApp/Telegram - schwarzer Bildschirm bei Screenshots';

  @override
  String get understood => 'Verstanden';

  @override
  String get destroyRoom => '⚠️ Raum zerstören';

  @override
  String get warningDestroyRoom =>
      'Diese Aktion zerstört den Chatraum dauerhaft für beide Benutzer.\\n\\nEin für beide Teilnehmer sichtbarer 10-Sekunden-Countdown wird gestartet.';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get audioNote => 'Audionotiz';

  @override
  String get recordedAudioNote => 'Audionotiz (aufgenommen)';

  @override
  String get playing => 'Wird abgespielt...';

  @override
  String get tapToStop => 'Tippen zum Stoppen';

  @override
  String get tapToPlay => 'Tippen zum Abspielen';

  @override
  String get image => 'Bild';

  @override
  String get backToMultipleChats => 'Zurück zu mehreren Chats';

  @override
  String get backToChat => 'Zurück zum Chat';

  @override
  String get screenshotsBlockedAutomatically =>
      'Screenshots AUTOMATISCH BLOCKIERT';

  @override
  String get screenshotsEnabled => 'Screenshots AKTIVIERT';

  @override
  String get identityVerifiedCorrectly =>
      'Identität des Partners korrekt verifiziert';

  @override
  String get createAccount => 'Konto erstellen';

  @override
  String get registerSubtitle =>
      'Registrieren Sie sich, um FlutterPutter zu nutzen';

  @override
  String get nickname => 'Nickname';

  @override
  String get chooseUniqueNickname => 'Wählen Sie einen einzigartigen Nickname';

  @override
  String get createSecurePassword => 'Erstellen Sie ein sicheres Passwort';

  @override
  String get confirmPassword => 'Passwort bestätigen';

  @override
  String get repeatPassword => 'Wiederholen Sie Ihr Passwort';

  @override
  String get invitationCode => 'Einladungscode';

  @override
  String get enterInvitationCode => 'Geben Sie Ihren Einladungscode ein';

  @override
  String get registerButton => 'Registrieren';

  @override
  String get pleaseConfirmPassword => 'Bitte bestätigen Sie Ihr Passwort';

  @override
  String get passwordsDoNotMatch => 'Die Passwörter stimmen nicht überein';

  @override
  String get pleaseEnterNickname => 'Bitte geben Sie einen Nickname ein';

  @override
  String get nicknameMinLength =>
      'Der Nickname muss mindestens 3 Zeichen lang sein';

  @override
  String get pleaseEnterInvitationCode =>
      'Bitte geben Sie einen Einladungscode ein';

  @override
  String get invitationCodeLength => 'Der Code muss 8 Zeichen lang sein';

  @override
  String get newChatInvitationReceived => '📩 Neue Chat-Einladung erhalten';

  @override
  String get view => 'Ansehen';

  @override
  String get chatInvitations => 'Chat-Einladungen';

  @override
  String get securitySettingsTooltip => 'Sicherheitseinstellungen';

  @override
  String helloUser(String nickname) {
    return 'Hallo, $nickname';
  }

  @override
  String get searchUsersToVideoCall =>
      'Suchen Sie Benutzer, um einen Videoanruf zu starten';

  @override
  String get searchUsersButton => 'Benutzer suchen';

  @override
  String get testIdentityVerification => 'Identitätsverifizierung testen';

  @override
  String get ephemeralChat => '💬 Temporärer Chat';

  @override
  String get multipleSimultaneousRooms =>
      'Mehrere gleichzeitige Räume (max. 10)';

  @override
  String get logout => 'Abmelden';

  @override
  String get logoutConfirmTitle => 'Abmelden';

  @override
  String get logoutConfirmMessage =>
      'Sind Sie sicher, dass Sie sich abmelden möchten?';

  @override
  String get helpSection => 'Hilfe und Support';

  @override
  String get supportCenter => 'Hilfezentrum';

  @override
  String get supportCenterDescription =>
      'Holen Sie sich Hilfe und sehen Sie sich die FAQs an';

  @override
  String get contactUs => 'Kontaktieren Sie uns';

  @override
  String get contactUsDescription =>
      'Senden Sie uns eine E-Mail, um Ihre Fragen zu klären';

  @override
  String get contactEmail => 'FlutterPutter@Proton.me';

  @override
  String get appVersion => 'Version';

  @override
  String get versionNumber => 'Version 1.0 Beta';

  @override
  String get termsAndConditions => 'Allgemeine Geschäftsbedingungen';

  @override
  String get termsDescription => 'Lesen Sie unsere Nutzungsbedingungen';

  @override
  String get privacyPolicy => 'Datenschutzrichtlinie';

  @override
  String get privacyPolicyDescription =>
      'Erfahren Sie, wie wir Ihre Informationen schützen';

  @override
  String get emailCopied => 'E-Mail in die Zwischenablage kopiert';

  @override
  String get openingWebPage => 'Webseite wird geöffnet...';

  @override
  String get errorOpeningWebPage => 'Fehler beim Öffnen der Webseite';

  @override
  String get pinLengthError =>
      'Die PIN muss zwischen 4 und 15 Zeichen lang sein';

  @override
  String get pinMismatch => 'Die PINs stimmen nicht überein';

  @override
  String get appLockSetupSuccess => '🔒 App-Sperre erfolgreich eingerichtet';

  @override
  String get pinSetupError => 'Fehler beim Einrichten der PIN';

  @override
  String get pinChangeSuccess => '🔒 PIN erfolgreich geändert';

  @override
  String get currentPinIncorrect => 'Aktuelle PIN falsch';

  @override
  String get disableAppLockTitle => 'Sperre deaktivieren';

  @override
  String get disableAppLockMessage =>
      'Sind Sie sicher, dass Sie die App-Sperre deaktivieren möchten?';

  @override
  String get appLockDisabled => '🔓 App-Sperre deaktiviert';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get changePin => 'PIN ändern:';

  @override
  String get currentPin => 'Aktuelle PIN';

  @override
  String get confirmNewPin => 'Neue PIN bestätigen';

  @override
  String get changePinButton => 'PIN ändern';

  @override
  String get biometricUnlock =>
      'Entsperren Sie die App zusätzlich zur PIN mit Biometrie';

  @override
  String get screenshotsAllowedMessage => '🔓 Screenshots ERLAUBT';

  @override
  String get screenshotsBlockedMessage => '🔒 Screenshots BLOCKIERT';

  @override
  String get screenshotConfigError =>
      'Fehler beim Aktualisieren der Screenshot-Konfiguration';

  @override
  String get protectionActive => 'Schutz aktiv';

  @override
  String get nativeProtectionFeatures =>
      '• Native Sperre unter iOS und Android\n• Warnung bei Erkennung von Screenshot-Versuchen\n• Schutz im App-Switcher';

  @override
  String get autoDestructionDefaultDisabled =>
      '🔥 Standard-Selbstzerstörung deaktiviert';

  @override
  String get autoDestructionError =>
      'Fehler beim Aktualisieren der Selbstzerstörungskonfiguration';

  @override
  String get protectYourApp => 'Schützen Sie Ihre Anwendung';

  @override
  String get securityPinDescription =>
      'Richten Sie eine Sicherheits-PIN ein, um Ihre Privatsphäre zu schützen. Benachrichtigungen werden weiterhin empfangen, auch wenn die App gesperrt ist.';

  @override
  String get lockActivated => 'Sperre aktiviert';

  @override
  String get disable => 'Deaktivieren';

  @override
  String get errorCopyingEmail => 'Fehler beim Kopieren der E-Mail';

  @override
  String get automaticLockTimeout => 'Automatische Sperrzeit';

  @override
  String get appWillLockAfter =>
      'Die Anwendung wird automatisch gesperrt nach:';

  @override
  String get biometricAuthentication => 'Biometrische Authentifizierung';

  @override
  String get enableBiometric => 'Fingerabdruck/Face ID aktivieren';

  @override
  String get autoApplyDefault => 'Automatisch anwenden';

  @override
  String get autoApplyEnabled => 'Wird beim Betreten neuer Räume angewendet';

  @override
  String get autoApplyDisabled => 'Nur manuell in jedem Raum anwenden';

  @override
  String get currentConfiguration => 'Aktuelle Konfiguration';

  @override
  String get sessionActive => 'aktive Sitzung';

  @override
  String get sessionsActive => 'aktive Sitzungen';

  @override
  String get noActiveSessionsMessage => 'Keine aktiven Sitzungen registriert';

  @override
  String get helpAndSupport =>
      'Holen Sie sich Hilfe, kontaktieren Sie uns oder lesen Sie unsere Richtlinien';

  @override
  String get autoDestructionDefaultEnabled => '🔥 Standard-Selbstzerstörung: ';

  @override
  String get verificationDemonstration => 'Verifizierungsdemonstration';

  @override
  String get roomLabel => 'Raum:';

  @override
  String get userLabel => 'Benutzer:';

  @override
  String get statusVerified => 'Status: Verifiziert ✅';

  @override
  String get identityVerifiedCorrect =>
      'Die Identität wurde korrekt verifiziert';

  @override
  String get identityVerifiedFull => '✅ Identität Verifiziert';

  @override
  String get bothUsersVerified =>
      'Beide Benutzer haben ihre Identität verifiziert';

  @override
  String get yourVerificationCodes => 'IHRE VERIFIZIERUNGSCODES';

  @override
  String get shareCodeMessage =>
      'Teilen Sie EINEN dieser Codes über einen anderen Kanal (WhatsApp, Telegram usw.)';

  @override
  String get hideCodesBut => '🙈 Codes ausblenden';

  @override
  String get alphanumericCode => '🔤 Alphanumerisch';

  @override
  String get numericCode => '🔢 Numerisch';

  @override
  String get emojiCode => '😀 Emoji';

  @override
  String get enterCodeToVerify =>
      '❌ Geben Sie einen Code zur Verifizierung ein';

  @override
  String get invalidCodeFormat => '❌ Ungültiges Codeformat';

  @override
  String get identityVerifiedSuccess => '✅ Identität erfolgreich verifiziert!';

  @override
  String get incorrectCode => '❌ Falscher Code';

  @override
  String get codesRegenerated => '🔄 Codes neu generiert';

  @override
  String get codeCopied => '📋 Code in die Zwischenablage kopiert';

  @override
  String get partnerCodesReceived => '📥 Partnercodes empfangen';

  @override
  String get codesSentToPartner => '📤 Codes an Partner gesendet';

  @override
  String get resendingCodes => '🔄 Codes erneut an Partner senden...';

  @override
  String get stepExpandVerification =>
      'Tippen Sie auf \"🔐 Identitätsverifizierung\", um zu erweitern';

  @override
  String get stepShowCodes =>
      'Tippen Sie auf \"👁️ Meine Codes anzeigen\", um Ihre einzigartigen Codes zu sehen';

  @override
  String get stepPasteCode =>
      'Fügen Sie den Code in \"PARTNERCODE VERIFIZIEREN\" ein';

  @override
  String get stepVerifyCode =>
      'Tippen Sie auf \"✅ Verifizieren\", um die Verifizierung zu simulieren';

  @override
  String get enterPartnerCode =>
      'Geben Sie den Code ein, den die andere Person mit Ihnen geteilt hat:';

  @override
  String get partnerCodesReceivedWithCode => '✅ Partnercodes empfangen:';

  @override
  String get waitingPartnerCodes => '⏳ Warte auf Partnercodes...';

  @override
  String get verificationSuccessMessage =>
      'Identität erfolgreich verifiziert! Beide Benutzer sind authentisch.';

  @override
  String get chatInvitationsTitle => 'Chat-Einladungen';

  @override
  String get cleanExpiredInvitations => 'Abgelaufene Einladungen bereinigen';

  @override
  String get refreshInvitations => 'Einladungen aktualisieren';

  @override
  String errorInitializing(String error) {
    return 'Initialisierungsfehler: $error';
  }

  @override
  String expiredInvitationsDeleted(int count) {
    return '$count abgelaufene Einladungen endgültig gelöscht';
  }

  @override
  String get noExpiredInvitationsToClean =>
      'Keine abgelaufenen Einladungen zum Bereinigen';

  @override
  String errorAcceptingInvitation(String error) {
    return 'Fehler beim Annehmen der Einladung: $error';
  }

  @override
  String errorUpdatingInvitations(String error) {
    return 'Fehler beim Aktualisieren der Einladungen: $error';
  }

  @override
  String invitationsUpdated(int active, int expired) {
    return 'Aktualisiert: $active aktiv, $expired abgelaufene gelöscht';
  }

  @override
  String invitationsUpdatedActive(int active) {
    return 'Aktualisiert: $active aktive Einladungen';
  }

  @override
  String get noInvitations => 'Keine Einladungen';

  @override
  String get invitationsWillAppearHere =>
      'Chat-Einladungen werden hier angezeigt';

  @override
  String get chatInvitation => 'Chat-Einladung';

  @override
  String fromUser(String userId) {
    return 'Von: $userId';
  }

  @override
  String get expired => 'Abgelaufen';

  @override
  String get reject => 'Ablehnen';

  @override
  String get accept => 'Akzeptieren';

  @override
  String get tapToCreateOrJoinEphemeralChats =>
      'Tippen, um temporäre Chats zu erstellen oder beizutreten';

  @override
  String get now => 'Jetzt';

  @override
  String get callEnded => 'Anruf beendet';

  @override
  String get videoCallFeatureAvailable => '🎥 Videoanruffunktion verfügbar';

  @override
  String get pendingInvitations => 'Ausstehende Einladungen';

  @override
  String chatInvitationsCount(int count) {
    return '$count Chat-Einladung(en)';
  }

  @override
  String get searching => 'Suchen...';

  @override
  String get noUsersFound => 'Keine Benutzer gefunden';

  @override
  String get errorSearchingUsers => 'Fehler bei der Benutzersuche';

  @override
  String get startVideoCall => 'Videoanruf starten';

  @override
  String get startAudioCall => 'Anruf starten';

  @override
  String confirmVideoCall(String nickname) {
    return 'Möchten Sie einen Videoanruf mit $nickname starten?';
  }

  @override
  String confirmAudioCall(String nickname) {
    return 'Möchten Sie einen Anruf mit $nickname starten?';
  }

  @override
  String get initiatingVideoCall => 'Videoanruf wird gestartet...';

  @override
  String get initiatingAudioCall => 'Anruf wird gestartet...';

  @override
  String get sendingInvitation => 'Einladung wird gesendet...';

  @override
  String get errorInitiatingCall => 'Fehler beim Starten des Anrufs';

  @override
  String get waitingForResponse => 'Warte auf Antwort...';

  @override
  String get invitationSentTo => 'Einladung gesendet an';

  @override
  String get waitingForAcceptance =>
      'Warte, bis die Einladung angenommen wird...';

  @override
  String get ephemeralChatTooltip => 'Temporärer Chat';

  @override
  String get audioCallTooltip => 'Anruf';

  @override
  String get videoCallTooltip => 'Video';

  @override
  String get searchUser => 'Benutzer suchen';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get searchingUsers => 'Benutzer werden gesucht...';

  @override
  String noUsersFoundWith(String query) {
    return 'Keine Benutzer gefunden\\nmit \"$query\"';
  }

  @override
  String errorSearchingUsersDetails(String error) {
    return 'Fehler bei der Benutzersuche: $error';
  }

  @override
  String multipleChatsTitle(int count) {
    return 'Mehrere Chats ($count/10)';
  }

  @override
  String get backToHome => 'Zurück zur Startseite';

  @override
  String get closeAllRooms => 'Alle Räume schließen';

  @override
  String get closeAllRoomsConfirm =>
      'Sind Sie sicher, dass Sie alle Chaträume schließen möchten?';

  @override
  String get closeAll => 'Alle schließen';

  @override
  String participants(int count) {
    return '$count Teilnehmer';
  }

  @override
  String roomActive(int count) {
    return 'Raum aktiv ($count Teilnehmer)';
  }

  @override
  String get noConnection => 'Keine Verbindung';

  @override
  String get createNewRoom => 'Neuen Raum erstellen';

  @override
  String get addChat => 'Chat hinzufügen';

  @override
  String get statistics => 'Statistiken';

  @override
  String get chatStatisticsTitle => 'Chat-Statistiken';

  @override
  String get activeRooms => 'Aktive Räume';

  @override
  String get totalMessages => 'Gesamtnachrichten';

  @override
  String get unreadMessages => 'Ungelesen';

  @override
  String get initiatingChat => 'Chat wird gestartet...';

  @override
  String errorClosingRoom(String error) {
    return 'Fehler beim Schließen des Raums: $error';
  }

  @override
  String get invitationAccepted => '✅ Einladung angenommen';

  @override
  String errorAcceptingInvitationDetails(String error) {
    return 'Fehler beim Annehmen der Einladung: $error';
  }

  @override
  String errorCreatingRoom(String error) {
    return 'Fehler beim Erstellen des Raums: $error';
  }

  @override
  String get createNewChatRoom => 'Neuen Chatraum erstellen';

  @override
  String get minutes => 'Minuten';

  @override
  String get seconds => 'Sekunden';

  @override
  String get microphonePermissions => '🎵 Mikrofonberechtigungen';

  @override
  String get microphonePermissionsContent =>
      'Um Audio aufzunehmen, müssen Sie die Mikrofonberechtigungen in den App-Einstellungen aktivieren.\n\nGehen Sie zu Einstellungen > Datenschutz > Mikrofon und aktivieren Sie die Berechtigungen für diese Anwendung.';

  @override
  String get openSettings => 'Einstellungen öffnen';

  @override
  String errorInitializingAudio(String error) {
    return 'Fehler beim Initialisieren von Audio: $error';
  }

  @override
  String get imageTooLarge => 'Bild zu groß. Maximal 500KB erlaubt.';

  @override
  String errorSendingImage(String error) {
    return 'Fehler beim Senden des Bildes: $error';
  }

  @override
  String errorSendingAudio(String error) {
    return 'Fehler beim Senden von Audio: $error';
  }

  @override
  String get destroyRoomContent =>
      'Diese Aktion zerstört den Chatraum dauerhaft für beide Benutzer.\n\nEin für beide Teilnehmer sichtbarer 10-Sekunden-Countdown wird gestartet.';

  @override
  String get destroyRoomButton => 'Raum zerstören';

  @override
  String get connectingToSecureChat => 'Verbinde mit sicherem Chat...';

  @override
  String get autoDestructionConfigured1Min =>
      'Selbstzerstörung konfiguriert: 1 Minute';

  @override
  String get autoDestructionConfigured5Min =>
      'Selbstzerstörung konfiguriert: 5 Minuten';

  @override
  String get autoDestructionConfigured1Hour =>
      'Selbstzerstörung konfiguriert: 1 Stunde';

  @override
  String screenshotAlert(String user) {
    return '📸 Achtung! $user hat einen Screenshot gemacht';
  }

  @override
  String screenshotNotification(String user) {
    return '📸 $user hat einen Screenshot gemacht';
  }

  @override
  String get initializingAudioRecorder => 'Audiorecorder wird initialisiert...';

  @override
  String get audioRecorderNotAvailable =>
      'Audiorecorder nicht verfügbar. Überprüfen Sie die Mikrofonberechtigungen.';

  @override
  String errorStartingRecording(String error) {
    return 'Fehler beim Starten der Aufnahme: $error';
  }

  @override
  String get audioPlayerNotAvailable => 'Audioplayer nicht verfügbar';

  @override
  String get audioNotAvailable => 'Audio nicht verfügbar';

  @override
  String errorPlayingAudio(String error) {
    return 'Fehler beim Abspielen von Audio: $error';
  }

  @override
  String get screenshotTestSent => '📸 Screenshot-Test gesendet';

  @override
  String errorSendingTest(String error) {
    return 'Fehler beim Senden des Tests: $error';
  }

  @override
  String get audioTooLong => 'Audio zu lang. Maximal 1MB erlaubt.';

  @override
  String get errorWebAudioRecording =>
      'Fehler: Audio konnte im Web nicht aufgenommen werden';

  @override
  String get errorWebAudioSaving =>
      'Fehler: Audio konnte nicht gespeichert werden';

  @override
  String errorStoppingRecording(String error) {
    return 'Fehler beim Stoppen der Aufnahme: $error';
  }

  @override
  String get sendEncryptedImageTooltip => 'Verschlüsseltes Bild senden';
}
