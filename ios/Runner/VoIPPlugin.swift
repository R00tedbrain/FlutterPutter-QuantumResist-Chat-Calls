import Flutter
import UIKit

public class VoIPPlugin: NSObject, FlutterPlugin {
    private var channel: FlutterMethodChannel?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "voip_native", binaryMessenger: registrar.messenger())
        let instance = VoIPPlugin()
        instance.channel = channel
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        // Configurar listeners para eventos VoIP
        instance.setupNotificationListeners()
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initializeVoIP":
            initializeVoIP(result: result)
        case "reportIncomingCall":
            if let args = call.arguments as? [String: Any] {
                reportIncomingCall(args: args, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            }
        case "endCall":
            if let args = call.arguments as? [String: Any],
               let callUUID = args["callUUID"] as? String {
                endCall(callUUID: callUUID, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing callUUID", details: nil))
            }
        case "endAllCalls":
            endAllCalls(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func initializeVoIP(result: @escaping FlutterResult) {
        if #available(iOS 10.0, *) {
            _ = VoIPManager.shared
            result(true)
        } else {
            result(FlutterError(code: "UNSUPPORTED_VERSION", message: "iOS 10.0+ required", details: nil))
        }
    }
    
    private func reportIncomingCall(args: [String: Any], result: @escaping FlutterResult) {
        guard #available(iOS 10.0, *) else {
            result(FlutterError(code: "UNSUPPORTED_VERSION", message: "iOS 10.0+ required", details: nil))
            return
        }
        
        let uuid = UUID()
        let callerName = args["callerName"] as? String ?? "Unknown"
        let hasVideo = args["hasVideo"] as? Bool ?? true
        
        VoIPManager.shared.reportIncomingCall(uuid: uuid, handle: callerName, hasVideo: hasVideo)
        result(uuid.uuidString)
    }
    
    private func endCall(callUUID: String, result: @escaping FlutterResult) {
        guard #available(iOS 10.0, *) else {
            result(FlutterError(code: "UNSUPPORTED_VERSION", message: "iOS 10.0+ required", details: nil))
            return
        }
        
        guard let uuid = UUID(uuidString: callUUID) else {
            result(FlutterError(code: "INVALID_UUID", message: "Invalid UUID format", details: nil))
            return
        }
        
        VoIPManager.shared.endCall(uuid: uuid)
        result(true)
    }
    
    private func endAllCalls(result: @escaping FlutterResult) {
        guard #available(iOS 10.0, *) else {
            result(FlutterError(code: "UNSUPPORTED_VERSION", message: "iOS 10.0+ required", details: nil))
            return
        }
        
        VoIPManager.shared.endAllCalls()
        result(true)
    }
    
    private func setupNotificationListeners() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(voipTokenReceived(_:)),
            name: NSNotification.Name("VoIPTokenReceived"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(callAnswered(_:)),
            name: NSNotification.Name("CallAnswered"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(callEnded(_:)),
            name: NSNotification.Name("CallEnded"),
            object: nil
        )
    }
    
    @objc private func voipTokenReceived(_ notification: Notification) {
        if let token = notification.userInfo?["token"] as? String {
            channel?.invokeMethod("onVoIPTokenReceived", arguments: ["token": token])
        }
    }
    
    @objc private func callAnswered(_ notification: Notification) {
        if let callUUID = notification.userInfo?["callUUID"] as? String {
            let timestamp = notification.userInfo?["timestamp"] as? Double
            let source = notification.userInfo?["source"] as? String
            
            var arguments: [String: Any] = ["callUUID": callUUID]
            if let timestamp = timestamp {
                arguments["timestamp"] = timestamp
            }
            if let source = source {
                arguments["source"] = source
            }
            
            channel?.invokeMethod("onCallAnswered", arguments: arguments)
        }
    }
    
    @objc private func callEnded(_ notification: Notification) {
        if let callUUID = notification.userInfo?["callUUID"] as? String {
            let timestamp = notification.userInfo?["timestamp"] as? Double
            let source = notification.userInfo?["source"] as? String
            
            var arguments: [String: Any] = ["callUUID": callUUID]
            if let timestamp = timestamp {
                arguments["timestamp"] = timestamp
            }
            if let source = source {
                arguments["source"] = source
            }
            
            channel?.invokeMethod("onCallEnded", arguments: arguments)
        }
    }
} 