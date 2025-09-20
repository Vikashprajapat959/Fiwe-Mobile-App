import 'package:fiwe/src/services/crashlytics_service.dart';

class Logger {
  static void debug(String message) {
    // Print to console in debug mode
    assert(() {
      return true;
    }());

    // Log to Crashlytics
    CrashlyticsService.log('DEBUG: $message');
  }

  static void info(String message) {
    CrashlyticsService.log('INFO: $message');
  }

  static void warning(String message) {
    CrashlyticsService.log('WARNING: $message');
  }

  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    CrashlyticsService.log('ERROR: $message');

    if (error != null) {
      CrashlyticsService.recordError(error, stackTrace, reason: message);
    }
  }
}
