import 'dart:developer';

import 'package:fiwe/src/models/standard_api_response.dart';
import 'package:fiwe/src/repositories/commune_repository.dart';
import 'package:fiwe/src/utils/loading_overlay.dart';
import 'package:get/get.dart';

class CommuneController extends GetxController {
  final communeRequestSent = <CommuneRequestSent>[].obs;
  final CommuneRepository communeRepository = CommuneRepository.instance;
  @override
  void onInit() {
    communeRepository
        .getAllSentRequests()
        .then((value) {
          final result = value.data;
          if (result != null) {
            final List<CommuneRequestSent> requests = List.from(
              result['items'],
            ).map((json) => CommuneRequestSent.fromJson(json)).toList();
            communeRequestSent(requests.where((r) => r.status == 'pending').toList());
          }

          communeRequestSent.refresh();
        })
        .catchError((error) {
          log(error.toString());
        });
    super.onInit();
  }

  bool isRequestSent(String userId) {
    log('isRequestSent $userId');
    log(communeRequestSent.length.toString());
    return communeRequestSent.any((request) => request.toUser.id == userId);
  }

  Future<void> sendCommuneRequest(String userId) async {
    LoadingOverlay.show();
    try {
      final result = await communeRepository.sendRequest(userId.toString());
      if (result.data != null) {
        communeRequestSent.add(CommuneRequestSent.fromJson(result.data!['commune_request']));
      }
    } on Exception catch (e) {
      // TODO
    } finally {
      LoadingOverlay.hide();
    }
  }

  Future<void> cancelRequest(String userId) async {
    LoadingOverlay.show();
    final requestId = communeRequestSent.firstWhere((element) => element.toUser.id == userId).id;
    final res = await communeRepository.cancelCommuneRequest(requestId);

    if (res.success) {
      communeRequestSent.removeWhere((r) => r.id == requestId);
      update();
    }
    LoadingOverlay.hide();
  }

  Future<ApiResponse<List<CommuneSummary>>> getAllCommunes() async {
    try {
      final result = await communeRepository.getAllCommunes();
      return result;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  // get al commune requests
  Future<ApiResponse<List<CommuneSummary>>> getAllRequests() async {
    try {
      final result = await communeRepository.getAllCommuneRequests();
      return result;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}

class CommuneRequestSent {
  CommuneRequestSent({
    required this.id,
    required this.status,
    required this.createdAt,
    required this.fromUser,
    required this.toUser,
  });
  factory CommuneRequestSent.fromJson(Map<String, dynamic> json) {
    return CommuneRequestSent(
      id: json['id'],
      status: json['status'],
      createdAt: json['created_at'],
      fromUser: CommuneUser.fromJson(json['from_user']),
      toUser: CommuneUser.fromJson(json['to_user']),
    );
  }
  String id;
  String status;
  String createdAt;
  CommuneUser fromUser;
  CommuneUser toUser;
}

class CommuneUser {
  CommuneUser(this.id, this.name, this.email, this.profileImageBase64);
  factory CommuneUser.fromJson(Map<String, dynamic> json) {
    return CommuneUser(json['id'], json['name'], json['email'], json['profile_image_base64']);
  }
  String id;
  String name;
  String email;
  String? profileImageBase64;
}
