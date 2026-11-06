// import 'dart:async';
// import 'dart:developer' as dev;

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../models/fcm_notification_data.dart';
// import '../utils/constants.dart';
// import '../widgets/global_notification_overlay_widget.dart';

// /// Global service for managing notification overlays across the entire app
// class GlobalNotificationOverlayService extends GetxService {
//   static GlobalNotificationOverlayService get instance => Get.find<GlobalNotificationOverlayService>();

//   // Observable for current notification
//   final Rxn<FCMNotificationData> _currentNotification = Rxn<FCMNotificationData>();

//   // Observable for overlay visibility
//   final RxBool _isVisible = false.obs;

//   // Service initialization flag
//   final RxBool _isInitialized = false.obs;

//   // Timer for auto-dismiss
//   Timer? _autoDismissTimer;

//   // Overlay entry reference
//   OverlayEntry? _overlayEntry;

//   /// Get current notification
//   FCMNotificationData? get currentNotification => _currentNotification.value;

//   /// Get current notification as observable
//   Rxn<FCMNotificationData> get currentNotificationObs => _currentNotification;

//   /// Check if service is ready to show notifications
//   bool get isReady => _isInitialized.value && (Get.overlayContext != null || Get.context != null);

//   /// Check if overlay is visible
//   bool get isVisible => _isVisible.value;

//   /// Get visibility as observable
//   RxBool get isVisibleObs => _isVisible;

//   /// Dismiss notification overlay
//   Future<void> dismissNotification() async {
//     dev.log(
//       'Attempting to dismiss notification. Current state - isVisible: ${_isVisible.value}, hasNotification: ${_currentNotification.value != null}, hasOverlayEntry: ${_overlayEntry != null}',
//       name: 'GlobalOverlay',
//     );

//     try {
//       if (_isVisible.value) {
//         _isVisible.value = false;
//         _currentNotification.value = null;

//         // Cancel auto-dismiss timer
//         _autoDismissTimer?.cancel();
//         _autoDismissTimer = null;

//         // Remove overlay safely
//         await _removeOverlaySafely();

//         // Add an additional check to ensure overlay is removed
//         await _ensureOverlayRemoved();

//         dev.log('Notification overlay dismissed successfully', name: 'GlobalOverlay');
//       } else {
//         dev.log('Notification overlay was not visible, nothing to dismiss', name: 'GlobalOverlay');
//       }
//     } catch (e) {
//       dev.log('Error dismissing notification overlay: $e', name: 'GlobalOverlay');
//       // Force reset state on error
//       _isVisible.value = false;
//       _currentNotification.value = null;
//       _autoDismissTimer?.cancel();
//       _autoDismissTimer = null;
//       _overlayEntry = null;
//     }
//   }

//   /// Dismiss notification by ID (if it matches current notification)
//   Future<void> dismissNotificationById(String notificationId) async {
//     if (_currentNotification.value?.id == notificationId) {
//       await dismissNotification();
//     }
//   }

//   /// Force dismiss (without animation - for emergency cases)
//   void forceDismiss() {
//     try {
//       _isVisible.value = false;
//       _currentNotification.value = null;
//       _autoDismissTimer?.cancel();
//       _autoDismissTimer = null;

//       // Force remove overlay entry
//       if (_overlayEntry != null) {
//         try {
//           if (_overlayEntry!.mounted) {
//             _overlayEntry!.remove();
//           } else {
//             dev.log('Overlay entry not mounted, skipping remove', name: 'GlobalOverlay');
//           }
//         } catch (e) {
//           dev.log('Error force removing overlay entry: $e', name: 'GlobalOverlay');
//         } finally {
//           _overlayEntry = null;
//         }
//       }

//       dev.log('Notification overlay force dismissed', name: 'GlobalOverlay');
//     } catch (e) {
//       dev.log('Error in force dismiss: $e', name: 'GlobalOverlay');
//       // Ensure state is reset even if errors occur
//       _isVisible.value = false;
//       _currentNotification.value = null;
//       _autoDismissTimer = null;
//       _overlayEntry = null;
//     }
//   }

//   /// Get current notification ID
//   String? getCurrentNotificationId() {
//     return _currentNotification.value?.id;
//   }

//   /// Get debug information
//   Map<String, dynamic> getDebugInfo() {
//     return {
//       'isInitialized': _isInitialized.value,
//       'isReady': isReady,
//       'isVisible': _isVisible.value,
//       'hasNotification': _currentNotification.value != null,
//       'notificationId': _currentNotification.value?.id,
//       'notificationTitle': _currentNotification.value?.title,
//       'hasOverlayEntry': _overlayEntry != null,
//       'hasAutoDismissTimer': _autoDismissTimer != null,
//       'hasOverlayContext': Get.overlayContext != null,
//       'hasContext': Get.context != null,
//     };
//   }

//   /// Check if notification overlay is currently active
//   bool hasActiveNotification() {
//     return _isVisible.value && _currentNotification.value != null;
//   }

