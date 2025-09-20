import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/video_room_controller.dart';

class DeepLinkService extends GetxService {
  static DeepLinkService get instance => Get.find<DeepLinkService>();

  late StreamSubscription _linkSubscription;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Handle incoming deep links
  void handleDeepLink(String? link) {
    if (link == null) return;

    try {
      final uri = Uri.parse(link);

      // Check if this is our custom scheme
      if (uri.scheme.contains("fiwe") && uri.host == 'room') {
        // Extract room ID from path
        final pathSegments = uri.pathSegments;
        if (pathSegments.isNotEmpty) {
          final roomId = pathSegments[0];
          _handleVideoRoomLink(roomId);
        }
      }
    } catch (e) {
      dev.log('Error parsing deep link: $e', name: 'DeepLinkService');
    }
  }

  /// Handle room invite deep link
  void handleRoomInviteLink(String roomId) {
    try {
      dev.log('Handling room invite link for room: $roomId', name: 'DeepLinkService');

      // Join the room using VideoRoomController
      VideoRoomController.instance.joinRoom(roomId, 'User');

      // Navigate to the room view
      navigatorKey.currentState?.pushNamed('/room/$roomId');
    } catch (e) {
      dev.log('Error handling room invite link: $e', name: 'DeepLinkService');
      Get.snackbar('Error', 'Failed to join video room: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  void onClose() {
    _linkSubscription.cancel();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    _initDeepLinks();
  }

  /// Handle video room deep link
  void _handleVideoRoomLink(String roomId) {
    try {
      dev.log('Handling video room link for room: $roomId', name: 'DeepLinkService');

      // Navigate using go_router
      navigatorKey.currentState?.pushNamed('/room/$roomId');

      // Also join the room using VideoRoomController
      VideoRoomController.instance.joinRoom(roomId, 'User');
    } catch (e) {
      dev.log('Error handling video room link: $e', name: 'DeepLinkService');
      Get.snackbar('Error', 'Failed to join video room: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  /// Initialize deep link handling
  void _initDeepLinks() async {
    try {
      // For go_router, we would typically handle deep links in the router configuration
      // This service can be used to handle specific deep link logic if needed
      dev.log('Deep link service initialized with go_router', name: 'DeepLinkService');
    } catch (e) {
      dev.log('Error initializing deep links: $e', name: 'DeepLinkService');
    }
  }
}
