import 'package:fiwe/src/views/home/home_view.dart';
import 'package:fiwe/src/views/login/login_view.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../services/google_auth_service.dart';
import '../services/shared_pref_service.dart';
import '../utils/constants.dart';

class AuthController extends GetxController {
  final GoogleAuthService _authService = GoogleAuthService();
  final Rx<GoogleSignInAccount?> _user = Rx<GoogleSignInAccount?>(null);
  final RxBool _isInitializing = RxBool(true);

  bool get isLoggedIn => _user.value != null;
  bool get supportsAuthenticate => _authService.supportsAuthenticate;
  bool get isInitializing => _isInitializing.value;

  GoogleSignInAccount? get user => _user.value;

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
      _user(null);
    } catch (e) {
      Get.snackbar('Error', 'Failed to sign out: $e');
    }
  }

  Future<void> _initAuth() async {
    try {
      _isInitializing(true);
      
      // Initialize the auth service and attempt to restore session
      final account = await _authService.initialize();
      _user(account);
      
      // Set up stream listener for auth events
      _authService.userStream.listen((account) {
        _user(account);
        
        if (account != null) {
          Get.offAll(() => HomeView());
        } else {
          Get.offAll(() => LoginView());
        }
      });
      
      _isInitializing(false);
      
      // Navigate based on initial authentication state
      if (account != null) {
        Get.offAll(() => HomeView());
      } else {
        Get.offAll(() => LoginView());
      }
      
    } catch (e) {
      _isInitializing(false);
      Get.snackbar('Initialization Error', 'Failed to initialize authentication: $e');
      
      // Fallback to login view on error
      Get.offAll(() => LoginView());
    }
  }
}
