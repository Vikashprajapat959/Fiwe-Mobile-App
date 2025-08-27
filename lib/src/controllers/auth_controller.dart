import 'dart:convert';
import 'dart:io';

import 'package:fiwe/src/models/social_profile.dart';
import 'package:fiwe/src/utils/endpoints.dart';
import 'package:fiwe/src/views/home/home_view.dart';
import 'package:fiwe/src/views/login/login_view.dart';
import 'package:fiwe/src/views/login/signup_view.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../services/apple_auth_service.dart';
import '../services/google_auth_service.dart';
import '../services/http_service.dart';
import '../services/shared_pref_service.dart';
import '../utils/constants.dart';
import '../utils/strings.dart';

class AuthController extends GetxController {
  final GoogleAuthService _googleAuthService = GoogleAuthService();
  final HttpService _httpService = HttpService();
  final Rx<GoogleSignInAccount?> _googleUser = Rx<GoogleSignInAccount?>(null);
  final Rx<AuthorizationCredentialAppleID?> _appleUser = Rx<AuthorizationCredentialAppleID?>(null);
  final RxBool _isInitializing = RxBool(true);
  final RxBool _isSigningUp = RxBool(false);
  final Rx<SocialProfile?> _userProfile = Rx<SocialProfile?>(null);
  final RxBool _isSplashComplete = RxBool(false);
  final Rx<LoginProvider?> _currentProvider = Rx<LoginProvider?>(null);
  final RxBool _isHandlingAuthentication = RxBool(false);

  AuthorizationCredentialAppleID? get appleUser => _appleUser.value;
  LoginProvider? get currentProvider => _currentProvider.value;

  /// Get current user info regardless of provider
  Map<String, String?> get currentUserInfo {
    if (_googleUser.value != null) {
      return {
        'email': _googleUser.value!.email,
        'displayName': _googleUser.value!.displayName,
        'id': _googleUser.value!.id,
      };
    } else if (_appleUser.value != null) {
      final fullName = _appleUser.value!.givenName != null && _appleUser.value!.familyName != null
          ? '${_appleUser.value!.givenName} ${_appleUser.value!.familyName}'
          : _appleUser.value!.givenName ?? _appleUser.value!.familyName ?? '';
      return {
        'email': _appleUser.value!.email,
        'displayName': fullName.isEmpty ? null : fullName,
        'id': _appleUser.value!.userIdentifier,
      };
    }
    return {'email': null, 'displayName': null, 'id': null};
  }

  GoogleSignInAccount? get googleUser => _googleUser.value;
  bool get isInitializing => _isInitializing.value;
  bool get isLoggedIn => _googleUser.value != null || _appleUser.value != null;
  bool get isSigningUp => _isSigningUp.value;
  bool get isSplashComplete => _isSplashComplete.value;
  bool get supportsAuthenticate => _googleAuthService.supportsAuthenticate;

  SocialProfile? get userProfile => _userProfile.value;

  Future<void> completeSignUp({
    required String name,
    required String email,
    required String dateOfBirth,
    required String pinCode,
    File? profileImage,
  }) async {
    try {
      _isSigningUp(true);

      // Get current ID token based on provider
      String? idToken;
      if (_googleUser.value != null) {
        final auth = _googleUser.value!.authentication;
        idToken = auth.idToken;
      } else if (_appleUser.value != null) {
        idToken = _appleUser.value!.identityToken;
      }

      // Update the profile in controller with complete information
      final profile = SocialProfile(
        name: name,
        email: email,
        dateOfBirth: dateOfBirth,
        pinCode: pinCode,
        profileImagePath: profileImage?.path,
        displayName: currentUserInfo['displayName'],
        idToken: idToken,
        isRegistered: true,
      );

      _userProfile(profile);

      Get.snackbar('Success', Strings.signUpSuccess, duration: const Duration(seconds: 3));

      // Navigate to home
      _navigateToHome();
    } catch (e) {
      Get.snackbar('Error', '${Strings.signUpError} $e', duration: const Duration(seconds: 3));
    } finally {
      _isSigningUp(false);
    }
  }

  /// Get stored user email for display purposes
  Future<String?> getStoredUserEmail() async {
    try {
      return await SharedPrefService.getString(Constants.loginEmailKey);
    } catch (e) {
      return null;
    }
  }

  /// Check if user has stored authentication data from any provider
  Future<bool> hasStoredAuthData() async {
    final hasGoogle = await _googleAuthService.hasStoredAuthData();
    final hasApple = await AppleAuthService.hasStoredAuthData();
    return hasGoogle || hasApple;
  }

  @override
  void onClose() {
    _googleAuthService.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    _initAuth();
    _startSplashTimer();
  }

