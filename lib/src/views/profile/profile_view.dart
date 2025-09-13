import 'package:fiwe/src/utils/app_text_styles.dart';
import 'package:fiwe/src/utils/colors.dart';
import 'package:fiwe/src/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AppSizes {
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double borderRadius = 12.0;
  static const double iconSize = 24.0;
  static const double avatarSize = 60.0;
}

class BadgeSection extends StatelessWidget {
  const BadgeSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Get.width,
      child: Row(
        children: [
          const Text('Badge', style: AppTextStyles.subHeading),
          Spacer(),
          _buildBadge(Icons.hexagon, CustomColors.textSecondary),
          const SizedBox(width: AppSizes.paddingSmall),
          _buildBadge(Icons.star, CustomColors.warning),
          const SizedBox(width: AppSizes.paddingSmall),
          _buildBadge(Icons.workspace_premium, CustomColors.error),
        ],
      ),
    );
  }

  Widget _buildBadge(IconData icon, Color color) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

class CustomCard extends StatelessWidget {
  final Widget child;

  final EdgeInsets? padding;
  const CustomCard({super.key, required this.child, this.padding});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: padding ?? EdgeInsets.all(12),
      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(12)), color: AppColors.surface),
      child: child,
    );
  }
}

// Constants for styling
class CustomColors {
  static const Color primary = Color(0xFF4CAF50);
  static const Color secondary = Color(0xFF2196F3);
  static const Color accent = Color(0xFF17A2B8);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFE53E3E);
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF212529);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color divider = Color(0xFFE9ECEF);
}

class MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color iconColor;
  final VoidCallback onTap;

  const MenuTile({super.key, required this.icon, required this.title, required this.iconColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: iconColor, borderRadius: BorderRadius.circular(AppSizes.borderRadius)),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(title, style: AppTextStyles.body),
      trailing: const Icon(Icons.chevron_right, color: CustomColors.textSecondary),
      onTap: onTap,
    );
  }
}

// Controller
class ProfileController extends GetxController {
  // Profile data
  var userName = 'John Smit'.obs;
  var rating = 4.5.obs;
  var reviewCount = 10.obs;
  var tagline = 'Your voice. Their ears. Let\'s go!'.obs;
  var profileCompletion = 75.obs;

  // Stats
  var totalRoomsCreated = 5.obs;
  var joinedRooms = 2.obs;
  var faceOfWeek = 2.obs;
  var totalCommence = 7.obs;
  var followers = 9.obs;
  var audiences = 50.obs;
  var toppedRooms = 3.obs;

  void editProfile() {
    Get.snackbar('Edit Profile', 'Navigating to edit profile screen');
  }

  void logout() {
    Get.snackbar('Logout', 'Logging out...');
  }

  void openAvailability() {
    Get.snackbar('Availability', 'Opening availability settings');
  }

  void openCommunes() {
    Get.snackbar('Communes', 'Opening communes');
  }

  void openPreferences() {
    Get.snackbar('Preferences', 'Opening preferences');
  }
}

// Reusable Components
class ProfileHeader extends StatelessWidget {
  final String name;
  final double rating;
  final int reviewCount;
  final String tagline;
  final String? avatarUrl;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.rating,
    required this.reviewCount,
    required this.tagline,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Avatar
        Stack(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderDark),
              ),
              padding: const EdgeInsets.all(4),
              child: avatarUrl != null
                  ? Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(fit: BoxFit.cover, image: NetworkImage(avatarUrl!)),
                      ),
                    )
                  : const Icon(LucideIcons.user, size: 30, color: CustomColors.textSecondary),
            ),
            Positioned(top: 0, right: 0, child: Icon(Icons.star, color: Colors.yellow)),
          ],
        ),
        const SizedBox(width: AppSizes.paddingMedium),
        // Profile info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: AppTextStyles.heading),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text('Rating', style: AppTextStyles.caption),
                  const Icon(Icons.star, color: CustomColors.warning, size: 16),
                  const SizedBox(width: 4),
                  Text('$rating', style: AppTextStyles.body),
                  const SizedBox(width: 4),
                  Text('($reviewCount)', style: AppTextStyles.caption),
                ],
              ),
              const SizedBox(height: 4),
              Text(tagline, style: AppTextStyles.caption),
            ],
          ),
        ),
      ],
    );
  }
}

