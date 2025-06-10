const io = require('socket.io-client');

// Test para simular el problema de invitaciones fantasma
class PhantomInvitationDebugTest {
  constructor() {
    this.persona1Socket = null;
    this.persona2Socket = null;
    this.invitationData = null;
    this.roomData = null;
  }

  async runTest() {
    console.log('🧪 === INICIANDO TEST DE INVITACIÓN FANTASMA ===');
    
    try {
      // Paso 1: Conectar PERSONA 1
      await this.connectPersona1();
      
      // Paso 2: Conectar PERSONA 2
      await this.connectPersona2();
      
      // Paso 3: PERSONA 1 invita a PERSONA 2
      await this.persona1InvitesPersona2();
      
      // Paso 4: PERSONA 2 acepta invitación
      await this.persona2AcceptsInvitation();
      
      // Paso 5: Verificar que la sala se creó
      await this.verifySalaCreated();
      
      // Paso 6: PERSONA 2 sale de la sala (PROBLEMA)
      await this.persona2LeavesSala();
      
      // Paso 7: Verificar estado después de salir
      await this.verifyStateAfterLeaving();
      
      // Paso 8: Simular que PERSONA 2 vuelve al home
      await this.simulateBackToHome();
      
      console.log('✅ Test completado');
      
    } catch (error) {
      console.error('❌ Error en test:', error);
    } finally {
      this.cleanup();
    }
  }

  async connectPersona1() {
    console.log('\n📱 === CONECTANDO PERSONA 1 ===');
    
    return new Promise((resolve, reject) => {
      this.persona1Socket = io('https://clubprivado.ws', {
        path: '/ephemeral-chat/socket.io',
        transports: ['websocket', 'polling'],
        query: {
          service: 'ephemeral-chat',
          type: 'flutter-ephemeral',
          client: 'test-node',
          instance_id: 'test_persona1_' + Date.now(),
          timestamp: Date.now().toString(),
          unique_id: 'ephemeral_test1_' + Date.now()
        }
      });

      this.persona1Socket.on('connect', () => {
        console.log('✅ PERSONA 1 conectada:', this.persona1Socket.id);
        
        // Registrar usuario
        this.persona1Socket.emit('register-user', {
          userId: 'test_user_1'
        });
        
        setTimeout(resolve, 1000);
      });

      this.persona1Socket.on('connect_error', (error) => {
        console.error('❌ Error conectando PERSONA 1:', error);
        reject(error);
      });

      this.setupPersona1Listeners();
    });
  }

  async connectPersona2() {
    console.log('\n📱 === CONECTANDO PERSONA 2 ===');
    
    return new Promise((resolve, reject) => {
      this.persona2Socket = io('https://clubprivado.ws', {
        path: '/ephemeral-chat/socket.io',
        transports: ['websocket', 'polling'],
        query: {
          service: 'ephemeral-chat',
          type: 'flutter-ephemeral',
          client: 'test-node',
          instance_id: 'test_persona2_' + Date.now(),
          timestamp: Date.now().toString(),
          unique_id: 'ephemeral_test2_' + Date.now()
        }
      });

      this.persona2Socket.on('connect', () => {
        console.log('✅ PERSONA 2 conectada:', this.persona2Socket.id);
        
        // Registrar usuario
        this.persona2Socket.emit('register-user', {
          userId: 'test_user_2'
        });
        
        setTimeout(resolve, 1000);
      });

      this.persona2Socket.on('connect_error', (error) => {
        console.error('❌ Error conectando PERSONA 2:', error);
        reject(error);
      });

      this.setupPersona2Listeners();
    });
  }

  setupPersona1Listeners() {
    console.log('🔧 Configurando listeners PERSONA 1...');
    
    this.persona1Socket.on('invitation-created', (data) => {
      console.log('📤 PERSONA 1 - Invitación creada:', data);
      this.invitationData = data;
    });

    this.persona1Socket.on('room-created', (data) => {
      console.log('🏠 PERSONA 1 - Sala creada:', data);
      this.roomData = data;
    });

    this.persona1Socket.on('room-destroyed', (data) => {
      console.log('💥 PERSONA 1 - Sala destruida:', data);
    });

    this.persona1Socket.onAny((event, data) => {
      console.log(`🔍 PERSONA 1 [${event}]:`, data);
    });
  }

  setupPersona2Listeners() {
    console.log('🔧 Configurando listeners PERSONA 2...');
    
    this.persona2Socket.on('chat-invitation-received', (data) => {
      console.log('📨 PERSONA 2 - Invitación recibida:', data);
      this.invitationData = data;
    });

    this.persona2Socket.on('room-created', (data) => {
      console.log('🏠 PERSONA 2 - Sala creada:', data);
      this.roomData = data;
    });

    this.persona2Socket.on('room-destroyed', (data) => {
      console.log('💥 PERSONA 2 - Sala destruida:', data);
    });

    // ESTE ES EL KEY LISTENER - aquí deberíamos ver si hay cleanup
    this.persona2Socket.on('cleanup-user-invitations', (data) => {
      console.log('🧹 PERSONA 2 - Cleanup invitaciones:', data);
    });

    this.persona2Socket.on('mark-user-invitations-completed', (data) => {
      console.log('✅ PERSONA 2 - Invitaciones marcadas como completadas:', data);
    });

    this.persona2Socket.onAny((event, data) => {
      console.log(`🔍 PERSONA 2 [${event}]:`, data);
    });
  }