  /// Send ID token to backend API (supports both Google and Apple)
  Future<Map<String, dynamic>?> sendIdTokenToBackend() async {
    try {
      String? idToken;
      String? provider;

      if (_googleUser.value != null) {
        final authentication = _googleUser.value!.authentication;
        idToken = authentication.idToken;
        provider = 'google';
      } else if (_appleUser.value != null) {
        idToken = _appleUser.value!.identityToken;
        provider = 'apple';
      }

      if (idToken == null) {
        throw Exception('Unable to get ID token from authentication provider');
      }

      // Prepare the request body
      final body = {'id_token': idToken, 'provider': provider};

      // Send POST request to the backend
      final response = await _httpService.post(Endpoints.idToken, body: body);

      // Parse the response
      if (response.body.isNotEmpty) {
        final responseData = Map<String, dynamic>.from(json.decode(response.body));

        // Save tokens to SharedPreferences (only tokens, not profile)
        if (responseData.containsKey('access')) {
          await SharedPrefService.setString(Constants.bearerTokenKey, responseData['access']);
        }

        if (responseData.containsKey('refresh')) {
          await SharedPrefService.setString(Constants.bearerTokenRefreshKey, responseData['refresh']);
        }

        return responseData;
      }

      return {'success': true, 'message': 'Token sent successfully'};
    } catch (e) {
      if (kDebugMode) {
        print('Error sending ID token to backend: $e');
      }

      Get.snackbar('API Error', 'Failed to send authentication token: $e', duration: const Duration(seconds: 3));

      return null;
    }
  }

  /// Sign in with Apple
  Future<void> signInWithApple() async {
    try {
      final credential = await AppleAuthService.signIn();
      if (credential == null) {
        Get.snackbar(
          'Authentication Failed',
          'Unable to sign in with Apple. Please try again.',
          duration: const Duration(seconds: 3),
        );
        return;
      }

      _appleUser(credential);
      _googleUser(null); // Clear Google user if exists
      _currentProvider(LoginProvider.apple);

      // Create social profile and handle authentication
      await _createSocialProfileFromApple(credential);
      await _handleAuthenticatedUser();
    } catch (e) {
      if (kDebugMode) {
        print('Apple Sign-In Error: $e');
      }

      Get.snackbar('Apple Sign-In Failed', 'Authentication failed: $e', duration: const Duration(seconds: 3));
    }
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      final account = await _googleAuthService.signIn();
      if (account == null) {
        Get.snackbar(
          'Authentication Failed',
          'Unable to sign in with Google. Please try again.',
          duration: const Duration(seconds: 3),
        );
        return;
      }

      _googleUser(account);
      _appleUser(null); // Clear Apple user if exists
      _currentProvider(LoginProvider.google);

      // Create social profile and handle authentication
      await _createSocialProfileFromGoogle(account);
      await _handleAuthenticatedUser();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        Get.snackbar('Sign-in Cancelled', 'The sign-in process was cancelled.', duration: const Duration(seconds: 3));
      } else {
        Get.snackbar(
          'Google Sign-In Error',
          'Authentication failed: ${e.description ?? e.code}',
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar('Sign-In Failed', 'Unexpected error: $e');
    }
  }

  Future<void> signOut() async {
    try {
      // Reset authentication handling flag
      _isHandlingAuthentication(false);

      // Sign out from the appropriate service
      if (_currentProvider.value == LoginProvider.google) {
        await _googleAuthService.signOut();
      } else if (_currentProvider.value == LoginProvider.apple) {
        await AppleAuthService.signOut();
      }

      // Clear tokens from SharedPreferences
      await SharedPrefService.clearAuthData();

      // Clear controller state
      _googleUser(null);
      _appleUser(null);
      _userProfile(null);
      _currentProvider(null);

      _navigateToLogin();
    } catch (e) {
      Get.snackbar('Error', 'Failed to sign out: $e');
    }
  }

  /// Check if both initialization and splash timer are complete
  void _checkNavigationReady() {
    if (!_isInitializing.value && _isSplashComplete.value) {
      _performNavigation();
    }
  }

  /// Create social profile from Apple credential
  Future<void> _createSocialProfileFromApple(AuthorizationCredentialAppleID credential) async {
    try {
      final fullName = credential.givenName != null && credential.familyName != null
          ? '${credential.givenName} ${credential.familyName}'
          : credential.givenName ?? credential.familyName ?? '';

      final profile = SocialProfile(
        email: credential.email,
        displayName: fullName.isEmpty ? null : fullName,
        idToken: credential.identityToken,
        isRegistered: false, // Will be determined by backend
      );

      _userProfile(profile);
    } catch (e) {
      if (kDebugMode) {
        print('Error creating Apple social profile: $e');
      }
      throw Exception('Failed to create Apple social profile: $e');
    }
  }

