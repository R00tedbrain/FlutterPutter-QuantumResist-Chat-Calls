// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Albanian (`sq`).
class AppLocalizationsSq extends AppLocalizations {
  AppLocalizationsSq([String locale = 'sq']) : super(locale);

  @override
  String get appTitle => 'FlutterPutter';

  @override
  String get loginTitle => 'Hyni për të vazhduar';

  @override
  String get email => 'Email';

  @override
  String get enterEmail => 'Vendosni emailin tuaj';

  @override
  String get password => 'Fjalëkalimi';

  @override
  String get enterPassword => 'Vendosni fjalëkalimin tuaj';

  @override
  String get pleaseEnterEmail => 'Ju lutemi vendosni emailin tuaj';

  @override
  String get enterValidEmail => 'Vendosni një email të vlefshëm';

  @override
  String get pleaseEnterPassword => 'Ju lutemi vendosni fjalëkalimin tuaj';

  @override
  String get passwordMinLength =>
      'Fjalëkalimi duhet të ketë të paktën 6 karaktere';

  @override
  String get loginButton => 'Hyni';

  @override
  String get noAccount => 'Nuk keni një llogari?';

  @override
  String get register => 'Regjistrohu';

  @override
  String get oneSessionSecurity =>
      '🔒 Lejohet vetëm 1 seancë aktive për përdorues për siguri më të madhe';

  @override
  String get oneSessionMaxSecurity =>
      'Vetëm 1 seancë për përdorues (Siguri Maksimale)';

  @override
  String get privacyAndSecurity => 'Privatësia dhe Siguria';

  @override
  String get noDataCollection => 'Ne nuk mbledhim të dhëna personale';

  @override
  String get anonymousConnections => 'Të gjitha lidhjet janë anonime';

  @override
  String get ephemeralChatRooms =>
      'Dhomat e bisedave të përkohshme që shkatërrohen automatikisht';

  @override
  String get encryptionInfo =>
      'Enkriptimi XSalsa20 me çelësa të rastësishëm për dhomë';

  @override
  String get chats => 'Bisedat';

  @override
  String get secureChat => 'Bisedë e Sigurt';

  @override
  String get secureChatDescription =>
      'Prekni për të krijuar ose bashkuar në biseda të përkohshme';

  @override
  String get privateVideoCall => 'Videothirrje Private';

  @override
  String get videoCallDescription => 'Thirrja përfundoi';

  @override
  String get multipleChats => 'Biseda të Shumta';

  @override
  String get newRoom => 'Dhomë e Re';

  @override
  String get noActiveChats => 'Nuk ka biseda aktive';

  @override
  String get useNewRoomButton =>
      'Përdorni skedën \'Dhomë e Re\' për të krijuar një bisedë';

  @override
  String get searchUsers => 'Kërko Përdorues';

  @override
  String get searchByNickname => 'Kërko sipas nofkës';

  @override
  String get calls => 'Thirrjet';

  @override
  String get verification => 'Verifikimi';

  @override
  String get verificationDemo => 'Demo: Verifikimi i Identitetit';

  @override
  String get verificationDemoDescription =>
      'Kjo është një demonstrim i sistemit të verifikimit anonim të identitetit. Në një implementim real, ky widget do të integrohej në dhomat e bisedave të përkohshme.';

  @override
  String get room => 'Dhomë';

  @override
  String get user => 'Përdorues';

  @override
  String get identityVerification => 'Verifikimi i Identitetit';

  @override
  String get verifyIdentityDescription =>
      'Prekni për të verifikuar identitetin në mënyrë anonime';

  @override
  String get statusNotVerified => 'Statusi: I Paverifikuar';

  @override
  String get notVerifiedYet => 'Identiteti ende nuk është verifikuar';

  @override
  String get howToTest => 'Si të Testoni Verifikimin';

  @override
  String get step1 => 'Prekni mbi';

  @override
  String get step2 => 'Prekni';

  @override
  String get step3 => 'Kopjoni një nga kodet (alfanumerik, numerik ose emoji)';

  @override
  String get step4 => 'Ngjisni kodin në';

  @override
  String get step5 => 'Prekni';

  @override
  String get showMyCodes => 'Shfaq Kodet e Mia';

  @override
  String get verifyPartnerCode => 'VERIFIKO KODIN E PARTNERIT';

  @override
  String get verify => 'Verifiko';

