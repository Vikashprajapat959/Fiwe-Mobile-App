class Strings {
  // App info
  static const String appName = 'Fiwe App';
  static const String welcomeMessage = 'Welcome to Fiwe!';
  static const String errorMessage = 'Something went wrong. Please try again.';
  static const String appVersion = 'Version 1.0.0';

  // Login screen
  static const String loginTitle = 'Welcome Back';
  static const String loginSubtitle = 'Million of people\nconnect on fi.we';
  static const String loginWithGoogle = 'Continue with Google';
  static const String loginButton = 'Login';
  static String loginWithApple = "Continue with Apple";

  // Signup screen
  static const String signUpTitle = 'Sign up';
  static const String signUpSubtitle = 'Enter your details to create\nyour account';
  static const String nameHint = 'Your Name';
  static const String emailHint = 'Your Email';
  static const String dateOfBirthHint = 'Date of birth';
  static const String pinCodeHint = 'Pin code';
  static const String signUpButton = 'Sign Up';
  static const String haveAccountText = 'Have an account? ';
  static const String signInLink = 'Sign In';
  static const String privacyPolicyText = 'I agree with ';
  static const String privacyPolicy = 'Privacy Policy';
  static const String andText = ' & ';
  static const String termsConditions = 'Terms & Conditions';

  // Validation messages
  static const String nameRequired = 'Name is required';
  static const String emailRequired = 'Email is required';
  static const String emailInvalid = 'Please enter a valid email';
  static const String dateOfBirthRequired = 'Date of birth is required';
  static const String pinCodeRequired = 'Pin code is required';
  static const String pinCodeInvalid = 'Pin code must be 6 digits';
  static const String termsRequired = 'Please accept terms and conditions';
  static const String profilePictureRequired = 'Please select a profile picture';

  // Success/Error messages
  static const String signUpSuccess = 'Account created successfully!';
  static const String signUpError = 'Failed to create account. Please try again.';
  static const String authError = 'Authentication failed. Please try again.';
  static const String networkError = 'Network error. Please check your connection.';

  // Loading messages
  static const String signingUp = 'Creating your account...';
  static const String signingIn = 'Signing you in...';
  static const String loading = 'Loading...';

  // Auth error messages
  static const String authenticationFailed = 'Authentication Failed';
  static const String unableToSignInWithApple = 'Unable to sign in with Apple. Please try again.';
  static const String unableToSignInWithGoogle = 'Unable to sign in with Google. Please try again.';
  static const String appleSignInFailed = 'Apple Sign-In Failed';
  static const String authenticationFailedError = 'Authentication failed';
  static const String googleSignInError = 'Google Sign-In Error';
  static const String signInCancelled = 'Sign-in Cancelled';
  static const String signInProcessCancelled = 'The sign-in process was cancelled.';
  static const String signInFailed = 'Sign-In Failed';
  static const String unexpectedError = 'Unexpected error';
  static const String apiError = 'API Error';
  static const String failedToSendAuthToken = 'Failed to send authentication token';
  static const String failedToSignOut = 'Failed to sign out';
  static const String authInProgress = 'Authentication already in progress, skipping duplicate call';
  static const String success = 'Success';
  static const String error = 'Error';

  // Signup error messages
  static const String validationError = 'Validation Error';
  static const String pleaseFixFormErrors = 'Please fix the form errors and try again';
  static const String termsRequiredTitle = 'Terms Required';
  static const String profilePictureRequiredTitle = 'Profile Picture Required';
  static const String signupFailed = 'Signup Failed';
  static const String pleaseTryAgain = 'Please try again.';
  static const String unexpectedSignupError = 'An unexpected error occurred during signup.';
  static const String info = 'Info';
  static const String privacyPolicyInfo = 'Privacy Policy will be opened here';
  static const String termsConditionsInfo = 'Terms & Conditions will be opened here';
  static const String fileTooLarge = 'File Too Large';
  static const String selectImageSmallerThan5MB = 'Please select an image smaller than 5MB';
  static const String imageSelected = 'Image Selected';
  static const String profileImageSelectedSuccessfully = 'Profile image selected successfully';
  static const String failedToSelectImage = 'Failed to select image. Please try again.';
  static const String failedToCompleteSignup = 'Failed to complete signup';
  static const String signupSuccessful = 'Signup successful';
  static const String nameMinLength = 'Name must be at least 2 characters';

  // SharedPreferences table view
  static const String sharedPreferencesData = 'SharedPreferences Data';
  static const String keyColumn = 'Key';
  static const String valueColumn = 'Value';
  static const String refreshData = 'Refresh';
  static const String clearAllData = 'Clear All';
  static const String deleteKey = 'Delete';
  static const String noDataFound = 'No data found in SharedPreferences';
  static const String confirmClearAll = 'Clear All Data';
  static const String confirmClearAllMessage =
      'Are you sure you want to clear all SharedPreferences data? This action cannot be undone.';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String nullValue = '(null)';
  static const String errorLoadingSharedPrefs = 'Error loading SharedPreferences data';
  static const String dataRefreshed = 'Data refreshed successfully';
  static const String allDataCleared = 'All data cleared successfully';
  static const String keyDeleted = 'Key deleted';
  static const String errorClearingData = 'Error clearing data';
  static const String errorDeletingKey = 'Error deleting key';

  // Data source categories for SharedPreferences table
  static const String sourceColumn = 'Source';
  static const String typeColumn = 'Type';
  static const String authenticationFlow = 'Authentication Flow';
  static const String userProfileData = 'User Profile Data';
  static const String signupFlow = 'Signup Flow';
  static const String flutterFramework = 'Flutter Framework';
  static const String firebaseSDK = 'Firebase SDK';
  static const String googleServices = 'Google Services';
  static const String appleServices = 'Apple Services';
  static const String thirdPartyPackages = 'Third Party Packages';
  static const String applicationData = 'Application Data';

  // Debug messages
  static const String appleSignInError = 'Apple Sign-In Error';
  static const String errorSendingIdToken = 'Error sending ID token to backend';
  static const String errorHandlingAuthUser = 'Error handling authenticated user';
  static const String googleAuthInitFailed = 'Google auth initialization failed';
  static const String appleAuthCheckFailed = 'Apple auth check failed';
  static const String authInitError = 'Auth initialization error';
  static const String errorCreatingAppleProfile = 'Error creating Apple social profile';
  static const String failedToCreateAppleProfile = 'Failed to create Apple social profile';
  static const String errorCreatingGoogleProfile = 'Error creating Google social profile';
  static const String failedToCreateGoogleProfile = 'Failed to create Google social profile';
  static const String unableToGetIdToken = 'Unable to get ID token from authentication provider';
  static const String tokenSentSuccessfully = 'Token sent successfully';

  // Helper method to capitalize a string
  static String capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  // Helper method to format error message with exception
  static String formatErrorMessage(String baseMessage, dynamic error) {
    return '$baseMessage: $error';
  }
}
