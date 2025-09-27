import 'package:fiwe/src/models/topic.model.dart';

class User {
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

  User({
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

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      dateOfBirth: json['date_of_birth'],
      pincode: json['pincode'],
      phoneNumber: json['phone_number'],
      profileImageUrl: json['profile_image_url'],
      profileBase64: json['profile_image_base64'],
      deviceId: json['device_id'],
      isTncAccepted: json['is_tnc_accepted'],
      isNew: json['is_new'],
      nickName: json['nickname'],
      fiveWords: json['your_five_words'],
      bio: json['bio'],
      isInterestsPending: json['is_interests_pending'],
      topics: (json['topics'] as List<dynamic>?)
          ?.map((topicJson) => Topic.fromJson(topicJson as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
      'topics': topics,
    };
  }

  User? copyWith({
    required String name,
    required String nickName,
    required String email,
    required String dateOfBirth,
    required String pincode,
    required String fiveWords,
    required String bio,
    required String profileImageBase64,
  }) {
    return User(
      id: id,
      email: email,
      name: name,
      dateOfBirth: dateOfBirth,
      pincode: pincode,
      nickName: nickName,
      fiveWords: fiveWords,
      bio: bio,
      phoneNumber: phoneNumber,
      profileImageUrl: profileImageUrl,
      deviceId: deviceId,
      isTncAccepted: isTncAccepted,
      isNew: isNew,
      isInterestsPending: isInterestsPending,
      topics: topics,
      profileBase64: profileImageBase64,
    );
  }
}
