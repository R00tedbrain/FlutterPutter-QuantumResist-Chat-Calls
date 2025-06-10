# Configuración iOS para FlutterPutter

## Permisos Configurados

### Permisos de Privacidad (Info.plist)
- ✅ **NSCameraUsageDescription**: Acceso a la cámara para videollamadas
- ✅ **NSMicrophoneUsageDescription**: Acceso al micrófono para llamadas de voz y video
- ✅ **NSLocalNetworkUsageDescription**: Acceso a la red local para conexiones WebRTC
- ✅ **NSPhotoLibraryUsageDescription**: Acceso a la galería para compartir imágenes

### Background Modes
- ✅ **audio**: Para mantener audio en background
- ✅ **voip**: Para llamadas VoIP
- ✅ **background-processing**: Para procesamiento en segundo plano

### Configuraciones de Seguridad
- ✅ **NSAppTransportSecurity**: Configurado para permitir localhost en desarrollo
- ✅ **ITSAppUsesNonExemptEncryption**: Configurado como false para App Store

## Configuración para App Store

### 1. Antes de Subir a App Store

1. **Actualizar Team ID y Bundle ID**:
   - Abrir `ios/ExportOptions.plist`
   - Reemplazar `YOUR_TEAM_ID` con tu Team ID de Apple Developer
   - Reemplazar `com.yourcompany.flutterputter` con tu Bundle ID real

2. **Configurar Signing en Xcode**:
   ```bash
   cd ios
   open Runner.xcworkspace
   ```
   - Seleccionar el proyecto Runner
   - En "Signing & Capabilities", configurar tu Team y Bundle Identifier

### 2. Generar Build para App Store

#### Opción A: Usando el Script Automático
```bash
cd ios
./generate_dsym.sh
```

#### Opción B: Usando Flutter
```bash
# Desde el directorio raíz del proyecto Flutter
flutter build ios --release
```

#### Opción C: Usando Xcode
1. Abrir `ios/Runner.xcworkspace`
2. Seleccionar "Any iOS Device" como destino
3. Product → Archive
4. En Organizer, seleccionar "Distribute App"
5. Elegir "App Store Connect"

### 3. Archivos dSYM

Los archivos dSYM se generan automáticamente y son necesarios para:
- Crash reporting en App Store Connect
- Debugging de crashes en producción
- Análisis de rendimiento

**Ubicación de dSYM**:
- Automático: `build/ios/archive/Runner.xcarchive/dSYMs/`
- Xcode: En el Organizer después del archive

## Configuraciones Técnicas

### Versión Mínima de iOS
- **iOS 12.0+** (configurado en Podfile)

### WebRTC Configuraciones
- Bitcode deshabilitado (requerido para WebRTC)
- Arquitecturas soportadas: arm64, x86_64
- Swift 5.0

### Capacidades de Hardware Requeridas
- ✅ ARMv7 processor
- ✅ Camera flash
- ✅ Front-facing camera
- ✅ Microphone

## Troubleshooting

### Error: "Bitcode is not supported"
- Ya está configurado en el Podfile para deshabilitar Bitcode

### Error: "Missing dSYM files"
- Ejecutar el script `generate_dsym.sh`
- O asegurarse de que "Debug Information Format" esté en "DWARF with dSYM File"

### Error de Permisos
- Verificar que todos los permisos estén en Info.plist
- Probar en dispositivo físico (no simulador)

### Error de Signing
- Verificar Team ID en ExportOptions.plist
- Configurar signing en Xcode
- Asegurarse de tener certificados válidos

## Comandos Útiles

```bash
# Limpiar build cache
flutter clean
cd ios && rm -rf Pods/ Podfile.lock && cd ..
flutter pub get
cd ios && pod install && cd ..

# Build de release
flutter build ios --release

# Verificar configuración
flutter doctor -v

# Instalar pods
cd ios && pod install && cd ..
```

## Checklist para App Store

- [ ] Permisos configurados en Info.plist
- [ ] Team ID actualizado en ExportOptions.plist
- [ ] Bundle ID configurado correctamente
- [ ] Certificados de distribución válidos
- [ ] App icons añadidos (1024x1024 para App Store)
- [ ] Screenshots preparados
- [ ] Descripción de la app lista
- [ ] Política de privacidad URL
- [ ] dSYM files generados y subidos
- [ ] Pruebas en dispositivos físicos
- [ ] Versión de build incrementada

## Notas Importantes

1. **Nunca subir con certificados de desarrollo**
2. **Siempre probar en dispositivos físicos antes de subir**
3. **Los permisos de cámara y micrófono son obligatorios para videollamadas**
4. **Los dSYM files son esenciales para debugging en producción**
5. **Bitcode debe estar deshabilitado para WebRTC** 