  @override
  String get realUsage =>
      'Në përdorim real: Përdoruesit do të ndanin kodet përmes WhatsApp, Telegram, etj.';

  @override
  String get securitySettings => 'Cilësimet e Sigurisë';

  @override
  String get securitySettingsDescription =>
      'Konfiguroni një PIN sigurie për të mbrojtur privatësinë tuaj. Njoftimet do të vazhdojnë të mbërrijnë edhe pse aplikacioni është i bllokuar.';

  @override
  String get configureAppLock => 'Konfiguro bllokimin e aplikacionit';

  @override
  String get newPin => 'PIN i Ri (4-15 karaktere)';

  @override
  String get confirmPin => 'Konfirmo PIN-in';

  @override
  String get activateLock => 'Aktivizo bllokimin';

  @override
  String get screenshotSecurity => 'Siguria e pamjeve të ekranit';

  @override
  String get screenshotSecurityDescription =>
      'Kontrolloni nëse mund të merren pamje të ekranit të aplikacionit.';

  @override
  String get allowScreenshots => 'Lejo pamjet e ekranit';

  @override
  String get screenshotsAllowed => 'Pamjet e ekranit janë të LEJUARA';

  @override
  String get screenshotsDisabled =>
      'Mund t\'i çaktivizoni për siguri më të madhe';

  @override
  String get autoDestructionDefault => 'Vetëshkatërrimi i paracaktuar';

  @override
  String get autoDestructionDescription =>
      'Konfiguroni një kohë vetëshkatërrimi që do të aplikohet automatikisht kur bashkoheni në dhoma të reja bisede:';

  @override
  String get defaultTime => 'Koha e paracaktuar:';

  @override
  String get noLimit => 'Pa limit';

  @override
  String get selectTime =>
      'Zgjidhni një kohë për të aktivizuar vetëshkatërrimin e paracaktuar. Mesazhet do të fshihen automatikisht pas kohës së konfiguruar.';

  @override
  String get activeSessions => 'Seancat aktive';

  @override
  String get activeSessionsDescription =>
      'Menaxhoni pajisjet ku keni seanca të hapura. Ngjashëm me Signal dhe WhatsApp.';

  @override
  String get currentState => 'Gjendja aktuale';

  @override
  String get noActiveSessionsRegistered => '0 seanca aktive të regjistruara';

  @override
  String get multipleSessions => 'Seanca të shumta: Çaktivizuar';

  @override
  String get configurationLikeSignal => 'dhe konfigurim si Signal';

  @override
  String get manageSessions => 'Menaxho seancat';

  @override
  String get allowMultipleSessions => 'Lejo seanca të shumta';

  @override
  String get onlyOneActiveSession =>
      'Vetëm një seancë aktive në të njëjtën kohë (si Signal)';

  @override
  String get searchByName => 'Kërko sipas emrit...';

  @override
  String get writeAtLeast2Characters =>
      'Shkruani të paktën 2 karaktere për të kërkuar përdorues';

  @override
  String get connecting => 'Duke u lidhur...';

  @override
  String get error => 'Gabim';

  @override
  String get secureMultimediaChat => 'Bisedë Multimediale e Sigurt';

  @override
  String get sendEncryptedMessages =>
      'Dërgoni mesazhe dhe imazhe\\ntë enkriptuara me XChaCha20-Poly1305';

  @override
  String get encryptedMessage => 'Mesazh i enkriptuar...';

  @override
  String get sendEncryptedImage => 'Dërgo imazh të enkriptuar';

  @override
  String get takePhoto => 'Bëj Foto';

  @override
  String get useCamera => 'Përdor kamerën';

  @override
  String get gallery => 'Galeria';

  @override
  String get selectImage => 'Zgjidh imazh';

  @override
  String get capturesBlocked => 'Pamjet e ekranit të bllokuara';

  @override
  String get capturesAllowed => 'Pamjet e ekranit të lejuara';

  @override
  String get e2eEncryptionSecurity => 'Enkriptimi E2E + Siguria';

  @override
  String get encryptionDescription =>
      'Të gjitha mesazhet, imazhet dhe audio janë të enkriptuara lokalisht me XChaCha20-Poly1305.\\n\\nServeri sheh vetëm blobe të enkriptuara të errëta.\\n\\nAudio me regjistrim real të implementuar.';

  @override
  String get screenshotsStatus => 'Pamjet e ekranit:';