  /// Create social profile from Google account
  Future<void> _createSocialProfileFromGoogle(GoogleSignInAccount account) async {
    try {
      final auth = account.authentication;

      final profile = SocialProfile(
        email: account.email,
        displayName: account.displayName,
        idToken: auth.idToken,
        isRegistered: false, // Will be determined by backend
      );

      _userProfile(profile);
    } catch (e) {
      if (kDebugMode) {
        print('Error creating Google social profile: $e');
      }
      throw Exception('Failed to create Google social profile: $e');
    }
  }

  Future<void> _handleAuthenticatedUser() async {
    // Prevent duplicate API calls during concurrent authentication handling
    if (_isHandlingAuthentication.value) {
      if (kDebugMode) {
        print('Authentication already in progress, skipping duplicate call');
      }
      return;
    }

    try {
      _isHandlingAuthentication(true);

      // Send ID token to backend and get response with is_new flag
      final backendResponse = await sendIdTokenToBackend();

      if (backendResponse != null) {
        // Check is_new flag from backend response
        final isNew = backendResponse['is_new'] ?? false;

        if (isNew) {
          // New user - navigate to signup
          _navigateToSignUp();
        } else {
          // Existing user - navigate to home
          _navigateToHome();
        }
      } else {
        // Fallback: If backend call fails, navigate to login
        _navigateToLogin();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error handling authenticated user: $e');
      }
      _navigateToLogin();
    } finally {
      _isHandlingAuthentication(false);
    }
  }

  Future<void> _initAuth() async {
    try {
      _isInitializing(true);

      // Try to restore existing authentication sessions
      bool hasAuthentication = false;

      // Check for Google authentication
      try {
        final googleAccount = await _googleAuthService.initialize();
        if (googleAccount != null) {
          _googleUser(googleAccount);
          _currentProvider(LoginProvider.google);
          await _createSocialProfileFromGoogle(googleAccount);
          hasAuthentication = true;
        }
      } catch (e) {
        if (kDebugMode) {
          print('Google auth initialization failed: $e');
        }
      }

      // If no Google auth, check for Apple auth (only if Apple Sign-In is available)
      if (!hasAuthentication && await AppleAuthService.isAvailable) {
        try {
          final hasAppleAuth = await AppleAuthService.hasStoredAuthData();
          if (hasAppleAuth) {
            _currentProvider(LoginProvider.apple);
            // Note: Apple doesn't provide automatic sign-in like Google
            // We'll handle this in the navigation logic
          }
        } catch (e) {
          if (kDebugMode) {
            print('Apple auth check failed: $e');
          }
        }
      }

      // Set up Google stream listener for future changes
      _googleAuthService.userStream.listen((newAccount) {
        if (_googleUser.value != newAccount) {
          _googleUser(newAccount);
          _currentProvider(newAccount != null ? LoginProvider.google : null);

          if (newAccount != null) {
            _createSocialProfileFromGoogle(newAccount).then((_) {
              // Only handle authentication if not already in progress and splash is complete
              if (!_isHandlingAuthentication.value && _isSplashComplete.value) {
                _handleAuthenticatedUser();
              }
            });
          } else if (_appleUser.value == null) {
            // Only navigate to login if no Apple user either and not handling auth
            if (!_isHandlingAuthentication.value) {
              _navigateToLogin();
            }
          }
        }
      });

      _isInitializing(false);
      _checkNavigationReady();
    } catch (e) {
      _isInitializing(false);
      if (kDebugMode) {
        print('Auth initialization error: $e');
      }
      _checkNavigationReady();
    }
  }

  void _navigateToHome() {
    if (Get.currentRoute != '/HomeView') {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (!Get.isDialogOpen! && !Get.isBottomSheetOpen!) {
          Get.offAll(() => const HomeView());
        }
      });
    }
  }

  void _navigateToLogin() {
    if (Get.currentRoute != '/LoginView') {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (!Get.isDialogOpen! && !Get.isBottomSheetOpen!) {
          Get.offAll(() => const LoginView());
        }
      });
    }
  }

  void _navigateToSignUp() {
    if (Get.currentRoute != '/SignUpView') {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (!Get.isDialogOpen! && !Get.isBottomSheetOpen!) {
          Get.offAll(() => const SignUpView());
        }
      });
    }
  }

  /// Perform navigation after both init and splash timer complete
  void _performNavigation() {
    if (isLoggedIn) {
      // User is authenticated, proceed with backend verification
      _handleAuthenticatedUser();
    } else {
      // No authentication found, go to login
      _navigateToLogin();
    }
  }

  /// Start splash timer to ensure minimum display time
  void _startSplashTimer() {
    Future.delayed(const Duration(seconds: 2), () {
      _isSplashComplete(true);
      _checkNavigationReady();
    });
  }
}

/// Enum for different login providers
enum LoginProvider { google, apple }
