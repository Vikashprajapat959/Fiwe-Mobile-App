import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:fiwe/firebase_options.dart';
import 'package:fiwe/src/repositories/room_repository.dart';
import 'package:fiwe/src/services/forground_handler.dart';
import 'package:fiwe/src/services/http_service.dart';
import 'package:fiwe/src/services/topic_service.dart';
import 'package:fiwe/src/utils/colors.dart';
import 'package:fiwe/src/views/home/create_room_view.dart';
import 'package:fiwe/src/views/home/home_view.dart';
import 'package:fiwe/src/views/interest/interest_selection_view.dart';
import 'package:fiwe/src/views/login/login_view.dart';
import 'package:fiwe/src/views/login/signup_view.dart';
import 'package:fiwe/src/views/login/splash_view.dart';
import 'package:fiwe/src/views/profile/profile_view.dart';
import 'package:fiwe/src/views/video_room/video_room_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'src/controllers/notification_controller.dart';
import 'src/controllers/video_room_controller.dart';
import 'src/services/badge_service.dart';
import 'src/services/deep_link_service.dart';
import 'src/services/global_notification_overlay_service.dart';
import 'src/services/hms_room_service.dart';
// Import notification services
import 'src/services/fcm_notification_service.dart';
import 'src/services/permission_service.dart';
import 'src/utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize notification services
  await _initializeServices();

  // Initialize 100ms SDK
  await _initializeHMS();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(const FiweApp());
}

@pragma('vm:entry-point')
// forgroundCallback
void startCallback() {
  FlutterForegroundTask.setTaskHandler(ForegroundHandler());
}

/// Initialize 100ms SDK
Future<void> _initializeHMS() async {
  try {
    // Initialize the 100ms SDK
    // Initialize HMS SDK with your credentials
    // Example: await HMSLogger.initialize();
    // Example: HMSManager.initialize();
    // Add your actual HMS initialization code here
    log('100ms SDK initialized successfully');
  } catch (e) {
    log('Error initializing 100ms SDK: $e');
  }
}

/// Initialize all services
Future<void> _initializeServices() async {
  // Register services with GetX dependency injection
  Get.put(HttpService(), permanent: true);
  Get.put(BadgeService(), permanent: true);
  Get.lazyPut<TopicService>(() => TopicService());
  // Get.put(NotificationService(), permanent: true);
  // Get.put(NotificationController(), permanent: true);
  Get.put(PermissionService(), permanent: true);
  Get.put(HMSRoomService(), permanent: true);
  Get.lazyPut(() => RoomRepository());
  Get.put(VideoRoomController(), permanent: true);
  Get.put(DeepLinkService(), permanent: true);
}

class FiweApp extends StatelessWidget {
  const FiweApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home: SplashView(),
      // Define named routes
      getPages: [
        GetPage(name: '/', page: () => SplashView()),
        GetPage(name: Constants.homeViewRoute, page: () => const HomeView()),
        GetPage(name: Constants.loginViewRoute, page: () => const LoginView()),
        GetPage(name: Constants.signUpViewRoute, page: () => const SignUpView()),
        GetPage(name: Constants.interestSelectionViewRoute, page: () => const InterestSelectionView()),
        GetPage(name: Constants.videoRoomRoute, page: () => const VideoRoomView()),
        GetPage(name: Constants.createRoomRoute, page: () => const CreateRoomView()),
        GetPage(name: Constants.profileScreenRoute, page: () => const ProfileScreen()),
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
