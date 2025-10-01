import 'dart:developer';
import 'dart:typed_data';

import 'package:fiwe/src/controllers/home_controller.dart';
import 'package:fiwe/src/models/hmsvideo_room.dart';
import 'package:fiwe/src/utils/app_text_styles.dart';
import 'package:fiwe/src/utils/colors.dart';
import 'package:fiwe/src/utils/constants.dart';
import 'package:fiwe/src/utils/helper.dart';
import 'package:fiwe/src/views/home/user_notification_view.dart';
import 'package:fiwe/src/views/profile/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// Controller for managing state

// Main Home Screen
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find();
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary.withAlpha(20), AppColors.secondaryYellow.withAlpha(20)],
              stops: const [0.0, .4],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                _buildHeader(),
                const SizedBox(height: 24),

                // Face of Week Section
                _buildFaceOfWeekSection(),
                const SizedBox(height: 32),

                // Active Room Section
                _buildActiveRoomSection(),
                const SizedBox(height: 32),

                // Trending Section
                _buildTrendingSection(),
                const SizedBox(height: 32),

                // Interests Section
                _buildInterestsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final HomeController controller = Get.find();
    return Row(
      children: [
        ProfileAvatar(imageUrl: controller.user?.profileBase64 ?? '', size: 48),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('${controller.user?.name}', style: AppTextStyles.headerTitle),
                  const SizedBox(width: 4),
                  const Icon(Icons.star, color: AppColors.orange, size: 16),
                ],
              ),
              Row(
                children: [
                  Text(
                    controller.user?.topics?.firstWhereOrNull((t) => t.isPrimary ?? false)?.title ?? 'No Interest',
                    style: AppTextStyles.subtitle,
                  ),
                  const Icon(Icons.star, color: AppColors.orange, size: 12),
                  const Text('4.5', style: AppTextStyles.subtitle),
                ],
              ),
            ],
          ),
        ),
        Row(
          children: [
            ActionButton(icon: const Icon(Icons.map_outlined), onTap: () {}),
            const SizedBox(width: 8),
            ActionButton(
              icon: const Icon(LucideIcons.bell, color: AppColors.secondaryYellow),
              onTap: () {
                Get.to(() => const UserNotificationView());
              },
              hasNotification: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFaceOfWeekSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Face of Week', style: AppTextStyles.sectionTitle),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              return FaceOfWeekCard(
                name: ['Hawkins', 'Lane', 'Fox', 'Edwards', 'Richa'][index],
                rating: [4.5, 4.1, 4.2, 3.9, 4.0][index],
                imageUrl: 'assets/face_$index.jpg',
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActiveRoomSection() {
    return FutureBuilder<List<HMSVideoRoom>>(
      future: HomeController.instance.getActiveRooms(),
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: LinearProgressIndicator());
        } else if (asyncSnapshot.connectionState == ConnectionState.done && asyncSnapshot.hasError) {
          return Center(child: Text('Error: ${asyncSnapshot.error}'));
        } else {
          final rooms = asyncSnapshot.data;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Active Room', style: AppTextStyles.sectionTitle),
                  TextButton(
                    onPressed: () {},
                    child: const Text('View All', style: AppTextStyles.viewAll),
                  ),
                ],
              ),

              // const SizedBox(height: 8),
              // ListView.separated(
              //   scrollDirection: Axis.horizontal,
              //   itemCount: 3,
              //   shrinkWrap: true, // measure to children in scrollDirection
              //   primary: false,
              //   separatorBuilder: (context, index) => const SizedBox(width: 14),
              //   itemBuilder: (context, index) {
              //     return RoomCard(
              //       roomName: 'Room name',
              //       createdBy: 'John Smit',
              //       joinedUsers: '3/5',
              //       imageUrl: 'assets/room_$index.jpg',
              //     );
              //   },
              // ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  spacing: 14,
                  children: List.generate(3, (index) {
                    return RoomCard(
                      roomName: rooms![index].title,
                      createdBy: rooms[index].creator?.name ?? '',
                      joinedUsers: '${rooms[index].currentOccupancy}/${rooms[index].capacity ?? 5}',
                      imageUrl: rooms[index].topic?.thumbnail ?? '',
                    );
                  }),
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildTrendingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Trending', style: AppTextStyles.sectionTitle),
            TextButton(
              onPressed: () {},
              child: const Text('View All', style: AppTextStyles.viewAll),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              return TrendingCard(
                roomName: 'Room name',
                interestName: 'Interest Name',
                category: 'Music',
                createdRooms: 5,
                imageUrl: 'assets/trending_$index.jpg',
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInterestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Interests', style: AppTextStyles.sectionTitle),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              return InterestCard(
                title: ['Fashion/lifestyle', 'Makeup/cosmetics', 'Sports'][index],
                rating: 4.5,
                imageUrl: 'assets/interest_$index.jpg',
              );
            },
          ),
        ),
      ],
    );
  }
}

