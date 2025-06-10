// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Serbian (`sr`).
class AppLocalizationsSr extends AppLocalizations {
  AppLocalizationsSr([String locale = 'sr']) : super(locale);

  @override
  String get appTitle => 'FlutterPutter';

  @override
  String get loginTitle => 'Prijavite se da biste nastavili';

  @override
  String get email => 'Email';

  @override
  String get enterEmail => 'Unesite Vaš email';

  @override
  String get password => 'Lozinka';

  @override
  String get enterPassword => 'Unesite Vašu lozinku';

  @override
  String get pleaseEnterEmail => 'Molimo unesite Vaš email';

  @override
  String get enterValidEmail => 'Unesite važeći email';

  @override
  String get pleaseEnterPassword => 'Molimo unesite Vašu lozinku';

  @override
  String get passwordMinLength => 'Lozinka mora imati najmanje 6 karaktera';

  @override
  String get loginButton => 'Prijavi se';

  @override
  String get noAccount => 'Nemate nalog?';

  @override
  String get register => 'Registrujte se';

  @override
  String get oneSessionSecurity =>
      '🔒 Dozvoljena je samo 1 aktivna sesija po korisniku radi veće bezbednosti';

  @override
  String get oneSessionMaxSecurity =>
      'Samo 1 sesija po korisniku (Maksimalna bezbednost)';

  @override
  String get privacyAndSecurity => 'Privatnost i Bezbednost';

  @override
  String get noDataCollection => 'Ne prikupljamo lične podatke';

  @override
  String get anonymousConnections => 'Sve konekcije su anonimne';

  @override
  String get ephemeralChatRooms =>
      'Privremene sobe za ćaskanje koje se automatski uništavaju';

  @override
  String get encryptionInfo =>
      'XSalsa20 enkripcija sa nasumičnim ključevima po sobi';

  @override
  String get chats => 'Ćaskanja';

  @override
  String get secureChat => 'Bezbedno Ćaskanje';

  @override
  String get secureChatDescription =>
      'Dodirnite da kreirate ili se pridružite privremenim ćaskanjima';

  @override
  String get privateVideoCall => 'Privatni Video Poziv';

  @override
  String get videoCallDescription => 'Poziv završen';

  @override
  String get multipleChats => 'Višestruka Ćaskanja';

  @override
  String get newRoom => 'Nova Soba';

  @override
  String get noActiveChats => 'Nema aktivnih ćaskanja';

  @override
  String get useNewRoomButton =>
      'Koristite karticu \'Nova Soba\' da kreirate ćaskanje';

  @override
  String get searchUsers => 'Pretraga Korisnika';

  @override
  String get searchByNickname => 'Pretraži po nadimku';

  @override
  String get calls => 'Pozivi';

  @override
  String get verification => 'Verifikacija';

  @override
  String get verificationDemo => '🔐 Demo Verifikacija';

  @override
  String get verificationDemoDescription =>
      'Ovo je demonstracija sistema anonimne verifikacije identiteta. U stvarnoj implementaciji, ovaj vidžet bi bio integrisan u privremene sobe za ćaskanje.';

  @override
  String get room => 'Soba';

  @override
  String get user => 'Korisnik';

  @override
  String get identityVerification => 'Verifikacija Identiteta';

  @override
  String get verifyIdentityDescription =>
      'Dodirnite da anonimno verifikujete identitet';

  @override
  String get statusNotVerified => 'Status: Neverifikovan';

  @override
  String get notVerifiedYet => 'Identitet još uvek nije verifikovan';

  @override
  String get howToTest => 'Kako Testirati Verifikaciju';

  @override
  String get step1 => 'Dodirnite na';

  @override
  String get step2 => 'Dodirnite';

  @override
  String get step3 =>
      'Kopirajte jedan od kodova (alfanumerički, numerički ili emoji)';

  @override
  String get step4 => 'Nalepite kod u';

  @override
  String get step5 => 'Dodirnite';

  @override
  String get showMyCodes => 'Prikaži Moje Kodove';

  @override
  String get verifyPartnerCode => 'VERIFIKUJ KOD PARTNERA';

  @override
  String get verify => 'Verifikuj';

  @override
  String get realUsage =>
      'U stvarnoj upotrebi: Korisnici bi delili kodove putem WhatsApp-a, Telegram-a, itd.';

  @override
  String get securitySettings => 'Bezbednosna Podešavanja';

