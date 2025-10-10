import 'package:fiwe/src/models/topic.model.dart';

/// User model representing user data
class User {
  const User({
    this.id,
    this.email,
    this.name,
    this.dateOfBirth,
    this.pincode,
    this.nickName,
    this.fiveWords,
    this.bio,
    this.phoneNumber,
    this.profileImageUrl,
    this.profileBase64,
    this.deviceId,
    this.isTncAccepted,
    this.isNew,
    this.isInterestsPending,
    this.topics,
    this.createdAt,
    this.updatedAt,
    this.isActive,
    this.primaryInterest,
  });

  /// Creates a User from JSON data
  factory User.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] as Map<String, dynamic>? ?? json;

    return User(
      id: userJson['id'],
      email: userJson['email'] as String?,
      name: userJson['name'] as String?,
      dateOfBirth: userJson['date_of_birth'] as String?,
      pincode: userJson['pincode'] as String?,
      phoneNumber: userJson['phone_number'] as String?,
      profileImageUrl: userJson['profile_image_url'] as String?,
      profileBase64: userJson['profile_image_base64'] as String?,
      deviceId: userJson['device_id'] as String?,
      isTncAccepted: userJson['is_tnc_accepted'] as bool?,
      isNew: userJson['is_new'] as bool?,
      nickName: userJson['nickname'] as String?,
      fiveWords: userJson['your_five_word'] as String?,
      bio: userJson['bio'] as String?,
      isInterestsPending: userJson['is_interests_pending'] as bool?,
      topics: (json['topics'] as List<dynamic>?)
          ?.map((dynamic topicJson) => Topic.fromJson(topicJson as Map<String, dynamic>))
          .toList(),
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

  /// Converts User to JSON format
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'email': email,
      'name': name,
      'date_of_birth': dateOfBirth,
      'pincode': pincode,
      'phone_number': phoneNumber,
      'profile_image_url': profileImageUrl,
      'device_id': deviceId,
      'is_tnc_accepted': isTncAccepted,
      'is_new': isNew,
      'nickname': nickName,
      'your_five_word': fiveWords,
      'bio': bio,
      'is_interests_pending': isInterestsPending,
      'topics': topics?.map((Topic topic) => topic.toJson()).toList(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_active': isActive,
      'primary_interest': primaryInterest?.toJson(),
    };
  }

  /// Creates a copy of this user with updated values
  User copyWith({
    dynamic id,
    String? email,
    String? name,
    String? nickName,
    String? dateOfBirth,
    String? pincode,
    String? fiveWords,
    String? bio,
    String? phoneNumber,
    String? profileImageUrl,
    String? profileBase64,
    String? deviceId,
    bool? isTncAccepted,
    bool? isNew,
    bool? isInterestsPending,
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
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      pincode: pincode ?? this.pincode,
      nickName: nickName ?? this.nickName,
      fiveWords: fiveWords ?? this.fiveWords,
      bio: bio ?? this.bio,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      profileBase64: profileBase64 ?? this.profileBase64,
      deviceId: deviceId ?? this.deviceId,
      isTncAccepted: isTncAccepted ?? this.isTncAccepted,
      isNew: isNew ?? this.isNew,
      isInterestsPending: isInterestsPending ?? this.isInterestsPending,
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
           other.profileBase64 == profileBase64 &&
           other.dateOfBirth == dateOfBirth &&
           other.pincode == pincode &&
           other.fiveWords == fiveWords &&
           other.bio == bio;
  }

  @override
  int get hashCode => Object.hash(
        id,
        email,
        name,
        nickName,
        profileBase64,
        dateOfBirth,
        pincode,
        fiveWords,
        bio,
      );

  @override
  String toString() {
    return 'User(id: $id, email: $email, name: $name)';
  }
}
