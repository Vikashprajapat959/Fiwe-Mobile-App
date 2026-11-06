import 'dart:developer';

import 'package:fiwe/src/models/standard_api_response.dart';
import 'package:fiwe/src/models/user_model.dart';
import 'package:fiwe/src/models/user_notification.dart';
import 'package:fiwe/src/services/http_service.dart';
import 'package:fiwe/src/utils/endpoints.dart';
import 'package:get/get.dart';

class UserService extends GetxService {
  final _httpService = Get.find<HttpService>();

  static UserService get instance => Get.find<UserService>();

  /// Follow topics
  Future<ApiResponse<Map<String, dynamic>?>> followTopics(List<String> topics, String primaryTopic) async {
    try {
      final response = await _httpService.post(
        Endpoints.followTopicsBulk,
        body: {
          'topics': topics
              .map((topic) => {'topic_id': topic, 'set_as_primary_interest': topic == primaryTopic})
              .toList(),
        },
        isAuthorized: true,
        log: false,
      );
      log(response.data.toString(), name: 'followTopics');
      return response.success
          ? ApiResponse.success(message: response.message, data: response.data)
          : ApiResponse.error(message: response.message, data: null);
    } catch (e) {
      return ApiResponse.error(message: 'Network error occurred while following topics: $e', data: null);
    }
  }

  /// Fetch notifications with pagination
  Future<ApiResponse<UserNotificationPage>> fetchUserNotifications({int page = 1, int pageSize = 20}) async {
    try {
      final response = await _httpService.get(
        '${Endpoints.fetchUserNotifications}?page=$page&pageSize=$pageSize',
        isAuthorized: true,
      );

      if (response.success && response.data != null) {
        return ApiResponse<UserNotificationPage>.success(
          data: UserNotificationPage.fromJson(response.data as Map<String, dynamic>),
          message: response.message,
        );
      } else {
        return ApiResponse<UserNotificationPage>.error(message: response.message, data: null);
      }
    } catch (e) {
      return ApiResponse<UserNotificationPage>.error(
        message: 'Network error while fetching notifications: $e',
        data: null,
      );
    }
  }

  /// Update user profile
  Future<ApiResponse<bool>> updateProfile(
    String name,
    String nickname,
    String email,
    String dob,
    String pincode,
    String fiweWord,
    String bio, {
    required String imageBase64,
  }) async {
    try {
      final response = await _httpService.put(
        Endpoints.updateProfile,
        body: {
          'name': name,
          'nickname': nickname,
          'email': email,
          'date_of_birth': dob,
          'pincode': pincode,
          'your_five_word': fiweWord,
          'bio': bio,
          'profile_image_base64': imageBase64,
        },
        isAuthorized: true,
      );

      return response.success
          ? ApiResponse<bool>.success(data: true, message: response.message)
          : ApiResponse<bool>.error(data: false, message: response.message);
    } catch (e) {
      return ApiResponse<bool>.error(message: 'Network error occurred while updating profile: $e', data: false);
    }
  }

  /// Fetch single user
  Future<User> fetchUser(String userId) async {
    try {
      final response = await _httpService.get('${Endpoints.users}/$userId', isAuthorized: true, log: true);

      if (response.success && response.data != null) {
        // Ensure 'user' key exists
        final userData = response.data!['user'] as Map<String, dynamic>?;
        if (userData == null) throw Exception('User data is null');

        return User.fromJson(userData);
      } else {
        throw Exception('Failed to fetch user: ${response.message}');
      }
    } catch (e) {
      throw Exception('Network error while fetching user: $e');
    }
  }
}
