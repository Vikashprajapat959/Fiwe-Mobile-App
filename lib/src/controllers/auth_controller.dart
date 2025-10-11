import 'package:fiwe/src/models/topic.model.dart';
import 'package:fiwe/src/services/crashlytics_service.dart';
import 'package:fiwe/src/services/fcm_notification_service.dart';
import 'package:fiwe/src/utils/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../models/user_model.dart';
import '../services/apple_auth_service.dart';
import '../services/google_auth_service.dart';
import '../services/http_service.dart';
import '../services/shared_pref_service.dart';
import '../utils/constants.dart';
import '../utils/endpoints.dart';
import '../utils/strings.dart';
import '../views/home/home_view.dart';
import '../views/interest/interest_selection_view.dart';
import '../views/login/login_view.dart';
import '../views/login/signup_view.dart';

/// Authentication controller handling user sign-in/sign-out operations
class AuthController extends GetxController {
  // Services
  final _googleAuthService = GoogleAuthService();
  final _httpService = Get.find<HttpService>();

  // Observables
  final Rx<GoogleSignInAccount?> _googleUser = Rx<GoogleSignInAccount?>(null);
  final Rx<AuthorizationCredentialAppleID?> _appleUser = Rx<AuthorizationCredentialAppleID?>(null);
  final Rx<User?> userProfile = Rx<User?>(null);
  final Rx<LoginProvider?> _currentProvider = Rx<LoginProvider?>(null);
  final RxBool _isInitializing = RxBool(true);
  final RxBool _isSigningUp = RxBool(false);
  final RxBool _isSplashComplete = RxBool(false);
  final RxBool _isHandlingAuthentication = RxBool(false);
  // setter for user profile topics
  set userTopics(List<Topic>? topics) {
    if (userProfile.value != null) {
      userProfile(userProfile.value!.copyWith(topics: topics));
    }
  }

  /// Updates the user profile with a new user object
  void updateUserProfile(User newUser) {
    userProfile.value = newUser;
  }

  AuthorizationCredentialAppleID? get appleUser => _appleUser.value;
  LoginProvider? get currentProvider => _currentProvider.value;

  /// Gets current user info based on active provider
  Map<String, String?> get currentUserInfo {
    if (_googleUser.value != null) {
      final user = _googleUser.value!;
      return <String, String?>{
        Constants.userInfoEmailKey: user.email,
        Constants.userInfoDisplayNameKey: user.displayName,
        Constants.userInfoIdKey: user.id,
      };
    }
    if (_appleUser.value != null) {
      final user = _appleUser.value!;
      final fullName = [
        user.givenName,
        user.familyName,
      ].where((String? name) => name?.isNotEmpty == true).join(Constants.nameSeparator);
      return <String, String?>{
        Constants.userInfoEmailKey: user.email,
        Constants.userInfoDisplayNameKey: fullName.isEmpty ? null : fullName,
        Constants.userInfoIdKey: user.userIdentifier,
      };
    }
    return <String, String?>{
      Constants.userInfoEmailKey: null,
      Constants.userInfoDisplayNameKey: null,
      Constants.userInfoIdKey: null,
    };
  }

  GoogleSignInAccount? get googleUser => _googleUser.value;
  // Getters
  bool get isInitializing => _isInitializing.value;
  bool get isLoggedIn => _googleUser.value != null || _appleUser.value != null;
  bool get isSigningUp => _isSigningUp.value;
  bool get isSplashComplete => _isSplashComplete.value;
  bool get supportsAuthenticate => _googleAuthService.supportsAuthenticate;

  // User? get userProfile => _userProfile.value;
  // set userProfile(User? user) => _userProfile(user);

  /// Completes user sign up process
  Future<void> completeSignUp(Map<String, dynamic> data) async {
    try {
      CrashlyticsService.setCustomKey('action', 'complete_sign_up');

      _isSigningUp(true);

      userProfile(User.fromJson(data['user'] as Map<String, dynamic>));
      Logger.info('Completing sign up for user: ${userProfile()?.email}');
      CrashlyticsService.setUserIdentifier('${userProfile()?.email}');

      Get.snackbar(Strings.success, Strings.signUpSuccess);
      _navigateToInterestSelection();
    } catch (e, s) {
      Logger.error('Error completing sign up', error: e, stackTrace: s);
      CrashlyticsService.recordError(e, s, reason: 'Sign up completion failed');
      Get.snackbar(Strings.error, Strings.formatErrorMessage(Strings.signUpError, e));
    } finally {
      _isSigningUp(false);
    }
  }

