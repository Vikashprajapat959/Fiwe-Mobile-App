import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

import 'package:fiwe/src/models/video_room_models.dart';
import 'package:fiwe/src/utils/constants.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:get/get.dart';

/// Persistent notification service for video room calls
/// Provides ongoing notifications while in video calls with duration tracking
class VideoRoomNotificationService extends GetxService {
  static VideoRoomNotificationService get instance => Get.find<VideoRoomNotificationService>();

  // Notification state
  final Rxn<NotificationState> _currentNotification = Rxn<NotificationState>();
  final RxBool _isServiceRunning = false.obs;
  final Rxn<VideoRoomState> _roomState = Rxn<VideoRoomState>();

  // Timer for duration updates
  Timer? _durationTimer;
  ReceivePort? _receivePort;

  // Getters
  NotificationState? get currentNotification => _currentNotification.value;
  bool get isServiceRunning => _isServiceRunning.value;
  VideoRoomState? get roomState => _roomState.value;

  // Observable getters
  Rxn<NotificationState> get currentNotificationObservable => _currentNotification;
  RxBool get isServiceRunningObservable => _isServiceRunning;

  @override
  void onInit() {
    super.onInit();
    _initializeService();
  }

  @override
  void onClose() {
    stopNotification();
    super.onClose();
  }

  /// Initialize the foreground service
  Future<void> _initializeService() async {
    try {
      // Initialize Flutter Foreground Task with persistent notification settings
      FlutterForegroundTask.init(
        androidNotificationOptions: AndroidNotificationOptions(
          channelId: 'fiwe_video_room',
          channelName: 'Video Room Service',
          channelDescription: 'Persistent notification for active video calls',
          channelImportance: NotificationChannelImportance.HIGH,
          priority: NotificationPriority.HIGH,
          showWhen: true,
        ),
        iosNotificationOptions: const IOSNotificationOptions(
          showNotification: true,
          playSound: false,
        ),
        foregroundTaskOptions: ForegroundTaskOptions(
          eventAction: ForegroundTaskEventAction.repeat(5000), // Update every 5 seconds
          autoRunOnBoot: false,
          allowWakeLock: true,
          allowWifiLock: false,
        ),
      );

      log('Notification service initialized with persistent settings', name: 'VideoRoomNotificationService');
    } catch (e) {
      log('Error initializing notification service: $e', name: 'VideoRoomNotificationService');
    }
  }

  /// Start persistent notification for video room
  Future<bool> startNotification(VideoRoomState roomState) async {
    try {
      if (_isServiceRunning.value) {
        log('Notification service already running', name: 'VideoRoomNotificationService');
        return true;
      }

      _roomState.value = roomState;

      // Create initial notification state
      final notificationState = NotificationState(
        notificationId: 'video_room_${roomState.roomId}',
        roomTitle: roomState.roomTitle,
        activeDuration: roomState.callDuration,
        participantCount: roomState.participantCount.value,
        connectionStatus: roomState.connectionStatus.value,
        actions: _createNotificationActions(),
        lastUpdate: DateTime.now(),
      );

      _currentNotification.value = notificationState;

      // Start foreground service
      var result = await FlutterForegroundTask.startService(
        notificationTitle: _buildNotificationTitle(notificationState),
        notificationText: _buildNotificationText(notificationState),
        callback: _startCallback,
      );

      bool started = result != null;

      if (started) {
        _isServiceRunning.value = true;
        _startDurationTimer();
        _setupReceivePort();
        
        log('Notification started for room: ${roomState.roomTitle}', name: 'VideoRoomNotificationService');
      }

      return started;
    } catch (e) {
      log('Error starting notification: $e', name: 'VideoRoomNotificationService');
      return false;
    }
  }

  /// Stop persistent notification
  Future<void> stopNotification() async {
    try {
      _durationTimer?.cancel();
      _durationTimer = null;

      _receivePort?.close();
      _receivePort = null;

      await FlutterForegroundTask.stopService();
      
      _isServiceRunning.value = false;
      _currentNotification.value = null;
      _roomState.value = null;

      log('Notification service stopped', name: 'VideoRoomNotificationService');
    } catch (e) {
      log('Error stopping notification: $e', name: 'VideoRoomNotificationService');
    }
  }

