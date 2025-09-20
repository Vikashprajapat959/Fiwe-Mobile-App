/// Model for notification action buttons
class FCMAction {
  /// Unique identifier for the action
  final String id;

  /// Display title for the action button
  final String title;

  /// Type of action (e.g., 'join_room' or 'mute')
  final String actionType;

  /// Additional data associated with the action
  final Map<String, dynamic> data;

  const FCMAction({required this.id, required this.title, required this.actionType, required this.data});

  /// Create NotificationAction from JSON
  factory FCMAction.fromJson(Map<String, dynamic> json) {
    return FCMAction(
      id: json['id'] as String,
      title: json['title'] as String,
      actionType: json['actionType'] as String,
      data: Map<String, dynamic>.from(json['data'] as Map<String, dynamic>? ?? {}),
    );
  }

  /// Convert NotificationAction to JSON
  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'actionType': actionType, 'data': data};
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FCMAction && other.id == id && other.title == title && other.actionType == actionType;
  }

  @override
  int get hashCode {
    return id.hashCode ^ title.hashCode ^ actionType.hashCode;
  }
}