  @override
  String get securitySettingsDescription =>
      'Podesite bezbednosni PIN da zaštitite svoju privatnost. Obaveštenja će i dalje stizati iako je aplikacija zaključana.';

  @override
  String get configureAppLock => 'Podesi zaključavanje aplikacije';

  @override
  String get newPin => 'Novi PIN (4-15 karaktera)';

  @override
  String get confirmPin => 'Potvrdi PIN';

  @override
  String get activateLock => 'Aktiviraj zaključavanje';

  @override
  String get screenshotSecurity => 'Bezbednost snimaka ekrana';

  @override
  String get screenshotSecurityDescription =>
      'Kontrolišite da li se mogu praviti snimci ekrana aplikacije.';

  @override
  String get allowScreenshots => 'Dozvoli snimke ekrana';

  @override
  String get screenshotsAllowed => 'Snimci ekrana su DOZVOLJENI';

  @override
  String get screenshotsDisabled =>
      'Možete ih onemogućiti radi veće bezbednosti';

  @override
  String get autoDestructionDefault => 'Podrazumevano samouništenje';

  @override
  String get autoDestructionDescription =>
      'Podesite vreme samouništenja koje će se automatski primeniti prilikom ulaska u nove sobe za ćaskanje:';

  @override
  String get defaultTime => 'Podrazumevano vreme:';

  @override
  String get noLimit => 'Bez ograničenja';

  @override
  String get selectTime =>
      'Izaberite vreme da omogućite podrazumevano samouništenje. Poruke će se automatski brisati nakon podešenog vremena.';

  @override
  String get activeSessions => 'Aktivne sesije';

  @override
  String get activeSessionsDescription =>
      'Upravljajte uređajima na kojima imate otvorene sesije. Slično kao Signal i WhatsApp.';

  @override
  String get currentState => 'Trenutno stanje';

  @override
  String get noActiveSessionsRegistered => '0 registrovanih aktivnih sesija';

  @override
  String get multipleSessions => 'Višestruke sesije: Onemogućeno';

  @override
  String get configurationLikeSignal => 'i konfiguracija kao Signal';

  @override
  String get manageSessions => 'Upravljaj sesijama';

  @override
  String get allowMultipleSessions => 'Dozvoli višestruke sesije';

  @override
  String get onlyOneActiveSession =>
      'Samo jedna aktivna sesija istovremeno (kao Signal)';

  @override
  String get searchByName => 'Pretraži po imenu...';

  @override
  String get writeAtLeast2Characters =>
      'Napišite najmanje 2 karaktera da biste pretražili korisnike';

  @override
  String get connecting => 'Povezivanje...';

  @override
  String get error => 'Greška';

  @override
  String get secureMultimediaChat => 'Bezbedno Multimedijalno Ćaskanje';

  @override
  String get sendEncryptedMessages =>
      'Šaljite poruke i slike\\nenkriptovane sa XChaCha20-Poly1305';

  @override
  String get encryptedMessage => 'Enkriptovana poruka...';

  @override
  String get sendEncryptedImage => 'Pošalji enkriptovanu sliku';

  @override
  String get takePhoto => 'Slikaj';

  @override
  String get useCamera => 'Koristi kameru';

  @override
  String get gallery => 'Galerija';

  @override
  String get selectImage => 'Izaberi sliku';

  @override
  String get capturesBlocked => 'Snimci ekrana blokirani';

  @override
  String get capturesAllowed => 'Snimci ekrana dozvoljeni';

  @override
  String get e2eEncryptionSecurity => 'E2E Enkripcija + Bezbednost';

  @override
  String get encryptionDescription =>
      'Sve poruke, slike i audio su lokalno enkriptovani sa XChaCha20-Poly1305.\\n\\nServer vidi samo neprozirne enkriptovane blobove.\\n\\nAudio sa implementiranim stvarnim snimanjem.';

  @override
  String get screenshotsStatus => 'Snimci ekrana:';

  @override
  String get screenshotsBlocked => 'BLOKIRANI';

  @override
  String get screenshotsPermitted => 'DOZVOLJENI';

  @override
  String get likeWhatsAppTelegram =>
      'Kao WhatsApp/Telegram - crni ekran na snimcima';

  @override
  String get understood => 'Razumem';

  @override
  String get destroyRoom => 'Uništi Sobu';

