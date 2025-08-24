import 'package:get/get.dart';
import 'auth_controller.dart';
import '../utils/strings.dart';

class LoginController extends GetxController {
  final RxBool _isLoading = RxBool(false);
  
  bool get isLoading => _isLoading.value;
  
  /// Handle Google Sign-In
  Future<void> signInWithGoogle() async {
    try {
      _isLoading.value = true;
      
      final AuthController authController = Get.find();
      await authController.signIn();
      
    } catch (e) {
      Get.snackbar(
        'Error',
        '${Strings.authError} $e',
        duration: const Duration(seconds: 3),
      );
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// Show app information
  void showAppInfo() {
    Get.snackbar(
      Strings.appName,
      'Version 1.0.0',
      duration: const Duration(seconds: 2),
    );
  }
}