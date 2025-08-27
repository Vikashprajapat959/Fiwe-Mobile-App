import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fiwe/src/services/shared_pref_service.dart';
import 'package:fiwe/src/utils/constants.dart';
import 'package:fiwe/src/utils/loading_overlay.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../services/http_service.dart';
import '../utils/endpoints.dart';
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

  // Services
  final ImagePicker _picker = ImagePicker();
  final HttpService _httpService = HttpService();

  bool get acceptTerms => _acceptTerms.value;
  bool get isLoading => _isLoading.value;
  // Getters
  File? get selectedProfileImage => _selectedProfileImage.value;

  /// Call API for signup with comprehensive error handling
  Future<Map<String, dynamic>?> callSignupAPI({
    required String name,
    required String email,
    required String dateOfBirth,
    required String pinCode,
    required bool isTncAccepted,
  }) async {
    try {
      // Validate inputs before API call
      if (name.trim().isEmpty || email.trim().isEmpty || dateOfBirth.trim().isEmpty || pinCode.trim().isEmpty) {
        throw ArgumentError('All required fields must be provided');
      }

      // Get device ID
      final deviceId = await _getDeviceId();

      // Convert profile image to base64 if exists
      final profileImageBase64 = _imageToBase64(_selectedProfileImage.value);

      // Prepare request body
      final body = {
        'name': name.trim(),
        'email': email.trim(),
        'dob': dateOfBirth.trim(),
        'pincode': pinCode.trim(),
        'is_tnc_accepted': isTncAccepted,
        'device_id': deviceId,
        if (profileImageBase64 != null) 'profile_image': profileImageBase64,
      };

      // Make API call
      final response = await _httpService.post(Endpoints.signup, body: body);

      // Parse response
      if (response.body.isNotEmpty) {
        final responseData = Map<String, dynamic>.from(json.decode(response.body));

        // Validate response structure
        if (responseData.containsKey('success') || responseData.containsKey('message')) {
          return responseData;
        }

        // If no success/message fields, consider it successful with data
        return {...responseData, 'success': true};
      }

      return {'success': true, 'message': 'Signup successful'};
    } catch (e) {
      if (kDebugMode) {
        print('Signup API Error: $e');
      }

      Get.snackbar('API Error', 'Failed to complete signup: ${e.toString()}', duration: const Duration(seconds: 3));
      return null;
    }
  }

  /// Handle signup form submission with improved error handling
  Future<void> handleSignUp() async {
    // Validate form first
    if (!formKey.currentState!.validate()) {
      Get.snackbar(
        'Validation Error',
        'Please fix the form errors and try again',
        duration: const Duration(seconds: 3),
      );
      return;
    }

    // Check terms acceptance
    if (!_acceptTerms.value) {
      Get.snackbar('Terms Required', Strings.termsRequired, duration: const Duration(seconds: 3));
      return;
    }

    // check if profile image is selected
    if (_selectedProfileImage() == null) {
      Get.snackbar('Profile Picture Required', Strings.profilePictureRequired, duration: const Duration(seconds: 3));
      return;
    }

    try {
      _isLoading.value = true;

      // Call the signup API with loading overlay
      final apiResponse = await executeWithLoading(
        callSignupAPI(
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          dateOfBirth: dateOfBirthController.text.trim(),
          pinCode: pinCodeController.text.trim(),
          isTncAccepted: _acceptTerms.value,
        ),
      );

      if (apiResponse != null) {
        // API call successful - proceed with local signup completion
        final AuthController authController = Get.find();

        // save access and refresh tokens from API response
        if (apiResponse['access_token'] != null && apiResponse['refresh_token'] != null) {
          await SharedPrefService.setString(Constants.bearerTokenRefreshKey, apiResponse['refresh']);
          await SharedPrefService.setString(Constants.bearerTokenKey, apiResponse['access']);
        }

        await authController.completeSignUp(
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          dateOfBirth: dateOfBirthController.text.trim(),
          pinCode: pinCodeController.text.trim(),
          profileImage: _selectedProfileImage.value,
        );
      } else {
        // API call failed - show specific error message
        final errorMessage = apiResponse?['message'] ?? apiResponse?['error'] ?? 'Signup failed. Please try again.';

        Get.snackbar('Signup Failed', errorMessage, duration: const Duration(seconds: 4));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Signup Error: $e');
      }

      Get.snackbar(
        'Error',
        'An unexpected error occurred during signup. Please try again.',
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

  @override
  void onClose() {
    // Dispose controllers to prevent memory leaks
    nameController.dispose();
    emailController.dispose();
    dateOfBirthController.dispose();
    pinCodeController.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    _prePopulateData();
  }

  /// Open privacy policy
  void openPrivacyPolicy() {
    // TODO: Implement privacy policy navigation
    Get.snackbar('Info', 'Privacy Policy will be opened here', duration: const Duration(seconds: 2));
  }

  /// Open terms and conditions
  void openTermsAndConditions() {
    // TODO: Implement terms and conditions navigation
    Get.snackbar('Info', 'Terms & Conditions will be opened here', duration: const Duration(seconds: 2));
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

  /// Select profile image from gallery with enhanced error handling
  Future<void> selectProfileImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        final file = File(image.path);

        // Validate file size (max 5MB)
        final fileSize = await file.length();
        if (fileSize > 5 * 1024 * 1024) {
          Get.snackbar(
            'File Too Large',
            'Please select an image smaller than 5MB',
            duration: const Duration(seconds: 3),
          );
          return;
        }

        _selectedProfileImage.value = file;

        Get.snackbar('Image Selected', 'Profile image selected successfully', duration: const Duration(seconds: 2));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Image picker error: $e');
      }

      Get.snackbar('Error', 'Failed to select image. Please try again.', duration: const Duration(seconds: 3));
    }
  }

  /// Toggle terms acceptance
  void toggleTermsAcceptance(bool? value) {
    _acceptTerms.value = value ?? false;
  }

  /// Validate date of birth field
  String? validateDateOfBirth(String? value) {
    if (value == null || value.trim().isEmpty) {
      return Strings.dateOfBirthRequired;
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

  /// Get device ID for API calls using FCM token
  Future<String> _getDeviceId() async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      return fcmToken ?? 'unknown';
    } catch (e) {
      return 'unknown';
    }
  }

  /// Convert profile image to base64 string with error handling
  String? _imageToBase64(File? imageFile) {
    if (imageFile == null) return null;

    try {
      // Check if file exists
      if (!imageFile.existsSync()) {
        if (kDebugMode) {
          print('Image file does not exist: ${imageFile.path}');
        }
        return null;
      }

      final bytes = imageFile.readAsBytesSync();

      // Validate file is not empty
      if (bytes.isEmpty) {
        if (kDebugMode) {
          print('Image file is empty');
        }
        return null;
      }

      return base64Encode(bytes);
    } catch (e) {
      if (kDebugMode) {
        print('Error converting image to base64: $e');
      }
      return null;
    }
  }

  /// Pre-populate form data from authentication provider
  void _prePopulateData() {
    final AuthController authController = Get.find();
    final userInfo = authController.currentUserInfo;

    // Pre-fill email if available
    if (userInfo['email'] != null) {
      emailController.text = userInfo['email']!;
    }

    // Pre-fill name if available
    if (userInfo['displayName'] != null && userInfo['displayName']!.isNotEmpty) {
      nameController.text = userInfo['displayName']!;
    }
  }
}
