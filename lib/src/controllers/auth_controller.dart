import 'package:fiwe/src/services/google_auth_service.dart';
import 'package:fiwe/src/services/shared_pref_service.dart';
import 'package:fiwe/src/utils/constants.dart';
import 'package:fiwe/src/views/home/home_view.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final GoogleAuthService googleAuthService = GoogleAuthService();

  @override
  onInit() {
    googleAuthService.init();
    super.onInit();
  }

  void signInWithGoogle() {
    googleAuthService.signInWithGoogle().then(
      (account) => {
        if (account != null)
          {
            SharedPrefService.setString(
              Constants.loginTokenKey,
              account.authentication.idToken ?? 'inavalid',
            ),
            Get.offAll(() => HomeView()),
          },
      },
    );
  }
}
