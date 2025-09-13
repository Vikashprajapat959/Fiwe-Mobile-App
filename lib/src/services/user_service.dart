import 'package:fiwe/src/services/http_service.dart';
import 'package:fiwe/src/services/shared_pref_service.dart';
import 'package:fiwe/src/utils/constants.dart';
import 'package:fiwe/src/utils/endpoints.dart';
import 'package:get/get.dart';
import 'package:fiwe/src/models/standard_api_response.dart'; // Add this import

class UserService {
  final _httService = Get.find<HttpService>();

  Future<StandardApiResponse<bool>> followTopics(List<String> topics, String primaryTopic) async {
    try {
      String token = await SharedPrefService.getString(Constants.storageBearerTokenKey) ?? "";

      final response = await _httService.post(
        Endpoints.followTopicsBulk,
        body: {
          "topics": topics.map((topic) => {"topic_id": topic, "set_interest_is_primary": topic == primaryTopic}).toList(),
        },
        headers: {"Authorization": "Bearer $token"},
      );

      final responseBody = response.body.toJson();

      if (responseBody.containsKey("success") && responseBody['success'] == true) {
        return StandardApiResponse<bool>.success(
          message: responseBody['message'] ?? 'Topics followed successfully',
          data: true,
        );
      } else {
        return StandardApiResponse<bool>.error(
          message: responseBody['message'] ?? 'Failed to follow topics',
          errors: responseBody['errors'],
          data: false,
        );
      }
    } catch (e) {
      return StandardApiResponse<bool>.error(
        message: 'Network error occurred while following topics: $e',
        data: false,
      );
    }
  }
}