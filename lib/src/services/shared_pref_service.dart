import 'package:shared_preferences/shared_preferences.dart';
import 'package:fiwe/src/utils/constants.dart';

class UserProfile {
  final String? name;
  final String? email;
  final String? dateOfBirth;
  final String? pinCode;
  final String? profileImagePath;
  final String? displayName;
  final String? idToken;
  final bool isRegistered;

  UserProfile({
    this.name,
    this.email,
    this.dateOfBirth,
    this.pinCode,
    this.profileImagePath,
    this.displayName,
    this.idToken,
    this.isRegistered = false,
  });

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

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
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
}

class SharedPrefService {
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<bool?> getBool(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  static Future<int?> getInt(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key);
  }

  static Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  static Future<void> setBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  static Future<void> setInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  static Future<void> setString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  // User profile specific methods
  static Future<void> saveUserProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (profile.name != null) {
      await prefs.setString(Constants.userNameKey, profile.name!);
    }
    if (profile.email != null) {
      await prefs.setString(Constants.userEmailKey, profile.email!);
    }
    if (profile.dateOfBirth != null) {
      await prefs.setString(Constants.userDateOfBirthKey, profile.dateOfBirth!);
    }
    if (profile.pinCode != null) {
      await prefs.setString(Constants.userPinCodeKey, profile.pinCode!);
    }
    if (profile.profileImagePath != null) {
      await prefs.setString(Constants.userProfileImageKey, profile.profileImagePath!);
    }
    if (profile.displayName != null) {
      await prefs.setString(Constants.userDisplayNameKey, profile.displayName!);
    }
    if (profile.idToken != null) {
      await prefs.setString(Constants.userIdTokenKey, profile.idToken!);
    }
    
    await prefs.setBool(Constants.isUserRegisteredKey, profile.isRegistered);
  }

  static Future<UserProfile?> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    
    final name = prefs.getString(Constants.userNameKey);
    final email = prefs.getString(Constants.userEmailKey);
    final dateOfBirth = prefs.getString(Constants.userDateOfBirthKey);
    final pinCode = prefs.getString(Constants.userPinCodeKey);
    final profileImagePath = prefs.getString(Constants.userProfileImageKey);
    final displayName = prefs.getString(Constants.userDisplayNameKey);
    final idToken = prefs.getString(Constants.userIdTokenKey);
    final isRegistered = prefs.getBool(Constants.isUserRegisteredKey) ?? false;
    
    // Return null if no user data exists
    if (email == null && name == null && displayName == null) {
      return null;
    }
    
    return UserProfile(
      name: name,
      email: email,
      dateOfBirth: dateOfBirth,
      pinCode: pinCode,
      profileImagePath: profileImagePath,
      displayName: displayName,
      idToken: idToken,
      isRegistered: isRegistered,
    );
  }

  static Future<bool> isUserRegistered() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(Constants.isUserRegisteredKey) ?? false;
  }

  static Future<void> markUserAsRegistered() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(Constants.isUserRegisteredKey, true);
  }

  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.remove(Constants.userNameKey);
    await prefs.remove(Constants.userEmailKey);
    await prefs.remove(Constants.userDateOfBirthKey);
    await prefs.remove(Constants.userPinCodeKey);
    await prefs.remove(Constants.userProfileImageKey);
    await prefs.remove(Constants.userDisplayNameKey);
    await prefs.remove(Constants.userIdTokenKey);
    await prefs.remove(Constants.isUserRegisteredKey);
    
    // Clear legacy auth keys as well
    await prefs.remove(Constants.loginTokenKey);
    await prefs.remove(Constants.loginUserIdKey);
    await prefs.remove(Constants.loginUsernameKey);
    await prefs.remove(Constants.loginEmailKey);
  }
}