  @override
  String get warningDestroyRoom =>
      'Ova akcija će trajno uništiti sobu za ćaskanje za oba korisnika.\\n\\nPokrenuće se brojač od 10 sekundi vidljiv za oba učesnika.';

  @override
  String get cancel => 'Otkaži';

  @override
  String get audioNote => 'Audio poruka';

  @override
  String get recordedAudioNote => 'Audio poruka (snimljena)';

  @override
  String get playing => 'Reprodukcija...';

  @override
  String get tapToStop => 'Dodirnite da zaustavite';

  @override
  String get tapToPlay => 'Dodirnite da reprodukujete';

  @override
  String get image => 'Slika';

  @override
  String get backToMultipleChats => 'Nazad na višestruka ćaskanja';

  @override
  String get backToChat => 'Nazad na ćaskanje';

  @override
  String get screenshotsBlockedAutomatically => 'Snimci ekrana BLOKIRANI';

  @override
  String get screenshotsEnabled => 'Snimci ekrana OMOGUĆENI';

  @override
  String get identityVerifiedCorrectly =>
      'Identitet partnera je uspešno verifikovan';

  @override
  String get createAccount => 'Kreiraj Nalog';

  @override
  String get registerSubtitle =>
      'Registrujte se da biste počeli da koristite FlutterPutter';

  @override
  String get nickname => 'Nadimak';

  @override
  String get chooseUniqueNickname => 'Izaberite jedinstveni nadimak';

  @override
  String get createSecurePassword => 'Kreirajte bezbednu lozinku';

  @override
  String get confirmPassword => 'Potvrdi Lozinku';

  @override
  String get repeatPassword => 'Ponovite Vašu lozinku';

  @override
  String get invitationCode => 'Pozivni Kod';

  @override
  String get enterInvitationCode => 'Unesite Vaš pozivni kod';

  @override
  String get registerButton => 'Registruj se';

  @override
  String get pleaseConfirmPassword => 'Molimo potvrdite Vašu lozinku';

  @override
  String get passwordsDoNotMatch => 'Lozinke se ne podudaraju';

  @override
  String get pleaseEnterNickname => 'Molimo unesite nadimak';

  @override
  String get nicknameMinLength => 'Nadimak mora imati najmanje 3 karaktera';

  @override
  String get pleaseEnterInvitationCode => 'Molimo unesite pozivni kod';

  @override
  String get invitationCodeLength => 'Kod mora imati 8 karaktera';

  @override
  String get newChatInvitationReceived =>
      '📩 Primljena nova pozivnica za ćaskanje';

  @override
  String get view => 'Prikaži';

  @override
  String get chatInvitations => 'Pozivnice za Ćaskanje';

  @override
  String get securitySettingsTooltip => 'Bezbednosna Podešavanja';

  @override
  String helloUser(String nickname) {
    return 'Zdravo, $nickname';
  }

  @override
  String get searchUsersToVideoCall =>
      'Pretražite korisnike da biste započeli video poziv';

  @override
  String get searchUsersButton => 'Pretraži Korisnike';

  @override
  String get testIdentityVerification => 'Testiraj verifikaciju identiteta';

  @override
  String get ephemeralChat => '💬 Privremeno Ćaskanje';

  @override
  String get multipleSimultaneousRooms =>
      'Višestruke simultane sobe (maks. 10)';

  @override
  String get logout => 'Odjavi se';

  @override
  String get logoutConfirmTitle => 'Odjavi se';

  @override
  String get logoutConfirmMessage =>
      'Da li ste sigurni da želite da se odjavite?';

  @override
  String get helpSection => 'Pomoć i Podrška';

  @override
  String get supportCenter => 'Centar za podršku';

  @override
  String get supportCenterDescription =>
      'Potražite pomoć i pogledajte česta pitanja';

  @override
  String get contactUs => 'Kontaktirajte nas';

  @override
  String get contactUsDescription =>
      'Pošaljite nam email da rešite Vaše nedoumice';

  @override
  String get contactEmail => 'FlutterPutter@Proton.me';

  @override
  String get appVersion => 'Verzija';

  @override
  String get versionNumber => 'Verzija 1.0 Beta';

  @override
  String get termsAndConditions => 'Uslovi korišćenja';

  @override
  String get termsDescription => 'Pročitajte naše uslove korišćenja usluge';

  @override
  String get privacyPolicy => 'Politika privatnosti';

  @override
  String get privacyPolicyDescription =>
      'Pogledajte kako štitimo Vaše informacije';

