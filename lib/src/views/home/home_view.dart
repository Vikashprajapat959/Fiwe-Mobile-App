import 'package:fiwe/src/controllers/auth_controller.dart' show AuthController;
import 'package:fiwe/src/utils/loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController controller = Get.find();
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: controller.signOut,
            child: const Text('Sign Out'),
          ),
          TextButton(
            onPressed: () {
              controller.executeWithLoading(
                Future.delayed(Duration(seconds: 15)),
                message: "Something is loading...",
                canDismiss: true,
              );
            },
            child: const Text('Sign In'),
          ),
        ],
      ),
      body: const Center(child: Text("Home")),
    );
  }
}
