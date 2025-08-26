import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constants.dart';

/// Service for managing SharedPreferences storage
/// Only handles primitive data types and authentication tokens
class SharedPrefService {
  // Private constructor to prevent instantiation
  SharedPrefService._();

  /// Clear all stored data
  static Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      throw Exception('Failed to clear preferences: $e');
    }
  }

  /// Clear only authentication data (tokens and legacy auth keys)
  static Future<void> clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Clear current token keys
      await prefs.remove(Constants.bearerTokenKey);
      await prefs.remove(Constants.bearerTokenRefreshKey);
      
      // Clear legacy auth keys
      await prefs.remove(Constants.loginTokenKey);
      await prefs.remove(Constants.loginUserIdKey);
      await prefs.remove(Constants.loginUsernameKey);
      await prefs.remove(Constants.loginEmailKey);
    } catch (e) {
      throw Exception('Failed to clear auth data: $e');
    }
  }

  /// Get boolean value
  static Future<bool?> getBool(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(key);
    } catch (e) {
      return null;
    }
  }

  /// Get integer value
  static Future<int?> getInt(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(key);
    } catch (e) {
      return null;
    }
  }

  /// Get string value
  static Future<String?> getString(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    } catch (e) {
      return null;
    }
  }

  /// Remove specific key
  static Future<void> remove(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    } catch (e) {
      throw Exception('Failed to remove key $key: $e');
    }
  }

  /// Set boolean value
  static Future<void> setBool(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (e) {
      throw Exception('Failed to set bool for key $key: $e');
    }
  }

  /// Set integer value
  static Future<void> setInt(String key, int value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(key, value);
    } catch (e) {
      throw Exception('Failed to set int for key $key: $e');
    }
  }

  /// Set string value
  static Future<void> setString(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } catch (e) {
      throw Exception('Failed to set string for key $key: $e');
    }
  }
}
