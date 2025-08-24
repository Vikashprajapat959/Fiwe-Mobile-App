import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/signup_controller.dart';
import '../../utils/strings.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class SignUpView extends StatelessWidget {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    // Use Get.find to get existing controller or Get.put with tag to ensure singleton
    final SignUpController controller = Get.isRegistered<SignUpController>() 
        ? Get.find<SignUpController>()
        : Get.put(SignUpController(), permanent: false);
    
    return Scaffold(
      backgroundColor: Color(Constants.backgroundColor),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: controller.formKey,
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  
                  // Profile Image Picker with GetX
                  Obx(() => GestureDetector(
                    onTap: controller.selectProfileImage,
                    child: _buildProfileImageWidget(controller),
                  )),
                  
                  const SizedBox(height: 40),
                  
                  // Title
                  Text(
                    Strings.signUpTitle,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(Constants.textColor),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Subtitle
                  Text(
                    Strings.signUpSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(Constants.hintTextColor),
                      height: 1.4,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Name Field
                  CustomTextField(
                    hintText: Strings.nameHint,
                    prefixIcon: Icons.person_outline,
                    controller: controller.nameController,
                    validator: controller.validateName,
                    textCapitalization: TextCapitalization.words,
                  ),
                  
                  // Email Field
                  CustomTextField(
                    hintText: Strings.emailHint,
                    prefixIcon: Icons.email_outlined,
                    controller: controller.emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: controller.validateEmail,
                    readOnly: true, // Pre-filled from Google Sign-In
                  ),
                  
                  // Date of Birth Field
                  CustomTextField(
                    hintText: Strings.dateOfBirthHint,
                    prefixIcon: Icons.calendar_today_outlined,
                    controller: controller.dateOfBirthController,
                    readOnly: true,
                    onTap: controller.selectDateOfBirth,
                    validator: controller.validateDateOfBirth,
                  ),
                  
                  // Pin Code Field
                  CustomTextField(
                    hintText: Strings.pinCodeHint,
                    prefixIcon: Icons.location_on_outlined,
                    controller: controller.pinCodeController,
                    keyboardType: TextInputType.number,
                    validator: controller.validatePinCode,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Terms and Conditions Checkbox with GetX
                  Obx(() => _buildTermsCheckbox(controller)),
                  
                  const SizedBox(height: 32),
                  
                  // Sign Up Button with GetX
                  Obx(() => CustomButton(
                    text: Strings.signUpButton,
                    onPressed: controller.isLoading ? null : controller.handleSignUp,
                    isLoading: controller.isLoading,
                  )),
                  
                  const SizedBox(height: 24),
                  
                  // Sign In Link
                  _buildSignInLink(controller),
                  
                  const SizedBox(height: 32),
                ],
              ),
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
            color: const Color(0xFFF5F5F5),
            border: Border.all(
              color: const Color(0xFFE5E7EB),
              width: 2,
            ),
            image: controller.selectedProfileImage != null
                ? DecorationImage(
                    image: FileImage(controller.selectedProfileImage!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: controller.selectedProfileImage == null
              ? const Icon(
                  Icons.person_outline,
                  size: 48,
                  color: Color(0xFF0891B2),
                )
              : null,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF0891B2),
            ),
            child: const Icon(
              Icons.camera_alt,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
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
              activeColor: Color(Constants.primaryColor),
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
                    color: Color(Constants.textColor),
                  ),
                ),
                GestureDetector(
                  onTap: controller.openPrivacyPolicy,
                  child: Text(
                    Strings.privacyPolicy,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(Constants.primaryColor),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                Text(
                  Strings.andText,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(Constants.textColor),
                  ),
                ),
                GestureDetector(
                  onTap: controller.openTermsAndConditions,
                  child: Text(
                    Strings.termsConditions,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(Constants.primaryColor),
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
  
  /// Build sign in link
  Widget _buildSignInLink(SignUpController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          Strings.haveAccountText,
          style: TextStyle(
            fontSize: 16,
            color: Color(Constants.hintTextColor),
          ),
        ),
        GestureDetector(
          onTap: controller.navigateToLogin,
          child: Text(
            Strings.signInLink,
            style: TextStyle(
              fontSize: 16,
              color: Color(Constants.primaryColor),
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.underline,
              decorationColor: Color(Constants.primaryColor),
            ),
          ),
        ),
      ],
    );
  }
}
