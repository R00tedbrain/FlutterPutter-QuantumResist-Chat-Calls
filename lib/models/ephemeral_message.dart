import 'dart:typed_data';

class EphemeralMessage {
  final String id;
  final String roomId;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final bool isEncrypted;
  final String? nonce;
  final int? destructionTimeMinutes;
  final DateTime? destructionTime;
  final MessageType type;

  // 🎯 NUEVOS CAMPOS MULTIMEDIA
  final String messageType; // 'text', 'audio', 'image'
  final Uint8List? mediaData; // Datos binarios del archivo multimedia
  final double? duration; // Duración del audio en segundos
  final Map<String, dynamic>? fileInfo; // Metadatos del archivo

  EphemeralMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.content,
    required this.timestamp,
    this.isEncrypted = true,
    this.nonce,
    this.destructionTimeMinutes,
    this.destructionTime,
    this.type = MessageType.normal,
    this.messageType = 'text', // Por defecto texto
    this.mediaData,
    this.duration,
    this.fileInfo,
  });

  factory EphemeralMessage.fromJson(Map<String, dynamic> json) {
    final destructionMinutes = json['destructionTimeMinutes'] as int?;
    DateTime? destructionTime;

    if (destructionMinutes != null) {
      final messageTime =
          DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String());
      destructionTime = messageTime.add(Duration(minutes: destructionMinutes));
    }

    MessageType messageType = MessageType.normal;
    final content = json['content'] ?? json['message'] ?? '';
    if (content.startsWith('DESTRUCTION_COUNTDOWN:')) {
      messageType = MessageType.destructionCountdown;
    } else if (content.startsWith('VERIFICATION_CODES:')) {
      messageType = MessageType.verification;
    }

    return EphemeralMessage(
      id: json['id'] ?? '',
      roomId: json['roomId'] ?? '',
      senderId: json['senderId'] ?? '',
      content: content,
      timestamp:
          DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      isEncrypted: json['isEncrypted'] ?? true,
      nonce: json['nonce'],
      destructionTimeMinutes: destructionMinutes,
      destructionTime: destructionTime,
      type: messageType,
      messageType: json['messageType'] ?? 'text',
      duration: json['duration']?.toDouble(),
      fileInfo: json['fileInfo'] as Map<String, dynamic>?,
    );
  }

  factory EphemeralMessage.destructionCountdown({
    required String roomId,
    required String senderId,
    required int countdown,
  }) {
    return EphemeralMessage(
      id: 'destruction_${DateTime.now().millisecondsSinceEpoch}',
      roomId: roomId,
      senderId: senderId,
      content: 'DESTRUCTION_COUNTDOWN:$countdown',
      timestamp: DateTime.now(),
      isEncrypted: false,
      type: MessageType.destructionCountdown,
      messageType: 'system',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomId': roomId,
      'senderId': senderId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'isEncrypted': isEncrypted,
      'nonce': nonce,
      'destructionTimeMinutes': destructionTimeMinutes,
      'type': type.toString(),
      'messageType': messageType,
      'duration': duration,
      'fileInfo': fileInfo,
    };
  }

  bool get isFromMe => senderId == 'me';

  bool get isDestructionCountdown => type == MessageType.destructionCountdown;
  bool get isVerification => type == MessageType.verification;
  bool get isSystemMessage => type != MessageType.normal;

  // 🎯 NUEVOS GETTERS MULTIMEDIA
  bool get isTextMessage => messageType == 'text';
  bool get isAudioMessage => messageType == 'audio';
  bool get isImageMessage => messageType == 'image';
  bool get isMultimediaMessage =>
      messageType != 'text' && messageType != 'system';

  int? get destructionCountdownValue {
    if (!isDestructionCountdown) return null;
    try {
      final parts = content.split(':');
      if (parts.length >= 2) {
        return int.parse(parts[1]);
      }
    } catch (e) {
      // Ignorar errores de parsing
    }
    return null;
  }

  Duration get age => DateTime.now().difference(timestamp);

  String get timeAgo {
    final duration = age;
    if (duration.inMinutes < 1) {
      return 'ahora';
    } else if (duration.inMinutes < 60) {
      return '${duration.inMinutes}m';
    } else if (duration.inHours < 24) {
      return '${duration.inHours}h';
    } else {
      return '${duration.inDays}d';
    }
  }

  bool get shouldBeDestroyed {
    if (destructionTime == null) return false;
    return DateTime.now().isAfter(destructionTime!);
  }

  Duration? get timeUntilDestruction {
    if (destructionTime == null) return null;
    final now = DateTime.now();
    if (now.isAfter(destructionTime!)) return Duration.zero;
    return destructionTime!.difference(now);
  }

  String get destructionCountdown {
    final remaining = timeUntilDestruction;
    if (remaining == null) return '';

    if (remaining.inSeconds <= 0) return '💥';

    if (remaining.inHours > 0) {
      return '🔥 ${remaining.inHours}h ${remaining.inMinutes % 60}m';
    } else if (remaining.inMinutes > 0) {
      return '🔥 ${remaining.inMinutes}m ${remaining.inSeconds % 60}s';
    } else {
      return '🔥 ${remaining.inSeconds}s';
    }
  }

  @override
  String toString() {
    return 'EphemeralMessage(id: $id, sender: $senderId, type: $type, messageType: $messageType, age: ${age.inSeconds}s)';
  }
}

enum MessageType {
  normal,
  destructionCountdown,
  verification,
}
