import 'package:fiwe/src/models/room_history.dart';
import 'package:fiwe/src/repositories/room_repository.dart';
import 'package:fiwe/src/utils/assets.dart';
import 'package:fiwe/src/utils/colors.dart';
import 'package:fiwe/src/utils/helper.dart';
import 'package:fiwe/src/widgets/app_back_button.dart';
import 'package:flutter/material.dart';

class RoomDetailView extends StatelessWidget {
  const RoomDetailView({super.key, required this.room});
  final Room room;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: RoomRepository.instance.getRoomDetailById(room.roomId),
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (asyncSnapshot.hasError) {
            return Center(child: Text('Error: ${asyncSnapshot.error}'));
          }
          if (!asyncSnapshot.hasData) {
            return const Center(child: Text('No data found.'));
          }
          final roomDetail = asyncSnapshot.data!.data!;

          final highestRatedParticipant = roomDetail.participant.isNotEmpty
              ? roomDetail.participant.reduce((a, b) => a.totalRating! > b.totalRating! ? a : b)
              : null;
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 300,
                floating: false,
                backgroundColor: Colors.white,
                leading: const Padding(
                  padding: EdgeInsets.all(6.0),
                  child: AppBackButton(theme: BackButtonTheme.light),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.memory(Helper.base64ToBytes(room.topic?.avatar), fit: BoxFit.cover),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Text(
                      room.topic?.name ?? 'Unknown',
                      style: const TextStyle(fontSize: 18, color: AppColors.primary, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),

                    // Title
                    Text(
                      room.description ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Creator Info
                    CreatorInfo(imageBytes: room.creator?.avatar ?? '', name: room.creator?.name ?? 'Unknown'),
                    const SizedBox(height: 24),

                    // Winner Section
                    // WinnerCard(
                    //   imageBytes: roomDetail.participant.isNotEmpty
                    //       ? roomDetail.participant.reduce((a, b) => a.totalRating > b.totalRating ? a : b).profileBase64
                    //       : null,
                    //   name: roomDetail.participant.isNotEmpty
                    //       ? (roomDetail.participant.reduce((a, b) => a.totalRating > b.totalRating ? a : b).name ??
                    //             'Unknown')
                    //       : 'Unknown',
                    //   points: roomDetail.participant.isNotEmpty
                    //       ? roomDetail.participant.reduce((a, b) => a.totalRating > b.totalRating ? a : b).totalRating
                    //       : 0,
                    // ),
                    if (highestRatedParticipant != null) ...[
                      WinnerCard(
                        imageBytes: highestRatedParticipant.profileBase64,
                        name: highestRatedParticipant.name ?? '',
                        points: highestRatedParticipant.totalRating ?? 0,
                      ),
                      const SizedBox(height: 24),
                    ],
                    // Participate Section
                    const Text(
                      'Participants',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                    const SizedBox(height: 16),
                    ...roomDetail.participant.map(
                      (participant) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ParticipantItem(
                            imageBytes: participant.profileBase64,
                            name: participant.name ?? '',
                            subtitle: participant.userId == room.creator?.id ? 'Creator' : null,
                            points: participant.totalRating.toString(),
                            hasBadge: true,
                          ),
                          if (participant != roomDetail.participant.last) const Divider(height: 32),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class CreatorInfo extends StatelessWidget {
  const CreatorInfo({super.key, required this.imageBytes, required this.name});
  final String imageBytes;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundImage: MemoryImage(Helper.base64ToBytes(imageBytes)),
          backgroundColor: Colors.grey[300],
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Created By', style: TextStyle(fontSize: 12, color: AppColors.primary)),
            Text(
              name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
          ],
        ),
      ],
    );
  }
}

class WinnerCard extends StatelessWidget {
  const WinnerCard({super.key, required this.imageBytes, required this.name, required this.points});
  final String? imageBytes;
  final String name;
  final double points;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.secondaryYellow.withAlpha(50),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.secondaryYellow.withAlpha(125), width: 1),
          ),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: MemoryImage(Helper.base64ToBytes(imageBytes)),
                    backgroundColor: Colors.grey[300],
                  ),

                  Positioned(right: 0, child: Image.asset(Assets.icons.starBadge, width: 20)),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: AppColors.secondaryYellow, borderRadius: BorderRadius.circular(30)),
                child: Text(
                  '$points PTS',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        ),

        Positioned(
          top: 0,
          left: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(color: AppColors.secondaryYellow, borderRadius: BorderRadius.circular(4)),
            child: const Text(
              'Winner',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.background),
            ),
          ),
        ),
      ],
    );
  }
}

class ParticipantItem extends StatelessWidget {
  const ParticipantItem({
    super.key,
    required this.imageBytes,
    required this.name,
    this.subtitle,
    required this.points,
    this.hasBadge = false,
  });
  final String? imageBytes;
  final String name;
  final String? subtitle;
  final String points;
  final bool hasBadge;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: MemoryImage(Helper.base64ToBytes(imageBytes)),
              backgroundColor: Colors.grey[300],
            ),
            if (hasBadge) Positioned(right: 0, child: Image.asset(Assets.icons.starBadge, width: 20)),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
              if (subtitle != null) Text(subtitle!, style: const TextStyle(fontSize: 12, color: Color(0xFF00A8CC))),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(color: AppColors.secondaryYellow, borderRadius: BorderRadius.circular(20)),
          child: Text(
            '$points PTS',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
