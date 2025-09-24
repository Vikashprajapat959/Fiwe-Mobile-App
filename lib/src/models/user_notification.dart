import 'package:fiwe/src/models/fcm_notification_data.dart';

class UserNotification {
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
  final RoomInviteData? roomInviteData;
  final String? campaignName;

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
    this.roomInviteData,
    this.campaignName,
  });

  factory UserNotification.fromJson(Map<String, dynamic> json) {
    return UserNotification(
      id: json['id'] as String,
      notificationType: json['notification_type'] as String,
      status: json['status'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      sentAt: DateTime.parse(json['sent_at'] as String),
      deliveredAt: json['delivered_at'] != null ? DateTime.parse(json['delivered_at'] as String) : null,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at'] as String) : null,
      expiresAt: json['expires_at'] != null ? DateTime.parse(json['expires_at'] as String) : null,
      roomId: json['room_id'],
      actionData: json['action_data'] != null ? Map<String, dynamic>.from(json['action_data']) : null,
      campaignName: json['campaign_name'],
      roomInviteData: json['action_data'] != null && json['notification_type'] == "room_invite"
          ? RoomInviteData.fromJson(Map<String, dynamic>.from(json['action_data']))
          : null,
    );
  }

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
    };
  }
}

class UserNotificationPage {
  final List<UserNotification> notifications;
  final int totalCount;
  final int currentPage;
  final int totalPages;
  final int pageSize;

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
      totalCount: json['total_count'],
      currentPage: json['current_page'],
      totalPages: json['total_pages'],
      pageSize: json['page_size'],
    );
  }

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