  async persona1InvitesPersona2() {
    console.log('\n📤 === PERSONA 1 INVITA A PERSONA 2 ===');
    
    return new Promise((resolve) => {
      this.persona1Socket.emit('create-chat-invitation', {
        targetUserId: 'test_user_2',
        fromUserId: 'test_user_1',
        message: 'Test invitation',
        expiresInMinutes: 15
      });
      
      // Esperar a que se procese la invitación
      setTimeout(resolve, 2000);
    });
  }

  async persona2AcceptsInvitation() {
    console.log('\n✅ === PERSONA 2 ACEPTA INVITACIÓN ===');
    
    if (!this.invitationData) {
      throw new Error('No se encontró invitación para aceptar');
    }
    
    return new Promise((resolve) => {
      this.persona2Socket.emit('accept-chat-invitation', {
        invitationId: this.invitationData.id || this.invitationData.invitationId
      });
      
      // Esperar a que se cree la sala
      setTimeout(resolve, 3000);
    });
  }

  async verifySalaCreated() {
    console.log('\n🔍 === VERIFICANDO SALA CREADA ===');
    
    if (!this.roomData) {
      throw new Error('❌ No se creó la sala correctamente');
    }
    
    console.log('✅ Sala verificada:', {
      roomId: this.roomData.roomId || this.roomData.id,
      participants: this.roomData.participantCount || 'unknown'
    });
  }

  async persona2LeavesSala() {
    console.log('\n🚪 === PERSONA 2 SALE DE LA SALA (MOMENTO CRÍTICO) ===');
    
    const roomId = this.roomData.roomId || this.roomData.id;
    
    return new Promise((resolve) => {
      // Simular salida de sala
      this.persona2Socket.emit('leave-room', {
        roomId: roomId,
        userId: 'test_user_2',
        reason: 'user_exit'
      });
      
      // AQUÍ DEBERÍA TRIGGER EL CLEANUP QUE AGREGUÉ
      console.log('🧹 Esperando cleanup automático...');
      
      setTimeout(resolve, 2000);
    });
  }

  async verifyStateAfterLeaving() {
    console.log('\n🔍 === VERIFICANDO ESTADO DESPUÉS DE SALIR ===');
    
    // Simular que PERSONA 2 se "reconecta" como si volviera al home
    console.log('🔄 Simulando reconexión de PERSONA 2...');
    
    // Verificar si hay invitaciones pendientes
    this.persona2Socket.emit('get-pending-invitations', {
      userId: 'test_user_2'
    });
    
    await new Promise(resolve => setTimeout(resolve, 1000));
  }

  async simulateBackToHome() {
    console.log('\n🏠 === SIMULANDO VUELTA AL HOME ===');
    
    // Esto simula cuando MainScreen se inicializa y verifica invitaciones
    console.log('📋 Verificando si aparecen invitaciones fantasma...');
    
    let phantomInvitationDetected = false;
    
    // Escuchar si llega una invitación fantasma
    const phantomListener = (data) => {
      if (data.fromUserId === 'test_user_1' && data.targetUserId === 'test_user_2') {
        phantomInvitationDetected = true;
        console.log('👻 ¡INVITACIÓN FANTASMA DETECTADA!:', data);
      }
    };
    
    this.persona2Socket.on('chat-invitation-received', phantomListener);
    
    // AGRESIVO: Simular múltiples reconexiones como hace Flutter
    console.log('🔄 Simulando reconexión #1 (como MainScreen)...');
    this.persona2Socket.emit('register-user', {
      userId: 'test_user_2'
    });
    
    await new Promise(resolve => setTimeout(resolve, 1000));
    
    console.log('🔄 Simulando reconexión #2 (como ensureConnection)...');
    this.persona2Socket.emit('register-user', {
      userId: 'test_user_2'
    });
    
    await new Promise(resolve => setTimeout(resolve, 1000));
    
    console.log('🔄 Simulando reconexión #3 (refresh app)...');
    this.persona2Socket.emit('register-user', {
      userId: 'test_user_2'
    });
    
    await new Promise(resolve => setTimeout(resolve, 2000));
    
    this.persona2Socket.off('chat-invitation-received', phantomListener);
    
    if (phantomInvitationDetected) {
      console.log('❌ PROBLEMA CONFIRMADO: Se detectó invitación fantasma');
    } else {
      console.log('✅ FIX FUNCIONANDO: No se detectó invitación fantasma');
    }
  }

  cleanup() {
    console.log('\n🧹 === LIMPIANDO TEST ===');
    
    if (this.persona1Socket) {
      this.persona1Socket.disconnect();
    }
    
    if (this.persona2Socket) {
      this.persona2Socket.disconnect();
    }
  }
}

// Ejecutar test
const test = new PhantomInvitationDebugTest();
test.runTest().then(() => {
  console.log('🏁 Test terminado');
  process.exit(0);
}).catch((error) => {
  console.error('💥 Test falló:', error);
  process.exit(1);
}); 