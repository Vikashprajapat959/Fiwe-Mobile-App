// Model for Video Room
// ignore_for_file: library_private_types_in_public_api

int? _parseInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is String) return int.tryParse(v);
  return null;
}

String? _parseString(dynamic v) {
  if (v == null) return null;
  return v.toString();
}

bool? _parseBool(dynamic v) {
  if (v == null) return null;
  if (v is bool) return v;
  if (v is String) {
    final s = v.toLowerCase();
    if (s == 'true') return true;
    if (s == 'false') return false;
  }
  if (v is int) return v != 0;
  return null;
}

DateTime? _parseDateTime(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  if (v is String) {
    try {
      return DateTime.parse(v);
    } catch (_) {
      return null;
    }
  }
  return null;
}

class HMSVideoRoom {
  HMSVideoRoom({
    required this.objectId,
    required this.hmsRoomId,
    required this.title,
    this.description,
    this.status,
    this.capacity,
    this.currentOccupancy,
    this.availableSlots,
    this.isPublic,
    this.joinToken,
    this.expiresAt,
    this.createdAt,
    this.topic,
    this.userRole,
    this.joinedAt,
    this.roomHostCode,
    this.roomGuestCode,
    this.creator,
  });

  factory HMSVideoRoom.fromJson(Map<String, dynamic> json) {
    return HMSVideoRoom(
      objectId: _parseString(json['room_id']) ?? '',
      hmsRoomId: _parseString(json['hms_room_id']) ?? '',
      title: _parseString(json['title']) ?? '',
      description: _parseString(json['description']) ?? '',
      status: _parseString(json['status']) ?? '',
      capacity: _parseInt(json['capacity']),
      currentOccupancy: _parseInt(json['current_occupancy']),
      availableSlots: _parseInt(json['available_slots']),
      isPublic: _parseBool(json['is_public']) ?? false,
      joinToken: _parseString(json['join_token']),
      expiresAt: _parseDateTime(json['expires_at']),
      createdAt: _parseDateTime(json['created_at']),
      topic: json['topic'] != null && json['topic'] is Map<String, dynamic>
          ? _Topic.fromJson(json['topic'] as Map<String, dynamic>)
          : null,
      userRole: _parseString(json['user_role']),
      joinedAt: _parseDateTime(json['joined_at']),
      roomHostCode: _parseString(json['room_host_code']),
      roomGuestCode: _parseString(json['room_guest_code']),
      creator: json['creator'] != null && json['creator'] is Map<String, dynamic>
          ? _Creator.fromJson(json['creator'] as Map<String, dynamic>)
          : null,
    );
  }

  final String objectId;
  final String hmsRoomId;
  final String title;
  final String? description;
  final String? status;
  final int? capacity;
  final int? currentOccupancy;
  final int? availableSlots;
  final bool? isPublic;
  final String? joinToken;
  final DateTime? expiresAt;
  final DateTime? createdAt;
  final _Topic? topic;
  final String? userRole;
  final DateTime? joinedAt;
  final String? roomHostCode;
  final String? roomGuestCode;
  final _Creator? creator;

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
      'join_token': joinToken,
      'room_guest_code': roomGuestCode,
      'creator': creator?.toJson(),
    };
  }
}

class _Topic {
  _Topic({this.id, required this.name, required this.description, required this.thumbnail});

  factory _Topic.fromJson(Map<String, dynamic> json) {
    return _Topic(
      id: _parseString(json['id']),
      thumbnail: _parseString(json['thumbnail']) ?? '',
      name: _parseString(json['name']) ?? '',
      description: _parseString(json['description']) ?? '',
    );
  }
  // normalize id to String? (UUID or numeric string)
  final String? id;
  final String name;
  final String description;
  final String thumbnail;

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'description': description, 'thumbnail': thumbnail};
  }
}

class _Creator {
  _Creator({this.id, required this.name, required this.email});

  factory _Creator.fromJson(Map<String, dynamic> json) {
    return _Creator(
      id: _parseString(json['id']), // converts 56 -> "56"
      name: _parseString(json['name']) ?? '',
      email: _parseString(json['email']) ?? '',
    );
  }
  // normalize id to String? so both numeric and string ids handled
  final String? id;
  final String name;
  final String email;

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email};
  }
}
