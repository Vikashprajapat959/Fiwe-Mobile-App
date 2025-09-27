// Model for Video Room
// ignore_for_file: library_private_types_in_public_api

class HMSVideoRoom {
  final String objectId;
  final String hmsRoomId;
  final String title;
  final String description;
  final String status;
  final int? capacity;
  final int? currentOccupancy;
  final int? availableSlots;
  final bool isPublic;
  final DateTime? expiresAt;
  final DateTime? createdAt;
  final _Topic? topic;
  final String userRole;
  final DateTime? joinedAt;
  final String roomHostCode;
  final String roomGuestCode;
  final _Creator? creator;

  HMSVideoRoom({
    required this.objectId,
    required this.hmsRoomId,
    required this.title,
    required this.description,
    required this.status,
    required this.capacity,
    required this.currentOccupancy,
    required this.availableSlots,
    required this.isPublic,
    this.expiresAt,
    this.createdAt,
    required this.topic,
    required this.userRole,
    this.joinedAt,
    required this.roomHostCode,
    required this.roomGuestCode,
    required this.creator,
  });

  factory HMSVideoRoom.fromJson(Map<String, dynamic> json) {
    return HMSVideoRoom(
      objectId: json['room_id'] as String,
      hmsRoomId: json['hms_room_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      status: json['status'] as String,
      capacity: json['capacity'] as int,
      currentOccupancy: json['current_occupancy'] as int,
      availableSlots: json['available_slots'] as int,
      isPublic: json['is_public'] as bool,
      expiresAt: json['expires_at'] != null ? DateTime.parse(json['expires_at'] as String) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      topic: _Topic.fromJson(json['topic'] as Map<String, dynamic>),
      userRole: json['user_role'] as String,
      joinedAt: json['joined_at'] != null ? DateTime.parse(json['joined_at'] as String) : null,
      roomHostCode: json['room_host_code'] as String,
      roomGuestCode: json['room_guest_code'] as String,
      creator: _Creator.fromJson(json['creator'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'room_id': objectId,
      'hms_room_id': hmsRoomId,
      'title': title,
      'description': description,
      'status': status,
      'capacity': capacity,
      'current_occupancy': currentOccupancy,
      'available_slots': availableSlots,
      'is_public': isPublic,
      'expires_at': expiresAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'topic': topic?.toJson(),
      'user_role': userRole,
      'joined_at': joinedAt?.toIso8601String(),
      'room_host_code': roomHostCode,
      'room_guest_code': roomGuestCode,
      'creator': creator?.toJson(),
    };
  }
}

class _Topic {
  final String id;
  final String name;
  final String description;

  _Topic({required this.id, required this.name, required this.description});

  factory _Topic.fromJson(Map<String, dynamic> json) {
    return _Topic(id: json['id'] as String, name: json['name'] as String, description: json['description'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'description': description};
  }
}

class _Creator {
  final String id;
  final String name;
  final String email;

  _Creator({required this.id, required this.name, required this.email});

  factory _Creator.fromJson(Map<String, dynamic> json) {
    return _Creator(id: json['id'] as String, name: json['name'] as String, email: json['email'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email};
  }
}
