import 'package:flutter/material.dart';

/// Represents a custom action button in a notification
class NotificationAction {
  /// The text to display on the button
  final String label;

  /// The callback function to execute when the button is pressed
  final VoidCallback onPressed;

  /// The visual style of the button
  final NotificationActionStyle style;

  /// Creates a notification action
  const NotificationAction({
    required this.label,
    required this.onPressed,
    this.style = NotificationActionStyle.primary,
  });
}

/// Defines the visual style of a notification action button
enum NotificationActionStyle {
  /// Primary action style (typically more prominent)
  primary,

  /// Secondary action style (typically less prominent)
  secondary,
}

enum NotificationType { info, success, warning, error }

/// Configuration object for customizing notification appearance and behavior
class NotificationConfig {
  /// The title text for the notification
  final String title;

  /// The detailed description text (optional)
  final String? description;

  /// Optional icon to display
  final Widget? icon;

  /// Auto-dismiss duration (null for no auto-dismiss)
  final Duration? duration;

  /// Custom metadata associated with notification
  final Map<String, dynamic>? metadata;

  /// Custom action buttons
  final List<NotificationAction>? actions;

  /// Callback when notification is dismissed
  final VoidCallback? onDismiss;

  /// Whether to dismiss the last notification before showing a new one
  final bool dismissBeforeShow;

  /// Decoration for the notification container (optional)
  final BoxDecoration? decoration;

  /// Whether to enable stacking for this notification
  /// When true, new notifications will stack on top of existing ones
  /// When false, behaves as current implementation
  final bool enableStacking;

  /// Notification type
  /// This can be used to apply different styles based on type
  /// BoxDecoration can still override this
  final NotificationType? type;

  /// Creates a notification configuration
  const NotificationConfig({
    required this.title,
    this.description,
    this.icon,
    this.duration,
    this.metadata,
    this.actions,
    this.onDismiss,
    this.decoration,
    this.type = NotificationType.info,
    this.dismissBeforeShow = false,
    this.enableStacking = true, // Default to enabled
  });
}
