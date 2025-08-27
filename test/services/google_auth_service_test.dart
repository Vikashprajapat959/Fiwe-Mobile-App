import 'package:fiwe/src/services/google_auth_service.dart';
import 'package:fiwe/src/services/shared_pref_service.dart';
import 'package:fiwe/src/utils/constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('GoogleAuthService Persistence Tests', () {
    late GoogleAuthService authService;

    setUp(() async {
      // Initialize SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
      authService = GoogleAuthService();
    });

    tearDown(() async {
      // Clean up after each test
      await SharedPrefService.clear();
      authService.dispose();
    });

    test('hasStoredAuthData should return false when no data is stored', () async {
      final hasData = await authService.hasStoredAuthData();
      expect(hasData, false);
    });

    test('hasStoredAuthData should return true when auth data is stored', () async {
      // Simulate stored auth data
      await SharedPrefService.setString(Constants.storageLoginEmailKey, 'test@example.com');
      await SharedPrefService.setString(Constants.storageLoginTokenKey, 'mock_token');

      final hasData = await authService.hasStoredAuthData();
      expect(hasData, true);
    });

    test('hasStoredAuthData should return false when only partial data is stored', () async {
      // Store only email, no token
      await SharedPrefService.setString(Constants.storageLoginEmailKey, 'test@example.com');

      final hasData = await authService.hasStoredAuthData();
      expect(hasData, false);
    });

    test('SharedPrefService should store and retrieve data correctly', () async {
      const testEmail = 'test@example.com';
      const testToken = 'mock_token_123';
      const testUserId = 'user_123';
      const testUsername = 'Test User';

      // Store test data
      await SharedPrefService.setString(Constants.storageLoginEmailKey, testEmail);
      await SharedPrefService.setString(Constants.storageLoginTokenKey, testToken);
      await SharedPrefService.setString(Constants.storageLoginUserIdKey, testUserId);
      await SharedPrefService.setString(Constants.storageLoginUsernameKey, testUsername);

      // Retrieve and verify data
      final email = await SharedPrefService.getString(Constants.storageLoginEmailKey);
      final token = await SharedPrefService.getString(Constants.storageLoginTokenKey);
      final userId = await SharedPrefService.getString(Constants.storageLoginUserIdKey);
      final username = await SharedPrefService.getString(Constants.storageLoginUsernameKey);

      expect(email, testEmail);
      expect(token, testToken);
      expect(userId, testUserId);
      expect(username, testUsername);
    });

    test('SharedPrefService should clear data correctly', () async {
      // Store test data
      await SharedPrefService.setString(Constants.storageLoginEmailKey, 'test@example.com');
      await SharedPrefService.setString(Constants.storageLoginTokenKey, 'mock_token');

      // Verify data is stored
      expect(await SharedPrefService.getString(Constants.storageLoginEmailKey), isNotNull);
      expect(await SharedPrefService.getString(Constants.storageLoginTokenKey), isNotNull);

      // Clear specific keys
      await SharedPrefService.remove(Constants.storageLoginEmailKey);
      await SharedPrefService.remove(Constants.storageLoginTokenKey);

      // Verify data is cleared
      expect(await SharedPrefService.getString(Constants.storageLoginEmailKey), isNull);
      expect(await SharedPrefService.getString(Constants.storageLoginTokenKey), isNull);
    });

    test('GoogleAuthService should handle authentication state properly', () async {
      // Test initial state
      expect(authService.supportsAuthenticate, isA<bool>());

      // Test stream access
      expect(authService.userStream, isA<Stream>());
    });
  });
}