  @override
  String get emailCopied => 'Email kopiran u klipbord';

  @override
  String get openingWebPage => 'Otvaranje veb stranice...';

  @override
  String get errorOpeningWebPage => 'Greška pri otvaranju veb stranice';

  @override
  String get pinLengthError => 'PIN mora imati između 4 i 15 karaktera';

  @override
  String get pinMismatch => 'PIN-ovi se ne podudaraju';

  @override
  String get appLockSetupSuccess =>
      '🔒 Zaključavanje aplikacije uspešno podešeno';

  @override
  String get pinSetupError => 'Greška pri podešavanju PIN-a';

  @override
  String get pinChangeSuccess => '🔒 PIN uspešno promenjen';

  @override
  String get currentPinIncorrect => 'Trenutni PIN je netačan';

  @override
  String get disableAppLockTitle => 'Onemogući zaključavanje';

  @override
  String get disableAppLockMessage =>
      'Da li ste sigurni da želite da onemogućite zaključavanje aplikacije?';

  @override
  String get appLockDisabled => '🔓 Zaključavanje aplikacije onemogućeno';

  @override
  String get confirm => 'Potvrdi';

  @override
  String get changePin => 'Promeni PIN:';

  @override
  String get currentPin => 'Trenutni PIN';

  @override
  String get confirmNewPin => 'Potvrdi novi PIN';

  @override
  String get changePinButton => 'Promeni PIN';

  @override
  String get biometricUnlock =>
      'Otključajte aplikaciju biometrijom pored PIN-a';

  @override
  String get screenshotsAllowedMessage => '🔓 Snimci ekrana DOZVOLJENI';

  @override
  String get screenshotsBlockedMessage => '🔒 Snimci ekrana BLOKIRANI';

  @override
  String get screenshotConfigError =>
      'Greška pri ažuriranju konfiguracije snimaka ekrana';

  @override
  String get protectionActive => 'Aktivna zaštita';

  @override
  String get nativeProtectionFeatures =>
      '• Nativno zaključavanje na iOS-u i Android-u\n• Upozorenje pri detekciji pokušaja snimanja\n• Zaštita u prebacivaču aplikacija';

  @override
  String get autoDestructionDefaultDisabled =>
      '🔥 Podrazumevano samouništenje onemogućeno';

  @override
  String get autoDestructionError =>
      'Greška pri ažuriranju konfiguracije samouništenja';

  @override
  String get protectYourApp => 'Zaštitite svoju aplikaciju';

  @override
  String get securityPinDescription =>
      'Podesite bezbednosni PIN da zaštitite svoju privatnost. Obaveštenja će i dalje stizati iako je aplikacija zaključana.';

  @override
  String get lockActivated => 'Zaključavanje aktivirano';

  @override
  String get disable => 'Onemogući';

  @override
  String get errorCopyingEmail => 'Greška pri kopiranju emaila';

  @override
  String get automaticLockTimeout => 'Vreme automatskog zaključavanja';

  @override
  String get appWillLockAfter =>
      'Aplikacija će se automatski zaključati nakon:';

  @override
  String get biometricAuthentication => 'Biometrijska autentifikacija';

  @override
  String get enableBiometric => 'Omogući otisak prsta/Face ID';

  @override
  String get autoApplyDefault => 'Automatski primeni';

  @override
  String get autoApplyEnabled => 'Primenjivaće se prilikom ulaska u nove sobe';

  @override
  String get autoApplyDisabled => 'Primenjuj samo ručno u svakoj sobi';

  @override
  String get currentConfiguration => 'Trenutna konfiguracija';

  @override
  String get sessionActive => 'aktivna sesija';

  @override
  String get sessionsActive => 'aktivne sesije';

  @override
  String get noActiveSessionsMessage => 'Nema registrovanih aktivnih sesija';

  @override
  String get helpAndSupport =>
      'Potražite pomoć, kontaktirajte nas ili pogledajte naše politike';

  @override
  String get autoDestructionDefaultEnabled =>
      '🔥 Podrazumevano samouništenje: ';

  @override
  String get verificationDemonstration => 'Demonstracija Verifikacije';

  @override
  String get roomLabel => 'Soba:';

  @override
  String get userLabel => 'Korisnik:';

  @override
  String get statusVerified => 'Status: Verifikovan ✅';

  @override
  String get identityVerifiedCorrect => 'Identitet je uspešno verifikovan';

