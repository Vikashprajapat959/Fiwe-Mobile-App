import 'package:fiwe/src/controllers/auth_controller.dart' show AuthController;
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
          TextButton(onPressed: controller.signOut, child: Text('Sign Out')),
        ],
      ),
      body: Center(child: Text("Home")),
    );
  }
}