  @override
  String get screenshotsBlocked => 'TË BLLOKUARA';

  @override
  String get screenshotsPermitted => 'TË LEJUARA';

  @override
  String get likeWhatsAppTelegram =>
      'Si WhatsApp/Telegram - ekran i zi në pamjet e ekranit';

  @override
  String get understood => 'E kuptova';

  @override
  String get destroyRoom => 'Shkatërro Dhomën';

  @override
  String get warningDestroyRoom =>
      'Ky veprim do të shkatërrojë përgjithmonë dhomën e bisedës për të dy përdoruesit.\\n\\nDo të fillojë një numërues prej 10 sekondash i dukshëm për të dy pjesëmarrësit.';

  @override
  String get cancel => 'Anulo';

  @override
  String get audioNote => 'Shënim audio';

  @override
  String get recordedAudioNote => 'Shënim audio (i regjistruar)';

  @override
  String get playing => 'Duke luajtur...';

  @override
  String get tapToStop => 'Prekni për të ndaluar';

  @override
  String get tapToPlay => 'Prekni për të luajtur';

  @override
  String get image => 'Imazh';

  @override
  String get backToMultipleChats => 'Kthehu te bisedat e shumta';

  @override
  String get backToChat => 'Kthehu te biseda';

  @override
  String get screenshotsBlockedAutomatically => 'Pamjet e ekranit TË BLLOKUARA';

  @override
  String get screenshotsEnabled => 'Pamjet e ekranit TË AKTIVIZUARA';

  @override
  String get identityVerifiedCorrectly =>
      'Identiteti i partnerit u verifikua saktë';

  @override
  String get createAccount => 'Krijo Llogari';

  @override
  String get registerSubtitle =>
      'Regjistrohu për të filluar përdorimin e FlutterPutter';

  @override
  String get nickname => 'Nofka';

  @override
  String get chooseUniqueNickname => 'Zgjidhni një nofkë unike';

  @override
  String get createSecurePassword => 'Krijoni një fjalëkalim të sigurt';

  @override
  String get confirmPassword => 'Konfirmo Fjalëkalimin';

  @override
  String get repeatPassword => 'Përsëritni fjalëkalimin tuaj';

  @override
  String get invitationCode => 'Kodi i Ftesës';

  @override
  String get enterInvitationCode => 'Vendosni kodin tuaj të ftesës';

  @override
  String get registerButton => 'Regjistrohu';

  @override
  String get pleaseConfirmPassword => 'Ju lutemi konfirmoni fjalëkalimin tuaj';

  @override
  String get passwordsDoNotMatch => 'Fjalëkalimet nuk përputhen';

  @override
  String get pleaseEnterNickname => 'Ju lutemi vendosni një nofkë';

  @override
  String get nicknameMinLength => 'Nofka duhet të ketë të paktën 3 karaktere';

  @override
  String get pleaseEnterInvitationCode => 'Ju lutemi vendosni një kod ftese';

  @override
  String get invitationCodeLength => 'Kodi duhet të ketë 8 karaktere';

  @override
  String get newChatInvitationReceived => '📩 Ftesë e re bisede e marrë';

  @override
  String get view => 'Shiko';

  @override
  String get chatInvitations => 'Ftesat e Bisedave';

  @override
  String get securitySettingsTooltip => 'Cilësimet e Sigurisë';

  @override
  String helloUser(String nickname) {
    return 'Përshëndetje, $nickname';
  }

  @override
  String get searchUsersToVideoCall =>
      'Kërkoni përdorues për të filluar një videothirrje';

  @override
  String get searchUsersButton => 'Kërko Përdorues';

  @override
  String get testIdentityVerification => 'Testo verifikimin e identitetit';

  @override
  String get ephemeralChat => '💬 Bisedë e Përkohshme';

  @override
  String get multipleSimultaneousRooms =>
      'Dhoma të shumta të njëkohshme (maks. 10)';

  @override
  String get logout => 'Dilni';

  @override
  String get logoutConfirmTitle => 'Dilni';

  @override
  String get logoutConfirmMessage => 'Jeni të sigurt që doni të dilni?';

  @override
  String get helpSection => 'Ndihma dhe Mbështetja';

  @override
  String get supportCenter => 'Qendra e mbështetjes';

  @override
  String get supportCenterDescription =>
      'Merrni ndihmë dhe konsultoni pyetjet e shpeshta';

