import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  final GoogleSignIn _signIn = GoogleSignIn.instance;

  void init() {
    // Initialize Google Sign-In if needed
    //_signIn.attemptLightweightAuthentication();
    _signIn.initialize();
    _signIn.authenticationEvents.listen((
      GoogleSignInAuthenticationEvent? event,
    ) {
      if (kDebugMode) {
        print('Current user changed: $event');
      }
    });
  }

  Future<GoogleSignInAccount?> signInWithGoogle() async {
    if (_signIn.supportsAuthenticate()) {
      try {
        final GoogleSignInAccount account = await _signIn.authenticate();
        print(account.authentication.idToken);
        return account;
      } catch (error) {
        if (kDebugMode) {
          print('Error during Google Sign-In: $error');
        }
        return null;
      }
    } else {
      if (kDebugMode) {
        print('Google Sign-In is not supported on this platform.');
      }
      return null;
    }
  }
}
