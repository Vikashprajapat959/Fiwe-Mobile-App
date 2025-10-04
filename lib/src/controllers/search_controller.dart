import 'dart:async';
import 'dart:developer';

import 'package:fiwe/src/models/user_model.dart';
import 'package:fiwe/src/services/http_service.dart';
import 'package:fiwe/src/utils/endpoints.dart';
import 'package:fiwe/src/utils/loading_overlay.dart';
import 'package:fiwe/src/views/profile/user_profile_view.dart';
import 'package:get/get.dart';

class SearchController extends GetxController {
  final HttpService httpService = HttpService.instance;

  var searchText = ''.obs;
  var searchResult = <_UserSearchResult>[].obs;

  Timer? _debounceTimer;

  // implement debounce
  void search(String value) {
    // Cancel previous timer if exists
    _debounceTimer?.cancel();

    searchText.value = value;

    // Don't query if search is empty
    if (value.isEmpty) {
      searchResult.value = [];
      return;
    }

    // Set new timer
    _debounceTimer = Timer(const Duration(milliseconds: 1000), () {
      queryResult(value);
    });
  }

  @override
  void onInit() {
    searchText.listen((value) {
      if (value.isEmpty) {
        searchResult.value = [];
        return;
      }
    });
    super.onInit();
  }

  void queryResult(String query) {
    log(query);
    if (query.isEmpty) {
      return;
    }
    httpService
        .get(Endpoints.search, queryParams: {'query': query}, isAuthorized: true)
        .then((response) {
          searchResult.value = response.data != null
              ? List.from(response.data!['items'].map((e) => _UserSearchResult.fromJson(e)).toList())
              : [];
        })
        .catchError((error) {
          log(error.toString(), name: 'SearchController');
        });
  }

  void fetchUser(String id) {
    LoadingOverlay.show();
    httpService
        .get('${Endpoints.users}/$id', isAuthorized: true)
        .then((response) {
          LoadingOverlay.hide();
          final user = User.fromJson(response.data!);
          if (user.id != null) {
            Get.to(() => UserProfileScreen(user: user));
          }
        })
        .catchError((error) {
          LoadingOverlay.hide();
          log(error.toString(), name: 'SearchController');
        });
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }
}

// ignore: unused_element
class _UserSearchResult {
  _UserSearchResult({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.profileImageBase64,
  });

  factory _UserSearchResult.fromJson(Map<String, dynamic> json) {
    return _UserSearchResult(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      profileImageBase64: json['profile_image_base64'],
    );
  }
  final String id;
  final String? name;
  final String? email;
  final String? phoneNumber;
  final String? profileImageBase64;
}