  @override
  String get identityVerifiedFull => '✅ Identitet Verifikovan';

  @override
  String get bothUsersVerified =>
      'Oba korisnika su verifikovala svoj identitet';

  @override
  String get yourVerificationCodes => 'VAŠI VERIFIKACIONI KODOVI';

  @override
  String get shareCodeMessage =>
      'Podelite JEDAN od ovih kodova putem drugog kanala (WhatsApp, Telegram, itd.)';

  @override
  String get hideCodesBut => '🙈 Sakrij Kodove';

  @override
  String get alphanumericCode => '🔤 Alfanumerički';

  @override
  String get numericCode => '🔢 Numerički';

  @override
  String get emojiCode => '😀 Emoji';

  @override
  String get enterCodeToVerify => '❌ Unesite kod za verifikaciju';

  @override
  String get invalidCodeFormat => '❌ Nevažeći format koda';

  @override
  String get identityVerifiedSuccess => '✅ Identitet uspešno verifikovan!';

  @override
  String get incorrectCode => '❌ Netačan kod';

  @override
  String get codesRegenerated => '🔄 Kodovi regenerisani';

  @override
  String get codeCopied => '📋 Kod kopiran u klipbord';

  @override
  String get partnerCodesReceived => '📥 Kodovi partnera primljeni';

  @override
  String get codesSentToPartner => '📤 Kodovi poslati partneru';

  @override
  String get resendingCodes => '🔄 Ponovno slanje kodova partneru...';

  @override
  String get stepExpandVerification =>
      'Dodirnite na \"🔐 Verifikacija Identiteta\" da proširite';

  @override
  String get stepShowCodes =>
      'Dodirnite \"👁️ Prikaži Moje Kodove\" da vidite svoje jedinstvene kodove';

  @override
  String get stepPasteCode => 'Nalepite kod u \"VERIFIKUJ KOD PARTNERA\"';

  @override
  String get stepVerifyCode =>
      'Dodirnite \"✅ Verifikuj\" da simulirate verifikaciju';

  @override
  String get enterPartnerCode =>
      'Unesite kod koji Vam je podelila druga osoba:';

  @override
  String get partnerCodesReceivedWithCode => '✅ Kodovi partnera primljeni:';

  @override
  String get waitingPartnerCodes => '⏳ Čekanje kodova partnera...';

  @override
  String get verificationSuccessMessage =>
      'Identitet uspešno verifikovan! Oba korisnika su autentična.';

  @override
  String get chatInvitationsTitle => 'Pozivnice za Ćaskanje';

  @override
  String get cleanExpiredInvitations => 'Očisti istekle pozivnice';

  @override
  String get refreshInvitations => 'Osveži pozivnice';

  @override
  String errorInitializing(String error) {
    return 'Greška pri inicijalizaciji: $error';
  }

  @override
  String expiredInvitationsDeleted(int count) {
    return '$count isteklih pozivnica je trajno obrisano';
  }

  @override
  String get noExpiredInvitationsToClean =>
      'Nema isteklih pozivnica za čišćenje';

  @override
  String errorAcceptingInvitation(String error) {
    return 'Greška pri prihvatanju pozivnice: $error';
  }

  @override
  String errorUpdatingInvitations(String error) {
    return 'Greška pri ažuriranju pozivnica: $error';
  }

  @override
  String invitationsUpdated(int active, int expired) {
    return 'Ažurirano: $active aktivnih, $expired isteklih obrisano';
  }

  @override
  String invitationsUpdatedActive(int active) {
    return 'Ažurirano: $active aktivnih pozivnica';
  }

  @override
  String get noInvitations => 'Nema pozivnica';

  @override
  String get invitationsWillAppearHere =>
      'Pozivnice za ćaskanje će se pojaviti ovde';

  @override
  String get chatInvitation => 'Pozivnica za ćaskanje';

  @override
  String fromUser(String userId) {
    return 'Od: $userId';
  }

  @override
  String get expired => 'Istekla';

  @override
  String get reject => 'Odbij';

  @override
  String get accept => 'Prihvati';

  @override
  String get tapToCreateOrJoinEphemeralChats =>
      'Dodirnite da kreirate ili se pridružite privremenim ćaskanjima';

  @override
  String get now => 'Sada';

  @override
  String get callEnded => 'Poziv završen';

  @override
  String get videoCallFeatureAvailable => '🎥 Funkcija video poziva dostupna';

