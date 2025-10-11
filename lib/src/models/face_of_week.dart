// ignore_for_file: library_private_types_in_public_api

import 'package:fiwe/src/models/topic.model.dart';

class FaceOfWeek {
  const FaceOfWeek(this.users);
  factory FaceOfWeek.fromJson(Map<String, dynamic> json) =>
      FaceOfWeek(List.from(json['topic_faces']).map((e) => FaceOfTheWeekUser.fromJson(e)).toList());
  final List<FaceOfTheWeekUser> users;
}

class FaceOfTheWeekUser {
  const FaceOfTheWeekUser({required this.topic, required this.user});

  factory FaceOfTheWeekUser.fromJson(Map<String, dynamic> json) {
    return FaceOfTheWeekUser(
      topic: Topic.fromJson(json['topic']),
      user: _FaceOfWeekUser.fromJson(json['face_of_week']),
    );
  }
  final Topic topic;
  final _FaceOfWeekUser user;
}

class _FaceOfWeekUser {
  const _FaceOfWeekUser({this.id, this.name, this.avgRating = 0.0, this.ratingCount = 0, this.profileBase64});

  factory _FaceOfWeekUser.fromJson(Map<String, dynamic> json) {
    return _FaceOfWeekUser(
      id: json['user_id'],
      name: json['name'],
      avgRating: json['average_rating'] ?? 0.0,
      ratingCount: json['rating_count'] ?? 0,
      profileBase64: json['profile_image_base64'],
    );
  }
  final String? id;
  final String? name;
  final double avgRating;
  final int ratingCount;
  final String? profileBase64;
}
