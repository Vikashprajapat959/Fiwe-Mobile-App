import 'dart:developer';

import 'package:fiwe/src/controllers/home_controller.dart';
import 'package:fiwe/src/models/hmsvideo_room.dart';
import 'package:fiwe/src/services/topic_service.dart';
import 'package:fiwe/src/utils/app_text_styles.dart';
import 'package:fiwe/src/utils/assets.dart';
import 'package:fiwe/src/utils/colors.dart';
import 'package:fiwe/src/utils/constants.dart';
import 'package:fiwe/src/utils/helper.dart';
import 'package:fiwe/src/views/home/leaderboard_view.dart';
import 'package:fiwe/src/views/home/user_notification_view.dart';
import 'package:fiwe/src/views/profile/profile_view.dart';
import 'package:fiwe/src/views/search/search_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// Controller for managing state

// Main Home Screen
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                _buildSearchBar(),
                // Face of Week Section
                _buildFaceOfWeekSection(),
                // const SizedBox(height: 16),

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
        Obx(() => ProfileAvatar(imageBytes: controller.user?.profileBase64 ?? '', size: 48)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() => Text('${controller.user?.name}', style: AppTextStyles.headerTitle)),
              Row(
                children: [
                  Obx(
                    () => Text(
                      controller.userTopics.firstWhereOrNull((t) => t.isPrimary ?? false)?.title ?? '',
                      style: AppTextStyles.subtitle,
                    ),
                  ),
                  const Icon(LucideIcons.star, color: AppColors.orange, size: 12),
                  const Text('4.5', style: AppTextStyles.subtitle),
                ],
              ),
            ],
          ),
        ),
        Row(
          children: [
            ActionButton(
              icon: const Icon(LucideIcons.medal, color: AppColors.secondaryYellow),
              onTap: () {
                Get.to(() => const LeaderboardView());
              },
            ),
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
    return FutureBuilder(
      future: Get.find<TopicService>().getFaceOfWeek(),
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: LinearProgressIndicator());
        }
        if (asyncSnapshot.connectionState == ConnectionState.done && asyncSnapshot.hasError) {
          return Center(child: Text('Error: ${asyncSnapshot.error}'));
        }
        if (!asyncSnapshot.hasData || asyncSnapshot.data!.users.isEmpty) {
          return const SizedBox.shrink();
        }

        final users = asyncSnapshot.data!.users;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Face of Week', style: AppTextStyles.sectionTitle),
            const SizedBox(height: 8),
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: users.length,
                separatorBuilder: (context, index) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  return FaceOfWeekCard(
                    name: users[index].user.name ?? '',
                    rating: users[index].user.avgRating,
                    imageBytes: users[index].user.profileBase64 ?? '',
                  );
                },
              ),
            ),
          ],
        );
      },
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
          if (rooms != null && rooms.isEmpty) {
            return const SizedBox.shrink();
          } else {
            final int visibleCount = rooms!.length > 4 ? 4 : rooms.length;
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

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    spacing: 14,
                    children: List.generate(visibleCount, (index) {
                      log(rooms[index].objectId.toString());
                      return RoomCard(
                        roomName: rooms[index].title,
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
        }
      },
    );
  }

  Widget _buildTrendingSection() {
    return FutureBuilder(
      future: Get.find<TopicService>().getCurrentAffairs(),
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: LinearProgressIndicator());
        } else if (asyncSnapshot.connectionState == ConnectionState.done && asyncSnapshot.hasError) {
          return Center(child: Text('Error: ${asyncSnapshot.error}'));
        }
        if (!asyncSnapshot.hasData || asyncSnapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }
        final trendingTopics = asyncSnapshot.data!;

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
                itemCount: trendingTopics.length,
                separatorBuilder: (context, index) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  return TrendingCard(
                    name: trendingTopics[index].title,
                    description: trendingTopics[index].description,
                    category: trendingTopics[index].category,
                    createdRooms: trendingTopics[index].roomCreated,
                    imageBytes: trendingTopics[index].image,
                  );
                },
              ),
            ),
          ],
        );
      },
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
          child: Obx(() {
            final topics = Get.find<HomeController>().userTopics();
            return ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: topics.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                return InterestCard(
                  title: topics[index].title,
                  rating: 4.5,
                  imageUrl: topics[index].avatar ?? 'data:image/jpeg;base64',
                );
              },
            );
          }),
        ),
      ],
    );
  }

  GestureDetector _buildSearchBar() {
    return GestureDetector(
      onTap: () {
        Get.to(() => const SearchView());
      },
      child: Hero(
        tag: 'search_bar',
        transitionOnUserGestures: true,

        child: Container(
          height: 46,
          width: double.infinity,
          alignment: Alignment.centerLeft,
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.only(left: 12),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(15),
            border: Border.all(color: AppColors.primary),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              ShaderMask(
                shaderCallback: (Rect bounds) {
                  return Constants.gradientDecoration.gradient!.createShader(bounds);
                },
                child: const Icon(LucideIcons.search, color: Colors.white),
              ),
              const SizedBox(width: 8),
              const Text('Search', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}

// Reusable Components

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, required this.imageBytes, this.size = 48});
  final String imageBytes;
  final double size;

  @override
  Widget build(BuildContext context) {
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
          image: imageBytes.isEmpty
              ? null
              : DecorationImage(
                  image: MemoryImage(Helper.base64ToBytes(imageBytes)),
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) {},
                ),
        ),
        child: imageBytes.isEmpty ? Icon(LucideIcons.user, color: AppColors.gray, size: size * 0.6) : null,
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
  const FaceOfWeekCard({super.key, required this.name, required this.rating, required this.imageBytes});
  final String name;
  final double rating;
  final String? imageBytes;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.lightGray,
                image: DecorationImage(
                  image: MemoryImage(Helper.base64ToBytes(imageBytes)),
                  fit: BoxFit.fill,
                  onError: (exception, stackTrace) {},
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [BoxShadow(color: Colors.black.withAlpha(16), blurRadius: 4, offset: const Offset(0, 2))],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(LucideIcons.star, color: AppColors.orange, size: 12),
                    const SizedBox(width: 2),
                    Text(rating.toString(), style: AppTextStyles.rating),
                  ],
                ),
              ),
            ),
            Positioned(top: 4, right: 4, child: Image.asset(Assets.icons.starBadge, width: 15, height: 15)),
          ],
        ),
        const SizedBox(height: 8),
        Text(name, style: AppTextStyles.cardName, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 4),
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
                    image: MemoryImage(Helper.base64ToBytes(imageUrl)),
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
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        createdBy,
                        maxLines: 1,
                        style: AppTextStyles.cardSubtitleBold,
                        textAlign: TextAlign.end,
                      ),
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
    required this.name,
    required this.description,
    required this.category,
    required this.createdRooms,
    required this.imageBytes,
  });
  final String name;
  final String description;
  final String category;
  final int createdRooms;
  final String? imageBytes;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(12)), color: AppColors.lightGray),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 110,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.darkText,
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: MemoryImage(Helper.base64ToBytes(imageBytes)),
                    fit: BoxFit.fill,
                    onError: (exception, stackTrace) {},
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: Constants.gradientDecoration.copyWith(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      topRight: Radius.circular(50),
                    ),
                  ),
                  child: Text.rich(
                    TextSpan(
                      text: 'Created Rooms ',
                      children: [
                        TextSpan(
                          text: '$createdRooms ',
                          style: AppTextStyles.badge.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    style: AppTextStyles.badge,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ...[
            Text(name, style: AppTextStyles.cardTitle, overflow: TextOverflow.ellipsis),
            Text(description, style: AppTextStyles.cardSubtitle, overflow: TextOverflow.ellipsis),
            Text(category, style: AppTextStyles.cardSubtitleBold, overflow: TextOverflow.ellipsis),
          ].map((child) => Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: child)),
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
    return Container(
      height: 160,
      width: 165,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        color: AppColors.primary.withAlpha(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            children: [
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: MemoryImage(Helper.base64ToBytes(imageUrl)),
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) {},
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    border: Border.all(color: AppColors.primaryDark),
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.star, color: AppColors.secondaryYellow, size: 12),
                      const SizedBox(width: 2),
                      Text(
                        rating.toString(),
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(title, overflow: TextOverflow.ellipsis, style: AppTextStyles.cardTitle, textAlign: TextAlign.center),
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
