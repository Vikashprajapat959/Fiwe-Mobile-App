import 'dart:developer';

import 'package:fiwe/src/models/hms_reaction.dart';
import 'package:fiwe/src/models/hmsvideo_room.dart';
import 'package:fiwe/src/services/crashlytics_service.dart';
import 'package:fiwe/src/services/pip_manager_service.dart';
import 'package:fiwe/src/services/room_state_monitor_service.dart';
import 'package:fiwe/src/services/video_room_notification_service.dart';
import 'package:fiwe/src/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../repositories/room_repository.dart';
import '../services/hms_room_service.dart';

class VideoRoomController extends GetxController with WidgetsBindingObserver {
  static VideoRoomController get instance => Get.find<VideoRoomController>();

  final HMSRoomService _roomService = Get.find<HMSRoomService>();
  final RoomRepository _roomRepository = Get.find<RoomRepository>();

  // New services for PIP and notifications
  final PipManagerService _pipManager = Get.find<PipManagerService>();
  final VideoRoomNotificationService _notificationService = Get.find<VideoRoomNotificationService>();
  final RoomStateMonitorService _roomStateMonitor = Get.find<RoomStateMonitorService>();

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

  // PIP and notification state
  final RxBool _isPipActive = false.obs;
  final RxBool _hasActiveNotification = false.obs;

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

  // PIP and notification getters
  bool get isPipActive => _isPipActive.value;
  bool get hasActiveNotification => _hasActiveNotification.value;

  // Service getters
  PipManagerService get pipManager => _pipManager;
  VideoRoomNotificationService get notificationService => _notificationService;
  RoomStateMonitorService get roomStateMonitor => _roomStateMonitor;

