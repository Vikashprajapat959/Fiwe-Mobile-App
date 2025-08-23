import 'package:fiwe/src/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController controller = Get.find();
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => controller.signIn(),
          child: const Text("Login"),
        ),
      ),
    );
  }
}
