import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fiwe/src/services/fcm_notification_service.dart';
import 'package:fiwe/src/utils/colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pinput/pinput.dart';

import '../services/http_service.dart';
import '../services/phone_auth_service.dart';
import '../services/shared_pref_service.dart';
import '../utils/constants.dart';
import '../utils/endpoints.dart';
import '../utils/loading_overlay.dart';
import '../utils/strings.dart';
import '../widgets/custom_button.dart';
import 'auth_controller.dart';

class SignUpController extends GetxController {
  // Form controllers and key
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final otpController = TextEditingController();
  final dateOfBirthController = TextEditingController();
  final pinCodeController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // Observables
  final _selectedProfileImage = Rx<File?>(null);
  final _acceptTerms = RxBool(false);
  final _isLoading = RxBool(false);

  // Phone verification observables
  final _verificationId = RxString('');
  final _isPhoneVerified = RxBool(false);
  final _isPhoneVerifying = RxBool(false);
  final _isOtpSent = RxBool(false);
  final _otpResendEnabled = RxBool(false);
  final _countdown = RxInt(0);
  Timer? _countdownTimer;

  // Services
  final _picker = ImagePicker();
  final _httpService = Get.find<HttpService>();
  final _phoneAuthService = PhoneAuthService();

  String otpSentTo = '';

  // Getters
  bool get acceptTerms => _acceptTerms.value;
  int get countdown => _countdown.value;
  bool get isLoading => _isLoading.value;

  bool get isOtpSent => _isOtpSent.value;
  bool get isPhoneVerified => _isPhoneVerified.value;
  bool get isPhoneVerifying => _isPhoneVerifying.value;
  bool get otpResendEnabled => _otpResendEnabled.value;
  // Phone verification getters
  String get phoneNumber => phoneController.text;
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

      if (response.success) {
        final data = response.data as Map<String, dynamic>;
        return data;
      } else {
        throw Exception('Failed to signup: ${response.message}');
      }
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

    // if (!_isPhoneVerified.value) {
    //   Get.snackbar(Strings.phoneVerificationRequired, Strings.pleaseVerifyPhone);
    //   return;
    // }

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
        final access = apiResponse[Constants.responseAccessKey];
        final refresh = apiResponse[Constants.responseRefreshKey];

        if (access != null && refresh != null) {
          await SharedPrefService.setString(Constants.storageBearerTokenKey, access);
          await SharedPrefService.setString(Constants.storageBearerTokenRefreshKey, refresh);
        }

