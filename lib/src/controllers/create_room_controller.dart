import 'package:fiwe/src/controllers/video_room_controller.dart';
import 'package:fiwe/src/models/topic.model.dart';
import 'package:fiwe/src/services/topic_service.dart';
import 'package:get/get.dart';

class CreateRoomController extends GetxController {
  final topicService = Get.find<TopicService>();
  final videoRoomController = Get.find<VideoRoomController>();

  // Section 1: Topics/Interests
  var topics = <Topic>[].obs;
  var selectedTopicId = "".obs;
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
  }

  Future<void> _loadTopics() async {
    try {
      final response = await topicService.getAllTopics();
      if (response.success) {
        topics.value = response.data ?? <Topic>[];
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
      selectedTopicId.value = "";
    } else {
      selectedTopicId.value = topicId;
    }
  }
}