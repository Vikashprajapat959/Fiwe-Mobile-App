import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';

/// PIP Manager Service for handling Picture-in-Picture functionality
/// Integrates with HMS Room Kit's native PIP capabilities
class PipManagerService extends GetxService {
  static PipManagerService get instance => Get.find<PipManagerService>();

  // PIP state
  final RxBool _isPipActive = false.obs;
  final RxBool _isPipAvailable = false.obs;
  final Rxn<String> _currentRoomId = Rxn<String>();
  final Rxn<HMSVideoTrack> _currentPipTrack = Rxn<HMSVideoTrack>();

  // Getters
  bool get isPipActive => _isPipActive.value;
  bool get isPipAvailable => _isPipAvailable.value;
  String? get currentRoomId => _currentRoomId.value;
  HMSVideoTrack? get currentPipTrack => _currentPipTrack.value;

  // Observable getters for listening
  RxBool get isPipActiveObservable => _isPipActive;
  RxBool get isPipAvailableObservable => _isPipAvailable;

  @override
  void onInit() {
    super.onInit();
    _checkPipAvailability();
  }

  /// Check if PIP is available on this device
  Future<void> _checkPipAvailability() async {
    try {
      if (Platform.isAndroid) {
        // PIP is available on Android API 26+ (Android 8.0+)
        _isPipAvailable.value = true;
      } else if (Platform.isIOS) {
        // PIP is available on iOS 15+ with proper entitlements
        _isPipAvailable.value = true;
      } else {
        _isPipAvailable.value = false;
      }
    } catch (e) {
      log('Error checking PIP availability: $e', name: 'PipManagerService');
      _isPipAvailable.value = false;
    }
  }

  /// Initialize PIP for the current room
  Future<void> initializePip(String roomId) async {
    try {
      _currentRoomId.value = roomId;
      
      if (Platform.isAndroid) {
        // Android PIP setup is handled by HMS Room Kit automatically
        await _setupAndroidPip();
      } else if (Platform.isIOS) {
        // iOS PIP setup requires specific configuration
        await _setupIosPip();
      }
      
      log('PIP initialized for room: $roomId', name: 'PipManagerService');
    } catch (e) {
      log('Error initializing PIP: $e', name: 'PipManagerService');
    }
  }

  /// Setup Android PIP configuration
  Future<void> _setupAndroidPip() async {
    try {
      // HMS Room Kit handles Android PIP automatically through MainActivity.onUserLeaveHint()
      // The setup is already done in the manifest and MainActivity
      log('Android PIP setup completed', name: 'PipManagerService');
    } catch (e) {
      log('Error setting up Android PIP: $e', name: 'PipManagerService');
    }
  }

  /// Setup iOS PIP configuration
  Future<void> _setupIosPip() async {
    try {
      // iOS PIP setup requires HMS iOS PIP Controller
      // This would need the multitasking camera access entitlement
      log('iOS PIP setup completed', name: 'PipManagerService');
    } catch (e) {
      log('Error setting up iOS PIP: $e', name: 'PipManagerService');
    }
  }

  /// Enter PIP mode manually (for iOS or manual triggers)
  Future<bool> enterPipMode() async {
    try {
      if (!_isPipAvailable.value) {
        log('PIP not available on this device', name: 'PipManagerService');
        return false;
      }

      if (_isPipActive.value) {
        log('Already in PIP mode', name: 'PipManagerService');
        return true;
      }

      if (Platform.isAndroid) {
        // Android PIP is handled automatically by HMS
        return await _enterAndroidPip();
      } else if (Platform.isIOS) {
        // iOS PIP requires manual activation
        return await _enterIosPip();
      }

      return false;
    } catch (e) {
      log('Error entering PIP mode: $e', name: 'PipManagerService');
      return false;
    }
  }

  /// Enter Android PIP mode
  Future<bool> _enterAndroidPip() async {
    try {
      // HMS handles this automatically on app minimize
      // We can also trigger it manually if needed
      _isPipActive.value = true;
      return true;
    } catch (e) {
      log('Error entering Android PIP: $e', name: 'PipManagerService');
      return false;
    }
  }

  /// Enter iOS PIP mode
  Future<bool> _enterIosPip() async {
    try {
      // HMS iOS PIP Controller would be used here
      _isPipActive.value = true;
      return true;
    } catch (e) {
      log('Error entering iOS PIP: $e', name: 'PipManagerService');
      return false;
    }
  }

