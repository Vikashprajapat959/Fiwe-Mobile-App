import 'dart:developer' as dev;
import 'package:fiwe/src/models/standard_api_response.dart';
import 'package:fiwe/src/services/http_service.dart';
import 'package:fiwe/src/utils/endpoints.dart';
import 'package:get/get.dart';

class RatingRepository extends GetxService {
  static RatingRepository get instance => Get.find<RatingRepository>();

  final HttpService _httpService = Get.find<HttpService>();

  /// Submit participant ratings to backend
  Future<bool> submitRatings(List<Map<String, dynamic>> ratings) async {
    try {
      dev.log('Submitting ${ratings.length} ratings', name: 'RatingRepository');

      final response = await _httpService.post(
        Endpoints.submitRatings,
        body: {'ratings': ratings},
        isAuthorized: true,
      );

      if (response.success) {
        dev.log('Ratings submitted successfully', name: 'RatingRepository');
        return true;
      } else {
        dev.log('Failed to submit ratings: ${response.message}', name: 'RatingRepository');
        return false;
      }
    } catch (e) {
      dev.log('Error submitting ratings: $e', name: 'RatingRepository');
      return false;
    }
  }

  /// Validate rating data before submission
  bool validateRatingData(Map<String, dynamic> rating) {
    return rating.containsKey('rated_user_id') &&
           rating.containsKey('room_participation_id') &&
           rating.containsKey('rating_score') &&
           rating['rating_score'] is int &&
           rating['rating_score'] >= 1 &&
           rating['rating_score'] <= 5;
  }
}