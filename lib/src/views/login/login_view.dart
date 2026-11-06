import 'dart:io';

import 'package:fiwe/src/utils/assets.dart';
import 'package:fiwe/src/utils/colors.dart';
import 'package:fiwe/src/utils/constants.dart';
import 'package:fiwe/src/widgets/custom_button.dart';
import 'package:fiwe/src/widgets/custom_text_field.dart';
import 'package:fiwe/src/widgets/social_login_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/login_controller.dart';
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
      body: Container(
        width: Get.width,
        height: Get.height,
        decoration: Constants.gradientDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image.asset(Assets.images.logoTransparent, width: Get.width * 0.4),
            SizedBox(height: Get.height * .1),
            const Text(
              Strings.loginSubtitle,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.surface),
            ),

            // test login button
            if (kDebugMode) ...[
              const SizedBox(height: 16),
              AppTextField(
                hintText: 'Enter Email',
                controller: controller.emailController,
              ).paddingSymmetric(horizontal: 16),
              const SizedBox(height: 16),
              AppButtonElevated(text: 'Test login', onPressed: controller.testLogin).paddingSymmetric(horizontal: 16),
            ],

            const SizedBox(height: 16),

            // Google Sign-In Button
            Obx(
              () => SocialLoginButton(
                onPressed: controller.isLoading ? null : controller.signInWithGoogle,
                backgroundColor: AppColors.surface,
                title: Strings.loginWithGoogle,
                icon: Image.asset(Assets.images.googleLogo, height: 20),
                titleColor: Colors.black,
              ),
            ),

            const SizedBox(height: 16),

            // Apple Sign-In Button (show only if available)
            Obx(() {
              if (controller.isAppleSignInAvailable && Platform.isIOS) {
                return SocialLoginButton(
                  onPressed: controller.isLoading ? null : controller.signInWithApple,
                  backgroundColor: Colors.black,
                  title: Strings.loginWithApple,
                  icon: const Icon(Icons.apple, color: Colors.white),
                  titleColor: Colors.white,
                );
              }
              return const SizedBox.shrink();
            }),
            SizedBox(height: Get.height * 0.1),
          ],
        ),
      ),
    );
  }
}
