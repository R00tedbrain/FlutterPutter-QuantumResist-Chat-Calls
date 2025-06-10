/**
 * Bridge JavaScript para @noble/post-quantum
 * Permite que Flutter Web use Kyber via JS interop
 * Compatible con el algoritmo usado en móvil (xkyber_crypto)
 */

// Importar @noble/post-quantum
import { ml_kem768 } from 'https://esm.sh/@noble/post-quantum@0.4.1/ml-kem.js';

console.log('🔐 [NOBLE-BRIDGE] Inicializando bridge para @noble/post-quantum...');

// Variables globales
let isInitialized = false;

/**
 * Inicializa el bridge
 */
async function initializeNobleBridge() {
    try {
        console.log('🔐 [NOBLE-BRIDGE] Verificando @noble/post-quantum...');
        
        // Test básico
        const testKeys = ml_kem768.keygen();
        if (testKeys && testKeys.publicKey && testKeys.secretKey) {
            console.log('🔐 [NOBLE-BRIDGE] ✅ @noble/post-quantum funcionando');
            console.log('🔐 [NOBLE-BRIDGE] 📊 Clave pública:', testKeys.publicKey.length, 'bytes');
            console.log('🔐 [NOBLE-BRIDGE] 📊 Clave secreta:', testKeys.secretKey.length, 'bytes');
            isInitialized = true;
            return true;
        } else {
            throw new Error('Test de claves falló');
        }
    } catch (error) {
        console.error('🔐 [NOBLE-BRIDGE] ❌ Error inicializando:', error);
        isInitialized = false;
        return false;
    }
}

/**
 * Test básico de noble-post-quantum
 */
window.testNobleKyber = function() {
    try {
        console.log('🔐 [NOBLE-BRIDGE] Ejecutando test básico...');
        
        if (!isInitialized) {
            console.log('🔐 [NOBLE-BRIDGE] Bridge no inicializado');
            return false;
        }

        // Test completo: generar claves, encapsular, desencapsular
        const keys = ml_kem768.keygen();
        const { cipherText, sharedSecret: secret1 } = ml_kem768.encapsulate(keys.publicKey);
        const secret2 = ml_kem768.decapsulate(cipherText, keys.secretKey);
        
        // Verificar que los secretos sean iguales
        const isValid = secret1.every((byte, index) => byte === secret2[index]);
        
        console.log('🔐 [NOBLE-BRIDGE] ✅ Test básico:', isValid ? 'EXITOSO' : 'FALLÓ');
        return isValid;
    } catch (error) {
        console.error('🔐 [NOBLE-BRIDGE] ❌ Error en test:', error);
        return false;
    }
};

/**
 * Genera un par de claves Kyber
 */
window.generateKyberKeyPair = function() {
    try {
        console.log('🔐 [NOBLE-BRIDGE] Generando par de claves...');
        
        if (!isInitialized) {
            throw new Error('Bridge no inicializado');
        }

        const keys = ml_kem768.keygen();
        
        console.log('🔐 [NOBLE-BRIDGE] ✅ Claves generadas');
        console.log('🔐 [NOBLE-BRIDGE] 📊 Clave pública:', keys.publicKey.length, 'bytes');
        console.log('🔐 [NOBLE-BRIDGE] 📊 Clave secreta:', keys.secretKey.length, 'bytes');
        
        return {
            publicKey: Array.from(keys.publicKey),
            secretKey: Array.from(keys.secretKey)
        };
    } catch (error) {
        console.error('🔐 [NOBLE-BRIDGE] ❌ Error generando claves:', error);
        throw error;
    }
};

/**
 * Encapsula una clave maestra de 64 bytes usando Kyber
 * Compatible con el formato de xkyber_crypto
 */
window.encapsulateKyberKey = function(masterKey, publicKey) {
    try {
        console.log('🔐 [NOBLE-BRIDGE] Encapsulando clave maestra...');
        
        if (!isInitialized) {
            throw new Error('Bridge no inicializado');
        }

        // Validar entrada
            if (!masterKey || masterKey.length !== 64) {
      throw new Error(`Clave maestra debe ser de 64 bytes, recibida: ${masterKey?.length}`);
        }
        
        if (!publicKey || publicKey.length === 0) {
            throw new Error('Clave pública inválida');
        }

        // Convertir arrays de Dart a Uint8Array
        const masterKeyBytes = new Uint8Array(masterKey);
        const publicKeyBytes = new Uint8Array(publicKey);
        
        // Encapsular usando ML-KEM-768
        const { cipherText, sharedSecret } = ml_kem768.encapsulate(publicKeyBytes);
        
        console.log('🔐 [NOBLE-BRIDGE] 🔐 Ciphertext Kyber:', cipherText.length, 'bytes');
        console.log('🔐 [NOBLE-BRIDGE] 🔐 Shared secret:', sharedSecret.length, 'bytes');
        
        // Cifrar la clave maestra con el shared secret (XOR repetido, compatible con móvil)
        const encryptedMasterKey = new Uint8Array(64);
        for (let i = 0; i < 64; i++) {
            encryptedMasterKey[i] = masterKeyBytes[i] ^ sharedSecret[i % sharedSecret.length];
        }
        
        // Concatenar: [ciphertext][encrypted_master_key] (formato compatible con móvil)
        const result = new Uint8Array(cipherText.length + encryptedMasterKey.length);
        result.set(cipherText);
        result.set(encryptedMasterKey, cipherText.length);
        
        console.log('🔐 [NOBLE-BRIDGE] ✅ Clave encapsulada:', result.length, 'bytes');
        console.log('🔐 [NOBLE-BRIDGE] 📊 Formato: [kyber_ciphertext][encrypted_master_key]');
        
        return Array.from(result);
    } catch (error) {
        console.error('🔐 [NOBLE-BRIDGE] ❌ Error encapsulando:', error);
        throw error;
    }
};

