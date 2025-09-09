/// Exception thrown when trying to join a room that is full
class RoomFullException implements Exception {
  final String message;
  final String? roomId;

  RoomFullException(this.message, {this.roomId});

  @override
  String toString() {
    return 'RoomFullException: $message${roomId != null ? ' (room ID: $roomId)' : ''}';
  }
}

/// Exception thrown when room token has expired
class TokenExpiredException implements Exception {
  final String message;
  final String? roomId;

  TokenExpiredException(this.message, {this.roomId});

  @override
  String toString() {
    return 'TokenExpiredException: $message${roomId != null ? ' (room ID: $roomId)' : ''}';
  }
}

/// Exception thrown when network connection is lost during video room session
class NetworkDisconnectionException implements Exception {
  final String message;
  final String? roomId;

  NetworkDisconnectionException(this.message, {this.roomId});

  @override
  String toString() {
    return 'NetworkDisconnectionException: $message${roomId != null ? ' (room ID: $roomId)' : ''}';
  }
}

/// Exception thrown when camera or microphone permissions are denied
class MediaPermissionDeniedException implements Exception {
  final String message;
  final List<String> deniedPermissions;

  MediaPermissionDeniedException(this.message, this.deniedPermissions);

  @override
  String toString() {
    return 'MediaPermissionDeniedException: $message (denied permissions: ${deniedPermissions.join(', ')})';
  }
}