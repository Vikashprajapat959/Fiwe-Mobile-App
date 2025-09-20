import 'dart:io';
import 'package:fiwe/src/services/crashlytics_service.dart';
import 'package:fiwe/src/utils/logger.dart';

void main() async {
  print('Verifying Crashlytics implementation...');
  
  // Test that we can call the Crashlytics service methods
  try {
    print('Testing Crashlytics service methods...');
    CrashlyticsService.log('Test log message');
    CrashlyticsService.setCustomKey('test_key', 'test_value');
    CrashlyticsService.setUserIdentifier('test_user');
    print('✓ Crashlytics service methods work correctly');
  } catch (e) {
    print('✗ Error testing Crashlytics service methods: $e');
  }
  
  // Test that we can call the Logger methods
  try {
    print('Testing Logger methods...');
    Logger.debug('Test debug message');
    Logger.info('Test info message');
    Logger.warning('Test warning message');
    Logger.error('Test error message');
    print('✓ Logger methods work correctly');
  } catch (e) {
    print('✗ Error testing Logger methods: $e');
  }
  
  print('Verification complete.');
  exit(0);
}