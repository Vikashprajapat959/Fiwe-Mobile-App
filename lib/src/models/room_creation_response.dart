class RoomCreationResponse {
  RoomCreationResponse({required this.roomId, required this.hostToken});

  factory RoomCreationResponse.fromJson(Map<String, dynamic> json) {
    return RoomCreationResponse(roomId: json['room_id'] as String, hostToken: json['host_token'] as String);
  }
  final String roomId;
  final String hostToken;

  Map<String, dynamic> toJson() {
    return {'room_id': roomId, 'host_token': hostToken};
  }
}