  @override
  String get pendingInvitations => 'Pozivnice na čekanju';

  @override
  String chatInvitationsCount(int count) {
    return '$count pozivnica za ćaskanje';
  }

  @override
  String get searching => 'Pretraživanje...';

  @override
  String get noUsersFound => 'Nisu pronađeni korisnici';

  @override
  String get errorSearchingUsers => 'Greška pri pretrazi korisnika';

  @override
  String get startVideoCall => 'Započni video poziv';

  @override
  String get startAudioCall => 'Započni poziv';

  @override
  String confirmVideoCall(String nickname) {
    return 'Želite li započeti video poziv sa $nickname?';
  }

  @override
  String confirmAudioCall(String nickname) {
    return 'Želite li započeti poziv sa $nickname?';
  }

  @override
  String get initiatingVideoCall => 'Započinjanje video poziva...';

  @override
  String get initiatingAudioCall => 'Započinjanje poziva...';

  @override
  String get sendingInvitation => 'Slanje pozivnice...';

  @override
  String get errorInitiatingCall => 'Greška pri započinjanju poziva';

  @override
  String get waitingForResponse => 'Čekanje odgovora...';

  @override
  String get invitationSentTo => 'Pozivnica poslata korisniku';

  @override
  String get waitingForAcceptance => 'Čeka se da prihvati pozivnicu...';

  @override
  String get ephemeralChatTooltip => 'Privremeno Ćaskanje';

  @override
  String get audioCallTooltip => 'Poziv';

  @override
  String get videoCallTooltip => 'Video';

  @override
  String get searchUser => 'Pretraži Korisnika';

  @override
  String get retry => 'Pokušaj ponovo';

  @override
  String get searchingUsers => 'Pretraživanje korisnika...';

  @override
  String noUsersFoundWith(String query) {
    return 'Nisu pronađeni korisnici\\nsa \"$query\"';
  }

  @override
  String errorSearchingUsersDetails(String error) {
    return 'Greška pri pretrazi korisnika: $error';
  }

  @override
  String multipleChatsTitle(int count) {
    return 'Višestruka Ćaskanja ($count/10)';
  }

  @override
  String get backToHome => 'Nazad na Početnu';

  @override
  String get closeAllRooms => 'Zatvori Sve Sobe';

  @override
  String get closeAllRoomsConfirm =>
      'Da li ste sigurni da želite da zatvorite sve sobe za ćaskanje?';

  @override
  String get closeAll => 'Zatvori Sve';

  @override
  String participants(int count) {
    return '$count učesnika';
  }

  @override
  String roomActive(int count) {
    return 'Soba aktivna ($count učesnika)';
  }

  @override
  String get noConnection => 'Nema konekcije';

  @override
  String get createNewRoom => 'Kreiraj Novu Sobu';

  @override
  String get addChat => 'Dodaj Ćaskanje';

  @override
  String get statistics => 'Statistika';

  @override
  String get chatStatisticsTitle => 'Statistika Ćaskanja';

  @override
  String get activeRooms => 'Aktivne sobe';

  @override
  String get totalMessages => 'Ukupno poruka';

  @override
  String get unreadMessages => 'Nepročitane';

  @override
  String get initiatingChat => 'Započinjanje ćaskanja...';

  @override
  String errorClosingRoom(String error) {
    return 'Greška pri zatvaranju sobe: $error';
  }

  @override
  String get invitationAccepted => '✅ Pozivnica prihvaćena';

  @override
  String errorAcceptingInvitationDetails(String error) {
    return 'Greška pri prihvatanju pozivnice: $error';
  }

  @override
  String errorCreatingRoom(String error) {
    return 'Greška pri kreiranju sobe: $error';
  }

  @override
  String get createNewChatRoom => 'Kreiraj novu sobu za ćaskanje';

  @override
  String get minutes => 'minuta';

  @override
  String get seconds => 'sekundi';

  @override
  String get microphonePermissions => '🎵 Dozvole za Mikrofon';

  @override
  String get microphonePermissionsContent =>
      'Da biste snimali audio, morate aktivirati dozvole za mikrofon u podešavanjima aplikacije.\n\nIdite na Podešavanja > Privatnost > Mikrofon i aktivirajte dozvole za ovu aplikaciju.';

  @override
  String get openSettings => 'Otvori Podešavanja';

  @override
  String errorInitializingAudio(String error) {
    return 'Greška pri inicijalizaciji audia: $error';
  }

