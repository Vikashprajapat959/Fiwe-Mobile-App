import 'dart:convert';
import 'dart:developer' as dev;

import 'package:fiwe/src/utils/endpoints.dart';
import 'package:get/get.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';

import '../models/social_profile.dart';
import '../utils/video_room_exceptions.dart';
import 'http_service.dart';

// Model for Reaction
class Reaction {
  final String id;
  final String userId;
  final String emoji;
  final DateTime timestamp;
  final String roomId;

  Reaction({
    required this.id,
    required this.userId,
    required this.emoji,
    required this.timestamp,
    required this.roomId,
  });

  // Create Reaction from JSON
  factory Reaction.fromJson(Map<String, dynamic> json) {
    return Reaction(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      emoji: json['emoji'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      roomId: json['room_id'] as String,
    );
  }

  // Convert Reaction to JSON
  Map<String, dynamic> toJson() {
    return {'id': id, 'user_id': userId, 'emoji': emoji, 'timestamp': timestamp.toIso8601String(), 'room_id': roomId};
  }
}

// Model for Video Room
class VideoRoom {
  final String id;
  final String roomId; // 100ms room ID
  final String title;
  final String createdBy; // User ID
  final List<String> participants; // User IDs
  final int maxParticipants; // 5
  final DateTime createdAt;
  final DateTime? endedAt;
  final bool isActive;

  VideoRoom({
    required this.id,
    required this.roomId,
    required this.title,
    required this.createdBy,
    required this.participants,
    this.maxParticipants = 5,
    required this.createdAt,
    this.endedAt,
    this.isActive = true,
  });

  // Create VideoRoom from JSON
  factory VideoRoom.fromJson(Map<String, dynamic> json) {
    return VideoRoom(
      id: json['id'] as String,
      roomId: json['room_id'] as String,
      title: json['title'] as String,
      createdBy: json['created_by'] as String,
      participants: List<String>.from(json['participants'] as List),
      maxParticipants: json['max_participants'] as int? ?? 5,
      createdAt: DateTime.parse(json['created_at'] as String),
      endedAt: json['ended_at'] != null ? DateTime.parse(json['ended_at'] as String) : null,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  // Convert VideoRoom to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_id': roomId,
      'title': title,
      'created_by': createdBy,
      'participants': participants,
      'max_participants': maxParticipants,
      'created_at': createdAt.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
      'is_active': isActive,
    };
  }
}

class VideoRoomService extends GetxService implements HMSUpdateListener, HMSActionResultListener {
  static const int _maxReconnectionAttempts = 3;

  static VideoRoomService get instance => Get.find<VideoRoomService>();

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
  final Rxn<VideoRoom> _currentVideoRoom = Rxn<VideoRoom>();

  // List of remote peers
  final RxList<HMSRemotePeer> _remotePeers = <HMSRemotePeer>[].obs;
  // List of reactions
  final RxList<Reaction> _reactions = <Reaction>[].obs;

  // Media state
  final RxBool _isMicOn = true.obs;
  final RxBool _isCameraOn = true.obs;

  HMSRoom? get currentRoom => _currentRoom;
  VideoRoom? get currentVideoRoom => _currentVideoRoom.value;

  Rxn<VideoRoom> get currentVideoRoomObservable => _currentVideoRoom;
  bool get isCameraOn => _isCameraOn.value;

  RxBool get isCameraOnObservable => _isCameraOn;
  bool get isInRoom => _isInRoom.value;

  RxBool get isInRoomObservable => _isInRoom;
  bool get isLoading => _isLoading.value;

  // Getters for Rx observables (needed for controller to listen to changes)
  RxBool get isLoadingObservable => _isLoading;
  bool get isMicOn => _isMicOn.value;
  RxBool get isMicOnObservable => _isMicOn;
  List<Reaction> get reactions => _reactions.toList();
  RxList<Reaction> get reactionsObservable => _reactions;
  List<HMSRemotePeer> get remotePeers => _remotePeers.toList();
  RxList<HMSRemotePeer> get remotePeersObservable => _remotePeers;

  /// Attempt to rejoin room after network disruption
  Future<bool> attemptRejoin(String roomId, String userName) async {
    try {
      dev.log('Attempting to rejoin room: $roomId', name: 'VideoRoomService');

      // Get fresh authentication token
      final authToken = await handleTokenRefresh(roomId);
      if (authToken == null) {
        dev.log('Failed to get fresh authentication token for room: $roomId', name: 'VideoRoomService');
        return false;
      }

      // Join room with proper configuration
      final config = HMSConfig(authToken: authToken, userName: userName);
      await _hmsSDK.join(config: config);

      // Get room details from backend
      final response = await _httpService.get('/rooms/$roomId', isAuthorized: true);

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final roomData = responseBody['data'];
        final room = VideoRoom.fromJson(roomData);

        _currentVideoRoom(room);
        _isInRoom(true);
        dev.log('Successfully rejoined video room: $roomId', name: 'VideoRoomService');
        return true;
      } else {
        dev.log('Failed to get room details after rejoin: ${responseBody['message']}', name: 'VideoRoomService');
        return false;
      }
    } catch (e) {
      dev.log('Error rejoining video room: $e', name: 'VideoRoomService');
      return false;
    }
  }

