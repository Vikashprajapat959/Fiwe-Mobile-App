import 'package:get/get.dart';

/// Room state model for tracking video room information
class VideoRoomState {
  final String roomId;
  final String roomTitle;
  final DateTime joinTime;
  final RxInt participantCount = 0.obs;
  final Rx<ConnectionStatus> connectionStatus = ConnectionStatus.connected.obs;
  final Rx<MediaState> mediaState = MediaState().obs;
  final RxBool isInPip = false.obs;
  final RxBool hasActiveNotification = false.obs;

  VideoRoomState({
    required this.roomId,
    required this.roomTitle,
    DateTime? joinTime,
  }) : joinTime = joinTime ?? DateTime.now();

  /// Get current call duration
  Duration get callDuration => DateTime.now().difference(joinTime);

  /// Format duration for display
  String get formattedDuration {
    final duration = callDuration;
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(hours >= 10 ? 2 : 1, '0')}:'
             '${minutes.toString().padLeft(2, '0')}:'
             '${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:'
             '${seconds.toString().padLeft(2, '0')}';
    }
  }

  /// Create a copy with updated values
  VideoRoomState copyWith({
    String? roomId,
    String? roomTitle,
    DateTime? joinTime,
    int? participantCount,
    ConnectionStatus? connectionStatus,
    MediaState? mediaState,
    bool? isInPip,
    bool? hasActiveNotification,
  }) {
    final newState = VideoRoomState(
      roomId: roomId ?? this.roomId,
      roomTitle: roomTitle ?? this.roomTitle,
      joinTime: joinTime ?? this.joinTime,
    );
    
    if (participantCount != null) newState.participantCount.value = participantCount;
    if (connectionStatus != null) newState.connectionStatus.value = connectionStatus;
    if (mediaState != null) newState.mediaState.value = mediaState;
    if (isInPip != null) newState.isInPip.value = isInPip;
    if (hasActiveNotification != null) newState.hasActiveNotification.value = hasActiveNotification;
    
    return newState;
  }

  Map<String, dynamic> toJson() {
    return {
      'roomId': roomId,
      'roomTitle': roomTitle,
      'joinTime': joinTime.toIso8601String(),
      'participantCount': participantCount.value,
      'connectionStatus': connectionStatus.value.toString(),
      'mediaState': mediaState.value.toJson(),
      'isInPip': isInPip.value,
      'hasActiveNotification': hasActiveNotification.value,
      'callDuration': callDuration.inSeconds,
    };
  }
}

/// Participant model
class Participant {
  final String userId;
  final String displayName;
  final bool isAudioMuted;
  final bool isVideoMuted;
  final bool isSpeaking;
  final bool isLocal;

  const Participant({
    required this.userId,
    required this.displayName,
    this.isAudioMuted = false,
    this.isVideoMuted = false,
    this.isSpeaking = false,
    this.isLocal = false,
  });

  Participant copyWith({
    String? userId,
    String? displayName,
    bool? isAudioMuted,
    bool? isVideoMuted,
    bool? isSpeaking,
    bool? isLocal,
  }) {
    return Participant(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      isAudioMuted: isAudioMuted ?? this.isAudioMuted,
      isVideoMuted: isVideoMuted ?? this.isVideoMuted,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      isLocal: isLocal ?? this.isLocal,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'displayName': displayName,
      'isAudioMuted': isAudioMuted,
      'isVideoMuted': isVideoMuted,
      'isSpeaking': isSpeaking,
      'isLocal': isLocal,
    };
  }
}

/// Media state model
class MediaState {
  final bool isMicrophoneOn;
  final bool isCameraOn;
  final String activeAudioDevice;
  final String videoQuality;

  const MediaState({
    this.isMicrophoneOn = true,
    this.isCameraOn = true,
    this.activeAudioDevice = 'Speaker',
    this.videoQuality = 'HD',
  });

  MediaState copyWith({
    bool? isMicrophoneOn,
    bool? isCameraOn,
    String? activeAudioDevice,
    String? videoQuality,
  }) {
    return MediaState(
      isMicrophoneOn: isMicrophoneOn ?? this.isMicrophoneOn,
      isCameraOn: isCameraOn ?? this.isCameraOn,
      activeAudioDevice: activeAudioDevice ?? this.activeAudioDevice,
      videoQuality: videoQuality ?? this.videoQuality,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isMicrophoneOn': isMicrophoneOn,
      'isCameraOn': isCameraOn,
      'activeAudioDevice': activeAudioDevice,
      'videoQuality': videoQuality,
    };
  }
}

/// Connection status enum
enum ConnectionStatus {
  connected,
  connecting,
  disconnected,
  reconnecting,
  failed;

  String get displayName {
    switch (this) {
      case ConnectionStatus.connected:
        return 'Connected';
      case ConnectionStatus.connecting:
        return 'Connecting...';
      case ConnectionStatus.disconnected:
        return 'Disconnected';
      case ConnectionStatus.reconnecting:
        return 'Reconnecting...';
      case ConnectionStatus.failed:
        return 'Connection Failed';
    }
  }

  bool get isConnected => this == ConnectionStatus.connected;
  bool get isDisconnected => this == ConnectionStatus.disconnected || this == ConnectionStatus.failed;
}

