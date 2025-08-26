import 'package:fiwe/src/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/signup_controller.dart';
import '../../utils/constants.dart';
import '../../utils/strings.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class SignUpView extends StatelessWidget {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    // Use Get.find to get existing controller or Get.put with tag to ensure singleton
    final SignUpController controller = Get.isRegistered<SignUpController>()
        ? Get.find<SignUpController>()
        : Get.put(SignUpController(), permanent: false);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Form(
            key: controller.formKey,
            child: Column(
              children: [
                const SizedBox(height: 16),
                // Profile Image Picker with GetX
                Obx(
                  () => GestureDetector(
                    onTap: controller.selectProfileImage,
                    child: _buildProfileImageWidget(controller),
                  ),
                ),

                const SizedBox(height: 40),

                // Title
                Text(
                  Strings.signUpTitle,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    // color: Color(Constants.textColor),
                  ),
                ),

                const SizedBox(height: 12),

                // Subtitle
                Text(
                  Strings.signUpSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    // color: Color(Constants.hintTextColor),
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 8),

                // Name Field
                AppTextField(
                  hintText: Strings.nameHint,
                  prefixIcon: Icons.person_outline,
                  controller: controller.nameController,
                  validator: controller.validateName,
                  textCapitalization: TextCapitalization.words,
                ).paddingOnly(bottom: 14),

                // Email Field
                AppTextField(
                  hintText: Strings.emailHint,
                  prefixIcon: Icons.email_outlined,
                  controller: controller.emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: controller.validateEmail,
                  readOnly: true, // Pre-filled from Google Sign-In
                ).paddingOnly(bottom: 14),

                // Date of Birth Field
                AppTextField(
                  hintText: Strings.dateOfBirthHint,
                  prefixIcon: Icons.calendar_today_outlined,
                  controller: controller.dateOfBirthController,
                  readOnly: true,
                  onTap: controller.selectDateOfBirth,
                  validator: controller.validateDateOfBirth,
                ).paddingOnly(bottom: 14),

                // Pin Code Field
                AppTextField(
                  hintText: Strings.pinCodeHint,
                  prefixIcon: Icons.location_on_outlined,
                  controller: controller.pinCodeController,
                  keyboardType: TextInputType.number,
                  validator: controller.validatePinCode,
                  maxLength: 6,
                ),

                const SizedBox(height: 24),

                // Terms and Conditions Checkbox with GetX
                Obx(() => _buildTermsCheckbox(controller)),

                const SizedBox(height: 32),

                // Sign Up Button with GetX
                AppButtonElevated(
                  text: Strings.signUpButton,
                  onPressed: controller.handleSignUp,
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build profile image widget with GetX state
  Widget _buildProfileImageWidget(SignUpController controller) {
    return Stack(
      children: [
        Container(
          width: Constants.profileImageSize,
          height: Constants.profileImageSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surface,
            border: Border.all(color: AppColors.borderDark, width: 1),
            image: controller.selectedProfileImage != null
                ? DecorationImage(
                    image: FileImage(controller.selectedProfileImage!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: controller.selectedProfileImage == null
              ? Container(
                  margin: const EdgeInsets.all(4),
                  height: Constants.profileImageSize - 4,
                  width: Constants.profileImageSize - 4,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.backgroundLight,
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    size: 48,
                    color: AppColors.primary,
                  ),
                )
              : null,
        ),
        Positioned(bottom: 0, right: 0, child: const _CameraIconButton()),
      ],
    );
  }

  /// Build terms and conditions checkbox
  Widget _buildTermsCheckbox(SignUpController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 24,
            width: 24,
            child: Checkbox(
              value: controller.acceptTerms,
              onChanged: controller.toggleTermsAcceptance,
              activeColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Wrap(
              children: [
                Text(
                  Strings.privacyPolicyText,
                  style: TextStyle(
                    fontSize: 14,
                    // color: Color(Constants.textColor),
                  ),
                ),
                GestureDetector(
                  onTap: controller.openPrivacyPolicy,
                  child: Text(
                    Strings.privacyPolicy,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                Text(
                  Strings.andText,
                  style: TextStyle(
                    fontSize: 14,
                    // color: Color(Constants.textColor),
                  ),
                ),
                GestureDetector(
                  onTap: controller.openTermsAndConditions,
                  child: Text(
                    Strings.termsConditions,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Reusable camera icon button widget
class _CameraIconButton extends StatelessWidget {
  const _CameraIconButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF0891B2),
      ),
      child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
    );
  }
}
