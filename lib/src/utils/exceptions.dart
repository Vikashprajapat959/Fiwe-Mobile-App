/// Base exception class for all HTTP-related errors
class BaseHttpException implements Exception {
  const BaseHttpException(
    this.message, {
    this.prefix,
    this.statusCode = 500,
    this.uri,
  });

  final String message;
  final String? prefix;
  final int statusCode;
  final Uri? uri;

  @override
  String toString() {
    final uriString = uri != null ? ', uri: $uri' : '';
    if (prefix != null) {
      return '$prefix: $message (status code: $statusCode$uriString)';
    }
    return '$message (status code: $statusCode$uriString)';
  }
}

/// Exception thrown when the request is malformed (400)
class BadRequestException extends BaseHttpException {
  const BadRequestException(super.message, {super.uri})
      : super(statusCode: 400);

  @override
  String toString() {
    return 'BadRequestException: $message (status code: $statusCode)';
  }
}

/// Exception thrown when authentication fails (401)
class UnauthorizedException extends BaseHttpException {
  const UnauthorizedException(super.message, {super.uri})
      : super(statusCode: 401);

  @override
  String toString() {
    return 'UnauthorizedException: $message (status code: $statusCode)';
  }
}

/// Exception thrown when access is forbidden (403)
class ForbiddenException extends BaseHttpException {
  const ForbiddenException(super.message, {super.uri})
      : super(statusCode: 403);

  @override
  String toString() {
    return 'ForbiddenException: $message (status code: $statusCode)';
  }
}

/// Exception thrown when resource is not found (404)
class NotFoundException extends BaseHttpException {
  const NotFoundException(super.message, {super.uri})
      : super(statusCode: 404);

  @override
  String toString() {
    return 'NotFoundException: $message (status code: $statusCode)';
  }
}

/// Exception thrown when there's a conflict with the current state (409)
class ConflictException extends BaseHttpException {
  const ConflictException(super.message, {super.uri})
      : super(statusCode: 409);

  @override
  String toString() {
    return 'ConflictException: $message (status code: $statusCode)';
  }
}

/// Exception thrown when server encounters an error (500)
class ServerException extends BaseHttpException {
  const ServerException(super.message, {super.uri})
      : super(statusCode: 500);

  @override
  String toString() {
    return 'ServerException: $message (status code: $statusCode)';
  }
}

/// Exception thrown when a network timeout occurs
class TimeoutException extends BaseHttpException {
  const TimeoutException(super.message, {super.uri})
      : super(statusCode: 408);

  @override
  String toString() {
    return 'TimeoutException: $message (status code: $statusCode)';
  }
}

/// Exception thrown when there's no internet connection
class NetworkException extends BaseHttpException {
  const NetworkException(super.message, {super.uri})
      : super(statusCode: 0);

  @override
  String toString() {
    return 'NetworkException: $message';
  }
}