// Reusable Components

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, required this.imageUrl, this.size = 48});
  final String imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    log(imageUrl);
    return GestureDetector(
      onTap: () {
        Get.to(() => const ProfileScreen());
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.lightGray,
          image: DecorationImage(
            image: MemoryImage(Helper.base64ToBytes(imageUrl) ?? Uint8List(255)),
            fit: BoxFit.cover,
            onError: (exception, stackTrace) {},
          ),
        ),
        child: imageUrl.isEmpty ? Icon(Icons.person, color: AppColors.gray, size: size * 0.6) : null,
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.hasNotification = false,
    this.notificationCount,
  });
  final Widget icon;
  final VoidCallback onTap;
  final bool hasNotification;
  final String? notificationCount;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.all(2),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary.withAlpha(90), width: 2),
              color: AppColors.primary.withAlpha(50),
              borderRadius: BorderRadius.circular(16),
            ),
            child: icon,
          ),
        ),
        if (hasNotification)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 16,
              height: 16,

              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 1),
                color: AppColors.errorBorder,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  '2',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class FaceOfWeekCard extends StatelessWidget {
  const FaceOfWeekCard({super.key, required this.name, required this.rating, required this.imageUrl});
  final String name;
  final double rating;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.lightGray,
                image: DecorationImage(
                  image: AssetImage(imageUrl),
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) {},
                ),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(color: AppColors.orange, shape: BoxShape.circle),
                child: const Icon(Icons.star, color: Colors.white, size: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(name, style: AppTextStyles.cardName),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, color: AppColors.orange, size: 12),
            const SizedBox(width: 2),
            Text(rating.toString(), style: AppTextStyles.rating),
          ],
        ),
      ],
    );
  }
}

class RoomCard extends StatelessWidget {
  const RoomCard({
    super.key,
    required this.roomName,
    required this.createdBy,
    required this.joinedUsers,
    required this.imageUrl,
  });
  final String roomName;
  final String createdBy;
  final String joinedUsers;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(16), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      alignment: Alignment.topCenter,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Container(
                height: 120,
                width: 150,
                decoration: BoxDecoration(
                  color: AppColors.lightGray,
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  image: DecorationImage(
                    image: MemoryImage(Helper.base64ToBytes(imageUrl) ?? Uint8List(255)),
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) {},
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: AppColors.teal, borderRadius: BorderRadius.circular(6)),
                  child: const Icon(Icons.accessibility, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 35,
                  child: Text(roomName, style: AppTextStyles.cardTitle, overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Created by ', style: AppTextStyles.cardSubtitle),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(createdBy, style: AppTextStyles.cardSubtitleBold, textAlign: TextAlign.end),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Text('Joined User', style: AppTextStyles.cardSubtitle),
                    const Spacer(),
                    Text(joinedUsers, style: AppTextStyles.cardSubtitleBold),
                  ],
                ),
                const SizedBox(height: 12),
                GradientButton(text: 'Join Now', onPressed: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TrendingCard extends StatelessWidget {
  const TrendingCard({
    super.key,
    required this.roomName,
    required this.interestName,
    required this.category,
    required this.createdRooms,
    required this.imageUrl,
  });
  final String roomName;
  final String interestName;
  final String category;
  final int createdRooms;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.lightGray,
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: AssetImage(imageUrl),
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) {},
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.teal, borderRadius: BorderRadius.circular(12)),
                  child: Text('Created Rooms $createdRooms', style: AppTextStyles.badge),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(roomName, style: AppTextStyles.cardTitle),
          Text(interestName, style: AppTextStyles.cardSubtitle),
          Text(category, style: AppTextStyles.cardSubtitleBold),
        ],
      ),
    );
  }
}

class InterestCard extends StatelessWidget {
  const InterestCard({super.key, required this.title, required this.rating, required this.imageUrl});
  final String title;
  final double rating;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.lightGray,
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: AssetImage(imageUrl),
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) {},
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: AppColors.orange, shape: BoxShape.circle),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.white, size: 12),
                      const SizedBox(width: 2),
                      Text(
                        rating.toString(),
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(title, style: AppTextStyles.cardTitle, maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class GradientButton extends StatelessWidget {
  const GradientButton({super.key, required this.text, required this.onPressed});
  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: 35,
        decoration: BoxDecoration(
          gradient: Constants.gradientDecoration.gradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(child: Text(text, style: AppTextStyles.buttonText)),
      ),
    );
  }
}
