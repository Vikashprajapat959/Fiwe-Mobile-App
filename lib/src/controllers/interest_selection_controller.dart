import 'package:fiwe/src/models/topic.model.dart';
import 'package:fiwe/src/services/topic_service.dart';
import 'package:get/get.dart';

/// Controller for managing interest selection screen state and logic
class InterestSelectionController extends GetxController {
  final selectedInterests = <String>[].obs;

  Future<List<Topic>> getAllInterests() async {
    return await TopicService().getAllTopics();
  }

  void toggleInterest(String interest) {
    if (selectedInterests.contains(interest)) {
      selectedInterests.remove(interest);
    } else {
      selectedInterests.add(interest);
    }
  }
}
