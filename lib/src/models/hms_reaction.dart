// Model for Reaction
class HMSReaction {
  HMSReaction({
    required this.id,
    required this.userId,
    required this.emoji,
    required this.timestamp,
    required this.roomId,
  });

  // Create Reaction from JSON
  factory HMSReaction.fromJson(Map<String, dynamic> json) {
    return HMSReaction(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      emoji: json['emoji'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      roomId: json['room_id'] as String,
    );
  }
  final String id;
  final String userId;
  final String emoji;
  final DateTime timestamp;
  final String roomId;

  // Convert Reaction to JSON
  Map<String, dynamic> toJson() {
    return {'id': id, 'user_id': userId, 'emoji': emoji, 'timestamp': timestamp.toIso8601String(), 'room_id': roomId};
  }
}
