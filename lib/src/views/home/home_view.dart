import 'dart:developer';

import 'package:fiwe/src/controllers/home_controller.dart';
import 'package:fiwe/src/utils/colors.dart';
import 'package:fiwe/src/utils/constants.dart';
import 'package:fiwe/src/views/home/create_room_view.dart';
import 'package:fiwe_notification/fiwe_notification.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController(), permanent: true);
    // Pass the context to the controller
    controller.setContext(context);

    return Scaffold(
      floatingActionButton: DecoratedBox(
        decoration: Constants.gradientDecoration.copyWith(shape: BoxShape.circle),
        child: FloatingActionButton(
          shape: CircleBorder(),
          backgroundColor: Colors.transparent,
          child: Icon(LucideIcons.plus, color: AppColors.surface),
          onPressed: () {
            // Get.to(() => EditProfileScreen());
            Get.to(() => CreateRoomView());
            // Get.find<VideoRoomController>().createRoom("Music");
          },
        ),
      ),
      bottomNavigationBar: Obx(
        () => NavigationBar(
          selectedIndex: controller.pageIndex(),
          onDestinationSelected: (value) {
            controller.pageIndex(value);
          },
          destinations: const [
            NavigationDestination(icon: Icon(LucideIcons.house), label: 'Home'),
            NavigationDestination(icon: Icon(LucideIcons.squareUser), label: 'Joined Rooms'),
            NavigationDestination(icon: Icon(LucideIcons.users), label: 'Communes'),
            NavigationDestination(icon: Icon(LucideIcons.userCheck), label: 'Followers'),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to Home View', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 32),

            // Notification Testing Section
            const Text('Notification Testing', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                InAppNotificationManager.setContext(context).show(
                  NotificationConfig(
                    title: "Success !",
                    description: "Your action was completed successfully.",
                    icon: Icon(Icons.check_circle, color: Colors.green),
                    // duration: Duration(seconds: 5),
                    metadata: {"type": "success", "id": "123"},
                    actions: [
                      NotificationAction(
                        label: "It Should Print",
                        onPressed: () {
                          log("Pressed");
                        },
                      ),
                      NotificationAction(
                        label: "Dismiss",
                        onPressed: () => InAppNotificationManager.dismiss(),
                        style: NotificationActionStyle.secondary,
                      ),
                    ],
                  ),
                );
              },
              child: const Text("Show Notification"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final controller = Get.find<HomeController>();
                controller.triggerTestNotification();
              },
              child: const Text("Trigger Test Notification from Code"),
            ),
            const SizedBox(height: 16),

            // Wrap(
            //   spacing: 8,
            //   runSpacing: 8,
            //   children: [
            //     ElevatedButton(
            //       onPressed: () => InAppNotificationManager.setContext(
            //         context,
            //       ).show(NotificationConfig(title: 'Test Notification', description: "This is a test notification.")),
            //       child: const Text('Show Test Notification'),
            //     ),

            //     ElevatedButton(
            //       onPressed: () => NotificationTestHelper.testSwipeDismissal(),
            //       child: const Text('Test Swipe Dismissal'),
            //     ),

            //     ElevatedButton(
            //       onPressed: () => NotificationTestHelper.showTestSequence(),
            //       child: const Text('Show Sequence'),
            //     ),

            //     ElevatedButton(
            //       onPressed: () => NotificationTestHelper.testAutoDiscard(),
            //       child: const Text('Test Auto-Discard'),
            //     ),

            //     ElevatedButton(
            //       onPressed: () => NotificationTestHelper.testInMemoryLimit(),
            //       child: const Text('Test Memory Limit'),
            //     ),

            //     ElevatedButton(
            //       onPressed: () => NotificationTestHelper.dismissCurrent(),
            //       child: const Text('Dismiss Current'),
            //     ),
            //   ],
            // ),

            // const SizedBox(height: 16),
            // Text(
            //   'Test notification system:\n'
            //   '• In-memory only (no persistence)\n'
            //   '• Auto-discard after 15 minutes\n'
            //   '• Max 20 notifications in memory\n'
            //   '• Swipe left/right to dismiss\n'
            //   '• Badge count persisted only',
            //   textAlign: TextAlign.center,
            //   style: TextStyle(color: Colors.grey[600], fontSize: 12),
            // ),
          ],
        ),
      ),
    );
    //   body: Obx(
    //     () => IndexedStack(
    //       index: controller.pageIndex(),
    //       children: [
    //         const HomeScreen(),
    //         Center(child: Text('Rooms Page', style: TextStyle(fontSize: 24))),
    //         Center(child: Text('Communes Page', style: TextStyle(fontSize: 24))),
    //         Center(child: Text('Followers Page', style: TextStyle(fontSize: 24))),
    //       ],
    //     ),
    //   ),
    // );
  }
}
