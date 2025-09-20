import 'dart:async';
import 'dart:developer';

import 'package:fiwe_notification/src/models/notification_config.dart';
import 'package:fiwe_notification/src/notification_widget.dart';
import 'package:flutter/material.dart';

/// Represents a stacked notification with its position and entry
class StackedNotification {
  final OverlayEntry entry;
  final NotificationConfig config;
  final int index;
  final double verticalOffset;

  StackedNotification({required this.entry, required this.config, required this.index, required this.verticalOffset});
}

/// Manages the overlay system for displaying notifications globally
class InAppNotificationOverlay {
  // Keep track of notification entries
  static final List<OverlayEntry> _entries = [];

  // Keep track of stacked notifications
  static final List<StackedNotification> _stackedNotifications = [];

  // Timer for auto-dismiss
  static Timer? _dismissTimer;

  /// Show a notification with the provided configuration
  static void show(NotificationConfig config, BuildContext context) {
    // Try to show the notification immediately
    if (!config.enableStacking || config.dismissBeforeShow) {
      _showSingle(config, context);
      return;
    }
    _showStacked(config, context);
  }

  /// Show a single notification (old behavior)
  static void _showSingle(NotificationConfig config, BuildContext context) {
    try {
      // Check if context has overlay
      final overlay = Overlay.of(context);
      // Dismiss last notification if dismissBeforeShow is true
      if (config.dismissBeforeShow && _entries.isNotEmpty) {
        dismiss();
      }

      // We need to create the overlay entry in a way that allows the callback to reference it
      late OverlayEntry overlayEntry;

      overlayEntry = OverlayEntry(
        builder: (context) => NotificationWidget(config: config, onDismiss: () => _removeEntry(overlayEntry)),
      );

      // Add to overlay
      overlay.insert(overlayEntry);
      // Track the entry
      _entries.add(overlayEntry);

      // Set up auto-dismiss if duration is specified
      if (config.duration != null) {
        _dismissTimer?.cancel();
        _dismissTimer = Timer(config.duration!, () {
          if (_entries.contains(overlayEntry)) {
            _removeEntry(overlayEntry);
          }
        });
      }
    } catch (e, stackTrace) {
      // Log error but don't throw to avoid breaking the UI
      log('Error in _showSingle: $e\nStack trace: $stackTrace', name: 'InAppNotificationOverlay');
    }
  }

  /// Show a stacked notification
  static void _showStacked(NotificationConfig config, BuildContext context) {
    try {
      // Check if context has overlay
      final overlay = Overlay.of(context);

      // Calculate vertical offset based on existing notifications
      final notificationIndex = _stackedNotifications.length;
      const notificationHeight = 6.0; // Fixed height of notification
      const verticalSpacing = 1.0; // Spacing between notifications
      final verticalOffset = notificationIndex * (notificationHeight + verticalSpacing);
      final horizontalOffset = notificationIndex == 0
          ? notificationIndex * 1.0
          : notificationIndex + 4.0; // Slight horizontal offset for stacking effect

      // We need to create the overlay entry in a way that allows the callback to reference it
      late OverlayEntry overlayEntry;

      overlayEntry = OverlayEntry(
        builder: (context) => NotificationWidget(
          config: config,
          onDismiss: () => _removeStackedEntry(overlayEntry),
          verticalOffset: verticalOffset,
          horizontalOffset: horizontalOffset,
        ),
      );

      // Add to overlay
      overlay.insert(overlayEntry);

      // Track the stacked notification
      _stackedNotifications.add(
        StackedNotification(
          entry: overlayEntry,
          config: config,
          index: notificationIndex,
          verticalOffset: verticalOffset,
        ),
      );
      // Set up auto-dismiss if duration is specified
      if (config.duration != null) {
        _dismissTimer?.cancel();
        _dismissTimer = Timer(config.duration!, () {
          if (_stackedNotifications.any((notification) => notification.entry == overlayEntry)) {
            _removeStackedEntry(overlayEntry);
          }
        });
      }
    } catch (e, stackTrace) {
      log('Error in _showStacked: $e\nStack trace: $stackTrace', name: 'InAppNotificationOverlay');
    }
  }

  /// Dismiss the currently visible notification
  static void dismiss() {
    if (_stackedNotifications.isNotEmpty) {
      // Dismiss the topmost stacked notification
      final lastNotification = _stackedNotifications.last;
      _removeStackedEntry(lastNotification.entry);
    } else if (_entries.isNotEmpty) {
      // Fallback to old behavior
      final lastEntry = _entries.last;
      _removeEntry(lastEntry);
    }
  }

  /// Dismiss a specific notification by index
  static void dismissAt(int index) {
    if (index >= 0 && index < _stackedNotifications.length) {
      final notification = _stackedNotifications[index];
      _removeStackedEntry(notification.entry);
    }
  }

  /// Dismiss all notifications
  static void dismissAll() {
    _dismissTimer?.cancel();
    _dismissTimer = null;

    // Dismiss stacked notifications
    // Make a copy of the list to avoid concurrent modification
    final stackedNotifications = List<StackedNotification>.from(_stackedNotifications);
    for (final notification in stackedNotifications) {
      notification.entry.remove();
    }
    _stackedNotifications.clear();

    // Dismiss single notifications (old behavior)
    // Make a copy of the list to avoid concurrent modification
    final entries = List<OverlayEntry>.from(_entries);
    for (final entry in entries) {
      entry.remove();
    }
    _entries.clear();
  }

  /// Check if any notifications are visible
  static bool get isVisible => _entries.isNotEmpty || _stackedNotifications.isNotEmpty;

  /// Remove an entry from tracking (old behavior)
  static void _removeEntry(OverlayEntry entry) {
    _dismissTimer?.cancel();
    _dismissTimer = null;

    _entries.remove(entry);
    entry.remove();
  }

  /// Remove a stacked entry from tracking
  static void _removeStackedEntry(OverlayEntry entry) {
    _dismissTimer?.cancel();
    _dismissTimer = null;

    // Find and remove the notification
    final notificationIndex = _stackedNotifications.indexWhere((notification) => notification.entry == entry);
    if (notificationIndex != -1) {
      _stackedNotifications.removeAt(notificationIndex);
      entry.remove();

      // Re-index remaining notifications
      _reindexStackedNotifications();
    }
  }

  /// Re-index stacked notifications after removal
  static void _reindexStackedNotifications() {
    // Update indices and vertical offsets for remaining notifications
    const notificationHeight = 80.0;
    const verticalSpacing = 10.0;

    for (int i = 0; i < _stackedNotifications.length; i++) {
      final notification = _stackedNotifications[i];
      final newOffset = i * (notificationHeight + verticalSpacing);

      // Update the notification with new index and offset
      _stackedNotifications[i] = StackedNotification(
        entry: notification.entry,
        config: notification.config,
        index: i,
        verticalOffset: newOffset,
      );
    }
  }
}
