import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:fiwe/src/models/notification_data.dart';
import 'package:fiwe/src/services/badge_service.dart';
import 'package:fiwe/src/services/global_notification_overlay_service.dart';
import 'package:fiwe/src/controllers/notification_controller.dart';

void main() {
  group('Notification System Tests', () {
    setUpAll(() {
      // Initialize GetX for testing
      Get.testMode = true;
    });

    tearDownAll(() {
      Get.reset();
    });

    test('NotificationData model creation from JSON', () {
      final json = {
        'id': 'test123',
        'title': 'Test Notification',
        'body': 'This is a test notification',
        'type': 1, // NotificationType.systemAlert
        'priority': 2, // NotificationPriority.high
        'timestamp': DateTime.now().toIso8601String(),
        'isRead': false,
        'data': {'key': 'value'},
      };

      final notification = NotificationData.fromJson(json);
      
      expect(notification.id, 'test123');
      expect(notification.title, 'Test Notification');
      expect(notification.body, 'This is a test notification');
      expect(notification.type, NotificationType.systemAlert);
      expect(notification.priority, NotificationPriority.high);
      expect(notification.isRead, false);
      expect(notification.data['key'], 'value');
    });

    test('NotificationData model toJson', () {
      final notification = NotificationData(
        id: 'test456',
        title: 'JSON Test',
        body: 'Testing JSON conversion',
        type: NotificationType.userMessage,
        priority: NotificationPriority.normal,
        timestamp: DateTime(2024, 1, 1),
        isRead: true,
        data: {'test': 'data'},
      );

      final json = notification.toJson();
      
      expect(json['id'], 'test456');
      expect(json['title'], 'JSON Test');
      expect(json['body'], 'Testing JSON conversion');
      expect(json['type'], 0); // NotificationType.userMessage index
      expect(json['priority'], 1); // NotificationPriority.normal index
      expect(json['isRead'], true);
      expect(json['data']['test'], 'data');
    });

    test('NotificationData copyWith functionality', () {
      final original = NotificationData(
        id: 'original',
        title: 'Original Title',
        body: 'Original Body',
        type: NotificationType.reminder,
        priority: NotificationPriority.low,
        timestamp: DateTime.now(),
        isRead: false,
        data: {},
      );

      final updated = original.copyWith(
        title: 'Updated Title',
        isRead: true,
      );
      
      expect(updated.id, 'original'); // unchanged
      expect(updated.title, 'Updated Title'); // changed
      expect(updated.body, 'Original Body'); // unchanged
      expect(updated.isRead, true); // changed
      expect(updated.type, NotificationType.reminder); // unchanged
    });

    test('NotificationData priority-based channel ID', () {
      final lowPriority = NotificationData(
        id: 'low',
        title: 'Low',
        body: 'Low priority notification',
        type: NotificationType.promotional,
        priority: NotificationPriority.low,
        timestamp: DateTime.now(),
        data: {},
      );

      final highPriority = NotificationData(
        id: 'high',
        title: 'High',
        body: 'High priority notification',
        type: NotificationType.systemAlert,
        priority: NotificationPriority.urgent,
        timestamp: DateTime.now(),
        data: {},
      );
      
      expect(lowPriority.androidChannelId, 'low_priority_channel');
      expect(highPriority.androidChannelId, 'urgent_priority_channel');
      expect(lowPriority.androidImportance, 2); // IMPORTANCE_LOW
      expect(highPriority.androidImportance, 5); // IMPORTANCE_MAX
    });

    test('BadgeService initialization and basic operations', () async {
      // Mock BadgeService for testing
      final badgeService = BadgeService();
      Get.put(badgeService);
      
      // Test initial state
      expect(badgeService.badgeCount, 0);
      
      // Note: Actual badge operations would require platform-specific testing
      // This test validates the service structure and basic functionality
    });

    test('NotificationController initialization', () async {
      // Initialize controller
      final controller = NotificationController();
      Get.put(controller);
      
      // Test initial state
      expect(controller.notifications, isEmpty);
      expect(controller.unreadCount, 0);
      expect(controller.isLoading, false);
      expect(controller.currentForegroundNotification, isNull);
    });

    test('GlobalNotificationOverlayService initialization and basic operations', () async {
      // Initialize global overlay service
      final overlayService = GlobalNotificationOverlayService();
      Get.put(overlayService);
      
      // Test initial state
      expect(overlayService.isVisible, false);
      expect(overlayService.currentNotification, isNull);
      expect(overlayService.hasActiveNotification(), false);
      
      // Test debug info
      final debugInfo = overlayService.getDebugInfo();
      expect(debugInfo['isVisible'], false);
      expect(debugInfo['hasNotification'], false);
    });

    test('GlobalNotificationOverlayService notification management', () async {
      final overlayService = GlobalNotificationOverlayService();
      Get.put(overlayService);
      
      final testNotification = NotificationData(
        id: 'overlay_test',
        title: 'Overlay Test',
        body: 'Testing overlay functionality',
        type: NotificationType.systemAlert,
        priority: NotificationPriority.normal,
        timestamp: DateTime.now(),
        data: {'test': true},
      );
      
      // Note: In a real test environment, you would mock the overlay functionality
      // since we can't create actual overlays in unit tests
      
      // Test notification ID tracking
      expect(overlayService.getCurrentNotificationId(), isNull);
      
      // Test force dismiss
      overlayService.forceDismiss();
      expect(overlayService.hasActiveNotification(), false);
    });
  });
}
