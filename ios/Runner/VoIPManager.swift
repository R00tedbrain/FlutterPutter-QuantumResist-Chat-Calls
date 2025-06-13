import UIKit
import PushKit
import CallKit
import AVFoundation

@available(iOS 10.0, *)
class VoIPManager: NSObject {
    static let shared = VoIPManager()
    
    private let voipRegistry = PKPushRegistry(queue: DispatchQueue.main)
    private let callController = CXCallController()
    private var provider: CXProvider?
    
    // NUEVO: Guardar token para reintentos
    private var currentVoIPToken: String?
    private var tokenRetryTimer: Timer?
    
    // NUEVO: Tracking de llamadas activas para evitar doble procesamiento
    private var activeCalls: [UUID: String] = [:]
    private var pendingCallActions: [UUID: Bool] = [:]
    
    override init() {
        super.init()
        setupCallKit()
        setupVoIP()
    }
    
    private func setupCallKit() {
        let configuration = CXProviderConfiguration(localizedName: "FlutterPutter")
        configuration.supportsVideo = true
        configuration.maximumCallGroups = 1
        configuration.maximumCallsPerCallGroup = 1
        configuration.supportedHandleTypes = [.generic]
        
        // 🍎 NUEVO: Configurar icono de la app para CallKit (SOLUCIÓN OFICIAL APPLE)
        if let iconImage = UIImage(named: "AppIcon") {
            configuration.iconTemplateImageData = iconImage.pngData()
        }
        
        provider = CXProvider(configuration: configuration)
        provider?.setDelegate(self, queue: nil)
    }
    
    private func setupVoIP() {
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = [.voIP]
    }
    
    func reportIncomingCall(uuid: UUID, handle: String, hasVideo: Bool = true) {
        // Verificar si ya estamos manejando esta llamada
        if activeCalls[uuid] != nil {
            print("⚠️ [VoIP] Llamada \(uuid) ya está siendo manejada, ignorando duplicado")
            return
        }
        
        print("📱 [VoIP] Reportando nueva llamada entrante: \(handle)")
        activeCalls[uuid] = handle
        
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: handle)
        update.hasVideo = hasVideo
        
        provider?.reportNewIncomingCall(with: uuid, update: update) { error in
            if let error = error {
                print("❌ [VoIP] Error reporting incoming call: \(error)")
                // Limpiar el tracking si hay error
                self.activeCalls.removeValue(forKey: uuid)
            } else {
                print("✅ [VoIP] Llamada reportada exitosamente: \(uuid)")
            }
        }
    }
    
    // NUEVO: Terminar llamada específica
    func endCall(uuid: UUID) {
        print("🔚 [VoIP] Terminando llamada: \(uuid)")
        
        let endCallAction = CXEndCallAction(call: uuid)
        let transaction = CXTransaction(action: endCallAction)
        
        callController.request(transaction) { error in
            if let error = error {
                print("❌ [VoIP] Error terminando llamada: \(error)")
            } else {
                print("✅ [VoIP] Llamada terminada exitosamente: \(uuid)")
                self.activeCalls.removeValue(forKey: uuid)
                self.pendingCallActions.removeValue(forKey: uuid)
            }
        }
    }
    
    // NUEVO: Terminar todas las llamadas
    func endAllCalls() {
        print("🔚 [VoIP] Terminando todas las llamadas activas")
        
        for uuid in activeCalls.keys {
            endCall(uuid: uuid)
        }
    }
    
    // NUEVO: Método para enviar token al servidor
    private func sendTokenToServer(_ token: String) {
        // Obtener el userId del UserDefaults o de donde lo tengas guardado
        guard let userId = UserDefaults.standard.string(forKey: "currentUserId") else {
            print("❌ [VoIP] No userId found, saving token for later")
            // Guardar el token para enviarlo cuando tengamos el userId
            self.currentVoIPToken = token
            return
        }
        
        // URL de tu servidor VPS para registrar tokens VoIP
        let serverURL = "http://192.142.10.106:3004/api/register-voip-token" // URL corregida
        
        guard let url = URL(string: serverURL) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Si tienes un token de autenticación, agrégalo aquí
        if let authToken = UserDefaults.standard.string(forKey: "authToken") {
            request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }
        
        let body: [String: Any] = [
            "userId": userId,
            "voipToken": token,
            "platform": "ios",
            "bundleId": Bundle.main.bundleIdentifier ?? "",
            "environment": "production", // o "sandbox" para desarrollo
            "deviceModel": UIDevice.current.model,
            "systemVersion": UIDevice.current.systemVersion
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            print("❌ [VoIP] Error creating request body: \(error)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ [VoIP] Error sending token to server: \(error)")
                // Reintentar después de 30 segundos
                self.scheduleTokenRetry(token)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    print("✅ [VoIP] Token successfully sent to server")
                    // Cancelar cualquier reintento pendiente
                    self.tokenRetryTimer?.invalidate()
                    self.tokenRetryTimer = nil
                } else {
                    print("❌ [VoIP] Server returned status: \(httpResponse.statusCode)")
                    // Reintentar si no fue exitoso
                    self.scheduleTokenRetry(token)
                }
            }
        }
        
        task.resume()
    }
    
    // NUEVO: Programar reintento de envío de token
    private func scheduleTokenRetry(_ token: String) {
        tokenRetryTimer?.invalidate()
        tokenRetryTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: false) { _ in
            print("🔄 [VoIP] Retrying to send token...")
            self.sendTokenToServer(token)
        }
    }
    
    // NUEVO: Método público para enviar token pendiente
    func sendPendingTokenIfNeeded() {
        if let token = currentVoIPToken {
            print("📤 [VoIP] Sending pending token...")
            sendTokenToServer(token)
        }
    }
}

