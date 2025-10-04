class InteractedParticipant {
  InteractedParticipant({
    required this.userId,
    required this.name,
    required this.profileImageBase64,
    required this.role,
    required this.joinedAt,
    required this.leftAt,
  });

  factory InteractedParticipant.fromJson(Map<String, dynamic> json) {
    return InteractedParticipant(
      userId: json['user_id'].toString(),
      name: json['name'],
      profileImageBase64: json['profile_image_base64'],
      role: json['role'],
      joinedAt: DateTime.parse(json['joined_at']),
      leftAt: DateTime.parse(json['left_at']),
    );
  }
  final String userId;
  final String name;
  final String? profileImageBase64;
  final String role;
  final DateTime joinedAt;
  final DateTime leftAt;
}
