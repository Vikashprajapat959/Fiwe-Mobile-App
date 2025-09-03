import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/notification_data.dart';
import '../controllers/notification_controller.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';

/// Widget for displaying in-app notifications when app is in foreground
class InAppNotificationWidget extends StatefulWidget {
  final NotificationData notification;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;
  final Duration duration;

  const InAppNotificationWidget({
    super.key,
    required this.notification,
    this.onTap,
    this.onDismiss,
    this.duration = const Duration(seconds: Constants.foregroundNotificationDurationSeconds),
  });

  @override
  State<InAppNotificationWidget> createState() => _InAppNotificationWidgetState();
}

class _InAppNotificationWidgetState extends State<InAppNotificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startShowAnimation();
    _scheduleAutoDismiss();
  }

  /// Initialize slide and fade animations
  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: Constants.notificationAnimationDurationMs),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  /// Start show animation
  void _startShowAnimation() {
    _animationController.forward();
  }

  /// Schedule auto-dismiss
  void _scheduleAutoDismiss() {
    Future.delayed(widget.duration, () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  /// Dismiss notification with animation
  Future<void> _dismiss() async {
    await _animationController.reverse();
    if (mounted) {
      widget.onDismiss?.call();
      NotificationController.instance.dismissForegroundNotification();
    }
  }

  /// Handle tap on notification
  void _handleTap() {
    widget.onTap?.call();
    NotificationController.instance.navigateToNotification(widget.notification);
  }

  /// Get notification icon based on type and priority
  IconData _getNotificationIcon() {
    switch (widget.notification.type) {
      case NotificationType.userMessage:
        return Icons.message;
      case NotificationType.systemAlert:
        return Icons.info;
      case NotificationType.promotional:
        return Icons.local_offer;
      case NotificationType.reminder:
        return Icons.schedule;
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
    // Use white text for darker backgrounds, dark text for lighter backgrounds
    return backgroundColor.computeLuminance() > 0.5 
        ? AppColors.textDark 
        : AppColors.textLight;
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.only(
            top: Constants.notificationTopMargin,
            left: Constants.notificationHorizontalMargin,
            right: Constants.notificationHorizontalMargin,
          ),
          child: Material(
            elevation: Constants.notificationElevation,
            borderRadius: BorderRadius.circular(Constants.notificationBorderRadius),
            color: _getNotificationColor(),
            child: InkWell(
              onTap: _handleTap,
              borderRadius: BorderRadius.circular(Constants.notificationBorderRadius),
              child: Container(
                padding: const EdgeInsets.all(Constants.notificationPadding),
                child: Row(
                  children: [
                    // Notification icon
                    Container(
                      padding: const EdgeInsets.all(Constants.notificationIconPadding),
                      decoration: BoxDecoration(
                        color: _getTextColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(Constants.notificationIconBorderRadius),
                      ),
                      child: Icon(
                        _getNotificationIcon(),
                        color: _getTextColor(),
                        size: Constants.notificationIconSize,
                      ),
                    ),
                    
                    const SizedBox(width: Constants.notificationContentSpacing),
                    
                    // Notification content
                    Expanded(
                      child: Column(
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          
                          // Body (if not empty)
                          if (widget.notification.body.isNotEmpty) ...[
                            const SizedBox(height: Constants.notificationTextSpacing),
                            Text(
                              widget.notification.body,
                              style: TextStyle(
                                color: _getTextColor().withOpacity(0.8),
                                fontSize: Constants.notificationBodyFontSize,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    const SizedBox(width: Constants.notificationContentSpacing),
                    
                    // Close button
                    GestureDetector(
                      onTap: _dismiss,
                      child: Container(
                        padding: const EdgeInsets.all(Constants.notificationCloseButtonPadding),
                        decoration: BoxDecoration(
                          color: _getTextColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(Constants.notificationCloseButtonBorderRadius),
                        ),
                        child: Icon(
                          Icons.close,
                          color: _getTextColor(),
                          size: Constants.notificationCloseButtonSize,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

/// Overlay widget for showing in-app notifications
class NotificationOverlay extends StatelessWidget {
  const NotificationOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<NotificationController>(
      builder: (controller) {
        final currentNotificationId = controller.currentForegroundNotification;
        
        if (currentNotificationId == null) {
          return const SizedBox.shrink();
        }

        final notification = controller.getNotificationById(currentNotificationId);
        
        if (notification == null) {
          return const SizedBox.shrink();
        }

        return Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: InAppNotificationWidget(
              notification: notification,
              onTap: () {
                controller.navigateToNotification(notification);
              },
              onDismiss: () {
                controller.dismissForegroundNotification();
              },
            ),
          ),
        );
      },
    );
  }
}

/// Helper widget to easily add notification overlay to any screen
class NotificationWrapper extends StatelessWidget {
  final Widget child;

  const NotificationWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        const NotificationOverlay(),
      ],
    );
  }
}