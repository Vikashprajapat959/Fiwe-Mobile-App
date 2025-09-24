import 'dart:developer' as dev;

import 'package:fiwe/src/controllers/auth_controller.dart';
import 'package:fiwe/src/models/fcm_notification_data.dart';
import 'package:fiwe/src/models/user_model.dart';
import 'package:fiwe/src/services/fcm_notification_service.dart';
import 'package:fiwe_notification/fiwe_notification.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class HomeController extends GetxController {
  var pageIndex = 0.obs;
  late FCMNotificationService _notificationService;
  BuildContext? _context;

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
        NotificationConfig(title: "Test Notification", description: "This is a test notification triggered from code"),
      );
    }
  }

  @override
  void onInit() {
    // Get.put(NotificationService(), permanent: true);
    _notificationService = FCMNotificationService.instance;
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
          description: "You have a new room invite from ${inviteData.inviteeName}",
          icon: Icon(LucideIcons.users),
          actions: [
            NotificationAction(
              label: "Dismiss",
              style: NotificationActionStyle.secondary,
              onPressed: () {
                // Handle dismiss action
                dev.log('Dismiss action pressed for room: ${inviteData.roomId}', name: 'HomeController');
              },
            ),
            NotificationAction(
              label: "Join",

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
}
