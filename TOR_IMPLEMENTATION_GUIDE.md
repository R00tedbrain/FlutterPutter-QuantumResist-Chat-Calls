# 🌐 GUÍA DE IMPLEMENTACIÓN TOR - FASE 1

## ✅ **LO QUE SE HA IMPLEMENTADO**

### 🏗️ **ARQUITECTURA COMPLETA**

```
📱 Flutter App
    ├── 🌐 TorService (Core)
    ├── ⚙️ TorConfigurationService (Configuración Persistente)
    ├── 🏭 TorHttpClientFactory (Factory HttpClient)
    ├── 🔗 TorApiIntegration (Integración con API)
    └── 📱 TorConfigurationWidget (UI)
```

---

## 🔧 **SERVICIOS IMPLEMENTADOS**

### 1️⃣ **TorService** (`lib/services/tor_service.dart`)
- ✅ Gestión central de conexiones Tor
- ✅ Proxy SOCKS5 automático 
- ✅ Test de conectividad
- ✅ Logs extensivos de debug
- ✅ Fallback automático a HTTP normal

### 2️⃣ **TorConfigurationService** (`lib/services/tor_configuration_service.dart`)
- ✅ Configuración persistente con SharedPreferences
- ✅ Enable/disable Tor por usuario
- ✅ Configuración custom de host:puerto
- ✅ Primera configuración automática

### 3️⃣ **TorHttpClientFactory** (`lib/services/tor_http_client_factory.dart`)
- ✅ Factory para HttpClient con proxy Tor
- ✅ Compatibilidad 100% con código existente
- ✅ Fallback seguro en caso de error

### 4️⃣ **TorApiIntegration** (`lib/services/tor_api_integration.dart`)
- ✅ Reemplazo directo de ApiService cuando se necesite Tor
- ✅ Métodos: GET, POST, PUT, DELETE con Tor
- ✅ Mantiene compatibilidad total con API existente
- ✅ Fallback automático a HTTP estándar

### 5️⃣ **TorConfigurationWidget** (`lib/widgets/tor_configuration_widget.dart`)
- ✅ UI completa para configurar Tor
- ✅ Toggle simple on/off
- ✅ Test de conectividad en tiempo real
- ✅ Configuración avanzada (host/puerto)
- ✅ Debug logs en tiempo real

---

## 🚀 **INICIALIZACIÓN AUTOMÁTICA**

### En `main.dart`:
```dart
// 🌐 Inicialización automática en app startup
await TorConfigurationService.initialize();
```

**LO QUE HACE:**
- ✅ Carga configuración guardada del usuario
- ✅ Inicializa TorService con configuración
- ✅ Funciona sin intervención del usuario
- ✅ Fallback seguro si hay errores

---

## 📱 **CÓMO USAR LA UI**

### Integrar el widget en cualquier pantalla:

```dart
import 'package:flutterputter/widgets/tor_configuration_widget.dart';

// En tu widget build():
TorConfigurationWidget(
  showAdvancedOptions: true,   // Mostrar config host/puerto
  showDebugLogs: true,         // Mostrar logs de debug
  onConfigurationChanged: () {
    // Callback cuando cambia la configuración
  },
)
```

**CARACTERÍSTICAS DEL WIDGET:**
- 🔘 Toggle simple para habilitar/deshabilitar Tor
- 🧪 Botón "Probar Conexión" con timing
- ⚙️ Configuración avanzada de host/puerto
- 📊 Estado de conexión en tiempo real
- 📝 Logs de debug expandibles
- ❌ Manejo de errores visual

---

## 🔗 **CÓMO USAR TOR EN TU CÓDIGO**

### **OPCIÓN 1: Usar TorApiIntegration (Recomendado)**

```dart
import 'package:flutterputter/services/tor_api_integration.dart';

// Reemplazar ApiService.get() con:
final response = await TorApiIntegration.get('/auth/login', token);

// Reemplazar ApiService.post() con:
final response = await TorApiIntegration.post('/auth/register', data, token);
```

**VENTAJAS:**
- ✅ Automáticamente usa Tor si está habilitado
- ✅ Fallback a HTTP normal si Tor está deshabilitado
- ✅ Misma API que ApiService existente
- ✅ No necesitas verificar estado manualmente

### **OPCIÓN 2: Verificar estado manualmente**

```dart
import 'package:flutterputter/services/tor_configuration_service.dart';

// Verificar si Tor está habilitado
final isTorEnabled = await TorConfigurationService.isTorEnabled();

if (isTorEnabled) {
  // Usar TorApiIntegration
  final response = await TorApiIntegration.get(endpoint, token);
} else {
  // Usar ApiService normal
  final response = await ApiService.get(endpoint, token);
}
```

---

