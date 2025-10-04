import 'dart:async';
import 'dart:developer';

import 'package:fiwe/src/models/video_room_models.dart';
import 'package:fiwe/src/services/pip_manager_service.dart';
import 'package:fiwe/src/services/video_room_notification_service.dart';
import 'package:get/get.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';

/// Room state monitor service for tracking video room state changes
/// Coordinates between HMS Room Kit, PIP, and notification services
class RoomStateMonitorService extends GetxService 
    implements HMSUpdateListener, HMSActionResultListener {
  
  static RoomStateMonitorService get instance => Get.find<RoomStateMonitorService>();

  // Dependencies
  final PipManagerService _pipManager = Get.find<PipManagerService>();
  final VideoRoomNotificationService _notificationService = Get.find<VideoRoomNotificationService>();

  // Room state
  final Rxn<VideoRoomState> _currentRoomState = Rxn<VideoRoomState>();
  final RxList<Participant> _participants = <Participant>[].obs;
  final RxBool _isMonitoring = false.obs;

  // Duration tracking
  Timer? _durationTimer;
  
  // Getters
  VideoRoomState? get currentRoomState => _currentRoomState.value;
  List<Participant> get participants => _participants.toList();
  bool get isMonitoring => _isMonitoring.value;

  // Observable getters
  Rxn<VideoRoomState> get currentRoomStateObservable => _currentRoomState;
  RxList<Participant> get participantsObservable => _participants;

  @override
  void onClose() {
    stopMonitoring();
    super.onClose();
  }

  /// Start monitoring room state for a specific room
  Future<void> startMonitoring({
    required String roomId,
    required String roomTitle,
    String? userId,
  }) async {
    try {
      if (_isMonitoring.value) {
        log('Already monitoring room state', name: 'RoomStateMonitorService');
        return;
      }

      // Create initial room state
      final roomState = VideoRoomState(
        roomId: roomId,
        roomTitle: roomTitle,
        joinTime: DateTime.now(),
      );

      _currentRoomState.value = roomState;
      _isMonitoring.value = true;

      // Initialize PIP for this room
      await _pipManager.initializePip(roomId);

      // Start persistent notification
      await _notificationService.startNotification(roomState);

      // Start duration tracking
      _startDurationTracking();

      log('Started monitoring room: $roomTitle ($roomId)', name: 'RoomStateMonitorService');
    } catch (e) {
      log('Error starting room monitoring: $e', name: 'RoomStateMonitorService');
      _isMonitoring.value = false;
    }
  }

  /// Stop monitoring room state
  Future<void> stopMonitoring() async {
    try {
      _durationTimer?.cancel();
      _durationTimer = null;

      await _notificationService.stopNotification();
      _pipManager.cleanupPip();

      _isMonitoring.value = false;
      _currentRoomState.value = null;
      _participants.clear();

      log('Stopped monitoring room state', name: 'RoomStateMonitorService');
    } catch (e) {
      log('Error stopping room monitoring: $e', name: 'RoomStateMonitorService');
    }
  }

  /// Update participant count
  void updateParticipantCount(int count) {
    try {
      final roomState = _currentRoomState.value;
      if (roomState != null) {
        roomState.participantCount.value = count;
        
        // Update notification
        _notificationService.updateNotification(
          participantCount: count,
        );
      }
    } catch (e) {
      log('Error updating participant count: $e', name: 'RoomStateMonitorService');
    }
  }

  /// Update connection status
  void updateConnectionStatus(ConnectionStatus status) {
    try {
      final roomState = _currentRoomState.value;
      if (roomState != null) {
        roomState.connectionStatus.value = status;
        
        // Update notification
        _notificationService.updateNotification(
          connectionStatus: status,
        );
      }
    } catch (e) {
      log('Error updating connection status: $e', name: 'RoomStateMonitorService');
    }
  }

  /// Update media state
  void updateMediaState(MediaState mediaState) {
    try {
      final roomState = _currentRoomState.value;
      if (roomState != null) {
        roomState.mediaState.value = mediaState;
      }
    } catch (e) {
      log('Error updating media state: $e', name: 'RoomStateMonitorService');
    }
  }

  /// Update PIP status
  void updatePipStatus(bool isInPip) {
    try {
      final roomState = _currentRoomState.value;
      if (roomState != null) {
        roomState.isInPip.value = isInPip;
        
        // Update notification
        _notificationService.updateNotification(
          isInPip: isInPip,
        );
      }
    } catch (e) {
      log('Error updating PIP status: $e', name: 'RoomStateMonitorService');
    }
  }

  /// Add participant
  void addParticipant(Participant participant) {
    try {
      _participants.add(participant);
      updateParticipantCount(_participants.length);
      
      log('Participant joined: ${participant.displayName}', name: 'RoomStateMonitorService');
    } catch (e) {
      log('Error adding participant: $e', name: 'RoomStateMonitorService');
    }
  }

  /// Remove participant
  void removeParticipant(String userId) {
    try {
      final participant = _participants.firstWhereOrNull((p) => p.userId == userId);
      if (participant != null) {
        _participants.remove(participant);
        updateParticipantCount(_participants.length);
        
        log('Participant left: ${participant.displayName}', name: 'RoomStateMonitorService');
      }
    } catch (e) {
      log('Error removing participant: $e', name: 'RoomStateMonitorService');
    }
  }

  /// Update participant
  void updateParticipant(Participant updatedParticipant) {
    try {
      final index = _participants.indexWhere((p) => p.userId == updatedParticipant.userId);
      if (index != -1) {
        _participants[index] = updatedParticipant;
      }
    } catch (e) {
      log('Error updating participant: $e', name: 'RoomStateMonitorService');
    }
  }

  /// Start duration tracking timer
  void _startDurationTracking() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Duration is calculated automatically in VideoRoomState.callDuration
      // This timer ensures regular updates to listeners
      _currentRoomState.refresh();
    });
  }

  /// Get current room duration
  Duration? getCurrentDuration() {
    return _currentRoomState.value?.callDuration;
  }

  /// Get formatted current duration
  String? getFormattedDuration() {
    return _currentRoomState.value?.formattedDuration;
  }

  // HMS Update Listener Implementation

  @override
  void onJoin({required HMSRoom room}) {
    try {
      updateConnectionStatus(ConnectionStatus.connected);
      updateParticipantCount(room.peerCount ?? 0);
      
      log('Joined room: ${room.name}', name: 'RoomStateMonitorService');
    } catch (e) {
      log('Error in onJoin: $e', name: 'RoomStateMonitorService');
    }
  }

  @override
  void onRoomUpdate({required HMSRoom room, required HMSRoomUpdate update}) {
    try {
      switch (update) {
        case HMSRoomUpdate.roomPeerCountUpdated:
          updateParticipantCount(room.peerCount ?? 0);
          break;
        default:
          break;
      }
    } catch (e) {
      log('Error in onRoomUpdate: $e', name: 'RoomStateMonitorService');
    }
  }

  @override
  void onPeerUpdate({required HMSPeer peer, required HMSPeerUpdate update}) {
    try {
      final participant = Participant(
        userId: peer.peerId,
        displayName: peer.name,
        isAudioMuted: peer.audioTrack?.isMute ?? true,
        isVideoMuted: peer.videoTrack?.isMute ?? true,
        isLocal: peer.isLocal,
      );

      switch (update) {
        case HMSPeerUpdate.peerJoined:
          addParticipant(participant);
          break;
        case HMSPeerUpdate.peerLeft:
          removeParticipant(peer.peerId);
          break;
        case HMSPeerUpdate.roleUpdated:
        case HMSPeerUpdate.metadataChanged:
        case HMSPeerUpdate.nameChanged:
          updateParticipant(participant);
          break;
        default:
          break;
      }
    } catch (e) {
      log('Error in onPeerUpdate: $e', name: 'RoomStateMonitorService');
    }
  }

  @override
  void onTrackUpdate({required HMSTrack track, required HMSTrackUpdate trackUpdate, required HMSPeer peer}) {
    try {
      // Update participant media state when tracks change
      if (peer.isLocal) {
        final currentMediaState = _currentRoomState.value?.mediaState.value ?? const MediaState();
        
        if (track.kind == HMSTrackKind.kHMSTrackKindAudio) {
          final updatedMediaState = currentMediaState.copyWith(
            isMicrophoneOn: !(track.isMute ?? true),
          );
          updateMediaState(updatedMediaState);
        } else if (track.kind == HMSTrackKind.kHMSTrackKindVideo) {
          final updatedMediaState = currentMediaState.copyWith(
            isCameraOn: !(track.isMute ?? true),
          );
          updateMediaState(updatedMediaState);
        }
      }
    } catch (e) {
      log('Error in onTrackUpdate: $e', name: 'RoomStateMonitorService');
    }
  }

  @override
  void onHMSError({required HMSException error}) {
    try {
      updateConnectionStatus(ConnectionStatus.failed);
      log('HMS Error: ${error.message}', name: 'RoomStateMonitorService');
    } catch (e) {
      log('Error in onHMSError: $e', name: 'RoomStateMonitorService');
    }
  }

  @override
  void onMessage({required HMSMessage message}) {
    // Handle chat messages if needed
  }

  @override
  void onReconnecting() {
    updateConnectionStatus(ConnectionStatus.reconnecting);
  }

  @override
  void onReconnected() {
    updateConnectionStatus(ConnectionStatus.connected);
  }

  @override
  void onRoleChangeRequest({required HMSRoleChangeRequest roleChangeRequest}) {
    // Handle role change requests if needed
  }

  @override
  void onChangeTrackStateRequest({required HMSTrackChangeRequest hmsTrackChangeRequest}) {
    // Handle track change requests if needed
  }

  @override
  void onRemovedFromRoom({required HMSPeerRemovedFromPeer hmsPeerRemovedFromPeer}) {
    // Handle removal from room
    stopMonitoring();
  }

  @override
  void onAudioDeviceChanged({HMSAudioDevice? currentAudioDevice, List<HMSAudioDevice>? availableAudioDevice}) {
    try {
      if (currentAudioDevice != null) {
        final currentMediaState = _currentRoomState.value?.mediaState.value ?? const MediaState();
        final updatedMediaState = currentMediaState.copyWith(
          activeAudioDevice: currentAudioDevice.name,
        );
        updateMediaState(updatedMediaState);
      }
    } catch (e) {
      log('Error in onAudioDeviceChanged: $e', name: 'RoomStateMonitorService');
    }
  }

  @override
  void onSessionStoreAvailable({HMSSessionStore? hmsSessionStore}) {
    // Handle session store availability if needed
  }

  @override
  void onPeerListUpdate({required List<HMSPeer> addedPeers, required List<HMSPeer> removedPeers}) {
    try {
      // Handle bulk peer updates
      for (final peer in addedPeers) {
        final participant = Participant(
          userId: peer.peerId,
          displayName: peer.name,
          isAudioMuted: peer.audioTrack?.isMute ?? true,
          isVideoMuted: peer.videoTrack?.isMute ?? true,
          isLocal: peer.isLocal,
        );
        addParticipant(participant);
      }
      
      for (final peer in removedPeers) {
        removeParticipant(peer.peerId);
      }
    } catch (e) {
      log('Error in onPeerListUpdate: $e', name: 'RoomStateMonitorService');
    }
  }

  @override
  void onUpdateSpeakers({required List<HMSSpeaker> updateSpeakers}) {
    try {
      // Handle speaker updates - update participants who are currently speaking
      for (final speaker in updateSpeakers) {
        final participant = _participants.firstWhereOrNull((p) => p.userId == speaker.peer.peerId);
        if (participant != null) {
          final updatedParticipant = participant.copyWith(isSpeaking: true);
          updateParticipant(updatedParticipant);
        }
      }
    } catch (e) {
      log('Error in onUpdateSpeakers: $e', name: 'RoomStateMonitorService');
    }
  }

  // HMS Action Result Listener Implementation

  @override
  void onSuccess({required HMSActionResultListenerMethod methodType, Map<String, dynamic>? arguments}) {
    // Handle successful actions
  }

  @override
  void onException({required HMSActionResultListenerMethod methodType, Map<String, dynamic>? arguments, required HMSException hmsException}) {
    try {
      updateConnectionStatus(ConnectionStatus.failed);
      log('HMS Action Exception: ${hmsException.message}', name: 'RoomStateMonitorService');
    } catch (e) {
      log('Error in onException: $e', name: 'RoomStateMonitorService');
    }
  }

  /// Get monitoring state info for debugging
  Map<String, dynamic> getMonitoringInfo() {
    return {
      'isMonitoring': _isMonitoring.value,
      'participantCount': _participants.length,
      'hasRoomState': _currentRoomState.value != null,
      'currentDuration': getFormattedDuration(),
      'roomState': _currentRoomState.value?.toJson(),
      'participants': _participants.map((p) => p.toJson()).toList(),
    };
  }
}