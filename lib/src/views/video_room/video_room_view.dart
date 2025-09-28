import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:get/get.dart';
import 'package:hms_room_kit/hms_room_kit.dart';

import '../../controllers/video_room_controller.dart';

class VideoRoomView extends StatefulWidget {
  const VideoRoomView({super.key});

  @override
  State<VideoRoomView> createState() => _VideoRoomViewState();
}

class _VideoRoomViewState extends State<VideoRoomView> with WidgetsBindingObserver {
  late VideoRoomController controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller = Get.put(VideoRoomController());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      // Add floating action button for manual PIP entry (for testing)
      // floatingActionButton: Obx(() {
      //   if (!controller.isInRoom) return const SizedBox.shrink();

      //   return Column(
      //     mainAxisSize: MainAxisSize.min,
      //     children: [
      //       // PIP toggle button
      //       FloatingActionButton(
      //         mini: true,
      //         heroTag: "pip",
      //         onPressed: () {
      //           if (controller.isPipActive) {
      //             controller.exitPipMode();
      //           } else {
      //             controller.enterPipMode();
      //           }
      //         },
      //         child: Icon(
      //           controller.isPipActive ? Icons.fullscreen : Icons.picture_in_picture,
      //         ),
      //       ),
      //       const SizedBox(height: 8),
      //       // Debug info button (only in debug mode)
      //       if (kDebugMode)
      //         FloatingActionButton(
      //           mini: true,
      //           heroTag: "debug",
      //           onPressed: () {
      //             _showDebugInfo(context);
      //           },
      //           child: const Icon(Icons.info),
      //         ),
      //     ],
      //   );
      // }),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!controller.isInRoom) {
          return const Center(
            child: Text('Not in a room', style: TextStyle(color: Colors.white)),
          );
        }

        // Use HMSPrebuilt widget instead of custom UI
        // Pass the room code and authentication token to HMSPrebuilt
        return WithForegroundTask(
          child: HMSPrebuilt(
            roomCode: controller.currentRoom?.roomHostCode ?? '',
            // authToken: controller.currentRoom?.joinToken ?? '',
            options: HMSPrebuiltOptions(userName: Get.routing.args?['userName'] ?? ''),

            onLeave: () {
              controller.leaveRoom();
            },
          ),
        );
      }),
    );
  }

  /// Show debug information dialog
  void _showDebugInfo(BuildContext context) {
    final debugInfo = controller.getDebugInfo();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Debug Information'),
        content: SingleChildScrollView(
          child: Text(
            debugInfo.entries.map((e) => '${e.key}: ${e.value}').join('\n'),
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
      ),
    );
  }
}
