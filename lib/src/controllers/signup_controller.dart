import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

import '../services/shared_pref_service.dart';
import '../utils/strings.dart';
import 'auth_controller.dart';

class SignUpController extends GetxController {
  // Controllers for form fields
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final dateOfBirthController = TextEditingController();
  final pinCodeController = TextEditingController();
  
  // Form key
  final formKey = GlobalKey<FormState>();
  
  // Observable variables
  final _selectedProfileImage = Rx<File?>(null);
  final _acceptTerms = RxBool(false);
  final _isLoading = RxBool(false);
  
  // ImagePicker instance
  final ImagePicker _picker = ImagePicker();
  
  // Getters
  File? get selectedProfileImage => _selectedProfileImage.value;
  bool get acceptTerms => _acceptTerms.value;
  bool get isLoading => _isLoading.value;
  
  @override
  void onInit() {
    super.onInit();
    _prePopulateData();
  }
  
  @override
  void onClose() {
    // Dispose controllers to prevent memory leaks
    nameController.dispose();
    emailController.dispose();
    dateOfBirthController.dispose();
    pinCodeController.dispose();
    super.onClose();
  }
  
  /// Pre-populate form data from Google Sign-In
  void _prePopulateData() {
    final AuthController authController = Get.find();
    final user = authController.user;
    
    if (user != null) {
      // Pre-fill email from Google account
      emailController.text = user.email;
      
      // Pre-fill name if available
      if (user.displayName != null && user.displayName!.isNotEmpty) {
        nameController.text = user.displayName!;
      }
    }
  }
  
  /// Toggle terms acceptance
  void toggleTermsAcceptance(bool? value) {
    _acceptTerms.value = value ?? false;
  }
  
  /// Select profile image from gallery
  Future<void> selectProfileImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      
      if (image != null) {
        _selectedProfileImage.value = File(image.path);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        duration: const Duration(seconds: 3),
      );
    }
  }
  
  /// Select date of birth
  Future<void> selectDateOfBirth() async {
    final DateTime? picked = await Get.dialog<DateTime>(
      DatePickerDialog(
        initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
        firstDate: DateTime(1920),
        lastDate: DateTime.now(),
      ),
    );

    if (picked != null) {
      dateOfBirthController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }
  
  /// Validate name field
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return Strings.nameRequired;
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }
  
  /// Validate email field
  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return Strings.emailRequired;
    }
    if (!GetUtils.isEmail(value.trim())) {
      return Strings.emailInvalid;
    }
    return null;
  }
  
  /// Validate date of birth field
  String? validateDateOfBirth(String? value) {
    if (value == null || value.trim().isEmpty) {
      return Strings.dateOfBirthRequired;
    }
    return null;
  }
  
  /// Validate pin code field
  String? validatePinCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return Strings.pinCodeRequired;
    }
    if (value.trim().length != 6 || !RegExp(r'^\d{6}$').hasMatch(value.trim())) {
      return Strings.pinCodeInvalid;
    }
    return null;
  }
  
  /// Handle signup form submission
  Future<void> handleSignUp() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (!_acceptTerms.value) {
      Get.snackbar(
        'Terms Required',
        Strings.termsRequired,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    try {
      _isLoading.value = true;
      
      final AuthController authController = Get.find();
      
      await authController.completeSignUp(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        dateOfBirth: dateOfBirthController.text.trim(),
        pinCode: pinCodeController.text.trim(),
        profileImage: _selectedProfileImage.value,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred: $e',
        duration: const Duration(seconds: 3),
      );
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// Navigate to login view
  void navigateToLogin() {
    if (Get.currentRoute != '/LoginView') {
      Get.back();
    }
  }
  
  /// Open privacy policy
  void openPrivacyPolicy() {
    // TODO: Implement privacy policy navigation
    Get.snackbar(
      'Info',
      'Privacy Policy will be opened here',
      duration: const Duration(seconds: 2),
    );
  }
  
  /// Open terms and conditions
  void openTermsAndConditions() {
    // TODO: Implement terms and conditions navigation
    Get.snackbar(
      'Info',
      'Terms & Conditions will be opened here',
      duration: const Duration(seconds: 2),
    );
  }
}