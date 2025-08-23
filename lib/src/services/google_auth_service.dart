import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  final _userStream = StreamController<GoogleSignInAccount?>.broadcast();
  bool _isDisposed = false;
  
  bool get supportsAuthenticate => _googleSignIn.supportsAuthenticate();

  Stream<GoogleSignInAccount?> get userStream => _userStream.stream;

  void dispose() {
    if (!_isDisposed) {
      _userStream.close();
      _isDisposed = true;
    }
  }

  Future<GoogleSignInAccount?> initialize() async {
    try {
      // Clear any previous sign-in state first
      await _googleSignIn.signOut();
      
      // Initialize Google Sign-In
      await _googleSignIn.initialize();
      
      debugPrint("Google Sign-In initialized successfully");
      
      // Set up authentication event listeners
      _googleSignIn.authenticationEvents
          .listen(_handleAuthEvent)
          .onError(_handleAuthError);
          
      // Attempt lightweight authentication (auto sign-in)
      final account = await _googleSignIn.attemptLightweightAuthentication();
      if (account != null) {
        debugPrint("Auto sign-in successful for: ${account.email}");
      } else {
        debugPrint("No existing authentication found");
      }
      
      return account;
    } catch (e) {
      debugPrint('Google Sign-In initialization error: $e');
      return null;
    }
  }

  Future<GoogleSignInAccount?> signIn() async {
    try {
      debugPrint('Starting Google Sign-In process...');
      
      if (!_googleSignIn.supportsAuthenticate()) {
        debugPrint('Google Sign-In authenticate not supported on this platform');
        throw Exception("Google Sign-In authenticate not supported on this platform.");
      }
      
      // First, try to sign out any existing user to clear state
      await _googleSignIn.signOut();
      
      // Attempt sign-in with proper error handling
      final account = await _googleSignIn.authenticate(
        scopeHint: ['email', 'profile'],
      );
      
      if (account != null) {
        debugPrint('Sign-in successful for: ${account.email}');
      } else {
        debugPrint('Sign-in returned null account');
      }
      
      return account;
    } on GoogleSignInException catch (e) {
      debugPrint('Google SignIn Exception: ${e.code}, ${e.description}');
      
      // Handle specific error codes
      if (e.code == GoogleSignInExceptionCode.canceled) {
        debugPrint('User cancelled the sign-in process');
      } else {
        debugPrint('Google Sign-In error: ${e.code} - ${e.description}');
      }
      
      rethrow;
    } catch (e) {
      debugPrint('Generic SignIn error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  void _handleAuthError(dynamic error) {
    debugPrint('Google Auth Error: $error');
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
