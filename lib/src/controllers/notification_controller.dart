// import 'dart:async';
// import 'dart:developer' as dev;

// import 'package:get/get.dart';

// import '../models/fcm_notification_data.dart';
// import '../services/badge_service.dart';
// import '../services/notification_service.dart';
// import '../utils/constants.dart';

// /// Controller for managing notification state and user interactions
// ///
// /// This controller handles in-memory notifications only for the current session.
// /// For persistent notification history, see NotificationHistoryController which
// /// will be implemented when backend API is available.
// ///
// /// Current functionality:
// /// - In-memory notification storage (max 20 notifications)
// /// - Auto-discard after 15 minutes for unread notifications
// /// - Badge count management
// /// - Foreground notification display via GlobalNotificationOverlayService
// ///
// /// Future scope (backend implementation):
// /// - Persistent notification history from server
// /// - Cross-device notification sync
// /// - Advanced filtering and search
// /// - Notification analytics and statistics
// class NotificationController extends GetxController {
//   // Auto-discard duration for notifications (15 minutes)
//   static const Duration _autoDiscardDuration = Duration(minutes: 15);

//   static NotificationController get instance => Get.find<NotificationController>();
//   // Observables for reactive UI
//   final RxList<FCMNotificationData> _notifications = <FCMNotificationData>[].obs;
//   final RxInt _unreadCount = 0.obs;
//   final RxBool _isLoading = false.obs;

//   final RxnString _currentForegroundNotification = RxnString();

//   // Stream subscription for notification service
//   StreamSubscription<FCMNotificationData>? _notificationSubscription;

//   // Timer for auto-discarding notifications
//   Timer? _autoDiscardTimer;

//   /// Get current foreground notification
//   String? get currentForegroundNotification => _currentForegroundNotification.value;

//   /// Get current foreground notification as observable
//   RxnString get currentForegroundNotificationObs => _currentForegroundNotification;

//   /// Get loading state
//   bool get isLoading => _isLoading.value;

//   /// Get loading state as observable
//   RxBool get isLoadingObs => _isLoading;

//   /// Get notifications list
//   List<FCMNotificationData> get notifications => _notifications.toList();

//   /// Get notifications as observable
//   RxList<FCMNotificationData> get notificationsObs => _notifications;

//   /// Get unread count
//   int get unreadCount => _unreadCount.value;

//   /// Get unread count as observable
//   RxInt get unreadCountObs => _unreadCount;

//   /// Add notification to the in-memory list
//   void addNotification(FCMNotificationData notification) {
//     try {
//       // Check if notification already exists
//       final existingIndex = _notifications.indexWhere((n) => n.id == notification.id);

//       if (existingIndex == -1) {
//         // Add new notification at the beginning (most recent first)
//         _notifications.insert(0, notification);

//         // Increment unread count if not read
//         if (!notification.isRead) {
//           _unreadCount.value++;
//         }

//         // Limit in-memory notifications to prevent memory issues
//         // Only keep recent notifications for current session
//         if (_notifications.length > Constants.maxInMemoryNotifications) {
//           // Get notifications to be removed before removing them
//           final notificationsToRemove = _notifications.sublist(Constants.maxInMemoryNotifications);

//           // Remove excess notifications
//           _notifications.removeRange(Constants.maxInMemoryNotifications, _notifications.length);

//           // Adjust unread count if removed notifications were unread
//           for (final removed in notificationsToRemove) {
//             if (!removed.isRead && _unreadCount.value > 0) {
//               _unreadCount.value--;
//             }
//           }
//         }

//         dev.log('Notification added to in-memory list: ${notification.title}', name: 'NotificationController');
//       } else {
//         dev.log('Notification already exists: ${notification.id}', name: 'NotificationController');
//       }
//     } catch (e) {
//       dev.log('Error adding notification: $e', name: 'NotificationController');
//     }
//   }

//   /// Clear all notifications from memory
//   void clearAll() {
//     try {
//       _notifications.clear();
//       _unreadCount.value = 0;
//       BadgeService.instance.clearBadge();

//       dev.log('All notifications cleared from memory', name: 'NotificationController');
//     } catch (e) {
//       dev.log('Error clearing notifications: $e', name: 'NotificationController');
//     }
//   }