  Future<String?> getStoredUserEmail() => SharedPrefService.getString(Constants.storageLoginEmailKey);

  /// Checks if stored authentication data exists
  Future<bool> hasStoredAuthData() async => (await Future.wait([
    _googleAuthService.hasStoredAuthData(),
    AppleAuthService.hasStoredAuthData(),
  ])).any((bool hasData) => hasData);

  @override
  void onClose() {
    _googleAuthService.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    _initAuth();
    _startSplashTimer();
  }

  /// Sends ID token to backend for authentication
  Future<Map<String, dynamic>?> sendIdTokenToBackend() async {
    try {
      final google = _googleUser.value;
      final apple = _appleUser.value;

      final idToken = google != null ? (google.authentication).idToken : apple?.identityToken;
      final provider = google != null ? Constants.googleProvider : Constants.appleProvider;

      if (idToken == null) {
        throw Exception(Strings.unableToGetIdToken);
      }

      final response = await _httpService
          .post(
            Endpoints.idToken,
            body: <String, dynamic>{
              Constants.requestIdTokenKey: idToken,
              Constants.requestProviderKey: provider,
              'device_id': await _getDeviceId(),
            },
            log: true,
          )
          .timeout(const Duration(seconds: Constants.apiTimeoutSeconds));

      if (response.data != null && response.data!.isNotEmpty) {
        final data = response.data!;
        if (data[Constants.responseAccessKey] != null) {
          await SharedPrefService.setString(
            Constants.storageBearerTokenKey,
            data[Constants.responseAccessKey] as String,
          );
        }
        if (data[Constants.responseRefreshKey] != null) {
          await SharedPrefService.setString(
            Constants.storageBearerTokenRefreshKey,
            data[Constants.responseRefreshKey] as String,
          );
        }
        if (response.data!.containsKey('user')) {
          userProfile(User.fromJson(response.data?['user'] as Map<String, dynamic>));
        }

        return data;
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print(Strings.formatErrorMessage(Strings.errorSendingIdToken, e));
      }
      Get.snackbar(Strings.apiError, Strings.formatErrorMessage(Strings.failedToSendAuthToken, e));
      return null;
    }
  }

  /// Signs in with Apple
  Future<void> signInWithApple() async {
    try {
      Logger.info('Attempting Apple sign in');
      CrashlyticsService.setCustomKey('action', 'apple_sign_in');

      final credential = await AppleAuthService.signIn();
      if (credential == null) {
        Logger.warning('Apple sign in returned null credential');
        Get.snackbar(
          Strings.authenticationFailed,
          Strings.unableToSignInWithApple,
          duration: const Duration(seconds: Constants.snackbarDurationSeconds),
        );
        return;
      }

      _appleUser(credential);
      _googleUser(null);
      _currentProvider(LoginProvider.apple);
      await _handleAuthenticatedUser();
    } catch (e, s) {
      Logger.error('Error during Apple sign in', error: e, stackTrace: s);
      CrashlyticsService.recordError(e, s, reason: 'Apple sign in failed');
      if (kDebugMode) {
        print(Strings.formatErrorMessage(Strings.appleSignInError, e));
      }
      Get.snackbar(
        Strings.appleSignInFailed,
        Strings.formatErrorMessage(Strings.authenticationFailedError, e),
        duration: const Duration(seconds: Constants.snackbarDurationSeconds),
      );
    }
  }

