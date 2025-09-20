import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/video_room_controller.dart';
import 'widgets/control_bar.dart';
import 'widgets/reaction_overlay.dart';
import 'widgets/video_tile_grid.dart';

class VideoRoomView extends StatelessWidget {
  const VideoRoomView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VideoRoomController());

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Obx(() => Text(controller.currentRoom?.title ?? 'Video Room')),
        backgroundColor: Colors.grey[800],
        foregroundColor: Colors.white,
        actions: [
          // Occupancy indicator
          Obx(() {
            final occupancy = controller.remotePeers.length + 1; // +1 for local participant
            final maxParticipants = controller.currentRoom?.maxParticipants ?? 5;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(12)),
                child: Text(
                  '$occupancy/$maxParticipants',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!controller.isInRoom) {
          return const Center(
            child: Text('Not in a room', style: TextStyle(color: Colors.white)),
          );
        }

        return Stack(
          children: [
            // Main content
            Column(
              children: [
                // Video tiles grid
                Expanded(child: VideoTileGrid(controller: controller)),

                // Controls
                ControlBar(controller: controller),
              ],
            ),

            // Reaction overlay
            const ReactionOverlay(),
          ],
        );
      }),
    );
  }
}
