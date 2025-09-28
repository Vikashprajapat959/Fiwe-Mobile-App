import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:fiwe/src/controllers/user_rating_controller.dart';
import 'package:fiwe/src/models/video_room_models.dart';
import 'package:fiwe/src/utils/colors.dart';
import 'package:fiwe/src/utils/constants.dart';

class UserRatingScreen extends StatefulWidget {
  const UserRatingScreen({super.key});

  @override
  State<UserRatingScreen> createState() => _UserRatingScreenState();
}

class _UserRatingScreenState extends State<UserRatingScreen> {
  late UserRatingController controller;
  
  @override
  void initState() {
    super.initState();
    controller = Get.put(UserRatingController());
    
    // Get arguments from navigation
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      final participants = args['participants'] as List<Participant>? ?? [];
      final roomId = args['roomParticipationId'] as String? ?? '';
      controller.initializeRatings(participants, roomId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Show confirmation dialog before leaving
        return await _showExitConfirmation() ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Rate Participants'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(LucideIcons.x),
            onPressed: () async {
              final shouldExit = await _showExitConfirmation();
              if (shouldExit == true) {
                Get.offAllNamed(Constants.homeViewRoute);
              }
            },
          ),
        ),
        body: Obx(() {
          if (controller.participantRatings.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.users, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No participants to rate',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Progress indicator
              _buildProgressIndicator(),
              
              // Global anonymous toggle
              _buildGlobalAnonymousToggle(),
              
              // Participant list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.participantRatings.length,
                  itemBuilder: (context, index) {
                    final rating = controller.participantRatings[index];
                    return ParticipantRatingCard(
                      participantRating: rating,
                      onRatingChanged: (score) {
                        controller.updateParticipantRating(rating.userId, score);
                      },
                      onFeedbackChanged: (feedback) {
                        controller.updateParticipantFeedback(rating.userId, feedback);
                      },
                      onAnonymousToggle: () {
                        controller.toggleParticipantAnonymous(rating.userId);
                      },
                    );
                  },
                ),
              ),
              
              // Submit button
              _buildSubmitButton(),
            ],
          );
        }),
        
        // Loading overlay
        bottomSheet: Obx(() {
          if (controller.isSubmitting) {
            return Container(
              height: 100,
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    SizedBox(height: 8),
                    Text('Submitting ratings...', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Obx(() {
      final completed = controller.completedRatingsCount;
      final total = controller.totalRatingsCount;
      final progress = total > 0 ? completed / total : 0.0;
      
      return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            const SizedBox(height: 8),
            Text(
              '$completed of $total participants rated',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildGlobalAnonymousToggle() {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            const Icon(LucideIcons.eyeOff, size: 20),
            const SizedBox(width: 8),
            const Text('Rate anonymously'),
            const Spacer(),
            Switch(
              value: controller.globalAnonymous,
              onChanged: (_) => controller.toggleGlobalAnonymous(),
              activeColor: AppColors.primary,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSubmitButton() {
    return Obx(() {
      final canSubmit = controller.allRatingsCompleted && !controller.isSubmitting;
      
      return Container(
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        child: ElevatedButton(
          onPressed: canSubmit ? controller.submitAllRatings : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            controller.isSubmitting 
                ? 'Submitting...' 
                : canSubmit 
                    ? 'Submit Ratings' 
                    : 'Complete all ratings to submit',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      );
    });
  }

  Future<bool?> _showExitConfirmation() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Rating Screen?'),
        content: const Text('Your ratings will be lost if you leave now.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Leave', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class ParticipantRatingCard extends StatefulWidget {
  final ParticipantRating participantRating;
  final Function(int) onRatingChanged;
  final Function(String) onFeedbackChanged;
  final VoidCallback onAnonymousToggle;

  const ParticipantRatingCard({
    super.key,
    required this.participantRating,
    required this.onRatingChanged,
    required this.onFeedbackChanged,
    required this.onAnonymousToggle,
  });

  @override
  State<ParticipantRatingCard> createState() => _ParticipantRatingCardState();
}

class _ParticipantRatingCardState extends State<ParticipantRatingCard> {
  late TextEditingController feedbackController;
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    feedbackController = TextEditingController(
      text: widget.participantRating.feedbackText.value,
    );
  }

  @override
  void dispose() {
    feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: widget.participantRating.isValid 
                ? AppColors.primary.withOpacity(0.3) 
                : Colors.grey.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Participant info and rating
              Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: widget.participantRating.avatarUrl != null
                        ? ClipOval(
                            child: Image.network(
                              widget.participantRating.avatarUrl!,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(LucideIcons.user, color: AppColors.primary);
                              },
                            ),
                          )
                        : const Icon(LucideIcons.user, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  
                  // Name and rating stars
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.participantRating.displayName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        StarRatingWidget(
                          rating: widget.participantRating.ratingScore.value,
                          onRatingChanged: widget.onRatingChanged,
                        ),
                      ],
                    ),
                  ),
                  
                  // Validation indicator
                  if (widget.participantRating.isValid)
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 20,
                    ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Feedback section
              GestureDetector(
                onTap: () => setState(() => isExpanded = !isExpanded),
                child: Row(
                  children: [
                    const Icon(Icons.message, size: 16),
                    const SizedBox(width: 8),
                    const Text(
                      'Add feedback (optional)',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const Spacer(),
                    Icon(
                      isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
              
              if (isExpanded) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: feedbackController,
                  maxLines: 3,
                  maxLength: 500,
                  decoration: InputDecoration(
                    hintText: 'Share your experience with this participant...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  onChanged: widget.onFeedbackChanged,
                ),
              ],
              
              const SizedBox(height: 12),
              
              // Anonymous toggle
              Row(
                children: [
                  const Icon(LucideIcons.eyeOff, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  const Text(
                    'Anonymous rating',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const Spacer(),
                  Switch(
                    value: widget.participantRating.isAnonymous.value,
                    onChanged: (_) => widget.onAnonymousToggle(),
                    activeColor: AppColors.primary,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}

class StarRatingWidget extends StatelessWidget {
  final int rating;
  final Function(int) onRatingChanged;
  final int maxRating;

  const StarRatingWidget({
    super.key,
    required this.rating,
    required this.onRatingChanged,
    this.maxRating = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxRating, (index) {
        final starIndex = index + 1;
        final isFilled = starIndex <= rating;
        
        return GestureDetector(
          onTap: () => onRatingChanged(starIndex),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Icon(
              isFilled ? Icons.star : Icons.star_border,
              color: isFilled ? Colors.amber : Colors.grey[300],
              size: 32,
            ),
          ),
        );
      }),
    );
  }
}