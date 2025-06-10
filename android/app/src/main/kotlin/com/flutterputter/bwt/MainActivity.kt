package com.flutterputter.bwt

import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
// NUEVO: Imports para detección de capturas
import android.database.ContentObserver
import android.provider.MediaStore
import android.os.Handler
import android.os.Looper
import android.net.Uri
import android.content.Context

class MainActivity : FlutterActivity() {
    private val CHANNEL = "screenshot_security"
    private var isScreenshotBlocked = false
    // NUEVO: Variables para detección de capturas
    private var screenshotObserver: ContentObserver? = null
    private var isScreenshotDetectionActive = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // NUEVO: Configurar canal de comunicación para capturas de pantalla
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "blockScreenshots" -> {
                    blockScreenshots()
                    result.success(true)
                    println("🔒 [ANDROID SCREENSHOT] Capturas BLOQUEADAS")
                }
                "enableScreenshots" -> {
                    enableScreenshots() 
                    result.success(true)
                    println("🔓 [ANDROID SCREENSHOT] Capturas HABILITADAS")
                }
                // NUEVO: Métodos para detección
                "startScreenshotDetection" -> {
                    startScreenshotDetection(flutterEngine)
                    result.success(true)
                    println("👁️ [ANDROID SCREENSHOT] Detección INICIADA")
                }
                "stopScreenshotDetection" -> {
                    stopScreenshotDetection()
                    result.success(true)
                    println("👁️ [ANDROID SCREENSHOT] Detección DETENIDA")
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
        
        println("✅ [ANDROID SCREENSHOT] Canal de comunicación configurado")
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        println("📱 [ANDROID SCREENSHOT] MainActivity creada")
    }

    // NUEVO: Bloquear capturas de pantalla de forma REAL
    private fun blockScreenshots() {
        try {
            // Método 1: FLAG_SECURE - Bloquea capturas y grabación de pantalla
            window.setFlags(
                WindowManager.LayoutParams.FLAG_SECURE,
                WindowManager.LayoutParams.FLAG_SECURE
            )
            
            isScreenshotBlocked = true
            println("🔒 [ANDROID SCREENSHOT] FLAG_SECURE activado - Capturas completamente bloqueadas")
            
        } catch (e: Exception) {
            println("❌ [ANDROID SCREENSHOT] Error bloqueando capturas: ${e.message}")
        }
    }

    // NUEVO: Habilitar capturas de pantalla
    private fun enableScreenshots() {
        try {
            // Remover FLAG_SECURE
            window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
            
            isScreenshotBlocked = false
            println("🔓 [ANDROID SCREENSHOT] FLAG_SECURE desactivado - Capturas habilitadas")
            
        } catch (e: Exception) {
            println("❌ [ANDROID SCREENSHOT] Error habilitando capturas: ${e.message}")
        }
    }

    // NUEVO: Iniciar detección de capturas de pantalla
    private fun startScreenshotDetection(flutterEngine: FlutterEngine) {
        if (isScreenshotDetectionActive) {
            println("👁️ [ANDROID SCREENSHOT] Detección ya está activa")
            return
        }

        try {
            val handler = Handler(Looper.getMainLooper())
            val methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            
            screenshotObserver = object : ContentObserver(handler) {
                override fun onChange(selfChange: Boolean, uri: Uri?) {
                    super.onChange(selfChange, uri)
                    
                    // Verificar si es una captura de pantalla
                    if (uri != null && isScreenshotUri(uri)) {
                        println("📸 [ANDROID SCREENSHOT] ¡CAPTURA DETECTADA! URI: $uri")
                        
                        // Notificar a Flutter
                        handler.post {
                            methodChannel.invokeMethod("onScreenshotDetected", mapOf(
                                "timestamp" to System.currentTimeMillis(),
                                "platform" to "android",
                                "uri" to uri.toString()
                            ))
                        }
                    }
                }
            }
            
            // Registrar el observer para cambios en MediaStore
            contentResolver.registerContentObserver(
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                true,
                screenshotObserver!!
            )
            
            isScreenshotDetectionActive = true
            println("👁️ [ANDROID SCREENSHOT] Observer registrado exitosamente")
            
        } catch (e: Exception) {
            println("❌ [ANDROID SCREENSHOT] Error iniciando detección: ${e.message}")
        }
    }
    
    // NUEVO: Detener detección de capturas
    private fun stopScreenshotDetection() {
        try {
            screenshotObserver?.let { observer ->
                contentResolver.unregisterContentObserver(observer)
                screenshotObserver = null
                isScreenshotDetectionActive = false
                println("👁️ [ANDROID SCREENSHOT] Observer desregistrado")
            }
        } catch (e: Exception) {
            println("❌ [ANDROID SCREENSHOT] Error deteniendo detección: ${e.message}")
        }
    }
    
    // NUEVO: Verificar si la URI corresponde a una captura de pantalla
    private fun isScreenshotUri(uri: Uri): Boolean {
        return try {
            val cursor = contentResolver.query(
                uri,
                arrayOf(MediaStore.Images.Media.DISPLAY_NAME, MediaStore.Images.Media.DATA),
                null, null, null
            )
            
            cursor?.use {
                if (it.moveToFirst()) {
                    val displayName = it.getString(it.getColumnIndexOrThrow(MediaStore.Images.Media.DISPLAY_NAME))
                    val data = it.getString(it.getColumnIndexOrThrow(MediaStore.Images.Media.DATA))
                    
                    // Verificar patrones comunes de capturas de pantalla
                    val isScreenshot = displayName?.contains("screenshot", ignoreCase = true) == true ||
                                     displayName?.contains("screen", ignoreCase = true) == true ||
                                     data?.contains("Screenshots", ignoreCase = true) == true ||
                                     data?.contains("screenshot", ignoreCase = true) == true
                    
                    println("👁️ [ANDROID SCREENSHOT] Verificando: $displayName -> $isScreenshot")
                    return isScreenshot
                }
            }
            false
        } catch (e: Exception) {
            println("❌ [ANDROID SCREENSHOT] Error verificando URI: ${e.message}")
            false
        }
    }

    override fun onResume() {
        super.onResume()
        // Mantener el estado de bloqueo al volver a la actividad
        if (isScreenshotBlocked) {
            window.setFlags(
                WindowManager.LayoutParams.FLAG_SECURE,
                WindowManager.LayoutParams.FLAG_SECURE
            )
            println("🔒 [ANDROID SCREENSHOT] FLAG_SECURE reactivado en onResume")
        }
    }
    
    override fun onDestroy() {
        super.onDestroy()
        // Limpiar recursos
        stopScreenshotDetection()
        println("🧹 [ANDROID SCREENSHOT] Recursos limpiados")
    }
} 