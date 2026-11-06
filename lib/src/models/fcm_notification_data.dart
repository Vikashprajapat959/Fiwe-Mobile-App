// lib/src/models/fcm_notification_data.dart

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fiwe/src/models/topic.model.dart';
import 'package:fiwe/src/models/user_model.dart';

/// Enums for notification types
enum NotificationType { roomInvite, promotional, userMessage, systemAlert, reminder, communeAccepted, communeRequest }

/// Enums for notification priority
enum NotificationPriority { low, normal, high, urgent }

// =========================================================
// RoomInviteData Model
// =========================================================
class RoomInviteData {
  RoomInviteData({
    required this.title,
    required this.body,
    required this.type,
    required this.roomId,
    required this.inviteeName,
    this.roomHostCode,
    this.roomGuestCode,
    this.deepLink,
    this.expiry,
    this.topicDetails,
    this.userDetails,
  });

  /// Deserialize from JSON
  factory RoomInviteData.fromJson(Map<String, dynamic> json) {
    return RoomInviteData(
      title: json['title'] as String,
      body: json['body'] as String,
      type: json['type'] as String,
      roomId: json['roomId'] as String,
      inviteeName: json['inviteeName'] as String,
      roomHostCode: json['roomHostCode'] as String?,
      roomGuestCode: json['roomGuestCode'] as String?,
      deepLink: json['deepLink'] as String?,
      expiry: json['expiry'] != null ? DateTime.tryParse(json['expiry']) : null,
      topicDetails: json['topicDetails'] != null ? Topic.fromJson(json['topicDetails']) : null,
      userDetails: json['userDetails'] != null ? User.fromJson(json['userDetails']) : null,
    );
  }

  final String title;
  final String body;
  final String type; // Expected 'room_invite'
  final String roomId;
  final String inviteeName;

  final String? roomHostCode;
  final String? roomGuestCode;
  final String? deepLink;
  final DateTime? expiry;
  final Topic? topicDetails;
  final User? userDetails;

  /// Serialize to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'type': type,
      'roomId': roomId,
      'inviteeName': inviteeName,
      'roomHostCode': roomHostCode,
      'roomGuestCode': roomGuestCode,
      'deepLink': deepLink,
      'expiry': expiry?.toIso8601String(),
      'topicDetails': topicDetails?.toJson(),
      'userDetails': userDetails?.toJson(), // ✅ Fixed null-safety
    };
  }
}

// =========================================================
// FCMNotificationData Model
// =========================================================
class FCMNotificationData {
  FCMNotificationData({required this.title, required this.body, required this.type, this.route, this.data});

  /// From RemoteMessage (Firebase)
  factory FCMNotificationData.fromRemoteMessage(RemoteMessage message) {
    return FCMNotificationData(
      title: message.notification?.title ?? message.data['title'] ?? 'Notification',
      body: message.notification?.body ?? message.data['body'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.toString().split('.').last == (message.data['type'] ?? 'systemAlert'),
        orElse: () => NotificationType.systemAlert,
      ),
      route: message.data['route'],
      data: message.data,
    );
  }

  /// From JSON
  factory FCMNotificationData.fromJson(Map<String, dynamic> json) {
    return FCMNotificationData(
      title: json['title'] as String,
      body: json['body'] as String,
      type: NotificationType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => NotificationType.systemAlert,
      ),
      route: json['route'] as String?,
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  final String title;
  final String body;
  final NotificationType type;
  final String? route;
  final Map<String, dynamic>? data;

  /// To JSON
  Map<String, dynamic> toJson() {
    return {'title': title, 'body': body, 'type': type.toString().split('.').last, 'route': route, 'data': data};
  }
}
