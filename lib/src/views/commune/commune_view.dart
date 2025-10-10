import 'package:fiwe/src/controllers/commune_controller.dart';
import 'package:fiwe/src/repositories/commune_repository.dart' show CommuneSummary;
import 'package:fiwe/src/utils/assets.dart';
import 'package:fiwe/src/utils/colors.dart';
import 'package:fiwe/src/utils/constants.dart';
import 'package:fiwe/src/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// Reusable Community Member Tile
class CommuneMemberTile extends StatelessWidget {
  const CommuneMemberTile({super.key, required this.member, this.onTap});
  final CommuneSummary member;
  final VoidCallback? onTap;

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
                    image: DecorationImage(
                      image: MemoryImage(Helper.base64ToBytes(member.imageBytes)),
                      fit: BoxFit.cover,
                    ),
                    border: Border.all(color: AppColors.divider, width: 0.5),
                  ),
                  // Placeholder when image is not available
                  child: member.imageBytes == null
                      ? Container(
                          decoration: const BoxDecoration(color: AppColors.divider, shape: BoxShape.circle),
                          child: const Icon(LucideIcons.user, color: AppColors.textSecondary, size: 28),
                        )
                      : null,
                ),

                // Verified Badge
                Positioned(right: 0, top: 0, child: Image.asset(Assets.icons.starBadge, width: 18)),
              ],
            ),
            const SizedBox(width: 16),

            // Name and Category
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name ?? '',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    member.primaryInterest?.title ?? '',
                    style: const TextStyle(fontSize: 14, color: AppColors.primary),
                  ),
                ],
              ),
            ),

            // Rating
            Row(
              children: [
                const Icon(LucideIcons.star, size: 18, color: AppColors.starColor),
                const SizedBox(width: 4),
                Text(
                  member.avgRating.toString(),
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
class MyCommunesScreen extends StatelessWidget {
  const MyCommunesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: const Text('My Communes'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.search, size: 24, color: AppColors.textPrimary),
            onPressed: () => Get.toNamed(Constants.searchUserRoute),
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: Get.find<CommuneController>().getAllCommunes(),
          builder: (context, asyncSnapshot) {
            if (asyncSnapshot.connectionState == ConnectionState.waiting || !asyncSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            if (asyncSnapshot.error != null) {
              return Center(child: Text(asyncSnapshot.error.toString()));
            }
            if (asyncSnapshot.data!.data!.isEmpty) {
              return const Center(child: Text('No commune found'));
            }
            //if error
            final members = asyncSnapshot.data!.data!;
            return ListView.separated(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: members.length,
              separatorBuilder: (context, index) => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Divider(height: 1, color: AppColors.divider),
              ),
              itemBuilder: (context, index) {
                return CommuneMemberTile(
                  member: members[index],
                  onTap: () {
                    // Get.to(()=>UserProfileScreen(user: ))
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
