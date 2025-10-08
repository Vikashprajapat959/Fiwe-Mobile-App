// ignore_for_file: library_private_types_in_public_api

import 'package:firebase_messaging/firebase_messaging.dart';

import 'fcm_action.dart';

/// Enumeration for different types of notifications
enum NotificationType {
  userMessage,
  systemAlert,
  promotional,
  reminder,
  roomInvite, // Added for room invite notifications
}

/// Enumeration for notification priorities
enum NotificationPriority { low, normal, high, urgent }

/// Data model for representing notifications in the app
class FCMNotificationData {
  const FCMNotificationData({
    required this.id,
    required this.title,
    required this.body,
    this.imageUrl,
    required this.data,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    required this.priority,
    this.route,
    this.userId,
    this.actions = const [],
    this.roomId,
  });

  /// Create NotificationData from Firebase RemoteMessage
  factory FCMNotificationData.fromRemoteMessage(RemoteMessage message) {
    // Check if this is a room invite notification
    final isRoomInvite = message.data['type'] == 'room_invite';

    return FCMNotificationData(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification?.title ?? 'New Notification Marketing',
      body: message.notification?.body ?? '',
      imageUrl: message.notification?.android?.imageUrl ?? message.notification?.apple?.imageUrl,
      data: message.data,
      type: _parseNotificationType(message.data['type']),
      timestamp: DateTime.now(),
      isRead: false,
      priority: _parseNotificationPriority(message.data['priority']),
      route: message.data['route'],
      userId: message.data['userId'],
      actions: isRoomInvite ? _createRoomInviteActions(message.data) : const [],
      roomId: isRoomInvite ? message.data['roomId'] : null,
    );
  }

  /// Create NotificationData from JSON
  factory FCMNotificationData.fromJson(Map<String, dynamic> json) {
    final actionsJson = json['actions'] as List<dynamic>? ?? [];
    final actions = actionsJson.map((action) => FCMAction.fromJson(Map<String, dynamic>.from(action as Map))).toList();

    return FCMNotificationData(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      imageUrl: json['imageUrl'],
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      type: NotificationType.values[json['type'] ?? 0],
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      isRead: json['isRead'] ?? false,
      priority: NotificationPriority.values[json['priority'] ?? 1],
      route: json['route'],
      userId: json['userId'],
      actions: actions,
      roomId: json['roomId'],
    );
  }

  /// Unique identifier for the notification
  final String id;

  /// Notification title
  final String title;

  /// Notification body/message
  final String body;

  /// Optional image URL for rich notifications
  final String? imageUrl;

  /// Additional data payload
  final Map<String, dynamic> data;

  /// Type of notification
  final NotificationType type;

  /// Timestamp when notification was received
  final DateTime timestamp;

  /// Whether the notification has been read
  final bool isRead;

  /// Priority level of the notification
  final NotificationPriority priority;

  /// Route to navigate to when notification is tapped
  final String? route;

  /// User ID if this is a user-specific notification
  final String? userId;

  /// Actions associated with the notification (e.g., buttons)
  final List<FCMAction> actions;

  /// Room ID for room invite notifications
  final String? roomId;

