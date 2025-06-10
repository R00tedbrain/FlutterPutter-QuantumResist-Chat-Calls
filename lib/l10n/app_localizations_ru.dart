// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'FlutterPutter';

  @override
  String get loginTitle => 'Войдите, чтобы продолжить';

  @override
  String get email => 'Электронная почта';

  @override
  String get enterEmail => 'Введите вашу электронную почту';

  @override
  String get password => 'Пароль';

  @override
  String get enterPassword => 'Введите ваш пароль';

  @override
  String get pleaseEnterEmail => 'Пожалуйста, введите вашу электронную почту';

  @override
  String get enterValidEmail =>
      'Введите действительный адрес электронной почты';

  @override
  String get pleaseEnterPassword => 'Пожалуйста, введите ваш пароль';

  @override
  String get passwordMinLength => 'Пароль должен содержать не менее 6 символов';

  @override
  String get loginButton => 'Войти';

  @override
  String get noAccount => 'У вас нет аккаунта?';

  @override
  String get register => 'Зарегистрироваться';

  @override
  String get oneSessionSecurity =>
      '🔒 В целях безопасности разрешена только 1 активная сессия на пользователя';

  @override
  String get oneSessionMaxSecurity =>
      'Только 1 сессия на пользователя (Максимальная безопасность)';

  @override
  String get privacyAndSecurity => 'Конфиденциальность и Безопасность';

  @override
  String get noDataCollection => 'Мы не собираем личные данные';

  @override
  String get anonymousConnections => 'Все соединения анонимны';

  @override
  String get ephemeralChatRooms =>
      'Эфемерные чат-комнаты, которые автоматически уничтожаются';

  @override
  String get encryptionInfo =>
      'Шифрование XSalsa20 со случайными ключами для каждой комнаты';

  @override
  String get chats => 'Чаты';

  @override
  String get secureChat => 'Безопасный чат';

  @override
  String get secureChatDescription =>
      'Нажмите, чтобы создать эфемерные чаты или присоединиться к ним';

  @override
  String get privateVideoCall => 'Приватный видеозвонок';

  @override
  String get videoCallDescription => 'Звонок завершен';

  @override
  String get multipleChats => 'Множественные чаты';

  @override
  String get newRoom => 'Новая комната';

  @override
  String get noActiveChats => 'Нет активных чатов';

  @override
  String get useNewRoomButton =>
      'Используйте вкладку \'Новая комната\' для создания чата';

  @override
  String get searchUsers => 'Поиск пользователей';

  @override
  String get searchByNickname => 'Поиск по никнейму';

  @override
  String get calls => 'Звонки';

  @override
  String get verification => 'Верификация';

  @override
  String get verificationDemo => '🔐 Демо Верификация';

  @override
  String get verificationDemoDescription =>
      'Это демонстрация анонимной системы верификации личности. В реальной реализации этот виджет будет интегрирован в эфемерные чат-комнаты.';

  @override
  String get room => 'Комната';

  @override
  String get user => 'Пользователь';

  @override
  String get identityVerification => 'Верификация личности';

  @override
  String get verifyIdentityDescription =>
      'Нажмите, чтобы анонимно верифицировать личность';

  @override
  String get statusNotVerified => 'Статус: Не верифицировано';

  @override
  String get notVerifiedYet => 'Личность еще не верифицирована';

  @override
  String get howToTest => 'Как протестировать верификацию';

  @override
  String get step1 => 'Нажмите на';

  @override
  String get step2 => 'Нажмите';

  @override
  String get step3 =>
      'Скопируйте один из кодов (буквенно-цифровой, цифровой или эмодзи)';

  @override
  String get step4 => 'Вставьте код в';

  @override
  String get step5 => 'Нажмите';

  @override
  String get showMyCodes => 'Показать мои коды';

  @override
  String get verifyPartnerCode => 'ПРОВЕРИТЬ КОД ПАРТНЕРА';

  @override
  String get verify => 'Проверить';

  @override
  String get realUsage =>
      'В реальном использовании: пользователи будут делиться кодами через WhatsApp, Telegram и т.д.';

  @override
  String get securitySettings => 'Настройки безопасности';

  @override
  String get securitySettingsDescription =>
      'Установите PIN-код безопасности для защиты вашей конфиденциальности. Уведомления будут поступать, даже если приложение заблокировано.';

  @override
  String get configureAppLock => 'Настроить блокировку приложения';

  @override
  String get newPin => 'Новый PIN-код (4-15 символов)';

  @override
  String get confirmPin => 'Подтвердить PIN-код';

  @override
  String get activateLock => 'Активировать блокировку';

  @override
  String get screenshotSecurity => 'Безопасность скриншотов';

  @override
  String get screenshotSecurityDescription =>
      'Управляйте возможностью создания скриншотов приложения.';

  @override
  String get allowScreenshots => 'Разрешить скриншоты';

  @override
  String get screenshotsAllowed => 'Скриншоты РАЗРЕШЕНЫ';

  @override
  String get screenshotsDisabled =>
      'Вы можете отключить их для большей безопасности';

  @override
  String get autoDestructionDefault => 'Автоудаление по умолчанию';

  @override
  String get autoDestructionDescription =>
      'Настройте время автоудаления, которое будет автоматически применяться при присоединении к новым чат-комнатам:';

  @override
  String get defaultTime => 'Время по умолчанию:';

  @override
  String get noLimit => 'Без ограничений';

  @override
  String get selectTime =>
      'Выберите время для включения автоудаления по умолчанию. Сообщения будут автоматически удаляться по истечении настроенного времени.';

  @override
  String get activeSessions => 'Активные сессии';

  @override
  String get activeSessionsDescription =>
      'Управляйте устройствами, на которых у вас открыты сессии. Аналогично Signal и WhatsApp.';

  @override
  String get currentState => 'Текущее состояние';

  @override
  String get noActiveSessionsRegistered =>
      '0 зарегистрированных активных сессий';

  @override
  String get multipleSessions => 'Множественные сессии: Отключено';

  @override
  String get configurationLikeSignal => 'и конфигурация как у Signal';

  @override
  String get manageSessions => 'Управлять сессиями';

  @override
  String get allowMultipleSessions => 'Разрешить множественные сессии';

  @override
  String get onlyOneActiveSession =>
      'Только одна активная сессия одновременно (как у Signal)';

  @override
  String get searchByName => 'Поиск по имени...';

  @override
  String get writeAtLeast2Characters =>
      'Введите не менее 2 символов для поиска пользователей';

  @override
  String get connecting => 'Подключение...';

  @override
  String get error => 'Ошибка';

  @override
  String get secureMultimediaChat => 'Безопасный мультимедийный чат';

  @override
  String get sendEncryptedMessages =>
      'Отправляйте сообщения и изображения,\\nзашифрованные с помощью XChaCha20-Poly1305';

  @override
  String get encryptedMessage => 'Зашифрованное сообщение...';

  @override
  String get sendEncryptedImage => '📷 Отправить зашифрованное изображение';

  @override
  String get takePhoto => 'Сделать фото';

  @override
  String get useCamera => 'Использовать камеру';

  @override
  String get gallery => 'Галерея';

  @override
  String get selectImage => 'Выбрать изображение';

  @override
  String get capturesBlocked => 'Скриншоты заблокированы';

  @override
  String get capturesAllowed => 'Скриншоты разрешены';

  @override
  String get e2eEncryptionSecurity => 'E2E шифрование + Безопасность';

  @override
  String get encryptionDescription =>
      'Все сообщения, изображения и аудио шифруются локально с помощью XChaCha20-Poly1305.\\n\\nСервер видит только непрозрачные зашифрованные двоичные объекты.\\n\\nРеализована запись реального аудио.';

  @override
  String get screenshotsStatus => 'Скриншоты:';

  @override
  String get screenshotsBlocked => 'ЗАБЛОКИРОВАНЫ';

  @override
  String get screenshotsPermitted => 'РАЗРЕШЕНЫ';

  @override
  String get likeWhatsAppTelegram =>
      'Как в WhatsApp/Telegram - черный экран на скриншотах';

  @override
  String get understood => 'Понятно';

  @override
  String get destroyRoom => '⚠️ Уничтожить комнату';

  @override
  String get warningDestroyRoom =>
      'Это действие навсегда уничтожит чат-комнату для обоих пользователей.\\n\\nБудет запущен 10-секундный обратный отсчет, видимый обоим участникам.';

  @override
  String get cancel => 'Отмена';

  @override
  String get audioNote => 'Аудиозаметка';

  @override
  String get recordedAudioNote => 'Аудиозаметка (записанная)';

  @override
  String get playing => 'Воспроизведение...';

  @override
  String get tapToStop => 'Нажмите, чтобы остановить';

  @override
  String get tapToPlay => 'Нажмите, чтобы воспроизвести';

  @override
  String get image => 'Изображение';

  @override
  String get backToMultipleChats => 'Вернуться к множественным чатам';

  @override
  String get backToChat => 'Вернуться в чат';

  @override
  String get screenshotsBlockedAutomatically =>
      'Скриншоты ЗАБЛОКИРОВАНЫ автоматически';

  @override
  String get screenshotsEnabled => 'Скриншоты ВКЛЮЧЕНЫ';

  @override
  String get identityVerifiedCorrectly =>
      'Личность партнера успешно верифицирована';

  @override
  String get createAccount => 'Создать аккаунт';

  @override
  String get registerSubtitle =>
      'Зарегистрируйтесь, чтобы начать использовать FlutterPutter';

  @override
  String get nickname => 'Никнейм';

  @override
  String get chooseUniqueNickname => 'Выберите уникальный никнейм';

  @override
  String get createSecurePassword => 'Создайте надежный пароль';

  @override
  String get confirmPassword => 'Подтвердить пароль';

  @override
  String get repeatPassword => 'Повторите ваш пароль';

  @override
  String get invitationCode => 'Код приглашения';

  @override
  String get enterInvitationCode => 'Введите ваш код приглашения';

  @override
  String get registerButton => 'Зарегистрироваться';

  @override
  String get pleaseConfirmPassword => 'Пожалуйста, подтвердите ваш пароль';

  @override
  String get passwordsDoNotMatch => 'Пароли не совпадают';

  @override
  String get pleaseEnterNickname => 'Пожалуйста, введите никнейм';

  @override
  String get nicknameMinLength =>
      'Никнейм должен содержать не менее 3 символов';

  @override
  String get pleaseEnterInvitationCode => 'Пожалуйста, введите код приглашения';

  @override
  String get invitationCodeLength => 'Код должен содержать 8 символов';

  @override
  String get newChatInvitationReceived => '📩 Получено новое приглашение в чат';

  @override
  String get view => 'Посмотреть';

  @override
  String get chatInvitations => 'Приглашения в чат';

  @override
  String get securitySettingsTooltip => 'Настройки безопасности';

  @override
  String helloUser(String nickname) {
    return 'Привет, $nickname';
  }

  @override
  String get searchUsersToVideoCall =>
      'Найдите пользователей, чтобы начать видеозвонок';

  @override
  String get searchUsersButton => 'Поиск пользователей';

  @override
  String get testIdentityVerification => 'Протестировать верификацию личности';

  @override
  String get ephemeralChat => '💬 Эфемерный чат';

  @override
  String get multipleSimultaneousRooms =>
      'Несколько одновременных комнат (макс. 10)';

  @override
  String get logout => 'Выйти';

  @override
  String get logoutConfirmTitle => 'Выйти';

  @override
  String get logoutConfirmMessage => 'Вы уверены, что хотите выйти?';

  @override
  String get helpSection => 'Помощь и Поддержка';

  @override
  String get supportCenter => 'Центр поддержки';

  @override
  String get supportCenterDescription =>
      'Получите помощь и ознакомьтесь с часто задаваемыми вопросами';

  @override
  String get contactUs => 'Свяжитесь с нами';

  @override
  String get contactUsDescription =>
      'Отправьте нам электронное письмо, чтобы разрешить ваши сомнения';

  @override
  String get contactEmail => 'FlutterPutter@Proton.me';

  @override
  String get appVersion => 'Версия';

  @override
  String get versionNumber => 'Версия 1.0 Бета';

  @override
  String get termsAndConditions => 'Условия и положения';

  @override
  String get termsDescription => 'Прочтите наши условия обслуживания';

  @override
  String get privacyPolicy => 'Политика конфиденциальности';

  @override
  String get privacyPolicyDescription =>
      'Узнайте, как мы защищаем вашу информацию';

  @override
  String get emailCopied => 'Электронная почта скопирована в буфер обмена';

  @override
  String get openingWebPage => 'Открытие веб-страницы...';

  @override
  String get errorOpeningWebPage => 'Ошибка при открытии веб-страницы';

  @override
  String get pinLengthError => 'PIN-код должен содержать от 4 до 15 символов';

  @override
  String get pinMismatch => 'PIN-коды не совпадают';

  @override
  String get appLockSetupSuccess =>
      '🔒 Блокировка приложения успешно настроена';

  @override
  String get pinSetupError => 'Ошибка настройки PIN-кода';

  @override
  String get pinChangeSuccess => '🔒 PIN-код успешно изменен';

  @override
  String get currentPinIncorrect => 'Текущий PIN-код неверен';

  @override
  String get disableAppLockTitle => 'Отключить блокировку';

  @override
  String get disableAppLockMessage =>
      'Вы уверены, что хотите отключить блокировку приложения?';

  @override
  String get appLockDisabled => '🔓 Блокировка приложения отключена';

  @override
  String get confirm => 'Подтвердить';

  @override
  String get changePin => 'Изменить PIN-код:';

  @override
  String get currentPin => 'Текущий PIN-код';

  @override
  String get confirmNewPin => 'Подтвердить новый PIN-код';

  @override
  String get changePinButton => 'Изменить PIN-код';

  @override
  String get biometricUnlock =>
      'Разблокируйте приложение с помощью биометрии в дополнение к PIN-коду';

  @override
  String get screenshotsAllowedMessage => '🔓 Скриншоты РАЗРЕШЕНЫ';

  @override
  String get screenshotsBlockedMessage => '🔒 Скриншоты ЗАБЛОКИРОВАНЫ';

  @override
  String get screenshotConfigError =>
      'Ошибка обновления конфигурации скриншотов';

  @override
  String get protectionActive => 'Защита активна';

  @override
  String get nativeProtectionFeatures =>
      '• Нативная блокировка на iOS и Android\n• Оповещение при обнаружении попыток захвата экрана\n• Защита в переключателе приложений';

  @override
  String get autoDestructionDefaultDisabled =>
      '🔥 Автоудаление по умолчанию отключено';

  @override
  String get autoDestructionError =>
      'Ошибка обновления конфигурации автоудаления';

  @override
  String get protectYourApp => 'Защитите ваше приложение';

  @override
  String get securityPinDescription =>
      'Установите PIN-код безопасности для защиты вашей конфиденциальности. Уведомления будут поступать, даже если приложение заблокировано.';

  @override
  String get lockActivated => 'Блокировка активирована';

  @override
  String get disable => 'Отключить';

  @override
  String get errorCopyingEmail => 'Ошибка при копировании электронной почты';

  @override
  String get automaticLockTimeout => 'Время автоматической блокировки';

  @override
  String get appWillLockAfter =>
      'Приложение будет автоматически заблокировано через:';

  @override
  String get biometricAuthentication => 'Биометрическая аутентификация';

  @override
  String get enableBiometric => 'Включить отпечаток пальца/Face ID';

  @override
  String get autoApplyDefault => 'Применять автоматически';

  @override
  String get autoApplyEnabled =>
      'Будет применяться при присоединении к новым комнатам';

  @override
  String get autoApplyDisabled => 'Применять вручную только в каждой комнате';

  @override
  String get currentConfiguration => 'Текущая конфигурация';

  @override
  String get sessionActive => 'активная сессия';

  @override
  String get sessionsActive => 'активные сессии';

  @override
  String get noActiveSessionsMessage =>
      'Нет зарегистрированных активных сессий';

  @override
  String get helpAndSupport =>
      'Получите помощь, свяжитесь с нами или ознакомьтесь с нашими политиками';

  @override
  String get autoDestructionDefaultEnabled => '🔥 Автоудаление по умолчанию: ';

  @override
  String get verificationDemonstration => 'Демонстрация верификации';

  @override
  String get roomLabel => 'Комната:';

  @override
  String get userLabel => 'Пользователь:';

  @override
  String get statusVerified => 'Статус: Верифицировано ✅';

  @override
  String get identityVerifiedCorrect => 'Личность успешно верифицирована';

  @override
  String get identityVerifiedFull => '✅ Личность верифицирована';

  @override
  String get bothUsersVerified =>
      'Оба пользователя верифицировали свою личность';

  @override
  String get yourVerificationCodes => 'ВАШИ КОДЫ ВЕРИФИКАЦИИ';

  @override
  String get shareCodeMessage =>
      'Поделитесь ОДНИМ из этих кодов через другой канал (WhatsApp, Telegram и т.д.)';

  @override
  String get hideCodesBut => '🙈 Скрыть коды';

  @override
  String get alphanumericCode => '🔤 Буквенно-цифровой';

  @override
  String get numericCode => '🔢 Цифровой';

  @override
  String get emojiCode => '😀 Эмодзи';

  @override
  String get enterCodeToVerify => '❌ Введите код для проверки';

  @override
  String get invalidCodeFormat => '❌ Неверный формат кода';

  @override
  String get identityVerifiedSuccess => '✅ Личность успешно верифицирована!';

  @override
  String get incorrectCode => '❌ Неверный код';

  @override
  String get codesRegenerated => '🔄 Коды перегенерированы';

  @override
  String get codeCopied => '📋 Код скопирован в буфер обмена';

  @override
  String get partnerCodesReceived => '📥 Коды партнера получены';

  @override
  String get codesSentToPartner => '📤 Коды отправлены партнеру';

  @override
  String get resendingCodes => '🔄 Повторная отправка кодов партнеру...';

  @override
  String get stepExpandVerification =>
      'Нажмите на \"🔐 Верификация личности\", чтобы развернуть';

  @override
  String get stepShowCodes =>
      'Нажмите \"👁️ Показать мои коды\", чтобы увидеть ваши уникальные коды';

  @override
  String get stepPasteCode => 'Вставьте код в \"ПРОВЕРИТЬ КОД ПАРТНЕРА\"';

  @override
  String get stepVerifyCode =>
      'Нажмите \"✅ Проверить\", чтобы симулировать верификацию';

  @override
  String get enterPartnerCode =>
      'Введите код, которым поделился с вами другой человек:';

  @override
  String get partnerCodesReceivedWithCode => '✅ Коды партнера получены:';

  @override
  String get waitingPartnerCodes => '⏳ Ожидание кодов партнера...';

  @override
  String get verificationSuccessMessage =>
      'Личность успешно верифицирована! Оба пользователя подлинны.';

  @override
  String get chatInvitationsTitle => 'Приглашения в чат';

  @override
  String get cleanExpiredInvitations => 'Очистить истекшие приглашения';

  @override
  String get refreshInvitations => 'Обновить приглашения';

  @override
  String errorInitializing(String error) {
    return 'Ошибка инициализации: $error';
  }

  @override
  String expiredInvitationsDeleted(int count) {
    return '$count истекших приглашений удалено навсегда';
  }

  @override
  String get noExpiredInvitationsToClean =>
      'Нет истекших приглашений для очистки';

  @override
  String errorAcceptingInvitation(String error) {
    return 'Ошибка принятия приглашения: $error';
  }

  @override
  String errorUpdatingInvitations(String error) {
    return 'Ошибка обновления приглашений: $error';
  }

  @override
  String invitationsUpdated(int active, int expired) {
    return 'Обновлено: $active активных, $expired истекших удалено';
  }

  @override
  String invitationsUpdatedActive(int active) {
    return 'Обновлено: $active активных приглашений';
  }

  @override
  String get noInvitations => 'Нет приглашений';

  @override
  String get invitationsWillAppearHere => 'Приглашения в чат появятся здесь';

  @override
  String get chatInvitation => 'Приглашение в чат';

  @override
  String fromUser(String userId) {
    return 'От: $userId';
  }

  @override
  String get expired => 'Истекло';

  @override
  String get reject => 'Отклонить';

  @override
  String get accept => 'Принять';

  @override
  String get tapToCreateOrJoinEphemeralChats =>
      'Нажмите, чтобы создать эфемерные чаты или присоединиться к ним';

  @override
  String get now => 'Сейчас';

  @override
  String get callEnded => 'Звонок завершен';

  @override
  String get videoCallFeatureAvailable => '🎥 Функция видеозвонка доступна';

  @override
  String get pendingInvitations => 'Ожидающие приглашения';

  @override
  String chatInvitationsCount(int count) {
    return '$count приглашений в чат';
  }

  @override
  String get searching => 'Поиск...';

  @override
  String get noUsersFound => 'Пользователи не найдены';

  @override
  String get errorSearchingUsers => 'Ошибка при поиске пользователей';

  @override
  String get startVideoCall => 'Начать видеозвонок';

  @override
  String get startAudioCall => 'Начать аудиозвонок';

  @override
  String confirmVideoCall(String nickname) {
    return 'Хотите начать видеозвонок с $nickname?';
  }

  @override
  String confirmAudioCall(String nickname) {
    return 'Хотите начать аудиозвонок с $nickname?';
  }

  @override
  String get initiatingVideoCall => 'Начало видеозвонка...';

  @override
  String get initiatingAudioCall => 'Начало аудиозвонка...';

  @override
  String get sendingInvitation => 'Отправка приглашения...';

  @override
  String get errorInitiatingCall => 'Ошибка при начале звонка';

  @override
  String get waitingForResponse => 'Ожидание ответа...';

  @override
  String get invitationSentTo => 'Приглашение отправлено';

  @override
  String get waitingForAcceptance => 'Ожидание принятия приглашения...';

  @override
  String get ephemeralChatTooltip => 'Эфемерный чат';

  @override
  String get audioCallTooltip => 'Звонок';

  @override
  String get videoCallTooltip => 'Видео';

  @override
  String get searchUser => 'Поиск пользователя';

  @override
  String get retry => 'Повторить';

  @override
  String get searchingUsers => 'Поиск пользователей...';

  @override
  String noUsersFoundWith(String query) {
    return 'Пользователи с \"$query\"\\nне найдены';
  }

  @override
  String errorSearchingUsersDetails(String error) {
    return 'Ошибка поиска пользователей: $error';
  }

  @override
  String multipleChatsTitle(int count) {
    return 'Множественные чаты ($count/10)';
  }

  @override
  String get backToHome => 'Вернуться на главный экран';

  @override
  String get closeAllRooms => 'Закрыть все комнаты';

  @override
  String get closeAllRoomsConfirm =>
      'Вы уверены, что хотите закрыть все чат-комнаты?';

  @override
  String get closeAll => 'Закрыть все';

  @override
  String participants(int count) {
    return '$count участников';
  }

  @override
  String roomActive(int count) {
    return 'Активная комната ($count участников)';
  }

  @override
  String get noConnection => 'Нет подключения';

  @override
  String get createNewRoom => 'Создать новую комнату';

  @override
  String get addChat => 'Добавить чат';

  @override
  String get statistics => 'Статистика';

  @override
  String get chatStatisticsTitle => 'Статистика чата';

  @override
  String get activeRooms => 'Активные комнаты';

  @override
  String get totalMessages => 'Всего сообщений';

  @override
  String get unreadMessages => 'Непрочитанные';

  @override
  String get initiatingChat => 'Начало чата...';

  @override
  String errorClosingRoom(String error) {
    return 'Ошибка при закрытии комнаты: $error';
  }

  @override
  String get invitationAccepted => '✅ Приглашение принято';

  @override
  String errorAcceptingInvitationDetails(String error) {
    return 'Ошибка принятия приглашения: $error';
  }

  @override
  String errorCreatingRoom(String error) {
    return 'Ошибка создания комнаты: $error';
  }

  @override
  String get createNewChatRoom => 'Создать новую чат-комнату';

  @override
  String get minutes => 'минут';

  @override
  String get seconds => 'секунд';

  @override
  String get microphonePermissions => '🎵 Разрешения для микрофона';

  @override
  String get microphonePermissionsContent =>
      'Для записи аудио необходимо включить разрешения для микрофона в настройках приложения.\n\nПерейдите в Настройки > Конфиденциальность > Микрофон и включите разрешения для этого приложения.';

  @override
  String get openSettings => 'Открыть настройки';

  @override
  String errorInitializingAudio(String error) {
    return 'Ошибка инициализации аудио: $error';
  }

  @override
  String get imageTooLarge =>
      'Изображение слишком большое. Максимально допустимый размер 500 КБ.';

  @override
  String errorSendingImage(String error) {
    return 'Ошибка отправки изображения: $error';
  }

  @override
  String errorSendingAudio(String error) {
    return 'Ошибка отправки аудио: $error';
  }

  @override
  String get destroyRoomContent =>
      'Это действие навсегда уничтожит чат-комнату для обоих пользователей.\\n\\nБудет запущен 10-секундный обратный отсчет, видимый обоим участникам.';

  @override
  String get destroyRoomButton => 'Уничтожить комнату';

  @override
  String get connectingToSecureChat => 'Подключение к безопасному чату...';

  @override
  String get autoDestructionConfigured1Min =>
      'Автоудаление настроено: 1 минута';

  @override
  String get autoDestructionConfigured5Min => 'Автоудаление настроено: 5 минут';

  @override
  String get autoDestructionConfigured1Hour => 'Автоудаление настроено: 1 час';

  @override
  String screenshotAlert(String user) {
    return '📸 Внимание! $user сделал скриншот';
  }

  @override
  String screenshotNotification(String user) {
    return '📸 $user сделал скриншот';
  }

  @override
  String get initializingAudioRecorder => 'Инициализация аудиорекордера...';

  @override
  String get audioRecorderNotAvailable =>
      'Аудиорекордер недоступен. Проверьте разрешения для микрофона.';

  @override
  String errorStartingRecording(String error) {
    return 'Ошибка начала записи: $error';
  }

  @override
  String get audioPlayerNotAvailable => 'Аудиоплеер недоступен';

  @override
  String get audioNotAvailable => 'Аудио недоступно';

  @override
  String errorPlayingAudio(String error) {
    return 'Ошибка воспроизведения аудио: $error';
  }

  @override
  String get screenshotTestSent => '📸 Тест скриншота отправлен';

  @override
  String errorSendingTest(String error) {
    return 'Ошибка отправки теста: $error';
  }

  @override
  String get audioTooLong =>
      'Аудио слишком длинное. Максимально допустимый размер 1 МБ.';

  @override
  String get errorWebAudioRecording =>
      'Ошибка: не удалось записать аудио в веб-версии';

  @override
  String get errorWebAudioSaving => 'Ошибка: не удалось сохранить аудио';

  @override
  String errorStoppingRecording(String error) {
    return 'Ошибка остановки записи: $error';
  }

  @override
  String get sendEncryptedImageTooltip => 'Отправить зашифрованное изображение';

  @override
  String get myProfile => 'Мой профиль';

  @override
  String get dangerZone => 'Опасная зона';

  @override
  String get dangerZoneDescription =>
      'Это действие навсегда удалит вашу учетную запись и все ваши данные. Вы не сможете восстановить свою учетную запись после удаления.';

  @override
  String get destroyMyAccount => 'Удалить мою учетную запись';

  @override
  String get warningTitle => 'Предупреждение!';

  @override
  String get destroyAccountWarning =>
      'Вы собираетесь навсегда удалить свою учетную запись.';

  @override
  String get thisActionWill => 'Это действие:';

  @override
  String get deleteAllData => '• Удалит все ваши данные';

  @override
  String get closeAllSessions => '• Закроет все ваши активные сессии';

  @override
  String get deleteChatHistory => '• Удалит вашу историю чатов';

  @override
  String get cannotBeUndone => '• Не может быть отменено';

  @override
  String get neverAccessAgain =>
      'После удаления вы никогда не сможете получить доступ к этой учетной записи.';

  @override
  String get continueButton => 'Продолжить';

  @override
  String get finalConfirmation => 'Финальное подтверждение';

  @override
  String get confirmDestructionText =>
      'Чтобы подтвердить удаление вашей учетной записи, введите:';

  @override
  String get typeConfirmation => 'Введите подтверждение';

  @override
  String get destroyAccount => 'Удалить учетную запись';

  @override
  String get functionalityInDevelopment => 'Функциональность в разработке';

  @override
  String get accountDestructionAvailable =>
      'Удаление учетной записи будет доступно в ближайшем обновлении. Ваш запрос зарегистрирован.';
}
