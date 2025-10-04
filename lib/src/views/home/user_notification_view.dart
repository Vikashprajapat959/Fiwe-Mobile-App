import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/user_notification_controller.dart';

class UserNotificationView extends StatefulWidget {
  const UserNotificationView({super.key});

  @override
  State<UserNotificationView> createState() => _UserNotificationViewState();
}

class _UserNotificationViewState extends State<UserNotificationView> {
  final UserNotificationController controller = Get.put(UserNotificationController());
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!controller.isLoadingMore.value && controller.hasMore.value) {
        controller.fetchNextPage();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: Obx(() {
        if (controller.isLoading.value && controller.notifications.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.notifications.isEmpty) {
          return const Center(child: Text('No notifications found.'));
        }
        return ListView.builder(
          controller: _scrollController,
          itemCount: controller.notifications.length + (controller.isLoadingMore.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == controller.notifications.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final notification = controller.notifications[index];
            return ListTile(
              leading: const Icon(Icons.notifications, color: Colors.blue),
              title: Text(notification.title),
              subtitle: Text(notification.body),
              trailing: Text('${notification.deliveredAt}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            );
          },
        );
      }),
    );
  }
}
