import 'package:fiwe/src/controllers/auth_controller.dart';
import 'package:fiwe/src/utils/assets.dart';
import 'package:fiwe/src/utils/colors.dart';
import 'package:fiwe/src/views/login/login_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: GetX<AuthController>(
        builder: (controller) {
          if (controller.isInitializing) {
            return Center(child: Image.asset(Assets.images.logo, width: Get.width * 0.5));
          }

          // This shoulx not be reached as navigation happens in controller,
          // but keeping as fallback
          return const LoginView();
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Get.put(AuthController());
  }
}
