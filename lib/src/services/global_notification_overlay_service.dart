import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/notification_data.dart';
import '../utils/constants.dart';
import '../widgets/global_notification_overlay_widget.dart';

/// Global service for managing notification overlays across the entire app
class GlobalNotificationOverlayService extends GetxService {
  static GlobalNotificationOverlayService get instance => Get.find<GlobalNotificationOverlayService>();

  // Observable for current notification
  final Rxn<NotificationData> _currentNotification = Rxn<NotificationData>();

  // Observable for overlay visibility
  final RxBool _isVisible = false.obs;

  // Service initialization flag
  final RxBool _isInitialized = false.obs;

  // Timer for auto-dismiss
  Timer? _autoDismissTimer;

  // Overlay entry reference
  OverlayEntry? _overlayEntry;

  /// Get current notification
  NotificationData? get currentNotification => _currentNotification.value;

  /// Get current notification as observable
  Rxn<NotificationData> get currentNotificationObs => _currentNotification;

  /// Check if service is ready to show notifications
  bool get isReady => _isInitialized.value && (Get.overlayContext != null || Get.context != null);

  /// Check if overlay is visible
  bool get isVisible => _isVisible.value;

  /// Get visibility as observable
  RxBool get isVisibleObs => _isVisible;

  /// Dismiss notification overlay
  Future<void> dismissNotification() async {
    try {
      if (_isVisible.value) {
        _isVisible.value = false;
        _currentNotification.value = null;

        // Cancel auto-dismiss timer
        _autoDismissTimer?.cancel();
        _autoDismissTimer = null;

        // Remove overlay safely
        await _removeOverlaySafely();

        dev.log('Notification overlay dismissed', name: 'GlobalOverlay');
      }
    } catch (e) {
      dev.log('Error dismissing notification overlay: $e', name: 'GlobalOverlay');
      // Force reset state on error
      _isVisible.value = false;
      _currentNotification.value = null;
      _autoDismissTimer?.cancel();
      _autoDismissTimer = null;
      _overlayEntry = null;
    }
  }

  /// Dismiss notification by ID (if it matches current notification)
  Future<void> dismissNotificationById(String notificationId) async {
    if (_currentNotification.value?.id == notificationId) {
      await dismissNotification();
    }
  }

  /// Force dismiss (without animation - for emergency cases)
  void forceDismiss() {
    try {
      _isVisible.value = false;
      _currentNotification.value = null;
      _autoDismissTimer?.cancel();
      _autoDismissTimer = null;

      // Force remove overlay entry
      if (_overlayEntry != null) {
        try {
          _overlayEntry?.remove();
        } catch (e) {
          dev.log('Error force removing overlay entry: $e', name: 'GlobalOverlay');
        } finally {
          _overlayEntry = null;
        }
      }

      dev.log('Notification overlay force dismissed', name: 'GlobalOverlay');
    } catch (e) {
      dev.log('Error in force dismiss: $e', name: 'GlobalOverlay');
      // Ensure state is reset even if errors occur
      _isVisible.value = false;
      _currentNotification.value = null;
      _autoDismissTimer = null;
      _overlayEntry = null;
    }
  }

  /// Get current notification ID
  String? getCurrentNotificationId() {
    return _currentNotification.value?.id;
  }

  /// Get debug information
  Map<String, dynamic> getDebugInfo() {
    return {
      'isInitialized': _isInitialized.value,
      'isReady': isReady,
      'isVisible': _isVisible.value,
      'hasNotification': _currentNotification.value != null,
      'notificationId': _currentNotification.value?.id,
      'notificationTitle': _currentNotification.value?.title,
      'hasOverlayEntry': _overlayEntry != null,
      'hasAutoDismissTimer': _autoDismissTimer != null,
      'hasOverlayContext': Get.overlayContext != null,
      'hasContext': Get.context != null,
    };
  }

  /// Check if notification overlay is currently active
  bool hasActiveNotification() {
    return _isVisible.value && _currentNotification.value != null;
  }

