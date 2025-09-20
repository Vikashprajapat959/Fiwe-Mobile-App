import 'dart:math';
import 'package:fiwe/src/models/hms_reaction.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/video_room_controller.dart';
import '../../../services/hms_room_service.dart'; // Import to access Reaction class

class ReactionOverlay extends StatefulWidget {
  const ReactionOverlay({super.key});

  @override
  State<ReactionOverlay> createState() => _ReactionOverlayState();
}

class _ReactionOverlayState extends State<ReactionOverlay>
    with TickerProviderStateMixin {
  final List<_AnimatedReaction> _animatedReactions = [];
  late VideoRoomController controller;

  @override
  void initState() {
    super.initState();
    // Get the controller
    controller = Get.find<VideoRoomController>();
    // Listen to reactions from the controller
    controller.reactionsObservable.listen(_addReaction);
  }

  void _addReaction(List<HMSReaction> reactions) {
    // Use the Reaction class from video_room_service
    if (reactions.isNotEmpty) {
      final latestReaction = reactions.last;
      final reactionKey = ValueKey(latestReaction.id); // Use reaction ID as key
      final newReaction = _AnimatedReaction(
        key: reactionKey,
        emoji: latestReaction.emoji,
        animationController: AnimationController(
          duration: const Duration(milliseconds: 3000),
          vsync: this,
        ),
      );

      setState(() {
        _animatedReactions.add(newReaction);
      });

      // Start the animation
      newReaction.animationController.forward();

      // Remove the reaction after animation completes
      newReaction.animationController.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _animatedReactions.removeWhere(
              (element) => element.key == reactionKey,
            );
          });
          newReaction.animationController.dispose();
        }
      });
    }
  }

  @override
  void dispose() {
    // Dispose all animation controllers
    for (final reaction in _animatedReactions) {
      reaction.animationController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background (transparent)
        const Positioned.fill(child: ColoredBox(color: Colors.transparent)),
        // Animated reactions
        ..._animatedReactions.map((reaction) {
          return AnimatedReactionWidget(
            key: reaction.key,
            emoji: reaction.emoji,
            controller: reaction.animationController,
          );
        }),
      ],
    );
  }
}

class _AnimatedReaction {
  final Key key;
  final String emoji;
  final AnimationController animationController;

  _AnimatedReaction({
    required this.key,
    required this.emoji,
    required this.animationController,
  });
}

class AnimatedReactionWidget extends StatefulWidget {
  final String emoji;
  final AnimationController controller;

  const AnimatedReactionWidget({
    super.key,
    required this.emoji,
    required this.controller,
  });

  @override
  State<AnimatedReactionWidget> createState() => _AnimatedReactionWidgetState();
}

class _AnimatedReactionWidgetState extends State<AnimatedReactionWidget> {
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // Random starting position at the bottom
    final random = Random();
    final startDx =
        random.nextDouble() * 0.8 + 0.1; // 10% to 90% of screen width

    _offsetAnimation =
        Tween<Offset>(
          begin: Offset(startDx, 1.0), // Start from bottom
          end: Offset(
            startDx + (random.nextDouble() - 0.5) * 0.4,
            -0.2,
          ), // End above top with some horizontal movement
        ).animate(
          CurvedAnimation(parent: widget.controller, curve: Curves.easeOut),
        );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.5).animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: const Interval(0.0, 0.3, curve: Curves.elasticOut),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        return Positioned.fill(
          child: FractionalTranslation(
            translation: _offsetAnimation.value,
            child: Center(
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _opacityAnimation.value,
                  child: Text(
                    widget.emoji,
                    style: const TextStyle(
                      fontSize: 40,
                      shadows: [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 3,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
