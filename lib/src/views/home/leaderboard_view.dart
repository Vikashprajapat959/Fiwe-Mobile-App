import 'package:fiwe/src/utils/assets.dart';
import 'package:fiwe/src/utils/colors.dart';
import 'package:fiwe/src/utils/constants.dart';
import 'package:fiwe/src/utils/helper.dart';
import 'package:fiwe/src/views/home/leaderboard_detail_view.dart';
import 'package:fiwe/src/widgets/app_back_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LeaderboardView extends StatelessWidget {
  const LeaderboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final leaderboardItems = [
      LeaderboardItemData(
        name: 'Calvin',
        interest: 'Fashion/lifestyle',
        rating: 4.5,
        imageBytes: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d',
      ),
      LeaderboardItemData(
        name: 'Eduardo',
        interest: 'Makeup/cosmetics',
        rating: 4.5,
        imageBytes: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e',
      ),
      LeaderboardItemData(
        name: 'Jacob',
        interest: 'Art/talent',
        rating: 4.5,
        imageBytes: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d',
      ),
      LeaderboardItemData(
        name: 'Guy',
        interest: 'One minute spotlight',
        rating: 4.5,
        imageBytes: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6',
      ),
      LeaderboardItemData(
        name: 'Randall',
        interest: 'One minute spotlight',
        rating: 4.5,
        imageBytes: 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce',
      ),
      LeaderboardItemData(
        name: 'Bruce',
        interest: 'One minute spotlight',
        rating: 4.5,
        imageBytes: 'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04',
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.all(4.0),
          child: AppBackButton(theme: BackButtonTheme.dark),
        ),
        title: const Text(
          'Leaderboard',
          style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: leaderboardItems.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Get.to(() => const LeaderboardDetailView());
            },
            child: LeaderboardItem(data: leaderboardItems[index]),
          );
        },
      ),
    );
  }
}

class LeaderboardItemData {
  LeaderboardItemData({required this.imageBytes, required this.name, required this.interest, required this.rating});
  final String name;
  final String interest;
  final double rating;
  final String imageBytes;
}

class LeaderboardItem extends StatelessWidget {
  const LeaderboardItem({super.key, required this.data});
  final LeaderboardItemData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: Constants.gradientDecoration.gradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1),
              image: DecorationImage(
                image: data.imageBytes.isNotEmpty
                    ? MemoryImage(Helper.base64ToBytes(data.imageBytes))
                    : const NetworkImage('https://via.placeholder.com/150') as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Name, Category, and Rating
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  data.name,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  data.interest,
                  style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.yellow, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      data.rating.toString(),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Badge Icon
          Container(
            width: 44,
            height: 44,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: AppColors.darkText, borderRadius: BorderRadius.circular(10)),
            child: Image.asset(Assets.icons.starBadge),
          ),
        ],
      ),
    );
  }
}