  @override
  void onClose() {
    // Clean up resources
    _autoDismissTimer?.cancel();
    _removeOverlay();
    _isInitialized.value = false;
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();

    // Mark as initialized after a short delay to ensure GetX context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isInitialized.value = true;
      dev.log('GlobalNotificationOverlayService initialized and ready', name: 'GlobalOverlay');
    });
  }

  /// Show notification overlay
  Future<void> showNotification(NotificationData notification) async {
    try {
      // Check if service is ready
      if (!isReady) {
        dev.log('Service not ready to show notifications, deferring...', name: 'GlobalOverlay');
        // Retry after a short delay if not ready
        Future.delayed(const Duration(milliseconds: 500), () {
          if (isReady) {
            showNotification(notification);
          } else {
            dev.log('Service still not ready after delay, skipping notification', name: 'GlobalOverlay');
          }
        });
        return;
      }

      // Validate notification data
      if (notification.title.isEmpty) {
        dev.log('Cannot show notification: title is empty', name: 'GlobalOverlay');
        return;
      }

      // Check if we have a valid context available
      final context = Get.overlayContext ?? Get.context;
      if (context == null) {
        dev.log('Cannot show notification: no valid context available', name: 'GlobalOverlay');
        return;
      }

      // Dismiss current notification if any
      await dismissNotification();

      // Set new notification
      _currentNotification.value = notification;
      _isVisible.value = true;

      // Create and insert overlay
      _createOverlay();

      // Set auto-dismiss timer
      _setAutoDismissTimer();

      dev.log('Notification overlay shown: ${notification.title}', name: 'GlobalOverlay');
    } catch (e) {
      dev.log('Error showing notification overlay: $e', name: 'GlobalOverlay');
      // Reset state on error
      _isVisible.value = false;
      _currentNotification.value = null;
    }
  }

  /// Update notification auto-dismiss duration
  void updateAutoDismissDuration(Duration duration) {
    if (_isVisible.value) {
      _autoDismissTimer?.cancel();
      _autoDismissTimer = Timer(duration, () {
        dismissNotification();
      });
    }
  }

  /// Create overlay entry
  void _createOverlay() {
    // Clean up any existing overlay first
    if (_overlayEntry != null) {
      _removeOverlay();
    }

    // Ensure we have a valid notification before creating overlay
    final notification = _currentNotification.value;
    if (notification == null) {
      dev.log('Cannot create overlay: notification is null', name: 'GlobalOverlay');
      return;
    }

    try {
      _overlayEntry = OverlayEntry(
        builder: (context) => GlobalNotificationOverlayWidget(
          notification: notification,
          onDismiss: dismissNotification,
          onTap: _handleNotificationTap,
        ),
      );

      // Insert overlay into the app with better error handling
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _insertOverlaySafely();
      });
    } catch (e) {
      dev.log('Error creating overlay entry: $e', name: 'GlobalOverlay');
      _overlayEntry = null;
      _isVisible.value = false;
      _currentNotification.value = null;
    }
  }

  /// Handle notification tap
  void _handleNotificationTap() {
    final notification = _currentNotification.value;
    if (notification != null) {
      // Navigate based on notification data
      if (notification.route != null && notification.route!.isNotEmpty) {
        Get.toNamed(notification.route!, arguments: notification.data);
      } else {
        // Default navigation based on type

        // TODO: handle on room invite
        switch (notification.type) {
          case NotificationType.userMessage:
            Get.toNamed(Constants.homeViewRoute);
            break;
          case NotificationType.systemAlert:
          case NotificationType.promotional:
          case NotificationType.roomInvite:
          case NotificationType.reminder:
            Get.toNamed(Constants.homeViewRoute);
            break;
        }
      }

      // Dismiss notification after navigation
      dismissNotification();

      dev.log('Notification tapped and navigation handled: ${notification.title}', name: 'GlobalOverlay');
    }
  }

  /// Safely insert overlay entry
  void _insertOverlaySafely() {
    try {
      // Try to get overlay context, with fallback options
      final overlayContext = Get.overlayContext ?? Get.context;
      if (overlayContext == null) {
        dev.log('Cannot insert overlay: no valid context available', name: 'GlobalOverlay');
        _removeOverlay();
        _isVisible.value = false;
        _currentNotification.value = null;
        return;
      }

      // Check if we still have a valid overlay entry
      if (_overlayEntry == null) {
        dev.log('Cannot insert overlay: overlay entry is null', name: 'GlobalOverlay');
        return;
      }

      final overlay = Overlay.of(overlayContext);
      overlay.insert(_overlayEntry!);
      dev.log('Overlay entry inserted successfully', name: 'GlobalOverlay');
    } catch (e) {
      dev.log('Error inserting overlay: $e', name: 'GlobalOverlay');
      _removeOverlay();
      // Reset state on error
      _isVisible.value = false;
      _currentNotification.value = null;
    }
  }

  /// Remove overlay entry (legacy method - kept for compatibility)
  void _removeOverlay() {
    try {
      if (_overlayEntry != null) {
        _overlayEntry!.remove();
        dev.log('Overlay entry removed', name: 'GlobalOverlay');
      }
    } catch (e) {
      dev.log('Error removing overlay: $e', name: 'GlobalOverlay');
    } finally {
      // Always null the entry regardless of success/failure
      _overlayEntry = null;
    }
  }

  /// Remove overlay entry safely
  Future<void> _removeOverlaySafely() async {
    if (_overlayEntry == null) {
      return;
    }

    try {
      // Use a post frame callback to ensure we're not in the middle of a build
      await Future(() {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          try {
            if (_overlayEntry != null) {
              _overlayEntry!.remove();
              dev.log('Overlay entry removed safely', name: 'GlobalOverlay');
            }
          } catch (e) {
            dev.log('Error removing overlay entry: $e', name: 'GlobalOverlay');
          } finally {
            _overlayEntry = null;
          }
        });
      });
    } catch (e) {
      dev.log('Error in safe overlay removal: $e', name: 'GlobalOverlay');
      // Force null the entry even if removal failed
      _overlayEntry = null;
    }
  }

  /// Set auto-dismiss timer
  void _setAutoDismissTimer() {
    _autoDismissTimer?.cancel();
    _autoDismissTimer = Timer(Duration(seconds: Constants.foregroundNotificationDurationSeconds), () {
      dismissNotification();
    });
  }
}
