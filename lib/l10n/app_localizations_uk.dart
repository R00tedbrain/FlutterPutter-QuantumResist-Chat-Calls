// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appTitle => 'FlutterPutter';

  @override
  String get loginTitle => 'Увійдіть, щоб продовжити';

  @override
  String get email => 'Email';

  @override
  String get enterEmail => 'Введіть вашу електронну пошту';

  @override
  String get password => 'Пароль';

  @override
  String get enterPassword => 'Введіть ваш пароль';

  @override
  String get pleaseEnterEmail => 'Будь ласка, введіть вашу електронну пошту';

  @override
  String get enterValidEmail => 'Введіть дійсну електронну пошту';

  @override
  String get pleaseEnterPassword => 'Будь ласка, введіть ваш пароль';

  @override
  String get passwordMinLength =>
      'Пароль повинен містити щонайменше 6 символів';

  @override
  String get loginButton => 'Увійти';

  @override
  String get noAccount => 'Немає облікового запису?';

  @override
  String get register => 'Зареєструватися';

  @override
  String get oneSessionSecurity =>
      '🔒 Дозволено лише 1 активну сесію на користувача для більшої безпеки';

  @override
  String get oneSessionMaxSecurity =>
      'Лише 1 сесія на користувача (Максимальна безпека)';

  @override
  String get privacyAndSecurity => 'Конфіденційність та Безпека';

  @override
  String get noDataCollection => 'Ми не збираємо особисті дані';

  @override
  String get anonymousConnections => 'Усі з\'єднання анонімні';

  @override
  String get ephemeralChatRooms =>
      'Тимчасові чат-кімнати, які автоматично знищуються';

  @override
  String get encryptionInfo =>
      'Шифрування XSalsa20 з випадковими ключами для кожної кімнати';

  @override
  String get chats => 'Чати';

  @override
  String get secureChat => 'Безпечний Чат';

  @override
  String get secureChatDescription =>
      'Торкніться, щоб створити або приєднатися до тимчасових чатів';

  @override
  String get privateVideoCall => 'Приватний Відеодзвінок';

  @override
  String get videoCallDescription => 'Дзвінок завершено';

  @override
  String get multipleChats => 'Кілька Чатів';

  @override
  String get newRoom => 'Нова Кімната';

  @override
  String get noActiveChats => 'Немає активних чатів';

  @override
  String get useNewRoomButton =>
      'Використовуйте вкладку \'Нова Кімната\', щоб створити чат';

  @override
  String get searchUsers => 'Пошук Користувачів';

  @override
  String get searchByNickname => 'Шукати за нікнеймом';

  @override
  String get calls => 'Дзвінки';

  @override
  String get verification => 'Верифікація';

  @override
  String get verificationDemo => 'Демо: Верифікація Особистості';

  @override
  String get verificationDemoDescription =>
      'Це демонстрація системи анонімної верифікації особистості. У реальній реалізації цей віджет був би інтегрований у тимчасові чат-кімнати.';

  @override
  String get room => 'Кімната';

  @override
  String get user => 'Користувач';

  @override
  String get identityVerification => 'Верифікація Особистості';

  @override
  String get verifyIdentityDescription =>
      'Торкніться, щоб анонімно верифікувати особистість';

  @override
  String get statusNotVerified => 'Статус: Не верифіковано';

  @override
  String get notVerifiedYet => 'Особистість ще не верифікована';

  @override
  String get howToTest => 'Як Тестувати Верифікацію';

  @override
  String get step1 => 'Торкніться на';

  @override
  String get step2 => 'Торкніться';

  @override
  String get step3 =>
      'Скопіюйте один із кодів (буквено-цифровий, цифровий або емодзі)';

  @override
  String get step4 => 'Вставте код у';

  @override
  String get step5 => 'Торкніться';

  @override
  String get showMyCodes => 'Показати Мої Коди';

  @override
  String get verifyPartnerCode => 'ПЕРЕВІРИТИ КОД ПАРТНЕРА';

  @override
  String get verify => 'Перевірити';

  @override
  String get realUsage =>
      'У реальному використанні: Користувачі ділилися б кодами через WhatsApp, Telegram тощо.';

  @override
  String get securitySettings => 'Налаштування Безпеки';

  @override
  String get securitySettingsDescription =>
      'Налаштуйте PIN-код безпеки для захисту вашої конфіденційності. Сповіщення продовжуватимуть надходити, навіть якщо програма заблокована.';

  @override
  String get configureAppLock => 'Налаштувати блокування програми';

  @override
  String get newPin => 'Новий PIN-код (4-15 символів)';

  @override
  String get confirmPin => 'Підтвердити PIN-код';

  @override
  String get activateLock => 'Активувати блокування';

  @override
  String get screenshotSecurity => 'Безпека знімків екрана';

  @override
  String get screenshotSecurityDescription =>
      'Керуйте можливістю робити знімки екрана програми.';

  @override
  String get allowScreenshots => 'Дозволити знімки екрана';

  @override
  String get screenshotsAllowed => 'Знімки екрана ДОЗВОЛЕНІ';

  @override
  String get screenshotsDisabled => 'Ви можете вимкнути їх для більшої безпеки';

  @override
  String get autoDestructionDefault => 'Самознищення за замовчуванням';

  @override
  String get autoDestructionDescription =>
      'Налаштуйте час самознищення, який автоматично застосовуватиметься при вході в нові чат-кімнати:';

  @override
  String get defaultTime => 'Час за замовчуванням:';

  @override
  String get noLimit => 'Без обмежень';

  @override
  String get selectTime =>
      'Виберіть час, щоб увімкнути самознищення за замовчуванням. Повідомлення будуть автоматично видалятися після встановленого часу.';

  @override
  String get activeSessions => 'Активні сесії';

  @override
  String get activeSessionsDescription =>
      'Керуйте пристроями, на яких у вас відкриті сесії. Подібно до Signal та WhatsApp.';

  @override
  String get currentState => 'Поточний стан';

  @override
  String get noActiveSessionsRegistered => '0 зареєстрованих активних сесій';

  @override
  String get multipleSessions => 'Кілька сесій: Вимкнено';

  @override
  String get configurationLikeSignal => 'та конфігурація як у Signal';

  @override
  String get manageSessions => 'Керувати сесіями';

  @override
  String get allowMultipleSessions => 'Дозволити кілька сесій';

  @override
  String get onlyOneActiveSession =>
      'Лише одна активна сесія одночасно (як у Signal)';

  @override
  String get searchByName => 'Шукати за ім\'ям...';

  @override
  String get writeAtLeast2Characters =>
      'Напишіть щонайменше 2 символи для пошуку користувачів';

  @override
  String get connecting => 'Підключення...';

  @override
  String get error => 'Помилка';

  @override
  String get secureMultimediaChat => 'Безпечний Мультимедійний Чат';

  @override
  String get sendEncryptedMessages =>
      'Надсилайте повідомлення та зображення,\\nзашифровані за допомогою XChaCha20-Poly1305';

  @override
  String get encryptedMessage => 'Зашифроване повідомлення...';

  @override
  String get sendEncryptedImage => 'Надіслати зашифроване зображення';

  @override
  String get takePhoto => 'Зробити Фото';

  @override
  String get useCamera => 'Використовувати камеру';

  @override
  String get gallery => 'Галерея';

  @override
  String get selectImage => 'Вибрати зображення';

  @override
  String get capturesBlocked => 'Знімки екрана заблоковані';

  @override
  String get capturesAllowed => 'Знімки екрана дозволені';

  @override
  String get e2eEncryptionSecurity => 'E2E Шифрування + Безпека';

  @override
  String get encryptionDescription =>
      'Усі повідомлення, зображення та аудіо локально шифруються за допомогою XChaCha20-Poly1305.\\n\\nСервер бачить лише непрозорі зашифровані дані.\\n\\nАудіо з реалізованим реальним записом.';

  @override
  String get screenshotsStatus => 'Знімки екрана:';

  @override
  String get screenshotsBlocked => 'ЗАБЛОКОВАНІ';

  @override
  String get screenshotsPermitted => 'ДОЗВОЛЕНІ';

  @override
  String get likeWhatsAppTelegram =>
      'Як у WhatsApp/Telegram - чорний екран на знімках';

  @override
  String get understood => 'Зрозуміло';

  @override
  String get destroyRoom => 'Знищити Кімнату';

  @override
  String get warningDestroyRoom =>
      'Ця дія назавжди знищить чат-кімнату для обох користувачів.\\n\\nРозпочнеться 10-секундний відлік, видимий для обох учасників.';

  @override
  String get cancel => 'Скасувати';

  @override
  String get audioNote => 'Аудіозапис';

  @override
  String get recordedAudioNote => 'Аудіозапис (записано)';

  @override
  String get playing => 'Відтворення...';

  @override
  String get tapToStop => 'Торкніться, щоб зупинити';

  @override
  String get tapToPlay => 'Торкніться, щоб відтворити';

  @override
  String get image => 'Зображення';

  @override
  String get backToMultipleChats => 'Повернутися до кількох чатів';

  @override
  String get backToChat => 'Повернутися до чату';

  @override
  String get screenshotsBlockedAutomatically => 'Знімки екрана ЗАБЛОКОВАНІ';

  @override
  String get screenshotsEnabled => 'Знімки екрана УВІМКНЕНІ';

  @override
  String get identityVerifiedCorrectly =>
      'Особистість партнера успішно верифікована';

  @override
  String get createAccount => 'Створити Обліковий Запис';

  @override
  String get registerSubtitle =>
      'Зареєструйтеся, щоб почати користуватися FlutterPutter';

  @override
  String get nickname => 'Нікнейм';

  @override
  String get chooseUniqueNickname => 'Виберіть унікальний нікнейм';

  @override
  String get createSecurePassword => 'Створіть надійний пароль';

  @override
  String get confirmPassword => 'Підтвердити Пароль';

  @override
  String get repeatPassword => 'Повторіть ваш пароль';

  @override
  String get invitationCode => 'Код Запрошення';

  @override
  String get enterInvitationCode => 'Введіть ваш код запрошення';

  @override
  String get registerButton => 'Зареєструватися';

  @override
  String get pleaseConfirmPassword => 'Будь ласка, підтвердіть ваш пароль';

  @override
  String get passwordsDoNotMatch => 'Паролі не збігаються';

  @override
  String get pleaseEnterNickname => 'Будь ласка, введіть нікнейм';

  @override
  String get nicknameMinLength =>
      'Нікнейм повинен містити щонайменше 3 символи';

  @override
  String get pleaseEnterInvitationCode => 'Будь ласка, введіть код запрошення';

  @override
  String get invitationCodeLength => 'Код повинен містити 8 символів';

  @override
  String get newChatInvitationReceived => '📩 Отримано нове запрошення до чату';

  @override
  String get view => 'Переглянути';

  @override
  String get chatInvitations => 'Запрошення до Чату';

  @override
  String get securitySettingsTooltip => 'Налаштування Безпеки';

  @override
  String helloUser(String nickname) {
    return 'Привіт, $nickname';
  }

  @override
  String get searchUsersToVideoCall =>
      'Шукайте користувачів, щоб розпочати відеодзвінок';

  @override
  String get searchUsersButton => 'Шукати Користувачів';

  @override
  String get testIdentityVerification => 'Тестувати верифікацію особистості';

  @override
  String get ephemeralChat => '💬 Тимчасовий Чат';

  @override
  String get multipleSimultaneousRooms => 'Кілька одночасних кімнат (макс. 10)';

  @override
  String get logout => 'Вийти';

  @override
  String get logoutConfirmTitle => 'Вийти';

  @override
  String get logoutConfirmMessage => 'Ви впевнені, що хочете вийти?';

  @override
  String get helpSection => 'Допомога та Підтримка';

  @override
  String get supportCenter => 'Центр підтримки';

  @override
  String get supportCenterDescription =>
      'Отримайте допомогу та перегляньте поширені запитання';

  @override
  String get contactUs => 'Зв\'яжіться з нами';

  @override
  String get contactUsDescription =>
      'Надішліть нам електронного листа, щоб вирішити ваші питання';

  @override
  String get contactEmail => 'FlutterPutter@Proton.me';

  @override
  String get appVersion => 'Версія';

  @override
  String get versionNumber => 'Версія 1.0 Бета';

  @override
  String get termsAndConditions => 'Умови та положення';

  @override
  String get termsDescription => 'Прочитайте наші умови надання послуг';

  @override
  String get privacyPolicy => 'Політика конфіденційності';

  @override
  String get privacyPolicyDescription =>
      'Дізнайтеся, як ми захищаємо вашу інформацію';

  @override
  String get emailCopied => 'Електронну пошту скопійовано до буфера обміну';

  @override
  String get openingWebPage => 'Відкриття веб-сторінки...';

  @override
  String get errorOpeningWebPage => 'Помилка при відкритті веб-сторінки';

  @override
  String get pinLengthError => 'PIN-код повинен містити від 4 до 15 символів';

  @override
  String get pinMismatch => 'PIN-коди не збігаються';

  @override
  String get appLockSetupSuccess =>
      '🔒 Блокування програми успішно налаштовано';

  @override
  String get pinSetupError => 'Помилка при налаштуванні PIN-коду';

  @override
  String get pinChangeSuccess => '🔒 PIN-код успішно змінено';

  @override
  String get currentPinIncorrect => 'Поточний PIN-код неправильний';

  @override
  String get disableAppLockTitle => 'Вимкнути блокування';

  @override
  String get disableAppLockMessage =>
      'Ви впевнені, що хочете вимкнути блокування програми?';

  @override
  String get appLockDisabled => '🔓 Блокування програми вимкнено';

  @override
  String get confirm => 'Підтвердити';

  @override
  String get changePin => 'Змінити PIN-код:';

  @override
  String get currentPin => 'Поточний PIN-код';

  @override
  String get confirmNewPin => 'Підтвердити новий PIN-код';

  @override
  String get changePinButton => 'Змінити PIN-код';

  @override
  String get biometricUnlock =>
      'Розблокуйте програму за допомогою біометрії на додаток до PIN-коду';

  @override
  String get screenshotsAllowedMessage => '🔓 Знімки екрана ДОЗВОЛЕНІ';

  @override
  String get screenshotsBlockedMessage => '🔒 Знімки екрана ЗАБЛОКОВАНІ';

  @override
  String get screenshotConfigError =>
      'Помилка оновлення конфігурації знімків екрана';

  @override
  String get protectionActive => 'Активний захист';

  @override
  String get nativeProtectionFeatures =>
      '• Нативне блокування на iOS та Android\n• Сповіщення при виявленні спроб знімка\n• Захист у перемикачі програм';

  @override
  String get autoDestructionDefaultDisabled =>
      '🔥 Самознищення за замовчуванням вимкнено';

  @override
  String get autoDestructionError =>
      'Помилка оновлення конфігурації самознищення';

  @override
  String get protectYourApp => 'Захистіть свою програму';

  @override
  String get securityPinDescription =>
      'Налаштуйте PIN-код безпеки для захисту вашої конфіденційності. Сповіщення продовжуватимуть надходити, навіть якщо програма заблокована.';

  @override
  String get lockActivated => 'Блокування активовано';

  @override
  String get disable => 'Вимкнути';

  @override
  String get errorCopyingEmail => 'Помилка копіювання електронної пошти';

  @override
  String get automaticLockTimeout => 'Час автоматичного блокування';

  @override
  String get appWillLockAfter => 'Програма автоматично заблокується через:';

  @override
  String get biometricAuthentication => 'Біометрична автентифікація';

  @override
  String get enableBiometric => 'Увімкнути відбиток пальця/Face ID';

  @override
  String get autoApplyDefault => 'Застосовувати автоматично';

  @override
  String get autoApplyEnabled => 'Застосовуватиметься при вході в нові кімнати';

  @override
  String get autoApplyDisabled => 'Застосовувати лише вручну в кожній кімнаті';

  @override
  String get currentConfiguration => 'Поточна конфігурація';

  @override
  String get sessionActive => 'активна сесія';

  @override
  String get sessionsActive => 'активні сесії';

  @override
  String get noActiveSessionsMessage => 'Немає зареєстрованих активних сесій';

  @override
  String get helpAndSupport =>
      'Отримайте допомогу, зв\'яжіться з нами або перегляньте наші політики';

  @override
  String get autoDestructionDefaultEnabled =>
      '🔥 Самознищення за замовчуванням: ';

  @override
  String get verificationDemonstration => 'Демонстрація Верифікації';

  @override
  String get roomLabel => 'Кімната:';

  @override
  String get userLabel => 'Користувач:';

  @override
  String get statusVerified => 'Статус: Верифіковано ✅';

  @override
  String get identityVerifiedCorrect => 'Особистість успішно верифікована';

  @override
  String get identityVerifiedFull => '✅ Особистість Верифіковано';

  @override
  String get bothUsersVerified =>
      'Обидва користувачі верифікували свою особистість';

  @override
  String get yourVerificationCodes => 'ВАШІ ВЕРИФІКАЦІЙНІ КОДИ';

  @override
  String get shareCodeMessage =>
      'Поділіться ОДНИМ з цих кодів через інший канал (WhatsApp, Telegram тощо)';

  @override
  String get hideCodesBut => '🙈 Приховати Коди';

  @override
  String get alphanumericCode => '🔤 Буквено-цифровий';

  @override
  String get numericCode => '🔢 Цифровий';

  @override
  String get emojiCode => '😀 Емодзі';

  @override
  String get enterCodeToVerify => '❌ Введіть код для верифікації';

  @override
  String get invalidCodeFormat => '❌ Неправильний формат коду';

  @override
  String get identityVerifiedSuccess => '✅ Особистість успішно верифікована!';

  @override
  String get incorrectCode => '❌ Неправильний код';

  @override
  String get codesRegenerated => '🔄 Коди регенеровано';

  @override
  String get codeCopied => '📋 Код скопійовано до буфера обміну';

  @override
  String get partnerCodesReceived => '📥 Коди партнера отримано';

  @override
  String get codesSentToPartner => '📤 Коди надіслано партнеру';

  @override
  String get resendingCodes => '🔄 Повторне надсилання кодів партнеру...';

  @override
  String get stepExpandVerification =>
      'Торкніться на \"🔐 Верифікація Особистості\", щоб розгорнути';

  @override
  String get stepShowCodes =>
      'Торкніться \"👁️ Показати Мої Коди\", щоб побачити ваші унікальні коди';

  @override
  String get stepPasteCode => 'Вставте код у \"ПЕРЕВІРИТИ КОД ПАРТНЕРА\"';

  @override
  String get stepVerifyCode =>
      'Торкніться \"✅ Перевірити\", щоб симулювати верифікацію';

  @override
  String get enterPartnerCode =>
      'Введіть код, яким з вами поділилася інша особа:';

  @override
  String get partnerCodesReceivedWithCode => '✅ Коди партнера отримано:';

  @override
  String get waitingPartnerCodes => '⏳ Очікування кодів партнера...';

  @override
  String get verificationSuccessMessage =>
      'Особистість успішно верифікована! Обидва користувачі автентичні.';

  @override
  String get chatInvitationsTitle => 'Запрошення до Чату';

  @override
  String get cleanExpiredInvitations => 'Очистити прострочені запрошення';

  @override
  String get refreshInvitations => 'Оновити запрошення';

  @override
  String errorInitializing(String error) {
    return 'Помилка ініціалізації: $error';
  }

  @override
  String expiredInvitationsDeleted(int count) {
    return '$count прострочених запрошень видалено назавжди';
  }

  @override
  String get noExpiredInvitationsToClean =>
      'Немає прострочених запрошень для очищення';

  @override
  String errorAcceptingInvitation(String error) {
    return 'Помилка прийняття запрошення: $error';
  }

  @override
  String errorUpdatingInvitations(String error) {
    return 'Помилка оновлення запрошень: $error';
  }

  @override
  String invitationsUpdated(int active, int expired) {
    return 'Оновлено: $active активних, $expired прострочених видалено';
  }

  @override
  String invitationsUpdatedActive(int active) {
    return 'Оновлено: $active активних запрошень';
  }

  @override
  String get noInvitations => 'Немає запрошень';

  @override
  String get invitationsWillAppearHere => 'Запрошення до чату з\'являться тут';

  @override
  String get chatInvitation => 'Запрошення до чату';

  @override
  String fromUser(String userId) {
    return 'Від: $userId';
  }

  @override
  String get expired => 'Прострочено';

  @override
  String get reject => 'Відхилити';

  @override
  String get accept => 'Прийняти';

  @override
  String get tapToCreateOrJoinEphemeralChats =>
      'Торкніться, щоб створити або приєднатися до тимчасових чатів';

  @override
  String get now => 'Зараз';

  @override
  String get callEnded => 'Дзвінок завершено';

  @override
  String get videoCallFeatureAvailable => '🎥 Функція відеодзвінка доступна';

  @override
  String get pendingInvitations => 'Очікуючі запрошення';

  @override
  String chatInvitationsCount(int count) {
    return '$count запрошень до чату';
  }

  @override
  String get searching => 'Пошук...';

  @override
  String get noUsersFound => 'Користувачів не знайдено';

  @override
  String get errorSearchingUsers => 'Помилка пошуку користувачів';

  @override
  String get startVideoCall => 'Розпочати відеодзвінок';

  @override
  String get startAudioCall => 'Розпочати дзвінок';

  @override
  String confirmVideoCall(String nickname) {
    return 'Бажаєте розпочати відеодзвінок з $nickname?';
  }

  @override
  String confirmAudioCall(String nickname) {
    return 'Бажаєте розпочати дзвінок з $nickname?';
  }

  @override
  String get initiatingVideoCall => 'Розпочинається відеодзвінок...';

  @override
  String get initiatingAudioCall => 'Розпочинається дзвінок...';

  @override
  String get sendingInvitation => 'Надсилання запрошення...';

  @override
  String get errorInitiatingCall => 'Помилка під час початку дзвінка';

  @override
  String get waitingForResponse => 'Очікування відповіді...';

  @override
  String get invitationSentTo => 'Запрошення надіслано до';

  @override
  String get waitingForAcceptance => 'Очікування прийняття запрошення...';

  @override
  String get ephemeralChatTooltip => 'Тимчасовий Чат';

  @override
  String get audioCallTooltip => 'Дзвінок';

  @override
  String get videoCallTooltip => 'Відео';

  @override
  String get searchUser => 'Шукати Користувача';

  @override
  String get retry => 'Повторити';

  @override
  String get searchingUsers => 'Пошук користувачів...';

  @override
  String noUsersFoundWith(String query) {
    return 'Користувачів не знайдено\\nз \"$query\"';
  }

  @override
  String errorSearchingUsersDetails(String error) {
    return 'Помилка пошуку користувачів: $error';
  }

  @override
  String multipleChatsTitle(int count) {
    return 'Кілька Чатів ($count/10)';
  }

  @override
  String get backToHome => 'Повернутися на Головну';

  @override
  String get closeAllRooms => 'Закрити Всі Кімнати';

  @override
  String get closeAllRoomsConfirm =>
      'Ви впевнені, що хочете закрити всі чат-кімнати?';

  @override
  String get closeAll => 'Закрити Всі';

  @override
  String participants(int count) {
    return '$count учасників';
  }

  @override
  String roomActive(int count) {
    return 'Кімната активна ($count учасників)';
  }

  @override
  String get noConnection => 'Немає з\'єднання';

  @override
  String get createNewRoom => 'Створити Нову Кімнату';

  @override
  String get addChat => 'Додати Чат';

  @override
  String get statistics => 'Статистика';

  @override
  String get chatStatisticsTitle => 'Статистика Чату';

  @override
  String get activeRooms => 'Активні кімнати';

  @override
  String get totalMessages => 'Всього повідомлень';

  @override
  String get unreadMessages => 'Непрочитані';

  @override
  String get initiatingChat => 'Розпочинається чат...';

  @override
  String errorClosingRoom(String error) {
    return 'Помилка закриття кімнати: $error';
  }

  @override
  String get invitationAccepted => '✅ Запрошення прийнято';

  @override
  String errorAcceptingInvitationDetails(String error) {
    return 'Помилка прийняття запрошення: $error';
  }

  @override
  String errorCreatingRoom(String error) {
    return 'Помилка створення кімнати: $error';
  }

  @override
  String get createNewChatRoom => 'Створити нову чат-кімнату';

  @override
  String get minutes => 'хвилин';

  @override
  String get seconds => 'секунд';

  @override
  String get microphonePermissions => '🎵 Дозволи на Мікрофон';

  @override
  String get microphonePermissionsContent =>
      'Щоб записувати аудіо, потрібно активувати дозволи на мікрофон у налаштуваннях програми.\n\nПерейдіть до Налаштування > Конфіденційність > Мікрофон та активуйте дозволи для цієї програми.';

  @override
  String get openSettings => 'Відкрити Налаштування';

  @override
  String errorInitializingAudio(String error) {
    return 'Помилка ініціалізації аудіо: $error';
  }

  @override
  String get imageTooLarge =>
      'Зображення завелике. Максимально дозволено 500 КБ.';

  @override
  String errorSendingImage(String error) {
    return 'Помилка надсилання зображення: $error';
  }

  @override
  String errorSendingAudio(String error) {
    return 'Помилка надсилання аудіо: $error';
  }

  @override
  String get destroyRoomContent =>
      'Ця дія назавжди знищить чат-кімнату для обох користувачів.\n\nРозпочнеться 10-секундний відлік, видимий для обох учасників.';

  @override
  String get destroyRoomButton => 'Знищити Кімнату';

  @override
  String get connectingToSecureChat => 'Підключення до безпечного чату...';

  @override
  String get autoDestructionConfigured1Min =>
      'Самознищення налаштовано: 1 хвилина';

  @override
  String get autoDestructionConfigured5Min =>
      'Самознищення налаштовано: 5 хвилин';

  @override
  String get autoDestructionConfigured1Hour =>
      'Самознищення налаштовано: 1 година';

  @override
  String screenshotAlert(String user) {
    return '📸 Увага! $user зробив знімок екрана';
  }

  @override
  String screenshotNotification(String user) {
    return '📸 $user зробив знімок екрана';
  }

  @override
  String get initializingAudioRecorder => 'Ініціалізація аудіорекордера...';

  @override
  String get audioRecorderNotAvailable =>
      'Аудіорекордер недоступний. Перевірте дозволи на мікрофон.';

  @override
  String errorStartingRecording(String error) {
    return 'Помилка початку запису: $error';
  }

  @override
  String get audioPlayerNotAvailable => 'Аудіоплеєр недоступний';

  @override
  String get audioNotAvailable => 'Аудіо недоступне';

  @override
  String errorPlayingAudio(String error) {
    return 'Помилка відтворення аудіо: $error';
  }

  @override
  String get screenshotTestSent => '📸 Тест знімка екрана надіслано';

  @override
  String errorSendingTest(String error) {
    return 'Помилка надсилання тесту: $error';
  }

  @override
  String get audioTooLong => 'Аудіо задовге. Максимально дозволено 1 МБ.';

  @override
  String get errorWebAudioRecording =>
      'Помилка: Не вдалося записати аудіо у веб-версії';

  @override
  String get errorWebAudioSaving => 'Помилка: Не вдалося зберегти аудіо';

  @override
  String errorStoppingRecording(String error) {
    return 'Помилка зупинки запису: $error';
  }

  @override
  String get sendEncryptedImageTooltip => 'Надіслати зашифроване зображення';

  @override
  String get myProfile => 'Мій Профіль';

  @override
  String get dangerZone => 'Небезпечна Зона';

  @override
  String get dangerZoneDescription =>
      'Ця дія назавжди видалить ваш обліковий запис і всі ваші дані. Ви не зможете відновити свій обліковий запис після видалення.';

  @override
  String get destroyMyAccount => 'Знищити мій обліковий запис';

  @override
  String get warningTitle => 'Попередження!';

  @override
  String get destroyAccountWarning =>
      'Ви збираєтеся назавжди знищити свій обліковий запис.';

  @override
  String get thisActionWill => 'Ця дія:';

  @override
  String get deleteAllData => '• Видалить всі ваші дані';

  @override
  String get closeAllSessions => '• Закрить всі ваші активні сесії';

  @override
  String get deleteChatHistory => '• Видалить вашу історію чатів';

  @override
  String get cannotBeUndone => '• Не може бути скасована';

  @override
  String get neverAccessAgain =>
      'Після знищення ви ніколи більше не зможете отримати доступ до цього облікового запису.';

  @override
  String get continueButton => 'Продовжити';

  @override
  String get finalConfirmation => 'Фінальне Підтвердження';

  @override
  String get confirmDestructionText =>
      'Щоб підтвердити знищення вашого облікового запису, введіть:';

  @override
  String get typeConfirmation => 'Введіть підтвердження';

  @override
  String get destroyAccount => 'Знищити Обліковий Запис';

  @override
  String get functionalityInDevelopment => 'Функціональність у розробці';

  @override
  String get accountDestructionAvailable =>
      'Знищення облікового запису буде доступне в наступному оновленні. Ваш запит зареєстровано.';
}