  @override
  String get imageTooLarge =>
      'Slika je prevelika. Maksimalno dozvoljeno 500KB.';

  @override
  String errorSendingImage(String error) {
    return 'Greška pri slanju slike: $error';
  }

  @override
  String errorSendingAudio(String error) {
    return 'Greška pri slanju audia: $error';
  }

  @override
  String get destroyRoomContent =>
      'Ova akcija će trajno uništiti sobu za ćaskanje za oba korisnika.\n\nPokrenuće se brojač od 10 sekundi vidljiv za oba učesnika.';

  @override
  String get destroyRoomButton => 'Uništi Sobu';

  @override
  String get connectingToSecureChat => 'Povezivanje na bezbedno ćaskanje...';

  @override
  String get autoDestructionConfigured1Min => 'Samouništenje podešeno: 1 minut';

  @override
  String get autoDestructionConfigured5Min =>
      'Samouništenje podešeno: 5 minuta';

  @override
  String get autoDestructionConfigured1Hour => 'Samouništenje podešeno: 1 sat';

  @override
  String screenshotAlert(String user) {
    return '📸 Upozorenje! $user je napravio snimak ekrana';
  }

  @override
  String screenshotNotification(String user) {
    return '📸 $user je napravio snimak ekrana';
  }

  @override
  String get initializingAudioRecorder => 'Inicijalizacija snimača zvuka...';

  @override
  String get audioRecorderNotAvailable =>
      'Snimač zvuka nije dostupan. Proverite dozvole za mikrofon.';

  @override
  String errorStartingRecording(String error) {
    return 'Greška pri pokretanju snimanja: $error';
  }

  @override
  String get audioPlayerNotAvailable => 'Audio plejer nije dostupan';

  @override
  String get audioNotAvailable => 'Audio nije dostupan';

  @override
  String errorPlayingAudio(String error) {
    return 'Greška pri reprodukciji audia: $error';
  }

  @override
  String get screenshotTestSent => '📸 Test snimka ekrana poslat';

  @override
  String errorSendingTest(String error) {
    return 'Greška pri slanju testa: $error';
  }

  @override
  String get audioTooLong => 'Audio je predugačak. Maksimalno dozvoljeno 1MB.';

  @override
  String get errorWebAudioRecording =>
      'Greška: Nije moguće snimiti audio na vebu';

  @override
  String get errorWebAudioSaving => 'Greška: Nije moguće sačuvati audio';

  @override
  String errorStoppingRecording(String error) {
    return 'Greška pri zaustavljanju snimanja: $error';
  }

  @override
  String get sendEncryptedImageTooltip => 'Pošalji enkriptovanu sliku';

  @override
  String get myProfile => 'Moj Profil';

  @override
  String get dangerZone => 'Opasna Zona';

  @override
  String get dangerZoneDescription =>
      'Ova akcija će trajno obrisati vaš nalog i sve vaše podatke. Nećete moći da vratite vaš nalog kada se obriše.';

  @override
  String get destroyMyAccount => 'Uništi moj nalog';

  @override
  String get warningTitle => 'Upozorenje!';

  @override
  String get destroyAccountWarning =>
      'Na putu ste da trajno uništite vaš nalog.';

  @override
  String get thisActionWill => 'Ova akcija će:';

  @override
  String get deleteAllData => '• Obrisati sve vaše podatke';

  @override
  String get closeAllSessions => '• Zatvoriti sve vaše aktivne sesije';

  @override
  String get deleteChatHistory => '• Obrisati vašu istoriju ćaskanja';

  @override
  String get cannotBeUndone => '• Ne može se poništiti';

  @override
  String get neverAccessAgain =>
      'Jednom uništen, nikad više nećete moći da pristupite ovom nalogu.';

  @override
  String get continueButton => 'Nastavi';

  @override
  String get finalConfirmation => 'Finalna Potvrda';

  @override
  String get confirmDestructionText =>
      'Da potvrdite uništavanje vašeg naloga, ukucajte:';

  @override
  String get typeConfirmation => 'Ukucajte potvrdu';

  @override
  String get destroyAccount => 'Uništi Nalog';

  @override
  String get functionalityInDevelopment => 'Funkcionalnost u razvoju';

  @override
  String get accountDestructionAvailable =>
      'Uništavanje naloga će biti dostupno u sledećem ažuriranju. Vaš zahtev je registrovan.';
}
