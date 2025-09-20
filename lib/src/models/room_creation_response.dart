class RoomCreationResponse {
  final String roomId;
  final String hostToken;

  RoomCreationResponse({
    required this.roomId,
    required this.hostToken,
  });

  factory RoomCreationResponse.fromJson(Map<String, dynamic> json) {
    return RoomCreationResponse(
      roomId: json['room_id'] as String,
      hostToken: json['host_token'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'room_id': roomId,
      'host_token': hostToken,
    };
  }
}