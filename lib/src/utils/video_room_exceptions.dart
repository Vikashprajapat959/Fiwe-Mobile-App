/// Exception thrown when trying to join a room that is full
class RoomFullException implements Exception {
  RoomFullException(this.message, {this.roomId});
  final String message;
  final String? roomId;

  @override
  String toString() {
    return 'RoomFullException: $message${roomId != null ? ' (room ID: $roomId)' : ''}';
  }
}

/// Exception thrown when room token has expired
class TokenExpiredException implements Exception {
  TokenExpiredException(this.message, {this.roomId});
  final String message;
  final String? roomId;

  @override
  String toString() {
    return 'TokenExpiredException: $message${roomId != null ? ' (room ID: $roomId)' : ''}';
  }
}

/// Exception thrown when network connection is lost during video room session
class NetworkDisconnectionException implements Exception {
  NetworkDisconnectionException(this.message, {this.roomId});
  final String message;
  final String? roomId;

  @override
  String toString() {
    return 'NetworkDisconnectionException: $message${roomId != null ? ' (room ID: $roomId)' : ''}';
  }
}

/// Exception thrown when camera or microphone permissions are denied
class MediaPermissionDeniedException implements Exception {
  MediaPermissionDeniedException(this.message, this.deniedPermissions);
  final String message;
  final List<String> deniedPermissions;

  @override
  String toString() {
    return 'MediaPermissionDeniedException: $message (denied permissions: ${deniedPermissions.join(', ')})';
  }
}
