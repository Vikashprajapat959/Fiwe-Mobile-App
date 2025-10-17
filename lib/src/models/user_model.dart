// lib/src/models/user_model.dart

import 'package:fiwe/src/models/topic.model.dart';

/// User model representing user data
class User {
  const User({
    this.id,
    this.email,
    this.name,
    this.nickName,
    this.dateOfBirth,
    this.pincode,
    this.phoneNumber,
    this.profileImageUrl,
    this.profileBase64,
    this.deviceId,
    this.isTncAccepted,
    this.isNew,
    this.isInterestsPending,
    this.fiveWords,
    this.bio,
    this.topics,
    this.createdAt,
    this.updatedAt,
    this.isActive,
    this.primaryInterest,
  });

  /// Creates a User from JSON data
  factory User.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] as Map<String, dynamic>? ?? json;

    final String? imageUrl = userJson['profile_image_url'] as String? ?? userJson['profileImageUrl'] as String?;

    return User(
      id: userJson['id'],
      email: userJson['email'] as String?,
      name: userJson['name'] as String?,
      nickName: userJson['nickname'] as String?,
      dateOfBirth: userJson['date_of_birth'] as String?,
      pincode: userJson['pincode'] as String?,
      phoneNumber: userJson['phone_number'] as String?,
      profileImageUrl: imageUrl,
      profileBase64: userJson['profile_image_base64'] as String?,
      deviceId: userJson['device_id'] as String?,
      isTncAccepted: userJson['is_tnc_accepted'] as bool?,
      isNew: userJson['is_new'] as bool?,
      isInterestsPending: userJson['is_interests_pending'] as bool?,
      fiveWords: userJson['your_five_word'] as String?,
      bio: userJson['bio'] as String?,
      topics: (json['topics'] as List<dynamic>?)?.map((e) => Topic.fromJson(e as Map<String, dynamic>)).toList(),
      createdAt: userJson['created_at'] != null ? DateTime.tryParse(userJson['created_at'] as String) : null,
      updatedAt: userJson['updated_at'] != null ? DateTime.tryParse(userJson['updated_at'] as String) : null,
      isActive: userJson['is_active'] as bool?,
      primaryInterest: userJson['primary_interest'] != null
          ? Topic.fromJson(userJson['primary_interest'] as Map<String, dynamic>)
          : null,
    );
  }

  final dynamic id;
  final String? email;
  final String? name;
  final String? nickName;
  final String? dateOfBirth;
  final String? pincode;
  final String? phoneNumber;
  final String? profileImageUrl;
  final String? profileBase64;
  final String? deviceId;
  final bool? isTncAccepted;
  final bool? isNew;
  final bool? isInterestsPending;
  final String? fiveWords;
  final String? bio;
  final List<Topic>? topics;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? isActive;
  final Topic? primaryInterest;

  /// Convert User to JSON (Null-safe)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'nickname': nickName,
      'date_of_birth': dateOfBirth,
      'pincode': pincode,
      'phone_number': phoneNumber,
      'profile_image_url': profileImageUrl,
      'profile_image_base64': profileBase64,
      'device_id': deviceId,
      'is_tnc_accepted': isTncAccepted,
      'is_new': isNew,
      'is_interests_pending': isInterestsPending,
      'your_five_word': fiveWords,
      'bio': bio,
      'topics': topics?.map((e) => e.toJson()).toList(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_active': isActive,
      'primary_interest': primaryInterest?.toJson(),
    };
  }

  /// Copy user with updated values (Null-safe)
  User copyWith({
    dynamic id,
    String? email,
    String? name,
    String? nickName,
    String? dateOfBirth,
    String? pincode,
    String? phoneNumber,
    String? profileImageUrl,
    String? profileBase64,
    String? deviceId,
    bool? isTncAccepted,
    bool? isNew,
    bool? isInterestsPending,
    String? fiveWords,
    String? bio,
    List<Topic>? topics,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    Topic? primaryInterest,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      nickName: nickName ?? this.nickName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      pincode: pincode ?? this.pincode,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      profileBase64: profileBase64 ?? this.profileBase64,
      deviceId: deviceId ?? this.deviceId,
      isTncAccepted: isTncAccepted ?? this.isTncAccepted,
      isNew: isNew ?? this.isNew,
      isInterestsPending: isInterestsPending ?? this.isInterestsPending,
      fiveWords: fiveWords ?? this.fiveWords,
      bio: bio ?? this.bio,
      topics: topics ?? this.topics,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      primaryInterest: primaryInterest ?? this.primaryInterest,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.email == email &&
        other.name == name &&
        other.nickName == nickName &&
        other.profileImageUrl == profileImageUrl &&
        other.profileBase64 == profileBase64 &&
        other.dateOfBirth == dateOfBirth &&
        other.pincode == pincode &&
        other.fiveWords == fiveWords &&
        other.bio == bio;
  }

  @override
  int get hashCode =>
      Object.hash(id, email, name, nickName, profileImageUrl, profileBase64, dateOfBirth, pincode, fiveWords, bio);

  @override
  String toString() {
    return 'User(id: $id, email: $email, name: $name)';
  }
}
