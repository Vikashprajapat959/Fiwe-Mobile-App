import 'package:fiwe/src/utils/colors.dart';
import 'package:fiwe/src/utils/helper.dart';
import 'package:fiwe/src/views/history/room_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/room_history_controller.dart';

class RoomHistoryScreen extends StatelessWidget {
  const RoomHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RoomHistoryController());
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'History',
          style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black54),
            onPressed: () {
              controller.fetchRoomHistory();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.roomHistory().rooms == null && controller.roomHistory().rooms!.isEmpty) {
            return const Center(child: Text('No room history available.'));
          }
          if (controller.error.isNotEmpty) {
            return Center(child: Text(controller.error.value));
          }
          final rooms = controller.roomHistory().rooms!;
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Get.to(() => RoomDetailView(room: rooms[index]));
                },
                child: HistoryCard(
                  imageUrl: rooms[index].topic?.avatar ?? '',
                  category: rooms[index].topic?.name ?? 'Unknown',
                  creatorName: rooms[index].creator?.name ?? 'Unknown',
                  joined:
                      '${rooms[index].stats?.totalParticipants}'
                      '/5',
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

class HistoryCard extends StatelessWidget {
  const HistoryCard({
    super.key,
    required this.imageUrl,
    required this.category,
    required this.creatorName,
    required this.joined,
  });
  final String imageUrl;
  final String category;
  final String creatorName;
  final String joined;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(color: AppColors.primary.withAlpha(10), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],

                  image: DecorationImage(image: MemoryImage(Helper.base64ToBytes(imageUrl)), fit: BoxFit.cover),
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: const Color(0xFF4A9DAE), borderRadius: BorderRadius.circular(6)),
                  child: const Icon(Icons.accessibility_new, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
          Text(
            category,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Text('Created by', style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  creatorName,
                  textAlign: TextAlign.end,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF00A8CC), fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Joined User', style: TextStyle(fontSize: 12, color: Colors.grey)),
              Text(
                joined,
                style: const TextStyle(fontSize: 12, color: Color(0xFF00A8CC), fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
