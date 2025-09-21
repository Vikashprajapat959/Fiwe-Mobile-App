import 'dart:developer' as dev;

import 'package:fiwe/src/models/standard_api_response.dart';
import 'package:fiwe/src/utils/endpoints.dart';
import 'package:get/get.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';

import '../models/hmsvideo_room.dart';
import 'http_service.dart';

class HMSRoomService extends GetxService implements HMSUpdateListener, HMSActionResultListener {
  static const int _maxReconnectionAttempts = 3;

  static HMSRoomService get instance => Get.find<HMSRoomService>();

  final HttpService _httpService = Get.find<HttpService>();

  // 100ms SDK instance
  late HMSSDK _hmsSDK;
  // Current room
  HMSRoom? _currentRoom;

  // Track if user is in a room
  final RxBool _isInRoom = false.obs;

  // Track reconnection attempts
  int _reconnectionAttempts = 0;
  // Track if room is loading
  final RxBool _isLoading = false.obs;
  // Current room details
  final Rxn<HMSVideoRoom> _currentVideoRoom = Rxn<HMSVideoRoom>();

  // List of remote peers
  // final RxList<HMSRemotePeer> _remotePeers = <HMSRemotePeer>[].obs;
  // List of reactions
  // final RxList<HMSReaction> _reactions = <HMSReaction>[].obs;

  // Media state (no longer needed as hms_room_kit handles this)
  // final RxBool _isMicOn = true.obs;
  // final RxBool _isCameraOn = true.obs;

  HMSRoom? get currentRoom => _currentRoom;
  HMSVideoRoom? get currentVideoRoom => _currentVideoRoom.value;

  Rxn<HMSVideoRoom> get currentVideoRoomObservable => _currentVideoRoom;
  // bool get isCameraOn => _isCameraOn.value; // Removed as hms_room_kit handles this

  // RxBool get isCameraOnObservable => _isCameraOn; // Removed as hms_room_kit handles this
  bool get isInRoom => _isInRoom.value;

  RxBool get isInRoomObservable => _isInRoom;
  bool get isLoading => _isLoading.value;

  // Getters for Rx observables (needed for controller to listen to changes)
  RxBool get isLoadingObservable => _isLoading;
  // bool get isMicOn => _isMicOn.value; // Removed as hms_room_kit handles this
  // RxBool get isMicOnObservable => _isMicOn; // Removed as hms_room_kit handles this
  // List<HMSReaction> get reactions => _reactions.toList();
  // RxList<HMSReaction> get reactionsObservable => _reactions;
  // List<HMSRemotePeer> get remotePeers => _remotePeers.toList();
  // RxList<HMSRemotePeer> get remotePeersObservable => _remotePeers;

  /// Attempt to rejoin room after network disruption
  // Future<ApiResponse<HMSVideoRoom?>> attemptRejoin(String roomId, String userName) async {
  //   try {
  //     dev.log('Attempting to rejoin room: $roomId', name: 'VideoRoomService');

  //     // Get fresh authentication token
  //     final authToken = await handleTokenRefresh(roomId);
  //     if (authToken == null) {
  //       dev.log('Failed to get fresh authentication token for room: $roomId', name: 'VideoRoomService');
  //       return ApiResponse<HMSVideoRoom?>.error(message: 'Failed to get fresh authentication token for room: $roomId');
  //     }

  //     // Join room with proper configuration
  //     final config = HMSConfig(authToken: authToken, userName: userName);
  //     await _hmsSDK.join(config: config);

  //     // Get room details from backend
  //     final response = await _httpService.get('/rooms/$roomId', isAuthorized: true);

  //     // final responseBody = jsonDecode(response.body) as Map<String, dynamic>;

  //     if (response.data != null && response.success) {
  //       final room = HMSVideoRoom.fromJson(response.data?['data']);

  //       _currentVideoRoom(room);
  //       _isInRoom(true);
  //       dev.log('Successfully rejoined video room: $roomId', name: 'VideoRoomService');
  //       return ApiResponse<HMSVideoRoom?>.success(message: response.message, data: room);
  //     } else {
  //       dev.log('Failed to get room details after rejoin: ${response.message}', name: 'VideoRoomService');
  //       return response as ApiResponse<HMSVideoRoom?>;
  //     }
  //   } catch (e) {
  //     dev.log('Error rejoining video room: $e', name: 'VideoRoomService');
  //     return ApiResponse<HMSVideoRoom?>.error(message: 'Error rejoining video room: $e');
  //   }
  // }

