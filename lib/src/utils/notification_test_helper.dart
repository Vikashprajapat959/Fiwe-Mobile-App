import 'dart:math';

import '../models/notification_data.dart';
import '../services/global_notification_overlay_service.dart';

/// Helper class for testing notification overlay functionality
class NotificationTestHelper {
  static final _random = Random();

  /// Dismiss current notification (if any)
  static Future<void> dismissCurrent() async {
    await GlobalNotificationOverlayService.instance.dismissNotification();
  }

  /// Force dismiss (for emergency testing)
  static void forceDismiss() {
    GlobalNotificationOverlayService.instance.forceDismiss();
  }

  /// Generate a random test notification
  static NotificationData generateTestNotification({
    NotificationType? type,
    NotificationPriority? priority,
    String? title,
    String? body,
  }) {
    final types = NotificationType.values;
    final priorities = NotificationPriority.values;

    return NotificationData(
      id: 'test_${DateTime.now().millisecondsSinceEpoch}',
      title: title ?? _getRandomTitle(),
      body: body ?? _getRandomBody(),
      type: type ?? types[_random.nextInt(types.length)],
      priority: priority ?? priorities[_random.nextInt(priorities.length)],
      timestamp: DateTime.now(),
      data: {'test': true, 'source': 'test_helper'},
    );
  }

  /// Get overlay service debug information
  static Map<String, dynamic> getOverlayDebugInfo() {
    final overlayInfo = GlobalNotificationOverlayService.instance.getDebugInfo();
    overlayInfo['storageType'] = 'in-memory-only';
    overlayInfo['autoDiscardEnabled'] = true;
    overlayInfo['autoDiscardDuration'] = '15 minutes';
    overlayInfo['maxInMemoryLimit'] = 20;
    return overlayInfo;
  }

  /// Check if overlay is currently active
  static bool isOverlayActive() {
    return GlobalNotificationOverlayService.instance.hasActiveNotification();
  }

  /// Show a test notification with specified parameters
  static Future<void> showTestNotification({
    NotificationType? type,
    NotificationPriority? priority,
    String? title,
    String? body,
  }) async {
    final notification = generateTestNotification(type: type, title: title, body: body, priority: priority);

    await GlobalNotificationOverlayService.instance.showNotification(notification);
  }

  /// Show a sequence of test notifications with delays
  static Future<void> showTestSequence() async {
    final notifications = [
      generateTestNotification(
        type: NotificationType.userMessage,
        priority: NotificationPriority.high,
        title: 'New Message',
        body: 'You have received a new message from John',
      ),
      generateTestNotification(
        type: NotificationType.systemAlert,
        priority: NotificationPriority.urgent,
        title: 'System Alert',
        body: 'Your account security settings have been updated',
      ),
      generateTestNotification(
        type: NotificationType.promotional,
        priority: NotificationPriority.normal,
        title: 'Special Offer',
        body: 'Get 50% off on your next purchase. Limited time offer!',
      ),
      generateTestNotification(
        type: NotificationType.reminder,
        priority: NotificationPriority.low,
        title: 'Reminder',
        body: 'Don\'t forget to complete your profile setup',
      ),
    ];

    for (int i = 0; i < notifications.length; i++) {
      await GlobalNotificationOverlayService.instance.showNotification(notifications[i]);

      // Wait for current notification to be dismissed or timeout
      await Future.delayed(const Duration(seconds: 7));
    }
  }

  /// Test auto-discard functionality with old notifications
  static Future<void> testAutoDiscard() async {
    final notification = generateTestNotification(
      type: NotificationType.systemAlert,
      priority: NotificationPriority.normal,
      title: 'Auto-Discard Test',
      body: 'This notification will be auto-discarded after 15 minutes if not read',
    );

    await GlobalNotificationOverlayService.instance.showNotification(notification);

    // Note: Auto-discard happens automatically every 15 minutes
    // In a real scenario, unread notifications older than 15 minutes are removed
  }

  /// Test in-memory limit by generating many notifications
  static Future<void> testInMemoryLimit() async {
    for (int i = 0; i < 25; i++) {
      final notification = generateTestNotification(
        title: 'Test Notification \${i + 1}',
        body: 'Testing in-memory notification limit (max 20)',
      );

      await GlobalNotificationOverlayService.instance.showNotification(notification);
      await Future.delayed(const Duration(milliseconds: 200));
    }

    print('Generated 25 notifications - only 20 should be kept in memory');
  }

  /// Test swipe dismissal by showing a notification with instructions
  static Future<void> testSwipeDismissal() async {
    final notification = generateTestNotification(
      type: NotificationType.systemAlert,
      priority: NotificationPriority.normal,
      title: 'Swipe Test',
      body: 'Try swiping this notification left or right to dismiss it',
    );

    await GlobalNotificationOverlayService.instance.showNotification(notification);
  }

  /// Random body generator
  static String _getRandomBody() {
    final bodies = [
      'This is a test notification to verify the overlay functionality.',
      'The notification system is working correctly.',
      'You can dismiss this by swiping or tapping the close button.',
      'This notification will auto-dismiss in a few seconds.',
      'Testing the notification positioning and animations.',
      'Verifying that notifications work across different screens.',
      'This is a longer notification body to test how the content wraps and displays within the notification overlay widget.',
    ];
    return bodies[_random.nextInt(bodies.length)];
  }

  /// Random title generator
  static String _getRandomTitle() {
    final titles = [
      'New Message',
      'System Update',
      'Reminder',
      'Alert',
      'Notification',
      'Important Update',
      'Quick Info',
      'Status Update',
    ];
    return titles[_random.nextInt(titles.length)];
  }
}
