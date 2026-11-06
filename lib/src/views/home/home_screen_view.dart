// lib/src/views/home/home_screen.dart

// NOTE: Ensure all imports are correct in your project structure
// If you face any 'not found' errors, verify these paths.

import 'package:fiwe/src/controllers/home_controller.dart';
import 'package:fiwe/src/controllers/video_room_controller.dart';
import 'package:fiwe/src/models/fcm_notification_data.dart';
import 'package:fiwe/src/models/hmsvideo_room.dart';
import 'package:fiwe/src/services/topic_service.dart';
import 'package:fiwe/src/utils/app_text_styles.dart';
import 'package:fiwe/src/utils/assets.dart'; // Ensure Assets class is correct
import 'package:fiwe/src/utils/colors.dart';
import 'package:fiwe/src/utils/constants.dart'; // Ensure Constants class is correct
import 'package:fiwe/src/utils/helper.dart'; // Ensure Helper class is correct
import 'package:fiwe/src/views/home/leaderboard_view.dart';
import 'package:fiwe/src/views/home/user_notification_view.dart';
import 'package:fiwe/src/views/profile/profile_view.dart';
import 'package:fiwe/src/views/search/search_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// Main Home Screen
// GetView automatically provides the 'controller' property
class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Pass context to the controller
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.setContext(context);
    });

    // Ensure initial data fetching
    if (controller.activeRooms.isEmpty && controller.isActiveRoomsLoading.isFalse) {
      controller.fetchInitialData();
    }

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
                _buildHeader(controller),
                const SizedBox(height: 24),
                _buildSearchBar(),

                // Active Room Section
                _buildActiveRoomSection(controller),
                const SizedBox(height: 32),

                // Face of Week Section
                _buildFaceOfWeekSection(),
                const SizedBox(height: 32),

                // Trending Section
                _buildTrendingSection(),
                const SizedBox(height: 32),

                // Interests Section
                _buildInterestsSection(controller),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Widgets ---

  Widget _buildHeader(HomeController controller) {
    return Row(
      children: [
        ProfileAvatar(imageBytes: controller.user?.profileBase64 ?? '', size: 48),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Correct user access: controller.user?.name
              Text(
                controller.user?.name ?? 'Guest User',
                style: AppTextStyles.headerTitle,
                overflow: TextOverflow.ellipsis,
              ),
              Row(
                children: [
                  Obx(
                    () => SizedBox(
                      width: 100,
                      child: Text(
                        controller.userTopics.firstWhereOrNull((t) => t.isPrimary ?? false)?.title ?? 'General',
                        style: AppTextStyles.subtitle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const Icon(LucideIcons.star, color: AppColors.orange, size: 12),
                  const Text('4.5', style: AppTextStyles.subtitle),
                ],
              ),
            ],
          ),
        ),
        // ये Row अब Expanded के बाहर है, इसलिए Row (Line 144) की एरर हट गई।
        Row(
          children: [
            ActionButton(
              icon: const Icon(LucideIcons.medal, color: AppColors.secondaryYellow),
              onTap: () => Get.to(() => const LeaderboardView()),
            ),
            const SizedBox(width: 8),
            ActionButton(
              icon: const Icon(LucideIcons.bell, color: AppColors.secondaryYellow),
              onTap: () => Get.to(() => const UserNotificationView()),
              hasNotification: true,
              notificationCount: '2',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: () => Get.to(() => const SearchView()),
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

  // Changed from FutureBuilder to Obx for reactivity
  Widget _buildActiveRoomSection(HomeController controller) {
    return Obx(() {
      if (controller.isActiveRoomsLoading.isTrue) {
        return const Center(child: LinearProgressIndicator());
      }

      final rooms = controller.activeRooms;
      if (rooms.isEmpty) {
        return const SizedBox.shrink();
      }

      final int visibleCount = rooms.length > 4 ? 4 : rooms.length;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              children: List.generate(visibleCount, (index) {
                return Padding(
                  padding: EdgeInsets.only(right: index == visibleCount - 1 ? 0 : 14),
                  child: RoomCard(
                    room: rooms[index],
                    roomName: rooms[index].title,
                    createdBy: rooms[index].creator?.name ?? 'Unknown',
                    joinedUsers: '${rooms[index].currentOccupancy}/${rooms[index].capacity ?? 5}',
                    imageUrl: rooms[index].topic?.thumbnail ?? '',
                    roomCode: rooms[index].roomGuestCode ?? '',
                  ),
                );
              }),
            ),
          ),
        ],
      );
    });
  }

  // Retained FutureBuilder for Face of Week
  Widget _buildFaceOfWeekSection() {
    // Note: Assuming Get.find<TopicService>().getFaceOfWeek() returns a Map/Object
    // containing a 'users' list, as suggested by your usage: asyncSnapshot.data!.users
    return FutureBuilder(
      future: Get.find<TopicService>().getFaceOfWeek(),
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }
        // Added null check for asyncSnapshot.data
        if (asyncSnapshot.connectionState == ConnectionState.done &&
            (asyncSnapshot.hasError || asyncSnapshot.data == null)) {
          return Center(child: Text('Error loading Face of Week: ${asyncSnapshot.error}'));
        }
        // NOTE: The next line assumes asyncSnapshot.data has a 'users' property.
        // If 'users' is directly the data, change asyncSnapshot.data!.users to asyncSnapshot.data!
        final users = asyncSnapshot.data!.users;

        if (users.isEmpty) {
          return const SizedBox.shrink();
        }

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
                    // Note: Assuming users[index].user structure
                    name: users[index].user.name ?? 'User',
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

  // Retained FutureBuilder for Trending Topics
  Widget _buildTrendingSection() {
    return FutureBuilder(
      future: Get.find<TopicService>().getCurrentAffairs(),
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: LinearProgressIndicator());
        } else if (asyncSnapshot.connectionState == ConnectionState.done && asyncSnapshot.hasError) {
          return Center(child: Text('Error loading Trending Topics: ${asyncSnapshot.error}'));
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

  // Obx for reactive list display
  Widget _buildInterestsSection(HomeController controller) {
    return Obx(() {
      final topics = controller.userTopics;
      if (topics.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Interests', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: topics.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                return InterestCard(
                  title: topics[index].title,
                  rating: 4.5,
                  imageUrl: topics[index].avatar ?? '', // null safety
                );
              },
            ),
          ),
        ],
      );
    });
  }
}