  /// Convert NotificationData to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'imageUrl': imageUrl,
      'data': data,
      'type': type.index,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'priority': priority.index,
      'route': route,
      'userId': userId,
      'actions': actions.map((action) => action.toJson()).toList(),
      'roomId': roomId,
    };
  }

  /// Create a copy of this notification with updated fields
  FCMNotificationData copyWith({
    String? id,
    String? title,
    String? body,
    String? imageUrl,
    Map<String, dynamic>? data,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
    NotificationPriority? priority,
    String? route,
    String? userId,
    List<FCMAction>? actions,
    String? roomId,
  }) {
    return FCMNotificationData(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      imageUrl: imageUrl ?? this.imageUrl,
      data: data ?? this.data,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      priority: priority ?? this.priority,
      route: route ?? this.route,
      userId: userId ?? this.userId,
      actions: actions ?? this.actions,
      roomId: roomId ?? this.roomId,
    );
  }

  /// Parse notification type from string
  static NotificationType _parseNotificationType(String? typeString) {
    switch (typeString?.toLowerCase()) {
      case 'user_message':
        return NotificationType.userMessage;
      case 'system_alert':
        return NotificationType.systemAlert;
      case 'promotional':
        return NotificationType.promotional;
      case 'reminder':
        return NotificationType.reminder;
      case 'room_invite':
        return NotificationType.roomInvite;
      default:
        return NotificationType.systemAlert;
    }
  }

  /// Parse notification priority from string
  static NotificationPriority _parseNotificationPriority(String? priorityString) {
    switch (priorityString?.toLowerCase()) {
      case 'low':
        return NotificationPriority.low;
      case 'normal':
        return NotificationPriority.normal;
      case 'high':
        return NotificationPriority.high;
      case 'urgent':
        return NotificationPriority.urgent;
      default:
        return NotificationPriority.normal;
    }
  }

  /// Create action buttons for room invite notifications
  static List<FCMAction> _createRoomInviteActions(Map<String, dynamic> data) {
    final roomId = data['roomId'] as String?;
    if (roomId == null) return const [];

    return [
      FCMAction(
        id: 'join_now_${DateTime.now().millisecondsSinceEpoch}',
        title: 'JOIN NOW',
        actionType: 'join_room',
        data: {'roomId': roomId},
      ),
      FCMAction(
        id: 'mute_${DateTime.now().millisecondsSinceEpoch}',
        title: 'MUTE',
        actionType: 'mute',
        data: {'roomId': roomId},
      ),
    ];
  }

  /// Get Android notification channel ID based on priority
  String get androidChannelId {
    switch (priority) {
      case NotificationPriority.low:
        return 'low_priority_channel';
      case NotificationPriority.normal:
        return 'normal_priority_channel';
      case NotificationPriority.high:
        return 'high_priority_channel';
      case NotificationPriority.urgent:
        return 'urgent_priority_channel';
    }
  }

  /// Get notification importance for Android
  int get androidImportance {
    switch (priority) {
      case NotificationPriority.low:
        return 2; // IMPORTANCE_LOW
      case NotificationPriority.normal:
        return 3; // IMPORTANCE_DEFAULT
      case NotificationPriority.high:
        return 4; // IMPORTANCE_HIGH
      case NotificationPriority.urgent:
        return 5; // IMPORTANCE_MAX
    }
  }

  @override
  String toString() {
    return 'NotificationData(id: $id, title: $title, body: $body, type: $type, priority: $priority, isRead: $isRead, roomId: $roomId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FCMNotificationData &&
        other.id == id &&
        other.title == title &&
        other.body == body &&
        other.type == type &&
        other.priority == priority &&
        other.roomId == roomId;
  }

  @override
  int get hashCode {
    return id.hashCode ^ title.hashCode ^ body.hashCode ^ type.hashCode ^ priority.hashCode ^ roomId.hashCode;
  }
}

class RoomInviteData {
  RoomInviteData({
    required this.roomId,
    required this.roomHostCode,
    required this.roomGuestCode,
    required this.title,
    required this.inviteeName,
    required this.deepLink,
    this.expiry,
    this.topicDetails,
    this.userDetails,
  });

  factory RoomInviteData.fromJson(Map<String, dynamic> json) {
    return RoomInviteData(
      roomId: json['room_id'] ?? '',
      roomHostCode: json['room_host_code'] ?? '',
      roomGuestCode: json['room_guest_code'] ?? '',
      title: json['title'] ?? '',
      inviteeName: json['invitee_name'] ?? '',
      deepLink: json['deep_link'] ?? '',
      expiry: DateTime.parse(json['expiry'] ?? DateTime.now().toIso8601String()),
      topicDetails: json['topic_details'] != null ? _TopicData.fromJson(Map.from(json['topic_details'])) : null,
      userDetails: json['user_details'] != null ? _UserData.fromJson(Map.from(json['user_details'])) : null,
    );
  }
  final String roomId;
  final String roomHostCode;
  final String roomGuestCode;
  final String title;
  final String inviteeName;
  final String deepLink;
  final DateTime? expiry;
  final _TopicData? topicDetails;
  final _UserData? userDetails;
}

class _UserData {
  _UserData({required this.userId, required this.name, required this.email});

  factory _UserData.fromJson(Map<String, dynamic> json) {
    return _UserData(userId: json['user_id'] ?? '', name: json['name'] ?? '', email: json['email'] ?? '');
  }
  final String userId;
  final String name;
  final String email;
}

class _TopicData {
  _TopicData({required this.topicId, required this.title, required this.description});

  factory _TopicData.fromJson(Map<String, dynamic> json) {
    return _TopicData(
      topicId: json['topic_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
    );
  }
  final String topicId;
  final String title;
  final String description;
}
