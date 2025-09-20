import 'package:fiwe/src/controllers/edit_profile_controller.dart';
import 'package:fiwe/src/widgets/custom_button.dart';
import 'package:fiwe/src/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// Reusable App Bar Component
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackPressed;

  const CustomAppBar({super.key, required this.title, this.onBackPressed});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: BackButton(),
      title: Text(
        title,
        style: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w600),
      ),
      centerTitle: true,
    );
  }
}

// Main Edit Profile Screen
class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final EditProfileController controller = Get.put(EditProfileController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'Edit Profile'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Avatar Section
            Center(
              child: Obx(
                () => ProfileAvatar(
                  imageUrl: controller.profileImage.value,
                  onTap: () {
                    // Handle image selection
                    Get.snackbar('Photo', 'Photo selection feature would go here', snackPosition: SnackPosition.BOTTOM);
                  },
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Form Fields
            AppTextField(lableText: "Your Name", hintText: 'Enter your name ', controller: controller.nameController),
            const SizedBox(height: 20),

            AppTextField(
              lableText: 'Nick Name',
              hintText: "Enter your nick name",
              controller: controller.nickNameController,
            ),
            const SizedBox(height: 20),

            AppTextField(
              lableText: 'Email address',
              hintText: 'Enter your email',
              controller: controller.emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),

            AppTextField(
              lableText: 'Date of Birth',
              hintText: ' elect your date of birth',
              controller: controller.dobController,
              readOnly: true,
              onTap: () => controller.selectDate(context),
              suffixIcon: const Icon(LucideIcons.calendar),
            ),
            const SizedBox(height: 20),

            AppTextField(
              lableText: 'Pin Code',
              hintText: 'Your pin code',
              controller: controller.pinController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),

            AppTextField(
              lableText: 'Five words that describe you',
              hintText: 'Your Five words',
              controller: controller.fiveWordsController,
            ),
            const SizedBox(height: 20),

            AppTextField(
              // : 'BIO',
              lableText: 'BIO',
              controller: controller.bioController,
              maxLines: 3,
              hintText: 'Enter BIO',
            ),

            // Word count
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('Max 80 Word', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ),
            ),

            const SizedBox(height: 40),

            // Update Button
            AppButtonElevated(text: 'Update Profile', onPressed: controller.updateProfile),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// Reusable Gradient Button Component
// class GradientButton extends StatelessWidget {
//   final String text;
//   final VoidCallback onPressed;
//   final double? width;
//   final double height;
//   final List<Color> gradientColors;

//   const GradientButton({
//     super.key,
//     required this.text,
//     required this.onPressed,
//     this.width,
//     this.height = 50,
//     this.gradientColors = const [Color(0xFF26D0CE), Color(0xFF1A9CC9)],
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: width ?? double.infinity,
//       height: height,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(25),
//         gradient: LinearGradient(colors: gradientColors, begin: Alignment.centerLeft, end: Alignment.centerRight),
//       ),
//       child: ElevatedButton(
//         onPressed: onPressed,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.transparent,
//           shadowColor: Colors.transparent,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
//         ),
//         child: Text(
//           text,
//           style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
//         ),
//       ),
//     );
//   }
// }

// Reusable Custom Text Field Component
// class CustomTextField extends StatelessWidget {
//   final String label;
//   final TextEditingController controller;
//   final TextInputType? keyboardType;
//   final bool readOnly;
//   final Widget? suffixIcon;
//   final VoidCallback? onTap;
//   final int maxLines;
//   final String? hintText;

//   const CustomTextField({
//     Key? key,
//     required this.label,
//     required this.controller,
//     this.keyboardType,
//     this.readOnly = false,
//     this.suffixIcon,
//     this.onTap,
//     this.maxLines = 1,
//     this.hintText,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w500,
//             color: Colors.black87,
//           ),
//         ),
//         const SizedBox(height: 8),
//         Container(
//           decoration: BoxDecoration(
//             color: Colors.grey[50],
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: Colors.grey[200]!),
//           ),
//           child: TextFormField(
//             controller: controller,
//             keyboardType: keyboardType,
//             readOnly: readOnly,
//             onTap: onTap,
//             maxLines: maxLines,
//             decoration: InputDecoration(
//               hintText: hintText,
//               hintStyle: TextStyle(color: Colors.grey[400]),
//               border: InputBorder.none,
//               contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               suffixIcon: suffixIcon,
//             ),
//             style: const TextStyle(
//               fontSize: 16,
//               color: Colors.black87,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// Reusable Profile Avatar Component
class ProfileAvatar extends StatelessWidget {
  final String imageUrl;
  final double size;
  final VoidCallback? onTap;

  const ProfileAvatar({super.key, required this.imageUrl, this.size = 120, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey[300]!, width: 2),
              image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.teal,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