/// Notification state model
class NotificationState {
  final String notificationId;
  final String roomTitle;
  final Duration activeDuration;
  final int participantCount;
  final ConnectionStatus connectionStatus;
  final List<NotificationActionData> actions;
  final DateTime lastUpdate;
  final bool isVisible;

  const NotificationState({
    required this.notificationId,
    required this.roomTitle,
    required this.activeDuration,
    required this.participantCount,
    required this.connectionStatus,
    required this.actions,
    required this.lastUpdate,
    this.isVisible = true,
  });

  NotificationState copyWith({
    String? notificationId,
    String? roomTitle,
    Duration? activeDuration,
    int? participantCount,
    ConnectionStatus? connectionStatus,
    List<NotificationActionData>? actions,
    DateTime? lastUpdate,
    bool? isVisible,
  }) {
    return NotificationState(
      notificationId: notificationId ?? this.notificationId,
      roomTitle: roomTitle ?? this.roomTitle,
      activeDuration: activeDuration ?? this.activeDuration,
      participantCount: participantCount ?? this.participantCount,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      actions: actions ?? this.actions,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      isVisible: isVisible ?? this.isVisible,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationId': notificationId,
      'roomTitle': roomTitle,
      'activeDurationSeconds': activeDuration.inSeconds,
      'participantCount': participantCount,
      'connectionStatus': connectionStatus.toString(),
      'actions': actions.map((a) => a.toJson()).toList(),
      'lastUpdate': lastUpdate.toIso8601String(),
      'isVisible': isVisible,
    };
  }
}

/// Notification action data
class NotificationActionData {
  final String actionId;
  final String label;
  final NotificationActionType type;
  final bool isEnabled;

  const NotificationActionData({
    required this.actionId,
    required this.label,
    required this.type,
    this.isEnabled = true,
  });

  NotificationActionData copyWith({
    String? actionId,
    String? label,
    NotificationActionType? type,
    bool? isEnabled,
  }) {
    return NotificationActionData(
      actionId: actionId ?? this.actionId,
      label: label ?? this.label,
      type: type ?? this.type,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'actionId': actionId,
      'label': label,
      'type': type.toString(),
      'isEnabled': isEnabled,
    };
  }
}

/// Notification action types
enum NotificationActionType {
  returnToCall,
  muteUnmute,
  leaveCall;

  String get actionId {
    switch (this) {
      case NotificationActionType.returnToCall:
        return 'return_to_call';
      case NotificationActionType.muteUnmute:
        return 'mute_unmute';
      case NotificationActionType.leaveCall:
        return 'leave_call';
    }
  }

  String get defaultLabel {
    switch (this) {
      case NotificationActionType.returnToCall:
        return 'Return to Call';
      case NotificationActionType.muteUnmute:
        return 'Mute/Unmute';
      case NotificationActionType.leaveCall:
        return 'Leave Call';
    }
  }
}

/// Participant rating model for user rating screen
class ParticipantRating {
  final String userId;
  final String displayName;
  final String? avatarUrl;
  final RxInt ratingScore; // 1-5 stars
  final RxString feedbackText;
  final RxBool isAnonymous;
  final RxBool hasChanges;

  ParticipantRating({
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    int initialRating = 0,
    String initialFeedback = '',
    bool initialAnonymous = false,
  }) : ratingScore = RxInt(initialRating),
       feedbackText = RxString(initialFeedback),
       isAnonymous = RxBool(initialAnonymous),
       hasChanges = RxBool(false);

  void updateRating(int score) {
    if (score >= 1 && score <= 5) {
      ratingScore.value = score;
      hasChanges.value = true;
    }
  }

  void updateFeedback(String feedback) {
    feedbackText.value = feedback.trim();
    hasChanges.value = true;
  }

  void toggleAnonymous() {
    isAnonymous.value = !isAnonymous.value;
    hasChanges.value = true;
  }

  bool get isValid => ratingScore.value > 0;

  factory ParticipantRating.fromParticipant(Participant participant) {
    return ParticipantRating(
      userId: participant.userId,
      displayName: participant.displayName,
    );
  }

  Map<String, dynamic> toSubmissionJson(String roomParticipationId) {
    return {
      'rated_user_id': userId,
      'room_participation_id': roomParticipationId,
      'rating_score': ratingScore.value,
      'feedback_text': feedbackText.value.isEmpty ? null : feedbackText.value,
      'is_anonymous': isAnonymous.value,
    };
  }
}

class RatingSubmission {
  final String ratedUserId;
  final String roomParticipationId;
  final int ratingScore;
  final String? feedbackText;
  final bool isAnonymous;

  const RatingSubmission({
    required this.ratedUserId,
    required this.roomParticipationId,
    required this.ratingScore,
    this.feedbackText,
    required this.isAnonymous,
  });

  bool get isValid => ratedUserId.isNotEmpty && roomParticipationId.isNotEmpty && ratingScore >= 1 && ratingScore <= 5;

  Map<String, dynamic> toJson() {
    return {
      'rated_user_id': ratedUserId,
      'room_participation_id': roomParticipationId,
      'rating_score': ratingScore,
      'feedback_text': feedbackText?.isEmpty == true ? null : feedbackText,
      'is_anonymous': isAnonymous,
    };
  }
}