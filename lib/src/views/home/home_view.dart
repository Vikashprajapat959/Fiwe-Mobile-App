import 'package:fiwe/src/controllers/auth_controller.dart';
import 'package:fiwe/src/views/login/login_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // TODO: Implement sign out functionality
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Sign Out'),
                    content: const Text('Are you sure you want to sign out?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () {
                          // Add your sign out logic here
                          // Call auth controller sign out method
                          // You may need to inject AuthController or get it from a state management solution
                          Get.find<AuthController>().signOut();
                          // Or: context.read<AuthController>().signOut();
                          // Or: AuthService.instance.signOut();

                          // For now, adding a placeholder that can be replaced with actual auth logic
                          debugPrint('User signed out');
                          // Navigate to login/welcome screen after sign out
                          Get.offAll(() => const LoginView());
                          Navigator.of(context).pop();
                        },
                        child: const Text('Sign Out'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: const Center(child: Text('Welcome to Home View', style: TextStyle(fontSize: 24))),
    );
  }
}
