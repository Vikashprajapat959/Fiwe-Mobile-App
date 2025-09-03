import 'package:firebase_core/firebase_core.dart';
import 'package:fiwe/firebase_options.dart';
import 'package:fiwe/src/views/home/home_view.dart';
import 'package:fiwe/src/views/interest/interest_selection_view.dart';
import 'package:fiwe/src/views/login/login_view.dart';
import 'package:fiwe/src/views/login/signup_view.dart';
import 'package:fiwe/src/views/login/splash_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'src/controllers/notification_controller.dart';
import 'src/services/badge_service.dart';
import 'src/services/global_notification_overlay_service.dart';
// Import notification services
import 'src/services/notification_service.dart';
import 'src/utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize notification services
  await _initializeServices();

  runApp(const FiweApp());
}

/// Initialize all services
Future<void> _initializeServices() async {
  // Register services with GetX dependency injection
  Get.put(BadgeService(), permanent: true);
  Get.put(NotificationService(), permanent: true);
  Get.put(GlobalNotificationOverlayService(), permanent: true);
  Get.put(NotificationController(), permanent: true);
}

class FiweApp extends StatelessWidget {
  const FiweApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(textTheme: GoogleFonts.interTextTheme(), useMaterial3: true),
      home: SplashView(),
      // Define named routes
      getPages: [
        GetPage(name: '/', page: () => SplashView()),
        GetPage(name: Constants.homeViewRoute, page: () => const HomeView()),
        GetPage(name: Constants.loginViewRoute, page: () => const LoginView()),
        GetPage(name: Constants.signUpViewRoute, page: () => const SignUpView()),
        GetPage(name: Constants.interestSelectionViewRoute, page: () => const InterestSelectionView()),
      ],
      // Fallback route generation for unknown routes
      onUnknownRoute: (settings) {
        return GetPageRoute(
          settings: settings,
          page: () => const HomeView(), // Default fallback
        );
      },
      // Initial route
      initialRoute: '/',
    );
  }
}