  @override
  String get contactUs => 'Na Kontaktoni';

  @override
  String get contactUsDescription =>
      'Na dërgoni një email për të zgjidhur dyshimet tuaja';

  @override
  String get contactEmail => 'FlutterPutter@Proton.me';

  @override
  String get appVersion => 'Versioni';

  @override
  String get versionNumber => 'Versioni 1.0 Beta';

  @override
  String get termsAndConditions => 'Kushtet dhe Afatet';

  @override
  String get termsDescription => 'Lexoni kushtet tona të shërbimit';

  @override
  String get privacyPolicy => 'Politika e Privatësisë';

  @override
  String get privacyPolicyDescription =>
      'Konsultoni se si mbrojmë informacionin tuaj';

  @override
  String get emailCopied => 'Emaili u kopjua në kujtesën e fragmenteve';

  @override
  String get openingWebPage => 'Duke hapur faqen e internetit...';

  @override
  String get errorOpeningWebPage => 'Gabim gjatë hapjes së faqes së internetit';

  @override
  String get pinLengthError => 'PIN-i duhet të ketë midis 4 dhe 15 karaktereve';

  @override
  String get pinMismatch => 'PIN-et nuk përputhen';

  @override
  String get appLockSetupSuccess =>
      '🔒 Bllokimi i aplikacionit u konfigurua me sukses';

  @override
  String get pinSetupError => 'Gabim gjatë konfigurimit të PIN-it';

  @override
  String get pinChangeSuccess => '🔒 PIN-i u ndryshua me sukses';

  @override
  String get currentPinIncorrect => 'PIN-i aktual është i pasaktë';

  @override
  String get disableAppLockTitle => 'Çaktivizo bllokimin';

  @override
  String get disableAppLockMessage =>
      'Jeni të sigurt që doni të çaktivizoni bllokimin e aplikacionit?';

  @override
  String get appLockDisabled => '🔓 Bllokimi i aplikacionit u çaktivizua';

  @override
  String get confirm => 'Konfirmo';

  @override
  String get changePin => 'Ndrysho PIN-in:';

  @override
  String get currentPin => 'PIN-i aktual';

  @override
  String get confirmNewPin => 'Konfirmo PIN-in e ri';

  @override
  String get changePinButton => 'Ndrysho PIN-in';

  @override
  String get biometricUnlock =>
      'Zhbloko aplikacionin me biometri përveç PIN-it';

  @override
  String get screenshotsAllowedMessage => '🔓 Pamjet e ekranit TË LEJUARA';

  @override
  String get screenshotsBlockedMessage => '🔒 Pamjet e ekranit TË BLLOKUARA';

  @override
  String get screenshotConfigError =>
      'Gabim gjatë përditësimit të konfigurimit të pamjeve të ekranit';

  @override
  String get protectionActive => 'Mbrojtje aktive';

  @override
  String get nativeProtectionFeatures =>
      '• Bllokim nativ në iOS dhe Android\n• Alarm kur zbulohen përpjekje për kapje\n• Mbrojtje në ndërruesin e aplikacioneve';

  @override
  String get autoDestructionDefaultDisabled =>
      '🔥 Vetëshkatërrimi i paracaktuar u çaktivizua';

  @override
  String get autoDestructionError =>
      'Gabim gjatë përditësimit të konfigurimit të vetëshkatërrimit';

  @override
  String get protectYourApp => 'Mbroni aplikacionin tuaj';

  @override
  String get securityPinDescription =>
      'Konfiguroni një PIN sigurie për të mbrojtur privatësinë tuaj. Njoftimet do të vazhdojnë të mbërrijnë edhe pse aplikacioni është i bllokuar.';

  @override
  String get lockActivated => 'Bllokimi u aktivizua';

  @override
  String get disable => 'Çaktivizo';

  @override
  String get errorCopyingEmail => 'Gabim gjatë kopjimit të emailit';

  @override
  String get automaticLockTimeout => 'Koha e bllokimit automatik';

  @override
  String get appWillLockAfter =>
      'Aplikacioni do të bllokohet automatikisht pas:';

  @override
  String get biometricAuthentication => 'Autentifikimi biometrik';

  @override
  String get enableBiometric => 'Aktivizo gjurmën e gishtit/Face ID';

  @override
  String get autoApplyDefault => 'Apliko automatikisht';

  @override
  String get autoApplyEnabled =>
      'Do të aplikohet kur bashkoheni në dhoma të reja';

