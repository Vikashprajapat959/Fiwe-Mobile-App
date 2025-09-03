import 'package:fiwe/src/models/topic.model.dart';
import 'package:fiwe/src/services/http_service.dart';
import 'package:fiwe/src/utils/endpoints.dart';
import 'package:fiwe/src/utils/extensions.dart';

class TopicService {
  final HttpService httpService = HttpService();

  Future<List<Topic>> getAllTopics() async {
    final response = await httpService.get(Endpoints.getAllTopics);
    final responseBody = response.body.toJson();
    if (responseBody.containsKey("sucess") && responseBody['success'] == true) {
      final List<dynamic> topicsData = responseBody['data'] ?? [];
      return topicsData.map((topicJson) => Topic.fromJson(topicJson)).toList();
    }
    return <Topic>[]; // Return empty list instead of null
  }
}
