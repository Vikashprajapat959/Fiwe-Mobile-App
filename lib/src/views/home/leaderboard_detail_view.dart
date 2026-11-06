import 'package:fiwe/src/utils/assets.dart';
import 'package:fiwe/src/utils/colors.dart';
import 'package:fiwe/src/utils/constants.dart';
import 'package:fiwe/src/utils/helper.dart';
import 'package:fiwe/src/widgets/app_back_button.dart';
import 'package:flutter/material.dart';

class LeaderboardDetailView extends StatelessWidget {
  const LeaderboardDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final topThree = [
      LeaderboardData(
        rank: 2,
        name: 'Jenny Wilson',
        rating: 4.5,
        points: '10PTS',
        imageBytes: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d',
        medalColor: Colors.grey,
      ),
      LeaderboardData(
        rank: 1,
        name: 'Esther Howard',
        rating: 4.5,
        points: '10PTS',
        imageBytes: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e',
        medalColor: const Color(0xFFFFD700),
      ),
      LeaderboardData(
        rank: 3,
        name: 'Guy Hawkins',
        rating: 4.5,
        points: '10PTS',
        imageBytes: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d',
        medalColor: const Color(0xFFCD7F32),
      ),
    ];

    final remainingList = List.generate(
      5,
      (index) => LeaderboardData(
        rank: index + 4,
        name: 'Leslie Alexander',
        rating: 4.5,
        points: '10PTS',
        imageBytes: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6',
      ),
    );

    return Scaffold(
      body: Column(
        children: [
          // Top Section with Gradient and Podium
          Container(
            decoration: BoxDecoration(
              gradient: Constants.gradientDecoration.gradient,
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Header
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Row(
                      children: [
                        AppBackButton(theme: BackButtonTheme.light),
                        Expanded(
                          child: Center(
                            child: Text(
                              'Leaderboard',
                              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        SizedBox(width: 48),
                      ],
                    ),
                  ),

                  // Podium
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 32, top: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Second Place
                        PodiumItem(data: topThree[0], size: 80, isTop: false),

                        // First Place
                        PodiumItem(data: topThree[1], size: 100, isTop: true),

                        // Third Place
                        PodiumItem(data: topThree[2], size: 80, isTop: false),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // List Section
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: remainingList.length,
              itemBuilder: (context, index) {
                return LeaderboardListItem(data: remainingList[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class LeaderboardData {
  LeaderboardData({
    required this.rank,
    required this.name,
    required this.rating,
    required this.points,
    required this.imageBytes,
    this.medalColor,
  });
  final int rank;
  final String name;
  final double rating;
  final String points;
  final String? imageBytes;
  final Color? medalColor;
}

class PodiumItem extends StatelessWidget {
  const PodiumItem({super.key, required this.data, required this.size, this.isTop = false});
  final LeaderboardData data;
  final double size;
  final bool isTop;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _getRankColor(data.rank), width: 2),
                image: DecorationImage(image: MemoryImage(Helper.base64ToBytes(data.imageBytes)), fit: BoxFit.cover),
              ),
            ),

            Positioned(top: 0, right: 0, child: Image.asset(_getBaggeIcon(data.rank), width: data.rank == 1 ? 30 : 25)),
            Positioned(
              bottom: -14,

              child: Center(
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    //lighter shade
                    color: _getRankColor(data.rank),
                    shape: BoxShape.circle,
                    border: Border.all(color: Helper.darken(_getRankColor(data.rank), 0.05), width: 2),
                  ),
                  child: Center(
                    child: Text(
                      '${data.rank}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          data.name,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, color: AppColors.secondaryYellow, size: 14),
            const SizedBox(width: 2),
            Text(data.rating.toString(), style: const TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(color: _getRankColor(data.rank), borderRadius: BorderRadius.circular(20)),
          child: Text(
            data.points,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        if (data.rank == 1 && isTop) const SizedBox(height: 30),
      ],
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return AppColors.secondaryYellow; // Gold
      case 2:
        return AppColors.silver; // Silver
      case 3:
        return AppColors.bronze; // Bronze
      default:
        return Colors.white; // Default
    }
  }

  String _getBaggeIcon(int rank) {
    switch (rank) {
      case 1:
        return Assets.icons.starBadge;
      case 2:
        return Assets.icons.silverMedal;
      case 3:
        return Assets.icons.bronzeMedal;
      default:
        throw Exception('Invalid rank for badge icon');
    }
  }
}

class LeaderboardListItem extends StatelessWidget {
  const LeaderboardListItem({super.key, required this.data});
  final LeaderboardData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          // Rank Number
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
            child: Center(
              child: Text(
                '${data.rank}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Avatar with Badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(image: MemoryImage(Helper.base64ToBytes(data.imageBytes)), fit: BoxFit.cover),
                ),
              ),
              Positioned(top: -4, right: -4, child: Image.asset(Assets.icons.starBadge, width: 18)),
            ],
          ),
          const SizedBox(width: 12),

          // Name and Rating
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.name,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Color(0xFFFF9800), size: 14),
                    const SizedBox(width: 4),
                    Text(data.rating.toString(), style: const TextStyle(fontSize: 14, color: Colors.black54)),
                  ],
                ),
              ],
            ),
          ),

          // Points Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: const Color(0xFFFF9800), borderRadius: BorderRadius.circular(20)),
            child: Text(
              data.points,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
