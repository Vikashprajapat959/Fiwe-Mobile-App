import 'package:fiwe_notification/fiwe_notification.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Integration tests', () {
    test('NotificationManager methods exist', () {
      expect(InAppNotificationManager.dismiss, isNotNull);
      expect(InAppNotificationManager.dismissAll, isNotNull);
      expect(InAppNotificationManager.dismissAt, isNotNull); // New method
      expect(InAppNotificationManager.isVisible, isNotNull);
    });

    test('NotificationConfig creation', () {
      final config = NotificationConfig(
        title: 'Test Notification',
        description: 'This is a test notification',
        duration: const Duration(seconds: 5),
        enableStacking: true, // New parameter
      );

      expect(config.title, 'Test Notification');
      expect(config.description, 'This is a test notification');
      expect(config.duration, const Duration(seconds: 5));
      expect(config.enableStacking, true);
    });

    test('NotificationAction creation', () {
      final action = NotificationAction(label: 'Test Action', onPressed: () {});

      expect(action.label, 'Test Action');
      expect(action.style, NotificationActionStyle.primary);
    });

    test('StackedNotification class exists', () {
      // This is a basic test to ensure the class exists
      // Actual functionality would require a full widget test environment
      expect(StackedNotification, isNotNull);
    });

    test('Notification stacking configuration', () {
      final configWithoutStacking = NotificationConfig(
        title: 'Non-stacked Notification',
        enableStacking: false,
      );

      final configWithStacking = NotificationConfig(
        title: 'Stacked Notification',
        enableStacking: true,
      );

      expect(configWithoutStacking.enableStacking, false);
      expect(configWithStacking.enableStacking, true);
    });
  });
}