class Constants {
  // API Response Keys (from backend responses)
  static const String responseAccessKey = 'access';
  static const String responseRefreshKey = 'refresh';
  static const String responseAccessTokenKey = 'access_token';
  static const String responseRefreshTokenKey = 'refresh_token';
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

  // Provider constants
  static const String googleProvider = 'google';
  static const String appleProvider = 'apple';

  // Route names
  static const String homeViewRoute = '/HomeView';
  static const String loginViewRoute = '/LoginView';
  static const String signUpViewRoute = '/SignUpView';

  // Timeout durations
  static const int apiTimeoutSeconds = 30;
  static const int snackbarDurationSeconds = 3;
  static const int splashDelaySeconds = 2;
  static const int navigationDelayMilliseconds = 100;
  static const int appInfoDurationSeconds = 2;

  // Legacy User Profile Keys (for SharedPreferences - consider deprecating)
  static const String userNameKey = 'user_name';
  static const String userEmailKey = 'user_email';
  static const String userDateOfBirthKey = 'user_date_of_birth';
  static const String userPinCodeKey = 'user_pin_code';
  static const String userProfileImageKey = 'user_profile_image';
  static const String userDisplayNameKey = 'user_display_name';
  static const String userIdTokenKey = 'user_id_token';
  static const String isUserRegisteredKey = 'is_user_registered';
  static const double defaultBorderRadius = 16.0;
  static const double profileImageSize = 120.0;
  static const double textFieldHeight = 44.0;
  static const double textFieldRadius = 8.0;
  static const double buttonHeight = 44.0;
  static const double buttonRadius = 12.0;

  // Name separator
  static const String nameSeparator = ' ';
  static const String emptyString = '';

  // File handling
  static const int maxFileSizeBytes = 5 * 1024 * 1024; // 5MB
  static const double imageMaxWidth = 512.0;
  static const double imageMaxHeight = 512.0;
  static const int imageQuality = 80;
  static const int minNameLength = 2;
  static const int pinCodeLength = 6;
  static const int minAgeYears = 18;
  static const int minYear = 1920;
  static const int maxDisplayStringLength = 50; // For SharedPreferences table display

  // Device info
  static const String unknownDevice = 'unknown';

  // API response keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';

  // UI Design tokens

  // Colors
  // static const int primaryColor = 0xFF0891B2;
  // static const int backgroundColor = 0xFFF9FAFB;
  // static const int textFieldBackgroundColor = 0xFFF5F5F5;
  // static const int textColor = 0xFF111827;
  // static const int textColorLight = 0xFF9CA3AF;
  // static const int hintTextColor = 0xFF9CA3AF;
  // static const int borderColor = 0xFFE5E7EB;
  // static const int iconColor = 0xFF6B7280;
}
