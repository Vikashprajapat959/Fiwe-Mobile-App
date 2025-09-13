import 'package:fiwe/src/models/topic.model.dart';
import 'package:fiwe/src/services/http_service.dart';
import 'package:fiwe/src/utils/endpoints.dart';
import 'package:fiwe/src/utils/extensions.dart';
import 'package:get/get.dart';
import 'package:fiwe/src/models/standard_api_response.dart'; // Add this import

class TopicService extends GetxService {
  final HttpService _httpService = Get.find<HttpService>();

  Future<StandardApiResponse<List<Topic>>> getAllTopics() async {
    try {
      final response = await _httpService.get(Endpoints.getAllTopics);
      final responseBody = response.body.toJson();
      
      if (responseBody.containsKey("success") && responseBody['success'] == true) {
        final List<dynamic> topicsData = responseBody['data']['topics'] ?? [];
        final topics = topicsData.map((topicJson) => Topic.fromJson(topicJson)).toList();

        return StandardApiResponse<List<Topic>>.success(
          message: responseBody['message'] ?? 'Topics retrieved successfully',
          data: topics,
        );
      } else {
        return StandardApiResponse<List<Topic>>.error(
          message: responseBody['message'] ?? 'Failed to retrieve topics',
          errors: responseBody['errors'],
        );
      }
    } catch (e) {
      return StandardApiResponse<List<Topic>>.error(
        message: 'Network error occurred while fetching topics: $e',
      );
    }
  }

  Future<StandardApiResponse<Map<String, List<Topic>>>> getTopicsByCategories() async {
    try {
      final response = await _httpService.get(Endpoints.getTopicsByCategories);
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

        return StandardApiResponse<Map<String, List<Topic>>>.success(
          message: responseBody['message'] ?? 'Topics by categories retrieved successfully',
          data: topicsByCategory,
        );
      } else {
        return StandardApiResponse<Map<String, List<Topic>>>.error(
          message: responseBody['message'] ?? 'Failed to retrieve topics by categories',
          errors: responseBody['errors'],
        );
      }
    } catch (e) {
      return StandardApiResponse<Map<String, List<Topic>>>.error(
        message: 'Network error occurred while fetching topics by categories: $e',
      );
    }
  }
}