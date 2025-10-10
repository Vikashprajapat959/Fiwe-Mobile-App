// Controller for managing profile data
import 'package:fiwe/src/controllers/auth_controller.dart';
import 'package:fiwe/src/services/user_service.dart';
import 'package:fiwe/src/utils/helper.dart';
import 'package:fiwe/src/utils/loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileController extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController nickNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController pinController = TextEditingController();
  final TextEditingController fiveWordsController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  RxString profileImage = ''.obs;
  final authController = Get.find<AuthController>();

  final userService = UserService.instance;
  @override
  void onClose() {
    nameController.dispose();
    nickNameController.dispose();
    emailController.dispose();
    dobController.dispose();
    pinController.dispose();
    fiveWordsController.dispose();
    bioController.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    _loadUserData();
    super.onInit();
  }

  void _loadUserData() {
    final user = authController.userProfile;
    if (user != null) {
      nameController.text = user.name ?? '';
      nickNameController.text = user.nickName ?? '';
      emailController.text = user.email ?? '';
      dobController.text = user.dateOfBirth ?? '';
      pinController.text = user.pincode ?? '';
      fiveWordsController.text = user.fiveWords ?? '';
      bioController.text = user.bio ?? '';
      profileImage.value = user.profileBase64 ?? '';
    }
  }

  void selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      // dobController.text =
      //     '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';

      // yyyy-mm-dd format
      final formattedDate =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      if (formattedDate.isNotEmpty) {
        dobController.text = formattedDate;
      }
    }
  }

  void updateProfile() async {
    // check if no updates made
    final user = authController.userProfile;
    if (user != null &&
        nameController.text == (user.name ?? '') &&
        nickNameController.text == (user.nickName ?? '') &&
        emailController.text == (user.email ?? '') &&
        dobController.text == (user.dateOfBirth ?? '') &&
        pinController.text == (user.pincode ?? '') &&
        fiveWordsController.text == (user.fiveWords ?? '') &&
        profileImage.value == (user.profileBase64 ?? '') &&
        bioController.text == (user.bio ?? '')) {
      Get.snackbar('Info', 'No changes made to update');
      return;
    }

    try {
      LoadingOverlay.show();

      final response = await userService.updateProfile(
        nameController.text,
        nickNameController.text,
        emailController.text,
        dobController.text,
        pinController.text,
        fiveWordsController.text,
        bioController.text,
        imageBase64: profileImage.value,
      );
      if (response.success) {
        Get.snackbar('Success', 'Profile updated successfully', snackPosition: SnackPosition.BOTTOM);
        // Update local user profile
        authController.userProfile = authController.userProfile?.copyWith(
          name: nameController.text,
          nickName: nickNameController.text,
          email: emailController.text,
          dateOfBirth: dobController.text,
          pincode: pinController.text,
          fiveWords: fiveWordsController.text,
          bio: bioController.text,
          profileBase64: profileImage.value,
        );
        // Close the edit profile view
      } else {
        Get.snackbar('Error', response.message, snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      LoadingOverlay.hide();
    }
  }

  void pickProfileImage() {
    ImagePicker()
        .pickImage(source: ImageSource.gallery, maxWidth: 600, maxHeight: 600, imageQuality: 80)
        .then((pickedFile) {
          if (pickedFile != null) {
            //profileImage.value = pickedFile.path;
            // convert image to base64 and update user profile
            Helper.imageFileToBase64(pickedFile)
                .then((base64Image) {
                  profileImage.value = base64Image;
                })
                .catchError((e) {
                  Get.snackbar('Error', 'Failed to process image: $e', snackPosition: SnackPosition.BOTTOM);
                });
          }
        })
        .catchError((e) {
          Get.snackbar('Error', 'Failed to pick image: $e', snackPosition: SnackPosition.BOTTOM);
        });
  }
}
