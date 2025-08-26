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

import '../services/google_auth_service.dart';
import '../services/http_service.dart';
import '../services/shared_pref_service.dart';
import '../utils/constants.dart';
import '../utils/strings.dart';

class AuthController extends GetxController {
  final GoogleAuthService _authService = GoogleAuthService();
  final HttpService _httpService = HttpService();
  final Rx<GoogleSignInAccount?> _user = Rx<GoogleSignInAccount?>(null);
  final RxBool _isInitializing = RxBool(true);
  final RxBool _isSigningUp = RxBool(false);
  final Rx<SocialProfile?> _userProfile = Rx<SocialProfile?>(null);
  final RxBool _isSplashComplete = RxBool(false);

  bool get isInitializing => _isInitializing.value;
  bool get isLoggedIn => _user.value != null;
  bool get isSigningUp => _isSigningUp.value;
  bool get isSplashComplete => _isSplashComplete.value;
  bool get supportsAuthenticate => _authService.supportsAuthenticate;
  GoogleSignInAccount? get user => _user.value;
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

      // Create user profile
      String? idToken;
      if (_user.value != null) {
        final auth = _user.value!.authentication;
        idToken = auth.idToken;
      }

      final profile = SocialProfile(
        name: name,
        email: email,
        dateOfBirth: dateOfBirth,
        pinCode: pinCode,
        profileImagePath: profileImage?.path,
        displayName: _user.value?.displayName,
        idToken: idToken,
        isRegistered: true,
      );

      // Save user profile to shared preferences
      await SharedPrefService.saveUserProfile(profile);
      await SharedPrefService.markUserAsRegistered();

      _userProfile(profile);

      Get.snackbar(
        'Success',
        Strings.signUpSuccess,
        duration: const Duration(seconds: 3),
      );

      // Navigate to home
      _navigateToHome();
    } catch (e) {
      Get.snackbar(
        'Error',
        '${Strings.signUpError} $e',
        duration: const Duration(seconds: 3),
      );
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

  /// Check if user has stored authentication data
  Future<bool> hasStoredAuthData() async {
    return await _authService.hasStoredAuthData();
  }

  /// Check if user is registered (completed signup)
  Future<bool> isUserRegistered() async {
    return await SharedPrefService.isUserRegistered();
  }

  @override
  void onClose() {
    _authService.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    _initAuth();
    _startSplashTimer();
  }

  /// Send ID token to backend API
  Future<Map<String, dynamic>?> sendIdTokenToBackend() async {
    try {
      // Get the current signed-in user
      final currentUser = _user.value;
      if (currentUser == null) {
        throw Exception('No user is currently signed in');
      }

      // Get fresh authentication credentials
      final authentication = currentUser.authentication;
      final idToken = authentication.idToken;

      if (idToken == null) {
        throw Exception('Unable to get ID token from Google Sign-In');
      }

      // Prepare the request body
      final body = {'id_token': idToken};

      // Send POST request to the backend
      final response = await _httpService.post(
        Endpoints.idToken, // Root endpoint of example.com
        body: body,
      );
      // Parse and return the response
      if (response.body.isNotEmpty) {
        return Map<String, dynamic>.from(json.decode(response.body));
      }
      // Check if response contains access and refresh tokens
      final responseData = Map<String, dynamic>.from(
        json.decode(response.body),
      );

      if (responseData.containsKey('access')) {
        await SharedPrefService.setString(
          Constants.bearerTokenKey,
          responseData['access'],
        );
      }

      if (responseData.containsKey('refresh')) {
        await SharedPrefService.setString(
          Constants.bearerTokenRefreshKey,
          responseData['refresh'],
        );
      }
      return {'success': true, 'message': 'Token sent successfully'};
    } catch (e) {
      if (kDebugMode) {
        print('Error sending ID token to backend: $e');
      }

      Get.snackbar(
        'API Error',
        'Failed to send authentication token: $e',
        duration: const Duration(seconds: 3),
      );

      return null;
    }
  }

  Future<void> signIn() async {
    try {
      final account = await _authService.signIn();
      if (account == null) {
        Get.snackbar(
          'Authentication Failed',
          'Unable to sign in. Please try again.',
          duration: const Duration(seconds: 3),
        );
        return;
      }
      _user(account);

      // Save basic Google account data
      await _saveGoogleAccountData(account);

      // Send ID token to backend
      await sendIdTokenToBackend();

      // Check if user has completed registration
      final isRegistered = await SharedPrefService.isUserRegistered();

      if (isRegistered) {
        // Load complete user profile
        _userProfile.value = await SharedPrefService.getUserProfile();
        _navigateToHome();
      } else {
        // Navigate to signup to complete registration
        _navigateToSignUp();
      }
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        Get.snackbar(
          'Sign-in Cancelled',
          'The sign-in process was cancelled.',
          duration: const Duration(seconds: 3),
        );
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
      await _authService.signOut();
      await SharedPrefService.clearUserData();
      SharedPrefService.remove(Constants.bearerTokenKey);
      SharedPrefService.remove(Constants.bearerTokenRefreshKey);
      _user(null);
      _userProfile(null);
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

  Future<void> _handleAuthenticatedUser(GoogleSignInAccount account) async {
    try {
      // Save Google account data
      await _saveGoogleAccountData(account);

      // Check if user has completed registration
      final isRegistered = await SharedPrefService.isUserRegistered();

      if (isRegistered) {
        // Load complete user profile
        _userProfile.value = await SharedPrefService.getUserProfile();
        _navigateToHome();
      } else {
        // Navigate to signup to complete registration
        _navigateToSignUp();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error handling authenticated user: $e');
      }
      _navigateToLogin();
    }
  }

  Future<void> _initAuth() async {
    try {
      _isInitializing(true);

      // Load stored user profile first
      _userProfile.value = await SharedPrefService.getUserProfile();

      // Initialize the auth service and attempt to restore session
      final account = await _authService.initialize();
      _user(account);
      sendIdTokenToBackend().then((value) {});
      // Set up stream listener for auth events (only for future changes)
      _authService.userStream.listen((newAccount) {
        // Only handle changes, not initial state
        if (_user.value != newAccount) {
          _user(newAccount);

          if (newAccount != null) {
            _handleAuthenticatedUser(newAccount);
          } else {
            _navigateToLogin();
          }
        }
      });

      _isInitializing(false);

      // Check if we can navigate (wait for splash timer)
      _checkNavigationReady();
    } catch (e) {
      _isInitializing(false);
      Get.snackbar(
        'Initialization Error',
        'Failed to initialize authentication: $e',
      );

      // Check if we can navigate (wait for splash timer)
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
    if (_user.value != null) {
      _handleAuthenticatedUser(_user.value!);
    } else {
      _navigateToLogin();
    }
  }

  Future<void> _saveGoogleAccountData(GoogleSignInAccount account) async {
    try {
      final auth = account.authentication;

      final profile = SocialProfile(
        email: account.email,
        displayName: account.displayName,
        idToken: auth.idToken,
        isRegistered: await SharedPrefService.isUserRegistered(),
      );
      await SharedPrefService.saveUserProfile(profile);
    } catch (e) {
      // Log error but don't block authentication flow
      if (kDebugMode) {
        print('Error saving Google account data: $e');
      }
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
