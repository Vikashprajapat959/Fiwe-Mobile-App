import 'dart:ui';

import 'package:fiwe/src/models/topic.model.dart';
import 'package:fiwe/src/services/topic_service.dart';
import 'package:fiwe/src/services/user_service.dart';
import 'package:fiwe/src/views/home/home_view.dart';
import 'package:get/get.dart';

/// Controller for managing interest selection screen state and logic
class InterestSelectionController extends GetxController {
  final selectedTopicIds = <String>[].obs;

  final primaryTopicSelection = "".obs;

  final pageIndex = 0.obs;

  final TopicService _topicService = TopicService();
  final UserService _userService = UserService();

  Map<String, List<Topic>> topicsByCategories = {};

  var topics = <Topic>[];

  final selectedCategories = <String>[].obs;

  List<String> get selectedTopics => selectedTopicIds.toList();

  Future<List<Topic>> getAllTopics() async {
    return await _topicService.getAllTopics();
  }

  List<Topic> getSelectedTopics() {
    return topics.where((topic) => selectedTopicIds.contains(topic.id)).toList();
  }

  bool isPrimarySelected(String topicID) {
    return primaryTopicSelection() == topicID;
  }

  // bool isCategorySelected(String category) {
  //   return selectedCategories.contains(category);
  // }

  bool isTopicSelected(String topicId) {
    return selectedTopicIds.contains(topicId);
  }

  Future<List<Topic>> loadTopics() async {
    try {
      if (topics.isEmpty) {
        final topicsFromService = await _topicService.getAllTopics();
        topics = topicsFromService;
        return topics;
      } else {
        return topics;
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load topics: ${e.toString()}");
      rethrow;
    }
  }

  VoidCallback? onContinue() {
    if (selectedTopicIds().length < 5) {
      Get.snackbar("Error", "You must select at least 5 topics");
      return null;
    } else {
      return updateUserInterests;
    }
  }

  // void toggleSlectionCategory(String category) {
  //   if (selectedCategories.contains(category)) {
  //     selectedCategories.remove(category);
  //   } else {
  //     if (selectedCategories.length >= 5) {
  //       Get.snackbar("Error", "You can only select up to 5 categories");
  //       return;
  //     }
  //     selectedCategories.add(category);
  //   }
  // }

  void toggleTopic(String topicId) {
    // can only select 5 topics
    if (selectedTopicIds.contains(topicId)) {
      selectedTopicIds.remove(topicId);
    } else {
      if (selectedTopicIds.length >= 5) {
        Get.snackbar("Error", "You can only select up to 5 topics");
        return;
      }
      selectedTopicIds.add(topicId);
    }
  }

  void updateUserInterests() {
    _userService.followTopics(selectedTopicIds()).then((success) {
      if (success) {
        Get.offAll(() => HomeView());
      } else {
        Get.snackbar("Error", "Something went wrong");
      }
    });
  }
}