  @override
  String get autoApplyDisabled => 'Apliko vetëm manualisht në çdo dhomë';

  @override
  String get currentConfiguration => 'Konfigurimi aktual';

  @override
  String get sessionActive => 'seancë aktive';

  @override
  String get sessionsActive => 'seanca aktive';

  @override
  String get noActiveSessionsMessage => 'Nuk ka seanca aktive të regjistruara';

  @override
  String get helpAndSupport =>
      'Merrni ndihmë, na kontaktoni ose konsultoni politikat tona';

  @override
  String get autoDestructionDefaultEnabled =>
      '🔥 Vetëshkatërrimi i paracaktuar: ';

  @override
  String get verificationDemonstration => 'Demonstrimi i Verifikimit';

  @override
  String get roomLabel => 'Dhoma:';

  @override
  String get userLabel => 'Përdoruesi:';

  @override
  String get statusVerified => 'Statusi: I Verifikuar ✅';

  @override
  String get identityVerifiedCorrect => 'Identiteti u verifikua saktë';

  @override
  String get identityVerifiedFull => '✅ Identiteti i Verifikuar';

  @override
  String get bothUsersVerified =>
      'Të dy përdoruesit kanë verifikuar identitetin e tyre';

  @override
  String get yourVerificationCodes => 'KODET TUAJA TË VERIFIKIMIT';

  @override
  String get shareCodeMessage =>
      'Ndani NJË nga këto kode përmes një kanali tjetër (WhatsApp, Telegram, etj.)';

  @override
  String get hideCodesBut => '🙈 Fshih Kodet';

  @override
  String get alphanumericCode => '🔤 Alfanumerik';

  @override
  String get numericCode => '🔢 Numerik';

  @override
  String get emojiCode => '😀 Emoji';

  @override
  String get enterCodeToVerify => '❌ Vendosni një kod për të verifikuar';

  @override
  String get invalidCodeFormat => '❌ Formati i kodit i pavlefshëm';

  @override
  String get identityVerifiedSuccess => '✅ Identiteti u verifikua me sukses!';

  @override
  String get incorrectCode => '❌ Kodi i pasaktë';

  @override
  String get codesRegenerated => '🔄 Kodet u rigjeneruan';

  @override
  String get codeCopied => '📋 Kodi u kopjua në kujtesën e fragmenteve';

  @override
  String get partnerCodesReceived => '📥 Kodet e partnerit u morën';

  @override
  String get codesSentToPartner => '📤 Kodet iu dërguan partnerit';

  @override
  String get resendingCodes => '🔄 Duke ridërguar kodet te partneri...';

  @override
  String get stepExpandVerification =>
      'Prekni mbi \"🔐 Verifikimi i Identitetit\" për të zgjeruar';

  @override
  String get stepShowCodes =>
      'Prekni \"👁️ Shfaq Kodet e Mia\" për të parë kodet tuaja unike';

  @override
  String get stepPasteCode => 'Ngjisni kodin në \"VERIFIKO KODIN E PARTNERIT\"';

  @override
  String get stepVerifyCode =>
      'Prekni \"✅ Verifiko\" për të simuluar verifikimin';

  @override
  String get enterPartnerCode =>
      'Vendosni kodin që ju ka ndarë personi tjetër:';

  @override
  String get partnerCodesReceivedWithCode => '✅ Kodet e partnerit u morën:';

  @override
  String get waitingPartnerCodes => '⏳ Duke pritur kodet e partnerit...';

  @override
  String get verificationSuccessMessage =>
      'Identiteti u verifikua me sukses! Të dy përdoruesit janë autentikë.';

  @override
  String get chatInvitationsTitle => 'Ftesat e Bisedave';

  @override
  String get cleanExpiredInvitations => 'Pastro ftesat e skaduara';

  @override
  String get refreshInvitations => 'Rifresko ftesat';

  @override
  String errorInitializing(String error) {
    return 'Gabim gjatë inicializimit: $error';
  }

  @override
  String expiredInvitationsDeleted(int count) {
    return '$count ftesa të skaduara u fshinë përgjithmonë';
  }

  @override
  String get noExpiredInvitationsToClean =>
      'Nuk ka ftesa të skaduara për t\'u pastruar';

  @override
  String errorAcceptingInvitation(String error) {
    return 'Gabim gjatë pranimit të ftesës: $error';
  }

