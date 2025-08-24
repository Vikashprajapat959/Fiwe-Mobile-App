import 'package:fiwe/src/utils/assets.dart';
import 'package:fiwe/src/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../controllers/login_controller.dart';
import '../../utils/constants.dart';
import '../../utils/strings.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    // Use Get.find to get existing controller or Get.put with proper lifecycle management
    final LoginController controller = Get.isRegistered<LoginController>()
        ? Get.find<LoginController>()
        : Get.put(LoginController(), permanent: false);

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(Assets.svgs.logoSvg),

            Text(
              Strings.loginSubtitle,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(Constants.textColor),
              ),
            ),

            const SizedBox(height: 8),

            // SocialLoginButton(onPressed: onPressed, backgroundColor: backgroundColor, title: title, icon: icon)

            // Google Sign In Button with GetX
            // Obx(() => _buildGoogleSignInButton(controller)),
            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }

  /// Build Google Sign-In button with loading state
  Widget _buildGoogleSignInButton(LoginController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: controller.isLoading ? null : controller.signInWithGoogle,
        icon: controller.isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0891B2)),
                ),
              )
            : Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://developers.google.com/identity/images/g-logo.png',
                    ),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
        label: Text(
          controller.isLoading ? Strings.signingIn : Strings.loginWithGoogle,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Color(Constants.textColor),
          elevation: controller.isLoading ? 0 : 2,
          shadowColor: Colors.black.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Color(Constants.borderColor), width: 1),
          ),
        ),
      ),
    );
  }
}
