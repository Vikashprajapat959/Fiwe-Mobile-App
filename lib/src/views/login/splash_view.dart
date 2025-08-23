import 'package:fiwe/src/controllers/auth_controller.dart';
import 'package:fiwe/src/views/login/login_view.dart';
import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AuthController());
    return Scaffold(body: LoginView());
  }
}
