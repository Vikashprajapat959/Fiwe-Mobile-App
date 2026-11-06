// Controller
import 'package:fiwe/src/controllers/auth_controller.dart';
import 'package:fiwe/src/models/user_model.dart';
import 'package:fiwe/src/utils/extensions.dart';
import 'package:fiwe/src/views/profile/edit_profile_view.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  // Profile data
  final AuthController authController = Get.find<AuthController>();
  // Stats
  var totalRoomsCreated = 5.obs;
  var joinedRooms = 2.obs;
  var faceOfWeek = 2.obs;
  var totalCommence = 7.obs;
  var followers = 9.obs;
  var audiences = 50.obs;
  var toppedRooms = 3.obs;

  void editProfile() {
    Get.to(() => const EditProfileScreen());
  }

  void logout() {
    Get.snackbar('Logout', 'Logging out...');
  }

  void openAvailability() {
    Get.snackbar('Availability', 'Opening availability settings');
  }

  void openCommunes() {
    Get.snackbar('Communes', 'Opening communes');
  }

  void openPreferences() {
    Get.snackbar('Preferences', 'Opening preferences');
  }

  double get profileCompletion {
    double completion = 0;
    final User? user = authController.userProfile();
    if (user != null) {
      if (!user.name.isNullOrEmpty) completion += 14.28;
      if (!user.nickName.isNullOrEmpty) completion += 14.28;
      if (!user.bio.isNullOrEmpty) completion += 14.28;
      if (!user.profileBase64.isNullOrEmpty) completion += 14.28;
      if (!user.email.isNullOrEmpty) completion += 14.28;
      if (!user.dateOfBirth.isNullOrEmpty) completion += 14.28;
      if (!user.pincode.isNullOrEmpty) completion += 14.28;
    }
    return completion;
  }
}