  /// Create a new video room through backend API
  Future<ApiResponse<HMSVideoRoom?>> createRoom(String title, String topicId) async {
    try {
      _isLoading(true);
      dev.log('Creating video room with title: $title', name: 'VideoRoomService');

      // Call backend API to create room and get 100ms room details
      final response = await _httpService.post(
        Endpoints.createRoom,
        body: {
          'title': title,
          'capacity': 5,
          'template_id': '68c14e6f74147bd574bb0e4b',
          "topic_id": topicId,
          //TODO: Update description based on user input
          "description": "Room about $title",
        },
        isAuthorized: true,
      );

      if (response.success) {
        final room = HMSVideoRoom.fromJson(response.data!);
        _currentVideoRoom(room);
        dev.log('Video room created successfully: ${room.objectId}', name: 'VideoRoomService');
        return ApiResponse<HMSVideoRoom?>.success(message: response.message, data: room);
      } else {
        dev.log('Failed to create video room: ${response.message}', name: 'VideoRoomService');
        return ApiResponse<HMSVideoRoom?>.error(message: response.message, errors: response.errors);
      }
    } catch (e) {
      dev.log('Error creating video room: $e', name: 'VideoRoomService');
      return ApiResponse<HMSVideoRoom?>.error(message: 'Error creating video room: $e');
    } finally {
      _isLoading(false);
    }
  }

  // // Add getter for local peer
  // Future<HMSLocalPeer?> getLocalPeer() async {
  //   return await _hmsSDK.getLocalPeer();
  // }

  // /// Get authentication token for joining a room
  // Future<ApiResponse<String?>> getRoomAuthToken(String roomId) async {
  //   try {
  //     dev.log('Getting auth token for room: $roomId', name: 'VideoRoomService');

  //     // Call backend API to get room auth token
  //     final response = await _httpService.post('/rooms/$roomId/token', body: {'room_id': roomId}, isAuthorized: true);

  //     final responseBody = response.data as Map<String, dynamic>;

  //     if (response.success) {
  //       final token = responseBody['data']['token'];
  //       return ApiResponse<String?>.success(
  //         message: responseBody['message'] ?? 'Token retrieved successfully',
  //         data: token,
  //       );
  //     } else {
  //       // Check if token is expired (401 Unauthorized)
  //       if (response.statusCode == 401) {
  //         dev.log('Token expired for room: $roomId', name: 'VideoRoomService');
  //         return ApiResponse<String?>.error(
  //           message: responseBody['message'] ?? 'Token expired',
  //           errors: responseBody['errors'],
  //         );
  //       }

  //       dev.log('Failed to get room auth token: ${responseBody['message']}', name: 'VideoRoomService');
  //       return ApiResponse<String?>.error(
  //         message: responseBody['message'] ?? 'Failed to get room auth token',
  //         errors: responseBody['errors'],
  //       );
  //     }
  //   } catch (e) {
  //     dev.log('Error getting room auth token: $e', name: 'VideoRoomService');
  //     return ApiResponse<String?>.error(message: 'Error getting room auth token: $e');
  //   }
  // }

  // /// Handle token refresh for expired tokens
  // Future<String?> handleTokenRefresh(String roomId) async {
  //   try {
  //     dev.log('Refreshing token for room: $roomId', name: 'VideoRoomService');

  //     // Call backend API to get fresh room auth token
  //     final response = await _httpService.post('/rooms/$roomId/token', body: {'room_id': roomId}, isAuthorized: true);

  //     // final responseBody = jsonDecode(response.body) as Map<String, dynamic>;

  //     if (response.success) {
  //       final token = response.data?['token'];
  //       dev.log('Token refreshed successfully for room: $roomId', name: 'VideoRoomService');
  //       return token;
  //     } else {
  //       dev.log('Failed to refresh token: ${response.message}', name: 'VideoRoomService');

  //       throw Exception(response.message ?? 'Failed to refresh token');
  //     }
  //   } catch (e) {
  //     dev.log('Error refreshing token: $e', name: 'VideoRoomService');
  //     rethrow;
  //   }
  // }

  // /// Join an existing video room
  // Future<ApiResponse<bool>> joinRoom(
  //   String roomId,
  //   String userName,
  //   String? token,
  //   String? roomObjectId, {
  //   HMSVideoRoom? roomObj,
  // }) async {
  //   try {
  //     _isLoading(true);
  //     dev.log('Joining video room with ID: $roomId', name: 'VideoRoomService');

