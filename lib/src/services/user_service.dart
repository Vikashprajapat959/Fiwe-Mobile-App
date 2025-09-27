import 'package:fiwe/src/models/standard_api_response.dart'; // Add this import
import 'package:fiwe/src/models/user_notification.dart';
import 'package:fiwe/src/services/http_service.dart';
import 'package:fiwe/src/services/shared_pref_service.dart';
import 'package:fiwe/src/utils/constants.dart';
import 'package:fiwe/src/utils/endpoints.dart';
import 'package:get/get.dart';

class UserService extends GetxService {
  final _httService = Get.find<HttpService>();

  static UserService get instance => Get.find<UserService>();

  Future<ApiResponse<bool>> followTopics(List<String> topics, String primaryTopic) async {
    try {
      String token = await SharedPrefService.getString(Constants.storageBearerTokenKey) ?? "";

      final response = await _httService.post(
        Endpoints.followTopicsBulk,
        body: {
          "topics": topics
              .map((topic) => {"topic_id": topic, "set_interest_is_primary": topic == primaryTopic})
              .toList(),
        },
        headers: {"Authorization": "Bearer $token"},
      );

      return response.success
          ? ApiResponse<bool>.success(data: true, message: response.message)
          : ApiResponse<bool>.error(message: response.message, data: false);
    } catch (e) {
      return ApiResponse<bool>.error(message: 'Network error occurred while following topics: $e', data: false);
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
          "name": name,
          "nickname": nickname,
          "email": email,
          "date_of_birth": dob,
          "pincode": pincode,
          "your_five_word": fiweWord,
          "bio": bio,
          "profile_image_base64": imageBase64,
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
}
