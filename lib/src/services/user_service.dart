import 'dart:developer';

import 'package:fiwe/src/models/standard_api_response.dart'; // Add this import
import 'package:fiwe/src/models/user_model.dart';
import 'package:fiwe/src/models/user_notification.dart';
import 'package:fiwe/src/services/http_service.dart';
import 'package:fiwe/src/utils/endpoints.dart';
import 'package:get/get.dart';

class UserService extends GetxService {
  final _httService = Get.find<HttpService>();

  static UserService get instance => Get.find<UserService>();

  Future<ApiResponse<Map<String, dynamic>?>> followTopics(List<String> topics, String primaryTopic) async {
    try {
      final response = await _httService.post(
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

  Future<ApiResponse<UserNotificationPage>> fetchUserNotifications() async {
    final response = await _httService.get(Endpoints.fetchUserNotifications, isAuthorized: true);
    return response.success
        ? ApiResponse<UserNotificationPage>.success(
            data: UserNotificationPage.fromJson(response.data as Map<String, dynamic>),
            message: response.message,
          )
        : ApiResponse<UserNotificationPage>.error(message: response.message, data: null);
  }

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
    // put request to update profile
    try {
      final response = await _httService.put(
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
          : ApiResponse<bool>.error(message: response.message, data: false);
    } catch (e) {
      return ApiResponse<bool>.error(message: 'Network error occurred while updating profile: $e', data: false);
    }
  }

  Future<User> fetchUser(String userId) async {
    final response = await _httService.get('${Endpoints.users}/$userId', isAuthorized: true, log: true);
    if (response.success && response.data != null) {
      final user = User.fromJson(response.data!['user']);
      return user;
    } else {
      throw Exception('Failed to fetch user: ${response.message}');
    }
  }
}