  //     // Get authentication token from backend
  //     var authToken = "";
  //     if (token == null) {
  //       final tokenResponse = await getRoomAuthToken(roomId);
  //       if (!tokenResponse.success || tokenResponse.data == null) {
  //         dev.log('Failed to get authentication token for room: $roomId', name: 'VideoRoomService');
  //         return ApiResponse<bool>.error(message: tokenResponse.message, errors: tokenResponse.errors);
  //       }

  //       authToken = tokenResponse.data!;
  //     } else {
  //       authToken = token;
  //     }

  //     // Join room with proper configuration
  //     final config = HMSConfig(
  //       authToken: authToken, // Token from backend
  //       userName: userName, // User's display name
  //     );

  //     // Get room details from backend
  //     // final response = await _httpService.post('/rooms/$roomObjectId/join', isAuthorized: true);
  //     await _hmsSDK.join(config: config);
  //     // final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
  //     var responseBody = {"success": true, "data": {}};
  //     if (responseBody.containsKey("success") && responseBody['success'] == true) {
  //       final roomData = responseBody['data'];
  //       final room = roomObj;

  //       _currentVideoRoom(room);
  //       _isInRoom(true);
  //       dev.log('Successfully joined video room: $roomId', name: 'VideoRoomService');

  //       // Navigate to the video room view
  //       Get.toNamed(Constants.videoRoomRoute);

  //       return ApiResponse<bool>.success(message: 'Successfully joined video room', data: true);
  //     } else {
  //       // Check if room is full
  //       if (responseBody['message']?.toString().toLowerCase().contains('full') == true ||
  //           responseBody['error']?.toString().toLowerCase().contains('full') == true) {
  //         dev.log('Room is full: $roomId', name: 'VideoRoomService');
  //         return ApiResponse<bool>.error(
  //           message: 'The room is currently full. Please try again later or create a new room.',
  //           // errors: responseBody['errors'],
  //         );
  //       }

  //       dev.log('Failed to get room details: ${responseBody['message']}', name: 'VideoRoomService');
  //       return ApiResponse<bool>.error(
  //         message: 'Failed to get room details',
  //         // errors: responseBody['errors'],
  //       );
  //     }
  //   } catch (e) {
  //     dev.log('Error joining video room: $e', name: 'VideoRoomService');
  //     return ApiResponse<bool>.error(message: 'Error joining video room: $e');
  //   } finally {
  //     _isLoading(false);
  //   }
  // }

  // /// Leave the current video room
  Future<ApiResponse<bool>> leaveRoom() async {
    try {
      _isLoading(true);
      dev.log('Leaving current video room', name: 'VideoRoomService');

      // await _hmsSDK.leave();
      // Call backend API to leave room
      // if (_currentVideoRoom.value == null) {
      //   return ApiResponse<bool>.error(message: 'No active room to leave');
      // }
      // final response = await _httpService.post('/rooms/${_currentVideoRoom.value!.objectId}/leave', isAuthorized: true);
      // if (!response.success) {
      //   dev.log('Warning: Room may not have been properly left on server', name: 'VideoRoomService');
      // }

      // _isInRoom(false);
      // _currentRoom = null;
      // _currentVideoRoom.value = null;
      // _remotePeers.clear();
      // _reactions.clear();

      dev.log('Successfully left video room', name: 'VideoRoomService');
      return ApiResponse<bool>.success(message: 'Successfully left video room', data: true);
    } catch (e) {
      dev.log('Error leaving video room: $e', name: 'VideoRoomService');
      return ApiResponse<bool>.error(message: 'Error leaving video room: $e');
    } finally {
      _isLoading(false);
    }
  }

  // Add missing HMSUpdateListener methods
  @override
  void onAudioDeviceChanged({HMSAudioDevice? currentAudioDevice, List<HMSAudioDevice>? availableAudioDevice}) {
    // Fixed parameter name
    dev.log('Audio device changed', name: 'VideoRoomService');
  }

  void onChangeTrack({required HMSTrackChangeRequest trackChangeRequest}) {
    dev.log('Track change request received', name: 'VideoRoomService');
  }

  @override
  void onChangeTrackStateRequest({required HMSTrackChangeRequest hmsTrackChangeRequest}) {
    dev.log('Change track state request received', name: 'VideoRoomService');
  }

  // HMSActionResultListener methods
  @override
  void onException({
    required HMSException hmsException,
    required HMSActionResultListenerMethod methodType,
    Map<String, dynamic>? arguments,
  }) {
    dev.log('HMS Action Exception in $methodType: ${hmsException.description}', name: 'VideoRoomService');
    // Show error to user
    Get.snackbar('Error', 'Failed to send reaction: ${hmsException.description}', snackPosition: SnackPosition.BOTTOM);
  }