//   @override
//   void onClose() {
//     // Clean up resources
//     _autoDismissTimer?.cancel();
//     _removeOverlay();
//     _isInitialized.value = false;
//     super.onClose();
//   }

//   @override
//   void onInit() {
//     super.onInit();

//     // Mark as initialized after a short delay to ensure GetX context is available
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _isInitialized.value = true;
//       dev.log('GlobalNotificationOverlayService initialized and ready', name: 'GlobalOverlay');
//     });
//   }

//   /// Show notification overlay
//   Future<void> showNotification(FCMNotificationData notification) async {
//     try {
//       dev.log(
//         'Attempting to show notification: ${notification.title}. Current state - isReady: $isReady, hasContext: ${Get.overlayContext != null || Get.context != null}',
//         name: 'GlobalOverlay',
//       );

//       // Check if service is ready
//       if (!isReady) {
//         dev.log('Service not ready to show notifications, deferring...', name: 'GlobalOverlay');
//         // Retry after a short delay if not ready
//         Future.delayed(const Duration(milliseconds: 500), () {
//           if (isReady) {
//             showNotification(notification);
//           } else {
//             dev.log('Service still not ready after delay, skipping notification', name: 'GlobalOverlay');
//           }
//         });
//         return;
//       }

//       // Validate notification data
//       if (notification.title.isEmpty) {
//         dev.log('Cannot show notification: title is empty', name: 'GlobalOverlay');
//         return;
//       }

//       // Check if we have a valid context available
//       final context = Get.overlayContext ?? Get.context;
//       if (context == null) {
//         dev.log('Cannot show notification: no valid context available', name: 'GlobalOverlay');
//         return;
//       }

//       dev.log('Context available, proceeding with notification display', name: 'GlobalOverlay');

//       // Dismiss current notification if any (but don't null the overlay entry yet)
//       if (_isVisible.value) {
//         dev.log('Dismissing current notification before showing new one', name: 'GlobalOverlay');
//         await _dismissCurrentNotification();
//       }

//       // Set new notification
//       _currentNotification.value = notification;
//       _isVisible.value = true;

//       // Create and insert overlay
//       _createOverlay();

//       // Set auto-dismiss timer
//       _setAutoDismissTimer();

//       dev.log('Notification overlay shown: ${notification.title}', name: 'GlobalOverlay');
//     } catch (e) {
//       dev.log('Error showing notification overlay: $e', name: 'GlobalOverlay');
//       // Reset state on error
//       _isVisible.value = false;
//       _currentNotification.value = null;
//     }
//   }

//   /// Update notification auto-dismiss duration
//   void updateAutoDismissDuration(Duration duration) {
//     if (_isVisible.value) {
//       _autoDismissTimer?.cancel();
//       _autoDismissTimer = Timer(duration, () {
//         dismissNotification();
//       });
//     }
//   }

//   /// Create overlay entry
//   void _createOverlay() {
//     dev.log('Creating overlay entry', name: 'GlobalOverlay');

//     // Ensure we have a valid notification before creating overlay
//     final notification = _currentNotification.value;
//     if (notification == null) {
//       dev.log('Cannot create overlay: notification is null', name: 'GlobalOverlay');
//       return;
//     }

//     try {
//       // Clean up any existing overlay first, but only if it's different
//       if (_overlayEntry != null) {
//         dev.log('Cleaning up existing overlay entry', name: 'GlobalOverlay');
//         _removeOverlay();
//       }

//       _overlayEntry = OverlayEntry(
//         builder: (context) => GlobalNotificationOverlayWidget(
//           notification: notification,
//           onDismiss: () {
//             dev.log('Overlay widget dismissed, calling service dismiss', name: 'GlobalOverlay');
//             dismissNotification();
//           },
//           onTap: _handleNotificationTap,
//         ),
//       );

//       // Insert overlay into the app with better error handling
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _insertOverlaySafely();
//       });
//     } catch (e) {
//       dev.log('Error creating overlay entry: $e', name: 'GlobalOverlay');
//       _overlayEntry = null;
//       _isVisible.value = false;
//       _currentNotification.value = null;
//     }
//   }

//   /// Dismiss current notification without removing overlay entry immediately
//   Future<void> _dismissCurrentNotification() async {
//     try {
//       if (_isVisible.value) {
//         _isVisible.value = false;
//         _currentNotification.value = null;

//         // Cancel auto-dismiss timer
//         _autoDismissTimer?.cancel();
//         _autoDismissTimer = null;

//         // Remove overlay safely
//         await _removeOverlaySafely();

//         // Add an additional check to ensure overlay is removed
//         await _ensureOverlayRemoved();

//         dev.log('Current notification dismissed successfully', name: 'GlobalOverlay');
//       }
//     } catch (e) {
//       dev.log('Error dismissing current notification: $e', name: 'GlobalOverlay');
//       // Force reset state on error
//       _isVisible.value = false;
//       _currentNotification.value = null;
//       _autoDismissTimer?.cancel();
//       _autoDismissTimer = null;
//     }
//   }

