import 'dart:developer' as dev;

import 'package:fiwe/src/models/hmsvideo_room.dart';
import 'package:fiwe/src/models/room_history.dart';
import 'package:fiwe/src/models/standard_api_response.dart';
import 'package:fiwe/src/services/forground_handler.dart';
import 'package:fiwe/src/utils/endpoints.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../services/hms_room_service.dart';
import '../services/http_service.dart';
import '../services/permission_service.dart';
import '../utils/constants.dart';

class RoomRepository extends GetxService {
  static RoomRepository get instance => Get.find<RoomRepository>();

  final HttpService _httpService = Get.find<HttpService>();
  final PermissionService _permissionService = Get.find<PermissionService>();
  final HMSRoomService _videoRoomService = Get.find<HMSRoomService>();

  /// Create a new video room
  /// This method encapsulates the entire room creation and joining workflow
  Future<bool> createRoom(String title, String topicId) async {
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
      final response = await _videoRoomService.createRoom(title, topicId);

      if (response.success && response.data != null) {
        dev.log('Room created successfully with ID: ${response.data!.objectId}', name: 'RoomRepository');

        // 3. Get current user's name from auth service
        // final userName = Get.find<AuthController>().userProfile()?.name ?? 'User';
        await ForegroundHandler().init();
       
        return true;
        // 4. Automatically join the room that was just created
        // final joinResponse = await _videoRoomService.joinRoom(
        //   response.data!.hmsRoomId,
        //   userName,
        //   response.data?.joinToken,
        //   response.data?.objectId,
        //   roomObj: response.data,
        // );

        // if (joinResponse.success) {
        //   // 5. Navigate to the video room view using named route
        //   Get.toNamed(Constants.videoRoomRoute);
        //   return true;
        // } else {
        //   Get.snackbar('Error', joinResponse.message, snackPosition: SnackPosition.BOTTOM);
        //   return false;
        // }
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
  Future<ApiResponse<Map<String, dynamic>>> leaveRoom(String roomId) async {
    try {
      final response = await _httpService.post('/rooms/$roomId/leave', isAuthorized: true);

      if (response.success) {
        return ApiResponse.success(message: response.message, data: response.data);
      } else {
        return ApiResponse.error(message: response.message);
      }
    } catch (e) {
      dev.log('Error leaving room: $e', name: 'RoomRepository');
      return ApiResponse.error(message: e.toString());
    }
  }

  // get user active room details
  Future<ApiResponse<HMSVideoRoom>> getActiveRoomDetails() async {
    try {
      final response = await _httpService.get(Endpoints.currentActiveRoom, isAuthorized: true);
      if (response.success && response.data != null) {
        final room = HMSVideoRoom.fromJson(response.data!);
        return ApiResponse<HMSVideoRoom>(success: true, data: room, message: 'Active room fetched successfully');
      } else {
        return ApiResponse<HMSVideoRoom>(success: false, data: null, message: response.message);
      }
    } catch (e) {
      dev.log('Error fetching active room details: $e', name: 'RoomRepository');
      return ApiResponse<HMSVideoRoom>(
        success: false,
        data: null,
        message: 'An error occurred while fetching active room details: $e',
      );
    }
  }

  Future<ApiResponse<List<HMSVideoRoom>>> getActiveRooms() async {
    try {
      final response = await _httpService.get(Endpoints.activeRooms, isAuthorized: true);
      if (response.success && response.data != null) {
        final rooms = (response.data?['rooms'] as List).map((e) => HMSVideoRoom.fromJson(e)).toList();
        return ApiResponse<List<HMSVideoRoom>>(
          success: true,
          data: rooms,
          message: 'Active rooms fetched successfully',
        );
      } else {
        return ApiResponse<List<HMSVideoRoom>>(success: false, data: null, message: response.message);
      }
    } catch (e) {
      dev.log('Error fetching active rooms: $e', name: 'RoomRepository');
      return ApiResponse<List<HMSVideoRoom>>(
        success: false,
        data: null,
        message: 'An error occurred while fetching active rooms: $e',
      );
    }
  }

  Future<ApiResponse<RoomHistory?>> getRoomHistory() async {
    try {
      final response = await _httpService.get(Endpoints.roomHistory, isAuthorized: true);
      if (response.success && response.data != null) {
        final rooms = RoomHistory.fromJson(response.data!);
        return ApiResponse<RoomHistory>(success: true, data: rooms, message: 'Room history fetched successfully');
      } else {
        return ApiResponse(success: false, data: null, message: response.message);
      }
    } catch (e) {
      dev.log('Error fetching room history: $e', name: 'RoomRepository');
      return ApiResponse.error(data: null, message: 'An error occurred while fetching room history: $e');
    }
  }

  Future<ApiResponse<RoomDetail>> getRoomDetailById(String roomId) async {
    final response = await _httpService.get('${Endpoints.roomHistory}$roomId', isAuthorized: true);
    try {
      if (response.success && response.data != null) {
        return ApiResponse.success(message: response.message, data: RoomDetail.fromJson(response.data!));
      } else {
        return ApiResponse.error(message: response.message);
      }
    } on Exception catch (e) {
      dev.log(e.toString(), name: 'RoomRepo');
      rethrow;
    }
  }

  void joinRoom(String rooId, String roomCode) async {
    final response = await _httpService.post('/rooms/$rooId/join', isAuthorized: true, body: {'room_code': roomCode});
    if (response.success) {
      dev.log('Joined room successfully', name: 'RoomRepository');
    } else {
      dev.log('Failed to join room: ${response.message}', name: 'RoomRepository');
    }
  }
}