## 📊 **DEBUGGING Y MONITOREO**

### **Ver estado completo de Tor:**

```dart
// Estado de configuración
final config = await TorConfigurationService.getConfiguration();
print('Tor enabled: ${config['enabled']}');
print('Host: ${config['host']}');
print('Port: ${config['port']}');

// Estado de servicios
final status = await TorApiIntegration.getTorStatus();
print('TorService: ${status['torService']}');
print('TorConfiguration: ${status['torConfiguration']}');
```

### **Test manual de conectividad:**

```dart
final isConnected = await TorApiIntegration.testTorConnectivity();
print('Tor connectivity: ${isConnected ? "OK" : "FAILED"}');
```

---

## 🛡️ **SEGURIDAD Y MEJORES PRÁCTICAS**

### ✅ **LO QUE ESTÁ PROTEGIDO:**

1. **Configuración Persistente**: Se guarda de forma segura en SharedPreferences
2. **Fallback Automático**: Si Tor falla, usa conexión directa sin romper la app
3. **Validación de Parámetros**: Host/puerto son validados antes de aplicar
4. **Error Handling**: Manejo completo de errores sin crashes
5. **No Modifica Código Existente**: Todo el código actual sigue funcionando igual

### ✅ **CONFIGURACIÓN RECOMENDADA:**

```dart
// Para desarrollo/testing
TorConfigurationWidget(
  showAdvancedOptions: true,   // Permitir cambiar host/puerto
  showDebugLogs: true,         // Ver logs detallados
)

// Para producción
TorConfigurationWidget(
  showAdvancedOptions: false,  // Solo toggle on/off
  showDebugLogs: false,        // Sin logs sensibles
)
```

---

## 🧪 **TESTING**

### **Test básico de funcionamiento:**

1. **Ejecutar la app**:
   ```bash
   flutter run
   ```

2. **Verificar logs en consola**:
   ```
   🔐 [MAIN] TorConfigurationService inicializado correctamente
   📊 [MAIN] Estado inicial Tor: DESHABILITADO
   ```

3. **En la UI del widget**:
   - ✅ Toggle debe aparecer en OFF
   - ✅ Debe mostrar "Usando conexiones directas"
   - ✅ Al activar debe intentar test de conectividad

### **Test con Tor Browser (Opcional)**:

1. **Abrir Tor Browser** en tu sistema
2. **En la app**: Habilitar Tor
3. **Verificar**: Debe conectar automáticamente al proxy de Tor Browser

---

## 🔄 **FLUJO COMPLETO DE DATOS**

### **SIN TOR (Por defecto):**
```
App → ApiService → HTTP directo → Servidor
```

### **CON TOR HABILITADO:**
```
App → TorApiIntegration → TorService → SOCKS5 Proxy → Red Tor → Servidor
```

**CRÍTICO**: El usuario decide cuándo usar Tor. La app funciona igual en ambos casos.

---

## 📋 **PRÓXIMOS PASOS (FASE 2)**

Una vez que esta FASE 1 funcione correctamente:

1. **🎥 Integración con Videollamadas**:
   - Tor para signaling WebRTC
   - Botón dual "Llamar Normal" vs "Llamar por Tor"

2. **⚡ Optimizaciones**:
   - Tor persistente (evitar reconectar)
   - Circuit management avanzado
   - Latency optimization

3. **🔧 Funciones Avanzadas**:
   - Bridge support para censura
   - Onion services para P2P directo
   - Multi-hop proxy chaining

---

## ❗ **IMPORTANTE PARA TESTING**

### **REQUISITOS:**
1. **Tor debe estar ejecutándose** en el sistema:
   - 🍎 **macOS**: `brew install tor && tor`
   - 🐧 **Linux**: `sudo apt install tor && tor`
   - 🪟 **Windows**: Tor Browser o Tor Expert Bundle

2. **Puerto por defecto**: `127.0.0.1:9050` (SOCKS5)

3. **Verificar conectividad**:
   ```bash
   # Test manual del proxy Tor
   curl --socks5 127.0.0.1:9050 https://check.torproject.org/api/ip
   ```

### **SI TOR NO ESTÁ INSTALADO:**
- ✅ La app funciona NORMALMENTE sin Tor
- ✅ El widget muestra errores de conectividad claros
- ✅ Todo el tráfico va por HTTP directo (modo actual)

---

## 📞 **SOPORTE**

Si encuentras algún problema:

1. **Revisar logs de debug** en el widget de configuración
2. **Verificar estado** con `getTorStatus()`
3. **Test manual** de conectividad Tor en sistema
4. **Fallback**: Deshabilitar Tor y usar conexiones directas

**RECUERDA**: Tor es OPCIONAL. La app debe funcionar perfectamente sin él. ✨ 