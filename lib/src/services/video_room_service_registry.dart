import 'package:fiwe/src/services/pip_manager_service.dart';
import 'package:fiwe/src/services/room_state_monitor_service.dart';
import 'package:fiwe/src/services/video_room_notification_service.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service registration for video room PIP and notification services
class VideoRoomServiceRegistry {
  
  /// Register all video room related services
  static Future<void> registerServices() async {
    // Register core services
    Get.lazyPut<PipManagerService>(() => PipManagerService(), fenix: true);
    Get.lazyPut<VideoRoomNotificationService>(() => VideoRoomNotificationService(), fenix: true);
    Get.lazyPut<RoomStateMonitorService>(() => RoomStateMonitorService(), fenix: true);
    
    print('Video room services registered successfully');
  }
  
  /// Initialize all services
  static Future<void> initializeServices() async {
    try {
      // Initialize persistence for crash recovery
      await _initializeCrashRecovery();
      
      // Initialize services
      Get.find<PipManagerService>();
      Get.find<VideoRoomNotificationService>();
      Get.find<RoomStateMonitorService>();
      
      print('Video room services initialized successfully');
    } catch (e) {
      print('Error initializing video room services: $e');
    }
  }
  
  /// Initialize crash recovery system
  static Future<void> _initializeCrashRecovery() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasActiveRoom = prefs.getBool('has_active_notification') ?? false;
      
      if (hasActiveRoom) {
        print('Detected previous app crash with active room - recovery mode enabled');
        // Recovery logic will be handled by notification service on startup
      }
    } catch (e) {
      print('Error initializing crash recovery: $e');
    }
  }
  
  /// Cleanup all services
  static Future<void> cleanupServices() async {
    try {
      if (Get.isRegistered<RoomStateMonitorService>()) {
        await Get.find<RoomStateMonitorService>().stopMonitoring();
      }
      
      if (Get.isRegistered<VideoRoomNotificationService>()) {
        await Get.find<VideoRoomNotificationService>().stopNotification();
      }
      
      if (Get.isRegistered<PipManagerService>()) {
        Get.find<PipManagerService>().cleanupPip();
      }
      
      print('Video room services cleaned up successfully');
    } catch (e) {
      print('Error cleaning up video room services: $e');
    }
  }
  
  /// Check if all services are registered
  static bool areServicesRegistered() {
    return Get.isRegistered<PipManagerService>() &&
           Get.isRegistered<VideoRoomNotificationService>() &&
           Get.isRegistered<RoomStateMonitorService>();
  }
  
  /// Get service status for debugging
  static Map<String, bool> getServiceStatus() {
    return {
      'PipManagerService': Get.isRegistered<PipManagerService>(),
      'VideoRoomNotificationService': Get.isRegistered<VideoRoomNotificationService>(),
      'RoomStateMonitorService': Get.isRegistered<RoomStateMonitorService>(),
    };
  }
}