//   /// Dismiss foreground notification
//   void dismissForegroundNotification() {
//     try {
//       //TODO:
//       // GlobalNotificationOverlayService.instance.dismissNotification();
//       _currentForegroundNotification.value = null;
//       dev.log('Foreground notification dismissed', name: 'NotificationController');
//     } catch (e) {
//       dev.log('Error dismissing foreground notification: $e', name: 'NotificationController');
//     }
//   }

//   /// Get controller debug info
//   Map<String, dynamic> getDebugInfo() {
//     return {
//       'notificationCount': _notifications.length,
//       'unreadCount': _unreadCount.value,
//       'isLoading': _isLoading.value,
//       'hasSubscription': _notificationSubscription != null,
//       'currentForegroundNotification': _currentForegroundNotification.value,
//       'storageType': 'in-memory-only',
//     };
//   }

//   /// Get notification by ID
//   FCMNotificationData? getNotificationById(String notificationId) {
//     try {
//       return _notifications.firstWhereOrNull((n) => n.id == notificationId);
//     } catch (e) {
//       dev.log('Error getting notification by ID: $e', name: 'NotificationController');
//       return null;
//     }
//   }

//   /// Get notifications by type
//   List<FCMNotificationData> getNotificationsByType(NotificationType type) {
//     try {
//       return _notifications.where((n) => n.type == type).toList();
//     } catch (e) {
//       dev.log('Error getting notifications by type: $e', name: 'NotificationController');
//       return [];
//     }
//   }

//   /// Get unread notifications
//   List<FCMNotificationData> getUnreadNotifications() {
//     try {
//       return _notifications.where((n) => !n.isRead).toList();
//     } catch (e) {
//       dev.log('Error getting unread notifications: $e', name: 'NotificationController');
//       return [];
//     }
//   }

//   /// Mark all notifications as read
//   void markAllAsRead() {
//     try {
//       int unreadToUpdate = 0;

//       for (int i = 0; i < _notifications.length; i++) {
//         if (!_notifications[i].isRead) {
//           _notifications[i] = _notifications[i].copyWith(isRead: true);
//           unreadToUpdate++;
//         }
//       }

//       if (unreadToUpdate > 0) {
//         _unreadCount.value = 0;
//         BadgeService.instance.clearBadge();

//         dev.log('$unreadToUpdate notifications marked as read', name: 'NotificationController');
//       }
//     } catch (e) {
//       dev.log('Error marking all notifications as read: $e', name: 'NotificationController');
//     }
//   }

//   /// Mark notification as read
//   void markAsRead(String notificationId) {
//     try {
//       final index = _notifications.indexWhere((n) => n.id == notificationId);

//       if (index != -1) {
//         final notification = _notifications[index];
//         if (!notification.isRead) {
//           // Update notification
//           _notifications[index] = notification.copyWith(isRead: true);

//           // Decrement unread count
//           if (_unreadCount.value > 0) {
//             _unreadCount.value--;
//           }

//           // Update badge count
//           BadgeService.instance.decrementBadge();

//           dev.log('Notification marked as read: $notificationId', name: 'NotificationController');
//         }
//       }
//     } catch (e) {
//       dev.log('Error marking notification as read: $e', name: 'NotificationController');
//     }
//   }

//   /// Navigate to notification destination
//   void navigateToNotification(FCMNotificationData notification) {
//     try {
//       // Mark as read
//       markAsRead(notification.id);

//       // Dismiss global overlay if showing TODO:
//       // GlobalNotificationOverlayService.instance.dismissNotification();
//       _currentForegroundNotification.value = null;

//       // Navigate based on notification data
//       if (notification.route != null && notification.route!.isNotEmpty) {
//         Get.toNamed(notification.route!, arguments: notification.data);
//       } else {
//         // Default navigation based on type
//         switch (notification.type) {
//           case NotificationType.userMessage:
//             Get.toNamed(Constants.homeViewRoute);
//             break;
//           case NotificationType.systemAlert:
//           case NotificationType.promotional:
//           //TODO: handle room invite
//           case NotificationType.roomInvite:
//           case NotificationType.reminder:
//             Get.toNamed(Constants.homeViewRoute);
//             break;
//         }
//       }

//       dev.log('Navigated to notification: ${notification.title}', name: 'NotificationController');
//     } catch (e) {
//       dev.log('Error navigating to notification: $e', name: 'NotificationController');
//     }
//   }

//   @override
//   void onClose() {
//     _notificationSubscription?.cancel();
//     _stopAutoDiscardTimer();
//     super.onClose();
//   }