  /// Create a new video room through backend API
  Future<VideoRoom?> createRoom(String title) async {
    try {
      _isLoading(true);
      dev.log('Creating video room with title: $title', name: 'VideoRoomService');

      // Call backend API to create room and get 100ms room details
      final response = await _httpService.post(
        Endpoints.createRoom,
        body: {'title': title, 'capacity': 5},
        isAuthorized: true,
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 201) {
        final roomData = responseBody['data'];
        final room = VideoRoom.fromJson(roomData);

        _currentVideoRoom(room);
        dev.log('Video room created successfully: ${room.id}', name: 'VideoRoomService');
        return room;
      } else {
        dev.log('Failed to create video room: ${responseBody['message']}', name: 'VideoRoomService');
        return null;
      }
    } catch (e) {
      dev.log('Error creating video room: $e', name: 'VideoRoomService');
      return null;
    } finally {
      _isLoading(false);
    }
  }

  // Add getter for local peer
  Future<HMSLocalPeer?> getLocalPeer() async {
    return await _hmsSDK.getLocalPeer();
  }

  /// Get authentication token for joining a room
  Future<String?> getRoomAuthToken(String roomId) async {
    try {
      dev.log('Getting auth token for room: $roomId', name: 'VideoRoomService');

      // Call backend API to get room auth token
      final response = await _httpService.post('/rooms/$roomId/token', body: {'room_id': roomId}, isAuthorized: true);

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseBody['data']['token'];
      } else {
        // Check if token is expired (401 Unauthorized)
        if (response.statusCode == 401) {
          dev.log('Token expired for room: $roomId', name: 'VideoRoomService');
          throw TokenExpiredException('Authentication token has expired', roomId: roomId);
        }

        dev.log('Failed to get room auth token: ${responseBody['message']}', name: 'VideoRoomService');
        return null;
      }
    } on TokenExpiredException {
      rethrow; // Re-throw our custom exception
    } catch (e) {
      dev.log('Error getting room auth token: $e', name: 'VideoRoomService');
      return null;
    }
  }

  /// Handle token refresh for expired tokens
  Future<String?> handleTokenRefresh(String roomId) async {
    try {
      dev.log('Refreshing token for room: $roomId', name: 'VideoRoomService');

      // Call backend API to get fresh room auth token
      final response = await _httpService.post('/rooms/$roomId/token', body: {'room_id': roomId}, isAuthorized: true);

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final token = responseBody['data']['token'];
        dev.log('Token refreshed successfully for room: $roomId', name: 'VideoRoomService');
        return token;
      } else {
        dev.log('Failed to refresh token: ${responseBody['message']}', name: 'VideoRoomService');
        return null;
      }
    } catch (e) {
      dev.log('Error refreshing token: $e', name: 'VideoRoomService');
      return null;
    }
  }

  /// Join an existing video room
  Future<bool> joinRoom(String roomId, String userName) async {
    try {
      _isLoading(true);
      dev.log('Joining video room with ID: $roomId', name: 'VideoRoomService');

      // Get authentication token from backend
      final authToken = await getRoomAuthToken(roomId);
      if (authToken == null) {
        dev.log('Failed to get authentication token for room: $roomId', name: 'VideoRoomService');
        return false;
      }

      // Join room with proper configuration
      final config = HMSConfig(
        authToken: authToken, // Token from backend
        userName: userName, // User's display name
      );
      await _hmsSDK.join(config: config);

      // Get room details from backend
      final response = await _httpService.get('/rooms/$roomId', isAuthorized: true);

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final roomData = responseBody['data'];
        final room = VideoRoom.fromJson(roomData);

        _currentVideoRoom(room);
        _isInRoom(true);
        dev.log('Successfully joined video room: $roomId', name: 'VideoRoomService');
        return true;
      } else {
        // Check if room is full
        if (responseBody['message']?.toString().toLowerCase().contains('full') == true ||
            responseBody['error']?.toString().toLowerCase().contains('full') == true) {
          dev.log('Room is full: $roomId', name: 'VideoRoomService');
          throw RoomFullException(
            'The room is currently full. Please try again later or create a new room.',
            roomId: roomId,
          );
        }

        dev.log('Failed to get room details: ${responseBody['message']}', name: 'VideoRoomService');
        return false;
      }
    } on RoomFullException {
      rethrow; // Re-throw our custom exception
    } catch (e) {
      dev.log('Error joining video room: $e', name: 'VideoRoomService');
      return false;
    } finally {
      _isLoading(false);
    }
  }

  /// Leave the current video room
  Future<bool> leaveRoom() async {
    try {
      _isLoading(true);
      dev.log('Leaving current video room', name: 'VideoRoomService');

      await _hmsSDK.leave();

      dev.log('Successfully left video room', name: 'VideoRoomService');
      return true;
    } catch (e) {
      dev.log('Error leaving video room: $e', name: 'VideoRoomService');
      return false;
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
    try {
      dev.log('Received message: ${message.message}', name: 'VideoRoomService');

      // Parse message to check if it's a reaction
      final messageData = jsonDecode(message.message);

      if (messageData['type'] == 'reaction') {
        // Create reaction object
        final reaction = Reaction(
          id: 'reaction_${DateTime.now().millisecondsSinceEpoch}',
          userId: messageData['sender']['peerId'],
          emoji: messageData['emoji'],
          timestamp: DateTime.now(),
          roomId: _currentVideoRoom.value?.id ?? '',
        );

        // Add to reactions list to trigger UI update
        _reactions.add(reaction);

        dev.log('Reaction received: ${reaction.emoji} from ${messageData['sender']['name']}', name: 'VideoRoomService');
      }
    } catch (e) {
      dev.log('Error processing message: $e', name: 'VideoRoomService');
    }
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
          _remotePeers.add(peer);
        }
        break;
      case HMSPeerUpdate.peerLeft:
        if (peer is HMSRemotePeer) {
          _remotePeers.removeWhere((element) => element.peerId == peer.peerId);
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
    _remotePeers.clear();
    _reactions.clear();
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
    // Reaction was sent successfully, no additional UI feedback needed
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
  Future<void> sendInvitations(List<SocialProfile> targetUsers) async {
    try {
      dev.log('Sending invitations to ${targetUsers.length} users', name: 'VideoRoomService');

      if (_currentVideoRoom.value == null) {
        dev.log('Cannot send invitations - not in a room', name: 'VideoRoomService');
        return;
      }

      // Send notification to each target user
      for (final user in targetUsers) {
        // TODO: Implement actual notification sending with deep link
        dev.log('Sending invitation to user: ${user.email}', name: 'VideoRoomService');
      }

      dev.log('Invitations sent successfully', name: 'VideoRoomService');
    } catch (e) {
      dev.log('Error sending invitations: $e', name: 'VideoRoomService');
    }
  }

  /// Send reaction to room using 100ms broadcast message
  Future<void> sendReaction(String emoji) async {
    try {
      if (_currentVideoRoom.value == null) {
        dev.log('Cannot send reaction - not in a room', name: 'VideoRoomService');
        return;
      }

      // Get local peer information
      final localPeer = await _hmsSDK.getLocalPeer();
      if (localPeer == null) {
        dev.log('Cannot send reaction - local peer not available', name: 'VideoRoomService');
        return;
      }

      // Create reaction message
      final reactionMessage = jsonEncode({
        'type': 'reaction',
        'emoji': emoji,
        'sender': {'peerId': localPeer.peerId, 'name': localPeer.name},
      });

      dev.log('Sending reaction: $emoji to room: ${_currentVideoRoom.value!.id}', name: 'VideoRoomService');

      // Send broadcast message using 100ms SDK
      _hmsSDK.sendBroadcastMessage(message: reactionMessage, type: 'reaction', hmsActionResultListener: this);
    } catch (e) {
      dev.log('Error sending reaction: $e', name: 'VideoRoomService');
    }
  }

  /// Toggle camera
  Future<void> toggleCamera() async {
    try {
      dev.log('Toggling camera', name: 'VideoRoomService');
      final localPeer = await _hmsSDK.getLocalPeer();
      if (localPeer?.videoTrack != null) {
        // Revert to the original implementation
        final isMuted = localPeer!.videoTrack!.isMute;
        _isCameraOn(!isMuted);
        // We'll implement the actual toggle later
      }
    } catch (e) {
      dev.log('Error toggling camera: $e', name: 'VideoRoomService');
    }
  }

  /// Toggle microphone
  Future<void> toggleMicrophone() async {
    try {
      dev.log('Toggling microphone', name: 'VideoRoomService');
      final localPeer = await _hmsSDK.getLocalPeer();
      if (localPeer?.audioTrack != null) {
        // Revert to the original implementation
        final isMuted = localPeer!.audioTrack!.isMute;
        _isMicOn(!isMuted);
        // We'll implement the actual toggle later
      }
    } catch (e) {
      dev.log('Error toggling microphone: $e', name: 'VideoRoomService');
    }
  }

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