/**
 * Desencapsula una clave maestra usando Kyber
 * Compatible con el formato de xkyber_crypto
 */
window.decapsulateKyberKey = function(encapsulatedData, secretKey) {
    try {
        console.log('🔐 [NOBLE-BRIDGE] Desencapsulando clave maestra...');
        
        if (!isInitialized) {
            throw new Error('Bridge no inicializado');
        }

        // Validar entrada
        if (!encapsulatedData || encapsulatedData.length === 0) {
            throw new Error('Datos encapsulados inválidos');
        }
        
        if (!secretKey || secretKey.length === 0) {
            throw new Error('Clave secreta inválida');
        }

        // Convertir arrays de Dart a Uint8Array
        const encapsulatedBytes = new Uint8Array(encapsulatedData);
        const secretKeyBytes = new Uint8Array(secretKey);
        
        // Determinar tamaño del ciphertext (constante para ML-KEM-768)
        // Para ML-KEM-768, el ciphertext es típicamente 1088 bytes
        const testKeys = ml_kem768.keygen();
        const testEncap = ml_kem768.encapsulate(testKeys.publicKey);
        const ciphertextSize = testEncap.cipherText.length;
        
        console.log('🔐 [NOBLE-BRIDGE] 📊 Tamaño ciphertext esperado:', ciphertextSize, 'bytes');
        
        if (encapsulatedBytes.length < ciphertextSize + 64) {
            throw new Error(`Datos muy pequeños: ${encapsulatedBytes.length} bytes (mínimo: ${ciphertextSize + 64})`);
        }
        
        // Extraer componentes
        const cipherText = encapsulatedBytes.slice(0, ciphertextSize);
        const encryptedMasterKey = encapsulatedBytes.slice(ciphertextSize, ciphertextSize + 64);
        
        console.log('🔐 [NOBLE-BRIDGE] 📊 Ciphertext extraído:', cipherText.length, 'bytes');
        console.log('🔐 [NOBLE-BRIDGE] 📊 Master key cifrada:', encryptedMasterKey.length, 'bytes');
        
        // Desencapsular para obtener el shared secret
        const sharedSecret = ml_kem768.decapsulate(cipherText, secretKeyBytes);
        
        console.log('🔐 [NOBLE-BRIDGE] 🔐 Shared secret recuperado:', sharedSecret.length, 'bytes');
        
        // Descifrar la clave maestra (XOR inverso)
        const masterKey = new Uint8Array(64);
        for (let i = 0; i < 64; i++) {
            masterKey[i] = encryptedMasterKey[i] ^ sharedSecret[i % sharedSecret.length];
        }
        
        console.log('🔐 [NOBLE-BRIDGE] ✅ Clave maestra desencapsulada:', masterKey.length, 'bytes');
        
        return Array.from(masterKey);
    } catch (error) {
        console.error('🔐 [NOBLE-BRIDGE] ❌ Error desencapsulando:', error);
        throw error;
    }
};

/**
 * Exponer el objeto mlkem para compatibilidad
 */
window.mlkem = {
    ml_kem768: ml_kem768,
    isReady: () => isInitialized
};

// Inicializar automáticamente cuando se carga el script
initializeNobleBridge().then(success => {
    if (success) {
        console.log('🔐 [NOBLE-BRIDGE] 🎉 Bridge inicializado correctamente');
        console.log('🔐 [NOBLE-BRIDGE] 🛡️ Algoritmo: ML-KEM-768 (equivalente a Kyber768)');
        console.log('🔐 [NOBLE-BRIDGE] 🔮 Resistencia post-cuántica: ACTIVA');
        console.log('🔐 [NOBLE-BRIDGE] 📱 Compatible con móvil (xkyber_crypto)');
    } else {
        console.warn('🔐 [NOBLE-BRIDGE] ⚠️ No se pudo inicializar el bridge');
    }
}).catch(error => {
    console.error('🔐 [NOBLE-BRIDGE] ❌ Error fatal inicializando:', error);
});

export { ml_kem768, initializeNobleBridge }; 