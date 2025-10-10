// ignore_for_file: library_private_types_in_public_api

import 'dart:developer';

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

  //getAllCommunes
  Future<ApiResponse<List<CommuneSummary>>> getAllCommunes() async {
    try {
      final response = await _httpService.get(Endpoints.communes, isAuthorized: true, log: true);

      if (response.data != null && response.data!['communes'] != null) {
        return ApiResponse.success(
          data: List.from(response.data!['communes']).map((e) => CommuneSummary.fromJson(e)).toList(),
          message: response.message,
        );
      } else {
        return ApiResponse.error(message: response.message);
      }
    } on Exception catch (e) {
      log('Error in getting communes: $e');
      rethrow;
    }
  }

  //getAllCommuneRequests
  Future<ApiResponse<List<CommuneSummary>>> getAllCommuneRequests() async {
    try {
      final response = await _httpService.get(Endpoints.communeRequestsReceived, isAuthorized: true, log: true);
      if (response.data != null && response.data!['requests'] != null) {
        return ApiResponse.success(
          data: List.from(response.data!['requests']).map((e) => CommuneSummary.fromJson(e)).toList(),
          message: response.message,
        );
      } else {
        return ApiResponse.error(message: response.message);
      }
    } on Exception catch (e) {
      log('Error in getting commune requests: $e');
      rethrow;
    }
  }
}

class CommuneSummary {
  CommuneSummary({this.id, this.name, this.email, this.imageBytes, this.avgRating, this.primaryInterest});

  factory CommuneSummary.fromJson(Map<String, dynamic> json) {
    return CommuneSummary(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      imageBytes: json['profile_image_base64'] ?? '',
      avgRating: json['average_rating'],

      primaryInterest: json['primary_topic'] == null ? null : _Topic.fromJson(json['primary_topic']),
    );
  }
  final String? id;
  final String? name;
  final String? email;
  final String? imageBytes;
  final double? avgRating;
  final _Topic? primaryInterest;
}

class _Topic {
  _Topic({required this.id, required this.title, required this.description});

  factory _Topic.fromJson(Map<String, dynamic> json) {
    return _Topic(id: json['id'], title: json['title'], description: json['description']);
  }
  final String id;
  final String title;
  final String description;
}
