import 'dart:developer' as developer;

import 'package:fiwe/src/services/crashlytics_service.dart';
import 'package:flutter/foundation.dart';

/// Logger utility following Flutter AI rules for structured logging
class Logger {
  /// Logs debug messages (only in debug mode)
  static void debug(String message, {String? name}) {
    if (kDebugMode) {
      developer.log(
        message,
        name: name ?? 'Logger',
        level: 500, // DEBUG level
      );
    }
    CrashlyticsService.log('DEBUG: $message');
  }

  /// Logs informational messages
  static void info(String message, {String? name}) {
    developer.log(
      message,
      name: name ?? 'Logger',
      level: 800, // INFO level
    );
    CrashlyticsService.log('INFO: $message');
  }

  /// Logs warning messages
  static void warning(String message, {String? name}) {
    developer.log(
      message,
      name: name ?? 'Logger',
      level: 900, // WARNING level
    );
    CrashlyticsService.log('WARNING: $message');
  }

  /// Logs error messages with optional error object and stack trace
  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String? name,
  }) {
    developer.log(
      message,
      name: name ?? 'Logger',
      level: 1000, // SEVERE level
      error: error,
      stackTrace: stackTrace,
    );
    
    CrashlyticsService.log('ERROR: $message');
    
    if (error != null) {
      CrashlyticsService.recordError(error, stackTrace, reason: message);
    }
  }

  /// Logs structured network requests
  static void network(
    String method,
    String url, {
    int? statusCode,
    Duration? duration,
    String? name,
  }) {
    final message = '$method $url'
        '${statusCode != null ? ' [$statusCode]' : ''}'
        '${duration != null ? ' (${duration.inMilliseconds}ms)' : ''}';
    
    developer.log(
      message,
      name: name ?? 'Network',
      level: 800,
    );
  }

  /// Logs performance metrics
  static void performance(
    String operation,
    Duration duration, {
    Map<String, dynamic>? metadata,
    String? name,
  }) {
    final message = '$operation completed in ${duration.inMilliseconds}ms'
        '${metadata != null ? ' - $metadata' : ''}';
    
    developer.log(
      message,
      name: name ?? 'Performance',
      level: 800,
    );
  }
}
