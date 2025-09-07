import 'package:fiwe/src/services/http_service.dart';
import 'package:fiwe/src/services/shared_pref_service.dart';
import 'package:fiwe/src/utils/constants.dart';
import 'package:fiwe/src/utils/endpoints.dart';

class UserService {
  final _httService = HttpService();

  Future<bool> followTopics(List<String> topics, String primaryTopic) async {
    String token = await SharedPrefService.getString(Constants.storageBearerTokenKey) ?? "";

    final response = await _httService.post(
      Endpoints.followTopicsBulk,
      body: {
        "topics": topics.map((topic) => {"topic_id": topic, "set_interest_is_primary": topic == primaryTopic}).toList(),
      },
      headers: {"Authorization": "Bearer $token"},
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }
}
