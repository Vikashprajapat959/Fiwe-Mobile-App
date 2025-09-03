import 'package:fiwe/src/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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
                  prefixIcon: LucideIcons.userPen,
                  controller: controller.nameController,
                  validator: controller.validateName,
                  textCapitalization: TextCapitalization.words,
                ).paddingOnly(bottom: 14),

                // Email Field
                AppTextField(
                  hintText: Strings.emailHint,
                  prefixIcon: LucideIcons.mail,
                  controller: controller.emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: controller.validateEmail,
                  readOnly: true, // Pre-filled from Google Sign-In
                ).paddingOnly(bottom: 14),

                // Phone Number Field
                Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextField(
                        hintText: Strings.phoneHint,
                        prefixIcon: LucideIcons.phone,
                        controller: controller.phoneController,
                        keyboardType: TextInputType.phone,
                        validator: controller.validatePhone,
                        maxLength: Constants.phoneMaxLength,
                        readOnly: controller.isPhoneVerified,
                      ),
                      if (controller.isPhoneVerified)
                        Padding(
                          padding: const EdgeInsets.only(top: 4, left: 16),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green, size: 16),
                              SizedBox(width: 4),
                              Text('Phone number verified', style: TextStyle(color: Colors.green, fontSize: 12)),
                            ],
                          ),
                        ),
                    ],
                  ).paddingOnly(bottom: 14),
                ),

                // Date of Birth Field
                AppTextField(
                  hintText: Strings.dateOfBirthHint,
                  prefixIcon: LucideIcons.calendar,
                  controller: controller.dateOfBirthController,
                  readOnly: true,
                  onTap: controller.selectDateOfBirth,
                  validator: controller.validateDateOfBirth,
                ).paddingOnly(bottom: 14),

                // Pin Code Field
                AppTextField(
                  hintText: Strings.pinCodeHint,
                  prefixIcon: LucideIcons.mapPin,
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
                AppButtonElevated(text: Strings.signUpButton, onPressed: controller.handleSignUp),

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
          padding: EdgeInsets.all(2),
          width: Constants.profileImageSize,
          height: Constants.profileImageSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surface,
            border: Border.all(color: AppColors.borderDark, width: 1),
          ),
          child: controller.selectedProfileImage == null
              ? Container(
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.backgroundLight),
                  child: const Icon(LucideIcons.user, size: 48, color: AppColors.primary),
                )
              : Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(image: FileImage(controller.selectedProfileImage!), fit: BoxFit.cover),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.backgroundLight, width: 2),
                  ),
                ),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
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
                    style: TextStyle(fontSize: 14, color: AppColors.primary, decoration: TextDecoration.underline),
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
                    style: TextStyle(fontSize: 14, color: AppColors.primary, decoration: TextDecoration.underline),
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
      decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
      child: Icon(LucideIcons.camera, color: Colors.white),
    );
  }
}
