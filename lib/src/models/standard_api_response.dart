class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final Map<String, dynamic>? errors;
  final int? statusCode; // Added statusCode field

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
    this.statusCode, // Add to constructor
  });

  /// Create a StandardApiResponse from JSON for single object data
  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJsonT) {
    return ApiResponse<T>(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] != null ? fromJsonT(json['data'] as Map<String, dynamic>) : null,
      errors: json['errors'] as Map<String, dynamic>?,
      statusCode: json['statusCode'] as int?, // Parse statusCode from JSON
    );
  }

  /// Create a successful response
  factory ApiResponse.success({required String message, T? data, int? statusCode}) {
    return ApiResponse<T>(success: true, message: message, data: data, statusCode: statusCode);
  }

  /// Create an error response
  factory ApiResponse.error({required String message, Map<String, dynamic>? errors, T? data, int? statusCode}) {
    return ApiResponse<T>(success: false, message: message, errors: errors, data: data, statusCode: statusCode);
  }
}
