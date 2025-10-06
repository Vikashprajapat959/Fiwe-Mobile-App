import 'package:fiwe/src/controllers/commune_controller.dart';
import 'package:fiwe/src/models/topic.model.dart';
import 'package:fiwe/src/models/user_model.dart';
import 'package:fiwe/src/utils/colors.dart';
import 'package:fiwe/src/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// Main Screen
class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key, required this.user});
  final User user;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      persistentFooterDecoration: const BoxDecoration(color: AppColors.background),
      persistentFooterButtons: [CommuneRequestButton(user: user)],
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    ProfileHeader(user: user),
                    const SizedBox(height: 32),
                    const BadgesSection(),
                    const SizedBox(height: 32),
                    const StatsSection(),
                    const SizedBox(height: 32),
                    InterestsSection(interests: user.topics ?? []),
                    const SizedBox(height: 24),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom App Bar
class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 2))],
              ),
              child: const Icon(Icons.chevron_left, color: AppColors.textPrimary, size: 20),
            ),
          ),
          const Expanded(
            child: Text('User Profile', textAlign: TextAlign.center, style: AppTextStyles.title),
          ),
          PopupMenuButton<String>(
            icon: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: AppColors.interestInactive, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.more_horiz, color: AppColors.textPrimary, size: 20),
            ),
            itemBuilder: (context) => [const PopupMenuItem(value: 'block', child: Text('Block'))],
          ),
        ],
      ),
    );
  }
}

// Profile Header
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.user});
  final User user;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: AppColors.white,
          child: CircleAvatar(
            radius: 56,
            backgroundImage: MemoryImage(Helper.base64ToBytes(user.profileBase64) ?? Helper.defaultProfileImageBytes),
          ),
        ),
        const SizedBox(height: 16),
        Text('${user.name}', style: AppTextStyles.profileName, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text('${user.bio}', style: AppTextStyles.profileBio, textAlign: TextAlign.center),
        const SizedBox(height: 12),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Rating', style: AppTextStyles.ratingLabel),
            SizedBox(width: 8),
            Icon(LucideIcons.star, color: AppColors.tertiary, size: 16),
            SizedBox(width: 4),
            Text('4.5 (10)', style: AppTextStyles.ratingValue),
          ],
        ),
      ],
    );
  }
}

// Badges Section
class BadgesSection extends StatelessWidget {
  const BadgesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Badges', style: AppTextStyles.sectionTitle),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            BadgeIcon(icon: Icons.star_border, color: AppColors.interestInactive),
            SizedBox(width: 12),
            BadgeIcon(icon: LucideIcons.star, color: AppColors.tertiary),
            SizedBox(width: 12),
            BadgeIcon(icon: Icons.star_half, color: AppColors.quaternary),
          ],
        ),
      ],
    );
  }
}

// Badge Icon Widget
class BadgeIcon extends StatelessWidget {
  const BadgeIcon({super.key, required this.icon, required this.color});
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Icon(icon, color: AppColors.white, size: 24),
    );
  }
}

// Stats Section
class StatsSection extends StatelessWidget {
  const StatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = [
      StatItem(label: 'Total Room Created', value: '5'),
      StatItem(label: 'Joined Rooms', value: '2'),
      StatItem(label: 'Face of Week', value: '2'),
      StatItem(label: 'Total Commence', value: '7'),
      StatItem(label: 'Followers', value: '9'),
      StatItem(label: 'Audiences', value: '50'),
      StatItem(label: 'Topped Rooms', value: '3'),
    ];

    return Column(
      children: [
        for (int i = 0; i < stats.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Expanded(child: StatCard(stat: stats[i])),
                const SizedBox(width: 24),
                Expanded(child: i + 1 < stats.length ? StatCard(stat: stats[i + 1]) : const SizedBox()),
              ],
            ),
          ),
      ],
    );
  }
}

// Stat Card
class StatCard extends StatelessWidget {
  const StatCard({super.key, required this.stat});
  final StatItem stat;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(stat.label, style: AppTextStyles.statLabel),
        const SizedBox(height: 4),
        Text(stat.value, style: AppTextStyles.statValue),
      ],
    );
  }
}

// Stat Item Model
class StatItem {
  StatItem({required this.label, required this.value});
  final String label;
  final String value;
}

// Interests Section
class InterestsSection extends StatelessWidget {
  const InterestsSection({super.key, required this.interests});
  final List<Topic> interests;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Interests', style: AppTextStyles.sectionTitle),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: interests.map((interest) => InterestChip(interest: interest)).toList(),
        ),
      ],
    );
  }
}

// Interest Chip
class InterestChip extends StatelessWidget {
  const InterestChip({super.key, required this.interest});
  final Topic interest;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: interest.isPrimary ?? false ? AppColors.interestActive : AppColors.interestInactive,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Text(
        interest.title,
        style: interest.isPrimary ?? false ? AppTextStyles.interestActive : AppTextStyles.interestInactive,
      ),
    );
  }
}

// Commune Request Button
class CommuneRequestButton extends StatelessWidget {
  const CommuneRequestButton({super.key, required this.user});
  final User user;
  @override
  Widget build(BuildContext context) {
    final CommuneController communeController = Get.find<CommuneController>();

    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondaryYellow],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: Obx(() {
          final requestSent = communeController.isRequestSent(user.id);
          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: requestSent
                ? () => communeController.cancelRequest(user.id)
                : () => communeController.sendCommuneRequest(user.id),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!requestSent) const Icon(Icons.add, color: AppColors.white, size: 24),
                const SizedBox(width: 8),
                Text(requestSent ? 'Cancel Commune Request' : 'Commune Request', style: AppTextStyles.buttonText),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// Text Styles
class AppTextStyles {
  static const TextStyle title = TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary);

  static const TextStyle profileName = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle profileBio = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle ratingLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle ratingValue = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle statLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle statValue = TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary);

  static const TextStyle interestActive = TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.white);

  static const TextStyle interestInactive = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle buttonText = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.white);
}
