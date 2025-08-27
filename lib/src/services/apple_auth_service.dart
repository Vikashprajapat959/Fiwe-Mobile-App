import 'dart:async';

import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../utils/constants.dart';
import 'shared_pref_service.dart';

/// Service for managing Apple Sign-In authentication
class AppleAuthService {
  /// Check if Apple Sign-In is available on the current platform
  static Future<bool> get isAvailable async {
    try {
      return await SignInWithApple.isAvailable();
    } catch (e) {
      return false;
    }
  }

  // Private constructor to prevent direct instantiation
  AppleAuthService._();

  /// Check if user has stored Apple authentication data
  static Future<bool> hasStoredAuthData() async {
    try {
      final email = await SharedPrefService.getString(Constants.loginEmailKey);
      final appleUserId = await SharedPrefService.getString(Constants.loginUserIdKey);
      return email != null && appleUserId != null;
    } catch (e) {
      return false;
    }
  }

  /// Perform Apple Sign-In
  static Future<AuthorizationCredentialAppleID?> signIn() async {
    try {
      // Check if Apple Sign-In is available
      if (!await isAvailable) {
        throw Exception('Apple Sign-In is not available on this device');
      }

      // Request authorization
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId: 'your.app.bundle.id', // Replace with your bundle ID
          redirectUri: Uri.parse('https://your-app.com/auth/apple/callback'), // Replace with your redirect URI
        ),
      );

      // Save authentication data
      await _saveAuthData(credential);

      return credential;
    } catch (e) {
      // Handle specific Apple Sign-In errors
      if (e is SignInWithAppleAuthorizationException) {
        switch (e.code) {
          case AuthorizationErrorCode.canceled:
            throw Exception('Apple Sign-In was cancelled by user');
          case AuthorizationErrorCode.failed:
            throw Exception('Apple Sign-In failed');
          case AuthorizationErrorCode.invalidResponse:
            throw Exception('Invalid response from Apple Sign-In');
          case AuthorizationErrorCode.notHandled:
            throw Exception('Apple Sign-In not handled');
          case AuthorizationErrorCode.notInteractive:
            throw Exception('Apple Sign-In not interactive');
          case AuthorizationErrorCode.unknown:
            throw Exception('Unknown Apple Sign-In error');
        }
      }

      rethrow;
    }
  }

  /// Clear Apple authentication data
  static Future<void> signOut() async {
    try {
      await _clearAuthData();
    } catch (e) {
      // Even if clearing fails, don't throw to prevent blocking logout
    }
  }

  /// Clear authentication data from SharedPreferences
  static Future<void> _clearAuthData() async {
    try {
      await SharedPrefService.remove(Constants.loginEmailKey);
      await SharedPrefService.remove(Constants.loginUserIdKey);
      await SharedPrefService.remove(Constants.loginUsernameKey);
      await SharedPrefService.remove(Constants.loginTokenKey);
    } catch (e) {
      // Log error but don't throw - this is cleanup operation
    }
  }

  /// Save Apple authentication data to SharedPreferences
  static Future<void> _saveAuthData(AuthorizationCredentialAppleID credential) async {
    try {
      // Save email if available
      if (credential.email != null) {
        await SharedPrefService.setString(Constants.loginEmailKey, credential.email!);
      }

      // Save user identifier (this should always be available)
      if (credential.userIdentifier != null && credential.userIdentifier!.isNotEmpty) {
        await SharedPrefService.setString(Constants.loginUserIdKey, credential.userIdentifier!);
      }

      // Save display name if available
      final fullName = credential.givenName != null && credential.familyName != null
          ? '${credential.givenName} ${credential.familyName}'
          : credential.givenName ?? credential.familyName ?? '';

      if (fullName.isNotEmpty) {
        await SharedPrefService.setString(Constants.loginUsernameKey, fullName);
      }

      // Save identity token if available
      if (credential.identityToken != null) {
        await SharedPrefService.setString(Constants.loginTokenKey, credential.identityToken!);
      }
    } catch (e) {
      // Log error but don't throw - authentication can proceed without local storage
    }
  }
}
