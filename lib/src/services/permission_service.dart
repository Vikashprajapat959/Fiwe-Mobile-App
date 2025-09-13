import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';

import '../utils/video_room_exceptions.dart';

class PermissionService extends GetxService {
  static PermissionService get instance => Get.find<PermissionService>();

  /// Request all permissions required for video rooms
  Future<bool> requestVideoRoomPermissions() async {
    try {
      dev.log('Requesting video room permissions', name: 'PermissionService');
      
      // Request camera permission
      final cameraStatus = await Permission.camera.request();
      dev.log('Camera permission status: $cameraStatus', name: 'PermissionService');
      
      // Request microphone permission
      final micStatus = await Permission.microphone.request();
      dev.log('Microphone permission status: $micStatus', name: 'PermissionService');
      
      // Check if notification permissions are granted
      final notificationPermission = await _requestNotificationPermissions();
      dev.log('Notification permission status: $notificationPermission', name: 'PermissionService');
      
      final allGranted = cameraStatus.isGranted && 
                        micStatus.isGranted && 
                        notificationPermission;
      
      // If permissions are denied, throw a specific exception
      if (!allGranted) {
        final deniedPermissions = <String>[];
        if (!cameraStatus.isGranted) deniedPermissions.add('camera');
        if (!micStatus.isGranted) deniedPermissions.add('microphone');
        
        if (deniedPermissions.isNotEmpty) {
          throw MediaPermissionDeniedException(
            'Required permissions were denied. Please enable ${deniedPermissions.join(' and ')} permissions in your device settings.',
            deniedPermissions,
          );
        }
      }
      
      dev.log('All video room permissions granted: $allGranted', name: 'PermissionService');
      return allGranted;
    } on MediaPermissionDeniedException {
      rethrow; // Re-throw our custom exception
    } catch (e) {
      dev.log('Error requesting video room permissions: $e', name: 'PermissionService');
      return false;
    }
  }

  /// Check if all video room permissions are granted
  Future<bool> checkVideoRoomPermissions() async {
    try {
      final cameraStatus = await Permission.camera.status;
      final micStatus = await Permission.microphone.status;
      final notificationStatus = await _checkNotificationPermissions();
      
      return cameraStatus.isGranted && 
             micStatus.isGranted && 
             notificationStatus;
    } catch (e) {
      dev.log('Error checking video room permissions: $e', name: 'PermissionService');
      return false;
    }
  }

  /// Request notification permissions
  Future<bool> _requestNotificationPermissions() async {
    try {
      // For iOS, we need to request notification permission specifically
      if (GetPlatform.isIOS) {
        // Note: This is a simplified approach. In a real app, you might need to
        // implement a more detailed notification permission request
        return true;
      }
      
      // For Android, notification permissions are generally granted by default
      return true;
    } catch (e) {
      dev.log('Error requesting notification permissions: $e', name: 'PermissionService');
      return false;
    }
  }

  /// Check notification permissions
  Future<bool> _checkNotificationPermissions() async {
    try {
      // For iOS, check notification permission status
      if (GetPlatform.isIOS) {
        final status = await Permission.notification.status;
        return status.isGranted;
      }
      
      // For Android, notification permissions are generally granted by default
      return true;
    } catch (e) {
      dev.log('Error checking notification permissions: $e', name: 'PermissionService');
      return false;
    }
  }

  /// Show permission instructions to the user
  void showPermissionInstructions(List<String> deniedPermissions) {
    final permissionList = deniedPermissions.join(' and ');
    Get.defaultDialog(
      title: 'Permissions Required',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'To use the video room feature, you need to enable $permissionList permissions.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Please go to your device settings and enable these permissions for this app.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
      textConfirm: 'Open Settings',
      onConfirm: () {
        _openAppSettings();
        Get.back();
      },
      textCancel: 'Cancel',
    );
  }

  /// Open app settings to allow user to grant permissions
  Future<void> _openAppSettings() async {
    await openAppSettings();
  }
}