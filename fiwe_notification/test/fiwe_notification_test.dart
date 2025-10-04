import 'package:fiwe_notification/fiwe_notification.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Notification Models', () {
    test('NotificationAction creation', () {
      final action = NotificationAction(label: 'Test Action', onPressed: () {});

      expect(action.label, 'Test Action');
      expect(action.style, NotificationActionStyle.primary);
    });

    test('NotificationConfig creation', () {
      final config = NotificationConfig(
        title: 'Test Notification',
        description: 'This is a test notification',
        duration: const Duration(seconds: 5),
      );

      expect(config.title, 'Test Notification');
      expect(config.description, 'This is a test notification');
      expect(config.duration, const Duration(seconds: 5));
      expect(config.dismissBeforeShow, false);
      expect(config.enableStacking, true); // Default value
    });

    test('NotificationConfig with custom values', () {
      final config = NotificationConfig(
        title: 'Test Notification', 
        dismissBeforeShow: true,
        enableStacking: false,
      );

      expect(config.dismissBeforeShow, true);
      expect(config.enableStacking, false);
    });
  });

  group('InAppNotificationManager', () {
    test('Manager methods exist', () {
      expect(InAppNotificationManager.dismiss, isNotNull);
      expect(InAppNotificationManager.dismissAll, isNotNull);
      expect(InAppNotificationManager.dismissAt, isNotNull); // New method
      expect(InAppNotificationManager.isVisible, isNotNull);
    });
  });

  group('StackedNotification', () {
    test('StackedNotification creation', () {
      // This is a basic test to ensure the class exists
      // Actual functionality would require a full widget test environment
      expect(StackedNotification, isNotNull);
    });
  });
}