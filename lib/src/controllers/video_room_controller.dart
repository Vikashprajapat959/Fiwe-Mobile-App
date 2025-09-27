import 'dart:developer';

import 'package:fiwe/src/models/hms_reaction.dart';
import 'package:fiwe/src/models/hmsvideo_room.dart';
import 'package:fiwe/src/services/crashlytics_service.dart';
import 'package:fiwe/src/utils/constants.dart';
import 'package:get/get.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';

import '../repositories/room_repository.dart';
import '../services/hms_room_service.dart';

class VideoRoomController extends GetxController {
  static VideoRoomController get instance => Get.find<VideoRoomController>();

  final HMSRoomService _roomService = Get.find<HMSRoomService>();
  final RoomRepository _roomRepository = Get.find<RoomRepository>();

  // Room state
  final Rxn<HMSVideoRoom> _currentRoom = Rxn<HMSVideoRoom>();
  final RxBool _isLoading = false.obs;
  final RxBool _isInRoom = false.obs;

  // HMSReaction state
  final RxList<HMSReaction> _reactions = <HMSReaction>[].obs;

  // Media state (no longer needed as hms_room_kit handles this)
  // final RxBool _isMicOn = true.obs;
  // final RxBool _isCameraOn = true.obs;

  // Participants state
  final RxList<HMSRemotePeer> _remotePeers = <HMSRemotePeer>[].obs;

  // Getters
  HMSVideoRoom? get currentRoom => _currentRoom.value;

  // setter for currentRoom
  set currentRoom(HMSVideoRoom? room) {
    _currentRoom.value = room;
    update();
  }

  //setter for isInRoom
  set isInRoom(bool value) {
    _isInRoom.value = value;
    update();
  }

  // bool get isCameraOn => _isCameraOn.value; // Removed as hms_room_kit handles this
  bool get isInRoom => _isInRoom.value;
  bool get isLoading => _isLoading.value;
  // bool get isMicOn => _isMicOn.value; // Removed as hms_room_kit handles this
  List<HMSReaction> get reactions => _reactions.toList();
  // Observable getters for listening
  RxList<HMSReaction> get reactionsObservable => _reactions; // Add this getter

  List<HMSRemotePeer> get remotePeers => _remotePeers.toList();