// MARK: - PKPushRegistryDelegate
@available(iOS 10.0, *)
extension VoIPManager: PKPushRegistryDelegate {
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        let token = pushCredentials.token.map { String(format: "%02.2hhx", $0) }.joined()
        print("VoIP Token: \(token)")
        
        // Guardar token localmente
        currentVoIPToken = token
        UserDefaults.standard.set(token, forKey: "voipToken")
        
        // NUEVO: Enviar token al servidor inmediatamente
        sendTokenToServer(token)
        
        // Enviar token al servidor Flutter (mantener compatibilidad)
        NotificationCenter.default.post(
            name: NSNotification.Name("VoIPTokenReceived"),
            object: nil,
            userInfo: ["token": token]
        )
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        guard type == .voIP else {
            completion()
            return
        }
        
        // Procesar notificación VoIP
        let callUUID = UUID()
        let callerName = payload.dictionaryPayload["caller_name"] as? String ?? "Unknown"
        
        reportIncomingCall(uuid: callUUID, handle: callerName)
        completion()
    }
}

// MARK: - CXProviderDelegate
@available(iOS 10.0, *)
extension VoIPManager: CXProviderDelegate {
    func providerDidReset(_ provider: CXProvider) {
        // Reset cuando el provider se reinicia
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        let callUUID = action.callUUID
        
        // Verificar si ya procesamos esta acción
        if pendingCallActions[callUUID] == true {
            print("⚠️ [VoIP] Acción de respuesta ya está siendo procesada para: \(callUUID)")
            action.fulfill()
            return
        }
        
        print("✅ [VoIP] Usuario acepta la llamada: \(callUUID)")
        pendingCallActions[callUUID] = true
        
        // Notificar a Flutter que la llamada fue aceptada
        NotificationCenter.default.post(
            name: NSNotification.Name("CallAnswered"),
            object: nil,
            userInfo: [
                "callUUID": callUUID.uuidString,
                "timestamp": Date().timeIntervalSince1970,
                "source": "callkit_native"
            ]
        )
        
        action.fulfill()
        
        // Marcar como procesada después de 2 segundos para evitar duplicados inmediatos
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.pendingCallActions.removeValue(forKey: callUUID)
        }
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        let callUUID = action.callUUID
        
        print("🔚 [VoIP] Usuario termina la llamada: \(callUUID)")
        
        // Limpiar el tracking de esta llamada
        activeCalls.removeValue(forKey: callUUID)
        pendingCallActions.removeValue(forKey: callUUID)
        
        // Notificar a Flutter que la llamada fue terminada
        NotificationCenter.default.post(
            name: NSNotification.Name("CallEnded"),
            object: nil,
            userInfo: [
                "callUUID": callUUID.uuidString,
                "timestamp": Date().timeIntervalSince1970,
                "source": "callkit_native"
            ]
        )
        
        action.fulfill()
    }
} 