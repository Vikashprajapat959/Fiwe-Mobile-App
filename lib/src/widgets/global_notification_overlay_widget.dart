import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/notification_data.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../utils/strings.dart';

/// Global notification overlay widget that appears over any screen
class GlobalNotificationOverlayWidget extends StatefulWidget {
  final NotificationData notification;
  final VoidCallback onDismiss;
  final VoidCallback onTap;

  const GlobalNotificationOverlayWidget({
    super.key,
    required this.notification,
    required this.onDismiss,
    required this.onTap,
  });

  @override
  State<GlobalNotificationOverlayWidget> createState() => _GlobalNotificationOverlayWidgetState();
}

class _GlobalNotificationOverlayWidgetState extends State<GlobalNotificationOverlayWidget>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _dismissController;
  late Animation<Offset> _slideAnimation;
  late Animation<Offset> _dismissAnimation;
  late Animation<double> _fadeAnimation;

  // Gesture tracking
  double _dragExtent = 0.0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _animateIn();
  }

  /// Initialize animations
  void _initializeAnimations() {
    // Slide-in animation controller
    _slideController = AnimationController(
      duration: Duration(milliseconds: Constants.notificationAnimationDurationMs),
      vsync: this,
    );

    // Dismiss animation controller
    _dismissController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Slide animation (from top)
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    // Dismiss animation (slide out)
    _dismissAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1),
    ).animate(CurvedAnimation(
      parent: _dismissController,
      curve: Curves.easeInBack,
    ));

    // Fade animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));
  }

  /// Animate notification in
  void _animateIn() {
    _slideController.forward();
  }

  /// Animate notification out and dismiss
  Future<void> _animateOut() async {
    await _dismissController.forward();
    widget.onDismiss();
  }

  /// Handle horizontal drag for swipe dismissal
  void _handleHorizontalDrag(DragUpdateDetails details) {
    if (!_isDragging) {
      _isDragging = true;
    }

    setState(() {
      _dragExtent += details.delta.dx;
    });
  }

  /// Handle drag end for swipe dismissal
  void _handleDragEnd(DragEndDetails details) {
    const double dismissThreshold = 100.0; // Minimum drag distance to dismiss
    
    if (_dragExtent.abs() > dismissThreshold) {
      // Dismiss if dragged far enough
      _animateOut();
    } else {
      // Reset position if not dragged far enough
      setState(() {
        _dragExtent = 0.0;
      });
    }
    _isDragging = false;
  }

  /// Get notification icon based on type
  IconData _getNotificationIcon() {
    switch (widget.notification.type) {
      case NotificationType.userMessage:
        return Icons.message_rounded;
      case NotificationType.systemAlert:
        return Icons.info_rounded;
      case NotificationType.promotional:
        return Icons.local_offer_rounded;
      case NotificationType.reminder:
        return Icons.schedule_rounded;
    }
  }

  /// Get notification color based on priority
  Color _getNotificationColor() {
    switch (widget.notification.priority) {
      case NotificationPriority.low:
        return AppColors.notificationLowPriority;
      case NotificationPriority.normal:
        return AppColors.notificationNormalPriority;
      case NotificationPriority.high:
        return AppColors.notificationHighPriority;
      case NotificationPriority.urgent:
        return AppColors.notificationUrgentPriority;
    }
  }

  /// Get text color based on background
  Color _getTextColor() {
    final backgroundColor = _getNotificationColor();
    return backgroundColor.computeLuminance() > 0.5 
        ? AppColors.textDark 
        : AppColors.textLight;
  }

  /// Calculate safe area top padding (includes status bar + AppBar)
  double _calculateTopPadding(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final statusBarHeight = mediaQuery.padding.top;
    const appBarHeight = kToolbarHeight; // Standard AppBar height
    
    return statusBarHeight + appBarHeight + Constants.notificationTopMargin;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: _calculateTopPadding(context),
      left: Constants.notificationHorizontalMargin,
      right: Constants.notificationHorizontalMargin,
      child: SlideTransition(
        position: _dismissController.isAnimating 
            ? _dismissAnimation 
            : _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Transform.translate(
            offset: Offset(_dragExtent, 0),
            child: GestureDetector(
              onTap: widget.onTap,
              onHorizontalDragUpdate: _handleHorizontalDrag,
              onHorizontalDragEnd: _handleDragEnd,
              child: Material(
                elevation: Constants.notificationElevation,
                borderRadius: BorderRadius.circular(Constants.notificationBorderRadius),
                color: _getNotificationColor(),
                child: Container(
                  constraints: BoxConstraints(
                    minHeight: Constants.notificationMinHeight,
                    maxHeight: Constants.notificationMaxHeight,
                  ),
                  padding: const EdgeInsets.all(Constants.notificationPadding),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Notification icon
                      _buildNotificationIcon(),
                      
                      const SizedBox(width: Constants.notificationContentSpacing),
                      
                      // Notification content
                      Expanded(child: _buildNotificationContent()),
                      
                      const SizedBox(width: Constants.notificationContentSpacing),
                      
                      // Dismiss button
                      _buildDismissButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build notification icon
  Widget _buildNotificationIcon() {
    return Container(
      padding: const EdgeInsets.all(Constants.notificationIconPadding),
      decoration: BoxDecoration(
        color: _getTextColor().withOpacity(0.15),
        borderRadius: BorderRadius.circular(Constants.notificationIconBorderRadius),
      ),
      child: Icon(
        _getNotificationIcon(),
        color: _getTextColor(),
        size: Constants.notificationIconSize,
      ),
    );
  }

  /// Build notification content
  Widget _buildNotificationContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title
        Text(
          widget.notification.title,
          style: TextStyle(
            color: _getTextColor(),
            fontSize: Constants.notificationTitleFontSize,
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        
        // Body (if not empty)
        if (widget.notification.body.isNotEmpty) ...[
          const SizedBox(height: Constants.notificationTextSpacing),
          Text(
            widget.notification.body,
            style: TextStyle(
              color: _getTextColor().withOpacity(0.9),
              fontSize: Constants.notificationBodyFontSize,
              height: 1.3,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        
        // Swipe hint for user education
        const SizedBox(height: Constants.notificationTextSpacing * 2),
        Text(
          Strings.notificationSwipeHint,
          style: TextStyle(
            color: _getTextColor().withOpacity(0.7),
            fontSize: Constants.notificationHintFontSize,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  /// Build dismiss button
  Widget _buildDismissButton() {
    return GestureDetector(
      onTap: _animateOut,
      child: Container(
        padding: const EdgeInsets.all(Constants.notificationCloseButtonPadding),
        decoration: BoxDecoration(
          color: _getTextColor().withOpacity(0.15),
          borderRadius: BorderRadius.circular(Constants.notificationCloseButtonBorderRadius),
        ),
        child: Icon(
          Icons.close_rounded,
          color: _getTextColor(),
          size: Constants.notificationCloseButtonSize,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    _dismissController.dispose();
    super.dispose();
  }
}