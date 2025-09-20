
import 'package:fiwe_notification/src/models/notification_config.dart';
import 'package:fiwe_notification/src/notification_overlay.dart';
import 'package:flutter/material.dart';

/// Central controller for managing notification lifecycle
/// Provides static methods to show, dismiss, and check visibility of notifications
/// This class acts as a facade to the InAppNotificationOverlay
class InAppNotificationManager {
  // Private constructor to prevent instantiation
  InAppNotificationManager._();

  static BuildContext? _context;

  /// Set the BuildContext for the notification manager
  /// This context is used to display notifications within the app's widget tree

  static InAppNotificationManager setContext(BuildContext context) {
    _context = context;
    return InAppNotificationManager._();
  }

  /// Show a notification with the provided configuration
  /// Example:
  /// ```dart
  /// InAppNotificationManager.setContext(context).show(
  ///  NotificationConfig(
  ///   title: "Success!",
  ///  description: "Your action was completed successfully.",
  ///  icon: Icon(Icons.check_circle, color: Colors.green),
  /// duration: Duration(seconds: 5),
  /// metadata: {"type": "success", "id": "123"},
  /// ),
  /// );
  /// ```
  ///
  void show(NotificationConfig config) {
    assert(
      _context != null,
      'InAppNotificationManager: Context is not set. Call setContext() before showing notifications.',
    );
    InAppNotificationOverlay.show(config, _context!);
  }

  /// Dismiss the currently visible notification
  static void dismiss() {
    InAppNotificationOverlay.dismiss();
  }

  /// Dismiss a specific notification by index
  static void dismissAt(int index) {
    InAppNotificationOverlay.dismissAt(index);
  }

  /// Dismiss all notifications
  static void dismissAll() {
    InAppNotificationOverlay.dismissAll();
  }

  /// Check if any notifications are visible
  static bool get isVisible => InAppNotificationOverlay.isVisible;
}