  /// Signs in with Google
  Future<void> signInWithGoogle() async {
    try {
      Logger.info('Attempting Google sign in');
      CrashlyticsService.setCustomKey('action', 'google_sign_in');

      final account = await _googleAuthService.signIn();
      if (account == null) {
        Logger.warning('Google sign in returned null account');
        Get.snackbar(
          Strings.authenticationFailed,
          Strings.unableToSignInWithGoogle,
          duration: const Duration(seconds: Constants.snackbarDurationSeconds),
        );
        return;
      }

      _googleUser(account);
      _appleUser(null);
      _currentProvider(LoginProvider.google);
      await _handleAuthenticatedUser();
    } on GoogleSignInException catch (e) {
      final message = e.code == GoogleSignInExceptionCode.canceled
          ? Strings.signInProcessCancelled
          : Strings.formatErrorMessage(Strings.authenticationFailedError, e.description ?? e.code);
      Logger.error('Google sign in exception: ${e.code}', error: e, stackTrace: e.details as StackTrace?);
      Get.snackbar(
        e.code == GoogleSignInExceptionCode.canceled ? Strings.signInCancelled : Strings.googleSignInError,
        message,
        duration: const Duration(seconds: Constants.snackbarDurationSeconds),
      );
    } catch (e, s) {
      Logger.error('Unexpected error during Google sign in', error: e, stackTrace: s);
      CrashlyticsService.recordError(e, s, reason: 'Google sign in failed');
      Get.snackbar(Strings.signInFailed, Strings.formatErrorMessage(Strings.unexpectedError, e));
    }
  }

  /// Signs out the current user
  Future<void> signOut() async {
    try {
      _isHandlingAuthentication(false);

      if (_currentProvider.value == LoginProvider.google) {
        await _googleAuthService.signOut();
      } else if (_currentProvider.value == LoginProvider.apple) {
        await AppleAuthService.signOut();
      }

      await SharedPrefService.clearAuthData();
      _googleUser(null);
      _appleUser(null);
      _currentProvider(null);
      _navigateToLogin();
    } catch (e) {
      Get.snackbar(Strings.error, Strings.formatErrorMessage(Strings.failedToSignOut, e));
    }
  }

  /// Checks if navigation is ready and performs navigation
  void _checkNavigationReady() {
    if (!_isInitializing.value && _isSplashComplete.value) {
      _performNavigation();
    }
  }

  // Future<void> _createSocialProfileFromApple(AuthorizationCredentialAppleID credential) async {
  //   try {
  //     final fullName = credential.givenName != null && credential.familyName != null
  //         ? '${credential.givenName}${Constants.nameSeparator}${credential.familyName}'
  //         : credential.givenName ?? credential.familyName ?? Constants.emptyString;

  //     // _userProfile(
  //     //   SocialProfile(
  //     //     email: credential.email,
  //     //     displayName: fullName.isEmpty ? null : fullName,
  //     //     idToken: credential.identityToken,
  //     //     isRegistered: false,
  //     //   ),
  //     // );
  //   } catch (e) {
  //     if (kDebugMode) print(Strings.formatErrorMessage(Strings.errorCreatingAppleProfile, e));
  //     throw Exception(Strings.failedToCreateAppleProfile);
  //   }
  // }

  // Future<void> _createSocialProfileFromGoogle(GoogleSignInAccount account) async {
  //   try {
  //     _userProfile(
  //       SocialProfile(
  //         email: account.email,
  //         displayName: account.displayName,
  //         idToken: account.authentication.idToken,
  //         isRegistered: false,
  //       ),
  //     );
  //   } catch (e) {
  //     if (kDebugMode) print(Strings.formatErrorMessage(Strings.errorCreatingGoogleProfile, e));
  //     throw Exception(Strings.failedToCreateGoogleProfile);
  //   }
  // }

  /// Handles authenticated user workflow
  Future<void> _handleAuthenticatedUser() async {
    if (_isHandlingAuthentication.value) {
      if (kDebugMode) print(Strings.authInProgress);
      return;
    }

    try {
      _isHandlingAuthentication(true);
      final backendResponse = await sendIdTokenToBackend();

      if (backendResponse != null) {
        if (backendResponse[Constants.responseIsNewKey] as bool? ?? false) {
          _navigateToSignUp();
        } else if (backendResponse['is_interests_pending'] as bool? ?? false) {
          _navigateToInterestSelection();
        } else {
          navigateToHome();
        }
      } else {
        Get.snackbar(Strings.error, Strings.unableToAuthenticateUser);
        _navigateToLogin();
      }
    } catch (e) {
      if (kDebugMode) {
        print(Strings.formatErrorMessage(Strings.errorHandlingAuthUser, e));
      }
      _navigateToLogin();
    } finally {
      _isHandlingAuthentication(false);
    }
  }

