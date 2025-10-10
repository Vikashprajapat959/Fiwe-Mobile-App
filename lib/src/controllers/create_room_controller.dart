import 'package:fiwe/src/controllers/auth_controller.dart';
import 'package:fiwe/src/controllers/video_room_controller.dart';
import 'package:fiwe/src/models/topic.model.dart';
import 'package:fiwe/src/services/topic_service.dart';
import 'package:get/get.dart';

class CreateRoomController extends GetxController {
  final topicService = Get.find<TopicService>();
  final videoRoomController = Get.find<VideoRoomController>();
  final authController = Get.find<AuthController>();

  // Section 1: Topics/Interests
  var topics = <Topic>[].obs;
  var selectedTopicId = ''.obs;
  var showAllTopics = false.obs;
  final int maxChipsToShow = 5;

  // Section 2: Room Name
  var roomName = ''.obs;

  // Section 3: Tabs
  var currentTab = 0.obs; // 0 for Description, 1 for Random

  // Section 4: Content based on tab selection
  var description = ''.obs;
  var randomText = ''.obs;

  // Computed properties
  List<Topic> get displayedTopics {
    if (showAllTopics.value) {
      return topics;
    }
    return topics.take(maxChipsToShow).toList();
  }

  String get selectedTabText {
    return currentTab.value == 0 ? description.value : randomText.value;
  }

  bool get showShowMoreButton {
    return topics.length > maxChipsToShow;
  }

  Future<void> createRoom() async {
    // Create a room with the selected topic, room name, and content
    await videoRoomController.createRoom(roomName(), selectedTopicId(), randomText());
  }

  bool isTopicSelected(String topicId) {
    return selectedTopicId() == topicId;
  }
 
  // Initialize with sample topics (in a real app, this would come from a service)
  @override
  void onInit() {
    super.onInit();
    // Sample topics for demonstration
    _loadTopics();
    currentTab.listen((index) {
      if (index == 1) {
        getRandomTopic();
      }
    });
  }

  Future<void> _loadTopics() async {
    try {
      final response = await topicService.getAllTopics();
      if (response.success) {
        topics.value = response.data ?? <Topic>[];
        //  sort topics based on user topics followed
        final userTopicIds = authController.userProfile()?.topics?.map((t) => t.id).toSet() ?? <dynamic>{};
        topics.sort((a, b) {
          final aFollowed = userTopicIds.contains(a.id);
          final bFollowed = userTopicIds.contains(b.id);
          if (aFollowed && !bFollowed) return -1;
          if (!aFollowed && bFollowed) return 1;
          return 0;
        });
      } else {
        Get.snackbar('Error', response.message, snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load topics: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  void setCurrentTab(int index) {
    currentTab.value = index;
  }

  void setDescription(String text) {
    description.value = text;
  }

  void setRandomText(String text) {
    randomText.value = text;
  }

  void setRoomName(String name) {
    roomName.value = name;
  }

  void toggleShowAllTopics() {
    showAllTopics.value = !showAllTopics.value;
  }

  // Methods
  void toggleTopicSelection(String topicId) {
    if (selectedTopicId.value == topicId) {
      selectedTopicId.value = '';
    } else {
      selectedTopicId.value = topicId;
    }
  }

  Future<void> getRandomTopic() async {
    try {
      final response = await topicService.getRandomTopic(
        topics.firstWhereOrNull((t) => t.id == selectedTopicId())?.title ?? '',
      );
      if (response.success) {
        randomText.value = response.data ?? 'Discuss anything!';
      } else {
        Get.snackbar('Error', response.message, snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch random topic: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }
}
