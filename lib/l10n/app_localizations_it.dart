// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'FlutterPutter';

  @override
  String get loginTitle => 'Accedi per continuare';

  @override
  String get email => 'Email';

  @override
  String get enterEmail => 'Inserisci la tua email';

  @override
  String get password => 'Password';

  @override
  String get enterPassword => 'Inserisci la tua password';

  @override
  String get pleaseEnterEmail => 'Per favore, inserisci la tua email';

  @override
  String get enterValidEmail => 'Inserisci un\'email valida';

  @override
  String get pleaseEnterPassword => 'Per favore, inserisci la tua password';

  @override
  String get passwordMinLength =>
      'La password deve contenere almeno 6 caratteri';

  @override
  String get loginButton => 'Accedi';

  @override
  String get noAccount => 'Non hai un account?';

  @override
  String get register => 'Registrati';

  @override
  String get oneSessionSecurity =>
      '🔒 È consentita solo 1 sessione attiva per utente per maggiore sicurezza';

  @override
  String get oneSessionMaxSecurity =>
      'Solo 1 sessione per utente (Massima sicurezza)';

  @override
  String get privacyAndSecurity => 'Privacy e Sicurezza';

  @override
  String get noDataCollection => 'Non raccogliamo dati personali';

  @override
  String get anonymousConnections => 'Tutte le connessioni sono anonime';

  @override
  String get ephemeralChatRooms =>
      'Stanze chat effimere che si distruggono automaticamente';

  @override
  String get encryptionInfo =>
      'Crittografia XSalsa20 con chiavi casuali per stanza';

  @override
  String get chats => 'Chat';

  @override
  String get secureChat => 'Chat Sicura';

  @override
  String get secureChatDescription =>
      'Tocca per creare o unirti a chat effimere';

  @override
  String get privateVideoCall => 'Videochiamata Privata';

  @override
  String get videoCallDescription => 'Chiamata terminata';

  @override
  String get multipleChats => 'Chat Multiple';

  @override
  String get newRoom => 'Nuova Stanza';

  @override
  String get noActiveChats => 'Nessuna chat attiva';

  @override
  String get useNewRoomButton =>
      'Usa la scheda \'Nuova Stanza\' per creare una chat';

  @override
  String get searchUsers => 'Cerca Utenti';

  @override
  String get searchByNickname => 'Cerca per nickname';

  @override
  String get calls => 'Chiamate';

  @override
  String get verification => 'Verifica';

  @override
  String get verificationDemo => '🔐 Demo Verifica';

  @override
  String get verificationDemoDescription =>
      'Questa è una dimostrazione del sistema di verifica dell\'identità anonima. In un\'implementazione reale, questo widget verrebbe integrato nelle stanze di chat effimere.';

  @override
  String get room => 'Stanza';

  @override
  String get user => 'Utente';

  @override
  String get identityVerification => 'Verifica Identità';

  @override
  String get verifyIdentityDescription =>
      'Tocca per verificare l\'identità in modo anonimo';

  @override
  String get statusNotVerified => 'Stato: Non Verificato';

  @override
  String get notVerifiedYet => 'L\'identità non è stata ancora verificata';

  @override
  String get howToTest => 'Come Testare la Verifica';

  @override
  String get step1 => 'Tocca su';

  @override
  String get step2 => 'Tocca';

  @override
  String get step3 => 'Copia uno dei codici (alfanumerico, numerico o emoji)';

  @override
  String get step4 => 'Incolla il codice in';

  @override
  String get step5 => 'Tocca';

  @override
  String get showMyCodes => 'Mostra i Miei Codici';

  @override
  String get verifyPartnerCode => 'VERIFICA CODICE PARTNER';

  @override
  String get verify => 'Verifica';

  @override
  String get realUsage =>
      'Nell\'uso reale: Gli utenti condividerebbero i codici tramite WhatsApp, Telegram, ecc.';

  @override
  String get securitySettings => 'Impostazioni di Sicurezza';

  @override
  String get securitySettingsDescription =>
      'Configura un PIN di sicurezza per proteggere la tua privacy. Le notifiche continueranno ad arrivare anche se l\'app è bloccata.';

  @override
  String get configureAppLock => 'Configura blocco app';

  @override
  String get newPin => 'Nuovo PIN (4-15 caratteri)';

  @override
  String get confirmPin => 'Conferma PIN';

  @override
  String get activateLock => 'Attiva blocco';

  @override
  String get screenshotSecurity => 'Sicurezza screenshot';

  @override
  String get screenshotSecurityDescription =>
      'Controlla se è possibile acquisire screenshot dell\'applicazione.';

  @override
  String get allowScreenshots => 'Consenti screenshot';

  @override
  String get screenshotsAllowed => 'Gli screenshot sono CONSENTITI';

  @override
  String get screenshotsDisabled => 'Puoi disabilitarli per maggiore sicurezza';

  @override
  String get autoDestructionDefault => 'Autodistruzione predefinita';

  @override
  String get autoDestructionDescription =>
      'Configura un tempo di autodistruzione che verrà applicato automaticamente quando ti unisci a nuove stanze chat:';

  @override
  String get defaultTime => 'Tempo predefinito:';

  @override
  String get noLimit => 'Nessun limite';

  @override
  String get selectTime =>
      'Seleziona un tempo per abilitare l\'autodistruzione predefinita. I messaggi verranno eliminati automaticamente dopo il tempo configurato.';

  @override
  String get activeSessions => 'Sessioni attive';

  @override
  String get activeSessionsDescription =>
      'Gestisci i dispositivi in cui hai sessioni aperte. Simile a Signal e WhatsApp.';

  @override
  String get currentState => 'Stato attuale';

  @override
  String get noActiveSessionsRegistered => '0 sessioni attive registrate';

  @override
  String get multipleSessions => 'Sessioni multiple: Disabilitato';

  @override
  String get configurationLikeSignal => 'e configurazione come Signal';

  @override
  String get manageSessions => 'Gestisci sessioni';

  @override
  String get allowMultipleSessions => 'Consenti sessioni multiple';

  @override
  String get onlyOneActiveSession =>
      'Solo una sessione attiva alla volta (come Signal)';

  @override
  String get searchByName => 'Cerca per nome...';

  @override
  String get writeAtLeast2Characters =>
      'Scrivi almeno 2 caratteri per cercare utenti';

  @override
  String get connecting => 'Connessione in corso...';

  @override
  String get error => 'Errore';

  @override
  String get secureMultimediaChat => 'Chat Multimediale Sicura';

  @override
  String get sendEncryptedMessages =>
      'Invia messaggi e immagini\\ncrittografati con XChaCha20-Poly1305';

  @override
  String get encryptedMessage => 'Messaggio crittografato...';

  @override
  String get sendEncryptedImage => '📷 Invia Immagine Crittografata';

  @override
  String get takePhoto => 'Scatta Foto';

  @override
  String get useCamera => 'Usa fotocamera';

  @override
  String get gallery => 'Galleria';

  @override
  String get selectImage => 'Seleziona immagine';

  @override
  String get capturesBlocked => 'Catture bloccate';

  @override
  String get capturesAllowed => 'Catture consentite';

  @override
  String get e2eEncryptionSecurity => 'Crittografia E2E + Sicurezza';

  @override
  String get encryptionDescription =>
      'Tutti i messaggi, immagini e audio sono crittografati localmente con XChaCha20-Poly1305.\\n\\nIl server vede solo blob crittografati opachi.\\n\\nAudio con registrazione reale implementata.';

  @override
  String get screenshotsStatus => 'Screenshot:';

  @override
  String get screenshotsBlocked => 'BLOCCATI';

  @override
  String get screenshotsPermitted => 'CONSENTITI';

  @override
  String get likeWhatsAppTelegram =>
      'Come WhatsApp/Telegram - schermo nero negli screenshot';

  @override
  String get understood => 'Capito';

  @override
  String get destroyRoom => '⚠️ Distruggi Stanza';

  @override
  String get warningDestroyRoom =>
      'Questa azione distruggerà permanentemente la stanza chat per entrambi gli utenti.\\n\\nVerrà avviato un contatore di 10 secondi visibile a entrambi i partecipanti.';

  @override
  String get cancel => 'Annulla';

  @override
  String get audioNote => 'Nota audio';

  @override
  String get recordedAudioNote => 'Nota audio (registrata)';

  @override
  String get playing => 'In riproduzione...';

  @override
  String get tapToStop => 'Tocca per fermare';

  @override
  String get tapToPlay => 'Tocca per riprodurre';

  @override
  String get image => 'Immagine';

  @override
  String get backToMultipleChats => 'Torna alle chat multiple';

  @override
  String get backToChat => 'Torna alla chat';

  @override
  String get screenshotsBlockedAutomatically =>
      'Screenshot BLOCCATI automaticamente';

  @override
  String get screenshotsEnabled => 'Screenshot ABILITATI';

  @override
  String get identityVerifiedCorrectly =>
      'Identità del partner verificata correttamente';

  @override
  String get createAccount => 'Crea Account';

  @override
  String get registerSubtitle =>
      'Registrati per iniziare a usare FlutterPutter';

  @override
  String get nickname => 'Nickname';

  @override
  String get chooseUniqueNickname => 'Scegli un nickname unico';

  @override
  String get createSecurePassword => 'Crea una password sicura';

  @override
  String get confirmPassword => 'Conferma Password';

  @override
  String get repeatPassword => 'Ripeti la tua password';

  @override
  String get invitationCode => 'Codice d\'Invito';

  @override
  String get enterInvitationCode => 'Inserisci il tuo codice d\'invito';

  @override
  String get registerButton => 'Registrati';

  @override
  String get pleaseConfirmPassword => 'Per favore, conferma la tua password';

  @override
  String get passwordsDoNotMatch => 'Le password non coincidono';

  @override
  String get pleaseEnterNickname => 'Per favore, inserisci un nickname';

  @override
  String get nicknameMinLength =>
      'Il nickname deve contenere almeno 3 caratteri';

  @override
  String get pleaseEnterInvitationCode =>
      'Per favore, inserisci un codice d\'invito';

  @override
  String get invitationCodeLength => 'Il codice deve contenere 8 caratteri';

  @override
  String get newChatInvitationReceived => '📩 Nuovo invito di chat ricevuto';

  @override
  String get view => 'Visualizza';

  @override
  String get chatInvitations => 'Inviti di Chat';

  @override
  String get securitySettingsTooltip => 'Impostazioni di Sicurezza';

  @override
  String helloUser(String nickname) {
    return 'Ciao, $nickname';
  }

  @override
  String get searchUsersToVideoCall =>
      'Cerca utenti per avviare una videochiamata';

  @override
  String get searchUsersButton => 'Cerca Utenti';

  @override
  String get testIdentityVerification => 'Testare verifica identità';

  @override
  String get ephemeralChat => '💬 Chat Effimera';

  @override
  String get multipleSimultaneousRooms =>
      'Stanze simultanee multiple (max. 10)';

  @override
  String get logout => 'Esci';

  @override
  String get logoutConfirmTitle => 'Esci';

  @override
  String get logoutConfirmMessage => 'Sei sicuro di voler uscire?';

  @override
  String get helpSection => 'Aiuto e Supporto';

  @override
  String get supportCenter => 'Centro assistenza';

  @override
  String get supportCenterDescription =>
      'Ottieni aiuto e consulta le domande frequenti';

  @override
  String get contactUs => 'Contattaci';

  @override
  String get contactUsDescription =>
      'Inviaci un\'email per risolvere i tuoi dubbi';

  @override
  String get contactEmail => 'FlutterPutter@Proton.me';

  @override
  String get appVersion => 'Versione';

  @override
  String get versionNumber => 'Versione 1.0 Beta';

  @override
  String get termsAndConditions => 'Termini e condizioni';

  @override
  String get termsDescription => 'Leggi i nostri termini di servizio';

  @override
  String get privacyPolicy => 'Politica sulla privacy';

  @override
  String get privacyPolicyDescription =>
      'Consulta come proteggiamo le tue informazioni';

  @override
  String get emailCopied => 'Email copiata negli appunti';

  @override
  String get openingWebPage => 'Apertura pagina web...';

  @override
  String get errorOpeningWebPage =>
      'Errore durante l\'apertura della pagina web';

  @override
  String get pinLengthError => 'Il PIN deve avere tra 4 e 15 caratteri';

  @override
  String get pinMismatch => 'I PIN non coincidono';

  @override
  String get appLockSetupSuccess =>
      '🔒 Blocco applicazione configurato con successo';

  @override
  String get pinSetupError => 'Errore durante la configurazione del PIN';

  @override
  String get pinChangeSuccess => '🔒 PIN cambiato con successo';

  @override
  String get currentPinIncorrect => 'PIN attuale errato';

  @override
  String get disableAppLockTitle => 'Disabilita blocco';

  @override
  String get disableAppLockMessage =>
      'Sei sicuro di voler disabilitare il blocco dell\'applicazione?';

  @override
  String get appLockDisabled => '🔓 Blocco applicazione disabilitato';

  @override
  String get confirm => 'Conferma';

  @override
  String get changePin => 'Cambia PIN:';

  @override
  String get currentPin => 'PIN attuale';

  @override
  String get confirmNewPin => 'Conferma nuovo PIN';

  @override
  String get changePinButton => 'Cambia PIN';

  @override
  String get biometricUnlock => 'Sblocca l\'app con la biometria oltre al PIN';

  @override
  String get screenshotsAllowedMessage => '🔓 Screenshot CONSENTITI';

  @override
  String get screenshotsBlockedMessage => '🔒 Screenshot BLOCCATI';

  @override
  String get screenshotConfigError =>
      'Errore durante l\'aggiornamento della configurazione degli screenshot';

  @override
  String get protectionActive => 'Protezione attiva';

  @override
  String get nativeProtectionFeatures =>
      '• Blocco nativo su iOS e Android\n• Avviso al rilevamento di tentativi di cattura\n• Protezione nell\'app switcher';

  @override
  String get autoDestructionDefaultDisabled =>
      '🔥 Autodistruzione predefinita disabilitata';

  @override
  String get autoDestructionError =>
      'Errore durante l\'aggiornamento della configurazione di autodistruzione';

  @override
  String get protectYourApp => 'Proteggi la tua applicazione';

  @override
  String get securityPinDescription =>
      'Configura un PIN di sicurezza per proteggere la tua privacy. Le notifiche continueranno ad arrivare anche se l\'app è bloccata.';

  @override
  String get lockActivated => 'Blocco attivato';

  @override
  String get disable => 'Disabilita';

  @override
  String get errorCopyingEmail => 'Errore durante la copia dell\'email';

  @override
  String get automaticLockTimeout => 'Tempo di blocco automatico';

  @override
  String get appWillLockAfter =>
      'L\'applicazione si bloccherà automaticamente dopo:';

  @override
  String get biometricAuthentication => 'Autenticazione biometrica';

  @override
  String get enableBiometric => 'Abilita impronta digitale/Face ID';

  @override
  String get autoApplyDefault => 'Applica automaticamente';

  @override
  String get autoApplyEnabled => 'Verrà applicato unendosi a nuove stanze';

  @override
  String get autoApplyDisabled => 'Applicare manualmente solo in ogni stanza';

  @override
  String get currentConfiguration => 'Configurazione attuale';

  @override
  String get sessionActive => 'sessione attiva';

  @override
  String get sessionsActive => 'sessioni attive';

  @override
  String get noActiveSessionsMessage => 'Nessuna sessione attiva registrata';

  @override
  String get helpAndSupport =>
      'Ottieni aiuto, contattaci o consulta le nostre politiche';

  @override
  String get autoDestructionDefaultEnabled =>
      '🔥 Autodistruzione predefinita: ';

  @override
  String get verificationDemonstration => 'Dimostrazione di Verifica';

  @override
  String get roomLabel => 'Stanza:';

  @override
  String get userLabel => 'Utente:';

  @override
  String get statusVerified => 'Stato: Verificato ✅';

  @override
  String get identityVerifiedCorrect =>
      'L\'identità è stata verificata correttamente';

  @override
  String get identityVerifiedFull => '✅ Identità Verificata';

  @override
  String get bothUsersVerified =>
      'Entrambi gli utenti hanno verificato la loro identità';

  @override
  String get yourVerificationCodes => 'I TUOI CODICI DI VERIFICA';

  @override
  String get shareCodeMessage =>
      'Condividi UNO di questi codici tramite un altro canale (WhatsApp, Telegram, ecc.)';

  @override
  String get hideCodesBut => '🙈 Nascondi Codici';

  @override
  String get alphanumericCode => '🔤 Alfanumerico';

  @override
  String get numericCode => '🔢 Numerico';

  @override
  String get emojiCode => '😀 Emoji';

  @override
  String get enterCodeToVerify => '❌ Inserisci un codice per verificare';

  @override
  String get invalidCodeFormat => '❌ Formato codice non valido';

  @override
  String get identityVerifiedSuccess => '✅ Identità verificata correttamente!';

  @override
  String get incorrectCode => '❌ Codice errato';

  @override
  String get codesRegenerated => '🔄 Codici rigenerati';

  @override
  String get codeCopied => '📋 Codice copiato negli appunti';

  @override
  String get partnerCodesReceived => '📥 Codici del partner ricevuti';

  @override
  String get codesSentToPartner => '📤 Codici inviati al partner';

  @override
  String get resendingCodes => '🔄 Reinvio codici al partner...';

  @override
  String get stepExpandVerification =>
      'Tocca su \"🔐 Verifica Identità\" per espandere';

  @override
  String get stepShowCodes =>
      'Tocca \"👁️ Mostra i Miei Codici\" per vedere i tuoi codici unici';

  @override
  String get stepPasteCode =>
      'Incolla il codice in \"VERIFICA CODICE PARTNER\"';

  @override
  String get stepVerifyCode => 'Tocca \"✅ Verifica\" per simulare la verifica';

  @override
  String get enterPartnerCode =>
      'Inserisci il codice che l\'altra persona ha condiviso con te:';

  @override
  String get partnerCodesReceivedWithCode => '✅ Codici del partner ricevuti:';

  @override
  String get waitingPartnerCodes => '⏳ In attesa dei codici del partner...';

  @override
  String get verificationSuccessMessage =>
      'Identità verificata correttamente! Entrambi gli utenti sono autentici.';

  @override
  String get chatInvitationsTitle => 'Inviti di Chat';

  @override
  String get cleanExpiredInvitations => 'Pulisci inviti scaduti';

  @override
  String get refreshInvitations => 'Aggiorna inviti';

  @override
  String errorInitializing(String error) {
    return 'Errore di inizializzazione: $error';
  }

  @override
  String expiredInvitationsDeleted(int count) {
    return '$count inviti scaduti eliminati definitivamente';
  }

  @override
  String get noExpiredInvitationsToClean => 'Nessun invito scaduto da pulire';

  @override
  String errorAcceptingInvitation(String error) {
    return 'Errore durante l\'accettazione dell\'invito: $error';
  }

  @override
  String errorUpdatingInvitations(String error) {
    return 'Errore durante l\'aggiornamento degli inviti: $error';
  }

  @override
  String invitationsUpdated(int active, int expired) {
    return 'Aggiornato: $active attivi, $expired scaduti eliminati';
  }

  @override
  String invitationsUpdatedActive(int active) {
    return 'Aggiornato: $active inviti attivi';
  }

  @override
  String get noInvitations => 'Nessun invito';

  @override
  String get invitationsWillAppearHere => 'Gli inviti di chat appariranno qui';

  @override
  String get chatInvitation => 'Invito di chat';

  @override
  String fromUser(String userId) {
    return 'Da: $userId';
  }

  @override
  String get expired => 'Scaduto';

  @override
  String get reject => 'Rifiuta';

  @override
  String get accept => 'Accetta';

  @override
  String get tapToCreateOrJoinEphemeralChats =>
      'Tocca per creare o unirti a chat effimere';

  @override
  String get now => 'Adesso';

  @override
  String get callEnded => 'Chiamata terminata';

  @override
  String get videoCallFeatureAvailable =>
      '🎥 Funzione videochiamata disponibile';

  @override
  String get pendingInvitations => 'Inviti in sospeso';

  @override
  String chatInvitationsCount(int count) {
    return '$count invito/i di chat';
  }

  @override
  String get searching => 'Ricerca in corso...';

  @override
  String get noUsersFound => 'Nessun utente trovato';

  @override
  String get errorSearchingUsers => 'Errore durante la ricerca di utenti';

  @override
  String get startVideoCall => 'Avvia videochiamata';

  @override
  String get startAudioCall => 'Avvia chiamata audio';

  @override
  String confirmVideoCall(String nickname) {
    return 'Vuoi avviare una videochiamata con $nickname?';
  }

  @override
  String confirmAudioCall(String nickname) {
    return 'Vuoi avviare una chiamata audio con $nickname?';
  }

  @override
  String get initiatingVideoCall => 'Avvio videochiamata...';

  @override
  String get initiatingAudioCall => 'Avvio chiamata audio...';

  @override
  String get sendingInvitation => 'Invio invito...';

  @override
  String get errorInitiatingCall => 'Errore durante l\'avvio della chiamata';

  @override
  String get waitingForResponse => 'In attesa di risposta...';

  @override
  String get invitationSentTo => 'Invito inviato a';

  @override
  String get waitingForAcceptance => 'In attesa che accetti l\'invito...';

  @override
  String get ephemeralChatTooltip => 'Chat Effimera';

  @override
  String get audioCallTooltip => 'Chiamata';

  @override
  String get videoCallTooltip => 'Video';

  @override
  String get searchUser => 'Cerca Utente';

  @override
  String get retry => 'Riprova';

  @override
  String get searchingUsers => 'Ricerca utenti in corso...';

  @override
  String noUsersFoundWith(String query) {
    return 'Nessun utente trovato\\ncon \"$query\"';
  }

  @override
  String errorSearchingUsersDetails(String error) {
    return 'Errore durante la ricerca di utenti: $error';
  }

  @override
  String multipleChatsTitle(int count) {
    return 'Chat Multiple ($count/10)';
  }

  @override
  String get backToHome => 'Torna alla Home';

  @override
  String get closeAllRooms => 'Chiudi Tutte le Stanze';

  @override
  String get closeAllRoomsConfirm =>
      'Sei sicuro di voler chiudere tutte le stanze chat?';

  @override
  String get closeAll => 'Chiudi Tutte';

  @override
  String participants(int count) {
    return '$count partecipanti';
  }

  @override
  String roomActive(int count) {
    return 'Stanza attiva ($count partecipanti)';
  }

  @override
  String get noConnection => 'Nessuna connessione';

  @override
  String get createNewRoom => 'Crea Nuova Stanza';

  @override
  String get addChat => 'Aggiungi Chat';

  @override
  String get statistics => 'Statistiche';

  @override
  String get chatStatisticsTitle => 'Statistiche Chat';

  @override
  String get activeRooms => 'Stanze attive';

  @override
  String get totalMessages => 'Messaggi totali';

  @override
  String get unreadMessages => 'Non letti';

  @override
  String get initiatingChat => 'Avvio chat...';

  @override
  String errorClosingRoom(String error) {
    return 'Errore durante la chiusura della stanza: $error';
  }

  @override
  String get invitationAccepted => '✅ Invito accettato';

  @override
  String errorAcceptingInvitationDetails(String error) {
    return 'Errore durante l\'accettazione dell\'invito: $error';
  }

  @override
  String errorCreatingRoom(String error) {
    return 'Errore durante la creazione della stanza: $error';
  }

  @override
  String get createNewChatRoom => 'Crea nuova stanza chat';

  @override
  String get minutes => 'minuti';

  @override
  String get seconds => 'secondi';

  @override
  String get microphonePermissions => '🎵 Permessi Microfono';

  @override
  String get microphonePermissionsContent =>
      'Per registrare audio devi attivare i permessi del microfono nelle impostazioni dell\'app.\n\nVai su Impostazioni > Privacy > Microfono e attiva i permessi per questa applicazione.';

  @override
  String get openSettings => 'Apri Impostazioni';

  @override
  String errorInitializingAudio(String error) {
    return 'Errore durante l\'inizializzazione dell\'audio: $error';
  }

  @override
  String get imageTooLarge =>
      'Immagine troppo grande. Massimo 500KB consentito.';

  @override
  String errorSendingImage(String error) {
    return 'Errore durante l\'invio dell\'immagine: $error';
  }

  @override
  String errorSendingAudio(String error) {
    return 'Errore durante l\'invio dell\'audio: $error';
  }

  @override
  String get destroyRoomContent =>
      'Questa azione distruggerà permanentemente la stanza chat per entrambi gli utenti.\\n\\nVerrà avviato un contatore di 10 secondi visibile a entrambi i partecipanti.';

  @override
  String get destroyRoomButton => 'Distruggi Stanza';

  @override
  String get connectingToSecureChat => 'Connessione alla chat sicura...';

  @override
  String get autoDestructionConfigured1Min =>
      'Autodistruzione configurata: 1 minuto';

  @override
  String get autoDestructionConfigured5Min =>
      'Autodistruzione configurata: 5 minuti';

  @override
  String get autoDestructionConfigured1Hour =>
      'Autodistruzione configurata: 1 ora';

  @override
  String screenshotAlert(String user) {
    return '📸 Attenzione! $user ha fatto uno screenshot';
  }

  @override
  String screenshotNotification(String user) {
    return '📸 $user ha fatto uno screenshot';
  }

  @override
  String get initializingAudioRecorder =>
      'Inizializzazione registratore audio...';

  @override
  String get audioRecorderNotAvailable =>
      'Registratore audio non disponibile. Verifica i permessi del microfono.';

  @override
  String errorStartingRecording(String error) {
    return 'Errore durante l\'avvio della registrazione: $error';
  }

  @override
  String get audioPlayerNotAvailable => 'Lettore audio non disponibile';

  @override
  String get audioNotAvailable => 'Audio non disponibile';

  @override
  String errorPlayingAudio(String error) {
    return 'Errore durante la riproduzione dell\'audio: $error';
  }

  @override
  String get screenshotTestSent => '📸 Test screenshot inviato';

  @override
  String errorSendingTest(String error) {
    return 'Errore durante l\'invio del test: $error';
  }

  @override
  String get audioTooLong => 'Audio troppo lungo. Massimo 1MB consentito.';

  @override
  String get errorWebAudioRecording =>
      'Errore: Impossibile registrare l\'audio sul web';

  @override
  String get errorWebAudioSaving => 'Errore: Impossibile salvare l\'audio';

  @override
  String errorStoppingRecording(String error) {
    return 'Errore durante l\'interruzione della registrazione: $error';
  }

  @override
  String get sendEncryptedImageTooltip => 'Invia immagine crittografata';
}
