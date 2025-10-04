import 'package:fiwe/src/models/standard_api_response.dart';
import 'package:fiwe/src/services/http_service.dart';
import 'package:fiwe/src/utils/endpoints.dart';

/// Repository for managing commune data.
///
/// This repository handles fetching commune data from the API service
/// and provides a clean interface for the application to access commune information.
class CommuneRepository {
  factory CommuneRepository() => _instance;
  CommuneRepository._internal();
  final HttpService _httpService = HttpService.instance;

  // instance
  static final CommuneRepository _instance = CommuneRepository._internal();

  static CommuneRepository get instance => _instance;
  // send commune request
  Future<ApiResponse<Map<String, dynamic>>> sendRequest(String userId) async {
    final response = await _httpService.post(
      Endpoints.sendCommuneRequest,
      body: {'to_user_id': userId},
      isAuthorized: true,
    );
    return response;
  }

  // get all sent commune requests
  Future<ApiResponse<Map<String, dynamic>>> getAllSentRequests() async {
    final response = await _httpService.get(Endpoints.communeRequestsSent, isAuthorized: true);
    return response;
  }

  Future<ApiResponse<Map<String, dynamic>>> cancelCommuneRequest(String requestId) async {
    final response = await _httpService.post(
      '${Endpoints.sendCommuneRequest}$requestId${Endpoints.rejectCommune}',
      isAuthorized: true,
    );
    return response;
  }
}