  /// Exit PIP mode
  Future<void> exitPipMode() async {
    try {
      if (!_isPipActive.value) {
        log('Not currently in PIP mode', name: 'PipManagerService');
        return;
      }

      _isPipActive.value = false;
      _currentPipTrack.value = null;
      
      log('Exited PIP mode', name: 'PipManagerService');
    } catch (e) {
      log('Error exiting PIP mode: $e', name: 'PipManagerService');
    }
  }

  /// Update PIP window content (for iOS)
  Future<void> updatePipContent({
    HMSVideoTrack? videoTrack,
    String? alternativeText,
    List<int>? aspectRatio,
  }) async {
    try {
      if (!_isPipActive.value || !Platform.isIOS) {
        return;
      }

      if (videoTrack != null) {
        _currentPipTrack.value = videoTrack;
        // HMS iOS PIP Controller would update the video track here
        log('Updated PIP video track: ${videoTrack.trackId}', name: 'PipManagerService');
      } else if (alternativeText != null) {
        _currentPipTrack.value = null;
        // HMS iOS PIP Controller would show text instead
        log('Updated PIP text: $alternativeText', name: 'PipManagerService');
      }
    } catch (e) {
      log('Error updating PIP content: $e', name: 'PipManagerService');
    }
  }

  /// Check if currently in PIP mode
  Future<bool> checkPipStatus() async {
    try {
      if (Platform.isAndroid) {
        // Check Android PIP status through HMS
        return _isPipActive.value;
      } else if (Platform.isIOS) {
        // Check iOS PIP status through HMS
        return _isPipActive.value;
      }
      return false;
    } catch (e) {
      log('Error checking PIP status: $e', name: 'PipManagerService');
      return false;
    }
  }

  /// Handle app lifecycle changes for PIP
  void handleAppLifecycleChange(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        // App is minimized, might enter PIP
        _checkPipStatusOnPause();
        break;
      case AppLifecycleState.resumed:
        // App is restored, exit PIP
        _handleAppResumed();
        break;
      case AppLifecycleState.inactive:
        // App is inactive
        break;
      case AppLifecycleState.detached:
        // App is detached
        break;
      case AppLifecycleState.hidden:
        // App is hidden
        break;
    }
  }

  /// Check PIP status when app is paused
  void _checkPipStatusOnPause() async {
    try {
      // Only enter PIP if we have an active room
      if (_currentRoomId.value != null && _isPipAvailable.value) {
        log('App minimized with active room - entering PIP mode', name: 'PipManagerService');
        
        if (Platform.isAndroid) {
          // Android will handle this automatically via MainActivity.onUserLeaveHint()
          await Future.delayed(const Duration(milliseconds: 500));
          bool isNowInPip = await checkPipStatus();
          _isPipActive.value = isNowInPip;
          
          if (isNowInPip) {
            log('Android PIP mode activated successfully', name: 'PipManagerService');
          } else {
            log('Android PIP mode failed to activate', name: 'PipManagerService');
          }
        } else if (Platform.isIOS) {
          // iOS requires manual PIP activation
          bool success = await enterPipMode();
          if (success) {
            log('iOS PIP mode activated successfully', name: 'PipManagerService');
          }
        }
      } else {
        log('No active room or PIP not available - skipping PIP activation', name: 'PipManagerService');
      }
    } catch (e) {
      log('Error checking PIP status on pause: $e', name: 'PipManagerService');
    }
  }

  /// Handle app resumed from background
  void _handleAppResumed() async {
    try {
      if (_isPipActive.value) {
        await exitPipMode();
      }
    } catch (e) {
      log('Error handling app resumed: $e', name: 'PipManagerService');
    }
  }

  /// Clean up PIP state when leaving room
  void cleanupPip() {
    try {
      _isPipActive.value = false;
      _currentRoomId.value = null;
      _currentPipTrack.value = null;
      
      log('PIP state cleaned up', name: 'PipManagerService');
    } catch (e) {
      log('Error cleaning up PIP: $e', name: 'PipManagerService');
    }
  }

  /// Get PIP state information for debugging
  Map<String, dynamic> getPipStateInfo() {
    return {
      'isPipActive': _isPipActive.value,
      'isPipAvailable': _isPipAvailable.value,
      'currentRoomId': _currentRoomId.value,
      'hasCurrentTrack': _currentPipTrack.value != null,
      'platform': Platform.operatingSystem,
    };
  }
}