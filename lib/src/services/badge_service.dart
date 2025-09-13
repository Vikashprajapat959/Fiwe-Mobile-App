import 'dart:developer' as dev;
import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing app icon badge counts
/// 
/// This service ONLY persists the badge count (integer) in SharedPreferences.
/// It does NOT store any notification data or content.
/// Notification data is handled in-memory only by NotificationController.
/// 
/// Follows SharedPreferences Architecture: Only authentication tokens and 
/// essential counters (like badge count) are persisted locally.
class BadgeService extends GetxService {
  static BadgeService get instance => Get.find<BadgeService>();

  // Badge count observable
  final RxInt _badgeCount = 0.obs;
  
  // SharedPreferences key for badge count persistence
  static const String _badgeCountKey = 'notification_badge_count';

  /// Get current badge count
  int get badgeCount => _badgeCount.value;

  /// Get badge count as observable
  RxInt get badgeCountObs => _badgeCount;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeBadgeService();
  }

  /// Initialize the badge service
  Future<void> _initializeBadgeService() async {
    try {
      // Check if badges are supported on this platform
      bool isSupported = await AppBadgePlus.isSupported();
      if (!isSupported) {
        dev.log('App badges not supported on this platform', name: 'BadgeService');
        return;
      }

      // Load persisted badge count
      await _loadBadgeCount();
      
      // Apply the loaded badge count
      await _applyBadgeCount();
      
      dev.log('Badge service initialized successfully. Current count: ${_badgeCount.value}', 
              name: 'BadgeService');
    } catch (e) {
      dev.log('Error initializing badge service: $e', name: 'BadgeService');
    }
  }

  /// Load badge count from SharedPreferences
  Future<void> _loadBadgeCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final count = prefs.getInt(_badgeCountKey) ?? 0;
      _badgeCount.value = count;
      dev.log('Loaded badge count from storage: $count', name: 'BadgeService');
    } catch (e) {
      dev.log('Error loading badge count: $e', name: 'BadgeService');
      _badgeCount.value = 0;
    }
  }

  /// Save badge count to SharedPreferences
  Future<void> _saveBadgeCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_badgeCountKey, _badgeCount.value);
      dev.log('Saved badge count to storage: ${_badgeCount.value}', name: 'BadgeService');
    } catch (e) {
      dev.log('Error saving badge count: $e', name: 'BadgeService');
    }
  }

  /// Apply badge count to app icon
  Future<void> _applyBadgeCount() async {
    try {
      if (_badgeCount.value <= 0) {
        await AppBadgePlus.updateBadge(0);
        dev.log('Badge removed from app icon', name: 'BadgeService');
      } else {
        await AppBadgePlus.updateBadge(_badgeCount.value);
        dev.log('Badge updated to: ${_badgeCount.value}', name: 'BadgeService');
      }
    } catch (e) {
      dev.log('Error applying badge count: $e', name: 'BadgeService');
    }
  }

  /// Update badge count
  Future<void> updateBadge(int count) async {
    try {
      if (count < 0) {
        dev.log('Badge count cannot be negative, setting to 0', name: 'BadgeService');
        count = 0;
      }

      _badgeCount.value = count;
      await _saveBadgeCount();
      await _applyBadgeCount();
      
      dev.log('Badge count updated to: $count', name: 'BadgeService');
    } catch (e) {
      dev.log('Error updating badge: $e', name: 'BadgeService');
    }
  }

  /// Increment badge count
  Future<void> incrementBadge() async {
    await updateBadge(_badgeCount.value + 1);
  }

  /// Decrement badge count
  Future<void> decrementBadge() async {
    final newCount = _badgeCount.value - 1;
    await updateBadge(newCount > 0 ? newCount : 0);
  }

  /// Clear badge (set count to 0)
  Future<void> clearBadge() async {
    await updateBadge(0);
  }

  /// Add multiple to badge count
  Future<void> addToBadge(int count) async {
    if (count > 0) {
      await updateBadge(_badgeCount.value + count);
    }
  }

  /// Subtract from badge count
  Future<void> subtractFromBadge(int count) async {
    if (count > 0) {
      final newCount = _badgeCount.value - count;
      await updateBadge(newCount > 0 ? newCount : 0);
    }
  }

  /// Check if badges are supported on current platform
  Future<bool> isSupported() async {
    try {
      return await AppBadgePlus.isSupported();
    } catch (e) {
      dev.log('Error checking badge support: $e', name: 'BadgeService');
      return false;
    }
  }

  /// Reset badge service (clear count and storage)
  Future<void> reset() async {
    try {
      _badgeCount.value = 0;
      await _saveBadgeCount();
      await AppBadgePlus.updateBadge(0);
      dev.log('Badge service reset successfully', name: 'BadgeService');
    } catch (e) {
      dev.log('Error resetting badge service: $e', name: 'BadgeService');
    }
  }

  /// Get badge status info for debugging
  Map<String, dynamic> getDebugInfo() {
    return {
      'badgeCount': _badgeCount.value,
      'isServiceInitialized': true,
      'storageKey': _badgeCountKey,
    };
  }

  @override
  void onClose() {
    // Clean up if needed
    super.onClose();
  }
}