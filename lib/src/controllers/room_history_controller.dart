import 'package:fiwe/src/repositories/room_repository.dart';
import 'package:get/get.dart';

import '../models/room_history.dart';

class RoomHistoryController extends GetxController {
  final RoomRepository _repository = RoomRepository.instance;

  var roomHistory = Rx<RoomHistory>(RoomHistory(rooms: []));
  var isLoading = false.obs;
  var error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRoomHistory();
  }

  Future<void> fetchRoomHistory() async {
    try {
      isLoading.value = true;
      error.value = '';
      final histories = await _repository.getRoomHistory();
      if (histories.success != true) {
        error.value = histories.message;
        return;
      }
      roomHistory(histories.data ?? RoomHistory(rooms: []));
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
