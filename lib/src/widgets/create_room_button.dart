import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/video_room_controller.dart';

class CreateRoomButton extends StatelessWidget {
  const CreateRoomButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _createRoom(context),
      child: const Text('Create Video Room'),
    );
  }

  void _createRoom(BuildContext context) {
    final controller = Get.put(VideoRoomController());
    
    // Show dialog to enter room title
    _showCreateRoomDialog(context, controller);
  }

  void _showCreateRoomDialog(BuildContext context, VideoRoomController controller) {
    final titleController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create Video Room'),
          content: TextField(
            controller: titleController,
            decoration: const InputDecoration(
              hintText: 'Enter room title',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  Navigator.of(context).pop();
                  controller.createRoom(titleController.text);
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}