  /// Create a new video room
  Future<void> createRoom(String title, String topicId, String randomTopic) async {
    try {
      _isLoading(true);
      //TODO: add topic id and random topic
      final success = await _roomRepository.createRoom(title, topicId);

      if (success) {
        log("Room Data: $currentRoom", name: "RoomData");
        _isInRoom(true);

        // Track room creation event
        _trackRoomEvent('created', additionalData: {'title': title, 'topicId': topicId});

        // Start monitoring room state with new services
        if (_currentRoom.value != null) {
          await _startRoomServices(_currentRoom.value!);
        }

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
      // Track room leave event before cleanup

      // 1. Call backend API to leave room
      final apiSuccess = await _roomRepository.leaveRoom(_currentRoom.value!.objectId);

      if (!apiSuccess) {
        Get.snackbar('Warning', 'Room may not have been properly left on server', snackPosition: SnackPosition.BOTTOM);
        return;
      }

      // 2. Leave the 100ms room
      _roomService.leaveRoom().then((response) {
        if (response.success) {
          // 3. Clean up local state
          _currentRoom(null);
          _isInRoom(false);
          _reactions.clear();
          _remotePeers.clear();
          _isPipActive(false);
          _hasActiveNotification(false);
        } else {
          CrashlyticsService.log("Error : ${response.message}");
        }
      });
    } catch (e, s) {
      CrashlyticsService.recordError(e, s);
    } finally {
      // 4. Stop room state monitoring
      _trackRoomEvent('left');

      // Get participants before stopping services
      final participants = _roomStateMonitor.participants;
      final roomId = _currentRoom.value?.objectId ?? '';
      final roomTitle = _currentRoom.value?.title ?? '';

      // Stop room services first
      await _stopRoomServices();

      // Navigate to rating screen if there are participants to rate
      if (participants.isNotEmpty && roomId.isNotEmpty) {
        Get.offAndToNamed(
          Constants.userRatingRoute,
          arguments: {'participants': participants, 'roomParticipationId': roomId, 'roomTitle': roomTitle},
        );
      } else {
        // Go directly to home if no participants to rate
        Get.offAndToNamed(Constants.homeViewRoute);
      }
    }
  }

  /// Start room services (PIP, notifications, monitoring)
  Future<void> _startRoomServices(HMSVideoRoom room) async {
    try {
      log('Starting room services for: ${room.title}', name: 'VideoRoomController');

      // Start room state monitoring first
      await _roomStateMonitor.startMonitoring(roomId: room.objectId, roomTitle: room.title);

      // Start persistent notification immediately
      final roomState = _roomStateMonitor.currentRoomState;
      if (roomState != null) {
        final notificationStarted = await _notificationService.startNotification(roomState);
        if (notificationStarted) {
          _hasActiveNotification(true);
          log('Persistent notification started successfully', name: 'VideoRoomController');
        } else {
          log('Failed to start persistent notification', name: 'VideoRoomController');
          Get.snackbar('Warning', 'Persistent notification could not be started', snackPosition: SnackPosition.BOTTOM);
        }
      }

      // Save room state for crash recovery
      await _saveRoomStateForRecovery(room);

      log('Room services started successfully for: ${room.title}', name: 'VideoRoomController');
    } catch (e, stackTrace) {
      log('Error starting room services: $e', name: 'VideoRoomController');
      CrashlyticsService.recordError(e, stackTrace);
      // Show user-friendly error but continue with basic functionality
      Get.snackbar('Warning', 'Some features may be limited', snackPosition: SnackPosition.BOTTOM);
    }
  }

  /// Save room state for crash recovery
  Future<void> _saveRoomStateForRecovery(HMSVideoRoom room) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('crash_recovery_room_id', room.objectId);
      await prefs.setString('crash_recovery_room_title', room.title);
      await prefs.setString('crash_recovery_join_time', DateTime.now().toIso8601String());
      await prefs.setBool('has_active_notification', true);
    } catch (e) {
      log('Error saving room state for recovery: $e', name: 'VideoRoomController');
    }
  }

  /// Stop room services
  Future<void> _stopRoomServices() async {
    try {
      await _roomStateMonitor.stopMonitoring();
      _hasActiveNotification(false);
      _isPipActive(false);

      // Clear crash recovery state
      await _clearCrashRecoveryState();

      log('Room services stopped', name: 'VideoRoomController');
    } catch (e) {
      log('Error stopping room services: $e', name: 'VideoRoomController');
    }
  }

  /// Clear crash recovery state
  Future<void> _clearCrashRecoveryState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('crash_recovery_room_id');
      await prefs.remove('crash_recovery_room_title');
      await prefs.remove('crash_recovery_join_time');
      await prefs.setBool('has_active_notification', false);
    } catch (e) {
      log('Error clearing crash recovery state: $e', name: 'VideoRoomController');
    }
  }

  @override
  void onInit() {
    super.onInit();

    // Add lifecycle observer for PIP handling
    WidgetsBinding.instance.addObserver(this);

    // Listen to room service changes
    ever(_roomService.isLoadingObservable, (value) => _isLoading(value));
    ever(_roomService.isInRoomObservable, (value) => _isInRoom(value));
    ever(_roomService.currentVideoRoomObservable, (value) => _currentRoom(value));

    // Listen to PIP service changes
    ever(_pipManager.isPipActiveObservable, (value) => _isPipActive(value));

    // Listen to notification service changes
    ever(_notificationService.isServiceRunningObservable, (value) => _hasActiveNotification(value));

    // Removed media state listeners as hms_room_kit handles this
    // ever(_roomService.isMicOnObservable, (value) => _isMicOn(value));
    // ever(_roomService.isCameraOnObservable, (value) => _isCameraOn(value));
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopRoomServices();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Handle app lifecycle changes for PIP
    _pipManager.handleAppLifecycleChange(state);

    // Handle specific lifecycle states
    switch (state) {
      case AppLifecycleState.paused:
        // App is minimized, might enter PIP mode
        log('App paused - potential PIP entry', name: 'VideoRoomController');
        if (_isInRoom.value) {
          log('User is in active room - PIP should activate', name: 'VideoRoomController');
        }
        break;
      case AppLifecycleState.resumed:
        // App is restored from background
        log('App resumed from background', name: 'VideoRoomController');
        if (_isPipActive.value) {
          log('Exiting PIP mode on app resume', name: 'VideoRoomController');
          exitPipMode();
        }
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  /// Handle PIP mode entry (can be called manually)
  Future<void> enterPipMode() async {
    try {
      if (!_isInRoom.value) {
        Get.snackbar('Error', 'Not currently in a video room', snackPosition: SnackPosition.BOTTOM);
        return;
      }

      bool success = await _pipManager.enterPipMode();
      if (success) {
        _isPipActive(true);
        _roomStateMonitor.updatePipStatus(true);
        log('Successfully entered PIP mode', name: 'VideoRoomController');
      } else {
        Get.snackbar('Error', 'Failed to enter PIP mode', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      log('Error entering PIP mode: $e', name: 'VideoRoomController');
      Get.snackbar('Error', 'Failed to enter PIP mode', snackPosition: SnackPosition.BOTTOM);
    }
  }

  /// Exit PIP mode
  Future<void> exitPipMode() async {
    try {
      await _pipManager.exitPipMode();
      _isPipActive(false);
      _roomStateMonitor.updatePipStatus(false);
      log('Exited PIP mode', name: 'VideoRoomController');
    } catch (e) {
      log('Error exiting PIP mode: $e', name: 'VideoRoomController');
    }
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

  /// Get current room duration
  String? getCurrentRoomDuration() {
    return _roomStateMonitor.getFormattedDuration();
  }

  /// Get participant count
  int getParticipantCount() {
    return _roomStateMonitor.participants.length;
  }

  /// Check if notification is active
  bool get isNotificationActive => _notificationService.isServiceRunning;

  /// Get debug information
  Map<String, dynamic> getDebugInfo() {
    return {
      'isInRoom': _isInRoom.value,
      'isLoading': _isLoading.value,
      'isPipActive': _isPipActive.value,
      'hasActiveNotification': _hasActiveNotification.value,
      'currentRoom': _currentRoom.value?.toJson(),
      'participantCount': getParticipantCount(),
      'roomDuration': getCurrentRoomDuration(),
      'pipManagerInfo': _pipManager.getPipStateInfo(),
      'notificationInfo': _notificationService.getNotificationInfo(),
      'monitoringInfo': _roomStateMonitor.getMonitoringInfo(),
    };
  }

  /// Log analytics event for monitoring
  void _logAnalyticsEvent(String eventName, Map<String, dynamic> parameters) {
    try {
      // Log to Firebase Analytics or your analytics service
      log('Analytics: $eventName - $parameters', name: 'VideoRoomController');

      // Example: FirebaseAnalytics.instance.logEvent(name: eventName, parameters: parameters);
    } catch (e) {
      log('Error logging analytics event: $e', name: 'VideoRoomController');
    }
  }

  /// Track room events for analytics
  void _trackRoomEvent(String event, {Map<String, dynamic>? additionalData}) {
    final data = {
      'roomId': _currentRoom.value?.objectId,
      'roomTitle': _currentRoom.value?.title,
      'participantCount': getParticipantCount(),
      'duration': getCurrentRoomDuration(),
      'timestamp': DateTime.now().toIso8601String(),
      ...?additionalData,
    };

    _logAnalyticsEvent('video_room_$event', data);
  }
}
