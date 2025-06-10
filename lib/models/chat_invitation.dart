class ChatInvitation {
  final String id;
  final String fromUserId;
  final String toUserId;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String status; // 'pending', 'accepted', 'rejected', 'expired'
  final String? roomId;

  ChatInvitation({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.createdAt,
    required this.expiresAt,
    this.status = 'pending',
    this.roomId,
  });

  factory ChatInvitation.fromJson(Map<String, dynamic> json) {
    return ChatInvitation(
      id: json['id'] ?? json['invitationId'] ?? '',
      fromUserId: json['fromUserId'] ?? json['from'] ?? '',
      toUserId: json['toUserId'] ?? json['to'] ?? '',
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      expiresAt: DateTime.parse(json['expiresAt'] ??
          DateTime.now().add(const Duration(minutes: 5)).toIso8601String()),
      status: json['status'] ?? 'pending',
      roomId: json['roomId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'status': status,
      'roomId': roomId,
    };
  }

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';
  bool get isExpired =>
      status == 'expired' || DateTime.now().isAfter(expiresAt);

  Duration get timeLeft => expiresAt.difference(DateTime.now());
  Duration get age => DateTime.now().difference(createdAt);

  String get timeLeftFormatted {
    final duration = timeLeft;
    if (duration.isNegative) return 'Expirada';

    if (duration.inMinutes < 1) {
      return '${duration.inSeconds}s';
    } else {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    }
  }

  @override
  String toString() {
    return 'ChatInvitation(id: $id, from: $fromUserId, status: $status, timeLeft: $timeLeftFormatted)';
  }
}
