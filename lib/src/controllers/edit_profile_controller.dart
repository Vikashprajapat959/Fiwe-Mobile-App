// Controller for managing profile data
import 'package:fiwe/src/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    var user = authController.userProfile;
    if (user != null) {
      nameController.text = user.name ?? '';
      nickNameController.text = "" ?? '';
      emailController.text = user.email ?? '';
      dobController.text = user.dateOfBirth ?? '';
      pinController.text = user.pincode ?? '';
      fiveWordsController.text = "" ?? '';
      bioController.text = "" ?? '';
      profileImage.value = user.profileImageUrl ?? '';
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
      dobController.text =
          '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
    }
  }

  void updateProfile() {
    // Handle profile update logic
    Get.snackbar(
      'Success',
      'Profile updated successfully!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }
}