  /// Update notification content
  Future<void> updateNotification({
    String? roomTitle,
    int? participantCount,
    ConnectionStatus? connectionStatus,
    bool? isInPip,
  }) async {
    try {
      if (!_isServiceRunning.value || _roomState.value == null) {
        return;
      }

      final currentRoom = _roomState.value!;
      final currentNotification = _currentNotification.value;
      
      if (currentNotification == null) return;

      // Update room state
      if (participantCount != null) {
        currentRoom.participantCount.value = participantCount;
      }
      if (connectionStatus != null) {
        currentRoom.connectionStatus.value = connectionStatus;
      }
      if (isInPip != null) {
        currentRoom.isInPip.value = isInPip;
      }

      // Update notification state
      final updatedNotification = currentNotification.copyWith(
        roomTitle: roomTitle,
        participantCount: participantCount,
        connectionStatus: connectionStatus,
        activeDuration: currentRoom.callDuration,
        lastUpdate: DateTime.now(),
      );

      _currentNotification.value = updatedNotification;

      // Update foreground notification
      await FlutterForegroundTask.updateService(
        notificationTitle: _buildNotificationTitle(updatedNotification),
        notificationText: _buildNotificationText(updatedNotification),
      );

    } catch (e) {
      log('Error updating notification: $e', name: 'VideoRoomNotificationService');
    }
  }

  /// Build notification title
  String _buildNotificationTitle(NotificationState state) {
    final statusIcon = state.connectionStatus.isConnected ? '🔵' : '🔴';
    return '$statusIcon ${state.roomTitle}';
  }

  /// Build notification text
  String _buildNotificationText(NotificationState state) {
    final duration = _roomState.value?.formattedDuration ?? '00:00';
    final participants = state.participantCount;
    final participantText = participants == 1 ? 'participant' : 'participants';
    
    return '$duration • $participants $participantText';
  }

  /// Create notification actions
  List<NotificationActionData> _createNotificationActions() {
    final actions = <NotificationActionData>[
      const NotificationActionData(
        actionId: 'return_to_call',
        label: 'Return to Call',
        type: NotificationActionType.returnToCall,
      ),
    ];

    // Add platform-specific actions
    if (Platform.isAndroid) {
      actions.addAll([
        const NotificationActionData(
          actionId: 'mute_unmute',
          label: 'Mute/Unmute',
          type: NotificationActionType.muteUnmute,
        ),
        const NotificationActionData(
          actionId: 'leave_call',
          label: 'Leave Call',
          type: NotificationActionType.leaveCall,
        ),
      ]);
    } else {
      // iOS supports fewer notification actions
      actions.add(
        const NotificationActionData(
          actionId: 'leave_call',
          label: 'Leave Call',
          type: NotificationActionType.leaveCall,
        ),
      );
    }

    return actions;
  }

