import 'package:fiwe/src/models/topic.model.dart';
import 'package:fiwe/src/services/http_service.dart';
import 'package:fiwe/src/utils/endpoints.dart';
import 'package:fiwe/src/utils/extensions.dart';

class TopicService {
  final HttpService httpService = HttpService();

  Future<List<Topic>> getAllTopics() async {
    final response = await httpService.get(Endpoints.getAllTopics);
    final responseBody = response.body.toJson();
    if (responseBody.containsKey("success") && responseBody['success'] == true) {
      final List<dynamic> topicsData = responseBody['data']['topics'] ?? [];
      return topicsData.map((topicJson) => Topic.fromJson(topicJson)).toList();
    }
    return <Topic>[]; // Return empty list instead of null
  }

  Future<Map<String, List<Topic>>> getTopicsByCategories() async {
    final response = await httpService.get(Endpoints.getTopicsByCategories);
    final responseBody = response.body.toJson();

    if (responseBody.containsKey("success") && responseBody['success'] == true) {
      final List<dynamic> categoriesData = responseBody['data'] ?? [];
      final Map<String, List<Topic>> topicsByCategory = <String, List<Topic>>{};

      for (final categoryData in categoriesData) {
        if (categoryData is Map<String, dynamic>) {
          categoryData.forEach((categoryName, topicsData) {
            if (topicsData is List) {
              final List<Topic> topics = topicsData.map((topicJson) => Topic.fromJson(topicJson)).toList();
              topicsByCategory[categoryName] = topics;
            }
          });
        }
      }

      return topicsByCategory;
    }

    return <String, List<Topic>>{}; // Return empty map instead of null
  }
}
