class UserNotification {
  UserNotification({
    required this.id,
    required this.notificationType,
    required this.status,
    required this.title,
    required this.body,
    required this.sentAt,
    this.deliveredAt,
    this.readAt,
    this.expiresAt,
    this.roomId,
    this.actionData,
    this.campaignName,
    this.creatorName,
    this.profileImageUrl,
    this.profileBase64,
  });

  factory UserNotification.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (_) {
          return null;
        }
      }
      return null;
    }

    final Map<String, dynamic>? actionData = json['action_data'] != null
        ? Map<String, dynamic>.from(json['action_data'])
        : null;

    final String title = json['title'] as String;

    String? extractedName;
    if (title.contains(':')) {
      extractedName = title.split(':').last.trim();
    } else {
      extractedName = title;
    }

    return UserNotification(
      id: json['id'] as String,
      notificationType: json['notification_type'] as String,
      status: json['status'] as String,
      title: title,
      body: json['body'] as String,
      sentAt: parseDate(json['sent_at'])!,
      deliveredAt: parseDate(json['delivered_at']),
      readAt: parseDate(json['read_at']),
      expiresAt: parseDate(json['expires_at']),
      roomId: json['room_id'] as String?,
      actionData: actionData,
      campaignName: json['campaign_name'] as String?,
      creatorName: json['creator_name'] as String? ?? extractedName,
      profileImageUrl: json['profile_image_url'] as String?,
      profileBase64: json['profile_image_base64'] as String?,
    );
  }

  UserNotification copyWith({String? profileImageUrl, String? profileBase64}) {
    return UserNotification(
      id: id,
      notificationType: notificationType,
      status: status,
      title: title,
      body: body,
      sentAt: sentAt,
      deliveredAt: deliveredAt,
      readAt: readAt,
      expiresAt: expiresAt,
      roomId: roomId,
      actionData: actionData,
      campaignName: campaignName,
      creatorName: creatorName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      profileBase64: profileBase64 ?? this.profileBase64,
    );
  }

  final String id;
  final String notificationType;
  final String status;
  final String title;
  final String body;
  final DateTime sentAt;
  final DateTime? deliveredAt;
  final DateTime? readAt;
  final DateTime? expiresAt;
  final String? roomId;
  final Map<String, dynamic>? actionData;
  final String? campaignName;
  final String? creatorName;
  final String? profileImageUrl;
  final String? profileBase64;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'notification_type': notificationType,
      'status': status,
      'title': title,
      'body': body,
      'sent_at': sentAt.toIso8601String(),
      'delivered_at': deliveredAt?.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'room_id': roomId,
      'action_data': actionData,
      'campaign_name': campaignName,
      'creator_name': creatorName,
      'profile_image_url': profileImageUrl,
      'profile_image_base64': profileBase64,
    };
  }
}

class UserNotificationPage {
  UserNotificationPage({
    required this.notifications,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
  });

  factory UserNotificationPage.fromJson(Map<String, dynamic> json) {
    return UserNotificationPage(
      notifications: (json['notifications'] as List<dynamic>)
          .map((e) => UserNotification.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: json['total_count'] as int,
      currentPage: json['current_page'] as int,
      totalPages: json['total_pages'] as int,
      pageSize: json['page_size'] as int,
    );
  }

  final List<UserNotification> notifications;
  final int totalCount;
  final int currentPage;
  final int totalPages;
  final int pageSize;

  Map<String, dynamic> toJson() {
    return {
      'notifications': notifications.map((e) => e.toJson()).toList(),
      'total_count': totalCount,
      'current_page': currentPage,
      'total_pages': totalPages,
      'page_size': pageSize,
    };
  }
}
