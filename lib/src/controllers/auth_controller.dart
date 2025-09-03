import 'dart:convert' show json;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../models/social_profile.dart';
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

class AuthController extends GetxController {
  // Services
  final _googleAuthService = GoogleAuthService();
  final _httpService = HttpService();

  // Observables
  final _googleUser = Rx<GoogleSignInAccount?>(null);
  final _appleUser = Rx<AuthorizationCredentialAppleID?>(null);
  final _userProfile = Rx<SocialProfile?>(null);
  final _currentProvider = Rx<LoginProvider?>(null);
  final _isInitializing = RxBool(true);
  final _isSigningUp = RxBool(false);
  final _isSplashComplete = RxBool(false);
  final _isHandlingAuthentication = RxBool(false);

  AuthorizationCredentialAppleID? get appleUser => _appleUser.value;
  LoginProvider? get currentProvider => _currentProvider.value;
  Map<String, String?> get currentUserInfo {
    if (_googleUser.value != null) {
      final user = _googleUser.value!;
      return {
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
      ].where((name) => name?.isNotEmpty == true).join(Constants.nameSeparator);
      return {
        Constants.userInfoEmailKey: user.email,
        Constants.userInfoDisplayNameKey: fullName.isEmpty ? null : fullName,
        Constants.userInfoIdKey: user.userIdentifier,
      };
    }
    return {Constants.userInfoEmailKey: null, Constants.userInfoDisplayNameKey: null, Constants.userInfoIdKey: null};
  }

  GoogleSignInAccount? get googleUser => _googleUser.value;
  // Getters
  bool get isInitializing => _isInitializing.value;
  bool get isLoggedIn => _googleUser.value != null || _appleUser.value != null;
  bool get isSigningUp => _isSigningUp.value;
  bool get isSplashComplete => _isSplashComplete.value;
  bool get supportsAuthenticate => _googleAuthService.supportsAuthenticate;

  SocialProfile? get userProfile => _userProfile.value;

  Future<void> completeSignUp({
    required String name,
    required String email,
    required String dateOfBirth,
    required String pinCode,
    File? profileImage,
  }) async {
    try {
      _isSigningUp(true);
      final idToken = _googleUser.value != null
          ? (_googleUser.value!.authentication).idToken
          : _appleUser.value?.identityToken;

      _userProfile(
        SocialProfile(
          name: name,
          email: email,
          dateOfBirth: dateOfBirth,
          pinCode: pinCode,
          profileImagePath: profileImage?.path,
          displayName: currentUserInfo[Constants.userInfoDisplayNameKey],
          idToken: idToken,
          isRegistered: true,
        ),
      );

      Get.snackbar(Strings.success, Strings.signUpSuccess);
      _navigateToInterestSelection();
    } catch (e) {
      Get.snackbar(Strings.error, Strings.formatErrorMessage(Strings.signUpError, e));
    } finally {
      _isSigningUp(false);
    }
  }

  Future<String?> getStoredUserEmail() => SharedPrefService.getString(Constants.storageLoginEmailKey);

  Future<bool> hasStoredAuthData() async => (await Future.wait([
    _googleAuthService.hasStoredAuthData(),
    AppleAuthService.hasStoredAuthData(),
  ])).any((hasData) => hasData);

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

  Future<Map<String, dynamic>?> sendIdTokenToBackend() async {
    try {
      final google = _googleUser.value;
      final apple = _appleUser.value;

      final idToken = google != null ? (google.authentication).idToken : apple?.identityToken;
      final provider = google != null ? Constants.googleProvider : Constants.appleProvider;

      if (idToken == null) throw Exception(Strings.unableToGetIdToken);

      final response = await _httpService
          .post(Endpoints.idToken, body: {Constants.requestIdTokenKey: idToken, Constants.requestProviderKey: provider})
          .timeout(Duration(seconds: Constants.apiTimeoutSeconds));

      if (response.body.isNotEmpty) {
        final data = Map<String, dynamic>.from(json.decode(response.body));
        if (data[Constants.responseAccessKey] != null)
          await SharedPrefService.setString(Constants.storageBearerTokenKey, data[Constants.responseAccessKey]);
        if (data[Constants.responseRefreshKey] != null)
          await SharedPrefService.setString(Constants.storageBearerTokenRefreshKey, data[Constants.responseRefreshKey]);
        return data;
      }
      return {Constants.responseSuccessKey: true, Constants.responseMessageKey: Strings.tokenSentSuccessfully};
    } catch (e) {
      if (kDebugMode) print(Strings.formatErrorMessage(Strings.errorSendingIdToken, e));
      Get.snackbar(Strings.apiError, Strings.formatErrorMessage(Strings.failedToSendAuthToken, e));
      return null;
    }
  }

