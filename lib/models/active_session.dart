class DeviceInfo {
  final String type; // web, ios, android, desktop
  final String? browser; // Chrome, Safari, Firefox, etc.
  final String? os; // iOS, Android, macOS, Windows, Linux
  final String? version; // Versión del SO o app
  final String? ip; // IP address (opcional para privacidad)
  final String? location; // Ubicación aproximada (opcional)
  final String? userAgent; // User agent completo (para identificación)

  DeviceInfo({
    required this.type,
    this.browser,
    this.os,
    this.version,
    this.ip,
    this.location,
    this.userAgent,
  });

  factory DeviceInfo.fromJson(Map<String, dynamic> json) {
    return DeviceInfo(
      type: json['type'] ?? 'unknown',
      browser: json['browser'],
      os: json['os'],
      version: json['version'],
      ip: json['ip'],
      location: json['location'],
      userAgent: json['userAgent'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (browser != null) 'browser': browser,
      if (os != null) 'os': os,
      if (version != null) 'version': version,
      if (ip != null) 'ip': ip,
      if (location != null) 'location': location,
      if (userAgent != null) 'userAgent': userAgent,
    };
  }

  String get displayName {
    if (type == 'web' && browser != null) {
      return '$browser Web';
    } else if (type == 'ios') {
      return 'iPhone/iPad';
    } else if (type == 'android') {
      return 'Android';
    } else if (type == 'desktop') {
      return os ?? 'Desktop';
    }
    return type;
  }

  String get icon {
    switch (type) {
      case 'web':
        return '🌐';
      case 'ios':
        return '📱';
      case 'android':
        return '🤖';
      case 'desktop':
        return '💻';
      default:
        return '📱';
    }
  }
}

class ActiveSession {
  final String sessionId;
  final String userId;
  final DeviceInfo deviceInfo;
  final DateTime linkedAt;
  final DateTime lastActivity;
  final bool isCurrentSession;
  final bool isPrimarySession;
  final String? linkedBy; // QR linking - quién vinculó esta sesión

  ActiveSession({
    required this.sessionId,
    required this.userId,
    required this.deviceInfo,
    required this.linkedAt,
    required this.lastActivity,
    this.isCurrentSession = false,
    this.isPrimarySession = false,
    this.linkedBy,
  });

  factory ActiveSession.fromJson(Map<String, dynamic> json) {
    return ActiveSession(
      sessionId: json['sessionId'] ?? '',
      userId: json['userId'] ?? '',
      deviceInfo: DeviceInfo.fromJson(json['deviceInfo'] ?? {}),
      linkedAt:
          DateTime.parse(json['linkedAt'] ?? DateTime.now().toIso8601String()),
      lastActivity: DateTime.parse(
          json['lastActivity'] ?? DateTime.now().toIso8601String()),
      isCurrentSession: json['isCurrentSession'] ?? false,
      isPrimarySession: json['isPrimarySession'] ?? false,
      linkedBy: json['linkedBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'userId': userId,
      'deviceInfo': deviceInfo.toJson(),
      'linkedAt': linkedAt.toIso8601String(),
      'lastActivity': lastActivity.toIso8601String(),
      'isCurrentSession': isCurrentSession,
      'isPrimarySession': isPrimarySession,
      if (linkedBy != null) 'linkedBy': linkedBy,
    };
  }

  String get lastActivityDisplay {
    final now = DateTime.now();
    final difference = now.difference(lastActivity);

    if (difference.inMinutes < 1) {
      return 'Activo ahora';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours}h';
    } else {
      return 'Hace ${difference.inDays}d';
    }
  }

  bool get isActive {
    final now = DateTime.now();
    final difference = now.difference(lastActivity);
    return difference.inMinutes <
        30; // Activo si hay actividad en los últimos 30 min
  }
}

class QRLinkingData {
  final String linkingToken;
  final String qrCodeData;
  final DateTime expiresAt;
  final String? fromDevice;

  QRLinkingData({
    required this.linkingToken,
    required this.qrCodeData,
    required this.expiresAt,
    this.fromDevice,
  });

  factory QRLinkingData.fromJson(Map<String, dynamic> json) {
    return QRLinkingData(
      linkingToken: json['linkingToken'] ?? '',
      qrCodeData: json['qrCodeData'] ?? '',
      expiresAt: DateTime.parse(json['expiresAt'] ??
          DateTime.now().add(const Duration(minutes: 5)).toIso8601String()),
      fromDevice: json['fromDevice'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'linkingToken': linkingToken,
      'qrCodeData': qrCodeData,
      'expiresAt': expiresAt.toIso8601String(),
      if (fromDevice != null) 'fromDevice': fromDevice,
    };
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  int get secondsRemaining {
    if (isExpired) return 0;
    return expiresAt.difference(DateTime.now()).inSeconds;
  }
}
