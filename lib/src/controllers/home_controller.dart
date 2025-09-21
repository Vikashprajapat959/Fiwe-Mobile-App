import 'dart:developer' as dev;

import 'package:fiwe/src/controllers/auth_controller.dart';
import 'package:fiwe/src/models/user_model.dart';
import 'package:fiwe/src/services/fcm_notification_service.dart';
import 'package:fiwe_notification/fiwe_notification.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

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

      if (context != null) {
        dev.log('Attempting to show notification: ${event.title}', name: 'HomeController');
        try {
          InAppNotificationManager.setContext(context).show(
            NotificationConfig(
              title: event.title,
              description: event.title,
              // You can customize other properties like backgroundColor, icon, etc.
            ),
          );
          dev.log('Notification shown successfully: ${event.title}', name: 'HomeController');
        } catch (e, stackTrace) {
          dev.log('Error showing notification: $e\nStack trace: $stackTrace', name: 'HomeController');
          // Fallback to using overlay context if there's an issue
          final fallbackContext = Get.overlayContext;
          if (fallbackContext != null) {
            try {
              InAppNotificationManager.setContext(
                fallbackContext,
              ).show(NotificationConfig(title: event.title, description: event.title));
              dev.log('Notification shown with fallback context: ${event.title}', name: 'HomeController');
            } catch (fallbackError, fallbackStackTrace) {
              dev.log(
                'Error with fallback context: $fallbackError\nStack trace: $fallbackStackTrace',
                name: 'HomeController',
              );
            }
          }
        }
      } else {
        dev.log('No context available to show notification: ${event.title}', name: 'HomeController');
      }
    });
    super.onReady();
  }
}
