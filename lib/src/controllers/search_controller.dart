import 'package:get/get.dart';

class SearchController extends GetxController {
  var searchText = ''.obs;
  var searchList = [].obs;

  // implement deboune
  void search(String value) {
    debounce(searchText, (value) {
      searchText.value = value;
    }, time: const Duration(milliseconds: 500));
  }

  @override
  void onInit() {
    searchText.listen((value) {});
    super.onInit();
  }

  void queryResult(String query) {
    // TODO: implement queryResult
  }
}
