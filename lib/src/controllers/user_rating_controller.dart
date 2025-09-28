import 'dart:developer';
import 'package:fiwe/src/models/video_room_models.dart';
import 'package:fiwe/src/repositories/rating_repository.dart';
import 'package:fiwe/src/utils/constants.dart';
import 'package:get/get.dart';

class UserRatingController extends GetxController {
  static UserRatingController get instance => Get.find<UserRatingController>();

  final RatingRepository _ratingRepository = Get.find<RatingRepository>();

  // State variables
  final RxList<ParticipantRating> _participantRatings = <ParticipantRating>[].obs;
  final RxBool _isSubmitting = false.obs;
  final RxBool _hasError = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxString _roomParticipationId = ''.obs;
  final RxBool _globalAnonymous = false.obs;

  // Getters
  List<ParticipantRating> get participantRatings => _participantRatings.toList();
  bool get isSubmitting => _isSubmitting.value;
  bool get hasError => _hasError.value;
  String get errorMessage => _errorMessage.value;
  bool get globalAnonymous => _globalAnonymous.value;
  
  // Observable getters for UI
  RxList<ParticipantRating> get participantRatingsObservable => _participantRatings;
  RxBool get isSubmittingObservable => _isSubmitting;

  /// Initialize ratings from participants list
  void initializeRatings(List<Participant> participants, String roomId) {
    try {
      _roomParticipationId.value = roomId;
      _participantRatings.clear();
      
      // Filter out local participant (user shouldn't rate themselves)
      final otherParticipants = participants.where((p) => !p.isLocal).toList();
      
      for (final participant in otherParticipants) {
        final rating = ParticipantRating.fromParticipant(participant);
        _participantRatings.add(rating);
      }
      
      _clearError();
      log('Initialized ratings for ${_participantRatings.length} participants', name: 'UserRatingController');
    } catch (e) {
      _setError('Failed to initialize ratings: $e');
      log('Error initializing ratings: $e', name: 'UserRatingController');
    }
  }

  /// Update rating for specific participant
  void updateParticipantRating(String userId, int score) {
    try {
      final rating = _participantRatings.firstWhereOrNull((r) => r.userId == userId);
      if (rating != null) {
        rating.updateRating(score);
        _clearError();
      }
    } catch (e) {
      _setError('Failed to update rating: $e');
    }
  }

  /// Update feedback for specific participant
  void updateParticipantFeedback(String userId, String feedback) {
    try {
      final rating = _participantRatings.firstWhereOrNull((r) => r.userId == userId);
      if (rating != null) {
        rating.updateFeedback(feedback);
        _clearError();
      }
    } catch (e) {
      _setError('Failed to update feedback: $e');
    }
  }

  /// Toggle anonymous mode for specific participant
  void toggleParticipantAnonymous(String userId) {
    try {
      final rating = _participantRatings.firstWhereOrNull((r) => r.userId == userId);
      if (rating != null) {
        rating.toggleAnonymous();
      }
    } catch (e) {
      _setError('Failed to toggle anonymous mode: $e');
    }
  }

  /// Toggle global anonymous mode
  void toggleGlobalAnonymous() {
    _globalAnonymous.value = !_globalAnonymous.value;
    // Apply to all participants
    for (final rating in _participantRatings) {
      rating.isAnonymous.value = _globalAnonymous.value;
    }
  }

  /// Validate all ratings before submission
  bool validateAllRatings() {
    final invalidRatings = _participantRatings.where((r) => !r.isValid).toList();
    
    if (invalidRatings.isNotEmpty) {
      _setError('Please provide ratings for all participants');
      return false;
    }
    
    _clearError();
    return true;
  }

  /// Submit all ratings to backend
  Future<void> submitAllRatings() async {
    if (_isSubmitting.value) return;
    
    try {
      _isSubmitting.value = true;
      _clearError();

      // Validate ratings first
      if (!validateAllRatings()) {
        return;
      }

      // Convert to submission format
      final submissions = _participantRatings
          .map((rating) => rating.toSubmissionJson(_roomParticipationId.value))
          .toList();

      // Submit to backend
      final success = await _ratingRepository.submitRatings(submissions);
      
      if (success) {
        // Navigate back to home with success message
        Get.offAllNamed(Constants.homeViewRoute);
        Get.snackbar(
          'Success', 
          'Thank you for your feedback!',
          snackPosition: SnackPosition.BOTTOM,
        );
        
        log('Successfully submitted ${submissions.length} ratings', name: 'UserRatingController');
      } else {
        _setError('Failed to submit ratings. Please try again.');
      }
    } catch (e) {
      _setError('An error occurred while submitting ratings: $e');
      log('Error submitting ratings: $e', name: 'UserRatingController');
    } finally {
      _isSubmitting.value = false;
    }
  }

  /// Get count of completed ratings
  int get completedRatingsCount {
    return _participantRatings.where((r) => r.isValid).length;
  }

  /// Get total ratings count
  int get totalRatingsCount => _participantRatings.length;

  /// Check if all ratings are completed
  bool get allRatingsCompleted => completedRatingsCount == totalRatingsCount;

  /// Clear error state
  void _clearError() {
    _hasError.value = false;
    _errorMessage.value = '';
  }

  /// Set error state
  void _setError(String message) {
    _hasError.value = true;
    _errorMessage.value = message;
  }

  /// Reset controller state
  void resetController() {
    _participantRatings.clear();
    _roomParticipationId.value = '';
    _isSubmitting.value = false;
    _globalAnonymous.value = false;
    _clearError();
  }

  @override
  void onClose() {
    resetController();
    super.onClose();
  }
}