import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_sq.dart';
import 'app_localizations_sr.dart';
import 'app_localizations_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('pt'),
    Locale('ru'),
    Locale('sq'),
    Locale('sr'),
    Locale('uk'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'FlutterPutter'**
  String get appTitle;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get loginTitle;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmail;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterEmail;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get enterValidEmail;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginButton;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get register;

  /// No description provided for @oneSessionSecurity.
  ///
  /// In en, this message translates to:
  /// **'🔒 Only 1 active session per user allowed for maximum security'**
  String get oneSessionSecurity;

  /// No description provided for @oneSessionMaxSecurity.
  ///
  /// In en, this message translates to:
  /// **'Only 1 session per user (Maximum security)'**
  String get oneSessionMaxSecurity;

  /// No description provided for @privacyAndSecurity.
  ///
  /// In en, this message translates to:
  /// **'Privacy and Security'**
  String get privacyAndSecurity;

  /// No description provided for @noDataCollection.
  ///
  /// In en, this message translates to:
  /// **'We don\'t collect personal data'**
  String get noDataCollection;

  /// No description provided for @anonymousConnections.
  ///
  /// In en, this message translates to:
  /// **'All connections are anonymous'**
  String get anonymousConnections;

  /// No description provided for @ephemeralChatRooms.
  ///
  /// In en, this message translates to:
  /// **'Ephemeral chat rooms that self-destruct automatically'**
  String get ephemeralChatRooms;

  /// No description provided for @encryptionInfo.
  ///
  /// In en, this message translates to:
  /// **'XSalsa20 encryption with random keys per room'**
  String get encryptionInfo;

  /// No description provided for @chats.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get chats;

  /// No description provided for @secureChat.
  ///
  /// In en, this message translates to:
  /// **'Secure Chat'**
  String get secureChat;

  /// No description provided for @secureChatDescription.
  ///
  /// In en, this message translates to:
  /// **'Tap to create or join ephemeral chats'**
  String get secureChatDescription;

  /// No description provided for @privateVideoCall.
  ///
  /// In en, this message translates to:
  /// **'Private Video Call'**
  String get privateVideoCall;

  /// No description provided for @videoCallDescription.
  ///
  /// In en, this message translates to:
  /// **'Call ended'**
  String get videoCallDescription;

  /// No description provided for @multipleChats.
  ///
  /// In en, this message translates to:
  /// **'Multiple Chats'**
  String get multipleChats;

  /// No description provided for @newRoom.
  ///
  /// In en, this message translates to:
  /// **'New Room'**
  String get newRoom;

  /// No description provided for @noActiveChats.
  ///
  /// In en, this message translates to:
  /// **'No active chats'**
  String get noActiveChats;

  /// No description provided for @useNewRoomButton.
  ///
  /// In en, this message translates to:
  /// **'Use the \'New Room\' tab to create a chat'**
  String get useNewRoomButton;

  /// No description provided for @searchUsers.
  ///
  /// In en, this message translates to:
  /// **'Search Users'**
  String get searchUsers;

  /// No description provided for @searchByNickname.
  ///
  /// In en, this message translates to:
  /// **'Search by nickname'**
  String get searchByNickname;

  /// No description provided for @calls.
  ///
  /// In en, this message translates to:
  /// **'Calls'**
  String get calls;

  /// No description provided for @verification.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get verification;

  /// No description provided for @verificationDemo.
  ///
  /// In en, this message translates to:
  /// **'🔐 Verification Demo'**
  String get verificationDemo;

  /// No description provided for @verificationDemoDescription.
  ///
  /// In en, this message translates to:
  /// **'This is a demonstration of the anonymous identity verification system. In a real implementation, this widget would be integrated into ephemeral chat rooms.'**
  String get verificationDemoDescription;

  /// No description provided for @room.
  ///
  /// In en, this message translates to:
  /// **'Room'**
  String get room;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @identityVerification.
  ///
  /// In en, this message translates to:
  /// **'Identity Verification'**
  String get identityVerification;

  /// No description provided for @verifyIdentityDescription.
  ///
  /// In en, this message translates to:
  /// **'Tap to verify identity anonymously'**
  String get verifyIdentityDescription;

  /// No description provided for @statusNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Status: Not Verified'**
  String get statusNotVerified;

  /// No description provided for @notVerifiedYet.
  ///
  /// In en, this message translates to:
  /// **'Identity has not been verified yet'**
  String get notVerifiedYet;

  /// No description provided for @howToTest.
  ///
  /// In en, this message translates to:
  /// **'How to Test Verification'**
  String get howToTest;

  /// No description provided for @step1.
  ///
  /// In en, this message translates to:
  /// **'Tap on'**
  String get step1;

  /// No description provided for @step2.
  ///
  /// In en, this message translates to:
  /// **'Tap'**
  String get step2;

  /// No description provided for @step3.
  ///
  /// In en, this message translates to:
  /// **'Copy one of the codes (alphanumeric, numeric or emoji)'**
  String get step3;

  /// No description provided for @step4.
  ///
  /// In en, this message translates to:
  /// **'Paste the code in'**
  String get step4;

  /// No description provided for @step5.
  ///
  /// In en, this message translates to:
  /// **'Tap'**
  String get step5;

  /// No description provided for @showMyCodes.
  ///
  /// In en, this message translates to:
  /// **'Show My Codes'**
  String get showMyCodes;

  /// No description provided for @verifyPartnerCode.
  ///
  /// In en, this message translates to:
  /// **'VERIFY PARTNER CODE'**
  String get verifyPartnerCode;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @realUsage.
  ///
  /// In en, this message translates to:
  /// **'In real usage: Users would share codes via WhatsApp, Telegram, etc.'**
  String get realUsage;

  /// No description provided for @securitySettings.
  ///
  /// In en, this message translates to:
  /// **'Security Settings'**
  String get securitySettings;

  /// No description provided for @securitySettingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Set up a security PIN to protect your privacy. Notifications will continue to arrive even when the app is locked.'**
  String get securitySettingsDescription;

  /// No description provided for @configureAppLock.
  ///
  /// In en, this message translates to:
  /// **'Configure app lock'**
  String get configureAppLock;

  /// No description provided for @newPin.
  ///
  /// In en, this message translates to:
  /// **'New PIN (4-15 characters)'**
  String get newPin;

  /// No description provided for @confirmPin.
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get confirmPin;

  /// No description provided for @activateLock.
  ///
  /// In en, this message translates to:
  /// **'Activate lock'**
  String get activateLock;

  /// No description provided for @screenshotSecurity.
  ///
  /// In en, this message translates to:
  /// **'Screenshot security'**
  String get screenshotSecurity;

  /// No description provided for @screenshotSecurityDescription.
  ///
  /// In en, this message translates to:
  /// **'Control whether screenshots can be taken of the application.'**
  String get screenshotSecurityDescription;

  /// No description provided for @allowScreenshots.
  ///
  /// In en, this message translates to:
  /// **'Allow screenshots'**
  String get allowScreenshots;

  /// No description provided for @screenshotsAllowed.
  ///
  /// In en, this message translates to:
  /// **'Screenshots are ALLOWED'**
  String get screenshotsAllowed;

  /// No description provided for @screenshotsDisabled.
  ///
  /// In en, this message translates to:
  /// **'You can disable them for greater security'**
  String get screenshotsDisabled;

  /// No description provided for @autoDestructionDefault.
  ///
  /// In en, this message translates to:
  /// **'Auto-destruction by default'**
  String get autoDestructionDefault;

  /// No description provided for @autoDestructionDescription.
  ///
  /// In en, this message translates to:
  /// **'Set an auto-destruction time that will be applied automatically when joining new chat rooms:'**
  String get autoDestructionDescription;

  /// No description provided for @defaultTime.
  ///
  /// In en, this message translates to:
  /// **'Default time:'**
  String get defaultTime;

  /// No description provided for @noLimit.
  ///
  /// In en, this message translates to:
  /// **'No limit'**
  String get noLimit;

  /// No description provided for @selectTime.
  ///
  /// In en, this message translates to:
  /// **'Select a time to enable default auto-destruction. Messages will be automatically deleted after the configured time.'**
  String get selectTime;

  /// No description provided for @activeSessions.
  ///
  /// In en, this message translates to:
  /// **'Active sessions'**
  String get activeSessions;

  /// No description provided for @activeSessionsDescription.
  ///
  /// In en, this message translates to:
  /// **'Manage devices where you have open sessions. Similar to Signal and WhatsApp.'**
  String get activeSessionsDescription;

  /// No description provided for @currentState.
  ///
  /// In en, this message translates to:
  /// **'Current state'**
  String get currentState;

  /// No description provided for @noActiveSessionsRegistered.
  ///
  /// In en, this message translates to:
  /// **'0 active sessions registered'**
  String get noActiveSessionsRegistered;

  /// No description provided for @multipleSessions.
  ///
  /// In en, this message translates to:
  /// **'Multiple sessions: Disabled'**
  String get multipleSessions;

  /// No description provided for @configurationLikeSignal.
  ///
  /// In en, this message translates to:
  /// **'and configuration like Signal'**
  String get configurationLikeSignal;

  /// No description provided for @manageSessions.
  ///
  /// In en, this message translates to:
  /// **'Manage sessions'**
  String get manageSessions;

  /// No description provided for @allowMultipleSessions.
  ///
  /// In en, this message translates to:
  /// **'Allow multiple sessions'**
  String get allowMultipleSessions;

  /// No description provided for @onlyOneActiveSession.
  ///
  /// In en, this message translates to:
  /// **'Only one active session at a time (like Signal)'**
  String get onlyOneActiveSession;

  /// No description provided for @searchByName.
  ///
  /// In en, this message translates to:
  /// **'Search by name...'**
  String get searchByName;

  /// No description provided for @writeAtLeast2Characters.
  ///
  /// In en, this message translates to:
  /// **'Write at least 2 characters to search users'**
  String get writeAtLeast2Characters;

  /// No description provided for @connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting to secure chat...'**
  String get connecting;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @secureMultimediaChat.
  ///
  /// In en, this message translates to:
  /// **'Secure Multimedia Chat'**
  String get secureMultimediaChat;

  /// No description provided for @sendEncryptedMessages.
  ///
  /// In en, this message translates to:
  /// **'Send messages and images\\nencrypted with XChaCha20-Poly1305'**
  String get sendEncryptedMessages;

  /// Message field placeholder
  ///
  /// In en, this message translates to:
  /// **'Encrypted message...'**
  String get encryptedMessage;

  /// Image picker title
  ///
  /// In en, this message translates to:
  /// **'📷 Send Encrypted Image'**
  String get sendEncryptedImage;

  /// Take photo option
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// Use camera description
  ///
  /// In en, this message translates to:
  /// **'Use camera'**
  String get useCamera;

  /// Gallery option
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// Select image description
  ///
  /// In en, this message translates to:
  /// **'Select image'**
  String get selectImage;

  /// No description provided for @capturesBlocked.
  ///
  /// In en, this message translates to:
  /// **'Captures blocked'**
  String get capturesBlocked;

  /// No description provided for @capturesAllowed.
  ///
  /// In en, this message translates to:
  /// **'Captures allowed'**
  String get capturesAllowed;

  /// No description provided for @e2eEncryptionSecurity.
  ///
  /// In en, this message translates to:
  /// **'E2E Encryption + Security'**
  String get e2eEncryptionSecurity;

  /// No description provided for @encryptionDescription.
  ///
  /// In en, this message translates to:
  /// **'All messages, images and audio are encrypted locally with XChaCha20-Poly1305.\\n\\nThe server only sees opaque encrypted blobs.\\n\\nAudio with real recording implemented.'**
  String get encryptionDescription;

  /// No description provided for @screenshotsStatus.
  ///
  /// In en, this message translates to:
  /// **'Screenshots:'**
  String get screenshotsStatus;

  /// No description provided for @screenshotsBlocked.
  ///
  /// In en, this message translates to:
  /// **'BLOCKED'**
  String get screenshotsBlocked;

  /// No description provided for @screenshotsPermitted.
  ///
  /// In en, this message translates to:
  /// **'PERMITTED'**
  String get screenshotsPermitted;

  /// No description provided for @likeWhatsAppTelegram.
  ///
  /// In en, this message translates to:
  /// **'Like WhatsApp/Telegram - black screen in captures'**
  String get likeWhatsAppTelegram;

  /// Understood button
  ///
  /// In en, this message translates to:
  /// **'Understood'**
  String get understood;

  /// Destroy room dialog title
  ///
  /// In en, this message translates to:
  /// **'⚠️ Destroy Room'**
  String get destroyRoom;

  /// No description provided for @warningDestroyRoom.
  ///
  /// In en, this message translates to:
  /// **'This action will permanently destroy the chat room for both users.\\n\\nA 10-second countdown visible to both participants will start.'**
  String get warningDestroyRoom;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Audio message type
  ///
  /// In en, this message translates to:
  /// **'Audio note'**
  String get audioNote;

  /// No description provided for @recordedAudioNote.
  ///
  /// In en, this message translates to:
  /// **'Audio note (recorded)'**
  String get recordedAudioNote;

  /// No description provided for @playing.
  ///
  /// In en, this message translates to:
  /// **'Playing...'**
  String get playing;

  /// No description provided for @tapToStop.
  ///
  /// In en, this message translates to:
  /// **'Tap to stop'**
  String get tapToStop;

  /// No description provided for @tapToPlay.
  ///
  /// In en, this message translates to:
  /// **'Tap to play'**
  String get tapToPlay;

  /// Image message type
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get image;

  /// No description provided for @backToMultipleChats.
  ///
  /// In en, this message translates to:
  /// **'Back to multiple chats'**
  String get backToMultipleChats;

  /// No description provided for @backToChat.
  ///
  /// In en, this message translates to:
  /// **'Back to chat'**
  String get backToChat;

  /// No description provided for @screenshotsBlockedAutomatically.
  ///
  /// In en, this message translates to:
  /// **'Screenshots BLOCKED'**
  String get screenshotsBlockedAutomatically;

  /// No description provided for @screenshotsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Screenshots ENABLED'**
  String get screenshotsEnabled;

  /// No description provided for @identityVerifiedCorrectly.
  ///
  /// In en, this message translates to:
  /// **'Partner identity verified correctly'**
  String get identityVerifiedCorrectly;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign up to start using FlutterPutter'**
  String get registerSubtitle;

  /// No description provided for @nickname.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get nickname;

  /// No description provided for @chooseUniqueNickname.
  ///
  /// In en, this message translates to:
  /// **'Choose a unique nickname'**
  String get chooseUniqueNickname;

  /// No description provided for @createSecurePassword.
  ///
  /// In en, this message translates to:
  /// **'Create a secure password'**
  String get createSecurePassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @repeatPassword.
  ///
  /// In en, this message translates to:
  /// **'Repeat your password'**
  String get repeatPassword;

  /// No description provided for @invitationCode.
  ///
  /// In en, this message translates to:
  /// **'Invitation Code'**
  String get invitationCode;

  /// No description provided for @enterInvitationCode.
  ///
  /// In en, this message translates to:
  /// **'Enter your invitation code'**
  String get enterInvitationCode;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get registerButton;

  /// No description provided for @pleaseConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get pleaseConfirmPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @pleaseEnterNickname.
  ///
  /// In en, this message translates to:
  /// **'Please enter a nickname'**
  String get pleaseEnterNickname;

  /// No description provided for @nicknameMinLength.
  ///
  /// In en, this message translates to:
  /// **'Nickname must be at least 3 characters'**
  String get nicknameMinLength;

  /// No description provided for @pleaseEnterInvitationCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter an invitation code'**
  String get pleaseEnterInvitationCode;

  /// No description provided for @invitationCodeLength.
  ///
  /// In en, this message translates to:
  /// **'Code must be 8 characters'**
  String get invitationCodeLength;

  /// No description provided for @newChatInvitationReceived.
  ///
  /// In en, this message translates to:
  /// **'📩 New chat invitation received'**
  String get newChatInvitationReceived;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @chatInvitations.
  ///
  /// In en, this message translates to:
  /// **'Chat Invitations'**
  String get chatInvitations;

  /// No description provided for @securitySettingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Security Settings'**
  String get securitySettingsTooltip;

  /// Greeting with user nickname
  ///
  /// In en, this message translates to:
  /// **'Hello, {nickname}'**
  String helloUser(String nickname);

  /// No description provided for @searchUsersToVideoCall.
  ///
  /// In en, this message translates to:
  /// **'Search users to start a video call'**
  String get searchUsersToVideoCall;

  /// No description provided for @searchUsersButton.
  ///
  /// In en, this message translates to:
  /// **'Search Users'**
  String get searchUsersButton;

  /// No description provided for @testIdentityVerification.
  ///
  /// In en, this message translates to:
  /// **'Test identity verification'**
  String get testIdentityVerification;

  /// No description provided for @ephemeralChat.
  ///
  /// In en, this message translates to:
  /// **'💬 Ephemeral Chat'**
  String get ephemeralChat;

  /// No description provided for @multipleSimultaneousRooms.
  ///
  /// In en, this message translates to:
  /// **'Multiple simultaneous rooms (max. 10)'**
  String get multipleSimultaneousRooms;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmMessage;

  /// Help section title
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSection;

  /// Support center option
  ///
  /// In en, this message translates to:
  /// **'Support Center'**
  String get supportCenter;

  /// Support center description
  ///
  /// In en, this message translates to:
  /// **'Get help and check frequently asked questions'**
  String get supportCenterDescription;

  /// Contact option
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get contactUs;

  /// Contact description
  ///
  /// In en, this message translates to:
  /// **'Send us an email to resolve your questions'**
  String get contactUsDescription;

  /// Contact email
  ///
  /// In en, this message translates to:
  /// **'FlutterPutter@Proton.me'**
  String get contactEmail;

  /// Version label
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get appVersion;

  /// App version number
  ///
  /// In en, this message translates to:
  /// **'Version 1.0 Beta'**
  String get versionNumber;

  /// Terms and conditions option
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get termsAndConditions;

  /// Terms and conditions description
  ///
  /// In en, this message translates to:
  /// **'Read our terms of service'**
  String get termsDescription;

  /// Privacy policy option
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Privacy policy description
  ///
  /// In en, this message translates to:
  /// **'Check how we protect your information'**
  String get privacyPolicyDescription;

  /// Message when email is copied to clipboard
  ///
  /// In en, this message translates to:
  /// **'Email copied to clipboard'**
  String get emailCopied;

  /// Message when opening a web page
  ///
  /// In en, this message translates to:
  /// **'Opening web page...'**
  String get openingWebPage;

  /// Error message when opening web page
  ///
  /// In en, this message translates to:
  /// **'Error opening web page'**
  String get errorOpeningWebPage;

  /// PIN length error message
  ///
  /// In en, this message translates to:
  /// **'PIN must be between 4 and 15 characters'**
  String get pinLengthError;

  /// Error when PINs don't match
  ///
  /// In en, this message translates to:
  /// **'PINs do not match'**
  String get pinMismatch;

  /// Success message when setting up app lock
  ///
  /// In en, this message translates to:
  /// **'🔒 App lock configured successfully'**
  String get appLockSetupSuccess;

  /// Error when setting up PIN
  ///
  /// In en, this message translates to:
  /// **'Error setting up PIN'**
  String get pinSetupError;

  /// Success message when changing PIN
  ///
  /// In en, this message translates to:
  /// **'🔒 PIN changed successfully'**
  String get pinChangeSuccess;

  /// Error when current PIN is wrong
  ///
  /// In en, this message translates to:
  /// **'Current PIN is incorrect'**
  String get currentPinIncorrect;

  /// Title for disable lock dialog
  ///
  /// In en, this message translates to:
  /// **'Disable lock'**
  String get disableAppLockTitle;

  /// Confirmation message for disabling lock
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to disable app lock?'**
  String get disableAppLockMessage;

  /// Message when app lock is disabled
  ///
  /// In en, this message translates to:
  /// **'🔓 App lock disabled'**
  String get appLockDisabled;

  /// Confirm button
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Change PIN title
  ///
  /// In en, this message translates to:
  /// **'Change PIN:'**
  String get changePin;

  /// Current PIN field
  ///
  /// In en, this message translates to:
  /// **'Current PIN'**
  String get currentPin;

  /// Confirm new PIN field
  ///
  /// In en, this message translates to:
  /// **'Confirm new PIN'**
  String get confirmNewPin;

  /// Change PIN button
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get changePinButton;

  /// Biometric unlock description
  ///
  /// In en, this message translates to:
  /// **'Unlock app with biometry in addition to PIN'**
  String get biometricUnlock;

  /// Message when screenshots are allowed
  ///
  /// In en, this message translates to:
  /// **'🔓 Screenshots ALLOWED'**
  String get screenshotsAllowedMessage;

  /// Message when screenshots are blocked
  ///
  /// In en, this message translates to:
  /// **'🔒 Screenshots BLOCKED'**
  String get screenshotsBlockedMessage;

  /// Error when updating screenshot settings
  ///
  /// In en, this message translates to:
  /// **'Error updating screenshot configuration'**
  String get screenshotConfigError;

  /// Active protection title
  ///
  /// In en, this message translates to:
  /// **'Active protection'**
  String get protectionActive;

  /// List of native protection features
  ///
  /// In en, this message translates to:
  /// **'• Native blocking on iOS and Android\n• Alert when capture attempts detected\n• Protection in app switcher'**
  String get nativeProtectionFeatures;

  /// Message when auto-destruction is disabled
  ///
  /// In en, this message translates to:
  /// **'🔥 Default auto-destruction disabled'**
  String get autoDestructionDefaultDisabled;

  /// Error when updating auto-destruction
  ///
  /// In en, this message translates to:
  /// **'Error updating auto-destruction configuration'**
  String get autoDestructionError;

  /// Main security title
  ///
  /// In en, this message translates to:
  /// **'Protect your app'**
  String get protectYourApp;

  /// PIN setup description
  ///
  /// In en, this message translates to:
  /// **'Set up a security PIN to protect your privacy. Notifications will continue to arrive even when the app is locked.'**
  String get securityPinDescription;

  /// Status when lock is active
  ///
  /// In en, this message translates to:
  /// **'Lock activated'**
  String get lockActivated;

  /// Disable button
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get disable;

  /// Error when copying email to clipboard
  ///
  /// In en, this message translates to:
  /// **'Error copying email'**
  String get errorCopyingEmail;

  /// Automatic lock timeout title
  ///
  /// In en, this message translates to:
  /// **'Automatic lock timeout'**
  String get automaticLockTimeout;

  /// Automatic lock description
  ///
  /// In en, this message translates to:
  /// **'The app will lock automatically after:'**
  String get appWillLockAfter;

  /// Biometric authentication title
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication'**
  String get biometricAuthentication;

  /// Enable biometric option
  ///
  /// In en, this message translates to:
  /// **'Enable fingerprint/Face ID'**
  String get enableBiometric;

  /// Auto-apply default option
  ///
  /// In en, this message translates to:
  /// **'Apply automatically'**
  String get autoApplyDefault;

  /// Description when auto-apply is enabled
  ///
  /// In en, this message translates to:
  /// **'Will be applied when joining new rooms'**
  String get autoApplyEnabled;

  /// Description when auto-apply is disabled
  ///
  /// In en, this message translates to:
  /// **'Only apply manually in each room'**
  String get autoApplyDisabled;

  /// Current configuration title
  ///
  /// In en, this message translates to:
  /// **'Current configuration'**
  String get currentConfiguration;

  /// Singular active session
  ///
  /// In en, this message translates to:
  /// **'active session'**
  String get sessionActive;

  /// Plural active sessions
  ///
  /// In en, this message translates to:
  /// **'active sessions'**
  String get sessionsActive;

  /// Message when no active sessions
  ///
  /// In en, this message translates to:
  /// **'No active sessions registered'**
  String get noActiveSessionsMessage;

  /// Help and support description
  ///
  /// In en, this message translates to:
  /// **'Get help, contact us or check our policies'**
  String get helpAndSupport;

  /// Message when auto-destruction is enabled
  ///
  /// In en, this message translates to:
  /// **'🔥 Default auto-destruction: '**
  String get autoDestructionDefaultEnabled;

  /// Title of verification demonstration
  ///
  /// In en, this message translates to:
  /// **'Verification Demonstration'**
  String get verificationDemonstration;

  /// Room label
  ///
  /// In en, this message translates to:
  /// **'Room:'**
  String get roomLabel;

  /// User label
  ///
  /// In en, this message translates to:
  /// **'User:'**
  String get userLabel;

  /// Status when verified
  ///
  /// In en, this message translates to:
  /// **'Status: Verified ✅'**
  String get statusVerified;

  /// Message when identity is verified
  ///
  /// In en, this message translates to:
  /// **'Identity has been verified correctly'**
  String get identityVerifiedCorrect;

  /// Title when identity is verified
  ///
  /// In en, this message translates to:
  /// **'✅ Identity Verified'**
  String get identityVerifiedFull;

  /// Message when both users are verified
  ///
  /// In en, this message translates to:
  /// **'Both users have verified their identity'**
  String get bothUsersVerified;

  /// Title of own verification codes
  ///
  /// In en, this message translates to:
  /// **'YOUR VERIFICATION CODES'**
  String get yourVerificationCodes;

  /// Instruction to share codes
  ///
  /// In en, this message translates to:
  /// **'Share ONE of these codes through another channel (WhatsApp, Telegram, etc.)'**
  String get shareCodeMessage;

  /// Button to hide codes
  ///
  /// In en, this message translates to:
  /// **'🙈 Hide Codes'**
  String get hideCodesBut;

  /// Alphanumeric code type
  ///
  /// In en, this message translates to:
  /// **'🔤 Alphanumeric'**
  String get alphanumericCode;

  /// Numeric code type
  ///
  /// In en, this message translates to:
  /// **'🔢 Numeric'**
  String get numericCode;

  /// Emoji code type
  ///
  /// In en, this message translates to:
  /// **'😀 Emoji'**
  String get emojiCode;

  /// Error when no code is entered
  ///
  /// In en, this message translates to:
  /// **'❌ Enter a code to verify'**
  String get enterCodeToVerify;

  /// Invalid code format error
  ///
  /// In en, this message translates to:
  /// **'❌ Invalid code format'**
  String get invalidCodeFormat;

  /// Success message when verifying
  ///
  /// In en, this message translates to:
  /// **'✅ Identity verified correctly!'**
  String get identityVerifiedSuccess;

  /// Error when code is incorrect
  ///
  /// In en, this message translates to:
  /// **'❌ Incorrect code'**
  String get incorrectCode;

  /// Message when codes are regenerated
  ///
  /// In en, this message translates to:
  /// **'🔄 Codes regenerated'**
  String get codesRegenerated;

  /// Message when code is copied
  ///
  /// In en, this message translates to:
  /// **'📋 Code copied to clipboard'**
  String get codeCopied;

  /// Message when partner codes are received
  ///
  /// In en, this message translates to:
  /// **'📥 Partner codes received'**
  String get partnerCodesReceived;

  /// Message when codes are sent
  ///
  /// In en, this message translates to:
  /// **'📤 Codes sent to partner'**
  String get codesSentToPartner;

  /// Message when resending codes
  ///
  /// In en, this message translates to:
  /// **'🔄 Resending codes to partner...'**
  String get resendingCodes;

  /// Step to expand verification
  ///
  /// In en, this message translates to:
  /// **'Tap on \"🔐 Identity Verification\" to expand'**
  String get stepExpandVerification;

  /// Step to show codes
  ///
  /// In en, this message translates to:
  /// **'Tap \"👁️ Show My Codes\" to see your unique codes'**
  String get stepShowCodes;

  /// Step to paste code
  ///
  /// In en, this message translates to:
  /// **'Paste the code in \"VERIFY PARTNER CODE\"'**
  String get stepPasteCode;

  /// Step to verify code
  ///
  /// In en, this message translates to:
  /// **'Tap \"✅ Verify\" to simulate verification'**
  String get stepVerifyCode;

  /// Instruction to enter partner code
  ///
  /// In en, this message translates to:
  /// **'Enter the code shared by the other person:'**
  String get enterPartnerCode;

  /// Message with received partner code
  ///
  /// In en, this message translates to:
  /// **'✅ Partner codes received:'**
  String get partnerCodesReceivedWithCode;

  /// Message waiting for partner codes
  ///
  /// In en, this message translates to:
  /// **'⏳ Waiting for partner codes...'**
  String get waitingPartnerCodes;

  /// Complete successful verification message
  ///
  /// In en, this message translates to:
  /// **'Identity verified correctly! Both users are authentic.'**
  String get verificationSuccessMessage;

  /// Chat invitations screen title
  ///
  /// In en, this message translates to:
  /// **'Chat Invitations'**
  String get chatInvitationsTitle;

  /// Tooltip to clean expired invitations
  ///
  /// In en, this message translates to:
  /// **'Clean expired invitations'**
  String get cleanExpiredInvitations;

  /// Tooltip to refresh invitations
  ///
  /// In en, this message translates to:
  /// **'Refresh invitations'**
  String get refreshInvitations;

  /// Error when initializing service
  ///
  /// In en, this message translates to:
  /// **'Error initializing: {error}'**
  String errorInitializing(String error);

  /// Message when expired invitations are deleted
  ///
  /// In en, this message translates to:
  /// **'{count} expired invitations deleted permanently'**
  String expiredInvitationsDeleted(int count);

  /// Message when no expired invitations
  ///
  /// In en, this message translates to:
  /// **'No expired invitations to clean'**
  String get noExpiredInvitationsToClean;

  /// Error when accepting invitation
  ///
  /// In en, this message translates to:
  /// **'Error accepting invitation: {error}'**
  String errorAcceptingInvitation(String error);

  /// Error when updating invitations
  ///
  /// In en, this message translates to:
  /// **'Error updating invitations: {error}'**
  String errorUpdatingInvitations(String error);

  /// Update message with counts
  ///
  /// In en, this message translates to:
  /// **'Updated: {active} active, {expired} expired deleted'**
  String invitationsUpdated(int active, int expired);

  /// Update message for active only
  ///
  /// In en, this message translates to:
  /// **'Updated: {active} active invitations'**
  String invitationsUpdatedActive(int active);

  /// Message when no invitations
  ///
  /// In en, this message translates to:
  /// **'No invitations'**
  String get noInvitations;

  /// Empty state description
  ///
  /// In en, this message translates to:
  /// **'Chat invitations will appear here'**
  String get invitationsWillAppearHere;

  /// Title of an individual invitation
  ///
  /// In en, this message translates to:
  /// **'Chat invitation'**
  String get chatInvitation;

  /// Which user the invitation is from
  ///
  /// In en, this message translates to:
  /// **'From: {userId}'**
  String fromUser(String userId);

  /// Expired invitation status
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expired;

  /// Button to reject invitation
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// Button to accept invitation
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// Secure chat description
  ///
  /// In en, this message translates to:
  /// **'Tap to create or join ephemeral chats'**
  String get tapToCreateOrJoinEphemeralChats;

  /// Current time
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get now;

  /// Call ended status
  ///
  /// In en, this message translates to:
  /// **'Call ended'**
  String get callEnded;

  /// Video call feature available message
  ///
  /// In en, this message translates to:
  /// **'🎥 Video call feature available'**
  String get videoCallFeatureAvailable;

  /// Pending invitations title
  ///
  /// In en, this message translates to:
  /// **'Pending invitations'**
  String get pendingInvitations;

  /// Chat invitations counter
  ///
  /// In en, this message translates to:
  /// **'{count} chat invitation(s)'**
  String chatInvitationsCount(int count);

  /// Message when searching
  ///
  /// In en, this message translates to:
  /// **'Searching...'**
  String get searching;

  /// Message when no users are found
  ///
  /// In en, this message translates to:
  /// **'No users found'**
  String get noUsersFound;

  /// Error when searching users
  ///
  /// In en, this message translates to:
  /// **'Error searching users'**
  String get errorSearchingUsers;

  /// Title to start video call
  ///
  /// In en, this message translates to:
  /// **'Start video call'**
  String get startVideoCall;

  /// Title to start audio call
  ///
  /// In en, this message translates to:
  /// **'Start call'**
  String get startAudioCall;

  /// Confirmation to start video call
  ///
  /// In en, this message translates to:
  /// **'Do you want to start a video call with {nickname}?'**
  String confirmVideoCall(String nickname);

  /// Confirmation to start audio call
  ///
  /// In en, this message translates to:
  /// **'Do you want to start a call with {nickname}?'**
  String confirmAudioCall(String nickname);

  /// Message when starting video call
  ///
  /// In en, this message translates to:
  /// **'Starting video call...'**
  String get initiatingVideoCall;

  /// Message when starting audio call
  ///
  /// In en, this message translates to:
  /// **'Starting call...'**
  String get initiatingAudioCall;

  /// Message when sending invitation
  ///
  /// In en, this message translates to:
  /// **'Sending invitation...'**
  String get sendingInvitation;

  /// Error when starting call
  ///
  /// In en, this message translates to:
  /// **'Error starting call'**
  String get errorInitiatingCall;

  /// Waiting screen title
  ///
  /// In en, this message translates to:
  /// **'Waiting for Response'**
  String get waitingForResponse;

  /// Invitation sent message
  ///
  /// In en, this message translates to:
  /// **'Invitation sent to'**
  String get invitationSentTo;

  /// Message waiting for acceptance
  ///
  /// In en, this message translates to:
  /// **'Waiting for invitation to be accepted...'**
  String get waitingForAcceptance;

  /// Tooltip for ephemeral chat
  ///
  /// In en, this message translates to:
  /// **'Ephemeral Chat'**
  String get ephemeralChatTooltip;

  /// Tooltip for audio call
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get audioCallTooltip;

  /// Tooltip for video call
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get videoCallTooltip;

  /// Search widget title
  ///
  /// In en, this message translates to:
  /// **'Search User'**
  String get searchUser;

  /// Retry button
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Message searching users
  ///
  /// In en, this message translates to:
  /// **'Searching users...'**
  String get searchingUsers;

  /// Message when no users found with specific search
  ///
  /// In en, this message translates to:
  /// **'No users found\\nwith \"{query}\"'**
  String noUsersFoundWith(String query);

  /// Detailed error when searching users
  ///
  /// In en, this message translates to:
  /// **'Error searching users: {error}'**
  String errorSearchingUsersDetails(String error);

  /// Multiple chats title with counter
  ///
  /// In en, this message translates to:
  /// **'Multiple Chats ({count}/10)'**
  String multipleChatsTitle(int count);

  /// Tooltip to go back to home
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// Button to close all rooms
  ///
  /// In en, this message translates to:
  /// **'Close All Rooms'**
  String get closeAllRooms;

  /// Confirmation to close all rooms
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to close all chat rooms?'**
  String get closeAllRoomsConfirm;

  /// Close all button
  ///
  /// In en, this message translates to:
  /// **'Close All'**
  String get closeAll;

  /// Participants counter
  ///
  /// In en, this message translates to:
  /// **'{count} participants'**
  String participants(int count);

  /// Active room status
  ///
  /// In en, this message translates to:
  /// **'Active room ({count} participants)'**
  String roomActive(int count);

  /// No connection status
  ///
  /// In en, this message translates to:
  /// **'No connection'**
  String get noConnection;

  /// Create new room title
  ///
  /// In en, this message translates to:
  /// **'Create New Room'**
  String get createNewRoom;

  /// Add chat button
  ///
  /// In en, this message translates to:
  /// **'Add Chat'**
  String get addChat;

  /// Statistics title
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// Chat statistics title
  ///
  /// In en, this message translates to:
  /// **'Chat Statistics'**
  String get chatStatisticsTitle;

  /// Active rooms
  ///
  /// In en, this message translates to:
  /// **'Active rooms'**
  String get activeRooms;

  /// Total messages
  ///
  /// In en, this message translates to:
  /// **'Total messages'**
  String get totalMessages;

  /// Unread messages
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get unreadMessages;

  /// Starting chat message
  ///
  /// In en, this message translates to:
  /// **'Starting chat...'**
  String get initiatingChat;

  /// Error closing room
  ///
  /// In en, this message translates to:
  /// **'Error closing room: {error}'**
  String errorClosingRoom(String error);

  /// Invitation accepted message
  ///
  /// In en, this message translates to:
  /// **'✅ Invitation accepted'**
  String get invitationAccepted;

  /// Detailed error accepting invitation
  ///
  /// In en, this message translates to:
  /// **'Error accepting invitation: {error}'**
  String errorAcceptingInvitationDetails(String error);

  /// Error creating room
  ///
  /// In en, this message translates to:
  /// **'Error creating room: {error}'**
  String errorCreatingRoom(String error);

  /// Tooltip create new chat room
  ///
  /// In en, this message translates to:
  /// **'Create new chat room'**
  String get createNewChatRoom;

  /// Word minutes for duration
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get minutes;

  /// Word seconds for duration
  ///
  /// In en, this message translates to:
  /// **'seconds'**
  String get seconds;

  /// Microphone permissions dialog title
  ///
  /// In en, this message translates to:
  /// **'🎵 Microphone Permissions'**
  String get microphonePermissions;

  /// Microphone permissions dialog content
  ///
  /// In en, this message translates to:
  /// **'To record audio you need to enable microphone permissions in the app settings.\n\nGo to Settings > Privacy > Microphone and enable permissions for this application.'**
  String get microphonePermissionsContent;

  /// Open settings button
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// Error initializing audio
  ///
  /// In en, this message translates to:
  /// **'Error initializing audio: {error}'**
  String errorInitializingAudio(String error);

  /// Image too large error
  ///
  /// In en, this message translates to:
  /// **'Image too large. Maximum 500KB allowed.'**
  String get imageTooLarge;

  /// Error sending image
  ///
  /// In en, this message translates to:
  /// **'Error sending image: {error}'**
  String errorSendingImage(String error);

  /// Error sending audio
  ///
  /// In en, this message translates to:
  /// **'Error sending audio: {error}'**
  String errorSendingAudio(String error);

  /// Destroy room dialog content
  ///
  /// In en, this message translates to:
  /// **'This action will permanently destroy the chat room for both users.\n\nA 10-second countdown visible to both participants will start.'**
  String get destroyRoomContent;

  /// Destroy room button
  ///
  /// In en, this message translates to:
  /// **'Destroy Room'**
  String get destroyRoomButton;

  /// Connecting to chat message
  ///
  /// In en, this message translates to:
  /// **'Connecting to secure chat...'**
  String get connectingToSecureChat;

  /// Auto-destruction 1 minute confirmation
  ///
  /// In en, this message translates to:
  /// **'Auto-destruction configured: 1 minute'**
  String get autoDestructionConfigured1Min;

  /// Auto-destruction 5 minutes confirmation
  ///
  /// In en, this message translates to:
  /// **'Auto-destruction configured: 5 minutes'**
  String get autoDestructionConfigured5Min;

  /// Auto-destruction 1 hour confirmation
  ///
  /// In en, this message translates to:
  /// **'Auto-destruction configured: 1 hour'**
  String get autoDestructionConfigured1Hour;

  /// Screenshot alert
  ///
  /// In en, this message translates to:
  /// **'📸 Alert! {user} took a screenshot'**
  String screenshotAlert(String user);

  /// Screenshot notification
  ///
  /// In en, this message translates to:
  /// **'📸 {user} has taken a screenshot'**
  String screenshotNotification(String user);

  /// Initializing recorder message
  ///
  /// In en, this message translates to:
  /// **'Initializing audio recorder...'**
  String get initializingAudioRecorder;

  /// Recorder not available error
  ///
  /// In en, this message translates to:
  /// **'Audio recorder not available. Check microphone permissions.'**
  String get audioRecorderNotAvailable;

  /// Error starting recording
  ///
  /// In en, this message translates to:
  /// **'Error starting recording: {error}'**
  String errorStartingRecording(String error);

  /// Player not available error
  ///
  /// In en, this message translates to:
  /// **'Audio player not available'**
  String get audioPlayerNotAvailable;

  /// Audio not available error
  ///
  /// In en, this message translates to:
  /// **'Audio not available'**
  String get audioNotAvailable;

  /// Error playing audio
  ///
  /// In en, this message translates to:
  /// **'Error playing audio: {error}'**
  String errorPlayingAudio(String error);

  /// Screenshot test confirmation
  ///
  /// In en, this message translates to:
  /// **'📸 Screenshot test sent'**
  String get screenshotTestSent;

  /// Error sending test
  ///
  /// In en, this message translates to:
  /// **'Error sending test: {error}'**
  String errorSendingTest(String error);

  /// Audio too long error
  ///
  /// In en, this message translates to:
  /// **'Audio too long. Maximum 1MB allowed.'**
  String get audioTooLong;

  /// Web recording error
  ///
  /// In en, this message translates to:
  /// **'Error: Could not record audio on web'**
  String get errorWebAudioRecording;

  /// Web audio saving error
  ///
  /// In en, this message translates to:
  /// **'Error: Could not save audio'**
  String get errorWebAudioSaving;

  /// Error stopping recording
  ///
  /// In en, this message translates to:
  /// **'Error stopping recording: {error}'**
  String errorStoppingRecording(String error);

  /// Send encrypted image button tooltip
  ///
  /// In en, this message translates to:
  /// **'Send encrypted image'**
  String get sendEncryptedImageTooltip;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fr',
    'it',
    'pt',
    'ru',
    'sq',
    'sr',
    'uk',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'sq':
      return AppLocalizationsSq();
    case 'sr':
      return AppLocalizationsSr();
    case 'uk':
      return AppLocalizationsUk();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
