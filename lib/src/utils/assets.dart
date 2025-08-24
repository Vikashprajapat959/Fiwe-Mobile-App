/// Asset management utility class for the fiwe application.
/// 
/// This class provides centralized access to all application assets including
/// images, icons, and SVGs. It follows the project's modular architecture
/// and provides type-safe access to asset paths.
/// 
/// Usage:
/// ```dart
/// Image.asset(Assets.images.logo)
/// SvgPicture.asset(Assets.svgs.welcomeIcon)
/// ```
class Assets {
  // Private constructor to prevent instantiation
  Assets._();

  /// Base paths for different asset types
  static const String _basePath = 'assets';
  static const String _imagesPath = '$_basePath/images';
  static const String _iconsPath = '$_basePath/icons';
  static const String _svgsPath = '$_basePath/svgs';

  /// Images assets
  static AppImages get images => AppImages._();

  /// Icons assets  
  static AppIcons get icons => AppIcons._();

  /// SVG assets
  static AppSvgs get svgs => AppSvgs._();
}

/// Image assets class
class AppImages {
  const AppImages._();

  // App branding
  String get logo => '${Assets._imagesPath}/logo.png';
  String get logoWhite => '${Assets._imagesPath}/logo_white.png';
  String get splashBackground => '${Assets._imagesPath}/splash_background.png';
  
  // Authentication related images
  String get loginBackground => '${Assets._imagesPath}/login_background.png';
  String get signupBackground => '${Assets._imagesPath}/signup_background.png';
  String get authIllustration => '${Assets._imagesPath}/auth_illustration.png';
  
  // Profile and user related
  String get defaultAvatar => '${Assets._imagesPath}/default_avatar.png';
  String get profilePlaceholder => '${Assets._imagesPath}/profile_placeholder.png';
  
  // Onboarding and welcome
  String get onboarding1 => '${Assets._imagesPath}/onboarding_1.png';
  String get onboarding2 => '${Assets._imagesPath}/onboarding_2.png';
  String get onboarding3 => '${Assets._imagesPath}/onboarding_3.png';
  String get welcomeImage => '${Assets._imagesPath}/welcome_image.png';
  
  // Empty states and illustrations
  String get emptyState => '${Assets._imagesPath}/empty_state.png';
  String get noConnection => '${Assets._imagesPath}/no_connection.png';
  String get errorIllustration => '${Assets._imagesPath}/error_illustration.png';
  
  // App specific images (customize based on your app needs)
  String get heroImage => '${Assets._imagesPath}/hero_image.png';
  String get featureImage1 => '${Assets._imagesPath}/feature_1.png';
  String get featureImage2 => '${Assets._imagesPath}/feature_2.png';
  String get featureImage3 => '${Assets._imagesPath}/feature_3.png';
}

/// Icon assets class
class AppIcons {
  const AppIcons._();

  // Navigation icons
  String get home => '${Assets._iconsPath}/home.png';
  String get homeSelected => '${Assets._iconsPath}/home_selected.png';
  String get profile => '${Assets._iconsPath}/profile.png';
  String get profileSelected => '${Assets._iconsPath}/profile_selected.png';
  String get settings => '${Assets._iconsPath}/settings.png';
  String get settingsSelected => '${Assets._iconsPath}/settings_selected.png';
  
  // Action icons
  String get add => '${Assets._iconsPath}/add.png';
  String get edit => '${Assets._iconsPath}/edit.png';
  String get delete => '${Assets._iconsPath}/delete.png';
  String get search => '${Assets._iconsPath}/search.png';
  String get filter => '${Assets._iconsPath}/filter.png';
  String get sort => '${Assets._iconsPath}/sort.png';
  
  // Authentication icons
  String get google => '${Assets._iconsPath}/google.png';
  String get facebook => '${Assets._iconsPath}/facebook.png';
  String get apple => '${Assets._iconsPath}/apple.png';
  String get email => '${Assets._iconsPath}/email.png';
  String get lock => '${Assets._iconsPath}/lock.png';
  String get visibility => '${Assets._iconsPath}/visibility.png';
  String get visibilityOff => '${Assets._iconsPath}/visibility_off.png';
  
