import 'package:fiwe/src/utils/colors.dart';
import 'package:flutter/painting.dart';

/// Application constants following Flutter AI rules for maintainability
class Constants {
  // Private constructor to prevent instantiation
  Constants._();

  // API Response Keys (from backend responses)
  static const String responseAccessKey = 'access';
  static const String responseRefreshKey = 'refresh';
  static const String responseSuccessKey = 'success';
  static const String responseMessageKey = 'message';
  static const String responseIsNewKey = 'is_new';

  // API Request Keys (for sending to backend)
  static const String requestIdTokenKey = 'id_token';
  static const String requestProviderKey = 'provider';

  // User Info Keys (from auth providers)
  static const String userInfoEmailKey = 'email';
  static const String userInfoDisplayNameKey = 'displayName';
  static const String userInfoIdKey = 'id';

  // SharedPreferences Storage Keys (for local storage)
  static const String storageLoginTokenKey = 'login_token';
  static const String storageLoginUserIdKey = 'login_user_id';
  static const String storageLoginUsernameKey = 'login_username';
  static const String storageLoginEmailKey = 'login_email';
  static const String storageBearerTokenKey = 'bearer_token';
  static const String storageBearerTokenRefreshKey = 'bearer_token_refresh';
  static const String storageUserSelectedInterestsKey = 'user_selected_interests';

  // Provider constants
  static const String googleProvider = 'google';
  static const String appleProvider = 'apple';
  static const String countryCode = '+91';

  // Route names
  static const String homeViewRoute = '/home';
  static const String loginViewRoute = '/login';
  static const String signUpViewRoute = '/signup';
  static const String interestSelectionViewRoute = '/interest-selection';
  static const String otpBottomSheetRoute = '/otp-verification';
  static const String createRoomRoute = '/create/room';
  static const String videoRoomRoute = '/video-room';
  static const String profileScreenRoute = '/profile';
  static const String userRatingRoute = '/user-rating';

  // Timeout durations (in seconds)
  static const int apiTimeoutSeconds = 30;
  static const int otpTimeoutSeconds = 60;
  static const int otpResendTimeoutSeconds = 30;
  static const int snackbarDurationSeconds = 3;
  static const int splashDelaySeconds = 2;
  static const int appInfoDurationSeconds = 2;
  static const int foregroundNotificationDurationSeconds = 5;

  // Timeout durations (in milliseconds)
  static const int navigationDelayMilliseconds = 100;
  static const int notificationAnimationDurationMs = 300;

  // Legacy User Profile Keys (for SharedPreferences - consider deprecating)
  static const String userNameKey = 'user_name';
  static const String userEmailKey = 'user_email';
  static const String userDateOfBirthKey = 'user_date_of_birth';
  static const String userPinCodeKey = 'user_pin_code';
  static const String userProfileImageKey = 'user_profile_image';
  static const String userDisplayNameKey = 'user_display_name';
  static const String userIdTokenKey = 'user_id_token';
  static const String isUserRegisteredKey = 'is_user_registered';

  // UI Design dimensions
  static const double defaultBorderRadius = 16.0;
  static const double profileImageSize = 120.0;
  static const double textFieldHeight = 44.0;
  static const double textFieldRadius = 8.0;
  static const double buttonHeight = 44.0;
  static const double buttonRadius = 12.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double borderRadius = 12.0;
  static const double iconSize = 24.0;
  static const double avatarSize = 60.0;
  static const double boxHeightCircle = 100.0;
  static const double paddingAll = 16.0;

  // String constants
  static const String nameSeparator = ' ';
  static const String emptyString = '';
  static const String unknownDevice = 'unknown';

  // File handling constants
  static const int maxFileSizeBytes = 5 * 1024 * 1024; // 5MB
  static const double imageMaxWidth = 512.0;
  static const double imageMaxHeight = 512.0;
  static const int imageQuality = 80;

  // Validation constants
  static const int minNameLength = 2;
  static const int pinCodeLength = 6;
  static const int phoneMaxLength = 10;
  static const int otpMaxLength = 6;
  static const int minAgeYears = 18;
  static const int minYear = 1920;
  static const int maxDisplayStringLength = 50; // For SharedPreferences table display

  // API response keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';

  // Notification constants
  static const int maxInMemoryNotifications = 20; // Limit for current session only

  // Notification channels (Android)
  static const String notificationChannelHighPriority = 'high_priority_channel';
  static const String notificationChannelNormalPriority = 'normal_priority_channel';
  static const String notificationChannelLowPriority = 'low_priority_channel';
  static const String notificationChannelUrgentPriority = 'urgent_priority_channel';

  // Notification UI dimensions
  static const double notificationTopMargin = 8.0;
  static const double notificationHorizontalMargin = 16.0;
  static const double notificationElevation = 8.0;
  static const double notificationBorderRadius = 12.0;
  static const double notificationPadding = 16.0;
  static const double notificationIconPadding = 8.0;
  static const double notificationIconBorderRadius = 8.0;
  static const double notificationIconSize = 24.0;
  static const double notificationContentSpacing = 12.0;
  static const double notificationTextSpacing = 4.0;
  static const double notificationTitleFontSize = 14.0;
  static const double notificationBodyFontSize = 12.0;
  static const double notificationHintFontSize = 10.0;
  static const double notificationCloseButtonPadding = 4.0;
  static const double notificationCloseButtonBorderRadius = 6.0;
  static const double notificationCloseButtonSize = 18.0;
  static const double notificationMinHeight = 80.0;
  static const double notificationMaxHeight = 120.0;

  // UI Design tokens
  static const BoxDecoration gradientDecoration = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.primary, // primary color
        AppColors.secondaryYellow, // secondary yellow color
      ],
    ),
  );

  static String searchUserRoute = '/search-user';
}