  /// Start duration update timer
  void _startDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _updateDuration();
    });
  }

  /// Update duration in notification
  void _updateDuration() async {
    try {
      if (!_isServiceRunning.value || 
          _roomState.value == null || 
          _currentNotification.value == null) {
        return;
      }

      final currentRoom = _roomState.value!;
      final currentNotification = _currentNotification.value!;

      // Update notification with new duration
      final updatedNotification = currentNotification.copyWith(
        activeDuration: currentRoom.callDuration,
        lastUpdate: DateTime.now(),
      );

      _currentNotification.value = updatedNotification;

      // Update foreground notification
      await FlutterForegroundTask.updateService(
        notificationTitle: _buildNotificationTitle(updatedNotification),
        notificationText: _buildNotificationText(updatedNotification),
      );

    } catch (e) {
      log('Error updating duration: $e', name: 'VideoRoomNotificationService');
    }
  }

  /// Setup receive port for communication
  void _setupReceivePort() {
    _receivePort = FlutterForegroundTask.receivePort;
    _receivePort?.listen((data) {
      if (data is Map<String, dynamic>) {
        _handleForegroundTaskMessage(data);
      }
    });
  }

  /// Handle messages from foreground task
  void _handleForegroundTaskMessage(Map<String, dynamic> message) {
    try {
      final action = message['action'] as String?;
      
      switch (action) {
        case 'notification_pressed':
          _handleNotificationPressed();
          break;
        case 'action_pressed':
          final actionId = message['actionId'] as String?;
          if (actionId != null) {
            _handleNotificationAction(actionId);
          }
          break;
        default:
          log('Unknown foreground task message: $message', name: 'VideoRoomNotificationService');
      }
    } catch (e) {
      log('Error handling foreground task message: $e', name: 'VideoRoomNotificationService');
    }
  }

  /// Handle notification tap
  void _handleNotificationPressed() {
    try {
      // Navigate back to video room
      Get.toNamed(Constants.videoRoomRoute);
    } catch (e) {
      log('Error handling notification press: $e', name: 'VideoRoomNotificationService');
    }
  }

  /// Handle notification action
  void _handleNotificationAction(String actionId) {
    try {
      switch (actionId) {
        case 'return_to_call':
          _handleReturnToCall();
          break;
        case 'mute_unmute':
          _handleMuteUnmute();
          break;
        case 'leave_call':
          _handleLeaveCall();
          break;
        default:
          log('Unknown notification action: $actionId', name: 'VideoRoomNotificationService');
      }
    } catch (e) {
      log('Error handling notification action: $e', name: 'VideoRoomNotificationService');
    }
  }

  /// Handle return to call action
  void _handleReturnToCall() {
    try {
      // Restore app and navigate to video room
      Get.toNamed(Constants.videoRoomRoute);
      log('Returning to call from notification', name: 'VideoRoomNotificationService');
    } catch (e) {
      log('Error returning to call: $e', name: 'VideoRoomNotificationService');
    }
  }

  /// Handle mute/unmute action
  void _handleMuteUnmute() {
    // This would need to integrate with the video room controller
    // For now, just log the action
    log('Mute/Unmute action triggered from notification', name: 'VideoRoomNotificationService');
  }

  /// Handle leave call action
  void _handleLeaveCall() {
    try {
      // This would trigger leaving the call
      // For now, stop the notification
      stopNotification();
      log('Leave call action triggered from notification', name: 'VideoRoomNotificationService');
    } catch (e) {
      log('Error handling leave call: $e', name: 'VideoRoomNotificationService');
    }
  }

  /// Get current notification info for debugging
  Map<String, dynamic> getNotificationInfo() {
    return {
      'isServiceRunning': _isServiceRunning.value,
      'hasCurrentNotification': _currentNotification.value != null,
      'hasRoomState': _roomState.value != null,
      'currentNotification': _currentNotification.value?.toJson(),
      'roomState': _roomState.value?.toJson(),
    };
  }
}

/// Foreground task callback
@pragma('vm:entry-point')
void _startCallback() {
  FlutterForegroundTask.setTaskHandler(_VideoRoomTaskHandler());
}

/// Task handler for foreground service
class _VideoRoomTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    log('VideoRoom foreground task started', name: 'VideoRoomTaskHandler');
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // This is called every 5 seconds (based on interval)
    // We can use this to send updates back to the main isolate
    FlutterForegroundTask.updateService(
      notificationTitle: 'Video Call Active',
      notificationText: 'Call in progress...',
    );
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    log('VideoRoom foreground task destroyed', name: 'VideoRoomTaskHandler');
  }

  @override
  void onNotificationPressed() {
    // Handle notification tap
    FlutterForegroundTask.launchApp(Constants.videoRoomRoute);
  }

  @override
  void onNotificationButtonPressed(String id) {
    // Handle notification action button press
    FlutterForegroundTask.sendDataToMain({
      'action': 'action_pressed',
      'actionId': id,
    });
  }
}