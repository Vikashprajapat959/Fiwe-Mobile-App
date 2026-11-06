import 'dart:developer';

import 'package:fiwe/src/models/user_model.dart';
import 'package:fiwe/src/models/user_notification.dart';
import 'package:fiwe/src/services/user_service.dart';
import 'package:get/get.dart';

class UserNotificationController extends GetxController {
  var notifications = <UserNotification>[].obs;
  var isLoading = false.obs;
  var page = 1;
  var pageSize = 20;
  var hasMore = true.obs;
  var isLoadingMore = false.obs;

  /// Fetch notifications with proper image fallback
  Future<void> fetchUserNotifications({int? page, int? pageSize}) async {
    if (isLoading.value || !hasMore.value) return;

    isLoading.value = true;

    try {
      // ✅ Pass page and pageSize to service
      final response = await UserService.instance.fetchUserNotifications(
        page: page ?? this.page,
        pageSize: pageSize ?? this.pageSize,
      );

      if (response.success && response.data != null) {
        final UserNotificationPage notificationPage = response.data!;

        if (notificationPage.notifications.isNotEmpty) {
          final updatedNotifications = await Future.wait(
            notificationPage.notifications.map((notification) async {
              // ✅ Use API image if available
              if (notification.profileImageUrl != null && notification.profileImageUrl!.isNotEmpty) {
                return notification;
              }

              // Try to get creatorId from actionData
              final creatorId =
                  notification.actionData?['creator_id'] as String? ??
                  notification.actionData?['user_id'] as String? ??
                  notification.actionData?['userId'] as String? ??
                  notification.actionData?['creatorId'] as String?;

              if (creatorId != null && creatorId.isNotEmpty) {
                User? userProfile;
                try {
                  userProfile = await UserService.instance.fetchUser(creatorId);
                } catch (e) {
                  log('Error fetching user profile for $creatorId: $e');
                }

                // Use userProfile image if available
                if (userProfile != null) {
                  if (userProfile.profileImageUrl != null && userProfile.profileImageUrl!.isNotEmpty) {
                    return notification.copyWith(profileImageUrl: userProfile.profileImageUrl);
                  } else if (userProfile.profileBase64 != null && userProfile.profileBase64!.isNotEmpty) {
                    return notification.copyWith(profileBase64: userProfile.profileBase64);
                  }
                }
              }

              // No image found, return original notification
              return notification;
            }),
          );

          if ((page ?? 1) == 1) {
            notifications.value = updatedNotifications;
          } else {
            notifications.addAll(updatedNotifications);
          }

          hasMore(notificationPage.notifications.length == (pageSize ?? this.pageSize));
          this.page = notificationPage.currentPage + 1;
        } else {
          hasMore(false);
        }
      } else {
        Get.snackbar('Error', response.message ?? 'Failed to fetch notifications.');
      }
    } catch (e, s) {
      log('Notification fetch error: $e', stackTrace: s);
      Get.snackbar('Error', 'Failed to fetch notifications: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch next page for infinite scroll
  void fetchNextPage() {
    if (isLoadingMore.value || !hasMore.value) return;
    isLoadingMore.value = true;
    fetchUserNotifications(page: page, pageSize: pageSize).whenComplete(() {
      isLoadingMore.value = false;
    });
  }

  @override
  void onInit() {
    fetchUserNotifications(page: 1, pageSize: pageSize);
    super.onInit();
  }
}