  /// Create a new video room
  Future<void> createRoom(String title, String topicId, String randomTopic) async {
    try {
      _isLoading(true);
      //TODO: add topic id and random topic
      final success = await _roomRepository.createRoom(title, topicId);

      if (success) {
        log("Room Data: $currentRoom", name: "RoomData");
        _isInRoom(true);
        // Success message and navigation will be handled by repository
        // Get.snackbar('Room Created', 'Video room created successfully', snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar('Error', 'Failed to create video room', snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      _isLoading(false);
    }
  }

  /// Get users with similar interests (placeholder implementation)
  // Future<List<SocialProfile>> getUsersWithSimilarInterests() async {
  //   try {
  //     // TODO: Implement actual logic to fetch users with similar interests
  //     // This would involve:
  //     // 1. Getting current user's interests
  //     // 2. Finding other users with matching interests
  //     // 3. Returning list of SocialProfile objects

  //     // Placeholder implementation
  //     return <SocialProfile>[];
  //   } catch (_) {
  //     Get.snackbar('Error', 'Failed to fetch users with similar interests', snackPosition: SnackPosition.BOTTOM);
  //     return <SocialProfile>[];
  //   }
  // }

  /// Join an existing video room
  // Future<void> joinRoom(String roomId, String userName, String? token, String roomObjectId) async {
  //   try {
  //     // Check and request permissions
  //     await _permissionService.requestVideoRoomPermissions();
  //   } on MediaPermissionDeniedException catch (e) {
  //     // Show permission instructions to the user
  //     _permissionService.showPermissionInstructions(e.deniedPermissions);
  //     return;
  //   } catch (e) {
  //     Get.snackbar(
  //       'Permissions Required',
  //       'Please grant camera and microphone permissions to join a video room',
  //       snackPosition: SnackPosition.BOTTOM,
  //     );
  //     return;
  //   }

  //   try {
  //     _isLoading(true);
  //     final response = await _roomService.joinRoom(roomId, userName, token, roomObjectId);
  //     if (response.success) {
  //       _isInRoom(true);
  //       Get.snackbar('Room Joined', response.message, snackPosition: SnackPosition.BOTTOM);
  //     } else {
  //       Get.snackbar('Error', response.message, snackPosition: SnackPosition.BOTTOM);
  //     }
  //   } on RoomFullException catch (e) {
  //     Get.snackbar('Room Full', e.message, snackPosition: SnackPosition.BOTTOM);
  //   } on TokenExpiredException {
  //     // Attempt to refresh token and retry
  //     Get.snackbar('Token Expired', 'Refreshing authentication token...', snackPosition: SnackPosition.BOTTOM);

  //     try {
  //       final refreshedResponse = await _roomService.attemptRejoin(roomId, userName);
  //       if (refreshedResponse.success && refreshedResponse.data != null) {
  //         _isInRoom(true);
  //         Get.snackbar(
  //           'Room Joined',
  //           'Successfully joined the video room with refreshed token',
  //           snackPosition: SnackPosition.BOTTOM,
  //         );
  //       } else {
  //         Get.snackbar('Error', refreshedResponse.message, snackPosition: SnackPosition.BOTTOM);
  //       }
  //     } catch (refreshError) {
  //       Get.snackbar('Error', 'Failed to refresh token: $refreshError', snackPosition: SnackPosition.BOTTOM);
  //     }
  //   } catch (e) {
  //     Get.snackbar('Error', 'Failed to join video room: $e', snackPosition: SnackPosition.BOTTOM);
  //   } finally {
  //     _isLoading(false);
  //   }
  // }

  /// Leave the current video room
  Future<void> leaveRoom() async {
    try {
      Get.offAndToNamed(Constants.homeViewRoute);

      // 1. Call backend API to leave room
      final apiSuccess = await _roomRepository.leaveRoom(_currentRoom.value!.objectId);

      if (!apiSuccess) {
        Get.snackbar('Warning', 'Room may not have been properly left on server', snackPosition: SnackPosition.BOTTOM);
      }

      // 2. Leave the 100ms room
      final response = await _roomService.leaveRoom();

      if (response.success) {
        // 3. Clean up local state
        _currentRoom(null);
        _isInRoom(false);
        _reactions.clear();
        _remotePeers.clear();
      } else {
        CrashlyticsService.log("Error : ${response.message}");
      }
    } catch (e, s) {
      CrashlyticsService.recordError(e, s);
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Listen to room service changes
    ever(_roomService.isLoadingObservable, (value) => _isLoading(value));
    ever(_roomService.isInRoomObservable, (value) => _isInRoom(value));
    ever(_roomService.currentVideoRoomObservable, (value) => _currentRoom(value));
    // ever(_roomService.remotePeersObservable, (value) => _remotePeers(value));
    // ever(_roomService.reactionsObservable, (value) => _reactions(value));
    // Removed media state listeners as hms_room_kit handles this
    // ever(_roomService.isMicOnObservable, (value) => _isMicOn(value));
    // ever(_roomService.isCameraOnObservable, (value) => _isCameraOn(value));
  }

  /// Send reaction to room
  // Future<void> sendReaction(String emoji) async {
  //   if (_currentRoom.value != null) {
  //     await _roomService.sendReaction(emoji);
  //   }
  // }

  // Removed toggleCamera and toggleMic methods as hms_room_kit handles this
  // /// Toggle camera
  // void toggleCamera() {
  //   _roomService.toggleCamera();
  // }

  // /// Toggle microphone
  // void toggleMic() {
  //   _roomService.toggleMicrophone();
  // }
}