  Future<void> signInWithApple() async {
    try {
      final credential = await AppleAuthService.signIn();
      if (credential == null) {
        Get.snackbar(
          Strings.authenticationFailed,
          Strings.unableToSignInWithApple,
          duration: Duration(seconds: Constants.snackbarDurationSeconds),
        );
        return;
      }

      _appleUser(credential);
      _googleUser(null);
      _currentProvider(LoginProvider.apple);
      await _createSocialProfileFromApple(credential);
      await _handleAuthenticatedUser();
    } catch (e) {
      if (kDebugMode) print(Strings.formatErrorMessage(Strings.appleSignInError, e));
      Get.snackbar(
        Strings.appleSignInFailed,
        Strings.formatErrorMessage(Strings.authenticationFailedError, e),
        duration: Duration(seconds: Constants.snackbarDurationSeconds),
      );
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final account = await _googleAuthService.signIn();
      if (account == null) {
        Get.snackbar(
          Strings.authenticationFailed,
          Strings.unableToSignInWithGoogle,
          duration: Duration(seconds: Constants.snackbarDurationSeconds),
        );
        return;
      }

      _googleUser(account);
      _appleUser(null);
      _currentProvider(LoginProvider.google);
      await _createSocialProfileFromGoogle(account);
      await _handleAuthenticatedUser();
    } on GoogleSignInException catch (e) {
      final message = e.code == GoogleSignInExceptionCode.canceled
          ? Strings.signInProcessCancelled
          : Strings.formatErrorMessage(Strings.authenticationFailedError, e.description ?? e.code);
      Get.snackbar(
        e.code == GoogleSignInExceptionCode.canceled ? Strings.signInCancelled : Strings.googleSignInError,
        message,
        duration: Duration(seconds: Constants.snackbarDurationSeconds),
      );
    } catch (e) {
      Get.snackbar(Strings.signInFailed, Strings.formatErrorMessage(Strings.unexpectedError, e));
    }
  }

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
      _userProfile(null);
      _currentProvider(null);
      _navigateToLogin();
    } catch (e) {
      Get.snackbar(Strings.error, Strings.formatErrorMessage(Strings.failedToSignOut, e));
    }
  }

  void _checkNavigationReady() {
    if (!_isInitializing.value && _isSplashComplete.value) _performNavigation();
  }

  Future<void> _createSocialProfileFromApple(AuthorizationCredentialAppleID credential) async {
    try {
      final fullName = credential.givenName != null && credential.familyName != null
          ? '${credential.givenName}${Constants.nameSeparator}${credential.familyName}'
          : credential.givenName ?? credential.familyName ?? Constants.emptyString;

      _userProfile(
        SocialProfile(
          email: credential.email,
          displayName: fullName.isEmpty ? null : fullName,
          idToken: credential.identityToken,
          isRegistered: false,
        ),
      );
    } catch (e) {
      if (kDebugMode) print(Strings.formatErrorMessage(Strings.errorCreatingAppleProfile, e));
      throw Exception(Strings.failedToCreateAppleProfile);
    }
  }

  Future<void> _createSocialProfileFromGoogle(GoogleSignInAccount account) async {
    try {
      _userProfile(
        SocialProfile(
          email: account.email,
          displayName: account.displayName,
          idToken: account.authentication.idToken,
          isRegistered: false,
        ),
      );
    } catch (e) {
      if (kDebugMode) print(Strings.formatErrorMessage(Strings.errorCreatingGoogleProfile, e));
      throw Exception(Strings.failedToCreateGoogleProfile);
    }
  }

  Future<void> _handleAuthenticatedUser() async {
    if (_isHandlingAuthentication.value) {
      if (kDebugMode) print(Strings.authInProgress);
      return;
    }

    try {
      _isHandlingAuthentication(true);
      final backendResponse = await sendIdTokenToBackend();

      if (backendResponse != null) {
        (backendResponse[Constants.responseIsNewKey] ?? false) ? _navigateToSignUp() : _navigateToHome();
      } else {
        _navigateToLogin();
      }
    } catch (e) {
      if (kDebugMode) print(Strings.formatErrorMessage(Strings.errorHandlingAuthUser, e));
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
          await _createSocialProfileFromGoogle(googleAccount);
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
            _createSocialProfileFromGoogle(newAccount).then((_) {
              if (!_isHandlingAuthentication.value && _isSplashComplete.value) {
                _handleAuthenticatedUser();
              }
            });
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

  void _navigateToHome() {
    if (Get.currentRoute != Constants.homeViewRoute) {
      Future.delayed(Duration(milliseconds: Constants.navigationDelayMilliseconds), () {
        if (!Get.isDialogOpen! && !Get.isBottomSheetOpen!) Get.offAll(() => const HomeView());
      });
    }
  }

  void _navigateToInterestSelection() {
    if (Get.currentRoute != Constants.interestSelectionViewRoute) {
      Future.delayed(Duration(milliseconds: Constants.navigationDelayMilliseconds), () {
        if (!Get.isDialogOpen! && !Get.isBottomSheetOpen!) {
          Get.offAll(() => const InterestSelectionView());
        }
      });
    }
  }

  void _navigateToLogin() {
    if (Get.currentRoute != Constants.loginViewRoute) {
      Future.delayed(Duration(milliseconds: Constants.navigationDelayMilliseconds), () {
        if (!Get.isDialogOpen! && !Get.isBottomSheetOpen!) Get.offAll(() => const LoginView());
      });
    }
  }

  void _navigateToSignUp() {
    if (Get.currentRoute != Constants.signUpViewRoute) {
      Future.delayed(Duration(milliseconds: Constants.navigationDelayMilliseconds), () {
        if (!Get.isDialogOpen! && !Get.isBottomSheetOpen!) Get.offAll(() => const SignUpView());
      });
    }
  }

  void _performNavigation() {
    isLoggedIn ? _handleAuthenticatedUser() : _navigateToLogin();
  }

  void _startSplashTimer() {
    Future.delayed(Duration(seconds: Constants.splashDelaySeconds), () {
      _isSplashComplete(true);
      _checkNavigationReady();
    });
  }
}

enum LoginProvider { google, apple }