//   /// Ensure overlay is completely removed
//   Future<void> _ensureOverlayRemoved() async {
//     // Small delay to allow for UI updates
//     await Future.delayed(const Duration(milliseconds: 50));

//     // Force a global rebuild if needed
//     try {
//       final context = Get.context ?? Get.overlayContext;
//       if (context != null) {
//         (context as Element).markNeedsBuild();
//       }
//     } catch (e) {
//       dev.log('Error forcing global rebuild: $e', name: 'GlobalOverlay');
//     }
//   }

//   /// Handle notification tap
//   void _handleNotificationTap() {
//     final notification = _currentNotification.value;
//     if (notification != null) {
//       // Navigate based on notification data
//       if (notification.route != null && notification.route!.isNotEmpty) {
//         Get.toNamed(notification.route!, arguments: notification.data);
//       } else {
//         // Default navigation based on type

//         // TODO: handle on room invite
//         switch (notification.type) {
//           case NotificationType.userMessage:
//             Get.toNamed(Constants.homeViewRoute);
//             break;
//           case NotificationType.systemAlert:
//           case NotificationType.promotional:
//           case NotificationType.roomInvite:
//           case NotificationType.reminder:
//             Get.toNamed(Constants.homeViewRoute);
//             break;
//         }
//       }

//       // Dismiss notification after navigation
//       dismissNotification();

//       dev.log('Notification tapped and navigation handled: ${notification.title}', name: 'GlobalOverlay');
//     }
//   }

//   /// Safely insert overlay entry
//   void _insertOverlaySafely() {
//     try {
//       // Try to get overlay context, with fallback options
//       final overlayContext = Get.overlayContext ?? Get.context;
//       if (overlayContext == null) {
//         dev.log('Cannot insert overlay: no valid context available', name: 'GlobalOverlay');
//         _removeOverlay();
//         _isVisible.value = false;
//         _currentNotification.value = null;
//         return;
//       }

//       // Check if we still have a valid overlay entry
//       if (_overlayEntry == null) {
//         dev.log('Cannot insert overlay: overlay entry is null', name: 'GlobalOverlay');
//         return;
//       }

//       if (!_overlayEntry!.mounted) {
//         final overlay = Overlay.of(overlayContext);
//         overlay.insert(_overlayEntry!);
//         dev.log('Overlay entry inserted successfully', name: 'GlobalOverlay');
//       } else {
//         dev.log('Overlay entry already mounted, skipping insert', name: 'GlobalOverlay');
//       }
//     } catch (e) {
//       dev.log('Error inserting overlay: $e', name: 'GlobalOverlay');
//       _removeOverlay();
//       // Reset state on error
//       _isVisible.value = false;
//       _currentNotification.value = null;
//     }
//   }

//   /// Remove overlay entry (legacy method - kept for compatibility)
//   void _removeOverlay() {
//     try {
//       if (_overlayEntry != null) {
//         // Check if the overlay entry is still attached before removing
//         try {
//           _overlayEntry!.remove();
//           dev.log('Overlay entry removed', name: 'GlobalOverlay');
//         } catch (e) {
//           dev.log('Error removing overlay entry: $e', name: 'GlobalOverlay');
//         }
//       }
//     } catch (e) {
//       dev.log('Error in _removeOverlay: $e', name: 'GlobalOverlay');
//     } finally {
//       // Always null the entry regardless of success/failure
//       _overlayEntry = null;
//     }
//   }

//   /// Remove overlay entry safely
//   Future<void> _removeOverlaySafely() async {
//     // If there's no overlay entry, nothing to do
//     if (_overlayEntry == null) {
//       dev.log('No overlay entry to remove', name: 'GlobalOverlay');
//       return;
//     }

//     try {
//       // Store the overlay entry reference
//       final overlayEntry = _overlayEntry;

//       // Remove the overlay entry if it exists
//       if (overlayEntry != null) {
//         try {
//           dev.log('Attempting to remove overlay entry', name: 'GlobalOverlay');
//           overlayEntry.remove();
//           dev.log('Overlay entry removed successfully', name: 'GlobalOverlay');
//         } catch (e) {
//           // This might happen if the overlay was already removed
//           dev.log('Warning: Overlay entry removal failed (might already be removed): $e', name: 'GlobalOverlay');
//         }
//       }

//       // Only null the reference after successful removal
//       _overlayEntry = null;
//     } catch (e) {
//       dev.log('Error in safe overlay removal: $e', name: 'GlobalOverlay');
//       // Ensure the overlay entry is null even if removal failed
//       _overlayEntry = null;
//     }
//   }

//   /// Set auto-dismiss timer
//   void _setAutoDismissTimer() {
//     _autoDismissTimer?.cancel();
//     _autoDismissTimer = Timer(Duration(seconds: Constants.foregroundNotificationDurationSeconds), () {
//       dismissNotification();
//     });
//   }
// }
