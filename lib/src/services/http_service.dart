import 'dart:convert';
import 'dart:developer' as developer;

import 'package:fiwe/src/services/shared_pref_service.dart';
import 'package:fiwe/src/utils/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../models/standard_api_response.dart';
import '../utils/exceptions.dart';

/// HTTP service for making API requests with error handling and logging
class HttpService extends GetxService {
  HttpService({
    this.baseUrl = 'https://fiwe.in/api',
    this.defaultHeaders = const <String, String>{'Content-Type': 'application/json', 'accept': 'application/json'},
    this.enableLogging = kDebugMode,
  });

  final String? baseUrl;
  final Map<String, String> defaultHeaders;
  final bool enableLogging;

  // instance
  static HttpService get instance => Get.find();

  /// Performs a DELETE request
  Future<ApiResponse<Map<String, dynamic>>> delete(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool isAuthorized = false,
  }) async {
    final uri = _buildUri(endpoint);
    final requestHeaders = await _buildHeaders(headers, isAuthorized);
    final requestBody = body != null ? jsonEncode(body) : null;

    _logRequest('DELETE', uri, headers: requestHeaders, body: requestBody);

    final stopwatch = Stopwatch()..start();

    try {
      final response = await http.delete(uri, headers: requestHeaders, body: requestBody);

      stopwatch.stop();

      _logResponse(response, stopwatch.elapsed);

      _handleError(response);
      return _parseApiResponse(response);
    } catch (e) {
      stopwatch.stop();

      if (e is Exception) {
        _logError(e, uri, stopwatch.elapsed);
      }

      return ApiResponse.error(message: e.toString());
    }
  }

  /// Performs a GET request
  Future<ApiResponse<Map<String, dynamic>>> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    bool isAuthorized = false,
    bool log = false,
  }) async {
    final uri = _buildUri(endpoint, queryParams);
    final requestHeaders = await _buildHeaders(headers, isAuthorized);

    if (log) {
      _logRequest('GET', uri, headers: requestHeaders);
    }

    final stopwatch = Stopwatch()..start();

    try {
      final response = await http.get(uri, headers: requestHeaders);

      stopwatch.stop();

      if (log) {
        _logResponse(response, stopwatch.elapsed);
      }

      _handleError(response);
      return _parseApiResponse(response);
    } catch (e) {
      stopwatch.stop();

      if (e is Exception) {
        _logError(e, uri, stopwatch.elapsed);
      }

      return ApiResponse.error(message: e.toString());
    }
  }

  /// Performs a POST request
  Future<ApiResponse<Map<String, dynamic>>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool isAuthorized = false,
    bool log = false,
  }) async {
    final uri = _buildUri(endpoint);
    final requestHeaders = await _buildHeaders(headers, isAuthorized);
    final requestBody = body != null ? jsonEncode(body) : null;

    _logRequest('POST', uri, headers: requestHeaders, body: requestBody);

    final stopwatch = Stopwatch()..start();

    try {
      final response = await http.post(uri, headers: requestHeaders, body: requestBody);

      stopwatch.stop();

      if (log) {
        _logResponse(response, stopwatch.elapsed);
      }
      _handleError(response);
      return _parseApiResponse(response);
    } catch (e) {
      stopwatch.stop();

      if (e is Exception) {
        _logError(e, uri, stopwatch.elapsed);
      }

      return ApiResponse.error(message: e.toString());
    }
  }

  /// Performs a PUT request
  Future<ApiResponse<Map<String, dynamic>>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool isAuthorized = false,
  }) async {
    final uri = _buildUri(endpoint);
    final requestHeaders = await _buildHeaders(headers, isAuthorized);
    final requestBody = body != null ? jsonEncode(body) : null;

    _logRequest('PUT', uri, headers: requestHeaders, body: requestBody);

    final stopwatch = Stopwatch()..start();

    try {
      final response = await http.put(uri, headers: requestHeaders, body: requestBody);

      stopwatch.stop();

      _logResponse(response, stopwatch.elapsed);

      _handleError(response);
      return _parseApiResponse(response);
    } catch (e) {
      stopwatch.stop();

      if (e is Exception) {
        _logError(e, uri, stopwatch.elapsed);
      }

      return ApiResponse.error(message: e.toString());
    }
  }

  /// Builds headers for the request
  Future<Map<String, String>> _buildHeaders(Map<String, String>? headers, bool isAuthorized) async {
    final requestHeaders = <String, String>{...defaultHeaders, ...?headers};

    if (isAuthorized) {
      final token = await _getBearerToken();
      if (token != null && token.isNotEmpty) {
        requestHeaders['Authorization'] = 'Bearer $token';
      }
    }

    return requestHeaders;
  }

  /// Builds URI from endpoint and query parameters
  Uri _buildUri(String endpoint, [Map<String, dynamic>? queryParams]) {
    return Uri.parse('$baseUrl$endpoint').replace(queryParameters: queryParams);
  }

  /// Gets the bearer token from shared preferences
  Future<String?> _getBearerToken() async {
    return SharedPrefService.getString(Constants.storageBearerTokenKey);
  }

  /// Handles HTTP errors and throws appropriate exceptions
  void _handleError(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;

    final message = 'Request failed: ${response.statusCode} ${response.reasonPhrase}';
    final uri = response.request?.url;

    switch (response.statusCode) {
      case 400:
        throw BadRequestException(message, uri: uri);
      case 401:
        throw UnauthorizedException(message, uri: uri);
      case 403:
        throw ForbiddenException(message, uri: uri);
      case 404:
        throw NotFoundException(message, uri: uri);
      case 409:
        throw ConflictException(message, uri: uri);
      case 500:
        throw ServerException(message, uri: uri);
      default:
        throw BaseHttpException(message, uri: uri, statusCode: response.statusCode);
    }
  }

  /// Logs error information
  void _logError(Exception error, Uri uri, Duration duration) {
    if (!enableLogging) return;

    final timestamp = DateTime.now().toIso8601String();
    developer.log('\n💥 ═══════════════════════════════════════════════════════════════', name: 'HTTP_ERROR');
    developer.log('📅 $timestamp', name: 'HTTP_ERROR');
    developer.log('🚨 Error occurred for: $uri', name: 'HTTP_ERROR');
    developer.log('⏱️  Duration: ${duration.inMilliseconds}ms', name: 'HTTP_ERROR');
    developer.log('💢 Error: $error', name: 'HTTP_ERROR');
    developer.log('═══════════════════════════════════════════════════════════════\n', name: 'HTTP_ERROR');
  }

  /// Logs request information
  void _logRequest(String method, Uri uri, {Map<String, String>? headers, String? body}) {
    if (!enableLogging) return;

    final timestamp = DateTime.now().toIso8601String();
    developer.log('\n🚀 ═══════════════════════════════════════════════════════════════', name: 'HTTP_REQUEST');
    developer.log('📅 $timestamp', name: 'HTTP_REQUEST');
    developer.log('🔥 $method ${uri.toString()}', name: 'HTTP_REQUEST');

    if (headers != null && headers.isNotEmpty) {
      developer.log('📋 Headers:', name: 'HTTP_REQUEST');
      headers.forEach((String key, String value) {
        developer.log('   $key: $value', name: 'HTTP_REQUEST');
      });
    }

    if (body != null && body.isNotEmpty) {
      developer.log('📦 Body:', name: 'HTTP_REQUEST');
      try {
        final jsonObject = json.decode(body);
        const encoder = JsonEncoder.withIndent('  ');
        final prettyJson = encoder.convert(jsonObject);
        developer.log(prettyJson, name: 'HTTP_REQUEST');
      } catch (e) {
        developer.log(body, name: 'HTTP_REQUEST');
      }
    }

    developer.log('═══════════════════════════════════════════════════════════════\n', name: 'HTTP_REQUEST');
  }

  /// Logs response information
  void _logResponse(http.Response response, Duration duration) {
    if (!enableLogging) return;

    final timestamp = DateTime.now().toIso8601String();
    final statusCode = response.statusCode;
    final isSuccess = statusCode >= 200 && statusCode < 300;
    final statusEmoji = isSuccess ? '✅' : '❌';

    developer.log(
      '\n$statusEmoji ═══════════════════════════════════════════════════════════════',
      name: 'HTTP_RESPONSE',
    );
    developer.log('📅 $timestamp', name: 'HTTP_RESPONSE');
    developer.log('⚡ ${response.request?.method} ${response.request?.url}', name: 'HTTP_RESPONSE');
    developer.log('🎯 Status: $statusCode ${response.reasonPhrase ?? ""}', name: 'HTTP_RESPONSE');
    developer.log('⏱️  Duration: ${duration.inMilliseconds}ms', name: 'HTTP_RESPONSE');

    if (response.headers.isNotEmpty) {
      developer.log('📋 Response Headers:', name: 'HTTP_RESPONSE');
      response.headers.forEach((String key, String value) {
        developer.log('   $key: $value', name: 'HTTP_RESPONSE');
      });
    }

    if (response.body.isNotEmpty) {
      developer.log('📦 Response Body:', name: 'HTTP_RESPONSE');
      try {
        final jsonObject = json.decode(response.body);
        const encoder = JsonEncoder.withIndent('  ');
        final prettyJson = encoder.convert(jsonObject);
        developer.log(prettyJson, name: 'HTTP_RESPONSE');
      } catch (e) {
        final body = response.body.length > 1000
            ? '${response.body.substring(0, 1000)}...\n[TRUNCATED - ${response.body.length} total characters]'
            : response.body;
        developer.log(body, name: 'HTTP_RESPONSE');
      }
    }

    developer.log('═══════════════════════════════════════════════════════════════\n', name: 'HTTP_RESPONSE');
  }

  /// Parses API response into standardized format
  ApiResponse<Map<String, dynamic>> _parseApiResponse(http.Response response) {
    try {
      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseBody.containsKey('success') && responseBody['success'] == true) {
        if (responseBody['data'] is List) {
          return ApiResponse.success(
            message: responseBody['message'] as String? ?? 'Request successful',
            data: {'items': responseBody['data']},
            statusCode: response.statusCode,
          );
        }
        return ApiResponse.success(
          message: responseBody['message'] as String? ?? 'Request successful',
          data: responseBody['data'] as Map<String, dynamic>?,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse.error(
          message: responseBody['message'] as String? ?? 'Request failed',
          errors: responseBody['errors'] as Map<String, dynamic>?,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(message: 'Failed to parse response: $e');
    }
  }
}