// -----------------------------------------------------------------------------
// --- Reusable Components (Corrected and Simplified) ---
// -----------------------------------------------------------------------------

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, required this.imageBytes, this.size = 48});
  final String imageBytes;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => const ProfileScreen()),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.lightGray,
          image: imageBytes.isEmpty
              ? null
              : DecorationImage(image: MemoryImage(Helper.base64ToBytes(imageBytes)), fit: BoxFit.cover),
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
              child: Center(
                child: Text(
                  notificationCount ?? 'N',
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
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
    final safeImageBytes = imageBytes ?? '';

    return SizedBox(
      // Added SizedBox for better width control in ListView
      width: 80,
      child: Column(
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
                  image: safeImageBytes.isNotEmpty
                      ? DecorationImage(image: MemoryImage(Helper.base64ToBytes(safeImageBytes)), fit: BoxFit.fill)
                      : null,
                ),
                child: safeImageBytes.isEmpty
                    ? const Center(child: Icon(LucideIcons.user, color: AppColors.gray, size: 40))
                    : null,
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withAlpha(16), blurRadius: 4, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.star, color: AppColors.orange, size: 12),
                      const SizedBox(width: 2),
                      Text(rating.toStringAsFixed(1), style: AppTextStyles.rating),
                    ],
                  ),
                ),
              ),
              // Assuming starBadge is defined correctly in Assets.icons
              Positioned(top: 4, right: 4, child: Image.asset(Assets.icons.starBadge, width: 15, height: 15)),
            ],
          ),
          const SizedBox(height: 8),
          Text(name, style: AppTextStyles.cardName, overflow: TextOverflow.ellipsis),
        ],
      ),
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
    required this.roomCode,
    required this.room,
  });
  final String roomName;
  final String createdBy;
  final String joinedUsers;
  final String imageUrl;
  final String roomCode;
  final HMSVideoRoom room; // Assumed type

  @override
  Widget build(BuildContext context) {
    // Assuming Get.find is setup correctly in GetX binding
    final videoRoomController = Get.find<VideoRoomController>();
    final homeController = Get.find<HomeController>();
    final safeImageUrl = imageUrl;

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
                  image: safeImageUrl.isNotEmpty
                      ? DecorationImage(image: MemoryImage(Helper.base64ToBytes(safeImageUrl)), fit: BoxFit.cover)
                      : null,
                ),
                child: safeImageUrl.isEmpty
                    ? const Center(child: Icon(LucideIcons.video, color: AppColors.gray, size: 40))
                    : null,
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
                  child: Text(
                    roomName,
                    style: AppTextStyles.cardTitle,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ), // Added maxLines to prevent overflow
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
                // Join Logic
                GradientButton(
                  text: 'Join Now',
                  onPressed: () {
                    // 1. Create RoomInviteData object with all required fields
                    final inviteData = RoomInviteData(
                      // Assumed model structure
                      roomId: room.objectId,
                      title: room.title,
                      body: 'Joining active room: ${room.title}',
                      type: 'roomInvite',
                      roomGuestCode: room.roomGuestCode?.toString() ?? '',
                      roomHostCode: room.roomHostCode?.toString() ?? '',
                      inviteeName: homeController.user?.name ?? 'Guest',
                      deepLink: '',
                      expiry: null,
                      topicDetails: null,
                      userDetails: null,
                    );

                    // 2. Call the centralized joinRoom method
                    videoRoomController.joinRoom(inviteData, homeController.user?.name ?? 'Guest');
                  },
                ),
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
    final safeImageBytes = imageBytes ?? '';

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
                  image: safeImageBytes.isNotEmpty
                      ? DecorationImage(image: MemoryImage(Helper.base64ToBytes(safeImageBytes)), fit: BoxFit.fill)
                      : null,
                ),
                child: safeImageBytes.isEmpty
                    ? const Center(child: Icon(LucideIcons.activity, color: Colors.white, size: 40))
                    : null,
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
          // List of widgets mapped to have padding
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
    final safeImageUrl = imageUrl;

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
                  image: safeImageUrl.isNotEmpty
                      ? DecorationImage(image: MemoryImage(Helper.base64ToBytes(safeImageUrl)), fit: BoxFit.cover)
                      : null,
                ),
                child: safeImageUrl.isEmpty
                    ? const Center(child: Icon(LucideIcons.bookmark, color: AppColors.gray, size: 40))
                    : null,
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
                        rating.toStringAsFixed(1),
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
