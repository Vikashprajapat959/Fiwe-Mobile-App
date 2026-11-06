// ignore_for_file: library_private_types_in_public_api

class RoomHistory {
  RoomHistory({this.rooms, this.pagination});

  factory RoomHistory.fromJson(Map<String, dynamic> json) => RoomHistory(
    rooms: json['rooms'] == null ? [] : List<Room>.from(json['rooms']!.map((x) => Room.fromJson(x))),
    pagination: json['pagination'] == null ? null : Pagination.fromJson(json['pagination']),
  );
  final List<Room>? rooms;
  final Pagination? pagination;

  Map<String, dynamic> toJson() => {
    'rooms': rooms == null ? [] : List<dynamic>.from(rooms!.map((x) => x.toJson())),
    'pagination': pagination?.toJson(),
  };
}

class Pagination {
  Pagination({this.currentPage, this.totalPages, this.totalRooms, this.pageSize});

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    currentPage: json['current_page'],
    totalPages: json['total_pages'],
    totalRooms: json['total_rooms'],
    pageSize: json['page_size'],
  );
  final int? currentPage;
  final int? totalPages;
  final int? totalRooms;
  final int? pageSize;

  Map<String, dynamic> toJson() => {
    'current_page': currentPage,
    'total_pages': totalPages,
    'total_rooms': totalRooms,
    'page_size': pageSize,
  };
}

class Room {
  Room({
    required this.roomId,
    this.hmsRoomId,
    this.title,
    this.originalTitle,
    this.description,
    this.status,
    this.capacity,
    this.isPublic,
    this.createdAt,
    this.expiresAt,
    this.endedAt,
    this.availableSlots,
    this.topic,
    this.creator,
    this.participants,
    this.stats,
  });

  factory Room.fromJson(Map<String, dynamic> json) => Room(
    roomId: json['room_id'],
    hmsRoomId: json['hms_room_id'],
    title: json['title'],
    originalTitle: json['original_title'],
    description: json['description'],
    status: json['status'],
    capacity: json['capacity'],
    isPublic: json['is_public'],
    createdAt: json['created_at'] == null ? null : DateTime.parse(json['created_at']),
    expiresAt: json['expires_at'] == null ? null : DateTime.parse(json['expires_at']),
    endedAt: json['ended_at'] == null ? null : DateTime.parse(json['ended_at']),
    availableSlots: json['available_slots'],
    topic: json['topic'] == null ? null : _Topic.fromJson(json['topic']),
    creator: json['creator'] == null ? null : _Creator.fromJson(json['creator']),
    participants: json['participants'] == null
        ? []
        : List<_Participant>.from(json['participants']!.map((x) => _Participant.fromJson(x))),
    stats: json['stats'] == null ? null : Stats.fromJson(json['stats']),
  );
  final String roomId;
  final String? hmsRoomId;
  final String? title;
  final String? originalTitle;
  final String? description;
  final String? status;
  final int? capacity;
  final bool? isPublic;
  final DateTime? createdAt;
  final DateTime? expiresAt;
  final DateTime? endedAt;
  final int? availableSlots;
  final _Topic? topic;
  final _Creator? creator;
  final List<_Participant>? participants;
  final Stats? stats;

  Map<String, dynamic> toJson() => {
    'room_id': roomId,
    'hms_room_id': hmsRoomId,
    'title': title,
    'original_title': originalTitle,
    'description': description,
    'status': status,
    'capacity': capacity,
    'is_public': isPublic,
    'created_at': createdAt?.toIso8601String(),
    'expires_at': expiresAt?.toIso8601String(),
    'ended_at': endedAt?.toIso8601String(),
    'available_slots': availableSlots,
    'topic': topic?.toJson(),
    'creator': creator?.toJson(),
    'participants': participants == null ? [] : List<dynamic>.from(participants!.map((x) => x.toJson())),
    'stats': stats?.toJson(),
  };
}

class _Creator {
  _Creator({this.id, this.name, this.email, this.avatar});

  factory _Creator.fromJson(Map<String, dynamic> json) =>
      _Creator(id: json['id'], name: json['name'], email: json['email'], avatar: json['profile_base64']);
  final String? id;
  final String? name;
  final String? email;
  final String? avatar;

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'email': email, 'profile_base64': avatar};
}

class _Participant {
  _Participant({
    this.participantId,
    this.userId,
    this.name,
    this.email,
    this.role,
    this.joinedAt,
    this.leftAt,
    this.isActive,
    this.durationInRoom,
    this.totalRating,
    this.profileBase64,
  });

  factory _Participant.fromJson(Map<String, dynamic> json) => _Participant(
    participantId: json['participant_id'],
    userId: json['user_id'],
    name: json['name'],
    email: json['email'],
    role: json['role'],
    joinedAt: json['joined_at'] == null ? null : DateTime.parse(json['joined_at']),
    leftAt: json['left_at'],
    isActive: json['is_active'],
    durationInRoom: json['duration_in_room'],
    totalRating: json['total_rating'],
    profileBase64: json['profile_base64'],
  );
  final String? participantId;
  final String? userId;
  final String? name;
  final String? email;
  final String? role;
  final DateTime? joinedAt;
  final dynamic leftAt;
  final bool? isActive;
  final String? durationInRoom;
  final double? totalRating;
  final String? profileBase64;

  Map<String, dynamic> toJson() => {
    'participant_id': participantId,
    'user_id': userId,
    'name': name,
    'email': email,
    'role': role,
    'joined_at': joinedAt?.toIso8601String(),
    'left_at': leftAt,
    'is_active': isActive,
    'duration_in_room': durationInRoom,
    'total_rating': totalRating,
  };
}

class Stats {
  Stats({this.totalParticipants, this.activeParticipants, this.inactiveParticipants});

  factory Stats.fromJson(Map<String, dynamic> json) => Stats(
    totalParticipants: json['total_participants'],
    activeParticipants: json['active_participants'],
    inactiveParticipants: json['inactive_participants'],
  );
  final int? totalParticipants;
  final int? activeParticipants;
  final int? inactiveParticipants;

  Map<String, dynamic> toJson() => {
    'total_participants': totalParticipants,
    'active_participants': activeParticipants,
    'inactive_participants': inactiveParticipants,
  };
}

class _Topic {
  _Topic({this.id, this.name, this.description, this.avatar});

  factory _Topic.fromJson(Map<String, dynamic> json) =>
      _Topic(id: json['id'], name: json['name'], description: json['description'], avatar: json['avatar']);
  final String? id;
  final String? name;
  final String? description;
  final String? avatar;

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'description': description, 'avatar': avatar};
}

class RoomDetail {
  RoomDetail({required this.room, required this.participant});

  factory RoomDetail.fromJson(Map<String, dynamic> json) => RoomDetail(
    room: Room.fromJson(json['room']),
    participant: List.from(json['participants']).map((e) => _Participant.fromJson(e)).toList(),
  );
  final Room room;
  final List<_Participant> participant;

  // Map<String, dynamic> toJson() => {'room': room.toJson(), 'participant': participant.toJson()};
}
