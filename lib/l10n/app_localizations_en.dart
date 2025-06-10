// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'FlutterPutter';

  @override
  String get loginTitle => 'Sign in to continue';

  @override
  String get email => 'Email';

  @override
  String get enterEmail => 'Enter your email';

  @override
  String get password => 'Password';

  @override
  String get enterPassword => 'Enter your password';

  @override
  String get pleaseEnterEmail => 'Please enter your email';

  @override
  String get enterValidEmail => 'Enter a valid email';

  @override
  String get pleaseEnterPassword => 'Please enter your password';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get loginButton => 'Sign In';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get register => 'Sign Up';

  @override
  String get oneSessionSecurity =>
      '🔒 Only 1 active session per user allowed for maximum security';

  @override
  String get oneSessionMaxSecurity =>
      'Only 1 session per user (Maximum security)';

  @override
  String get privacyAndSecurity => 'Privacy and Security';

  @override
  String get noDataCollection => 'We don\'t collect personal data';

  @override
  String get anonymousConnections => 'All connections are anonymous';

  @override
  String get ephemeralChatRooms =>
      'Ephemeral chat rooms that self-destruct automatically';

  @override
  String get encryptionInfo => 'XSalsa20 encryption with random keys per room';

  @override
  String get chats => 'Chats';

  @override
  String get secureChat => 'Secure Chat';

  @override
  String get secureChatDescription => 'Tap to create or join ephemeral chats';

  @override
  String get privateVideoCall => 'Private Video Call';

  @override
  String get videoCallDescription => 'Call ended';

  @override
  String get multipleChats => 'Multiple Chats';

  @override
  String get newRoom => 'New Room';

  @override
  String get noActiveChats => 'No active chats';

  @override
  String get useNewRoomButton => 'Use the \'New Room\' tab to create a chat';

  @override
  String get searchUsers => 'Search Users';

  @override
  String get searchByNickname => 'Search by nickname';

  @override
  String get calls => 'Calls';

  @override
  String get verification => 'Verification';

  @override
  String get verificationDemo => '🔐 Verification Demo';

  @override
  String get verificationDemoDescription =>
      'This is a demonstration of the anonymous identity verification system. In a real implementation, this widget would be integrated into ephemeral chat rooms.';

  @override
  String get room => 'Room';

  @override
  String get user => 'User';

  @override
  String get identityVerification => 'Identity Verification';

  @override
  String get verifyIdentityDescription => 'Tap to verify identity anonymously';

  @override
  String get statusNotVerified => 'Status: Not Verified';

  @override
  String get notVerifiedYet => 'Identity has not been verified yet';

  @override
  String get howToTest => 'How to Test Verification';

  @override
  String get step1 => 'Tap on';

  @override
  String get step2 => 'Tap';

  @override
  String get step3 => 'Copy one of the codes (alphanumeric, numeric or emoji)';

  @override
  String get step4 => 'Paste the code in';

  @override
  String get step5 => 'Tap';

  @override
  String get showMyCodes => 'Show My Codes';

  @override
  String get verifyPartnerCode => 'VERIFY PARTNER CODE';

  @override
  String get verify => 'Verify';

  @override
  String get realUsage =>
      'In real usage: Users would share codes via WhatsApp, Telegram, etc.';

  @override
  String get securitySettings => 'Security Settings';

  @override
  String get securitySettingsDescription =>
      'Set up a security PIN to protect your privacy. Notifications will continue to arrive even when the app is locked.';

  @override
  String get configureAppLock => 'Configure app lock';

  @override
  String get newPin => 'New PIN (4-15 characters)';

  @override
  String get confirmPin => 'Confirm PIN';

  @override
  String get activateLock => 'Activate lock';

  @override
  String get screenshotSecurity => 'Screenshot security';

  @override
  String get screenshotSecurityDescription =>
      'Control whether screenshots can be taken of the application.';

  @override
  String get allowScreenshots => 'Allow screenshots';

  @override
  String get screenshotsAllowed => 'Screenshots are ALLOWED';

  @override
  String get screenshotsDisabled => 'You can disable them for greater security';

  @override
  String get autoDestructionDefault => 'Auto-destruction by default';

  @override
  String get autoDestructionDescription =>
      'Set an auto-destruction time that will be applied automatically when joining new chat rooms:';

  @override
  String get defaultTime => 'Default time:';

  @override
  String get noLimit => 'No limit';

  @override
  String get selectTime =>
      'Select a time to enable default auto-destruction. Messages will be automatically deleted after the configured time.';

  @override
  String get activeSessions => 'Active sessions';

  @override
  String get activeSessionsDescription =>
      'Manage devices where you have open sessions. Similar to Signal and WhatsApp.';

  @override
  String get currentState => 'Current state';

  @override
  String get noActiveSessionsRegistered => '0 active sessions registered';

  @override
  String get multipleSessions => 'Multiple sessions: Disabled';

  @override
  String get configurationLikeSignal => 'and configuration like Signal';

  @override
  String get manageSessions => 'Manage sessions';

  @override
  String get allowMultipleSessions => 'Allow multiple sessions';

  @override
  String get onlyOneActiveSession =>
      'Only one active session at a time (like Signal)';

  @override
  String get searchByName => 'Search by name...';

  @override
  String get writeAtLeast2Characters =>
      'Write at least 2 characters to search users';

  @override
  String get connecting => 'Connecting to secure chat...';

  @override
  String get error => 'Error';

  @override
  String get secureMultimediaChat => 'Secure Multimedia Chat';

  @override
  String get sendEncryptedMessages =>
      'Send messages and images\\nencrypted with XChaCha20-Poly1305';

  @override
  String get encryptedMessage => 'Encrypted message...';

  @override
  String get sendEncryptedImage => '📷 Send Encrypted Image';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get useCamera => 'Use camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get selectImage => 'Select image';

  @override
  String get capturesBlocked => 'Captures blocked';

  @override
  String get capturesAllowed => 'Captures allowed';

  @override
  String get e2eEncryptionSecurity => 'E2E Encryption + Security';

  @override
  String get encryptionDescription =>
      'All messages, images and audio are encrypted locally with XChaCha20-Poly1305.\\n\\nThe server only sees opaque encrypted blobs.\\n\\nAudio with real recording implemented.';

  @override
  String get screenshotsStatus => 'Screenshots:';

  @override
  String get screenshotsBlocked => 'BLOCKED';

  @override
  String get screenshotsPermitted => 'PERMITTED';

  @override
  String get likeWhatsAppTelegram =>
      'Like WhatsApp/Telegram - black screen in captures';

  @override
  String get understood => 'Understood';

  @override
  String get destroyRoom => '⚠️ Destroy Room';

  @override
  String get warningDestroyRoom =>
      'This action will permanently destroy the chat room for both users.\\n\\nA 10-second countdown visible to both participants will start.';

  @override
  String get cancel => 'Cancel';

  @override
  String get audioNote => 'Audio note';

  @override
  String get recordedAudioNote => 'Audio note (recorded)';

  @override
  String get playing => 'Playing...';

  @override
  String get tapToStop => 'Tap to stop';

  @override
  String get tapToPlay => 'Tap to play';

  @override
  String get image => 'Image';

  @override
  String get backToMultipleChats => 'Back to multiple chats';

  @override
  String get backToChat => 'Back to chat';

  @override
  String get screenshotsBlockedAutomatically => 'Screenshots BLOCKED';

  @override
  String get screenshotsEnabled => 'Screenshots ENABLED';

  @override
  String get identityVerifiedCorrectly => 'Partner identity verified correctly';

  @override
  String get createAccount => 'Create Account';

  @override
  String get registerSubtitle => 'Sign up to start using FlutterPutter';

  @override
  String get nickname => 'Nickname';

  @override
  String get chooseUniqueNickname => 'Choose a unique nickname';

  @override
  String get createSecurePassword => 'Create a secure password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get repeatPassword => 'Repeat your password';

  @override
  String get invitationCode => 'Invitation Code';

  @override
  String get enterInvitationCode => 'Enter your invitation code';

  @override
  String get registerButton => 'Sign Up';

  @override
  String get pleaseConfirmPassword => 'Please confirm your password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get pleaseEnterNickname => 'Please enter a nickname';

  @override
  String get nicknameMinLength => 'Nickname must be at least 3 characters';

  @override
  String get pleaseEnterInvitationCode => 'Please enter an invitation code';

  @override
  String get invitationCodeLength => 'Code must be 8 characters';

  @override
  String get newChatInvitationReceived => '📩 New chat invitation received';

  @override
  String get view => 'View';

  @override
  String get chatInvitations => 'Chat Invitations';

  @override
  String get securitySettingsTooltip => 'Security Settings';

  @override
  String helloUser(String nickname) {
    return 'Hello, $nickname';
  }

  @override
  String get searchUsersToVideoCall => 'Search users to start a video call';

  @override
  String get searchUsersButton => 'Search Users';

  @override
  String get testIdentityVerification => 'Test identity verification';

  @override
  String get ephemeralChat => '💬 Ephemeral Chat';

  @override
  String get multipleSimultaneousRooms =>
      'Multiple simultaneous rooms (max. 10)';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirmTitle => 'Logout';

  @override
  String get logoutConfirmMessage => 'Are you sure you want to logout?';

  @override
  String get helpSection => 'Help & Support';

  @override
  String get supportCenter => 'Support Center';

  @override
  String get supportCenterDescription =>
      'Get help and check frequently asked questions';

  @override
  String get contactUs => 'Contact us';

  @override
  String get contactUsDescription =>
      'Send us an email to resolve your questions';

  @override
  String get contactEmail => 'FlutterPutter@Proton.me';

  @override
  String get appVersion => 'Version';

  @override
  String get versionNumber => 'Version 1.0 Beta';

  @override
  String get termsAndConditions => 'Terms and Conditions';

  @override
  String get termsDescription => 'Read our terms of service';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get privacyPolicyDescription =>
      'Check how we protect your information';

  @override
  String get emailCopied => 'Email copied to clipboard';

  @override
  String get openingWebPage => 'Opening web page...';

  @override
  String get errorOpeningWebPage => 'Error opening web page';

  @override
  String get pinLengthError => 'PIN must be between 4 and 15 characters';

  @override
  String get pinMismatch => 'PINs do not match';

  @override
  String get appLockSetupSuccess => '🔒 App lock configured successfully';

  @override
  String get pinSetupError => 'Error setting up PIN';

  @override
  String get pinChangeSuccess => '🔒 PIN changed successfully';

  @override
  String get currentPinIncorrect => 'Current PIN is incorrect';

  @override
  String get disableAppLockTitle => 'Disable lock';

  @override
  String get disableAppLockMessage =>
      'Are you sure you want to disable app lock?';

  @override
  String get appLockDisabled => '🔓 App lock disabled';

  @override
  String get confirm => 'Confirm';

  @override
  String get changePin => 'Change PIN:';

  @override
  String get currentPin => 'Current PIN';

  @override
  String get confirmNewPin => 'Confirm new PIN';

  @override
  String get changePinButton => 'Change PIN';

  @override
  String get biometricUnlock => 'Unlock app with biometry in addition to PIN';

  @override
  String get screenshotsAllowedMessage => '🔓 Screenshots ALLOWED';

  @override
  String get screenshotsBlockedMessage => '🔒 Screenshots BLOCKED';

  @override
  String get screenshotConfigError => 'Error updating screenshot configuration';

  @override
  String get protectionActive => 'Active protection';

  @override
  String get nativeProtectionFeatures =>
      '• Native blocking on iOS and Android\n• Alert when capture attempts detected\n• Protection in app switcher';

  @override
  String get autoDestructionDefaultDisabled =>
      '🔥 Default auto-destruction disabled';

  @override
  String get autoDestructionError =>
      'Error updating auto-destruction configuration';

  @override
  String get protectYourApp => 'Protect your app';

  @override
  String get securityPinDescription =>
      'Set up a security PIN to protect your privacy. Notifications will continue to arrive even when the app is locked.';

  @override
  String get lockActivated => 'Lock activated';

  @override
  String get disable => 'Disable';

  @override
  String get errorCopyingEmail => 'Error copying email';

  @override
  String get automaticLockTimeout => 'Automatic lock timeout';

  @override
  String get appWillLockAfter => 'The app will lock automatically after:';

  @override
  String get biometricAuthentication => 'Biometric authentication';

  @override
  String get enableBiometric => 'Enable fingerprint/Face ID';

  @override
  String get autoApplyDefault => 'Apply automatically';

  @override
  String get autoApplyEnabled => 'Will be applied when joining new rooms';

  @override
  String get autoApplyDisabled => 'Only apply manually in each room';

  @override
  String get currentConfiguration => 'Current configuration';

  @override
  String get sessionActive => 'active session';

  @override
  String get sessionsActive => 'active sessions';

  @override
  String get noActiveSessionsMessage => 'No active sessions registered';

  @override
  String get helpAndSupport => 'Get help, contact us or check our policies';

  @override
  String get autoDestructionDefaultEnabled => '🔥 Default auto-destruction: ';

  @override
  String get verificationDemonstration => 'Verification Demonstration';

  @override
  String get roomLabel => 'Room:';

  @override
  String get userLabel => 'User:';

  @override
  String get statusVerified => 'Status: Verified ✅';

  @override
  String get identityVerifiedCorrect => 'Identity has been verified correctly';

  @override
  String get identityVerifiedFull => '✅ Identity Verified';

  @override
  String get bothUsersVerified => 'Both users have verified their identity';

  @override
  String get yourVerificationCodes => 'YOUR VERIFICATION CODES';

  @override
  String get shareCodeMessage =>
      'Share ONE of these codes through another channel (WhatsApp, Telegram, etc.)';

  @override
  String get hideCodesBut => '🙈 Hide Codes';

  @override
  String get alphanumericCode => '🔤 Alphanumeric';

  @override
  String get numericCode => '🔢 Numeric';

  @override
  String get emojiCode => '😀 Emoji';

  @override
  String get enterCodeToVerify => '❌ Enter a code to verify';

  @override
  String get invalidCodeFormat => '❌ Invalid code format';

  @override
  String get identityVerifiedSuccess => '✅ Identity verified correctly!';

  @override
  String get incorrectCode => '❌ Incorrect code';

  @override
  String get codesRegenerated => '🔄 Codes regenerated';

  @override
  String get codeCopied => '📋 Code copied to clipboard';

  @override
  String get partnerCodesReceived => '📥 Partner codes received';

  @override
  String get codesSentToPartner => '📤 Codes sent to partner';

  @override
  String get resendingCodes => '🔄 Resending codes to partner...';

  @override
  String get stepExpandVerification =>
      'Tap on \"🔐 Identity Verification\" to expand';

  @override
  String get stepShowCodes =>
      'Tap \"👁️ Show My Codes\" to see your unique codes';

  @override
  String get stepPasteCode => 'Paste the code in \"VERIFY PARTNER CODE\"';

  @override
  String get stepVerifyCode => 'Tap \"✅ Verify\" to simulate verification';

  @override
  String get enterPartnerCode => 'Enter the code shared by the other person:';

  @override
  String get partnerCodesReceivedWithCode => '✅ Partner codes received:';

  @override
  String get waitingPartnerCodes => '⏳ Waiting for partner codes...';

  @override
  String get verificationSuccessMessage =>
      'Identity verified correctly! Both users are authentic.';

  @override
  String get chatInvitationsTitle => 'Chat Invitations';

  @override
  String get cleanExpiredInvitations => 'Clean expired invitations';

  @override
  String get refreshInvitations => 'Refresh invitations';

  @override
  String errorInitializing(String error) {
    return 'Error initializing: $error';
  }

  @override
  String expiredInvitationsDeleted(int count) {
    return '$count expired invitations deleted permanently';
  }

  @override
  String get noExpiredInvitationsToClean => 'No expired invitations to clean';

  @override
  String errorAcceptingInvitation(String error) {
    return 'Error accepting invitation: $error';
  }

  @override
  String errorUpdatingInvitations(String error) {
    return 'Error updating invitations: $error';
  }

  @override
  String invitationsUpdated(int active, int expired) {
    return 'Updated: $active active, $expired expired deleted';
  }

  @override
  String invitationsUpdatedActive(int active) {
    return 'Updated: $active active invitations';
  }

  @override
  String get noInvitations => 'No invitations';

  @override
  String get invitationsWillAppearHere => 'Chat invitations will appear here';

  @override
  String get chatInvitation => 'Chat invitation';

  @override
  String fromUser(String userId) {
    return 'From: $userId';
  }

  @override
  String get expired => 'Expired';

  @override
  String get reject => 'Reject';

  @override
  String get accept => 'Accept';

  @override
  String get tapToCreateOrJoinEphemeralChats =>
      'Tap to create or join ephemeral chats';

  @override
  String get now => 'Now';

  @override
  String get callEnded => 'Call ended';

  @override
  String get videoCallFeatureAvailable => '🎥 Video call feature available';

  @override
  String get pendingInvitations => 'Pending invitations';

  @override
  String chatInvitationsCount(int count) {
    return '$count chat invitation(s)';
  }

  @override
  String get searching => 'Searching...';

  @override
  String get noUsersFound => 'No users found';

  @override
  String get errorSearchingUsers => 'Error searching users';

  @override
  String get startVideoCall => 'Start video call';

  @override
  String get startAudioCall => 'Start call';

  @override
  String confirmVideoCall(String nickname) {
    return 'Do you want to start a video call with $nickname?';
  }

  @override
  String confirmAudioCall(String nickname) {
    return 'Do you want to start a call with $nickname?';
  }

  @override
  String get initiatingVideoCall => 'Starting video call...';

  @override
  String get initiatingAudioCall => 'Starting call...';

  @override
  String get sendingInvitation => 'Sending invitation...';

  @override
  String get errorInitiatingCall => 'Error starting call';

  @override
  String get waitingForResponse => 'Waiting for Response';

  @override
  String get invitationSentTo => 'Invitation sent to';

  @override
  String get waitingForAcceptance => 'Waiting for invitation to be accepted...';

  @override
  String get ephemeralChatTooltip => 'Ephemeral Chat';

  @override
  String get audioCallTooltip => 'Call';

  @override
  String get videoCallTooltip => 'Video';

  @override
  String get searchUser => 'Search User';

  @override
  String get retry => 'Retry';

  @override
  String get searchingUsers => 'Searching users...';

  @override
  String noUsersFoundWith(String query) {
    return 'No users found\\nwith \"$query\"';
  }

  @override
  String errorSearchingUsersDetails(String error) {
    return 'Error searching users: $error';
  }

  @override
  String multipleChatsTitle(int count) {
    return 'Multiple Chats ($count/10)';
  }

  @override
  String get backToHome => 'Back to Home';

  @override
  String get closeAllRooms => 'Close All Rooms';

  @override
  String get closeAllRoomsConfirm =>
      'Are you sure you want to close all chat rooms?';

  @override
  String get closeAll => 'Close All';

  @override
  String participants(int count) {
    return '$count participants';
  }

  @override
  String roomActive(int count) {
    return 'Active room ($count participants)';
  }

  @override
  String get noConnection => 'No connection';

  @override
  String get createNewRoom => 'Create New Room';

  @override
  String get addChat => 'Add Chat';

  @override
  String get statistics => 'Statistics';

  @override
  String get chatStatisticsTitle => 'Chat Statistics';

  @override
  String get activeRooms => 'Active rooms';

  @override
  String get totalMessages => 'Total messages';

  @override
  String get unreadMessages => 'Unread';

  @override
  String get initiatingChat => 'Starting chat...';

  @override
  String errorClosingRoom(String error) {
    return 'Error closing room: $error';
  }

  @override
  String get invitationAccepted => '✅ Invitation accepted';

  @override
  String errorAcceptingInvitationDetails(String error) {
    return 'Error accepting invitation: $error';
  }

  @override
  String errorCreatingRoom(String error) {
    return 'Error creating room: $error';
  }

  @override
  String get createNewChatRoom => 'Create new chat room';

  @override
  String get minutes => 'minutes';

  @override
  String get seconds => 'seconds';

  @override
  String get microphonePermissions => '🎵 Microphone Permissions';

  @override
  String get microphonePermissionsContent =>
      'To record audio you need to enable microphone permissions in the app settings.\n\nGo to Settings > Privacy > Microphone and enable permissions for this application.';

  @override
  String get openSettings => 'Open Settings';

  @override
  String errorInitializingAudio(String error) {
    return 'Error initializing audio: $error';
  }

  @override
  String get imageTooLarge => 'Image too large. Maximum 500KB allowed.';

  @override
  String errorSendingImage(String error) {
    return 'Error sending image: $error';
  }

  @override
  String errorSendingAudio(String error) {
    return 'Error sending audio: $error';
  }

  @override
  String get destroyRoomContent =>
      'This action will permanently destroy the chat room for both users.\n\nA 10-second countdown visible to both participants will start.';

  @override
  String get destroyRoomButton => 'Destroy Room';

  @override
  String get connectingToSecureChat => 'Connecting to secure chat...';

  @override
  String get autoDestructionConfigured1Min =>
      'Auto-destruction configured: 1 minute';

  @override
  String get autoDestructionConfigured5Min =>
      'Auto-destruction configured: 5 minutes';

  @override
  String get autoDestructionConfigured1Hour =>
      'Auto-destruction configured: 1 hour';

  @override
  String screenshotAlert(String user) {
    return '📸 Alert! $user took a screenshot';
  }

  @override
  String screenshotNotification(String user) {
    return '📸 $user has taken a screenshot';
  }

  @override
  String get initializingAudioRecorder => 'Initializing audio recorder...';

  @override
  String get audioRecorderNotAvailable =>
      'Audio recorder not available. Check microphone permissions.';

  @override
  String errorStartingRecording(String error) {
    return 'Error starting recording: $error';
  }

  @override
  String get audioPlayerNotAvailable => 'Audio player not available';

  @override
  String get audioNotAvailable => 'Audio not available';

  @override
  String errorPlayingAudio(String error) {
    return 'Error playing audio: $error';
  }

  @override
  String get screenshotTestSent => '📸 Screenshot test sent';

  @override
  String errorSendingTest(String error) {
    return 'Error sending test: $error';
  }

  @override
  String get audioTooLong => 'Audio too long. Maximum 1MB allowed.';

  @override
  String get errorWebAudioRecording => 'Error: Could not record audio on web';

  @override
  String get errorWebAudioSaving => 'Error: Could not save audio';

  @override
  String errorStoppingRecording(String error) {
    return 'Error stopping recording: $error';
  }

  @override
  String get sendEncryptedImageTooltip => 'Send encrypted image';

  @override
  String get myProfile => 'My Profile';

  @override
  String get dangerZone => 'Danger Zone';

  @override
  String get dangerZoneDescription =>
      'This action will permanently delete your account and all your data. You will not be able to recover your account once it is deleted.';

  @override
  String get destroyMyAccount => 'Destroy my account';

  @override
  String get warningTitle => 'Warning!';

  @override
  String get destroyAccountWarning =>
      'You are about to permanently destroy your account.';

  @override
  String get thisActionWill => 'This action will:';

  @override
  String get deleteAllData => '• Delete all your data';

  @override
  String get closeAllSessions => '• Close all your active sessions';

  @override
  String get deleteChatHistory => '• Delete your chat history';

  @override
  String get cannotBeUndone => '• Cannot be undone';

  @override
  String get neverAccessAgain =>
      'Once destroyed, you will never be able to access this account again.';

  @override
  String get continueButton => 'Continue';

  @override
  String get finalConfirmation => 'Final Confirmation';

  @override
  String get confirmDestructionText =>
      'To confirm the destruction of your account, type:';

  @override
  String get typeConfirmation => 'Type confirmation';

  @override
  String get destroyAccount => 'Destroy Account';

  @override
  String get functionalityInDevelopment => 'Functionality in development';

  @override
  String get accountDestructionAvailable =>
      'Account destruction will be available in an upcoming update. Your request has been registered.';
}
