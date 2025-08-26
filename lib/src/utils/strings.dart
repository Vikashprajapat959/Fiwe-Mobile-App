class Strings {
  // App info
  static const String appName = 'Fiwe App';
  static const String welcomeMessage = 'Welcome to Fiwe!';
  static const String errorMessage = 'Something went wrong. Please try again.';

  // Login screen
  static const String loginTitle = 'Welcome Back';
  static const String loginSubtitle = 'Million of people\nconnect on fi.we';
  static const String loginWithGoogle = 'Continue with Google';
  static const String loginButton = 'Login';

  // Signup screen
  static const String signUpTitle = 'Sign up';
  static const String signUpSubtitle =
      'Enter your details to create\nyour account';
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

  // Success/Error messages
  static const String signUpSuccess = 'Account created successfully!';
  static const String signUpError =
      'Failed to create account. Please try again.';
  static const String authError = 'Authentication failed. Please try again.';
  static const String networkError =
      'Network error. Please check your connection.';

  // Loading messages
  static const String signingUp = 'Creating your account...';
  static const String signingIn = 'Signing you in...';
  static const String loading = 'Loading...';

  // Helper method to capitalize a string
  static String capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }
}
