import 'dart:convert';

import 'package:http/http.dart' as http;

import '../utils/exceptions.dart';

class HttpService {
  final String baseUrl;
  final Map<String, String> defaultHeaders;

  HttpService({
    required this.baseUrl,
    this.defaultHeaders = const {'Content-Type': 'application/json'},
  });

  Future<http.Response> delete(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(endpoint);
    final response = await http.delete(
      uri,
      headers: {...defaultHeaders, ...?headers},
      body: body != null ? jsonEncode(body) : null,
    );
    _handleError(response);
    return response;
  }

  Future<http.Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(endpoint, queryParams);
    final response = await http.get(
      uri,
      headers: {...defaultHeaders, ...?headers},
    );
    _handleError(response);
    return response;
  }

  Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(endpoint);
    final response = await http.post(
      uri,
      headers: {...defaultHeaders, ...?headers},
      body: body != null ? jsonEncode(body) : null,
    );
    _handleError(response);
    return response;
  }

  Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(endpoint);
    final response = await http.put(
      uri,
      headers: {...defaultHeaders, ...?headers},
      body: body != null ? jsonEncode(body) : null,
    );
    _handleError(response);
    return response;
  }

  Uri _buildUri(String endpoint, [Map<String, dynamic>? queryParams]) {
    return Uri.parse('$baseUrl$endpoint').replace(queryParameters: queryParams);
  }

  void _handleError(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;

    final message =
        'Request failed: ${response.statusCode} ${response.reasonPhrase}';
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
        throw BaseHttpException(
          message,
          uri: uri,
          statusCode: response.statusCode,
        );
    }
  }
}
