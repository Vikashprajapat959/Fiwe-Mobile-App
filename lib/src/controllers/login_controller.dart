import 'package:get/get.dart';

import '../services/apple_auth_service.dart';
import '../utils/strings.dart';
import 'auth_controller.dart';

class LoginController extends GetxController {
  final RxBool _isLoading = RxBool(false);
  final RxBool _isAppleSignInAvailable = RxBool(false);

  bool get isAppleSignInAvailable => _isAppleSignInAvailable.value;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    _checkAppleSignInAvailability();
  }

  /// Show app information
  void showAppInfo() {
    Get.snackbar(Strings.appName, 'Version 1.0.0', duration: const Duration(seconds: 2));
  }

  /// Handle Apple Sign-In
  Future<void> signInWithApple() async {
    try {
      _isLoading.value = true;

      final AuthController authController = Get.find();
      await authController.signInWithApple();
    } catch (e) {
      Get.snackbar('Error', '${Strings.authError} $e', duration: const Duration(seconds: 3));
    } finally {
      _isLoading.value = false;
    }
  }

  /// Handle Google Sign-In
  Future<void> signInWithGoogle() async {
    try {
      _isLoading.value = true;

      final AuthController authController = Get.find();
      await authController.signInWithGoogle();
    } catch (e) {
      Get.snackbar('Error', '${Strings.authError} $e', duration: const Duration(seconds: 3));
    } finally {
      _isLoading.value = false;
    }
  }

  /// Check if Apple Sign-In is available on this device
  Future<void> _checkAppleSignInAvailability() async {
    try {
      final isAvailable = await AppleAuthService.isAvailable;
      _isAppleSignInAvailable(isAvailable);
    } catch (e) {
      _isAppleSignInAvailable(false);
    }
  }
}
