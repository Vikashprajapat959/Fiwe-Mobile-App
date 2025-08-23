import 'package:fiwe/src/controllers/auth_controller.dart';
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
  void initState() {
    super.initState();
    Get.put(AuthController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetX<AuthController>(
        builder: (controller) {
          if (controller.isInitializing) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Initializing...',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          }
          
          // This should not be reached as navigation happens in controller,
          // but keeping as fallback
          return const LoginView();
        },
      ),
    );
  }
}