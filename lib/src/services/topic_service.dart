import 'package:fiwe/src/models/standard_api_response.dart'; // Add this import
import 'package:fiwe/src/models/topic.model.dart';
import 'package:fiwe/src/services/http_service.dart';
import 'package:fiwe/src/utils/endpoints.dart';
import 'package:get/get.dart';

class TopicService extends GetxService {
  final HttpService _httpService = Get.find<HttpService>();

  Future<ApiResponse<List<Topic>>> getAllTopics() async {
    try {
      final response = await _httpService.get(Endpoints.getAllTopics, log: false);
      final responseBody = response.data;

      if (response.success) {
        final List<dynamic> topicsData = responseBody!['topics'] ?? [];
        final topics = topicsData.map((topicJson) => Topic.fromJson(topicJson)).toList();

        return ApiResponse<List<Topic>>.success(
          message: responseBody['message'] ?? 'Topics retrieved successfully',
          data: topics,
        );
      } else {
        return ApiResponse<List<Topic>>.error(
          message: responseBody?['message'] ?? 'Failed to retrieve topics',
          errors: responseBody?['errors'],
        );
      }
    } catch (e) {
      return ApiResponse<List<Topic>>.error(message: 'Network error occurred while fetching topics: $e');
    }
  }

  Future<ApiResponse<Map<String, List<Topic>>>> getTopicsByCategories() async {
    try {
      final response = await _httpService.get(Endpoints.getTopicsByCategories);
      final responseBody = response.data;

      if (response.success) {
        final List<dynamic> categoriesData = responseBody?['data'] ?? [];
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

        return ApiResponse<Map<String, List<Topic>>>.success(
          message: responseBody?['message'] ?? 'Topics by categories retrieved successfully',
          data: topicsByCategory,
        );
      } else {
        return ApiResponse<Map<String, List<Topic>>>.error(
          message: responseBody?['message'] ?? 'Failed to retrieve topics by categories',
          errors: responseBody?['errors'],
        );
      }
    } catch (e) {
      return ApiResponse<Map<String, List<Topic>>>.error(
        message: 'Network error occurred while fetching topics by categories: $e',
      );
    }
  }
}
