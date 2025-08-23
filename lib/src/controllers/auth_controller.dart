import 'package:fiwe/src/views/home/home_view.dart';
import 'package:fiwe/src/views/login/login_view.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../services/google_auth_service.dart';

class AuthController extends GetxController {
  final GoogleAuthService _authService = GoogleAuthService();
  final Rx<GoogleSignInAccount?> _user = Rx<GoogleSignInAccount?>(null);

  bool get isLoggedIn => _user.value != null;
  bool get supportsAuthenticate => _authService.supportsAuthenticate;

  GoogleSignInAccount? get user => _user.value;

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
    } catch (e) {
      Get.snackbar('Error', 'Failed to sign out: $e');
    }
  }

  Future<void> _initAuth() async {
    try {
      _user(await _authService.initialize());
      _authService.userStream.listen((account) {
        _user(account);
        if (account != null) {
          Get.offAll(() => HomeView());
        } else {
          Get.offAll(() => LoginView());
        }
      });
    } catch (e) {
      Get.snackbar('Initialization Error', 'Failed to initialize authentication: $e');
    }
  }
}