//   @override
//   Future<void> onInit() async {
//     super.onInit();
//     await _initializeController();
//   }

//   /// Remove notification from in-memory list
//   void removeNotification(String notificationId) {
//     try {
//       final index = _notifications.indexWhere((n) => n.id == notificationId);

//       if (index != -1) {
//         final notification = _notifications[index];
//         _notifications.removeAt(index);

//         // Decrement unread count if notification was unread
//         if (!notification.isRead && _unreadCount.value > 0) {
//           _unreadCount.value--;
//           BadgeService.instance.decrementBadge();
//         }

//         dev.log('Notification removed from memory: $notificationId', name: 'NotificationController');
//       }
//     } catch (e) {
//       dev.log('Error removing notification: $e', name: 'NotificationController');
//     }
//   }

//   /// Auto-discard old notifications that user hasn't interacted with
//   void _autoDiscardOldNotifications() {
//     try {
//       final now = DateTime.now();
//       final cutoffTime = now.subtract(_autoDiscardDuration);

//       // Count notifications to be removed
//       final notificationsToRemove = _notifications
//           .where((notification) => notification.timestamp.isBefore(cutoffTime) && !notification.isRead)
//           .toList();

//       if (notificationsToRemove.isNotEmpty) {
//         // Remove old unread notifications
//         for (final notification in notificationsToRemove) {
//           _notifications.removeWhere((n) => n.id == notification.id);

//           // Decrement unread count and badge
//           if (_unreadCount.value > 0) {
//             _unreadCount.value--;
//             BadgeService.instance.decrementBadge();
//           }
//         }

//         dev.log('Auto-discarded ${notificationsToRemove.length} old notifications', name: 'NotificationController');
//       }
//     } catch (e) {
//       dev.log('Error auto-discarding notifications: $e', name: 'NotificationController');
//     }
//   }

//   /// Handle new incoming notification
//   void _handleNewNotification(FCMNotificationData notification) {
//     try {
//       // Add to notifications list
//       addNotification(notification);

//       // Show foreground notification
//       _showForegroundNotification(notification);

//       dev.log('New notification handled: ${notification.title}', name: 'NotificationController');
//     } catch (e) {
//       dev.log('Error handling new notification: $e', name: 'NotificationController');
//     }
//   }

//   /// Initialize the notification controller
//   Future<void> _initializeController() async {
//     try {
//       _isLoading.value = true;

//       // Setup notification service listener
//       _setupNotificationListener();

//       // Start auto-discard timer
//       _startAutoDiscardTimer();

//       dev.log('NotificationController initialized for in-memory notifications only', name: 'NotificationController');
//     } catch (e) {
//       dev.log('Error initializing NotificationController: $e', name: 'NotificationController');
//     } finally {
//       _isLoading.value = false;
//     }
//   }

//   /// Setup notification service listener
//   void _setupNotificationListener() {
//     try {
//       _notificationSubscription = NotificationService.instance.notificationStream.listen(
//         (FCMNotificationData notification) {
//           _handleNewNotification(notification);
//         },
//         onError: (error) {
//           dev.log('Error in notification stream: $error', name: 'NotificationController');
//         },
//       );

//       dev.log('Notification listener setup complete', name: 'NotificationController');
//     } catch (e) {
//       dev.log('Error setting up notification listener: $e', name: 'NotificationController');
//     }
//   }

//   /// Show foreground notification
//   void _showForegroundNotification(FCMNotificationData notification) {
//     try {
//       // Use global overlay service to show notification TODO:
//       //GlobalNotificationOverlayService.instance.showNotification(notification);

//       dev.log(
//         'Foreground notification shown via global overlay: ${notification.title}',
//         name: 'NotificationController',
//       );
//     } catch (e) {
//       dev.log('Error showing foreground notification: $e', name: 'NotificationController');
//     }
//   }

//   /// Start auto-discard timer for old notifications
//   void _startAutoDiscardTimer() {
//     _autoDiscardTimer?.cancel();
//     _autoDiscardTimer = Timer.periodic(_autoDiscardDuration, (_) => _autoDiscardOldNotifications());
//   }

//   /// Stop auto-discard timer
//   void _stopAutoDiscardTimer() {
//     _autoDiscardTimer?.cancel();
//     _autoDiscardTimer = null;
//   }
// }
