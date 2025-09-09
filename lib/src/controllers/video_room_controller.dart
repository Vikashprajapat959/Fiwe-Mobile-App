import 'package:get/get.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';

import '../models/social_profile.dart';
import '../services/video_room_service.dart';
import '../services/permission_service.dart';
import '../repositories/room_repository.dart';
import '../utils/video_room_exceptions.dart';

class VideoRoomController extends GetxController {
  static VideoRoomController get instance => Get.find<VideoRoomController>();

  final VideoRoomService _roomService = Get.find<VideoRoomService>();
  final PermissionService _permissionService = Get.find<PermissionService>();
  final RoomRepository _roomRepository = Get.find<RoomRepository>();

  // Room state
  final Rxn<VideoRoom> _currentRoom = Rxn<VideoRoom>();
  final RxBool _isLoading = false.obs;
  final RxBool _isInRoom = false.obs;

  // Reaction state
  final RxList<Reaction> _reactions = <Reaction>[].obs;

  // Media state
  final RxBool _isMicOn = true.obs;
  final RxBool _isCameraOn = true.obs;

  // Participants state
  final RxList<HMSRemotePeer> _remotePeers = <HMSRemotePeer>[].obs;

  // Getters
  VideoRoom? get currentRoom => _currentRoom.value;
  bool get isLoading => _isLoading.value;
  bool get isInRoom => _isInRoom.value;
  List<Reaction> get reactions => _reactions.toList();
  bool get isMicOn => _isMicOn.value;
  bool get isCameraOn => _isCameraOn.value;
  List<HMSRemotePeer> get remotePeers => _remotePeers.toList();

  // Observable getters for listening
  RxList<Reaction> get reactionsObservable => _reactions; // Add this getter

  @override
  void onInit() {
    super.onInit();
    // Listen to room service changes
    ever(_roomService.isLoadingObservable, (value) => _isLoading(value));
    ever(_roomService.isInRoomObservable, (value) => _isInRoom(value));
    ever(
      _roomService.currentVideoRoomObservable,
      (value) => _currentRoom(value),
    );
    ever(_roomService.remotePeersObservable, (value) => _remotePeers(value));
    ever(_roomService.reactionsObservable, (value) => _reactions(value));
    ever(_roomService.isMicOnObservable, (value) => _isMicOn(value));
    ever(_roomService.isCameraOnObservable, (value) => _isCameraOn(value));
  }

  /// Create a new video room
  Future<void> createRoom(String title) async {
    try {
      _isLoading(true);
      final success = await _roomRepository.createRoom(title);
      if (success) {
        Get.snackbar(
          'Room Created',
          'Video room created successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to create video room',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      _isLoading(false);
    }
  }

  /// Join an existing video room
  Future<void> joinRoom(String roomId, String userName) async {
    try {
      // Check and request permissions
      await _permissionService.requestVideoRoomPermissions();
    } on MediaPermissionDeniedException catch (e) {
      // Show permission instructions to the user
      _permissionService.showPermissionInstructions(e.deniedPermissions);
      return;
    } catch (e) {
      Get.snackbar(
        'Permissions Required',
        'Please grant camera and microphone permissions to join a video room',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      _isLoading(true);
      final success = await _roomService.joinRoom(roomId, userName);
      if (success) {
        _isInRoom(true);
        Get.snackbar(
          'Room Joined',
          'Successfully joined the video room',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } on RoomFullException catch (e) {
      Get.snackbar(
        'Room Full',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } on TokenExpiredException {
      // Attempt to refresh token and retry
      Get.snackbar(
        'Token Expired',
        'Refreshing authentication token...',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      try {
        final refreshed = await _roomService.attemptRejoin(roomId, userName);
        if (refreshed) {
          _isInRoom(true);
          Get.snackbar(
            'Room Joined',
            'Successfully joined the video room with refreshed token',
            snackPosition: SnackPosition.BOTTOM,
          );
        } else {
          Get.snackbar(
            'Error',
            'Failed to join video room even after token refresh',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } catch (refreshError) {
        Get.snackbar(
          'Error',
          'Failed to refresh token: $refreshError',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to join video room: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading(false);
    }
  }

  /// Leave the current video room
  Future<void> leaveRoom() async {
    try {
      _isLoading(true);
      
      // 1. Call backend API to leave room
      final apiSuccess = await _roomRepository.leaveRoom(_currentRoom.value!.id);
      
      if (!apiSuccess) {
        Get.snackbar(
          'Warning',
          'Room may not have been properly left on server',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      
      // 2. Leave the 100ms room
      final sdkSuccess = await _roomService.leaveRoom();
      
      if (!sdkSuccess) {
        Get.snackbar(
          'Error',
          'Failed to disconnect from video room',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      
      // 3. Clean up local state
      _currentRoom(null);
      _isInRoom(false);
      _reactions.clear();
      _remotePeers.clear();
      
      // 4. Navigate back to lobby
      Get.back();
      
      Get.snackbar(
        'Room Left',
        'Successfully left the video room',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to leave video room: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading(false);
    }
  }

  /// Send reaction to room
  Future<void> sendReaction(String emoji) async {
    if (_currentRoom.value != null) {
      await _roomService.sendReaction(emoji);
    }
  }

  /// Toggle microphone
  void toggleMic() {
    _roomService.toggleMicrophone();
  }

  /// Toggle camera
  void toggleCamera() {
    _roomService.toggleCamera();
  }

  /// Get users with similar interests (placeholder implementation)
  Future<List<SocialProfile>> getUsersWithSimilarInterests() async {
    try {
      // TODO: Implement actual logic to fetch users with similar interests
      // This would involve:
      // 1. Getting current user's interests
      // 2. Finding other users with matching interests
      // 3. Returning list of SocialProfile objects

      // Placeholder implementation
      return <SocialProfile>[];
    } catch (_) {
      Get.snackbar(
        'Error',
        'Failed to fetch users with similar interests',
        snackPosition: SnackPosition.BOTTOM,
      );
      return <SocialProfile>[];
    }
  }
}
