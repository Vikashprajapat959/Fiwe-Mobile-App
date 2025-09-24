import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Color Theme
class AppColors {
  static const Color primary = Color(0xFF00BCD4);
  static const Color secondary = Color(0xFF4CAF50);
  static const Color accent = Color(0xFFFFC107);
  static const Color background = Color(0xFFF5F5F5);
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color divider = Color(0xFFE0E0E0);
  static const Color starColor = Color(0xFFFFC107);
  static const Color badgeOrange = Color(0xFFFF9800);
}

// Community Member Model
class CommunityMember {
  final String name;
  final String category;
  final String profileImage;
  final double rating;
  final bool hasVerifiedBadge;

  CommunityMember({
    required this.name,
    required this.category,
    required this.profileImage,
    required this.rating,
    this.hasVerifiedBadge = true,
  });
}

// Reusable Community Member Tile
class CommunityMemberTile extends StatelessWidget {
  final CommunityMember member;
  final VoidCallback? onTap;

  const CommunityMemberTile({super.key, required this.member, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            // Profile Image with Badge
            Stack(
              children: [
                // Profile Image
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(image: AssetImage(member.profileImage), fit: BoxFit.cover),
                    border: Border.all(color: AppColors.divider, width: 0.5),
                  ),
                  // Placeholder when image is not available
                  child: member.profileImage.isEmpty
                      ? Container(
                          decoration: BoxDecoration(color: AppColors.divider, shape: BoxShape.circle),
                          child: Icon(Icons.person, color: AppColors.textSecondary, size: 28),
                        )
                      : null,
                ),
                // Verified Badge
                if (member.hasVerifiedBadge)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppColors.badgeOrange,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.star, size: 12, color: Colors.white),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),

            // Name and Category
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(member.category, style: const TextStyle(fontSize: 14, color: AppColors.primary)),
                ],
              ),
            ),

            // Rating
            Row(
              children: [
                const Icon(Icons.star, size: 18, color: AppColors.starColor),
                const SizedBox(width: 4),
                Text(
                  member.rating.toString(),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Main My Communes Screen
class MyCommunesScreen extends StatefulWidget {
  const MyCommunesScreen({super.key});

  @override
  State<MyCommunesScreen> createState() => _MyCommunesScreenState();
}

class _MyCommunesScreenState extends State<MyCommunesScreen> {
  // Sample data - Replace with actual data from your backend
  final List<CommunityMember> members = [
    CommunityMember(
      name: 'Albert Flores',
      category: 'Fashion/lifestyle',
      profileImage: '', // Add actual image path
      rating: 4.5,
    ),
    CommunityMember(name: 'Marvin McKinney', category: 'Fashion/lifestyle', profileImage: '', rating: 4.5),
    CommunityMember(name: 'Brooklyn Simmons', category: 'Fashion/lifestyle', profileImage: '', rating: 4.5),
    CommunityMember(name: 'Bessie Cooper', category: 'Fashion/lifestyle', profileImage: '', rating: 4.5),
    CommunityMember(name: 'Kathryn Murphy', category: 'Fashion/lifestyle', profileImage: '', rating: 4.5),
    CommunityMember(name: 'Leslie Alexander', category: 'Fashion/lifestyle', profileImage: '', rating: 4.5),
    CommunityMember(name: 'Devon Lane', category: 'Fashion/lifestyle', profileImage: '', rating: 4.5),
    CommunityMember(name: 'Cameron Williamson', category: 'Fashion/lifestyle', profileImage: '', rating: 4.5),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: const Text(
          'My Communes',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Members List
            ListView.separated(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: members.length,
              separatorBuilder: (context, index) => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Divider(height: 1, color: AppColors.divider),
              ),
              itemBuilder: (context, index) {
                return CommunityMemberTile(
                  member: members[index],
                  onTap: () {
                    // Handle member tap
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${members[index].name} clicked'), duration: const Duration(seconds: 1)),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
