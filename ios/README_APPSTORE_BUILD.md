# Instrucciones para construir FlutterPutter para App Store

## Errores solucionados

### ✅ 1. Error de validación en Info.plist
- **Problema**: Valor inválido `background-processing` en `UIBackgroundModes`
- **Solución**: Removido `background-processing`, manteniendo solo `audio` y `voip`

### ✅ 2. Problemas de dSYM para frameworks
- **Problema**: Los frameworks WebRTC y flutter_webrtc no generaban archivos dSYM
- **Solución**: Configurado el Podfile para forzar la generación de dSYM en Release y Profile

### ✅ 3. Archivo de entitlements simplificado
- **Problema**: Entitlements complejos que requerían configuración especial en Apple Developer
- **Solución**: Creado `Runner.entitlements` con permisos básicos:
  - Acceso a cámara en multitarea (`com.apple.developer.avfoundation.multitasking-camera-access`)

### ✅ 4. Configuración de firma automática
- **Problema**: Faltaba `CODE_SIGN_STYLE = Automatic` en las configuraciones
- **Solución**: Agregado a todas las configuraciones de build (Debug, Release, Profile)

## Pasos para construir desde Xcode

### 1. Preparación
```bash
cd videollamadas_app/frontend/videollamadas
flutter clean
flutter pub get
cd ios
pod install
```

### 2. Abrir en Xcode
```bash
open Runner.xcworkspace
```

### 3. Configuración en Xcode
1. Selecciona el target **Runner**
2. Ve a **Signing & Capabilities**
3. Asegúrate de que tu **Team** esté seleccionado
4. Verifica que **Bundle Identifier** sea: `com.flutterputter.bwt`
5. El **Provisioning Profile** se configurará automáticamente

### 4. Configuración de Build
1. Selecciona **Product > Scheme > Edit Scheme**
2. En **Archive**, asegúrate de que **Build Configuration** esté en **Release**
3. Ve a **Build Settings** del target Runner
4. Verifica que:
   - `DEBUG_INFORMATION_FORMAT` = `dwarf-with-dsym` (para Release y Profile)
   - `CODE_SIGN_ENTITLEMENTS` = `Runner/Runner.entitlements`
   - `CODE_SIGN_STYLE` = `Automatic`

### 5. Construir para App Store
1. Selecciona **Product > Archive**
2. Una vez completado, se abrirá **Organizer**
3. Selecciona tu archivo y haz clic en **Distribute App**
4. Sigue el proceso de distribución de Apple

## Verificaciones importantes

### Archivos dSYM generados
Los siguientes archivos dSYM deben generarse automáticamente:
- `Runner.app.dSYM`
- `App.framework.dSYM`
- `flutter_webrtc.app.dSYM`
- `fluttertoast.app.dSYM`
- `shared_preferences_foundation.app.dSYM`
- `path_provider_foundation.app.dSYM`

### Configuraciones aplicadas
- ✅ `UIBackgroundModes` corregido en Info.plist
- ✅ Entitlements básicos configurados
- ✅ dSYM habilitado para todos los frameworks
- ✅ Configuración de Pods actualizada
- ✅ Proyecto Xcode configurado correctamente
- ✅ Firma automática habilitada

## Notas importantes

1. **Entitlements simplificados**: Solo incluimos permisos básicos que no requieren configuración especial en Apple Developer Program.

2. **Background modes**: Los background modes están configurados en `Info.plist`, no en entitlements.

3. **WebRTC Framework**: El framework WebRTC-SDK es precompilado y no genera dSYM propio, esto es normal.

4. **Configuración automática**: Todas las configuraciones se aplican automáticamente al hacer `pod install`.

5. **Validación**: Si encuentras errores de validación, verifica que:
   - El archivo `Runner.entitlements` esté presente
   - Las configuraciones de build estén correctas
   - El bundle identifier coincida con tu App Store Connect
   - Tu equipo de desarrollo esté seleccionado en Xcode

6. **Debugging**: Si necesitas debug symbols para crash reports, los archivos dSYM se subirán automáticamente a App Store Connect durante la distribución.

## Solución de problemas

### Si aparece error de provisioning profile:
1. Ve a **Signing & Capabilities** en Xcode
2. Cambia temporalmente a **Manual** y luego de vuelta a **Automatic**
3. Asegúrate de que tu Apple ID esté configurado en Xcode Preferences

### Si aparece error de entitlements:
- Los entitlements están simplificados para evitar problemas con provisioning profiles básicos
- Solo incluyen permisos que no requieren configuración especial 