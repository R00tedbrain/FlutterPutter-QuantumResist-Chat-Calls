class User {
  final String id;
  final String email;
  final String nickname;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.nickname,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      nickname: json['nickname'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nickname': nickname,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
