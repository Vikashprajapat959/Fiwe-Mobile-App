/// Standard API response model for consistent API handling
class ApiResponse<T> {
  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
    this.statusCode,
  });

  /// Creates an ApiResponse from JSON for single object data
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] != null
          ? fromJsonT(json['data'] as Map<String, dynamic>)
          : null,
      errors: json['errors'] as Map<String, dynamic>?,
      statusCode: json['statusCode'] as int?,
    );
  }

  /// Creates a successful response
  factory ApiResponse.success({
    required String message,
    T? data,
    int? statusCode,
  }) {
    return ApiResponse<T>(
      success: true,
      message: message,
      data: data,
      statusCode: statusCode,
    );
  }

  /// Creates an error response
  factory ApiResponse.error({
    required String message,
    Map<String, dynamic>? errors,
    T? data,
    int? statusCode,
  }) {
    return ApiResponse<T>(
      success: false,
      message: message,
      errors: errors,
      data: data,
      statusCode: statusCode,
    );
  }

  final bool success;
  final String message;
  final T? data;
  final Map<String, dynamic>? errors;
  final int? statusCode;

  /// Checks if the response is successful
  bool get isSuccess => success;

  /// Checks if the response is an error
  bool get isError => !success;

  /// Checks if the response has data
  bool get hasData => data != null;

  /// Checks if the response has errors
  bool get hasErrors => errors != null && errors!.isNotEmpty;

  @override
  String toString() {
    return 'ApiResponse(success: $success, message: $message, '
        'statusCode: $statusCode, hasData: $hasData, hasErrors: $hasErrors)';
  }
}
