import 'dart:developer';

import 'package:fiwe/src/controllers/home_controller.dart';
import 'package:fiwe/src/services/http_service.dart';
import 'package:fiwe/src/utils/colors.dart';
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
              stops: [0.0, .4],
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
        ProfileAvatar(imageUrl: controller.user?.profileBase64 ?? "", size: 48),
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
                    controller.user?.topics?.firstWhereOrNull((t) => t.isPrimary ?? false)?.title ?? "No Interest",
                    style: AppTextStyles.subtitle,
                  ),
                  const Icon(Icons.star, color: AppColors.orange, size: 12),
                  Text('4.5', style: AppTextStyles.subtitle),
                ],
              ),
            ],
          ),
        ),
        Row(
          children: [
            ActionButton(icon: Icon(Icons.map_outlined), onTap: () {}),
            const SizedBox(width: 8),
            ActionButton(
              icon: Icon(LucideIcons.bell, color: AppColors.secondaryYellow),
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
        Text('Face of Week', style: AppTextStyles.sectionTitle),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Active Room', style: AppTextStyles.sectionTitle),
            TextButton(
              onPressed: () {},
              child: Text('View All', style: AppTextStyles.viewAll),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              return RoomCard(
                roomName: 'Room name',
                createdBy: 'John Smit',
                joinedUsers: '3/5',
                imageUrl: 'assets/room_$index.jpg',
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTrendingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Trending', style: AppTextStyles.sectionTitle),
            TextButton(
              onPressed: () {},
              child: Text('View All', style: AppTextStyles.viewAll),
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
        Text('Interests', style: AppTextStyles.sectionTitle),
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
  final String imageUrl;
  final double size;

  const ProfileAvatar({super.key, required this.imageUrl, this.size = 48});

  @override
  Widget build(BuildContext context) {
    var img = '${Get.find<HttpService>().baseUrl}$imageUrl';
    log(img);
    return GestureDetector(
      onTap: () {
        Get.to(() => ProfileScreen());
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.lightGray,
          image: DecorationImage(image: NetworkImage(img), fit: BoxFit.cover, onError: (exception, stackTrace) {}),
        ),
        child: imageUrl.isEmpty ? Icon(Icons.person, color: AppColors.gray, size: size * 0.6) : null,
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback onTap;
  final bool hasNotification;
  final String? notificationCount;

  const ActionButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.hasNotification = false,
    this.notificationCount,
  });

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
  final String name;
  final double rating;
  final String imageUrl;

  const FaceOfWeekCard({super.key, required this.name, required this.rating, required this.imageUrl});

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
  final String roomName;
  final String createdBy;
  final String joinedUsers;
  final String imageUrl;

  const RoomCard({
    super.key,
    required this.roomName,
    required this.createdBy,
    required this.joinedUsers,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))],
      ),
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
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  image: DecorationImage(
                    image: AssetImage(imageUrl),
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
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(roomName, style: AppTextStyles.cardTitle),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('Created by ', style: AppTextStyles.cardSubtitle),
                    Text(createdBy, style: AppTextStyles.cardSubtitleBold),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('Joined User', style: AppTextStyles.cardSubtitle),
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
  final String roomName;
  final String interestName;
  final String category;
  final int createdRooms;
  final String imageUrl;

  const TrendingCard({
    super.key,
    required this.roomName,
    required this.interestName,
    required this.category,
    required this.createdRooms,
    required this.imageUrl,
  });

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
  final String title;
  final double rating;
  final String imageUrl;

  const InterestCard({super.key, required this.title, required this.rating, required this.imageUrl});

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
  final String text;
  final VoidCallback onPressed;

  const GradientButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: 36,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.teal, AppColors.orange],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(child: Text(text, style: AppTextStyles.buttonText)),
      ),
    );
  }
}

class AppTextStyles {
  static const TextStyle headerTitle = TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.darkText);

  static const TextStyle subtitle = TextStyle(fontSize: 14, color: AppColors.teal, fontWeight: FontWeight.w500);

  static const TextStyle sectionTitle = TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkText);

  static const TextStyle viewAll = TextStyle(fontSize: 14, color: AppColors.teal, fontWeight: FontWeight.w500);

  static const TextStyle cardName = TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.darkText);

  static const TextStyle cardTitle = TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.darkText);

  static const TextStyle cardSubtitle = TextStyle(fontSize: 12, color: AppColors.mediumText);

  static const TextStyle cardSubtitleBold = TextStyle(fontSize: 12, color: AppColors.teal, fontWeight: FontWeight.w600);

  static const TextStyle rating = TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.darkText);

  static const TextStyle buttonText = TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white);

  static const TextStyle badge = TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.white);
}
