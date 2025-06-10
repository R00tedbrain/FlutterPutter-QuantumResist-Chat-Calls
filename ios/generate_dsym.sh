#!/bin/bash

# Script para generar dSYM files para App Store submission
# Este script debe ejecutarse después de hacer el build de release

echo "🔧 Generando archivos dSYM para App Store submission..."

# Configurar variables
CONFIGURATION="Release"
WORKSPACE="Runner.xcworkspace"
SCHEME="Runner"
ARCHIVE_PATH="build/ios/archive/Runner.xcarchive"

# Limpiar builds anteriores
echo "🧹 Limpiando builds anteriores..."
rm -rf build/ios/archive/
rm -rf build/ios/ipa/

# Crear directorios necesarios
mkdir -p build/ios/archive/
mkdir -p build/ios/ipa/

# Generar archive con dSYM
echo "📦 Generando archive con símbolos de depuración..."
xcodebuild -workspace "$WORKSPACE" \
           -scheme "$SCHEME" \
           -configuration "$CONFIGURATION" \
           -archivePath "$ARCHIVE_PATH" \
           -allowProvisioningUpdates \
           DEBUG_INFORMATION_FORMAT=dwarf-with-dsym \
           DWARF_DSYM_FOLDER_PATH=build/ios/archive/ \
           archive

# Verificar que se generaron los dSYM
if [ -d "$ARCHIVE_PATH/dSYMs" ]; then
    echo "✅ dSYM files generados exitosamente en: $ARCHIVE_PATH/dSYMs"
    ls -la "$ARCHIVE_PATH/dSYMs"
else
    echo "❌ Error: No se pudieron generar los archivos dSYM"
    exit 1
fi

# Exportar IPA para App Store
echo "📤 Exportando IPA para App Store..."
xcodebuild -exportArchive \
           -archivePath "$ARCHIVE_PATH" \
           -exportPath "build/ios/ipa/" \
           -exportOptionsPlist "ios/ExportOptions.plist"

echo "🎉 Proceso completado. Archivos listos para App Store submission:"
echo "   - Archive: $ARCHIVE_PATH"
echo "   - dSYM: $ARCHIVE_PATH/dSYMs"
echo "   - IPA: build/ios/ipa/" 