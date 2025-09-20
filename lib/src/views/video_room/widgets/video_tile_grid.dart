// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:hmssdk_flutter/hmssdk_flutter.dart';

// import '../../../controllers/video_room_controller.dart';
// import '../../../services/hms_room_service.dart';
// //import 'video_tile.dart';

// class VideoTileGrid extends StatelessWidget {
//   final VideoRoomController controller;

//   const VideoTileGrid({super.key, required this.controller});

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<HMSLocalPeer?>(
//       future: _getLocalPeer(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         final localPeer = snapshot.data;

//         return Obx(() {
//           // Get remote peers from the controller
//           final remotePeers = controller.remotePeers;

//           // Create a list of all peers (local + remote)
//           final allPeers = <HMSPeer>[...remotePeers];
//           if (localPeer != null) {
//             allPeers.insert(0, localPeer);
//           }

//           if (allPeers.isEmpty) {
//             return const Center(
//               child: Text('No participants in the room', style: TextStyle(color: Colors.white)),
//             );
//           }

//           // Calculate grid layout based on number of participants
//           int crossAxisCount;
//           if (allPeers.length == 1) {
//             crossAxisCount = 1;
//           } else if (allPeers.length <= 4) {
//             crossAxisCount = 2;
//           } else {
//             crossAxisCount = 3;
//           }

//           return GridView.builder(
//             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: crossAxisCount,
//               crossAxisSpacing: 8,
//               mainAxisSpacing: 8,
//               childAspectRatio: 0.75, // Adjust aspect ratio for video tiles
//             ),
//             itemCount: allPeers.length,
//             itemBuilder: (context, index) {
//               final peer = allPeers[index];
//               return null;
//               // return VideoTile(peer: peer);
//             },
//           );
//         });
//       },
//     );
//   }

//   // Future<HMSLocalPeer?> _getLocalPeer() async {
//   //   final videoRoomService = Get.find<HMSRoomService>();
//   //   return videoRoomService.getLocalPeer();
//   // }
// }
