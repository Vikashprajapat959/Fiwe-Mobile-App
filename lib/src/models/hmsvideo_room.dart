//Model for Video Room
class HMSVideoRoom {
  final String objectId;
  final String hmsRoomId; // 100ms room ID
  final String title;
  final String description;
  final String createdBy; // User ID
  final List<String> participants; // User IDs
  final int capacity; // 5
  final String status;
  final bool isPublic;
  final DateTime? expiresAt;
  final String? joinToken;
  final String participantId;
  final DateTime? createdAt;
  final DateTime? endedAt;
  final bool? isActive;
  final String roomHostCode;
  final String roomGuestCode;

  HMSVideoRoom({
    required this.objectId,
    required this.hmsRoomId,
    required this.title,
    required this.description,
    required this.createdBy,
    required this.participants,
    required this.capacity,
    required this.status,
    required this.isPublic,
    required this.roomHostCode,
    required this.roomGuestCode,
    this.expiresAt,
    this.joinToken,
    required this.participantId,
    this.createdAt,
    this.endedAt,
    this.isActive = true,
  });

  // Create VideoRoom from JSON
  factory HMSVideoRoom.fromJson(Map<String, dynamic> json) {
    return HMSVideoRoom(
      objectId: json['room_id'] as String,
      hmsRoomId: json['hms_room_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      createdBy: '', // Not in the provided JSON structure
      participants: [], // Not in the provided JSON structure
      capacity: json['capacity'] as int,
      status: json['status'] as String,
      isPublic: json['is_public'] as bool,
      expiresAt: json['expires_at'] != null ? DateTime.parse(json['expires_at'] as String) : null,
      joinToken: json['join_token'] as String?,
      participantId: json['participant_id'] as String,
      createdAt: null, // Not in the provided JSON structure
      endedAt: null, // Not in the provided JSON structure
      isActive: true, // Default value
      roomHostCode: json['room_host_code'] as String,
      roomGuestCode: json['room_guest_code'] as String,
    );
  }

  // Convert VideoRoom to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': objectId,
      'hms_room_id': hmsRoomId,
      'title': title,
      'description': description,
      'created_by': createdBy,
      'participants': participants,
      'capacity': capacity,
      'status': status,
      'is_public': isPublic,
      'expires_at': expiresAt?.toIso8601String(),
      'join_token': joinToken,
      'participant_id': participantId,
      'created_at': createdAt?.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
      'is_active': isActive,
    };
  }
}