        // Complete signup in auth controller
        final authController = Get.find<AuthController>();
        await authController.completeSignUp(apiResponse);
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
    phoneController.dispose();
    otpController.dispose();
    dateOfBirthController.dispose();
    pinCodeController.dispose();
    _stopCountdown();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    _prePopulateData();
    _setupPhoneListener();
  }

  /// Open privacy policy
  void openPrivacyPolicy() => Get.snackbar(Strings.info, Strings.privacyPolicyInfo);

  /// Open terms and conditions
  void openTermsAndConditions() => Get.snackbar(Strings.info, Strings.termsConditionsInfo);

  /// Resend OTP to the same phone number
  Future<void> resendOtp() async {
    final phone = phoneController.text.trim();
    if (validatePhone(phone) != null) return;

    try {
      _isPhoneVerifying.value = true;

      final verificationId = await executeWithLoading(_phoneAuthService.resendOtp(phone));

      _verificationId.value = verificationId;
      _startCountdown();
      otpController.clear();

      Get.snackbar(Strings.otpSent, Strings.otpSentSuccessfully);
    } catch (e) {
      if (kDebugMode) print(Strings.formatErrorMessage('Resend OTP Error', e));
      Get.snackbar(Strings.otpError, Strings.formatErrorMessage(Strings.failedToSendOtp, e));
    } finally {
      _isPhoneVerifying.value = false;
    }
  }

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

  /// Send OTP to phone number
  Future<void> sendOtp() async {
    final phone = phoneController.text.trim();
    if (validatePhone(phone) != null) return;
    otpSentTo = phone;
    try {
      _isPhoneVerifying.value = true;

      final verificationId = await executeWithLoading(_phoneAuthService.sendOtp(phone));

      _verificationId.value = verificationId;
      _isOtpSent.value = true;
      _startCountdown();
      _showOtpBottomSheet();

      Get.snackbar(Strings.otpSent, Strings.otpSentSuccessfully);
    } catch (e) {
      if (kDebugMode) print(Strings.formatErrorMessage('Send OTP Error', e));
      Get.snackbar(Strings.otpError, Strings.formatErrorMessage(Strings.failedToSendOtp, e));
    } finally {
      _isPhoneVerifying.value = false;
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

  /// OTP validation
  String? validateOtp(String? value) {
    if (value?.trim().isEmpty ?? true) return Strings.otpRequired;
    final otp = value!.trim();
    if (otp.length != Constants.otpMaxLength) return Strings.otpInvalid;
    if (!RegExp(r'^\d{6}$').hasMatch(otp)) return Strings.otpInvalidFormat;
    return null;
  }

  /// Phone number validation
  String? validatePhone(String? value) {
    if (value?.trim().isEmpty ?? true) return Strings.phoneRequired;
    final phone = value!.trim();
    if (phone.length != Constants.phoneMaxLength) return Strings.phoneInvalid;
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(phone)) return Strings.phoneInvalidFormat;
    return null;
  }

  String? validatePinCode(String? value) {
    if (value?.trim().isEmpty ?? true) return Strings.pinCodeRequired;
    return (value!.trim().length != Constants.pinCodeLength || !RegExp(r'^\d{6}$').hasMatch(value.trim()))
        ? Strings.pinCodeInvalid
        : null;
  }

  /// Verify OTP entered by user
  Future<void> verifyOtp() async {
    final otp = otpController.text.trim();
    if (validateOtp(otp) != null) return;

    try {
      _isPhoneVerifying.value = true;

      final isVerified = await executeWithLoading(_phoneAuthService.verifyOtp(_verificationId.value, otp, phoneNumber));

      if (isVerified) {
        _isPhoneVerified.value = true;
        _stopCountdown();
        Get.back(); // Close bottom sheet
        Get.snackbar(Strings.verificationSuccess, Strings.phoneVerifiedSuccessfully);
      } else {
        Get.snackbar(Strings.verificationFailed, Strings.invalidOtp);
      }
    } catch (e) {
      if (kDebugMode) print(Strings.formatErrorMessage('Verify OTP Error', e));
      Get.snackbar(Strings.verificationError, Strings.formatErrorMessage(Strings.failedToVerifyOtp, e));
    } finally {
      _isPhoneVerifying.value = false;
    }
  }

  /// Build OTP bottom sheet widget
  Widget _buildOtpBottomSheet() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Get.theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(Strings.verifyPhoneTitle, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              IconButton(
                onPressed: () {
                  _stopCountdown();
                  Get.back();
                },
                icon: Icon(Icons.close),
              ),
            ],
          ),

          SizedBox(height: 8),

          // Phone number display
          Text(
            '${Strings.otpSentTo} ${Constants.countryCode} ${phoneController.text}',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),

          SizedBox(height: 24),

          // OTP input field
          // AppTextField(
          //   hintText: Strings.otpHint,
          //   prefixIcon: Icons.lock_outline,
          //   controller: otpController,
          //   keyboardType: TextInputType.number,
          //   validator: validateOtp,
          //   maxLength: Constants.otpMaxLength,
          // ),
          Pinput(
            controller: otpController,
            length: Constants.otpMaxLength,
            validator: validateOtp,
            onChanged: (value) {
              if (value.length == Constants.otpMaxLength) {
                verifyOtp();
              }
            },
            defaultPinTheme: PinTheme(
              width: 56,
              height: 56,
              textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            focusedPinTheme: PinTheme(
              width: 56,
              height: 56,
              textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            submittedPinTheme: PinTheme(
              width: 56,
              height: 56,
              textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              decoration: BoxDecoration(
                border: Border.all(color: Get.theme.primaryColor),
                borderRadius: BorderRadius.circular(8),
                color: AppColors.primary.withAlpha(50),
              ),
            ),
            pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
            showCursor: true,
          ),
          SizedBox(height: 24),

          // Verify button
          Obx(() => AppButtonElevated(text: Strings.verifyOtp, onPressed: isPhoneVerifying ? null : verifyOtp)),

          SizedBox(height: 16),

          // Resend OTP
          Obx(
            () => otpResendEnabled
                ? TextButton(onPressed: resendOtp, child: Text(Strings.resendOtp))
                : Text('${Strings.resendOtpIn} ${countdown}s', style: TextStyle(color: Colors.grey[600])),
          ),

          SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Helper methods
  Future<String> _getDeviceId() async {
    return FCMNotificationService.instance.deviceToken ?? 'Unknown';
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

  /// Setup phone number listener for automatic OTP triggering
  void _setupPhoneListener() {
    phoneController.addListener(() {
      final phone = phoneController.text.trim();
      if (phone.length == Constants.phoneMaxLength &&
          !_isPhoneVerified.value &&
          !_isPhoneVerifying.value &&
          validatePhone(phone) == null &&
          phone != otpSentTo) {
        // Automatically send OTP when 10 valid digits are entered
        sendOtp();
      }
    });
  }

  /// Show OTP bottom sheet
  void _showOtpBottomSheet() {
    Get.bottomSheet(_buildOtpBottomSheet(), isDismissible: false, enableDrag: false, isScrollControlled: true);
  }

  /// Start countdown timer for OTP resend
  void _startCountdown() {
    _otpResendEnabled.value = false;
    _countdown.value = Constants.otpResendTimeoutSeconds;

    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_countdown.value > 0) {
        _countdown.value--;
      } else {
        _otpResendEnabled.value = true;
        timer.cancel();
      }
    });
  }

  /// Stop countdown timer
  void _stopCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _otpResendEnabled.value = true;
  }
}
