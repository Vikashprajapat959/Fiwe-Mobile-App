import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class CrashlyticsService {
  static Future<void> initialize() async {
    if (kIsWeb) return;

    // Handle uncaught errors
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

    // Handle async errors
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  static void log(String message) {
    if (!kIsWeb && !kDebugMode) {
      FirebaseCrashlytics.instance.log(message);
    }
  }

  static void setCustomKey(String key, dynamic value) {
    if (!kIsWeb && !kDebugMode) {
      FirebaseCrashlytics.instance.setCustomKey(key, value);
    }
  }

  static void setUserIdentifier(String identifier) {
    if (!kIsWeb && !kDebugMode) {
      FirebaseCrashlytics.instance.setUserIdentifier(identifier);
    }
  }

  static void recordError(dynamic exception, StackTrace? stack, {String? reason}) {
    if (!kIsWeb && !kDebugMode) {
      FirebaseCrashlytics.instance.recordError(exception, stack, reason: reason);
    }
  }

  static void recordFlutterError(FlutterErrorDetails details) {
    if (!kIsWeb && !kDebugMode) {
      FirebaseCrashlytics.instance.recordFlutterError(details);
    }
  }

  static void recordDartError(Object error, StackTrace stackTrace) {
    if (!kIsWeb && !kDebugMode) {
      FirebaseCrashlytics.instance.recordError(error, stackTrace);
    }
  }
}
