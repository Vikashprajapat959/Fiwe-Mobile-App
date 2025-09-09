import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/video_room_controller.dart';

class ControlBar extends StatelessWidget {
  final VideoRoomController controller;
  
  const ControlBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Microphone toggle button
          Obx(() {
            return IconButton(
              iconSize: 30,
              icon: Icon(
                controller.isMicOn ? Icons.mic : Icons.mic_off,
                color: controller.isMicOn ? Colors.white : Colors.red,
              ),
              onPressed: controller.toggleMic,
            );
          }),
          
          // Camera toggle button
          Obx(() {
            return IconButton(
              iconSize: 30,
              icon: Icon(
                controller.isCameraOn ? Icons.videocam : Icons.videocam_off,
                color: controller.isCameraOn ? Colors.white : Colors.red,
              ),
              onPressed: controller.toggleCamera,
            );
          }),
          
          // Emoji reactions
          IconButton(
            icon: const Text('👍', style: TextStyle(fontSize: 24)),
            onPressed: () => controller.sendReaction('👍'),
          ),
          IconButton(
            icon: const Text('👏', style: TextStyle(fontSize: 24)),
            onPressed: () => controller.sendReaction('👏'),
          ),
          IconButton(
            icon: const Text('😂', style: TextStyle(fontSize: 24)),
            onPressed: () => controller.sendReaction('😂'),
          ),
          IconButton(
            icon: const Text('❤️', style: TextStyle(fontSize: 24)),
            onPressed: () => controller.sendReaction('❤️'),
          ),
          
          // Leave room button
          ElevatedButton(
            onPressed: controller.leaveRoom,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'Leave',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}