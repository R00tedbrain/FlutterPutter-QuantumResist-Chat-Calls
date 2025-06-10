// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'فلاتر باتر';

  @override
  String get loginTitle => 'سجل الدخول للمتابعة';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get enterEmail => 'أدخل بريدك الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get enterPassword => 'أدخل كلمة المرور الخاصة بك';

  @override
  String get pleaseEnterEmail => 'من فضلك أدخل بريدك الإلكتروني';

  @override
  String get enterValidEmail => 'أدخل بريدًا إلكترونيًا صالحًا';

  @override
  String get pleaseEnterPassword => 'من فضلك أدخل كلمة المرور';

  @override
  String get passwordMinLength =>
      'يجب أن تتكون كلمة المرور من 6 أحرف على الأقل';

  @override
  String get loginButton => 'تسجيل الدخول';

  @override
  String get noAccount => 'ليس لديك حساب؟';

  @override
  String get register => 'سجل';

  @override
  String get oneSessionSecurity =>
      '🔒 يُسمح بجلسة نشطة واحدة فقط لكل مستخدم لمزيد من الأمان';

  @override
  String get oneSessionMaxSecurity =>
      'جلسة واحدة فقط لكل مستخدم (أقصى درجات الأمان)';

  @override
  String get privacyAndSecurity => 'الخصوصية والأمان';

  @override
  String get noDataCollection => 'نحن لا نجمع بيانات شخصية';

  @override
  String get anonymousConnections => 'جميع الاتصالات مجهولة المصدر';

  @override
  String get ephemeralChatRooms =>
      'غرف دردشة سريعة الزوال يتم تدميرها تلقائيًا';

  @override
  String get encryptionInfo => 'تشفير XSalsa20 بمفاتيح عشوائية لكل غرفة';

  @override
  String get chats => 'الدردشات';

  @override
  String get secureChat => 'دردشة آمنة';

  @override
  String get secureChatDescription =>
      'انقر لإنشاء أو الانضمام إلى الدردشات سريعة الزوال';

  @override
  String get privateVideoCall => 'مكالمة فيديو خاصة';

  @override
  String get videoCallDescription => 'انتهت المكالمة';

  @override
  String get multipleChats => 'دردشات متعددة';

  @override
  String get newRoom => 'غرفة جديدة';

  @override
  String get noActiveChats => 'لا توجد دردشات نشطة';

  @override
  String get useNewRoomButton =>
      'استخدم علامة التبويب \'غرفة جديدة\' لإنشاء دردشة';

  @override
  String get searchUsers => 'بحث عن المستخدمين';

  @override
  String get searchByNickname => 'بحث بالاسم المستعار';

  @override
  String get calls => 'المكالمات';

  @override
  String get verification => 'التحقق';

  @override
  String get verificationDemo => '🔐 عرض توضيحي للتحقق';

  @override
  String get verificationDemoDescription =>
      'هذا عرض توضيحي لنظام التحقق من الهوية المجهول. في التنفيذ الحقيقي، سيتم دمج هذه الأداة في غرف الدردشة سريعة الزوال.';

  @override
  String get room => 'الغرفة';

  @override
  String get user => 'المستخدم';

  @override
  String get identityVerification => 'التحقق من الهوية';

  @override
  String get verifyIdentityDescription => 'انقر للتحقق من الهوية بشكل مجهول';

  @override
  String get statusNotVerified => 'الحالة: لم يتم التحقق';

  @override
  String get notVerifiedYet => 'لم يتم التحقق من الهوية بعد';

  @override
  String get howToTest => 'كيفية اختبار التحقق';

  @override
  String get step1 => 'اضغط على';

  @override
  String get step2 => 'اضغط';

  @override
  String get step3 => 'انسخ أحد الرموز (أبجدي رقمي، رقمي، أو إيموجي)';

  @override
  String get step4 => 'الصق الرمز في';

  @override
  String get step5 => 'اضغط';

  @override
  String get showMyCodes => 'عرض رموزي';

  @override
  String get verifyPartnerCode => 'التحقق من رمز الشريك';

  @override
  String get verify => 'تحقق';

  @override
  String get realUsage =>
      'في الاستخدام الحقيقي: سيشارك المستخدمون الرموز عبر WhatsApp، Telegram، إلخ.';

  @override
  String get securitySettings => 'إعدادات الأمان';

  @override
  String get securitySettingsDescription =>
      'قم بتكوين رقم تعريف شخصي (PIN) للأمان لحماية خصوصيتك. ستستمر الإشعارات في الوصول حتى إذا كان التطبيق مقفلاً.';

  @override
  String get configureAppLock => 'تكوين قفل التطبيق';

  @override
  String get newPin => 'رقم تعريف شخصي جديد (4-15 حرفًا)';

  @override
  String get confirmPin => 'تأكيد رقم التعريف الشخصي';

  @override
  String get activateLock => 'تفعيل القفل';

  @override
  String get screenshotSecurity => 'أمان لقطات الشاشة';

  @override
  String get screenshotSecurityDescription =>
      'تحكم فيما إذا كان يمكن التقاط لقطات شاشة للتطبيق.';

  @override
  String get allowScreenshots => 'السماح بلقطات الشاشة';

  @override
  String get screenshotsAllowed => 'لقطات الشاشة مسموح بها';

  @override
  String get screenshotsDisabled => 'يمكنك تعطيلها لمزيد من الأمان';

  @override
  String get autoDestructionDefault => 'التدمير الذاتي الافتراضي';

  @override
  String get autoDestructionDescription =>
      'قم بتكوين وقت تدمير ذاتي سيتم تطبيقه تلقائيًا عند الانضمام إلى غرف دردشة جديدة:';

  @override
  String get defaultTime => 'الوقت الافتراضي:';

  @override
  String get noLimit => 'بلا حدود';

  @override
  String get selectTime =>
      'حدد وقتًا لتمكين التدمير الذاتي الافتراضي. سيتم حذف الرسائل تلقائيًا بعد الوقت الذي تم تكوينه.';

  @override
  String get activeSessions => 'الجلسات النشطة';

  @override
  String get activeSessionsDescription =>
      'إدارة الأجهزة التي لديك فيها جلسات مفتوحة. مشابه لـ Signal و WhatsApp.';

  @override
  String get currentState => 'الحالة الحالية';

  @override
  String get noActiveSessionsRegistered => '0 جلسات نشطة مسجلة';

  @override
  String get multipleSessions => 'جلسات متعددة: معطلة';

  @override
  String get configurationLikeSignal => 'وتكوين مثل Signal';

  @override
  String get manageSessions => 'إدارة الجلسات';

  @override
  String get allowMultipleSessions => 'السماح بجلسات متعددة';

  @override
  String get onlyOneActiveSession =>
      'جلسة نشطة واحدة فقط في كل مرة (مثل Signal)';

  @override
  String get searchByName => 'بحث بالاسم...';

  @override
  String get writeAtLeast2Characters =>
      'اكتب حرفين على الأقل للبحث عن المستخدمين';

  @override
  String get connecting => 'جارٍ الاتصال...';

  @override
  String get error => 'خطأ';

  @override
  String get secureMultimediaChat => 'دردشة وسائط متعددة آمنة';

  @override
  String get sendEncryptedMessages =>
      'أرسل رسائل وصورًا\\nمشفرة باستخدام XChaCha20-Poly1305';

  @override
  String get encryptedMessage => 'رسالة مشفرة...';

  @override
  String get sendEncryptedImage => '📷 إرسال صورة مشفرة';

  @override
  String get takePhoto => 'التقاط صورة';

  @override
  String get useCamera => 'استخدام الكاميرا';

  @override
  String get gallery => 'المعرض';

  @override
  String get selectImage => 'تحديد صورة';

  @override
  String get capturesBlocked => 'التقاطات محظورة';

  @override
  String get capturesAllowed => 'التقاطات مسموح بها';

  @override
  String get e2eEncryptionSecurity => 'تشفير من طرف إلى طرف + أمان';

  @override
  String get encryptionDescription =>
      'جميع الرسائل والصور والصوتيات مشفرة محليًا باستخدام XChaCha20-Poly1305.\\n\\nيرى الخادم فقط كتل بيانات مشفرة معتمة.\\n\\nتم تنفيذ الصوت مع تسجيل حقيقي.';

  @override
  String get screenshotsStatus => 'لقطات الشاشة:';

  @override
  String get screenshotsBlocked => 'محظورة';

  @override
  String get screenshotsPermitted => 'مسموح بها';

  @override
  String get likeWhatsAppTelegram =>
      'مثل WhatsApp/Telegram - شاشة سوداء في لقطات الشاشة';

  @override
  String get understood => 'مفهوم';

  @override
  String get destroyRoom => '⚠️ تدمير الغرفة';

  @override
  String get warningDestroyRoom =>
      'سيؤدي هذا الإجراء إلى تدمير غرفة الدردشة بشكل دائم لكلا المستخدمين.\\n\\nسيبدأ عد تنازلي لمدة 10 ثوانٍ مرئي لكلا المشاركين.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get audioNote => 'ملاحظة صوتية';

  @override
  String get recordedAudioNote => 'ملاحظة صوتية (مسجلة)';

  @override
  String get playing => 'قيد التشغيل...';

  @override
  String get tapToStop => 'انقر للتوقف';

  @override
  String get tapToPlay => 'انقر للتشغيل';

  @override
  String get image => 'صورة';

  @override
  String get backToMultipleChats => 'العودة إلى الدردشات المتعددة';

  @override
  String get backToChat => 'العودة إلى الدردشة';

  @override
  String get screenshotsBlockedAutomatically => 'لقطات الشاشة محظورة تلقائيًا';

  @override
  String get screenshotsEnabled => 'لقطات الشاشة مفعلة';

  @override
  String get identityVerifiedCorrectly => 'تم التحقق من هوية الشريك بنجاح';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get registerSubtitle => 'سجل لتبدأ في استخدام FlutterPutter';

  @override
  String get nickname => 'الاسم المستعار';

  @override
  String get chooseUniqueNickname => 'اختر اسمًا مستعارًا فريدًا';

  @override
  String get createSecurePassword => 'أنشئ كلمة مرور آمنة';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get repeatPassword => 'كرر كلمة المرور الخاصة بك';

  @override
  String get invitationCode => 'رمز الدعوة';

  @override
  String get enterInvitationCode => 'أدخل رمز الدعوة الخاص بك';

  @override
  String get registerButton => 'تسجيل';

  @override
  String get pleaseConfirmPassword => 'يرجى تأكيد كلمة المرور الخاصة بك';

  @override
  String get passwordsDoNotMatch => 'كلمات المرور غير متطابقة';

  @override
  String get pleaseEnterNickname => 'يرجى إدخال اسم مستعار';

  @override
  String get nicknameMinLength =>
      'يجب أن يتكون الاسم المستعار من 3 أحرف على الأقل';

  @override
  String get pleaseEnterInvitationCode => 'يرجى إدخال رمز دعوة';

  @override
  String get invitationCodeLength => 'يجب أن يتكون الرمز من 8 أحرف';

  @override
  String get newChatInvitationReceived => '📩 تم استلام دعوة دردشة جديدة';

  @override
  String get view => 'عرض';

  @override
  String get chatInvitations => 'دعوات الدردشة';

  @override
  String get securitySettingsTooltip => 'إعدادات الأمان';

  @override
  String helloUser(String nickname) {
    return 'مرحبًا، $nickname';
  }

  @override
  String get searchUsersToVideoCall => 'ابحث عن مستخدمين لبدء مكالمة فيديو';

  @override
  String get searchUsersButton => 'بحث عن المستخدمين';

  @override
  String get testIdentityVerification => 'اختبار التحقق من الهوية';

  @override
  String get ephemeralChat => '💬 دردشة سريعة الزوال';

  @override
  String get multipleSimultaneousRooms => 'غرف متزامنة متعددة (بحد أقصى 10)';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get logoutConfirmTitle => 'تسجيل الخروج';

  @override
  String get logoutConfirmMessage => 'هل أنت متأكد أنك تريد تسجيل الخروج؟';

  @override
  String get helpSection => 'المساعدة والدعم';

  @override
  String get supportCenter => 'مركز المساعدة';

  @override
  String get supportCenterDescription =>
      'احصل على المساعدة واطلع على الأسئلة الشائعة';

  @override
  String get contactUs => 'اتصل بنا';

  @override
  String get contactUsDescription => 'أرسل لنا بريدًا إلكترونيًا لحل شكوكك';

  @override
  String get contactEmail => 'FlutterPutter@Proton.me';

  @override
  String get appVersion => 'الإصدار';

  @override
  String get versionNumber => 'الإصدار 1.0 تجريبي';

  @override
  String get termsAndConditions => 'الشروط والأحكام';

  @override
  String get termsDescription => 'اقرأ شروط الخدمة الخاصة بنا';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get privacyPolicyDescription => 'راجع كيف نحمي معلوماتك';

  @override
  String get emailCopied => 'تم نسخ البريد الإلكتروني إلى الحافظة';

  @override
  String get openingWebPage => 'جارٍ فتح صفحة الويب...';

  @override
  String get errorOpeningWebPage => 'خطأ في فتح صفحة الويب';

  @override
  String get pinLengthError =>
      'يجب أن يتكون رقم التعريف الشخصي من 4 إلى 15 حرفًا';

  @override
  String get pinMismatch => 'أرقام التعريف الشخصية غير متطابقة';

  @override
  String get appLockSetupSuccess => '🔒 تم تكوين قفل التطبيق بنجاح';

  @override
  String get pinSetupError => 'خطأ في تكوين رقم التعريف الشخصي';

  @override
  String get pinChangeSuccess => '🔒 تم تغيير رقم التعريف الشخصي بنجاح';

  @override
  String get currentPinIncorrect => 'رقم التعريف الشخصي الحالي غير صحيح';

  @override
  String get disableAppLockTitle => 'تعطيل القفل';

  @override
  String get disableAppLockMessage =>
      'هل أنت متأكد أنك تريد تعطيل قفل التطبيق؟';

  @override
  String get appLockDisabled => '🔓 تم تعطيل قفل التطبيق';

  @override
  String get confirm => 'تأكيد';

  @override
  String get changePin => 'تغيير رقم التعريف الشخصي:';

  @override
  String get currentPin => 'رقم التعريف الشخصي الحالي';

  @override
  String get confirmNewPin => 'تأكيد رقم التعريف الشخصي الجديد';

  @override
  String get changePinButton => 'تغيير رقم التعريف الشخصي';

  @override
  String get biometricUnlock =>
      'افتح التطبيق باستخدام القياسات الحيوية بالإضافة إلى رقم التعريف الشخصي';

  @override
  String get screenshotsAllowedMessage => '🔓 لقطات الشاشة مسموح بها';

  @override
  String get screenshotsBlockedMessage => '🔒 لقطات الشاشة محظورة';

  @override
  String get screenshotConfigError => 'خطأ في تحديث تكوين لقطات الشاشة';

  @override
  String get protectionActive => 'الحماية نشطة';

  @override
  String get nativeProtectionFeatures =>
      '• قفل أصلي على iOS و Android\n• تنبيه عند اكتشاف محاولات التقاط\n• حماية في مبدل التطبيقات';

  @override
  String get autoDestructionDefaultDisabled =>
      '🔥 تم تعطيل التدمير الذاتي الافتراضي';

  @override
  String get autoDestructionError => 'خطأ في تحديث تكوين التدمير الذاتي';

  @override
  String get protectYourApp => 'احمِ تطبيقك';

  @override
  String get securityPinDescription =>
      'قم بتكوين رقم تعريف شخصي (PIN) للأمان لحماية خصوصيتك. ستستمر الإشعارات في الوصول حتى إذا كان التطبيق مقفلاً.';

  @override
  String get lockActivated => 'تم تفعيل القفل';

  @override
  String get disable => 'تعطيل';

  @override
  String get errorCopyingEmail => 'خطأ في نسخ البريد الإلكتروني';

  @override
  String get automaticLockTimeout => 'مهلة القفل التلقائي';

  @override
  String get appWillLockAfter => 'سيتم قفل التطبيق تلقائيًا بعد:';

  @override
  String get biometricAuthentication => 'المصادقة البيومترية';

  @override
  String get enableBiometric => 'تمكين بصمة الإصبع/معرف الوجه';

  @override
  String get autoApplyDefault => 'تطبيق تلقائي';

  @override
  String get autoApplyEnabled => 'سيتم تطبيقه عند الانضمام إلى غرف جديدة';

  @override
  String get autoApplyDisabled => 'تطبيق يدوي فقط في كل غرفة';

  @override
  String get currentConfiguration => 'التكوين الحالي';

  @override
  String get sessionActive => 'جلسة نشطة';

  @override
  String get sessionsActive => 'جلسات نشطة';

  @override
  String get noActiveSessionsMessage => 'لا توجد جلسات نشطة مسجلة';

  @override
  String get helpAndSupport => 'احصل على المساعدة، اتصل بنا، أو راجع سياساتنا';

  @override
  String get autoDestructionDefaultEnabled => '🔥 التدمير الذاتي الافتراضي: ';

  @override
  String get verificationDemonstration => 'عرض توضيحي للتحقق';

  @override
  String get roomLabel => 'الغرفة:';

  @override
  String get userLabel => 'المستخدم:';

  @override
  String get statusVerified => 'الحالة: تم التحقق ✅';

  @override
  String get identityVerifiedCorrect => 'تم التحقق من الهوية بنجاح';

  @override
  String get identityVerifiedFull => '✅ الهوية محققة';

  @override
  String get bothUsersVerified => 'كلا المستخدمين قد تحققا من هويتهما';

  @override
  String get yourVerificationCodes => 'رموز التحقق الخاصة بك';

  @override
  String get shareCodeMessage =>
      'شارك أحد هذه الرموز عبر قناة أخرى (WhatsApp، Telegram، إلخ.)';

  @override
  String get hideCodesBut => '🙈 إخفاء الرموز';

  @override
  String get alphanumericCode => '🔤 أبجدي رقمي';

  @override
  String get numericCode => '🔢 رقمي';

  @override
  String get emojiCode => '😀 إيموجي';

  @override
  String get enterCodeToVerify => '❌ أدخل رمزًا للتحقق';

  @override
  String get invalidCodeFormat => '❌ تنسيق الرمز غير صالح';

  @override
  String get identityVerifiedSuccess => '✅ تم التحقق من الهوية بنجاح!';

  @override
  String get incorrectCode => '❌ رمز غير صحيح';

  @override
  String get codesRegenerated => '🔄 تم إعادة إنشاء الرموز';

  @override
  String get codeCopied => '📋 تم نسخ الرمز إلى الحافظة';

  @override
  String get partnerCodesReceived => '📥 تم استلام رموز الشريك';

  @override
  String get codesSentToPartner => '📤 تم إرسال الرموز إلى الشريك';

  @override
  String get resendingCodes => '🔄 إعادة إرسال الرموز إلى الشريك...';

  @override
  String get stepExpandVerification =>
      'اضغط على \"🔐 التحقق من الهوية\" للتوسيع';

  @override
  String get stepShowCodes => 'اضغط على \"👁️ عرض رموزي\" لرؤية رموزك الفريدة';

  @override
  String get stepPasteCode => 'الصق الرمز في \"التحقق من رمز الشريك\"';

  @override
  String get stepVerifyCode => 'اضغط على \"✅ تحقق\" لمحاكاة التحقق';

  @override
  String get enterPartnerCode => 'أدخل الرمز الذي شاركه الشخص الآخر معك:';

  @override
  String get partnerCodesReceivedWithCode => '✅ تم استلام رموز الشريك:';

  @override
  String get waitingPartnerCodes => '⏳ في انتظار رموز الشريك...';

  @override
  String get verificationSuccessMessage =>
      'تم التحقق من الهوية بنجاح! كلا المستخدمين أصليان.';

  @override
  String get chatInvitationsTitle => 'دعوات الدردشة';

  @override
  String get cleanExpiredInvitations => 'تنظيف الدعوات منتهية الصلاحية';

  @override
  String get refreshInvitations => 'تحديث الدعوات';

  @override
  String errorInitializing(String error) {
    return 'خطأ في التهيئة: $error';
  }

  @override
  String expiredInvitationsDeleted(int count) {
    return 'تم حذف $count دعوات منتهية الصلاحية نهائيًا';
  }

  @override
  String get noExpiredInvitationsToClean =>
      'لا توجد دعوات منتهية الصلاحية للتنظيف';

  @override
  String errorAcceptingInvitation(String error) {
    return 'خطأ في قبول الدعوة: $error';
  }

  @override
  String errorUpdatingInvitations(String error) {
    return 'خطأ في تحديث الدعوات: $error';
  }

  @override
  String invitationsUpdated(int active, int expired) {
    return 'تم التحديث: $active نشطة، $expired منتهية الصلاحية تم حذفها';
  }

  @override
  String invitationsUpdatedActive(int active) {
    return 'تم التحديث: $active دعوات نشطة';
  }

  @override
  String get noInvitations => 'لا توجد دعوات';

  @override
  String get invitationsWillAppearHere => 'ستظهر دعوات الدردشة هنا';

  @override
  String get chatInvitation => 'دعوة دردشة';

  @override
  String fromUser(String userId) {
    return 'من: $userId';
  }

  @override
  String get expired => 'منتهية الصلاحية';

  @override
  String get reject => 'رفض';

  @override
  String get accept => 'قبول';

  @override
  String get tapToCreateOrJoinEphemeralChats =>
      'انقر لإنشاء أو الانضمام إلى الدردشات سريعة الزوال';

  @override
  String get now => 'الآن';

  @override
  String get callEnded => 'انتهت المكالمة';

  @override
  String get videoCallFeatureAvailable => '🎥 ميزة مكالمات الفيديو متاحة';

  @override
  String get pendingInvitations => 'الدعوات المعلقة';

  @override
  String chatInvitationsCount(int count) {
    return '$count دعوة (دعوات) دردشة';
  }

  @override
  String get searching => 'جارٍ البحث...';

  @override
  String get noUsersFound => 'لم يتم العثور على مستخدمين';

  @override
  String get errorSearchingUsers => 'خطأ في البحث عن المستخدمين';

  @override
  String get startVideoCall => 'بدء مكالمة فيديو';

  @override
  String get startAudioCall => 'بدء مكالمة صوتية';

  @override
  String confirmVideoCall(String nickname) {
    return 'هل تريد بدء مكالمة فيديو مع $nickname؟';
  }

  @override
  String confirmAudioCall(String nickname) {
    return 'هل تريد بدء مكالمة صوتية مع $nickname؟';
  }

  @override
  String get initiatingVideoCall => 'جارٍ بدء مكالمة الفيديو...';

  @override
  String get initiatingAudioCall => 'جارٍ بدء المكالمة الصوتية...';

  @override
  String get sendingInvitation => 'جارٍ إرسال الدعوة...';

  @override
  String get errorInitiatingCall => 'خطأ في بدء المكالمة';

  @override
  String get waitingForResponse => 'في انتظار الرد...';

  @override
  String get invitationSentTo => 'تم إرسال الدعوة إلى';

  @override
  String get waitingForAcceptance => 'في انتظار قبول الدعوة...';

  @override
  String get ephemeralChatTooltip => 'دردشة سريعة الزوال';

  @override
  String get audioCallTooltip => 'مكالمة';

  @override
  String get videoCallTooltip => 'فيديو';

  @override
  String get searchUser => 'بحث عن مستخدم';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get searchingUsers => 'جارٍ البحث عن المستخدمين...';

  @override
  String noUsersFoundWith(String query) {
    return 'لم يتم العثور على مستخدمين\\nبـ \"$query\"';
  }

  @override
  String errorSearchingUsersDetails(String error) {
    return 'خطأ في البحث عن المستخدمين: $error';
  }

  @override
  String multipleChatsTitle(int count) {
    return 'دردشات متعددة ($count/10)';
  }

  @override
  String get backToHome => 'العودة إلى الرئيسية';

  @override
  String get closeAllRooms => 'إغلاق جميع الغرف';

  @override
  String get closeAllRoomsConfirm =>
      'هل أنت متأكد أنك تريد إغلاق جميع غرف الدردشة؟';

  @override
  String get closeAll => 'إغلاق الكل';

  @override
  String participants(int count) {
    return '$count مشاركين';
  }

  @override
  String roomActive(int count) {
    return 'الغرفة نشطة ($count مشاركين)';
  }

  @override
  String get noConnection => 'لا يوجد اتصال';

  @override
  String get createNewRoom => 'إنشاء غرفة جديدة';

  @override
  String get addChat => 'إضافة دردشة';

  @override
  String get statistics => 'الإحصائيات';

  @override
  String get chatStatisticsTitle => 'إحصائيات الدردشة';

  @override
  String get activeRooms => 'الغرف النشطة';

  @override
  String get totalMessages => 'إجمالي الرسائل';

  @override
  String get unreadMessages => 'غير مقروءة';

  @override
  String get initiatingChat => 'جارٍ بدء الدردشة...';

  @override
  String errorClosingRoom(String error) {
    return 'خطأ في إغلاق الغرفة: $error';
  }

  @override
  String get invitationAccepted => '✅ تم قبول الدعوة';

  @override
  String errorAcceptingInvitationDetails(String error) {
    return 'خطأ في قبول الدعوة: $error';
  }

  @override
  String errorCreatingRoom(String error) {
    return 'خطأ في إنشاء الغرفة: $error';
  }

  @override
  String get createNewChatRoom => 'إنشاء غرفة دردشة جديدة';

  @override
  String get minutes => 'دقائق';

  @override
  String get seconds => 'ثوانٍ';

  @override
  String get microphonePermissions => '🎵 أذونات الميكروفون';

  @override
  String get microphonePermissionsContent =>
      'لتسجيل الصوت، تحتاج إلى تفعيل أذونات الميكروفون في إعدادات التطبيق.\n\nاذهب إلى الإعدادات > الخصوصية > الميكروفون وقم بتفعيل الأذونات لهذا التطبيق.';

  @override
  String get openSettings => 'فتح الإعدادات';

  @override
  String errorInitializingAudio(String error) {
    return 'خطأ في تهيئة الصوت: $error';
  }

  @override
  String get imageTooLarge =>
      'الصورة كبيرة جدًا. الحد الأقصى المسموح به 500 كيلوبايت.';

  @override
  String errorSendingImage(String error) {
    return 'خطأ في إرسال الصورة: $error';
  }

  @override
  String errorSendingAudio(String error) {
    return 'خطأ في إرسال الصوت: $error';
  }

  @override
  String get destroyRoomContent =>
      'سيؤدي هذا الإجراء إلى تدمير غرفة الدردشة بشكل دائم لكلا المستخدمين.\\n\\nسيبدأ عد تنازلي لمدة 10 ثوانٍ مرئي لكلا المشاركين.';

  @override
  String get destroyRoomButton => 'تدمير الغرفة';

  @override
  String get connectingToSecureChat => 'جارٍ الاتصال بالدردشة الآمنة...';

  @override
  String get autoDestructionConfigured1Min =>
      'تم تكوين التدمير الذاتي: دقيقة واحدة';

  @override
  String get autoDestructionConfigured5Min =>
      'تم تكوين التدمير الذاتي: 5 دقائق';

  @override
  String get autoDestructionConfigured1Hour =>
      'تم تكوين التدمير الذاتي: ساعة واحدة';

  @override
  String screenshotAlert(String user) {
    return '📸 تنبيه! $user التقط لقطة شاشة';
  }

  @override
  String screenshotNotification(String user) {
    return '📸 $user التقط لقطة شاشة';
  }

  @override
  String get initializingAudioRecorder => 'جارٍ تهيئة مسجل الصوت...';

  @override
  String get audioRecorderNotAvailable =>
      'مسجل الصوت غير متوفر. تحقق من أذونات الميكروفون.';

  @override
  String errorStartingRecording(String error) {
    return 'خطأ في بدء التسجيل: $error';
  }

  @override
  String get audioPlayerNotAvailable => 'مشغل الصوت غير متوفر';

  @override
  String get audioNotAvailable => 'الصوت غير متوفر';

  @override
  String errorPlayingAudio(String error) {
    return 'خطأ في تشغيل الصوت: $error';
  }

  @override
  String get screenshotTestSent => '📸 تم إرسال اختبار لقطة الشاشة';

  @override
  String errorSendingTest(String error) {
    return 'خطأ في إرسال الاختبار: $error';
  }

  @override
  String get audioTooLong =>
      'الصوت طويل جدًا. الحد الأقصى المسموح به 1 ميغابايت.';

  @override
  String get errorWebAudioRecording => 'خطأ: تعذر تسجيل الصوت على الويب';

  @override
  String get errorWebAudioSaving => 'خطأ: تعذر حفظ الصوت';

  @override
  String errorStoppingRecording(String error) {
    return 'خطأ في إيقاف التسجيل: $error';
  }

  @override
  String get sendEncryptedImageTooltip => 'إرسال صورة مشفرة';

  @override
  String get myProfile => 'ملفي الشخصي';

  @override
  String get dangerZone => 'المنطقة الخطيرة';

  @override
  String get dangerZoneDescription =>
      'سيؤدي هذا الإجراء إلى حذف حسابك وجميع بياناتك بشكل دائم. لن تتمكن من استرداد حسابك بمجرد حذفه.';

  @override
  String get destroyMyAccount => 'تدمير حسابي';

  @override
  String get warningTitle => 'تحذير!';

  @override
  String get destroyAccountWarning => 'أنت على وشك تدمير حسابك بشكل دائم.';

  @override
  String get thisActionWill => 'سيؤدي هذا الإجراء إلى:';

  @override
  String get deleteAllData => '• حذف جميع بياناتك';

  @override
  String get closeAllSessions => '• إغلاق جميع جلساتك النشطة';

  @override
  String get deleteChatHistory => '• حذف سجل المحادثات الخاص بك';

  @override
  String get cannotBeUndone => '• لا يمكن التراجع عنه';

  @override
  String get neverAccessAgain =>
      'بمجرد التدمير، لن تتمكن أبدًا من الوصول إلى هذا الحساب مرة أخرى.';

  @override
  String get continueButton => 'متابعة';

  @override
  String get finalConfirmation => 'التأكيد النهائي';

  @override
  String get confirmDestructionText => 'لتأكيد تدمير حسابك، اكتب:';

  @override
  String get typeConfirmation => 'اكتب التأكيد';

  @override
  String get destroyAccount => 'تدمير الحساب';

  @override
  String get functionalityInDevelopment => 'الوظيفة قيد التطوير';

  @override
  String get accountDestructionAvailable =>
      'سيكون تدمير الحساب متاحًا في تحديث قادم. تم تسجيل طلبك.';
}
