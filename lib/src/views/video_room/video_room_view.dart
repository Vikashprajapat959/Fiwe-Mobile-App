import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:get/get.dart';
import 'package:hms_room_kit/hms_room_kit.dart';

import '../../controllers/video_room_controller.dart';

class VideoRoomView extends StatelessWidget {
  const VideoRoomView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VideoRoomController());

    return Scaffold(
      backgroundColor: Colors.grey[900],
      // appBar: AppBar(
      //   title: Obx(() => Text(controller.currentRoom?.title ?? 'Video Room')),
      //   backgroundColor: Colors.grey[800],
      //   foregroundColor: Colors.white,
      //   actions: [
      //     // Occupancy indicator
      //     Obx(() {
      //       final occupancy = controller.remotePeers.length + 1; // +1 for local participant
      //       final maxParticipants = controller.currentRoom?.capacity ?? 5;
      //       return Padding(
      //         padding: const EdgeInsets.all(16.0),
      //         child: Container(
      //           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      //           decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(12)),
      //           child: Text(
      //             '$occupancy/$maxParticipants',
      //             style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      //           ),
      //         ),
      //       );
      //     }),
      //   ],
      // ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // if (!controller.isInRoom) {
        //   return const Center(
        //     child: Text('Not in a room', style: TextStyle(color: Colors.white)),
        //   );
        // }

        // Use HMSPrebuilt widget instead of custom UI
        // Pass the room code and authentication token to HMSPrebuilt
        return WithForegroundTask(
          child: HMSPrebuilt(
            roomCode: controller.currentRoom?.roomHostCode ?? '',
            authToken: controller.currentRoom?.joinToken ?? '',
            options: HMSPrebuiltOptions(userName: Get.routing.args?['userName'] ?? ''),

            onLeave: () {
              controller.leaveRoom();
            },
          ),
        );
      }),
    );
  }
}
