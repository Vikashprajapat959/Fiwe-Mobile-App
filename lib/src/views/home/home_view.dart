import 'package:fiwe/src/controllers/auth_controller.dart';
import 'package:fiwe/src/controllers/video_room_controller.dart';
import 'package:fiwe/src/utils/notification_test_helper.dart';
import 'package:fiwe/src/views/login/login_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.find<VideoRoomController>().createRoom("Music");
        },
      ),
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to Home View', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 32),

            // Notification Testing Section
            const Text('Notification Testing', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => NotificationTestHelper.showTestNotification(
                    title: 'Test Notification',
                    body: 'This is a test notification. Try swiping to dismiss!',
                  ),
                  child: const Text('Show Test Notification'),
                ),

                ElevatedButton(
                  onPressed: () => NotificationTestHelper.testSwipeDismissal(),
                  child: const Text('Test Swipe Dismissal'),
                ),

                ElevatedButton(
                  onPressed: () => NotificationTestHelper.showTestSequence(),
                  child: const Text('Show Sequence'),
                ),

                ElevatedButton(
                  onPressed: () => NotificationTestHelper.testAutoDiscard(),
                  child: const Text('Test Auto-Discard'),
                ),

                ElevatedButton(
                  onPressed: () => NotificationTestHelper.testInMemoryLimit(),
                  child: const Text('Test Memory Limit'),
                ),

                ElevatedButton(
                  onPressed: () => NotificationTestHelper.dismissCurrent(),
                  child: const Text('Dismiss Current'),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Text(
              'Test notification system:\n'
              '• In-memory only (no persistence)\n'
              '• Auto-discard after 15 minutes\n'
              '• Max 20 notifications in memory\n'
              '• Swipe left/right to dismiss\n'
              '• Badge count persisted only',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