  Future<void> _initAuth() async {
    try {
      _isInitializing(true);
      bool hasAuthentication = false;

      // Check Google authentication
      try {
        final googleAccount = await _googleAuthService.initialize();
        if (googleAccount != null) {
          _googleUser(googleAccount);
          _currentProvider(LoginProvider.google);
          // await _createSocialProfileFromGoogle(googleAccount);
          hasAuthentication = true;
        }
      } catch (e) {
        if (kDebugMode) print(Strings.formatErrorMessage(Strings.googleAuthInitFailed, e));
      }

      // Check Apple authentication if no Google auth
      if (!hasAuthentication && await AppleAuthService.isAvailable) {
        try {
          if (await AppleAuthService.hasStoredAuthData()) {
            _currentProvider(LoginProvider.apple);
          }
        } catch (e) {
          if (kDebugMode) print(Strings.formatErrorMessage(Strings.appleAuthCheckFailed, e));
        }
      }

      // Set up Google stream listener
      _googleAuthService.userStream.listen((newAccount) {
        if (_googleUser.value != newAccount) {
          _googleUser(newAccount);
          _currentProvider(newAccount != null ? LoginProvider.google : null);

          if (newAccount != null) {
            _handleAuthenticatedUser();
            // _createSocialProfileFromGoogle(newAccount).then((_) {
            //   if (!_isHandlingAuthentication.value && _isSplashComplete.value) {
            //     _handleAuthenticatedUser();
            //   }
            // });
          } else if (_appleUser.value == null && !_isHandlingAuthentication.value) {
            _navigateToLogin();
          }
        }
      });
    } catch (e) {
      if (kDebugMode) print(Strings.formatErrorMessage(Strings.authInitError, e));
    } finally {
      _isInitializing(false);
      _checkNavigationReady();
    }
  }

  void navigateToHome() {
    if (Get.currentRoute != Constants.homeViewRoute) {
      Future.delayed(const Duration(milliseconds: Constants.navigationDelayMilliseconds), () {
        if (!Get.isDialogOpen! && !Get.isBottomSheetOpen!) Get.offAll(() => const HomeView());
      });
    }
  }

  void _navigateToInterestSelection() {
    if (Get.currentRoute != Constants.interestSelectionViewRoute) {
      Future.delayed(const Duration(milliseconds: Constants.navigationDelayMilliseconds), () {
        if (!Get.isDialogOpen! && !Get.isBottomSheetOpen!) {
          Get.offAll(() => const InterestSelectionView());
        }
      });
    }
  }

  void _navigateToLogin() {
    if (Get.currentRoute != Constants.loginViewRoute) {
      Future.delayed(const Duration(milliseconds: Constants.navigationDelayMilliseconds), () {
        if (!Get.isDialogOpen! && !Get.isBottomSheetOpen!) Get.offAll(() => const LoginView());
      });
    }
  }

  void _navigateToSignUp() {
    if (Get.currentRoute != Constants.signUpViewRoute) {
      Future.delayed(const Duration(milliseconds: Constants.navigationDelayMilliseconds), () {
        if (!Get.isDialogOpen! && !Get.isBottomSheetOpen!) Get.offAll(() => const SignUpView());
      });
    }
  }

  void _performNavigation() {
    isLoggedIn ? _handleAuthenticatedUser() : _navigateToLogin();
  }

  void _startSplashTimer() {
    Future.delayed(const Duration(seconds: Constants.splashDelaySeconds), () {
      _isSplashComplete(true);
      _checkNavigationReady();
    });
  }

  /// Gets device ID for authentication
  Future<String> _getDeviceId() async {
    try {
      return FCMNotificationService.instance.deviceToken ?? Constants.unknownDevice;
    } catch (e) {
      return Constants.unknownDevice;
    }
  }
}

enum LoginProvider { google, apple }
