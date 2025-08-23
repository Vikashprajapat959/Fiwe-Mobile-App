import 'package:fiwe/src/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AuthController());
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => controller.signInWithGoogle(),
          child: Text("Login"),
        ),
      ),
    );
  }
}
