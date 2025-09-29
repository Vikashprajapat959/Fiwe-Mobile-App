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
  });

  /// Creates a User from JSON data
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'] as String?,
      name: json['name'] as String?,
      dateOfBirth: json['date_of_birth'] as String?,
      pincode: json['pincode'] as String?,
      phoneNumber: json['phone_number'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
      profileBase64: json['profile_image_base64'] as String?,
      deviceId: json['device_id'] as String?,
      isTncAccepted: json['is_tnc_accepted'] as bool?,
      isNew: json['is_new'] as bool?,
      nickName: json['nickname'] as String?,
      fiveWords: json['your_five_words'] as String?,
      bio: json['bio'] as String?,
      isInterestsPending: json['is_interests_pending'] as bool?,
      topics: (json['topics'] as List<dynamic>?)
          ?.map((dynamic topicJson) => Topic.fromJson(topicJson as Map<String, dynamic>))
          .toList(),
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
      'your_five_words': fiveWords,
      'bio': bio,
      'is_interests_pending': isInterestsPending,
      'topics': topics?.map((Topic topic) => topic.toJson()).toList(),
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
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id && other.email == email;
  }

  @override
  int get hashCode => id.hashCode ^ email.hashCode;

  @override
  String toString() {
    return 'User(id: $id, email: $email, name: $name)';
  }
}
