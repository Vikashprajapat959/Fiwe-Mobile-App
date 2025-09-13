import 'package:get/get.dart';

import '../models/notification_data.dart';
import '../services/global_notification_overlay_service.dart';

/// Utility class for notification actions that don't require a specific notification instance
class NotificationActions {
  /// Dismiss all notifications
  static Future<void> dismissAll() async {
    try {
      await GlobalNotificationOverlayService.instance.dismissNotification();
    } catch (e) {
      // Log error but don't throw to avoid breaking the UI
      Get.log('Error dismissing all notifications: $e');
    }
  }

  /// Check if any notification is currently being displayed
  static Future<bool> isAnyDisplayed() async {
    try {
      return GlobalNotificationOverlayService.instance.hasActiveNotification();
    } catch (e) {
      Get.log('Error checking if any notification is displayed: $e');
      return false;
    }
  }
}

/// Extension on NotificationData to provide convenient methods for notification actions
extension NotificationDataExtension on NotificationData {
  /// Dismiss this notification if it's currently being displayed
  Future<void> dismiss() async {
    try {
      final service = GlobalNotificationOverlayService.instance;
      // Check if this notification is currently displayed
      if (service.getCurrentNotificationId() == id) {
        await service.dismissNotification();
      }
    } catch (e) {
      // Log error but don't throw to avoid breaking the UI
      Get.log('Error dismissing notification: $e');
    }
  }

  /// Check if this notification is currently being displayed
  Future<bool> isDisplayed() async {
    try {
      return GlobalNotificationOverlayService.instance.getCurrentNotificationId() == id;
    } catch (e) {
      Get.log('Error checking notification display status: $e');
      return false;
    }
  }

  /// Show this notification using the global notification overlay service
  Future<void> show() async {
    try {
      await GlobalNotificationOverlayService.instance.showNotification(this);
    } catch (e) {
      // Log error but don't throw to avoid breaking the UI
      Get.log('Error showing notification: $e');
    }
  }
}
