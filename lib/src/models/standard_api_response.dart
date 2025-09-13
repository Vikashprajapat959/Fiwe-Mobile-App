/// Standard API response wrapper for consistent handling of API responses
///
/// All API responses follow a standardized format:
/// Success responses: { "success": true, "message": "Success message", "data": {...} }
/// Error responses: { "success": false, "message": "Error message", "errors": {...} }
class StandardApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final Map<String, dynamic>? errors;

  StandardApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });

  /// Create a StandardApiResponse from JSON for single object data
  factory StandardApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return StandardApiResponse<T>(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] != null ? fromJsonT(json['data'] as Map<String, dynamic>) : null,
      errors: json['errors'] as Map<String, dynamic>?,
    );
  }

  /// Create a successful response
  factory StandardApiResponse.success({
    required String message,
    T? data,
  }) {
    return StandardApiResponse<T>(
      success: true,
      message: message,
      data: data,
    );
  }

  /// Create an error response
  factory StandardApiResponse.error({
    required String message,
    Map<String, dynamic>? errors,
    T? data,
  }) {
    return StandardApiResponse<T>(
      success: false,
      message: message,
      errors: errors,
      data: data,
    );
  }
}