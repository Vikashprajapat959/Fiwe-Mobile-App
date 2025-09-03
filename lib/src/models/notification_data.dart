import 'package:firebase_messaging/firebase_messaging.dart';

/// Enumeration for different types of notifications
enum NotificationType {
  userMessage,
  systemAlert,
  promotional,
  reminder,
}

/// Enumeration for notification priorities
enum NotificationPriority {
  low,
  normal,
  high,
  urgent,
}

/// Data model for representing notifications in the app
class NotificationData {
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

  const NotificationData({
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
  });

  /// Create NotificationData from Firebase RemoteMessage
  factory NotificationData.fromRemoteMessage(RemoteMessage message) {
    return NotificationData(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification?.title ?? 'New Notification',
      body: message.notification?.body ?? '',
      imageUrl: message.notification?.android?.imageUrl ?? 
                message.notification?.apple?.imageUrl,
      data: message.data,
      type: _parseNotificationType(message.data['type']),
      timestamp: DateTime.now(),
      isRead: false,
      priority: _parseNotificationPriority(message.data['priority']),
      route: message.data['route'],
      userId: message.data['userId'],
    );
  }

  /// Create NotificationData from JSON
  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
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
    );
  }

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
    };
  }

  /// Create a copy of this notification with updated fields
  NotificationData copyWith({
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
  }) {
    return NotificationData(
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
    return 'NotificationData(id: $id, title: $title, body: $body, type: $type, priority: $priority, isRead: $isRead)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationData &&
        other.id == id &&
        other.title == title &&
        other.body == body &&
        other.type == type &&
        other.priority == priority;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        body.hashCode ^
        type.hashCode ^
        priority.hashCode;
  }
}