  @override
  void onHMSError({required HMSException error}) {
    dev.log('HMS Error: ${error.description}', name: 'VideoRoomService');
    Get.snackbar('Video Room Error', error.description);
  }

  @override
  void onInit() {
    super.onInit();
    _initializeHMSSDK();
  }

  // HMSUpdateListener methods
  @override
  void onJoin({required HMSRoom room}) {
    _currentRoom = room;
    _isInRoom(true);
    dev.log('Successfully joined room: ${room.id}', name: 'VideoRoomService');
  }

  @override
  void onMessage({required HMSMessage message}) {
    // try {
    //   dev.log('Received message: ${message.message}', name: 'VideoRoomService');

    //   // Parse message to check if it's a reaction
    //   final messageData = jsonDecode(message.message);

    //   if (messageData['type'] == 'reaction') {
    //     // Create reaction object
    //     final reaction = HMSReaction(
    //       id: 'reaction_${DateTime.now().millisecondsSinceEpoch}',
    //       userId: messageData['sender']['peerId'],
    //       emoji: messageData['emoji'],
    //       timestamp: DateTime.now(),
    //       roomId: _currentVideoRoom.value?.objectId ?? '',
    //     );

    //     // Add to reactions list to trigger UI update
    //     // _reactions.add(reaction);

    //     dev.log(
    //       'HMSReaction received: ${reaction.emoji} from ${messageData['sender']['name']}',
    //       name: 'VideoRoomService',
    //     );
    //   }
    // } catch (e) {
    //   dev.log('Error processing message: $e', name: 'VideoRoomService');
    // }
  }

  @override
  void onPeerListUpdate({List<HMSPeer>? addedPeers, List<HMSPeer>? removedPeers, List<HMSPeer>? updatedPeers}) {
    dev.log('Peer list updated', name: 'VideoRoomService');
  }

  @override
  void onPeerUpdate({required HMSPeer peer, required HMSPeerUpdate update}) {
    switch (update) {
      case HMSPeerUpdate.peerJoined:
        if (peer is HMSRemotePeer) {
          // _remotePeers.add(peer);
        }
        break;
      case HMSPeerUpdate.peerLeft:
        if (peer is HMSRemotePeer) {
          // _remotePeers.removeWhere((element) => element.peerId == peer.peerId);
        }
        break;
      default:
        break;
    }
    dev.log('Peer update: $update for peer: ${peer.name}', name: 'VideoRoomService');
  }

  @override
  void onReconnected() {
    _reconnectionAttempts = 0; // Reset counter on successful reconnection
    dev.log('Reconnected to room', name: 'VideoRoomService');
    Get.snackbar('Reconnected', 'Successfully reconnected to the video room');
    // Hide reconnection spinner if implemented in UI
  }

  @override
  void onReconnecting() {
    _reconnectionAttempts++;
    dev.log('Reconnecting to room (attempt $_reconnectionAttempts)', name: 'VideoRoomService');

    // Show reconnection spinner in UI
    Get.snackbar('Reconnecting', 'Attempting to reconnect to the video room (attempt $_reconnectionAttempts)');

    // If we've exceeded max attempts, try to rejoin manually
    if (_reconnectionAttempts > _maxReconnectionAttempts && _currentVideoRoom.value != null) {
      dev.log('Max reconnection attempts exceeded, attempting manual rejoin', name: 'VideoRoomService');
      // This would trigger a manual rejoin attempt from the controller
    }
  }

  @override
  void onRemovedFromRoom({required HMSPeerRemovedFromPeer hmsPeerRemovedFromPeer}) {
    dev.log('Removed from room: ${hmsPeerRemovedFromPeer.reason}', name: 'VideoRoomService');
    _isInRoom(false);
    _currentVideoRoom(null);
    // _remotePeers.clear();
    // _reactions.clear();
  }

  @override
  void onRoleChangeRequest({required HMSRoleChangeRequest roleChangeRequest}) {
    dev.log('Role change request received', name: 'VideoRoomService');
  }

  @override
  void onRoomUpdate({required HMSRoom room, required HMSRoomUpdate update}) {
    dev.log('Room update: $update', name: 'VideoRoomService');
  }

  @override
  void onSessionStoreAvailable({HMSSessionStore? hmsSessionStore}) {
    dev.log('Session store available', name: 'VideoRoomService');
  }

