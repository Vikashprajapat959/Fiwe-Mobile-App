import 'dart:developer' as dev;

import 'package:fiwe/src/controllers/auth_controller.dart';
import 'package:fiwe/src/controllers/video_room_controller.dart';
import 'package:fiwe/src/models/fcm_notification_data.dart';
import 'package:fiwe/src/models/hmsvideo_room.dart';
import 'package:fiwe/src/models/user_model.dart';
import 'package:fiwe/src/repositories/room_repository.dart';
import 'package:fiwe/src/services/fcm_notification_service.dart';
import 'package:fiwe/src/utils/constants.dart';
import 'package:fiwe_notification/fiwe_notification.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class HomeController extends GetxController {
  var pageIndex = 0.obs;
  late FCMNotificationService _notificationService;
  BuildContext? _context;

  // instance
  static HomeController get instance => Get.find<HomeController>();

  final RoomRepository roomRepository = RoomRepository.instance;
  // get user
  User? get user => Get.find<AuthController>().userProfile;

  // Method to set context from the view
  void setContext(BuildContext context) {
    _context = context;
  }

  // Method to manually trigger a notification for testing
  void triggerTestNotification() {
    final context = _context ?? Get.overlayContext;
    if (context != null) {
      InAppNotificationManager.setContext(context).show(
        const NotificationConfig(
          title: 'Test Notification',
          description: 'This is a test notification triggered from code',
        ),
      );
    }
  }

  @override
  void onInit() {
    // Get.put(NotificationService(), permanent: true);
    _notificationService = FCMNotificationService.instance;
    fetchActiveRoomDetails();
    super.onInit();
  }

  @override
  void onReady() {
    dev.log('HomeController onReady called', name: 'HomeController');
    _notificationService.roomInviteStream.listen((event) {
      dev.log('Received notification event: ${event.title}', name: 'HomeController');

      // Use the context set by the view or fallback to overlay context
      final context = _context ?? Get.overlayContext;
      dev.log('Context available: ${context != null}', name: 'HomeController');

      _showRoomInviteNotification(event);
    });
    super.onReady();
  }

  void _showRoomInviteNotification(RoomInviteData inviteData) {
    final context = _context ?? Get.overlayContext;
    if (context != null) {
      InAppNotificationManager.setContext(context).show(
        NotificationConfig(
          title: inviteData.title,
          description: 'You have a new room invite from ${inviteData.inviteeName}',
          icon: const Icon(LucideIcons.users),
          actions: [
            NotificationAction(
              label: 'Dismiss',
              style: NotificationActionStyle.secondary,
              onPressed: () {
                // Handle dismiss action
                dev.log('Dismiss action pressed for room: ${inviteData.roomId}', name: 'HomeController');
              },
            ),
            NotificationAction(
              label: 'Join',

              onPressed: () {
                // Get.off(()=>VideoRoomView(

                // ));
                // Handle join action, e.g., navigate to the room using inviteData.deepLink
                dev.log('Join action pressed for room: ${inviteData.roomId}', name: 'HomeController');
                // Example navigation (uncomment and implement navigation logic)
                // Get.toNamed(inviteData.deepLink);
              },
            ),
          ],
        ),
      );
    } else {
      dev.log('No context available to show room invite notification: ${inviteData.title}', name: 'HomeController');
    }
  }

  // get user active room details
  Future<void> fetchActiveRoomDetails() async {
    try {
      final roomRepository = RoomRepository.instance;
      final response = await roomRepository.getActiveRoomDetails();
      if (response.success && response.data != null) {
        dev.log('Active room details fetched successfully: ${response.data!.title}', name: 'HomeController');
        // You can store the room details in a variable or state management solution as needed
        showJoinPreviousRoomNotification(response.data!);
      } else {
        dev.log('No active room found or failed to fetch: ${response.message}', name: 'HomeController');
      }
    } catch (e) {
      dev.log('Error fetching active room details: $e', name: 'HomeController');
    }
  }

  // show user notification to join previos room if any
  void showJoinPreviousRoomNotification(HMSVideoRoom room) {
    final VideoRoomController controller = VideoRoomController.instance;
    controller.currentRoom = room;
    controller.isInRoom = true;
    final context = _context ?? Get.overlayContext;
    if (context != null) {
      InAppNotificationManager.setContext(context).show(
        NotificationConfig(
          title: 'Rejoin Room',
          description: 'You have an active room: ${room.title}.\nWould you like to rejoin?',
          icon: const Icon(LucideIcons.video),
          onDismiss: () {
            // Clear current room if user dismisses the notification
            InAppNotificationManager.dismiss();
            controller.leaveRoom();
          },
          actions: [
            NotificationAction(
              label: 'Dismiss',
              style: NotificationActionStyle.secondary,
              onPressed: () {
                // leave room action
                controller.leaveRoom();
              },
            ),
            NotificationAction(
              label: 'Join',
              onPressed: () {
                InAppNotificationManager.dismiss();
                Get.toNamed(Constants.videoRoomRoute, arguments: {'userName': user?.name ?? '  Guest'});
              },
            ),
          ],
        ),
      );
    } else {
      dev.log('No context available to show rejoin room notification for room: ${room.title}', name: 'HomeController');
    }
  }

  Future<List<HMSVideoRoom>> getActiveRooms() async {
    try {
      final roomRepository = RoomRepository.instance;
      final response = await roomRepository.getActiveRooms();
      if (response.success && response.data != null) {
        dev.log('Active rooms fetched successfully: ${response.data!.length}', name: 'HomeController');
        return response.data!;
        // You can store the room details in a variable or state management solution as needed
      } else {
        dev.log('No active rooms found or failed to fetch: ${response.message}', name: 'HomeController');
        throw Exception('No active rooms found or failed to fetch: ${response.message}');
      }
    } catch (e) {
      dev.log('Error fetching active rooms: $e', name: 'HomeController');
      rethrow;
    }
  }
}
