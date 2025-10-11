import 'package:fiwe/src/models/user_model.dart';
import 'package:fiwe/src/services/http_service.dart';
import 'package:fiwe/src/services/shared_pref_service.dart';
import 'package:fiwe/src/utils/loading_overlay.dart';
import 'package:flutter/src/widgets/editable_text.dart';
import 'package:get/get.dart';

import '../services/apple_auth_service.dart';
import '../utils/constants.dart';
import '../utils/strings.dart';
import 'auth_controller.dart';

class LoginController extends GetxController {
  final RxBool _isLoading = RxBool(false);
  final RxBool _isAppleSignInAvailable = RxBool(false);

  TextEditingController? emailController;

  bool get isAppleSignInAvailable => _isAppleSignInAvailable.value;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController();
    _checkAppleSignInAvailability();
  }

  /// Show app information
  void showAppInfo() {
    Get.snackbar(
      Strings.appName,
      Strings.appVersion,
      duration: const Duration(seconds: Constants.appInfoDurationSeconds),
    );
  }

  /// Handle Apple Sign-In
  Future<void> signInWithApple() async {
    try {
      _isLoading.value = true;

      final AuthController authController = Get.find();
      await authController.signInWithApple();
    } catch (e) {
      Get.snackbar(
        Strings.error,
        Strings.formatErrorMessage(Strings.authError, e),
        duration: const Duration(seconds: Constants.snackbarDurationSeconds),
      );
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
      Get.snackbar(
        Strings.error,
        Strings.formatErrorMessage(Strings.authError, e),
        duration: const Duration(seconds: Constants.snackbarDurationSeconds),
      );
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

  void testLogin() async {
    LoadingOverlay.show();
    try {
      final http = HttpService.instance;
      final response = await http.post('/auth/user-token', body: {'email': emailController?.text});
      if (response.data != null && response.data!.isNotEmpty) {
        final data = response.data!;
        if (data[Constants.responseAccessKey] != null) {
          await SharedPrefService.setString(
            Constants.storageBearerTokenKey,
            data[Constants.responseAccessKey] as String,
          );
        }
        if (data[Constants.responseRefreshKey] != null) {
          await SharedPrefService.setString(
            Constants.storageBearerTokenRefreshKey,
            data[Constants.responseRefreshKey] as String,
          );
        }
        if (response.data!.containsKey('user')) {
          Get.find<AuthController>().userProfile.value = User.fromJson(response.data?['user'] as Map<String, dynamic>);
        }

        Get.offAllNamed(Constants.homeViewRoute);
      }
    } catch (e) {
      Get.snackbar(
        Strings.error,
        Strings.formatErrorMessage(Strings.authError, e),
        duration: const Duration(seconds: Constants.snackbarDurationSeconds),
      );
    } finally {
      LoadingOverlay.hide();
      // TODO
    }
  }
}
