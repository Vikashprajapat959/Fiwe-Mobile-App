import 'package:fiwe/src/models/standard_api_response.dart'; // Add this import
import 'package:fiwe/src/services/http_service.dart';
import 'package:fiwe/src/services/shared_pref_service.dart';
import 'package:fiwe/src/utils/constants.dart';
import 'package:fiwe/src/utils/endpoints.dart';
import 'package:get/get.dart';

class UserService {
  final _httService = Get.find<HttpService>();

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
}
