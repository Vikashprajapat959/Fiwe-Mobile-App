import 'dart:io';
import 'package:fiwe/src/views/home/home_view.dart';
import 'package:fiwe/src/views/login/login_view.dart';
import 'package:fiwe/src/views/login/signup_view.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../services/google_auth_service.dart';
import '../services/shared_pref_service.dart';
import '../utils/constants.dart';
import '../utils/strings.dart';

class AuthController extends GetxController {
  final GoogleAuthService _authService = GoogleAuthService();
  final Rx<GoogleSignInAccount?> _user = Rx<GoogleSignInAccount?>(null);
  final RxBool _isInitializing = RxBool(true);
  final RxBool _isSigningUp = RxBool(false);
  final Rx<UserProfile?> _userProfile = Rx<UserProfile?>(null);

  bool get isLoggedIn => _user.value != null;
  bool get supportsAuthenticate => _authService.supportsAuthenticate;
  bool get isInitializing => _isInitializing.value;
  bool get isSigningUp => _isSigningUp.value;
  GoogleSignInAccount? get user => _user.value;
  UserProfile? get userProfile => _userProfile.value;

  /// Check if user has stored authentication data
  Future<bool> hasStoredAuthData() async {
    return await _authService.hasStoredAuthData();
  }

  /// Get stored user email for display purposes
  Future<String?> getStoredUserEmail() async {
    try {
      return await SharedPrefService.getString(Constants.loginEmailKey);
    } catch (e) {
      return null;
    }
  }

  /// Check if user is registered (completed signup)
  Future<bool> isUserRegistered() async {
    return await SharedPrefService.isUserRegistered();
  }

  @override
  void onInit() {
    super.onInit();
    _initAuth();
  }

  @override
  void onClose() {
    _authService.dispose();
    super.onClose();
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
      _user(null);
      _userProfile(null);
      _navigateToLogin();
    } catch (e) {
      Get.snackbar('Error', 'Failed to sign out: $e');
    }
  }

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
        final auth = await _user.value!.authentication;
        idToken = auth.idToken;
      }
      
      final profile = UserProfile(
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

  Future<void> _saveGoogleAccountData(GoogleSignInAccount account) async {
    try {
      final auth = await account.authentication;
      
      final profile = UserProfile(
        email: account.email,
        displayName: account.displayName,
        idToken: auth.idToken,
        isRegistered: await SharedPrefService.isUserRegistered(),
      );
      printInfo(info:auth.idToken.toString());
      await SharedPrefService.saveUserProfile(profile);
    } catch (e) {
      // Log error but don't block authentication flow
      print('Error saving Google account data: $e');
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
      
      // Navigate based on initial authentication state (only once)
      if (account != null) {
        await _handleAuthenticatedUser(account);
      } else {
        _navigateToLogin();
      }
      
    } catch (e) {
      _isInitializing(false);
      Get.snackbar('Initialization Error', 'Failed to initialize authentication: $e');
      
      // Fallback to login view on error
      _navigateToLogin();
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
      print('Error handling authenticated user: $e');
      _navigateToLogin();
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
  
  void _navigateToHome() {
    if (Get.currentRoute != '/HomeView') {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (!Get.isDialogOpen! && !Get.isBottomSheetOpen!) {
          Get.offAll(() => const HomeView());
        }
      });
    }
  }
}