  @override
  void onSuccess({required HMSActionResultListenerMethod methodType, Map<String, dynamic>? arguments, dynamic result}) {
    dev.log('HMS Action Success for $methodType', name: 'VideoRoomService');
    // HMSReaction was sent successfully, no additional UI feedback needed
    // as the reaction will be received via onMessage callback
  }

  @override
  void onTrackUpdate({required HMSTrack track, required HMSTrackUpdate trackUpdate, required HMSPeer peer}) {
    dev.log('Track update: $trackUpdate for track: ${track.trackId}', name: 'VideoRoomService');
  }

  @override
  void onUpdateSpeakers({required List<HMSSpeaker> updateSpeakers}) {
    dev.log('Speakers updated', name: 'VideoRoomService');
  }

  /// Send invitations to users with similar interests
  // Future<void> sendInvitations(List<SocialProfile> targetUsers) async {
  //   try {
  //     dev.log('Sending invitations to ${targetUsers.length} users', name: 'VideoRoomService');

  //     if (_currentVideoRoom.value == null) {
  //       dev.log('Cannot send invitations - not in a room', name: 'VideoRoomService');
  //       return;
  //     }

  //     // Send notification to each target user
  //     for (final user in targetUsers) {
  //       // TODO: Implement actual notification sending with deep link
  //       // You can implement notification logic here, or remove this comment if not needed.
  //       dev.log('Sending invitation to user: ${user.email}', name: 'VideoRoomService');
  //     }

  //     dev.log('Invitations sent successfully', name: 'VideoRoomService');
  //   } catch (e) {
  //     dev.log('Error sending invitations: $e', name: 'VideoRoomService');
  //   }
  // }

  /// Send reaction to room using 100ms broadcast message
  // Future<void> sendReaction(String emoji) async {
  //   try {
  //     if (_currentVideoRoom.value == null) {
  //       dev.log('Cannot send reaction - not in a room', name: 'VideoRoomService');
  //       return;
  //     }

  //     // Get local peer information
  //     final localPeer = await _hmsSDK.getLocalPeer();
  //     if (localPeer == null) {
  //       dev.log('Cannot send reaction - local peer not available', name: 'VideoRoomService');
  //       return;
  //     }

  //     // Create reaction message
  //     final reactionMessage = jsonEncode({
  //       'type': 'reaction',
  //       'emoji': emoji,
  //       'sender': {'peerId': localPeer.peerId, 'name': localPeer.name},
  //     });

  //     dev.log('Sending reaction: $emoji to room: ${_currentVideoRoom.value!.objectId}', name: 'VideoRoomService');

  //     // Send broadcast message using 100ms SDK
  //     _hmsSDK.sendBroadcastMessage(message: reactionMessage, type: 'reaction', hmsActionResultListener: this);
  //   } catch (e) {
  //     dev.log('Error sending reaction: $e', name: 'VideoRoomService');
  //   }
  // }

  // Removed toggleCamera and toggleMicrophone methods as hms_room_kit handles this
  // /// Toggle camera
  // Future<void> toggleCamera() async {
  //   try {
  //     dev.log('Toggling camera', name: 'VideoRoomService');
  //     final localPeer = await _hmsSDK.getLocalPeer();
  //     if (localPeer?.videoTrack != null) {
  //       // Revert to the original implementation
  //       final isMuted = localPeer!.videoTrack!.isMute;
  //       _isCameraOn(!isMuted);
  //       // We'll implement the actual toggle later
  //     }
  //   } catch (e) {
  //     dev.log('Error toggling camera: $e', name: 'VideoRoomService');
  //   }
  // }

  // /// Toggle microphone
  // Future<void> toggleMicrophone() async {
  //   try {
  //     dev.log('Toggling microphone', name: 'VideoRoomService');
  //     final localPeer = await _hmsSDK.getLocalPeer();
  //     if (localPeer?.audioTrack != null) {
  //       // Revert to the original implementation
  //       final isMuted = localPeer!.audioTrack!.isMute;
  //       _isMicOn(!isMuted);
  //       // We'll implement the actual toggle later
  //     }
  //   } catch (e) {
  //     dev.log('Error toggling microphone: $e', name: 'VideoRoomService');
  //   }
  // }

  /// Initialize the 100ms SDK
  void _initializeHMSSDK() {
    try {
      _hmsSDK = HMSSDK();
      _hmsSDK.build(); // Important: build the SDK
      _hmsSDK.addUpdateListener(listener: this); // Add listener for updates
      dev.log('100ms SDK initialized in VideoRoomService', name: 'VideoRoomService');
    } catch (e) {
      dev.log('Error initializing 100ms SDK: $e', name: 'VideoRoomService');
    }
  }
}
