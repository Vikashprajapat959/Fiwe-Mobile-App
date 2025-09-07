import 'package:fiwe/src/models/topic.model.dart';
import 'package:fiwe/src/services/topic_service.dart';
import 'package:fiwe/src/services/user_service.dart';
import 'package:fiwe/src/utils/loading_overlay.dart';
import 'package:fiwe/src/views/home/home_view.dart';
import 'package:flutter/widgets.dart';
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

  final PageController pageController = PageController();

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
      return () => Get.snackbar("Error", "You must select at least 5 topics");
    } else if (selectedTopicIds().length == 5 && primaryTopicSelection() == "") {
      return () {
        pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeIn);
        pageIndex(1);
      };
    } else {
      return updateUserInterests;
    }
  }

  void previousPage() {
    pageController.previousPage(duration: Duration(milliseconds: 300), curve: Curves.easeIn);
    pageIndex(0);
  }

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

  void updateUserInterests() async {
    var success = await executeWithLoading(_userService.followTopics(selectedTopicIds(), primaryTopicSelection()));

    if (success) {
      Get.offAll(() => HomeView());
    } else {
      Get.snackbar("Error", "Something went wrong");
    }
  }
}
