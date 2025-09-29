import 'dart:developer' as developer;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:fiwe/firebase_options.dart';
import 'package:fiwe/src/controllers/user_rating_controller.dart';
import 'package:fiwe/src/repositories/rating_repository.dart';
import 'package:fiwe/src/repositories/room_repository.dart';
import 'package:fiwe/src/services/forground_handler.dart';
import 'package:fiwe/src/services/http_service.dart';
import 'package:fiwe/src/services/topic_service.dart';
import 'package:fiwe/src/services/user_service.dart';
import 'package:fiwe/src/services/video_room_service_registry.dart';
import 'package:fiwe/src/utils/colors.dart';
import 'package:fiwe/src/views/home/create_room_view.dart';
import 'package:fiwe/src/views/home/home_view.dart';
import 'package:fiwe/src/views/interest/interest_selection_view.dart';
import 'package:fiwe/src/views/login/login_view.dart';
import 'package:fiwe/src/views/login/signup_view.dart';
import 'package:fiwe/src/views/login/splash_view.dart';
import 'package:fiwe/src/views/profile/profile_view.dart';
import 'package:fiwe/src/views/rating/user_rating_screen.dart';
import 'package:fiwe/src/views/video_room/video_room_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'src/controllers/video_room_controller.dart';
import 'src/services/badge_service.dart';
import 'src/services/crashlytics_service.dart';
import 'src/services/deep_link_service.dart';
// Import notification services
import 'src/services/fcm_notification_service.dart';
import 'src/services/hms_room_service.dart';
import 'src/services/permission_service.dart';
import 'src/utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Crashlytics
  await CrashlyticsService.initialize();

  // Force crashlytics to be non-fatal in debug mode
  if (!kReleaseMode) {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
  }

  // Initialize notification services
  await _initializeServices();

  // Initialize 100ms SDK
  await _initializeHMS();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const FiweApp());
}

@pragma('vm:entry-point')
// Foreground callback
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
    developer.log('100ms SDK initialized successfully', name: 'HMS');
  } catch (e, stackTrace) {
    developer.log(
      'Error initializing 100ms SDK: $e',
      name: 'HMS',
      error: e,
      stackTrace: stackTrace,
    );
    CrashlyticsService.recordError(e, stackTrace);
  }
}

/// Initialize all services
Future<void> _initializeServices() async {
  try {
    developer.log('Initializing services...', name: 'Main');
    
    // Initialize video room services first (PIP, notifications, monitoring)
    await VideoRoomServiceRegistry.registerServices();
    await VideoRoomServiceRegistry.initializeServices();
    
    // Register other core services with GetX dependency injection
    Get.put(FCMNotificationService(), permanent: true);
    Get.put(HttpService(), permanent: true);
    Get.put(BadgeService(), permanent: true);
    Get.put(UserService(), permanent: true);
    Get.lazyPut<TopicService>(() => TopicService());
    Get.put(PermissionService(), permanent: true);
    Get.put(HMSRoomService(), permanent: true);
    Get.lazyPut(() => RoomRepository());
    Get.lazyPut(() => RatingRepository());
    Get.put(VideoRoomController(), permanent: true);
    Get.lazyPut(() => UserRatingController());
    Get.put(DeepLinkService(), permanent: true);
    
    // Initialize foreground task permissions
    await _initializeForegroundTask();
    
    developer.log('All services initialized successfully', name: 'Main');
  } catch (e, stackTrace) {
    developer.log(
      'Error initializing services: $e',
      name: 'Main',
      error: e,
      stackTrace: stackTrace,
    );
    CrashlyticsService.recordError(e, stackTrace);
    // Don't rethrow - allow app to continue with limited functionality
  }
}

/// Initialize foreground task for notifications
Future<void> _initializeForegroundTask() async {
  try {
    // Request notification permissions first
    await FlutterForegroundTask.requestIgnoreBatteryOptimization();
    
    // Initialize with proper configuration for persistent notifications
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'fiwe_video_room',
        channelName: 'Video Room Service',
        channelDescription: 'Persistent notification for active video calls - cannot be dismissed',
        channelImportance: NotificationChannelImportance.HIGH,
        priority: NotificationPriority.HIGH,
        showWhen: true,
        enableVibration: false,
        playSound: false,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(5000), // Update every 5 seconds
        autoRunOnBoot: false,
        allowWakeLock: true,
        allowWifiLock: false,
      ),
    );
    
    developer.log(
      'Foreground task initialized with persistent notification settings',
      name: 'Main',
    );
  } catch (e, stackTrace) {
    developer.log(
      'Error initializing foreground task: $e',
      name: 'Main',
      error: e,
      stackTrace: stackTrace,
    );
    CrashlyticsService.recordError(e, stackTrace);
  }
}

class FiweApp extends StatelessWidget {
  const FiweApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Fiwe',
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: ThemeMode.system,
      home: const SplashView(),
      getPages: _buildRoutes(),
      onUnknownRoute: _handleUnknownRoute,
      initialRoute: '/',
    );
  }

  /// Build light theme with Material 3 design
  ThemeData _buildLightTheme() {
    return ThemeData.from(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.interTextTheme(),
    );
  }

  /// Build dark theme with Material 3 design
  ThemeData _buildDarkTheme() {
    return ThemeData.from(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
      ),
      textTheme: GoogleFonts.interTextTheme(),
    );
  }

  /// Build application routes
  List<GetPage> _buildRoutes() {
    return [
      GetPage(name: '/', page: () => const SplashView()),
      GetPage(name: Constants.homeViewRoute, page: () => const HomeView()),
      GetPage(name: Constants.loginViewRoute, page: () => const LoginView()),
      GetPage(name: Constants.signUpViewRoute, page: () => const SignUpView()),
      GetPage(
        name: Constants.interestSelectionViewRoute,
        page: () => const InterestSelectionView(),
      ),
      GetPage(
        name: Constants.videoRoomRoute,
        page: () => const VideoRoomView(),
      ),
      GetPage(
        name: Constants.createRoomRoute,
        page: () => const CreateRoomView(),
      ),
      GetPage(
        name: Constants.userRatingRoute,
        page: () => const UserRatingScreen(),
      ),
      GetPage(
        name: Constants.profileScreenRoute,
        page: () => const ProfileScreen(),
      ),
    ];
  }

  /// Handle unknown routes
  GetPageRoute _handleUnknownRoute(RouteSettings settings) {
    return GetPageRoute(
      settings: settings,
      page: () => const HomeView(), // Default fallback
    );
  }
}
