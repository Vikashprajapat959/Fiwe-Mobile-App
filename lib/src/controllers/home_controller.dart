// lib/src/controllers/home_controller.dart

import 'dart:developer' as dev;

import 'package:fiwe/src/controllers/auth_controller.dart';
import 'package:fiwe/src/controllers/commune_controller.dart';
import 'package:fiwe/src/controllers/video_room_controller.dart';
import 'package:fiwe/src/models/fcm_notification_data.dart';
import 'package:fiwe/src/models/hmsvideo_room.dart';
import 'package:fiwe/src/models/standard_api_response.dart';
import 'package:fiwe/src/models/topic.model.dart';
import 'package:fiwe/src/models/user_model.dart';
import 'package:fiwe/src/repositories/room_repository.dart';
import 'package:fiwe/src/services/fcm_notification_service.dart';
import 'package:fiwe/src/services/topic_service.dart';
import 'package:fiwe_notification/fiwe_notification.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class HomeController extends GetxController {
  // Reactive States for Home Screen Data
  final RxInt pageIndex = 0.obs;
  final RxList<Topic> userTopics = <Topic>[].obs;
  final RxList<HMSVideoRoom> activeRooms = <HMSVideoRoom>[].obs;
  final RxBool isActiveRoomsLoading = true.obs;

  // Dependencies and Services
  final TopicService _topicService = Get.find<TopicService>();
  final RoomRepository roomRepository = RoomRepository.instance;
  late FCMNotificationService _notificationService;

  // Get user profile from AuthController
  User? get user => Get.find<AuthController>().userProfile();

  // Context for In-App Notifications
  BuildContext? _context;

  static HomeController get instance => Get.find<HomeController>();

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
    Get.put(CommuneController(), permanent: true);
    _notificationService = FCMNotificationService.instance;
    super.onInit();
  }

  @override
  void onReady() {
    fetchInitialData();

    dev.log('HomeController onReady called', name: 'HomeController');
    _notificationService.roomInviteStream.listen((event) {
      dev.log('Received notification event: ${event.title}', name: 'HomeController');
      _showRoomInviteNotification(event);
    });

    super.onReady();
  }

  // Combined Initial Data Fetch (Centralized Data Loading)
  Future<void> fetchInitialData() async {
    // Fetch active rooms and user topics simultaneously
    await Future.wait([
      _fetchActiveRoomsForHome(),
      getAllUserTopics().catchError((error) {
        dev.log('Error fetching user topics: $error', name: 'HomeController');
      }),
    ]);

    // Check for previous active room after initial data is loaded
    await fetchActiveRoomDetails();
  }

  // Reactive Active Rooms Fetch
  Future<void> _fetchActiveRoomsForHome() async {
    isActiveRoomsLoading.value = true;
    try {
      final response = await roomRepository.getActiveRooms();
      if (response.success && response.data != null) {
        dev.log('Active rooms fetched successfully: ${response.data!.length}', name: 'HomeController');
        activeRooms.assignAll(response.data!); // Populate reactive list
      } else {
        dev.log('No active rooms found or failed to fetch: ${response.message}', name: 'HomeController');
        activeRooms.clear();
      }
    } catch (e) {
      dev.log('Error fetching active rooms: $e', name: 'HomeController');
      activeRooms.clear();
    } finally {
      isActiveRoomsLoading.value = false;
    }
  }

  Future<List<HMSVideoRoom>> getActiveRooms() async {
    try {
      final response = await roomRepository.getActiveRooms();
      if (response.success && response.data != null) {
        dev.log('Non-reactive Active rooms fetched successfully: ${response.data!.length}', name: 'HomeController');
        return response.data!;
      } else {
        throw Exception('No active rooms found or failed to fetch: ${response.message}');
      }
    } catch (e) {
      dev.log('Error fetching active rooms non-reactive: $e', name: 'HomeController');
      rethrow;
    }
  }

  // User Topics Fetch
  Future<void> getAllUserTopics() async {
    try {
      final result = await _topicService.getTopicsFollowedByUser().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          dev.log('Timeout fetching user topics', name: 'HomeController');
          return ApiResponse<List<Topic>>.error(message: 'Timeout fetching user topics');
        },
      );
      userTopics(result.data ?? []); // Populate reactive list
    } catch (e) {
      dev.log('Error in getAllUserTopics: $e', name: 'HomeController');
      userTopics(<Topic>[]);
    }
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
                dev.log('Dismiss action pressed for room: ${inviteData.roomId}', name: 'HomeController');
              },
            ),
            NotificationAction(
              label: 'Join',
              onPressed: () {
                InAppNotificationManager.dismissAll();
                final controller = Get.find<VideoRoomController>();
                controller.joinRoom(inviteData, user?.name ?? 'Guest');
                dev.log('Join action pressed for room: ${inviteData.roomGuestCode}', name: 'HomeController');
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
      final response = await roomRepository.getActiveRoomDetails();
      if (response.success && response.data != null) {
        dev.log('Active room details fetched successfully: ${response.data!.title}', name: 'HomeController');
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
            InAppNotificationManager.dismiss();
            controller.leaveRoom();
          },
          actions: [
            NotificationAction(
              label: 'Dismiss',
              style: NotificationActionStyle.secondary,
              onPressed: () {
                InAppNotificationManager.dismissAll();
                controller.leaveRoom();
              },
            ),
            NotificationAction(
              label: 'Join',
              onPressed: () {
                InAppNotificationManager.dismiss();

                // FIX: Added required 'body' and 'type' fields.
                final inviteData = RoomInviteData(
                  roomId: room.objectId,
                  // Required fields from your FCMNotificationData model:
                  title: 'Rejoin Room', // Use the notification title
                  body: 'Rejoining active room: ${room.title}', // Use a descriptive body
                  type: 'roomInvite', // Set the type string as expected by your model
                  // Ensure these are Non-nullable Strings
                  roomGuestCode: room.roomGuestCode?.toString() ?? '',
                  roomHostCode: room.roomHostCode?.toString() ?? '',

                  inviteeName: user?.name ?? 'Guest',
                  deepLink: '',
                  expiry: null,
                  topicDetails: null,
                  userDetails: null,
                );

                controller.joinRoom(inviteData, isPreviousSession: true, user?.name ?? 'Guest');
              },
            ),
          ],
        ),
      );
    } else {
      dev.log('No context available to show rejoin room notification for room: ${room.title}', name: 'HomeController');
    }
  }
}
