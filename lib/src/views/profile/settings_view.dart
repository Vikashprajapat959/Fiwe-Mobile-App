import 'package:fiwe/src/widgets/app_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Color Theme
class AppColors {
  static const Color primary = Color(0xFF4CAF50);
  static const Color secondary = Color(0xFF2196F3);
  static const Color warning = Color(0xFFFF9800);
  static const Color danger = Color(0xFFF44336);
  static const Color info = Color(0xFF00BCD4);
  static const Color background = Color(0xFFF5F5F5);
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color divider = Color(0xFFE0E0E0);
}

// Reusable Settings Item Model
class SettingsItem {
  SettingsItem({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.onTap,
    this.isDanger = false,
  });
  final String title;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;
  final bool isDanger;
}

// Reusable Settings Tile Component
class SettingsTile extends StatelessWidget {
  const SettingsTile({super.key, required this.item});
  final SettingsItem item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            // Icon Container
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: item.iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(item.icon, color: item.iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            // Title
            Expanded(
              child: Text(
                item.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: item.isDanger ? AppColors.danger : AppColors.textPrimary,
                ),
              ),
            ),
            // Arrow Icon
            const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 24),
          ],
        ),
      ),
    );
  }
}

// Custom App Bar
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,

      leading: const Padding(
        padding: EdgeInsets.all(8.0),
        child: AppBackButton(theme: BackButtonTheme.dark),
      ),
      title: Text(
        title,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w600),
      ),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// Main Settings Screen
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Define settings items
    final List<SettingsItem> settingsItems = [
      SettingsItem(
        title: 'Contact Us',
        icon: Icons.person_outline,
        iconColor: AppColors.info,
        onTap: () {
          // Navigate to Contact Us
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contact Us clicked')));
        },
      ),
      SettingsItem(
        title: 'About Us',
        icon: Icons.info_outline,
        iconColor: AppColors.warning,
        onTap: () {
          // Navigate to About Us
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('About Us clicked')));
        },
      ),
      SettingsItem(
        title: 'Privacy Policy',
        icon: Icons.security_outlined,
        iconColor: AppColors.primary,
        onTap: () {
          // Navigate to Privacy Policy
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Privacy Policy clicked')));
        },
      ),
      SettingsItem(
        title: 'Terms & Conditions',
        icon: Icons.description_outlined,
        iconColor: AppColors.primary,
        onTap: () {
          // Navigate to Terms & Conditions
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Terms & Conditions clicked')));
        },
      ),
      SettingsItem(
        title: 'Delete Account',
        icon: Icons.remove_circle_outline,
        iconColor: AppColors.danger,
        onTap: () {
          _showDeleteAccountDialog(context);
        },
        isDanger: true,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Settings'),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            // Settings List
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                children: [
                  for (int i = 0; i < settingsItems.length; i++) ...[
                    SettingsTile(item: settingsItems[i]),
                    if (i < settingsItems.length - 1)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Divider(height: 1, color: AppColors.divider),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Delete Account',
            style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Account deleted successfully'), backgroundColor: AppColors.danger),
                );
              },
              child: const Text('Delete', style: TextStyle(color: AppColors.danger)),
            ),
          ],
        );
      },
    );
  }
}
