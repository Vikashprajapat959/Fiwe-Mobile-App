import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  final _userStream = StreamController<GoogleSignInAccount?>.broadcast();
  bool get supportsAuthenticate => _googleSignIn.supportsAuthenticate();

  Stream<GoogleSignInAccount?> get userStream => _userStream.stream;

  void dispose() {
    _userStream.close();
  }

  Future<GoogleSignInAccount?> initialize() async {
    unawaited(_googleSignIn.initialize());

    print("Initialize");
    _googleSignIn.authenticationEvents
        .listen(_handleAuthEvent)
        .onError(_handleAuthError);
    return await _googleSignIn.attemptLightweightAuthentication();
  }

  Future<GoogleSignInAccount?> signIn() async {
    try {
      if (_googleSignIn.supportsAuthenticate()) {
        final account = await _googleSignIn.authenticate(
          scopeHint: ['email', 'profile'],
        );
        return account;
      } else {
        throw Exception("Authenticate not supported on this platform.");
      }
    } on GoogleSignInException catch (e) {
      debugPrint('Google SignIn Exception: ${e.code}, ${e.description}');
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
    _userStream.add(null);
  }

  void _handleAuthEvent(GoogleSignInAuthenticationEvent event) {
    if (event is GoogleSignInAuthenticationEventSignIn) {
      _userStream.add(event.user);
    } else if (event is GoogleSignInAuthenticationEventSignOut) {
      _userStream.add(null);
    }
  }
}
