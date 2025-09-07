import 'dart:async';
import 'dart:convert';
import 'dart:io';

// FIREBASE_IMPLEMENTATION: Commented out Firebase imports
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../utils/constants.dart';
import '../utils/endpoints.dart';
import '../utils/strings.dart';
import 'http_service.dart';

/// Service class for handling phone authentication
/// Migrated from Firebase to API-based implementation
class PhoneAuthService {
  // FIREBASE_IMPLEMENTATION: Commented out Firebase Auth instance
  // final FirebaseAuth _auth = FirebaseAuth.instance;

  // API_IMPLEMENTATION: New HTTP service for API calls
  final HttpService _httpService = HttpService();

  /// Resend OTP to the same phone number
  /// Returns new verification ID
  Future<String> resendOtp(String phoneNumber) async {
    if (kDebugMode) print('Resending OTP to: $phoneNumber');
    return await sendOtp(phoneNumber);
  }

  /// Send OTP to the provided phone number
  /// Returns verification ID for OTP verification
  Future<String> sendOtp(String phoneNumber) async {
    // FIREBASE_IMPLEMENTATION: Commented out Firebase-based implementation
    /*
    final Completer<String> completer = Completer();
    
    try {
      final formattedPhone = '${Constants.countryCode}$phoneNumber';
      
      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: (PhoneAuthCredential credential) {
          // Auto-verification completed (Android only)
          if (kDebugMode) print('Phone verification completed automatically');
        },
        verificationFailed: (FirebaseAuthException e) {
          if (kDebugMode) print('Phone verification failed: ${e.message}');
          completer.completeError(_handleFirebaseException(e));
        },
        codeSent: (String verificationId, int? resendToken) {
          if (kDebugMode) print('OTP sent successfully, verification ID: $verificationId');
          completer.complete(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          if (kDebugMode) print('Auto retrieval timeout for verification ID: $verificationId');
        },
        timeout: Duration(seconds: Constants.otpTimeoutSeconds),
      );
      
      return await completer.future;
    } on SocketException {
      throw Exception(Strings.noInternetConnection);
    } on TimeoutException {
      throw Exception(Strings.checkInternetConnection);
    } catch (e) {
      if (kDebugMode) print('Error sending OTP: $e');
      throw Exception(Strings.formatErrorMessage(Strings.failedToSendOtp, e));
    }
    */

    // API_IMPLEMENTATION: New HTTP-based implementation
    try {
      final formattedPhone = _formatPhoneNumber(phoneNumber);

      final response = await _httpService.post(Endpoints.sendOtp, body: {'phone': formattedPhone});

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        final verificationId = data['session_id'] as String;
        if (kDebugMode) print('OTP sent successfully, verification ID: $verificationId');
        return verificationId;
      } else {
        throw Exception(data['message']);
      }
    } on SocketException {
      throw Exception(Strings.noInternetConnection);
    } on TimeoutException {
      throw Exception(Strings.checkInternetConnection);
    } catch (e) {
      if (kDebugMode) print('Error sending OTP: $e');
      if (e is Exception) {
        rethrow;
      }
      throw Exception(Strings.formatErrorMessage(Strings.failedToSendOtp, e));
    }
  }

  /// Verify OTP with the verification ID
  /// Returns true if verification is successful
  Future<bool> verifyOtp(String verificationId, String otp, String phone) async {
    // FIREBASE_IMPLEMENTATION: Commented out Firebase-based implementation
    /*
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      
      // Sign in temporarily to verify the credential
      final result = await _auth.signInWithCredential(credential);
      
      // Sign out immediately as we only need verification
      if (result.user != null) {
        await _auth.signOut();
        if (kDebugMode) print('Phone verification successful');
        return true;
      }
      
      return false;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) print('OTP verification failed: ${e.message}');
      throw _handleFirebaseException(e);
    } on SocketException {
      throw Exception(Strings.noInternetConnection);
    } on TimeoutException {
      throw Exception(Strings.checkInternetConnection);
    } catch (e) {
      if (kDebugMode) print('Error verifying OTP: $e');
      throw Exception(Strings.formatErrorMessage(Strings.failedToVerifyOtp, e));
    }
    */

    // API_IMPLEMENTATION: New HTTP-based verification
    try {
      final response = await _httpService.post(
        Endpoints.verifyOtp,
        body: {'session_id': verificationId, 'otp': otp, 'phone': _formatPhoneNumber(phone)},
      );

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        // final verified = data['verified'] ?? false;
        // if (verified && kDebugMode) print('Phone verification successful');
        // return verified;
        return true;
      } else {
        throw _handleApiException(data);
      }
    } on SocketException {
      throw Exception(Strings.noInternetConnection);
    } on TimeoutException {
      throw Exception(Strings.checkInternetConnection);
    } catch (e) {
      if (kDebugMode) print('Error verifying OTP: $e');
      if (e is Exception) {
        rethrow;
      }
      throw Exception(Strings.formatErrorMessage(Strings.failedToVerifyOtp, e));
    }
  }

  /// Format phone number with country code
  String _formatPhoneNumber(String phoneNumber) {
    // Remove any existing country code or special characters
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');

    // If phone already has country code, return as is
    if (cleanPhone.startsWith('91') && cleanPhone.length == 12) {
      return '+$cleanPhone';
    }

    // Add country code for 10-digit numbers
    if (cleanPhone.length == 10) {
      return '${Constants.countryCode}$cleanPhone';
    }

    // Return formatted phone with country code
    return '${Constants.countryCode}$phoneNumber';
  }

  /// Handle API response exceptions
  /// Maps API error codes to user-friendly messages
  Exception _handleApiException(Map<String, dynamic> data) {
    final errorCode = data['message'] as String?;
    String message;

    switch (errorCode) {
      case 'INVALID_PHONE_NUMBER':
        message = Strings.phoneInvalidFormat;
        break;
      case 'TOO_MANY_REQUESTS':
        message = Strings.tooManyRequests;
        break;
      case 'INVALID_OTP':
        message = Strings.invalidOtp;
        break;
      case 'SESSION_EXPIRED':
        message = 'Verification session expired. Please try again.';
        break;
      case 'SERVER_ERROR':
        message = 'Service temporarily unavailable. Please try again.';
        break;
      case 'NETWORK_ERROR':
        message = Strings.networkError;
        break;
      default:
        message = data['message'] ?? Strings.authenticationFailed;
    }

    return Exception(message);
  }

  // FIREBASE_IMPLEMENTATION: Commented out Firebase exception handler
  /*
  /// Handle Firebase authentication exceptions
  Exception _handleFirebaseException(FirebaseAuthException e) {
    String message;
    
    switch (e.code) {
      case 'invalid-phone-number':
        message = Strings.phoneInvalidFormat;
        break;
      case 'too-many-requests':
        message = Strings.tooManyRequests;
        break;
      case 'invalid-verification-code':
        message = Strings.invalidOtp;
        break;
      case 'session-expired':
        message = 'Verification session expired. Please try again.';
        break;
      case 'quota-exceeded':
        message = 'SMS quota exceeded. Please try again later.';
        break;
      case 'app-not-authorized':
        message = 'App not authorized for phone authentication.';
        break;
      case 'network-request-failed':
        message = Strings.networkError;
        break;
      default:
        message = Strings.formatErrorMessage(Strings.authenticationFailed, e.message);
    }
    
    return Exception(message);
  }
  */
}
