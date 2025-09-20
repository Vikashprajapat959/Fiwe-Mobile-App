import 'package:fiwe_notification/src/models/notification_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Visual representation of notifications with animations
class NotificationWidget extends StatefulWidget {
  final NotificationConfig config;
  final VoidCallback onDismiss;
  final double verticalOffset;
  final double horizontalOffset;

  const NotificationWidget({
    super.key,
    required this.config,
    required this.onDismiss,
    this.verticalOffset = 0.0,
    this.horizontalOffset = 0, // Default to no offset
  });

  @override
  State<NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget> with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late AnimationController _dismissController;
  late Animation<Offset> _dismissAnimation;

  // Store animation values
  late Offset _slideBegin;
  late Offset _slideEnd;
  late Offset _dismissBegin;
  late Offset _dismissEnd;

  // Scale transformation for long press effect
  double _scale = 1.0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();

    // Initialize slide-in animation
    _slideController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);

    _slideBegin = const Offset(0, -0.2); // Start from halfway off-screen
    _slideEnd = const Offset(0, 0.4); // Will be updated in build method

    _slideAnimation = Tween<Offset>(
      begin: _slideBegin,
      end: _slideEnd,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack));

    // Initialize dismiss animation
    _dismissController = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);

    _dismissBegin = const Offset(0, 0.4); // Will be updated in build method
    _dismissEnd = const Offset(0, -0.2); // Dismiss to halfway off-screen

    _dismissAnimation = Tween<Offset>(
      begin: _dismissBegin,
      end: _dismissEnd,
    ).animate(CurvedAnimation(parent: _dismissController, curve: Curves.easeIn));

    // Start slide-in animation
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _dismissController.dispose();
    super.dispose();
  }

  /// Handle horizontal drag for dismissal
  void _handleDragStart(DragStartDetails details) {
    _isDragging = true;
  }

  /// Handle drag update for visual feedback
  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;

    // We could implement visual feedback here, but for simplicity
    // we'll just track the drag
  }

  /// Handle drag end to determine if we should dismiss
  void _handleDragEnd(DragEndDetails details) {
    if (!_isDragging) return;

    _isDragging = false;

    // Check if the drag velocity is enough to dismiss
    if (details.velocity.pixelsPerSecond.dx.abs() > 1000) {
      // Dismiss in the direction of the swipe
      _dismissHorizontally(details.velocity.pixelsPerSecond.dx > 0 ? 1 : -1);
    }
  }

  /// Handle long press for visual feedback
  void _handleLongPress() {
    // Add haptic feedback
    HapticFeedback.lightImpact();

    // Shrink the notification slightly
    setState(() {
      _scale = 0.95; // Shrink to 95% of original size
    });
  }

  /// Handle long press end
  void _handleLongPressEnd() {
    // Reset the scale
    setState(() {
      _scale = 1.0; // Reset to original size
    });
  }

  /// Dismiss the notification horizontally
  void _dismissHorizontally(int direction) {
    // Set up horizontal dismiss animation
    _dismissEnd = Offset(direction * 2.0, _dismissBegin.dy); // Move left or right while maintaining vertical position

    _dismissAnimation = Tween<Offset>(
      begin: _dismissBegin,
      end: _dismissEnd,
    ).animate(CurvedAnimation(parent: _dismissController, curve: Curves.easeIn));

    // Forward the animation and dismiss
    _dismissController.forward().then((_) {
      widget.onDismiss();
    });
  }

  /// Dismiss the notification to the top (for auto-dismiss)
  void dismissToTop() {
    _dismissController.forward().then((_) {
      widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Update animation end positions based on vertical offset
    final screenHeight = MediaQuery.of(context).size.height;
    final relativeOffset = widget.verticalOffset / screenHeight + 0.4;
    final relativeHorizontalOffset = widget.horizontalOffset / MediaQuery.of(context).size.width;

    // Update slide animation end position
    _slideEnd = Offset(relativeHorizontalOffset, relativeOffset);
    _slideAnimation = Tween<Offset>(
      begin: _slideBegin,
      end: _slideEnd,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack));

    // Update dismiss animation begin position
    _dismissBegin = Offset(0, relativeOffset);
    _dismissAnimation = Tween<Offset>(
      begin: _dismissBegin,
      end: _dismissEnd,
    ).animate(CurvedAnimation(parent: _dismissController, curve: Curves.easeIn));

    return GestureDetector(
      onHorizontalDragStart: _handleDragStart,
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      onLongPress: _handleLongPress,
      onLongPressUp: _handleLongPressEnd,
      child: AnimatedBuilder(
        animation: _slideController,
        builder: (context, child) {
          return AnimatedBuilder(
            animation: _dismissController,
            builder: (context, child) {
              // Determine which animation to use
              final animation = _dismissController.isAnimating ? _dismissAnimation : _slideAnimation;

              return Align(
                alignment: Alignment.topCenter,
                child: Transform.scale(
                  scale: _scale,
                  child: FractionalTranslation(
                    translation: animation.value,
                    child: Transform.translate(
                      offset: Offset(0, widget.verticalOffset),
                      child: _buildNotificationContent(),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  BoxDecoration _getDecorationBasedOnType() {
    switch (widget.config.type) {
      case NotificationType.success:
        return BoxDecoration(
          color: Colors.green.shade50,
          border: Border.all(color: Colors.green.shade200),
          borderRadius: BorderRadius.all(Radius.elliptical(12, 14)),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(2, 2))],
        );
      case NotificationType.error:
        return BoxDecoration(
          color: Colors.red.shade50,
          border: Border.all(color: Colors.red.shade200),
          borderRadius: BorderRadius.all(Radius.elliptical(12, 14)),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(2, 2))],
        );
      case NotificationType.warning:
        return BoxDecoration(
          color: Colors.orange.shade50,
          border: Border.all(color: Colors.orange.shade200),
          borderRadius: BorderRadius.all(Radius.elliptical(12, 14)),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(2, 2))],
        );
      case NotificationType.info:
      default:
        return BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.blue.shade200),
          borderRadius: BorderRadius.all(Radius.elliptical(12, 14)),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(2, 2))],
        );
    }
  }

  /// Build the actual notification content
  Widget _buildNotificationContent() {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(16.0),
        padding: const EdgeInsets.all(16.0),
        decoration: widget.config.decoration ?? _getDecorationBasedOnType(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,

                    children: [
                      // Title
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Icon (if provided)
                          if (widget.config.icon != null) ...[widget.config.icon!, const SizedBox(width: 8.0)],

                          Text(
                            widget.config.title,
                            style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),

                      // Description (if provided)
                      if (widget.config.description != null) ...[
                        const SizedBox(height: 4.0),
                        Text(widget.config.description!, style: const TextStyle(fontSize: 14.0, color: Colors.grey)),
                      ],
                    ],
                  ),
                ),

                // Dismiss button
                IconButton(icon: const Icon(Icons.close, size: 20.0), onPressed: dismissToTop),
              ],
            ),
            // Actions (if provided)
            if (widget.config.actions != null && widget.config.actions!.isNotEmpty) ...[
              const SizedBox(height: 8.0),
              Align(
                alignment: Alignment.centerRight,
                child: Wrap(
                  alignment: WrapAlignment.end,
                  children: widget.config.actions!.map((action) {
                    return TextButton(
                      onPressed: action.onPressed,
                      child: Text(action.label),
                      style: ButtonStyle(
                        foregroundColor: WidgetStatePropertyAll(
                          action.style == NotificationActionStyle.primary ? Colors.green : Colors.red,
                        ),
                        textStyle: WidgetStatePropertyAll(const TextStyle(fontSize: 14.0)),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
