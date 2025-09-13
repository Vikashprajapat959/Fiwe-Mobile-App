import 'dart:developer' as dev;

import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../services/http_service.dart';
import '../services/permission_service.dart';
import '../services/video_room_service.dart';
import '../utils/constants.dart';

class RoomRepository extends GetxService {
  static RoomRepository get instance => Get.find<RoomRepository>();

  final HttpService _httpService = Get.find<HttpService>();
  final PermissionService _permissionService = Get.find<PermissionService>();
  final VideoRoomService _videoRoomService = Get.find<VideoRoomService>();

  /// Create a new video room
  /// This method encapsulates the entire room creation and joining workflow
  Future<bool> createRoom(String title) async {
    try {
      dev.log('Starting room creation process with title: $title', name: 'RoomRepository');

      // 1. Request required permissions (camera and microphone)
      final permissionsGranted = await _permissionService.requestVideoRoomPermissions();
      if (!permissionsGranted) {
        dev.log('Permissions not granted for video room creation', name: 'RoomRepository');
        Get.snackbar(
          'Permissions Required',
          'Please grant camera and microphone permissions to create a video room',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      dev.log('Permissions granted, proceeding with room creation', name: 'RoomRepository');

      // 2. Call backend API endpoint to create room
      // Using the existing VideoRoomService method for consistency
      final response = await _videoRoomService.createRoom(title);

      if (response.success && response.data != null) {
        dev.log('Room created successfully with ID: ${response.data!.id}', name: 'RoomRepository');

        // 3. Get current user's name from auth service
        final userName = Get.find<AuthController>().userProfile?.displayName ?? 'User';
        
        // 4. Automatically join the room that was just created
        final joinResponse = await _videoRoomService.joinRoom(response.data!.id, userName);
        
        if (joinResponse.success) {
          // 5. Navigate to the video room view using named route
          Get.toNamed(Constants.videoRoomRoute);
          return true;
        } else {
          Get.snackbar('Error', joinResponse.message, snackPosition: SnackPosition.BOTTOM);
          return false;
        }
      } else {
        dev.log('Failed to create room: ${response.message}', name: 'RoomRepository');
        Get.snackbar('Error', response.message, snackPosition: SnackPosition.BOTTOM);
        return false;
      }
    } catch (e) {
      dev.log('Error during room creation process: $e', name: 'RoomRepository');
      Get.snackbar('Error', 'An error occurred while creating the room: $e', snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }

  /// Leave a video room
  Future<bool> leaveRoom(String roomId) async {
    try {
      final response = await _httpService.post('/rooms/$roomId/leave', isAuthorized: true);
      final responseBody = response.body.toJson();

      if (responseBody.containsKey("success") && responseBody['success'] == true) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      dev.log('Error leaving room: $e', name: 'RoomRepository');
      return false;
    }
  }
}