  // Status and notification icons
  String get success => '${Assets._iconsPath}/success.png';
  String get error => '${Assets._iconsPath}/error.png';
  String get warning => '${Assets._iconsPath}/warning.png';
  String get info => '${Assets._iconsPath}/info.png';
  String get notification => '${Assets._iconsPath}/notification.png';
  
  // Camera and media icons
  String get camera => '${Assets._iconsPath}/camera.png';
  String get gallery => '${Assets._iconsPath}/gallery.png';
  String get video => '${Assets._iconsPath}/video.png';
  String get play => '${Assets._iconsPath}/play.png';
  String get pause => '${Assets._iconsPath}/pause.png';
  
  // Common utility icons
  String get back => '${Assets._iconsPath}/back.png';
  String get forward => '${Assets._iconsPath}/forward.png';
  String get close => '${Assets._iconsPath}/close.png';
  String get menu => '${Assets._iconsPath}/menu.png';
  String get more => '${Assets._iconsPath}/more.png';
  String get share => '${Assets._iconsPath}/share.png';
  String get download => '${Assets._iconsPath}/download.png';
  String get upload => '${Assets._iconsPath}/upload.png';
}

/// SVG assets class
class AppSvgs {
  const AppSvgs._();

  // App branding SVGs
  String get logoSvg => '${Assets._svgsPath}/app_logo.svg';
  String get brandIcon => '${Assets._svgsPath}/brand_icon.svg';
  String get appSymbol => '${Assets._svgsPath}/app_symbol.svg';
  
  // Authentication illustrations
  String get loginIllustration => '${Assets._svgsPath}/login_illustration.svg';
  String get signupIllustration => '${Assets._svgsPath}/signup_illustration.svg';
  String get forgotPasswordIllustration => '${Assets._svgsPath}/forgot_password_illustration.svg';
  String get emailVerificationIllustration => '${Assets._svgsPath}/email_verification_illustration.svg';
  
  // Onboarding illustrations
  String get onboardingWelcome => '${Assets._svgsPath}/onboarding_welcome.svg';
  String get onboardingFeature1 => '${Assets._svgsPath}/onboarding_feature_1.svg';
  String get onboardingFeature2 => '${Assets._svgsPath}/onboarding_feature_2.svg';
  String get onboardingFeature3 => '${Assets._svgsPath}/onboarding_feature_3.svg';
  
  // Empty states and error illustrations
  String get emptyStateIllustration => '${Assets._svgsPath}/empty_state_illustration.svg';
  String get noDataIllustration => '${Assets._svgsPath}/no_data_illustration.svg';
  String get networkErrorIllustration => '${Assets._svgsPath}/network_error_illustration.svg';
  String get serverErrorIllustration => '${Assets._svgsPath}/server_error_illustration.svg';
  String get notFoundIllustration => '${Assets._svgsPath}/not_found_illustration.svg';
  
  // Success and completion illustrations
  String get successIllustration => '${Assets._svgsPath}/success_illustration.svg';
  String get completedIllustration => '${Assets._svgsPath}/completed_illustration.svg';
  String get achievementIllustration => '${Assets._svgsPath}/achievement_illustration.svg';
  
  // Social media and external service icons
  String get googleIcon => '${Assets._svgsPath}/google_icon.svg';
  String get facebookIcon => '${Assets._svgsPath}/facebook_icon.svg';
  String get twitterIcon => '${Assets._svgsPath}/twitter_icon.svg';
  String get linkedinIcon => '${Assets._svgsPath}/linkedin_icon.svg';
  String get instagramIcon => '${Assets._svgsPath}/instagram_icon.svg';
  
  // Feature and category illustrations
  String get securityIllustration => '${Assets._svgsPath}/security_illustration.svg';
  String get performanceIllustration => '${Assets._svgsPath}/performance_illustration.svg';
  String get analyticsIllustration => '${Assets._svgsPath}/analytics_illustration.svg';
  String get teamworkIllustration => '${Assets._svgsPath}/teamwork_illustration.svg';
  String get innovationIllustration => '${Assets._svgsPath}/innovation_illustration.svg';
}