  @override
  String errorUpdatingInvitations(String error) {
    return 'Gabim gjatë përditësimit të ftesave: $error';
  }

  @override
  String invitationsUpdated(int active, int expired) {
    return 'Përditësuar: $active aktive, $expired të skaduara të fshira';
  }

  @override
  String invitationsUpdatedActive(int active) {
    return 'Përditësuar: $active ftesa aktive';
  }

  @override
  String get noInvitations => 'Nuk ka ftesa';

  @override
  String get invitationsWillAppearHere =>
      'Ftesat e bisedave do të shfaqen këtu';

  @override
  String get chatInvitation => 'Ftesë bisede';

  @override
  String fromUser(String userId) {
    return 'Nga: $userId';
  }

  @override
  String get expired => 'E skaduar';

  @override
  String get reject => 'Refuzo';

  @override
  String get accept => 'Prano';

  @override
  String get tapToCreateOrJoinEphemeralChats =>
      'Prekni për të krijuar ose bashkuar në biseda të përkohshme';

  @override
  String get now => 'Tani';

  @override
  String get callEnded => 'Thirrja përfundoi';

  @override
  String get videoCallFeatureAvailable =>
      '🎥 Funksioni i videothirrjes i disponueshëm';

  @override
  String get pendingInvitations => 'Ftesat në pritje';

  @override
  String chatInvitationsCount(int count) {
    return '$count ftesë(a) bisede';
  }

  @override
  String get searching => 'Duke kërkuar...';

  @override
  String get noUsersFound => 'Nuk u gjetën përdorues';

  @override
  String get errorSearchingUsers => 'Gabim gjatë kërkimit të përdoruesve';

  @override
  String get startVideoCall => 'Fillo videothirrjen';

  @override
  String get startAudioCall => 'Fillo thirrjen';

  @override
  String confirmVideoCall(String nickname) {
    return 'Dëshironi të filloni një videothirrje me $nickname?';
  }

  @override
  String confirmAudioCall(String nickname) {
    return 'Dëshironi të filloni një thirrje me $nickname?';
  }

  @override
  String get initiatingVideoCall => 'Duke filluar videothirrjen...';

  @override
  String get initiatingAudioCall => 'Duke filluar thirrjen...';

  @override
  String get sendingInvitation => 'Duke dërguar ftesën...';

  @override
  String get errorInitiatingCall => 'Gabim gjatë fillimit të thirrjes';

  @override
  String get waitingForResponse => 'Duke pritur përgjigje...';

  @override
  String get invitationSentTo => 'Ftesa iu dërgua';

  @override
  String get waitingForAcceptance => 'Duke pritur që të pranojë ftesën...';

  @override
  String get ephemeralChatTooltip => 'Bisedë e Përkohshme';

  @override
  String get audioCallTooltip => 'Thirrje';

  @override
  String get videoCallTooltip => 'Video';

  @override
  String get searchUser => 'Kërko Përdorues';

  @override
  String get retry => 'Provo Përsëri';

  @override
  String get searchingUsers => 'Duke kërkuar përdorues...';

  @override
  String noUsersFoundWith(String query) {
    return 'Nuk u gjetën përdorues\\nme \"$query\"';
  }

  @override
  String errorSearchingUsersDetails(String error) {
    return 'Gabim gjatë kërkimit të përdoruesve: $error';
  }

  @override
  String multipleChatsTitle(int count) {
    return 'Biseda të Shumta ($count/10)';
  }

  @override
  String get backToHome => 'Kthehu në Fillim';

  @override
  String get closeAllRooms => 'Mbyll Të Gjitha Dhomat';

  @override
  String get closeAllRoomsConfirm =>
      'Jeni të sigurt që doni të mbyllni të gjitha dhomat e bisedave?';

  @override
  String get closeAll => 'Mbyll Të Gjitha';

  @override
  String participants(int count) {
    return '$count pjesëmarrës';
  }

  @override
  String roomActive(int count) {
    return 'Dhomë aktive ($count pjesëmarrës)';
  }

  @override
  String get noConnection => 'Pa lidhje';

  @override
  String get createNewRoom => 'Krijo Dhomë të Re';

  @override
  String get addChat => 'Shto Bisedë';

  @override
  String get statistics => 'Statistikat';

  @override
  String get chatStatisticsTitle => 'Statistikat e Bisedës';

  @override
  String get activeRooms => 'Dhomat aktive';

