/// Exception thrown when the request is malformed (400)
class BadRequestException extends BaseHttpException {
  BadRequestException(String message, {Uri? uri})
    : super(message, uri: uri, statusCode: 400);

  @override
  String toString() {
    return 'BadRequestException: $message (status code: $statusCode)';
  }
}

/// Base exception class for all HTTP-related errors
class BaseHttpException implements Exception {
  final String message;
  final String? prefix;
  final int statusCode;
  final Uri? uri;

  BaseHttpException(
    this.message, {
    this.prefix,
    this.statusCode = 500,
    this.uri,
  });

  @override
  String toString() {
    final uriString = uri != null ? ', uri: $uri' : '';
    if (prefix != null) {
      return '$prefix: $message (status code: $statusCode$uriString)';
    }
    return '$message (status code: $statusCode$uriString)';
  }
}

/// Exception thrown when there's a conflict with the current state (409)
class ConflictException extends BaseHttpException {
  ConflictException(String message, {Uri? uri})
    : super(message, uri: uri, statusCode: 409);

  @override
  String toString() {
    return 'ConflictException: $message (status code: $statusCode)';
  }
}

/// Exception thrown when access is forbidden (403)
class ForbiddenException extends BaseHttpException {
  ForbiddenException(String message, {Uri? uri})
    : super(message, uri: uri, statusCode: 403);

  @override
  String toString() {
    return 'ForbiddenException: $message (status code: $statusCode)';
  }
}

/// Exception thrown when resource is not found (404)
class NotFoundException extends BaseHttpException {
  NotFoundException(String message, {Uri? uri})
    : super(message, uri: uri, statusCode: 404);

  @override
  String toString() {
    return 'NotFoundException: $message (status code: $statusCode)';
  }
}

/// Exception thrown when server encounters an error (500)
class ServerException extends BaseHttpException {
  ServerException(String message, {Uri? uri})
    : super(message, uri: uri, statusCode: 500);

  @override
  String toString() {
    return 'ServerException: $message (status code: $statusCode)';
  }
}

/// Exception thrown when authentication fails (401)
class UnauthorizedException extends BaseHttpException {
  UnauthorizedException(String message, {Uri? uri})
    : super(message, uri: uri, statusCode: 401);

  @override
  String toString() {
    return 'UnauthorizedException: $message (status code: $statusCode)';
  }
}
