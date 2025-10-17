import 'dart:convert';

import 'package:fiwe/src/controllers/user_notification_controller.dart';
import 'package:fiwe/src/models/user_notification.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 24) {
      final period = dateTime.hour >= 12 ? 'pm' : 'am';
      final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$hour.$minute$period';
    }
    if (difference.inDays == 1) return 'Yesterday';
    return '${dateTime.day}/${dateTime.month}';
  }

  String _extractName(UserNotification notification) {
    if (notification.creatorName != null && notification.creatorName!.isNotEmpty) return notification.creatorName!;
    if (notification.body.contains('join')) {
      final bodyParts = notification.body.split('join');
      if (bodyParts.length > 1) {
        final bodyName = bodyParts.last.trim();
        if (bodyName.isNotEmpty) return bodyName;
      }
    }
    if (notification.title.contains(':')) {
      final titleName = notification.title.split(':').last.trim();
      if (titleName.isNotEmpty) return titleName;
    }
    return 'Room User';
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.notifications.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.notifications.isEmpty) {
          return const Center(
            child: Text('No notifications found.', style: TextStyle(color: Colors.black)),
          );
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
            final creatorName = _extractName(notification);
            final interestOrType =
                notification.actionData?['interest'] as String? ??
                notification.notificationType
                    .split('_')
                    .map((word) => word[0].toUpperCase() + word.substring(1))
                    .join(' ');

            return ListTile(
              leading: CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: notification.profileImageUrl != null && notification.profileImageUrl!.isNotEmpty
                    ? NetworkImage(notification.profileImageUrl!)
                    : (notification.profileBase64 != null && notification.profileBase64!.isNotEmpty
                          ? MemoryImage(base64Decode(notification.profileBase64!)) as ImageProvider
                          : null),
                child:
                    (notification.profileImageUrl == null || notification.profileImageUrl!.isEmpty) &&
                        (notification.profileBase64 == null || notification.profileBase64!.isEmpty)
                    ? Text(
                        creatorName.isNotEmpty ? creatorName[0].toUpperCase() : 'N',
                        style: const TextStyle(color: Colors.black54, fontSize: 18),
                      )
                    : null,
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    interestOrType,
                    style: const TextStyle(fontWeight: FontWeight.w400, color: Colors.black, fontSize: 14),
                  ),
                  Text(
                    creatorName,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 14),
                  ),
                ],
              ),
              subtitle: Text(notification.body, style: const TextStyle(color: Colors.black54, fontSize: 13)),
              trailing: Text(
                notification.deliveredAt != null
                    ? _formatTime(notification.deliveredAt!)
                    : _formatTime(notification.sentAt),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            );
          },
        );
      }),
    );
  }
}