  @override
  String get totalMessages => 'Mesazhet totale';

  @override
  String get unreadMessages => 'Të palexuara';

  @override
  String get initiatingChat => 'Duke filluar bisedën...';

  @override
  String errorClosingRoom(String error) {
    return 'Gabim gjatë mbylljes së dhomës: $error';
  }

  @override
  String get invitationAccepted => '✅ Ftesa u pranua';

  @override
  String errorAcceptingInvitationDetails(String error) {
    return 'Gabim gjatë pranimit të ftesës: $error';
  }

  @override
  String errorCreatingRoom(String error) {
    return 'Gabim gjatë krijimit të dhomës: $error';
  }

  @override
  String get createNewChatRoom => 'Krijo dhomë të re bisede';

  @override
  String get minutes => 'minuta';

  @override
  String get seconds => 'sekonda';

  @override
  String get microphonePermissions => '🎵 Lejet e Mikrofonit';

  @override
  String get microphonePermissionsContent =>
      'Për të regjistruar audio duhet të aktivizoni lejet e mikrofonit në cilësimet e aplikacionit.\n\nShkoni te Cilësimet > Privatësia > Mikrofoni dhe aktivizoni lejet për këtë aplikacion.';

  @override
  String get openSettings => 'Hap Cilësimet';

  @override
  String errorInitializingAudio(String error) {
    return 'Gabim gjatë inicializimit të audios: $error';
  }

  @override
  String get imageTooLarge => 'Imazhi shumë i madh. Maksimumi i lejuar 500KB.';

  @override
  String errorSendingImage(String error) {
    return 'Gabim gjatë dërgimit të imazhit: $error';
  }

  @override
  String errorSendingAudio(String error) {
    return 'Gabim gjatë dërgimit të audios: $error';
  }

  @override
  String get destroyRoomContent =>
      'Ky veprim do të shkatërrojë përgjithmonë dhomën e bisedës për të dy përdoruesit.\n\nDo të fillojë një numërues prej 10 sekondash i dukshëm për të dy pjesëmarrësit.';

  @override
  String get destroyRoomButton => 'Shkatërro Dhomën';

  @override
  String get connectingToSecureChat => 'Duke u lidhur me bisedën e sigurt...';

  @override
  String get autoDestructionConfigured1Min =>
      'Vetëshkatërrimi i konfiguruar: 1 minutë';

  @override
  String get autoDestructionConfigured5Min =>
      'Vetëshkatërrimi i konfiguruar: 5 minuta';

  @override
  String get autoDestructionConfigured1Hour =>
      'Vetëshkatërrimi i konfiguruar: 1 orë';

  @override
  String screenshotAlert(String user) {
    return '📸 Kujdes! $user bëri një pamje ekrani';
  }

  @override
  String screenshotNotification(String user) {
    return '📸 $user ka bërë një pamje ekrani';
  }

  @override
  String get initializingAudioRecorder =>
      'Duke inicializuar regjistruesin e audios...';

  @override
  String get audioRecorderNotAvailable =>
      'Regjistruesi i audios nuk është i disponueshëm. Kontrolloni lejet e mikrofonit.';

  @override
  String errorStartingRecording(String error) {
    return 'Gabim gjatë fillimit të regjistrimit: $error';
  }

  @override
  String get audioPlayerNotAvailable =>
      'Luajtësi i audios nuk është i disponueshëm';

  @override
  String get audioNotAvailable => 'Audio nuk është i disponueshëm';

  @override
  String errorPlayingAudio(String error) {
    return 'Gabim gjatë luajtjes së audios: $error';
  }

  @override
  String get screenshotTestSent => '📸 Testi i pamjes së ekranit u dërgua';

  @override
  String errorSendingTest(String error) {
    return 'Gabim gjatë dërgimit të testit: $error';
  }

  @override
  String get audioTooLong => 'Audio shumë i gjatë. Maksimumi i lejuar 1MB.';

  @override
  String get errorWebAudioRecording =>
      'Gabim: Nuk mund të regjistrohej audio në ueb';

  @override
  String get errorWebAudioSaving => 'Gabim: Nuk mund të ruhej audio';

  @override
  String errorStoppingRecording(String error) {
    return 'Gabim gjatë ndalimit të regjistrimit: $error';
  }

  @override
  String get sendEncryptedImageTooltip => 'Dërgo imazh të enkriptuar';
}
