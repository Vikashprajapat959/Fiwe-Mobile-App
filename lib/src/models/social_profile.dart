class SocialProfile {
  final String? name;
  final String? email;
  final String? dateOfBirth;
  final String? pinCode;
  final String? profileImagePath;
  final String? displayName;
  final String? idToken;
  final bool isRegistered;

  SocialProfile({
    this.name,
    this.email,
    this.dateOfBirth,
    this.pinCode,
    this.profileImagePath,
    this.displayName,
    this.idToken,
    this.isRegistered = false,
  });

  factory SocialProfile.fromMap(Map<String, dynamic> map) {
    return SocialProfile(
      name: map['name'],
      email: map['email'],
      dateOfBirth: map['dateOfBirth'],
      pinCode: map['pinCode'],
      profileImagePath: map['profileImagePath'],
      displayName: map['displayName'],
      idToken: map['idToken'],
      isRegistered: map['isRegistered'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'dateOfBirth': dateOfBirth,
      'pinCode': pinCode,
      'profileImagePath': profileImagePath,
      'displayName': displayName,
      'idToken': idToken,
      'isRegistered': isRegistered,
    };
  }
}
