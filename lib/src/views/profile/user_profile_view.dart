import 'package:flutter/material.dart';

// Main Screen
class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    SizedBox(height: 24),
                    ProfileHeader(),
                    SizedBox(height: 32),
                    BadgesSection(),
                    SizedBox(height: 32),
                    StatsSection(),
                    SizedBox(height: 32),
                    InterestsSection(),
                    SizedBox(height: 24),
                    CommuneRequestButton(),
                    SizedBox(height: 24),
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

// App Colors
class AppColors {
  static const Color background = Color(0xFFF8F9FA);
  static const Color primary = Color(0xFF007AFF);
  static const Color secondary = Color(0xFF34C759);
  static const Color tertiary = Color(0xFFFF9500);
  static const Color quaternary = Color(0xFFFF6347);
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color white = Color(0xFFFFFFFF);
  static const Color shadow = Color(0x1A000000);
  static const Color interestActive = Color(0xFF48CAE4);
  static const Color interestInactive = Color(0xFFE5E5EA);
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
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: AppColors.white,
          child: CircleAvatar(
            radius: 56,
            backgroundImage: NetworkImage(
              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop&crop=face',
            ),
          ),
        ),
        SizedBox(height: 16),
        Text('Josh', style: AppTextStyles.profileName),
        SizedBox(height: 8),
        Text('Your voice. Their ears. Let\'s go!', style: AppTextStyles.profileBio),
        SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Rating', style: AppTextStyles.ratingLabel),
            SizedBox(width: 8),
            Icon(Icons.star, color: AppColors.tertiary, size: 16),
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
            BadgeIcon(icon: Icons.star, color: AppColors.tertiary),
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
  const InterestsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final interests = [
      Interest(name: 'Fashion/lifestyle', isActive: true),
      Interest(name: 'Geo politics', isActive: false),
      Interest(name: 'Humor/satire', isActive: false),
      Interest(name: 'Critics/reviews', isActive: false),
      Interest(name: 'Cosmos/out of world', isActive: false),
    ];

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
  final Interest interest;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: interest.isActive ? AppColors.interestActive : AppColors.interestInactive,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Text(
        interest.name,
        style: interest.isActive ? AppTextStyles.interestActive : AppTextStyles.interestInactive,
      ),
    );
  }
}

// Interest Model
class Interest {
  Interest({required this.name, required this.isActive});
  final String name;
  final bool isActive;
}

// Commune Request Button
class CommuneRequestButton extends StatelessWidget {
  const CommuneRequestButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.interestActive, AppColors.secondary],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: AppColors.interestActive.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Handle button press
          },
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: AppColors.white, size: 24),
              SizedBox(width: 8),
              Text('Commune Request', style: AppTextStyles.buttonText),
            ],
          ),
        ),
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
