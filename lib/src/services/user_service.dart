import 'package:fiwe/src/services/http_service.dart';
import 'package:fiwe/src/services/shared_pref_service.dart';
import 'package:fiwe/src/utils/constants.dart';
import 'package:fiwe/src/utils/endpoints.dart';

class UserService {
  final httService = HttpService();

  Future<bool> followTopics(List<String> topics) async {
    String token = await SharedPrefService.getString(Constants.storageBearerTokenKey) ?? "";

    final response = await httService.post(
      Endpoints.followTopicsBulk,
      body: {"topics": topics},
      headers: {"Authorization": "Bearer $token"},
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }
}
