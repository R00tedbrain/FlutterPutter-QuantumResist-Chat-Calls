class EphemeralRoom {
  final String id;
  final List<String> participants;
  final DateTime createdAt;
  final DateTime lastActivity;
  final String encryptionKey;
  final int messageCount;

  EphemeralRoom({
    required this.id,
    required this.participants,
    required this.createdAt,
    required this.lastActivity,
    required this.encryptionKey,
    this.messageCount = 0,
  });

  factory EphemeralRoom.fromJson(Map<String, dynamic> json) {
    return EphemeralRoom(
      id: json['id'] ?? json['roomId'] ?? '',
      participants: List<String>.from(json['participants'] ?? []),
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      lastActivity: DateTime.parse(
          json['lastActivity'] ?? DateTime.now().toIso8601String()),
      encryptionKey: json['encryptionKey'] ?? '',
      messageCount: json['messageCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participants': participants,
      'createdAt': createdAt.toIso8601String(),
      'lastActivity': lastActivity.toIso8601String(),
      'encryptionKey': encryptionKey,
      'messageCount': messageCount,
    };
  }

  bool get isEmpty => participants.isEmpty;

  bool hasParticipant(String userId) {
    return participants.contains(userId);
  }

  int get participantCount => participants.length;

  Duration get age => DateTime.now().difference(createdAt);

  Duration get timeSinceLastActivity => DateTime.now().difference(lastActivity);

  @override
  String toString() {
    return 'EphemeralRoom(id: $id, participants: ${participants.length}, age: ${age.inMinutes}min)';
  }
}
