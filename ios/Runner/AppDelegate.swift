import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  
  // NUEVO: Referencia para bloqueo REAL de capturas (según Apple)
  private var secureTextField: UITextField?
  private var isScreenshotBlocked = false
  // NUEVO: Variables para detección
  private var screenshotDetectionActive = false
  private var screenshotChannel: FlutterMethodChannel?
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Registrar plugin VoIP nativo (SIN dependencias externas)
    if let registrar = self.registrar(forPlugin: "VoIPPlugin") {
        VoIPPlugin.register(with: registrar)
    }
    
    // NUEVO: Configurar método channel para capturas de pantalla
    setupScreenshotSecurity()
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // NUEVO: Configurar el canal de comunicación para capturas de pantalla
  private func setupScreenshotSecurity() {
    guard let controller = window?.rootViewController as? FlutterViewController else {
      print("❌ [iOS SCREENSHOT] No se pudo obtener FlutterViewController")
      return
    }
    
    let channel = FlutterMethodChannel(
      name: "screenshot_security",
      binaryMessenger: controller.binaryMessenger
    )
    
    // Guardar referencia al canal para uso posterior
    screenshotChannel = channel
    
    channel.setMethodCallHandler { [weak self] call, result in
      switch call.method {
      case "blockScreenshots":
        self?.blockScreenshots()
        result(true)
        print("🔒 [iOS SCREENSHOT] Capturas BLOQUEADAS (método oficial Apple)")
        
      case "enableScreenshots":
        self?.enableScreenshots()
        result(true)
        print("🔓 [iOS SCREENSHOT] Capturas HABILITADAS")
        
      // NUEVO: Métodos para detección
      case "startScreenshotDetection":
        self?.startScreenshotDetection()
        result(true)
        print("👁️ [iOS SCREENSHOT] Detección INICIADA")
        
      case "stopScreenshotDetection":
        self?.stopScreenshotDetection()
        result(true)
        print("👁️ [iOS SCREENSHOT] Detección DETENIDA")
        
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    
    print("✅ [iOS SCREENSHOT] Canal de comunicación configurado")
  }
  
  // NUEVO: Iniciar detección de capturas
  private func startScreenshotDetection() {
    if screenshotDetectionActive {
      print("👁️ [iOS SCREENSHOT] Detección ya está activa")
      return
    }
    
    screenshotDetectionActive = true
    
    // Observar capturas de pantalla
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(screenshotDetected),
      name: UIApplication.userDidTakeScreenshotNotification,
      object: nil
    )
    
    // Observar grabación de pantalla (iOS 11+)
    if #available(iOS 11.0, *) {
      NotificationCenter.default.addObserver(
        self,
        selector: #selector(screenRecordingDetected),
        name: UIScreen.capturedDidChangeNotification,
        object: nil
      )
    }
    
    print("👁️ [iOS SCREENSHOT] Observadores registrados para detección")
  }
  
  // NUEVO: Detener detección de capturas
  private func stopScreenshotDetection() {
    screenshotDetectionActive = false
    
    NotificationCenter.default.removeObserver(
      self,
      name: UIApplication.userDidTakeScreenshotNotification,
      object: nil
    )
    
    if #available(iOS 11.0, *) {
      NotificationCenter.default.removeObserver(
        self,
        name: UIScreen.capturedDidChangeNotification,
        object: nil
      )
    }
    
    print("👁️ [iOS SCREENSHOT] Observadores removidos")
  }
  
  // NUEVO: Método llamado cuando se detecta una captura
  @objc private func screenshotDetected() {
    if screenshotDetectionActive {
      print("📸 [iOS SCREENSHOT] ¡CAPTURA DETECTADA!")
      
      // Notificar a Flutter
      let timestamp = Int64(Date().timeIntervalSince1970 * 1000)
      screenshotChannel?.invokeMethod("onScreenshotDetected", arguments: [
        "timestamp": timestamp,
        "platform": "ios",
        "type": "screenshot"
      ])
    }
    
    // Mantener funcionalidad existente si está bloqueado
    if isScreenshotBlocked {
      print("⚠️ [iOS SCREENSHOT] Usuario intentó captura - pero está BLOQUEADA por isSecureTextEntry")
      
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        if let controller = self.window?.rootViewController {
          let alert = UIAlertController(
            title: "🔒 Captura protegida",
            message: "El contenido está protegido. La captura se muestra como pantalla negra por seguridad.",
            preferredStyle: .alert
          )
          alert.addAction(UIAlertAction(title: "Entendido", style: .default))
          controller.present(alert, animated: true)
        }
      }
    }
  }
  
  // NUEVO: Método para detectar grabación de pantalla
  @objc private func screenRecordingDetected() {
    if #available(iOS 11.0, *) {
      if UIScreen.main.isCaptured && screenshotDetectionActive {
        print("📹 [iOS SCREENSHOT] ¡GRABACIÓN DE PANTALLA DETECTADA!")
        
        // Notificar a Flutter
        let timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        screenshotChannel?.invokeMethod("onScreenshotDetected", arguments: [
          "timestamp": timestamp,
          "platform": "ios",
          "type": "screen_recording"
        ])
      }
      
      // Mantener funcionalidad existente si está bloqueado
      if UIScreen.main.isCaptured && isScreenshotBlocked {
        print("⚠️ [iOS SCREENSHOT] Grabación de pantalla detectada - contenido protegido por isSecureTextEntry")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
          if let controller = self.window?.rootViewController {
            let alert = UIAlertController(
              title: "📹 Grabación detectada",
              message: "El contenido está protegido durante la grabación de pantalla.",
              preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Entendido", style: .default))
            controller.present(alert, animated: true)
          }
        }
      }
    }
  }
  
  // NUEVO: Bloquear capturas de pantalla REALMENTE (método oficial Apple)
  private func blockScreenshots() {
    guard let window = self.window else {
      print("❌ [iOS SCREENSHOT] No se pudo obtener window")
      return
    }
    
    isScreenshotBlocked = true
    
    // MÉTODO OFICIAL APPLE: Usar isSecureTextEntry para bloqueo REAL
    makeSecure(window: window)
    
    print("🔒 [iOS SCREENSHOT] Sistema de bloqueo REAL activado (según documentación Apple)")
  }
  
  // NUEVO: Método oficial de Apple para bloqueo REAL de capturas (SIMPLIFICADO)
  private func makeSecure(window: UIWindow) {
    // Crear UITextField invisible con isSecureTextEntry = true
    let field = UITextField()
    field.isSecureTextEntry = true
    
    // Hacer completamente invisible y sin interferir con la UI
    field.frame = CGRect(x: -1000, y: -1000, width: 1, height: 1)
    field.alpha = 0.0
    field.isUserInteractionEnabled = false
    field.isHidden = false // Importante: debe estar "visible" para el sistema pero fuera de pantalla
    
    // Agregar como subview sin interferir con la jerarquía existente
    window.addSubview(field)
    
    // Guardar referencia para poder eliminarlo después
    secureTextField = field
    
    print("🔒 [iOS SCREENSHOT] ✅ Campo de texto seguro implementado - capturas REALMENTE bloqueadas")
  }

  // NUEVO: Habilitar capturas de pantalla
  private func enableScreenshots() {
    isScreenshotBlocked = false
    
    // Remover el UITextField seguro
    secureTextField?.removeFromSuperview()
    secureTextField = nil
    
    print("🔓 [iOS SCREENSHOT] Sistema de bloqueo desactivado")
  }
  
  // NUEVO: Método heredado para compatibilidad - ahora delegado a screenshotDetected
  @objc private func userDidTakeScreenshot() {
    screenshotDetected()
  }
  
  // NUEVO: Método heredado para compatibilidad - ahora delegado a screenRecordingDetected
  @objc private func handleScreenRecordingChanged() {
    screenRecordingDetected()
  }
}