// Main Profile Screen
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: AppBar(
        backgroundColor: CustomColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: CustomColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: const Text('Profile', style: AppTextStyles.heading),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: CustomColors.textSecondary),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // White container for main profile content
            Column(
              children: [
                // Profile Header
                CustomCard(
                  child: Obx(
                    () => ProfileHeader(
                      name: controller.userName.value,
                      rating: controller.rating.value,
                      reviewCount: controller.reviewCount.value,
                      tagline: controller.tagline.value,
                    ),
                  ),
                ),

                // Progress Bar
                CustomCard(
                  child: Obx(
                    () => ProgressBar(percentage: controller.profileCompletion.value, title: 'Complete Your Profile'),
                  ),
                ),

                // Badges
                CustomCard(child: const BadgeSection()),

                // Stats Grid
                CustomCard(
                  padding: EdgeInsets.only(top: 12, right: 12, left: 12),
                  child: Obx(
                    () => StatsGrid(
                      stats: {
                        'Total Room Created': controller.totalRoomsCreated.value,
                        'Joined Rooms': controller.joinedRooms.value,
                        'Face of Week': controller.faceOfWeek.value,
                        'Total Commence': controller.totalCommence.value,
                        'Followers': controller.followers.value,
                        'Audiences': controller.audiences.value,
                        'Topped Rooms': controller.toppedRooms.value,
                      },
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSizes.paddingMedium),

            // Menu Items
            CustomCard(
              child: Column(
                children: [
                  MenuTile(
                    icon: Icons.edit,
                    title: 'Edit Profile',
                    iconColor: CustomColors.primary,
                    onTap: controller.editProfile,
                  ),
                  Divider(),
                  MenuTile(
                    icon: Icons.tune,
                    title: 'Preference',
                    iconColor: CustomColors.secondary,
                    onTap: controller.openPreferences,
                  ),
                  Divider(),
                  MenuTile(
                    icon: Icons.schedule,
                    title: 'Availability',
                    iconColor: CustomColors.accent,
                    onTap: controller.openAvailability,
                  ),
                  Divider(),
                  MenuTile(
                    icon: Icons.groups,
                    title: 'Communes',
                    iconColor: CustomColors.error,
                    onTap: controller.openCommunes,
                  ),
                  Divider(),
                  MenuTile(
                    icon: Icons.logout,
                    title: 'Logout',
                    iconColor: CustomColors.warning,
                    onTap: controller.logout,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProgressBar extends StatelessWidget {
  final int percentage;
  final String title;

  const ProgressBar({super.key, required this.percentage, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: AppTextStyles.subHeading),
            Text('$percentage%', style: AppTextStyles.subHeading),
          ],
        ),
        const SizedBox(height: AppSizes.paddingSmall),
        Container(
          height: 8,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: CustomColors.divider),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage / 100,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: Constants.gradientDecoration.gradient,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class StatsGrid extends StatelessWidget {
  final Map<String, int> stats;

  const StatsGrid({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 7,
        mainAxisSpacing: 4,
        crossAxisSpacing: 16,
      ),
      itemCount: stats.length,

      itemBuilder: (context, index) {
        String key = stats.keys.elementAt(index);
        int value = stats[key]!;
        return _buildStatItem(key, value);
      },
    );
  }

  Widget _buildStatItem(String label, int value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(label, style: AppTextStyles.caption, overflow: TextOverflow.ellipsis),
        ),
        Text('$value', style: AppTextStyles.number),
      ],
    );
  }
}
