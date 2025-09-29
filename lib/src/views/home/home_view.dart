import 'package:fiwe/src/controllers/home_controller.dart';
import 'package:fiwe/src/utils/colors.dart';
import 'package:fiwe/src/utils/constants.dart';
import 'package:fiwe/src/views/home/create_room_view.dart';
import 'package:fiwe/src/views/home/home_screen_view.dart';
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
          shape: const CircleBorder(),
          backgroundColor: Colors.transparent,
          child: const Icon(LucideIcons.plus, color: AppColors.surface),
          onPressed: () {
            // Get.to(() => EditProfileScreen());
            Get.to(() => const CreateRoomView());
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

      body: Obx(
        () => IndexedStack(
          index: controller.pageIndex(),
          children: const [
            HomeScreen(),
            Center(child: Text('Rooms Page', style: TextStyle(fontSize: 24))),
            Center(child: Text('Communes Page', style: TextStyle(fontSize: 24))),
            Center(child: Text('Followers Page', style: TextStyle(fontSize: 24))),
          ],
        ),
      ),
    );
  }
}
