// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'FlutterPutter';

  @override
  String get loginTitle => 'Inicia sesión para continuar';

  @override
  String get email => 'Email';

  @override
  String get enterEmail => 'Ingresa tu email';

  @override
  String get password => 'Contraseña';

  @override
  String get enterPassword => 'Ingresa tu contraseña';

  @override
  String get pleaseEnterEmail => 'Por favor, ingresa tu email';

  @override
  String get enterValidEmail => 'Ingresa un email válido';

  @override
  String get pleaseEnterPassword => 'Por favor, ingresa tu contraseña';

  @override
  String get passwordMinLength =>
      'La contraseña debe tener al menos 6 caracteres';

  @override
  String get loginButton => 'Iniciar Sesión';

  @override
  String get noAccount => '¿No tienes una cuenta?';

  @override
  String get register => 'Regístrate';

  @override
  String get oneSessionSecurity =>
      '🔒 Solo se permite 1 sesión activa por usuario para mayor seguridad';

  @override
  String get oneSessionMaxSecurity =>
      'Solo 1 sesión por usuario (Máxima seguridad)';

  @override
  String get privacyAndSecurity => 'Privacidad y Seguridad';

  @override
  String get noDataCollection => 'No recopilamos datos personales';

  @override
  String get anonymousConnections => 'Todas las conexiones son anónimas';

  @override
  String get ephemeralChatRooms =>
      'Salas de chat efímeras que se destruyen automáticamente';

  @override
  String get encryptionInfo =>
      'Cifrado XSalsa20 con claves aleatorias por sala';

  @override
  String get chats => 'Chats';

  @override
  String get secureChat => 'Chat Seguro';

  @override
  String get secureChatDescription =>
      'Toca para crear o unirte a chats efímeros';

  @override
  String get privateVideoCall => 'VideoLlamada Privada';

  @override
  String get videoCallDescription => 'Llamada terminada';

  @override
  String get multipleChats => 'Chats Múltiples';

  @override
  String get newRoom => 'Nueva Sala';

  @override
  String get noActiveChats => 'No hay chats activos';

  @override
  String get useNewRoomButton =>
      'Usa la pestaña \'Nueva Sala\' para crear un chat';

  @override
  String get searchUsers => 'Buscar Usuarios';

  @override
  String get searchByNickname => 'Buscar por nickname';

  @override
  String get calls => 'Llamadas';

  @override
  String get verification => 'Verificación';

  @override
  String get verificationDemo => '🔐 Demo Verificación';

  @override
  String get verificationDemoDescription =>
      'Esta es una demostración del sistema de verificación de identidad anónima. En una implementación real, este widget se integraría en las salas de chat efímero.';

  @override
  String get room => 'Sala';

  @override
  String get user => 'Usuario';

  @override
  String get identityVerification => 'Verificación de Identidad';

  @override
  String get verifyIdentityDescription =>
      'Toca para verificar identidad de forma anónima';

  @override
  String get statusNotVerified => 'Estado: Sin Verificar';

  @override
  String get notVerifiedYet => 'Aún no se ha verificado la identidad';

  @override
  String get howToTest => 'Cómo Probar la Verificación';

  @override
  String get step1 => 'Toca en';

  @override
  String get step2 => 'Toca';

  @override
  String get step3 =>
      'Copia uno de los códigos (alfanumérico, numérico o emoji)';

  @override
  String get step4 => 'Pega el código en';

  @override
  String get step5 => 'Toca';

  @override
  String get showMyCodes => 'Mostrar Mis Códigos';

  @override
  String get verifyPartnerCode => 'VERIFICAR CÓDIGO DEL PARTNER';

  @override
  String get verify => 'Verificar';

  @override
  String get realUsage =>
      'En uso real: Los usuarios compartirían códigos por WhatsApp, Telegram, etc.';

  @override
  String get securitySettings => 'Configuraciones de Seguridad';

  @override
  String get securitySettingsDescription =>
      'Configura un PIN de seguridad para proteger tu privacidad. Las notificaciones seguirán llegando aunque la app esté bloqueada.';

  @override
  String get configureAppLock => 'Configurar bloqueo de aplicación';

  @override
  String get newPin => 'Nuevo PIN (4-15 caracteres)';

  @override
  String get confirmPin => 'Confirmar PIN';

  @override
  String get activateLock => 'Activar bloqueo';

  @override
  String get screenshotSecurity => 'Seguridad de capturas';

  @override
  String get screenshotSecurityDescription =>
      'Controla si se pueden tomar capturas de pantalla de la aplicación.';

  @override
  String get allowScreenshots => 'Permitir capturas de pantalla';

  @override
  String get screenshotsAllowed => 'Las capturas están PERMITIDAS';

  @override
  String get screenshotsDisabled =>
      'Puedes deshabilitarlas para mayor seguridad';

  @override
  String get autoDestructionDefault => 'Auto-destrucción por defecto';

  @override
  String get autoDestructionDescription =>
      'Configura un tiempo de auto-destrucción que se aplicará automáticamente al unirte a nuevas salas de chat:';

  @override
  String get defaultTime => 'Tiempo por defecto:';

  @override
  String get noLimit => 'Sin límite';

  @override
  String get selectTime =>
      'Selecciona un tiempo para habilitar la auto-destrucción por defecto. Los mensajes se eliminarán automáticamente después del tiempo configurado.';

  @override
  String get activeSessions => 'Sesiones activas';

  @override
  String get activeSessionsDescription =>
      'Gestiona los dispositivos donde tienes sesiones abiertas. Similar a Signal y WhatsApp.';

  @override
  String get currentState => 'Estado actual';

  @override
  String get noActiveSessionsRegistered => '0 de sesiones activas registradas';

  @override
  String get multipleSessions => 'Múltiples sesiones: Deshabilitado';

  @override
  String get configurationLikeSignal => 'y configuración como Signal';

  @override
  String get manageSessions => 'Gestionar sesiones';

  @override
  String get allowMultipleSessions => 'Permitir múltiples sesiones';

  @override
  String get onlyOneActiveSession =>
      'Solo una sesión activa a la vez (como Signal)';

  @override
  String get searchByName => 'Buscar por nombre...';

  @override
  String get writeAtLeast2Characters =>
      'Escribe al menos 2 caracteres para buscar usuarios';

  @override
  String get connecting => 'Conectando...';

  @override
  String get error => 'Error';

  @override
  String get secureMultimediaChat => 'Chat Multimedia Seguro';

  @override
  String get sendEncryptedMessages =>
      'Envía mensajes e imágenes\\ncifrados con XChaCha20-Poly1305';

  @override
  String get encryptedMessage => 'Mensaje cifrado...';

  @override
  String get sendEncryptedImage => '📷 Enviar Imagen Cifrada';

  @override
  String get takePhoto => 'Tomar Foto';

  @override
  String get useCamera => 'Usar cámara';

  @override
  String get gallery => 'Galería';

  @override
  String get selectImage => 'Seleccionar imagen';

  @override
  String get capturesBlocked => 'Capturas bloqueadas';

  @override
  String get capturesAllowed => 'Capturas permitidas';

  @override
  String get e2eEncryptionSecurity => 'Cifrado E2E + Seguridad';

  @override
  String get encryptionDescription =>
      'Todos los mensajes, imágenes y audio están cifrados localmente con XChaCha20-Poly1305.\\n\\nEl servidor solo ve blobs cifrados opacos.\\n\\nAudio con grabación real implementada.';

  @override
  String get screenshotsStatus => 'Capturas de pantalla:';

  @override
  String get screenshotsBlocked => 'BLOQUEADAS';

  @override
  String get screenshotsPermitted => 'PERMITIDAS';

  @override
  String get likeWhatsAppTelegram =>
      'Como WhatsApp/Telegram - pantalla negra en capturas';

  @override
  String get understood => 'Entendido';

  @override
  String get destroyRoom => '⚠️ Destruir Sala';

  @override
  String get warningDestroyRoom =>
      'Esta acción destruirá permanentemente la sala de chat para ambos usuarios.\\n\\nSe iniciará un contador de 10 segundos visible para ambos participantes.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get audioNote => 'Nota de audio';

  @override
  String get recordedAudioNote => 'Nota de audio (grabada)';

  @override
  String get playing => 'Reproduciendo...';

  @override
  String get tapToStop => 'Toca para detener';

  @override
  String get tapToPlay => 'Toca para reproducir';

  @override
  String get image => 'Imagen';

  @override
  String get backToMultipleChats => 'Volver a chats múltiples';

  @override
  String get backToChat => 'Volver a chat';

  @override
  String get screenshotsBlockedAutomatically =>
      'Capturas de pantalla BLOQUEADAS';

  @override
  String get screenshotsEnabled => 'Capturas de pantalla HABILITADAS';

  @override
  String get identityVerifiedCorrectly =>
      'Identidad del partner verificada correctamente';

  @override
  String get createAccount => 'Crear Cuenta';

  @override
  String get registerSubtitle =>
      'Regístrate para comenzar a usar FlutterPutter';

  @override
  String get nickname => 'Nickname';

  @override
  String get chooseUniqueNickname => 'Elige un nickname único';

  @override
  String get createSecurePassword => 'Crea una contraseña segura';

  @override
  String get confirmPassword => 'Confirmar Contraseña';

  @override
  String get repeatPassword => 'Repite tu contraseña';

  @override
  String get invitationCode => 'Código de Invitación';

  @override
  String get enterInvitationCode => 'Ingresa tu código de invitación';

  @override
  String get registerButton => 'Registrarse';

  @override
  String get pleaseConfirmPassword => 'Por favor, confirma tu contraseña';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get pleaseEnterNickname => 'Por favor, ingresa un nickname';

  @override
  String get nicknameMinLength =>
      'El nickname debe tener al menos 3 caracteres';

  @override
  String get pleaseEnterInvitationCode =>
      'Por favor, ingresa un código de invitación';

  @override
  String get invitationCodeLength => 'El código debe tener 8 caracteres';

  @override
  String get newChatInvitationReceived =>
      '📩 Nueva invitación de chat recibida';

  @override
  String get view => 'Ver';

  @override
  String get chatInvitations => 'Invitaciones de Chat';

  @override
  String get securitySettingsTooltip => 'Configuraciones de Seguridad';

  @override
  String helloUser(String nickname) {
    return 'Hola, $nickname';
  }

  @override
  String get searchUsersToVideoCall =>
      'Busca usuarios para iniciar una videollamada';

  @override
  String get searchUsersButton => 'Buscar Usuarios';

  @override
  String get testIdentityVerification => 'Probar verificación de identidad';

  @override
  String get ephemeralChat => '💬 Chat Efímero';

  @override
  String get multipleSimultaneousRooms =>
      'Múltiples salas simultáneas (máx. 10)';

  @override
  String get logout => 'Cerrar Sesión';

  @override
  String get logoutConfirmTitle => 'Cerrar Sesión';

  @override
  String get logoutConfirmMessage =>
      '¿Estás seguro de que quieres cerrar sesión?';

  @override
  String get helpSection => 'Ayuda y Soporte';

  @override
  String get supportCenter => 'Centro de asistencia';

  @override
  String get supportCenterDescription =>
      'Obtén ayuda y consulta las preguntas frecuentes';

  @override
  String get contactUs => 'Contacta con nosotros';

  @override
  String get contactUsDescription =>
      'Envíanos un email para resolver tus dudas';

  @override
  String get contactEmail => 'FlutterPutter@Proton.me';

  @override
  String get appVersion => 'Versión';

  @override
  String get versionNumber => 'Version 1.0 Beta';

  @override
  String get termsAndConditions => 'Términos y condiciones';

  @override
  String get termsDescription => 'Lee nuestros términos de servicio';

  @override
  String get privacyPolicy => 'Política de privacidad';

  @override
  String get privacyPolicyDescription =>
      'Consulta cómo protegemos tu información';

  @override
  String get emailCopied => 'Email copiado al portapapeles';

  @override
  String get openingWebPage => 'Abriendo página web...';

  @override
  String get errorOpeningWebPage => 'Error al abrir la página web';

  @override
  String get pinLengthError => 'El PIN debe tener entre 4 y 15 caracteres';

  @override
  String get pinMismatch => 'Los PINs no coinciden';

  @override
  String get appLockSetupSuccess =>
      '🔒 Bloqueo de aplicación configurado exitosamente';

  @override
  String get pinSetupError => 'Error configurando el PIN';

  @override
  String get pinChangeSuccess => '🔒 PIN cambiado exitosamente';

  @override
  String get currentPinIncorrect => 'PIN actual incorrecto';

  @override
  String get disableAppLockTitle => 'Deshabilitar bloqueo';

  @override
  String get disableAppLockMessage =>
      '¿Estás seguro de que quieres deshabilitar el bloqueo de aplicación?';

  @override
  String get appLockDisabled => '🔓 Bloqueo de aplicación deshabilitado';

  @override
  String get confirm => 'Confirmar';

  @override
  String get changePin => 'Cambiar PIN:';

  @override
  String get currentPin => 'PIN actual';

  @override
  String get confirmNewPin => 'Confirmar nuevo PIN';

  @override
  String get changePinButton => 'Cambiar PIN';

  @override
  String get biometricUnlock =>
      'Desbloquea la app con biometría además del PIN';

  @override
  String get screenshotsAllowedMessage => '🔓 Capturas de pantalla PERMITIDAS';

  @override
  String get screenshotsBlockedMessage => '🔒 Capturas de pantalla BLOQUEADAS';

  @override
  String get screenshotConfigError =>
      'Error actualizando configuración de capturas';

  @override
  String get protectionActive => 'Protección activa';

  @override
  String get nativeProtectionFeatures =>
      '• Bloqueo nativo en iOS y Android\n• Alerta al detectar intentos de captura\n• Protección en app switcher';

  @override
  String get autoDestructionDefaultDisabled =>
      '🔥 Auto-destrucción por defecto deshabilitada';

  @override
  String get autoDestructionError =>
      'Error actualizando configuración de auto-destrucción';

  @override
  String get protectYourApp => 'Protege tu aplicación';

  @override
  String get securityPinDescription =>
      'Configura un PIN de seguridad para proteger tu privacidad. Las notificaciones seguirán llegando aunque la app esté bloqueada.';

  @override
  String get lockActivated => 'Bloqueo activado';

  @override
  String get disable => 'Deshabilitar';

  @override
  String get errorCopyingEmail => 'Error al copiar el email';

  @override
  String get automaticLockTimeout => 'Tiempo de bloqueo automático';

  @override
  String get appWillLockAfter =>
      'La aplicación se bloqueará automáticamente después de:';

  @override
  String get biometricAuthentication => 'Autenticación biométrica';

  @override
  String get enableBiometric => 'Habilitar huella/Face ID';

  @override
  String get autoApplyDefault => 'Aplicar automáticamente';

  @override
  String get autoApplyEnabled => 'Se aplicará al unirse a nuevas salas';

  @override
  String get autoApplyDisabled => 'Solo aplicar manualmente en cada sala';

  @override
  String get currentConfiguration => 'Configuración actual';

  @override
  String get sessionActive => 'sesión activa';

  @override
  String get sessionsActive => 'sesiones activas';

  @override
  String get noActiveSessionsMessage => 'Sin sesiones activas registradas';

  @override
  String get helpAndSupport =>
      'Obtén ayuda, contacta con nosotros o consulta nuestras políticas';

  @override
  String get autoDestructionDefaultEnabled =>
      '🔥 Auto-destrucción por defecto: ';

  @override
  String get verificationDemonstration => 'Demostración de Verificación';

  @override
  String get roomLabel => 'Sala:';

  @override
  String get userLabel => 'Usuario:';

  @override
  String get statusVerified => 'Estado: Verificado ✅';

  @override
  String get identityVerifiedCorrect =>
      'La identidad ha sido verificada correctamente';

  @override
  String get identityVerifiedFull => '✅ Identidad Verificada';

  @override
  String get bothUsersVerified => 'Ambos usuarios han verificado su identidad';

  @override
  String get yourVerificationCodes => 'TUS CÓDIGOS DE VERIFICACIÓN';

  @override
  String get shareCodeMessage =>
      'Comparte UNO de estos códigos por otro canal (WhatsApp, Telegram, etc.)';

  @override
  String get hideCodesBut => '🙈 Ocultar Códigos';

  @override
  String get alphanumericCode => '🔤 Alfanumérico';

  @override
  String get numericCode => '🔢 Numérico';

  @override
  String get emojiCode => '😀 Emoji';

  @override
  String get enterCodeToVerify => '❌ Ingresa un código para verificar';

  @override
  String get invalidCodeFormat => '❌ Formato de código inválido';

  @override
  String get identityVerifiedSuccess =>
      '✅ ¡Identidad verificada correctamente!';

  @override
  String get incorrectCode => '❌ Código incorrecto';

  @override
  String get codesRegenerated => '🔄 Códigos regenerados';

  @override
  String get codeCopied => '📋 Código copiado al portapapeles';

  @override
  String get partnerCodesReceived => '📥 Códigos del partner recibidos';

  @override
  String get codesSentToPartner => '📤 Códigos enviados al partner';

  @override
  String get resendingCodes => '🔄 Reenviando códigos al partner...';

  @override
  String get stepExpandVerification =>
      'Toca en \"🔐 Verificación de Identidad\" para expandir';

  @override
  String get stepShowCodes =>
      'Toca \"👁️ Mostrar Mis Códigos\" para ver tus códigos únicos';

  @override
  String get stepPasteCode =>
      'Pega el código en \"VERIFICAR CÓDIGO DEL PARTNER\"';

  @override
  String get stepVerifyCode =>
      'Toca \"✅ Verificar\" para simular la verificación';

  @override
  String get enterPartnerCode =>
      'Ingresa el código que te compartió la otra persona:';

  @override
  String get partnerCodesReceivedWithCode => '✅ Códigos del partner recibidos:';

  @override
  String get waitingPartnerCodes => '⏳ Esperando códigos del partner...';

  @override
  String get verificationSuccessMessage =>
      '¡Identidad verificada correctamente! Ambos usuarios son auténticos.';

  @override
  String get chatInvitationsTitle => 'Invitaciones de Chat';

  @override
  String get cleanExpiredInvitations => 'Limpiar invitaciones expiradas';

  @override
  String get refreshInvitations => 'Actualizar invitaciones';

  @override
  String errorInitializing(String error) {
    return 'Error inicializando: $error';
  }

  @override
  String expiredInvitationsDeleted(int count) {
    return '$count invitaciones expiradas eliminadas definitivamente';
  }

  @override
  String get noExpiredInvitationsToClean =>
      'No hay invitaciones expiradas para limpiar';

  @override
  String errorAcceptingInvitation(String error) {
    return 'Error aceptando invitación: $error';
  }

  @override
  String errorUpdatingInvitations(String error) {
    return 'Error actualizando invitaciones: $error';
  }

  @override
  String invitationsUpdated(int active, int expired) {
    return 'Actualizado: $active activas, $expired expiradas eliminadas';
  }

  @override
  String invitationsUpdatedActive(int active) {
    return 'Actualizado: $active invitaciones activas';
  }

  @override
  String get noInvitations => 'No hay invitaciones';

  @override
  String get invitationsWillAppearHere =>
      'Las invitaciones de chat aparecerán aquí';

  @override
  String get chatInvitation => 'Invitación de chat';

  @override
  String fromUser(String userId) {
    return 'De: $userId';
  }

  @override
  String get expired => 'Expirada';

  @override
  String get reject => 'Rechazar';

  @override
  String get accept => 'Aceptar';

  @override
  String get tapToCreateOrJoinEphemeralChats =>
      'Toca para crear o unirte a chats efímeros';

  @override
  String get now => 'Ahora';

  @override
  String get callEnded => 'Llamada terminada';

  @override
  String get videoCallFeatureAvailable =>
      '🎥 Función de videollamada disponible';

  @override
  String get pendingInvitations => 'Invitaciones pendientes';

  @override
  String chatInvitationsCount(int count) {
    return '$count invitación(es) de chat';
  }

  @override
  String get searching => 'Buscando...';

  @override
  String get noUsersFound => 'No se encontraron usuarios';

  @override
  String get errorSearchingUsers => 'Error al buscar usuarios';

  @override
  String get startVideoCall => 'Iniciar videollamada';

  @override
  String get startAudioCall => 'Iniciar llamada';

  @override
  String confirmVideoCall(String nickname) {
    return '¿Quieres iniciar una videollamada con $nickname?';
  }

  @override
  String confirmAudioCall(String nickname) {
    return '¿Quieres iniciar una llamada con $nickname?';
  }

  @override
  String get initiatingVideoCall => 'Iniciando videollamada...';

  @override
  String get initiatingAudioCall => 'Iniciando llamada...';

  @override
  String get sendingInvitation => 'Enviando invitación...';

  @override
  String get errorInitiatingCall => 'Error al iniciar la llamada';

  @override
  String get waitingForResponse => 'Esperando respuesta...';

  @override
  String get invitationSentTo => 'Invitación enviada a';

  @override
  String get waitingForAcceptance => 'Esperando que acepte la invitación...';

  @override
  String get ephemeralChatTooltip => 'Chat Efímero';

  @override
  String get audioCallTooltip => 'Llamada';

  @override
  String get videoCallTooltip => 'Video';

  @override
  String get searchUser => 'Buscar Usuario';

  @override
  String get retry => 'Reintentar';

  @override
  String get searchingUsers => 'Buscando usuarios...';

  @override
  String noUsersFoundWith(String query) {
    return 'No se encontraron usuarios\\ncon \"$query\"';
  }

  @override
  String errorSearchingUsersDetails(String error) {
    return 'Error buscando usuarios: $error';
  }

  @override
  String multipleChatsTitle(int count) {
    return 'Chats Múltiples ($count/10)';
  }

  @override
  String get backToHome => 'Volver al Home';

  @override
  String get closeAllRooms => 'Cerrar Todas las Salas';

  @override
  String get closeAllRoomsConfirm =>
      '¿Estás seguro de que quieres cerrar todas las salas de chat?';

  @override
  String get closeAll => 'Cerrar Todas';

  @override
  String participants(int count) {
    return '$count participantes';
  }

  @override
  String roomActive(int count) {
    return 'Sala activa ($count participantes)';
  }

  @override
  String get noConnection => 'Sin conexión';

  @override
  String get createNewRoom => 'Crear Nueva Sala';

  @override
  String get addChat => 'Agregar Chat';

  @override
  String get statistics => 'Estadísticas';

  @override
  String get chatStatisticsTitle => 'Estadísticas de Chat';

  @override
  String get activeRooms => 'Salas activas';

  @override
  String get totalMessages => 'Mensajes totales';

  @override
  String get unreadMessages => 'No leídos';

  @override
  String get initiatingChat => 'Iniciando chat...';

  @override
  String errorClosingRoom(String error) {
    return 'Error cerrando sala: $error';
  }

  @override
  String get invitationAccepted => '✅ Invitación aceptada';

  @override
  String errorAcceptingInvitationDetails(String error) {
    return 'Error aceptando invitación: $error';
  }

  @override
  String errorCreatingRoom(String error) {
    return 'Error creando sala: $error';
  }

  @override
  String get createNewChatRoom => 'Crear nueva sala de chat';

  @override
  String get minutes => 'minutos';

  @override
  String get seconds => 'segundos';

  @override
  String get microphonePermissions => '🎵 Permisos de Micrófono';

  @override
  String get microphonePermissionsContent =>
      'Para grabar audio necesitas activar los permisos de micrófono en la configuración de la app.\n\nVe a Configuración > Privacidad > Micrófono y activa los permisos para esta aplicación.';

  @override
  String get openSettings => 'Abrir Configuración';

  @override
  String errorInitializingAudio(String error) {
    return 'Error inicializando audio: $error';
  }

  @override
  String get imageTooLarge =>
      'Imagen demasiado grande. Máximo 500KB permitido.';

  @override
  String errorSendingImage(String error) {
    return 'Error enviando imagen: $error';
  }

  @override
  String errorSendingAudio(String error) {
    return 'Error enviando audio: $error';
  }

  @override
  String get destroyRoomContent =>
      'Esta acción destruirá permanentemente la sala de chat para ambos usuarios.\n\nSe iniciará un contador de 10 segundos visible para ambos participantes.';

  @override
  String get destroyRoomButton => 'Destruir Sala';

  @override
  String get connectingToSecureChat => 'Conectando al chat seguro...';

  @override
  String get autoDestructionConfigured1Min =>
      'Autodestrucción configurada: 1 minuto';

  @override
  String get autoDestructionConfigured5Min =>
      'Autodestrucción configurada: 5 minutos';

  @override
  String get autoDestructionConfigured1Hour =>
      'Autodestrucción configurada: 1 hora';

  @override
  String screenshotAlert(String user) {
    return '📸 ¡Alerta! $user tomó una captura';
  }

  @override
  String screenshotNotification(String user) {
    return '📸 $user ha tomado una captura de pantalla';
  }

  @override
  String get initializingAudioRecorder => 'Inicializando grabador de audio...';

  @override
  String get audioRecorderNotAvailable =>
      'Grabador de audio no disponible. Verifica los permisos de micrófono.';

  @override
  String errorStartingRecording(String error) {
    return 'Error iniciando grabación: $error';
  }

  @override
  String get audioPlayerNotAvailable => 'Reproductor de audio no disponible';

  @override
  String get audioNotAvailable => 'Audio no disponible';

  @override
  String errorPlayingAudio(String error) {
    return 'Error reproduciendo audio: $error';
  }

  @override
  String get screenshotTestSent => '📸 Test de captura enviado';

  @override
  String errorSendingTest(String error) {
    return 'Error enviando test: $error';
  }

  @override
  String get audioTooLong => 'Audio demasiado largo. Máximo 1MB permitido.';

  @override
  String get errorWebAudioRecording =>
      'Error: No se pudo grabar el audio en web';

  @override
  String get errorWebAudioSaving => 'Error: No se pudo guardar el audio';

  @override
  String errorStoppingRecording(String error) {
    return 'Error deteniendo grabación: $error';
  }

  @override
  String get sendEncryptedImageTooltip => 'Enviar imagen cifrada';

  @override
  String get myProfile => 'Mi Perfil';

  @override
  String get dangerZone => 'Zona Peligrosa';

  @override
  String get dangerZoneDescription =>
      'Esta acción eliminará permanentemente tu cuenta y todos tus datos. No podrás recuperar tu cuenta una vez que sea eliminada.';

  @override
  String get destroyMyAccount => 'Destruir mi cuenta';

  @override
  String get warningTitle => '¡Advertencia!';

  @override
  String get destroyAccountWarning =>
      'Estás a punto de destruir tu cuenta permanentemente.';

  @override
  String get thisActionWill => 'Esta acción:';

  @override
  String get deleteAllData => '• Eliminará todos tus datos';

  @override
  String get closeAllSessions => '• Cerrará todas tus sesiones activas';

  @override
  String get deleteChatHistory => '• Eliminará tu historial de chats';

  @override
  String get cannotBeUndone => '• No se puede deshacer';

  @override
  String get neverAccessAgain =>
      'Una vez destruida, nunca más podrás acceder a esta cuenta.';

  @override
  String get continueButton => 'Continuar';

  @override
  String get finalConfirmation => 'Confirmación Final';

  @override
  String get confirmDestructionText =>
      'Para confirmar la destrucción de tu cuenta, escribe:';

  @override
  String get typeConfirmation => 'Escribir confirmación';

  @override
  String get destroyAccount => 'Destruir Cuenta';

  @override
  String get functionalityInDevelopment => 'Funcionalidad en desarrollo';

  @override
  String get accountDestructionAvailable =>
      'La destrucción de cuenta estará disponible en una próxima actualización. Tu solicitud ha sido registrada.';
}
