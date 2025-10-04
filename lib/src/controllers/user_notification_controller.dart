import 'dart:developer';

import 'package:fiwe/src/models/user_notification.dart';
import 'package:fiwe/src/services/user_service.dart';
import 'package:get/get.dart';

class UserNotificationController extends GetxController {
  // Define observable list to hold user notifications
  var notifications = <UserNotification>[].obs;
  var isLoading = false.obs;
  var page = 1;
  var pageSize = 20;
  var hasMore = true.obs;

  var isLoadingMore = false.obs;

  // Method to fetch user notifications from API
  Future<void> fetchUserNotifications({
    int? page,
    int? pageSize,
    String? notificationType,
    String? status,
    bool? unreadOnly,
  }) async {
    if (isLoading.value || !hasMore()) return;

    isLoading.value = true;
    try {
      // Call your UserService to fetch notification
      final response = await UserService.instance.fetchUserNotifications();
      if (response.success && response.data != null) {
        if (page == 1) {
          notifications.value = response.data!.notifications;
        } else {
          notifications.addAll(response.data!.notifications);
        }
        hasMore(response.data!.notifications.length == (pageSize ?? this.pageSize));
        this.page = page ?? this.page + 1;
      } else {
        // Handle error response
        Get.snackbar('Error', response.message);
      }
    } catch (e, s) {
      log(e.toString(), stackTrace: s);
      Get.snackbar('Error', 'Failed to fetch notifications: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void fetchNextPage() {
    if (isLoadingMore.value || !hasMore.value) return;
    isLoadingMore.value = true;
    fetchUserNotifications(page: page + 1, pageSize: pageSize).whenComplete(() {
      isLoadingMore.value = false;
    });
  }

  @override
  void onInit() {
    fetchUserNotifications(page: 1, pageSize: pageSize);
    super.onInit();
  }
}
