import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../services/http_service.dart';
import '../services/shared_pref_service.dart';
import '../utils/constants.dart';
import '../utils/endpoints.dart';
import '../utils/loading_overlay.dart';
import '../utils/strings.dart';
import 'auth_controller.dart';

class SignUpController extends GetxController {
  // Form controllers and key
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final dateOfBirthController = TextEditingController();
  final pinCodeController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // Observables
  final _selectedProfileImage = Rx<File?>(null);
  final _acceptTerms = RxBool(false);
  final _isLoading = RxBool(false);

  // Services
  final _picker = ImagePicker();
  final _httpService = HttpService();

  // Getters
  bool get acceptTerms => _acceptTerms.value;
  bool get isLoading => _isLoading.value;
  File? get selectedProfileImage => _selectedProfileImage.value;

  /// Call signup API with form data
  Future<Map<String, dynamic>?> callSignupAPI({
    required String name,
    required String email,
    required String dateOfBirth,
    required String pinCode,
    required bool isTncAccepted,
  }) async {
    try {
      final body = {
        'name': name.trim(),
        'email': email.trim(),
        'dob': dateOfBirth.trim(),
        'pincode': pinCode.trim(),
        'is_tnc_accepted': isTncAccepted,
        'device_id': await _getDeviceId(),
        if (_imageToBase64(_selectedProfileImage.value) != null)
          'profile_image': _imageToBase64(_selectedProfileImage.value),
      };

      final response = await _httpService.post(Endpoints.signup, body: body);

      if (response.body.isNotEmpty) {
        final data = Map<String, dynamic>.from(json.decode(response.body));
        return data.containsKey('success') || data.containsKey('message') ? data : {...data, 'success': true};
      }

      return {Constants.responseSuccessKey: true, Constants.responseMessageKey: Strings.signupSuccessful};
    } catch (e) {
      if (kDebugMode) print(Strings.formatErrorMessage('Signup API Error', e));
      Get.snackbar(
        Strings.apiError,
        Strings.formatErrorMessage(Strings.failedToCompleteSignup, e),
        duration: Duration(seconds: Constants.snackbarDurationSeconds),
      );
      return null;
    }
  }

  /// Handle signup form submission
  Future<void> handleSignUp() async {
    if (!formKey.currentState!.validate()) {
      Get.snackbar(Strings.validationError, Strings.pleaseFixFormErrors);
      return;
    }

    if (!_acceptTerms.value) {
      Get.snackbar(Strings.termsRequiredTitle, Strings.termsRequired);
      return;
    }

    if (_selectedProfileImage.value == null) {
      Get.snackbar(Strings.profilePictureRequiredTitle, Strings.profilePictureRequired);
      return;
    }

    try {
      _isLoading.value = true;

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
        // Save tokens if available
        final access = apiResponse[Constants.responseAccessTokenKey] ?? apiResponse[Constants.responseAccessKey];
        final refresh = apiResponse[Constants.responseRefreshTokenKey] ?? apiResponse[Constants.responseRefreshKey];

        if (access != null && refresh != null) {
          await SharedPrefService.setString(Constants.storageBearerTokenKey, access);
          await SharedPrefService.setString(Constants.storageBearerTokenRefreshKey, refresh);
        }

        // Complete signup in auth controller
        final authController = Get.find<AuthController>();
        await authController.completeSignUp(
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          dateOfBirth: dateOfBirthController.text.trim(),
          pinCode: pinCodeController.text.trim(),
          profileImage: _selectedProfileImage.value,
        );
      } else {
        Get.snackbar(Strings.signupFailed, Strings.pleaseTryAgain);
      }
    } catch (e) {
      if (kDebugMode) print(Strings.formatErrorMessage('Signup Error', e));
      Get.snackbar(Strings.error, Strings.unexpectedSignupError);
    } finally {
      _isLoading.value = false;
    }
  }

  /// Navigate to login view
  void navigateToLogin() => Get.currentRoute != Constants.loginViewRoute ? Get.back() : null;

  @override
  void onClose() {
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
  void openPrivacyPolicy() => Get.snackbar(Strings.info, Strings.privacyPolicyInfo);

  /// Open terms and conditions
  void openTermsAndConditions() => Get.snackbar(Strings.info, Strings.termsConditionsInfo);

  /// Select date of birth
  Future<void> selectDateOfBirth() async {
    final picked = await Get.dialog<DateTime>(
      DatePickerDialog(
        initialDate: DateTime.now().subtract(Duration(days: 365 * Constants.minAgeYears)),
        firstDate: DateTime(Constants.minYear),
        lastDate: DateTime.now(),
      ),
    );

    if (picked != null) {
      dateOfBirthController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  /// Select profile image from gallery
  Future<void> selectProfileImage() async {
    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: Constants.imageMaxWidth,
        maxHeight: Constants.imageMaxHeight,
        imageQuality: Constants.imageQuality,
      );

      if (image != null) {
        final file = File(image.path);
        final fileSize = await file.length();

        if (fileSize > Constants.maxFileSizeBytes) {
          Get.snackbar(Strings.fileTooLarge, Strings.selectImageSmallerThan5MB);
          return;
        }

        _selectedProfileImage.value = file;
        Get.snackbar(Strings.imageSelected, Strings.profileImageSelectedSuccessfully);
      }
    } catch (e) {
      if (kDebugMode) print(Strings.formatErrorMessage('Image picker error', e));
      Get.snackbar(Strings.error, Strings.failedToSelectImage);
    }
  }

  /// Toggle terms acceptance
  void toggleTermsAcceptance(bool? value) => _acceptTerms.value = value ?? false;

  String? validateDateOfBirth(String? value) => (value?.trim().isEmpty ?? true) ? Strings.dateOfBirthRequired : null;

  String? validateEmail(String? value) {
    if (value?.trim().isEmpty ?? true) return Strings.emailRequired;
    return !GetUtils.isEmail(value!.trim()) ? Strings.emailInvalid : null;
  }

  /// Validation methods
  String? validateName(String? value) {
    if (value?.trim().isEmpty ?? true) return Strings.nameRequired;
    return value!.trim().length < Constants.minNameLength ? Strings.nameMinLength : null;
  }

  String? validatePinCode(String? value) {
    if (value?.trim().isEmpty ?? true) return Strings.pinCodeRequired;
    return (value!.trim().length != Constants.pinCodeLength || !RegExp(r'^\d{6}$').hasMatch(value.trim()))
        ? Strings.pinCodeInvalid
        : null;
  }

  /// Helper methods
  Future<String> _getDeviceId() async {
    try {
      return await FirebaseMessaging.instance.getToken() ?? Constants.unknownDevice;
    } catch (e) {
      return Constants.unknownDevice;
    }
  }

  String? _imageToBase64(File? imageFile) {
    if (imageFile?.existsSync() != true) return null;

    try {
      final bytes = imageFile!.readAsBytesSync();
      return bytes.isNotEmpty ? base64Encode(bytes) : null;
    } catch (e) {
      if (kDebugMode) print(Strings.formatErrorMessage('Error converting image to base64', e));
      return null;
    }
  }

  void _prePopulateData() {
    final userInfo = Get.find<AuthController>().currentUserInfo;

    if (userInfo[Constants.userInfoEmailKey]?.isNotEmpty == true) {
      emailController.text = userInfo[Constants.userInfoEmailKey]!;
    }

    if (userInfo[Constants.userInfoDisplayNameKey]?.isNotEmpty == true) {
      nameController.text = userInfo[Constants.userInfoDisplayNameKey]!;
    }
  }
}
