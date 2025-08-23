import 'dart:async';

import 'package:google_sign_in/google_sign_in.dart';
import 'shared_pref_service.dart';
import '../utils/constants.dart';

class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  final _userStream = StreamController<GoogleSignInAccount?>.broadcast();
  bool _isDisposed = false;
  
  bool get supportsAuthenticate => _googleSignIn.supportsAuthenticate();

  Stream<GoogleSignInAccount?> get userStream => _userStream.stream;

  /// Save authentication data to SharedPreferences
  Future<void> _saveAuthData(GoogleSignInAccount account) async {
    try {
      await SharedPrefService.setString(Constants.loginEmailKey, account.email);
      await SharedPrefService.setString(Constants.loginUserIdKey, account.id);
      await SharedPrefService.setString(Constants.loginUsernameKey, account.displayName ?? '');
      
      // Get authentication token if available
      final auth = await account.authentication;
      if (auth.idToken != null) {
        await SharedPrefService.setString(Constants.loginTokenKey, auth.idToken!);
      }
    } catch (e) {
      // Error saving authentication data
    }
  }

  /// Clear authentication data from SharedPreferences
  Future<void> _clearAuthData() async {
    try {
      await SharedPrefService.remove(Constants.loginEmailKey);
      await SharedPrefService.remove(Constants.loginUserIdKey);
      await SharedPrefService.remove(Constants.loginUsernameKey);
      await SharedPrefService.remove(Constants.loginTokenKey);
    } catch (e) {
      // Error clearing authentication data
    }
  }

  /// Check if user has stored authentication data
  Future<bool> hasStoredAuthData() async {
    try {
      final email = await SharedPrefService.getString(Constants.loginEmailKey);
      final token = await SharedPrefService.getString(Constants.loginTokenKey);
      return email != null && token != null;
    } catch (e) {
      return false;
    }
  }

  void dispose() {
    if (!_isDisposed) {
      _userStream.close();
      _isDisposed = true;
    }
  }

  Future<GoogleSignInAccount?> initialize() async {
    try {
      // Initialize Google Sign-In
      await _googleSignIn.initialize();
      
      // Set up authentication event listeners
      _googleSignIn.authenticationEvents
          .listen(_handleAuthEvent)
          .onError(_handleAuthError);
      
      // First check if we have stored authentication data
      final hasStoredAuth = await hasStoredAuthData();
      if (hasStoredAuth) {
        // Attempt lightweight authentication (auto sign-in)
        final account = await _googleSignIn.attemptLightweightAuthentication();
        if (account != null) {
          // Refresh stored auth data with current session
          await _saveAuthData(account);
          return account;
        } else {
          await _clearAuthData();
        }
      }
      
      return null;
    } catch (e) {
      // Clear potentially corrupted stored data
      await _clearAuthData();
      return null;
    }
  }

  Future<GoogleSignInAccount?> signIn() async {
    try {
      if (!_googleSignIn.supportsAuthenticate()) {
        throw Exception("Google Sign-In authenticate not supported on this platform.");
      }
      
      // First, try to sign out any existing user to clear state
      await _googleSignIn.signOut();
      
      // Attempt sign-in with proper error handling
      final account = await _googleSignIn.authenticate(
        scopeHint: ['email', 'profile'],
      );
      
      // Save authentication data to SharedPreferences on successful sign-in
      if (account != null) {
        await _saveAuthData(account);
      }
      
      return account;
    } on GoogleSignInException catch (e) {
      // Handle specific error codes
      if (e.code == GoogleSignInExceptionCode.canceled) {
        // User cancelled the sign-in process
      } else {
        // Google Sign-In error
      }
      
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _clearAuthData();
    } catch (e) {
      // Even if Google sign-out fails, clear local data
      await _clearAuthData();
      rethrow;
    }
  }

  void _handleAuthError(dynamic error) {
    if (!_isDisposed) {
      _userStream.add(null);
    }
  }

  void _handleAuthEvent(GoogleSignInAuthenticationEvent event) {
    if (!_isDisposed) {
      if (event is GoogleSignInAuthenticationEventSignIn) {
        _userStream.add(event.user);
      } else if (event is GoogleSignInAuthenticationEventSignOut) {
        _userStream.add(null);
      }
    }
  }
}
