import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Helper class to show loading overlays with modal barriers
/// Blocks user interaction during async operations
class LoadingOverlay {
  static OverlayEntry? _overlayEntry;
  static bool _isShowing = false;

  /// Check if overlay is currently showing
  static bool get isShowing => _isShowing;

  /// Execute an async function with loading overlay
  ///
  /// Automatically shows overlay before execution and hides after completion
  /// [future] - The async function to execute
  /// [message] - Loading message to display
  /// [canDismiss] - Whether user can dismiss the overlay
  /// Returns the result of the future
  static Future<T> execute<T>(
    Future<T> future, {
    String? message,
    bool canDismiss = false,
    Color backgroundColor = const Color(0x80000000),
    Color indicatorColor = Colors.white,
  }) async {
    bool showedOverlay = false;

    try {
      // Only show overlay if context is available
      if (Get.context != null) {
        show(backgroundColor: backgroundColor, indicatorColor: indicatorColor);
        showedOverlay = _isShowing;
      }

      final result = await future;
      return result;
    } finally {
      // Only hide if we successfully showed the overlay
      if (showedOverlay) {
        hide();
      }
    }
  }

  /// Force hide the loading overlay (emergency cleanup)
  /// Use this when normal hide() doesn't work
  static void forceHide() {
    try {
      if (_overlayEntry != null && _overlayEntry!.mounted) {
        _overlayEntry!.remove();
      }
    } catch (e) {
      // Ignore any errors during force cleanup
    } finally {
      _overlayEntry = null;
      _isShowing = false;
    }
  }

  /// Hide the loading overlay
  static void hide() {
    if (!_isShowing || _overlayEntry == null) return;

    try {
      // Check if the overlay entry is still mounted before removing
      if (_overlayEntry!.mounted) {
        _overlayEntry!.remove();
      }
    } catch (e) {
      // Silently handle removal errors
    } finally {
      _overlayEntry = null;
      _isShowing = false;
    }
  }

  /// Show loading overlay with modal barrier
  ///
  /// [message] - Optional loading message to display
  /// [canDismiss] - Whether user can dismiss the overlay by tapping
  /// [backgroundColor] - Background color of the modal barrier
  /// [indicatorColor] - Color of the loading indicator
  static void show({Color backgroundColor = const Color(0x80000000), Color indicatorColor = Colors.white}) {
    if (_isShowing || Get.context == null) return;

    _isShowing = true;
    _overlayEntry = OverlayEntry(
      builder: (context) => _LoadingOverlayWidget(backgroundColor: backgroundColor, indicatorColor: indicatorColor),
    );

    try {
      final overlay = Overlay.of(Get.overlayContext!);
      overlay.insert(_overlayEntry!);
    } catch (e) {
      // If overlay insertion fails, reset state
      _overlayEntry = null;
      _isShowing = false;
    }
  }
}

/// Internal widget for the loading overlay
class _LoadingOverlayWidget extends StatelessWidget {
  final Color backgroundColor;
  final Color indicatorColor;

  const _LoadingOverlayWidget({required this.backgroundColor, required this.indicatorColor});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      child: Center(
        child: SizedBox(
          height: 60,
          width: 60,
          child: CircularProgressIndicator(strokeWidth: 4, valueColor: AlwaysStoppedAnimation<Color>(indicatorColor)),
        ),
      ),
    );
  }
}

/// Extension methods for easier usage with GetX controllers
extension LoadingOverlayExtension on GetxController {
  /// Execute async task with loading overlay from a controller
  Future<T> executeWithLoading<T>(
    Future<T> future, {
    String? message,
    bool canDismiss = false,
    Color backgroundColor = const Color(0x80000000),
    Color indicatorColor = Colors.white,
  }) {
    return LoadingOverlay.execute(
      future,
      message: message,
      canDismiss: canDismiss,
      backgroundColor: backgroundColor,
      indicatorColor: indicatorColor,
    );
  }

  /// Force hide loading overlay from a controller (emergency cleanup)
  void forceHideLoading() {
    LoadingOverlay.forceHide();
  }

  /// Hide loading overlay from a controller
  void hideLoading() {
    LoadingOverlay.hide();
  }

  /// Show loading overlay from a controller
  void showLoading({
    String? message,
    bool canDismiss = false,
    Color backgroundColor = const Color(0x80000000),
    Color indicatorColor = Colors.white,
  }) {
    LoadingOverlay.show(backgroundColor: backgroundColor, indicatorColor: indicatorColor);
  }
}
