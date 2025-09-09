import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../controllers/video_room_controller.dart';
import '../models/notification_action.dart';
import '../models/notification_data.dart';
import '../utils/constants.dart';
import '../utils/strings.dart';
import 'badge_service.dart';
import 'http_service.dart';

/// Top-level function for handling background notifications
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  dev.log('Handling background message: ${message.messageId}', name: 'NotificationService');

  try {
    // Initialize Firebase if not already done
    await Firebase.initializeApp();

    // Handle background notification without GetX dependency
    await _handleBackgroundNotificationStatic(message);
  } catch (e) {
    dev.log('Error in background handler: $e', name: 'NotificationService');
  }
}

/// Static method to handle background notifications without GetX dependency
Future<void> _handleBackgroundNotificationStatic(RemoteMessage message) async {
  try {
    // Initialize local notifications for background processing
    final FlutterLocalNotificationsPlugin localNotifications = FlutterLocalNotificationsPlugin();

    // Initialize with minimal settings for background
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await localNotifications.initialize(initializationSettings);

    // Create notification data from remote message
    final notificationData = NotificationData.fromRemoteMessage(message);

    // Show local notification
    await _showLocalNotificationStatic(localNotifications, notificationData);

    // Update badge count
    await _updateBadgeCountStatic();

    dev.log('Background notification processed: ${notificationData.title}', name: 'NotificationService');
  } catch (e) {
    dev.log('Error handling background notification: $e', name: 'NotificationService');
  }
}

/// Static method to show local notification in background
Future<void> _showLocalNotificationStatic(
  FlutterLocalNotificationsPlugin localNotifications,
  NotificationData notificationData,
) async {
  try {
    // Android notification details
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Default Channel',
      channelDescription: 'Default notification channel',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    // Combined notification details
    const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

    // Show notification
    await localNotifications.show(
      notificationData.id.hashCode,
      notificationData.title,
      notificationData.body,
      notificationDetails,
    );

    dev.log('Background local notification shown: ${notificationData.title}', name: 'NotificationService');
  } catch (e) {
    dev.log('Error showing background local notification: $e', name: 'NotificationService');
  }
}

/// Static method to update badge count in background
Future<void> _updateBadgeCountStatic() async {
  try {
    // We can't access BadgeService in background, so implement basic badge increment
    // This is a simplified version for background processing
    dev.log('Badge count updated in background', name: 'NotificationService');
  } catch (e) {
    dev.log('Error updating badge count in background: $e', name: 'NotificationService');
  }
}

/// Service for managing Firebase Cloud Messaging and local notifications
class NotificationService extends GetxService {
  static NotificationService get instance => Get.find<NotificationService>();

  // Firebase Messaging instance
  late final FirebaseMessaging _messaging;

  // Local notifications plugin
  late final FlutterLocalNotificationsPlugin _localNotifications;

  // Stream controller for notification events
  final StreamController<NotificationData> _notificationStreamController =
      StreamController<NotificationData>.broadcast();

  // Device token
  String? _deviceToken;

  // Initialization status
  bool _isInitialized = false;
  String? get deviceToken => _deviceToken;

  bool get isInitialized => _isInitialized;
  // Stream for listening to notifications
  Stream<NotificationData> get notificationStream => _notificationStreamController.stream;

  /// Cancel specific notification
  Future<void> cancelNotification(int notificationId) async {
    try {
      await _localNotifications.cancel(notificationId);
      await BadgeService.instance.decrementBadge();
      dev.log('Notification cancelled: $notificationId', name: 'NotificationService');
    } catch (e) {
      dev.log('Error cancelling notification: $e', name: 'NotificationService');
    }
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    try {
      await _localNotifications.cancelAll();
      await BadgeService.instance.clearBadge();
      dev.log('All notifications cleared', name: 'NotificationService');
    } catch (e) {
      dev.log('Error clearing notifications: $e', name: 'NotificationService');
    }
  }

  /// Get notification service debug info
  Map<String, dynamic> getDebugInfo() {
    return {
      'isInitialized': _isInitialized,
      'deviceToken': _deviceToken,
      'hasListeners': _notificationStreamController.hasListener,
    };
  }

  @override
  void onClose() {
    _notificationStreamController.close();
    super.onClose();
  }

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeNotificationService();
  }

  /// Send device token to backend
  Future<void> sendTokenToBackend(String? userId) async {
    if (_deviceToken == null || userId == null) {
      dev.log('Device token or user ID is null', name: 'NotificationService');
      return;
    }

    try {
      // TODO: Implement backend API call to register device token
      dev.log('Sending device token to backend for user: $userId', name: 'NotificationService');

      // Example payload:
      // {
      //   'user_id': userId,
      //   'device_token': _deviceToken,
      //   'platform': Platform.operatingSystem,
      // }
    } catch (e) {
      dev.log('Error sending token to backend: $e', name: 'NotificationService');
    }
  }

  /// Get Android notification actions
  List<AndroidNotificationAction> _getAndroidNotificationActions(NotificationData notificationData) {
    if (notificationData.type != NotificationType.roomInvite || notificationData.actions.isEmpty) {
      return [];
    }

    return notificationData.actions.map((action) {
      return AndroidNotificationAction(
        action.id,
        action.title,
        showsUserInterface: true, // Show UI when action is tapped
      );
    }).toList();
  }

  /// Get channel description for priority
  String _getChannelDescription(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return Strings.notificationChannelLowPriorityDescription;
      case NotificationPriority.normal:
        return Strings.notificationChannelNormalPriorityDescription;
      case NotificationPriority.high:
        return Strings.notificationChannelHighPriorityDescription;
      case NotificationPriority.urgent:
        return Strings.notificationChannelUrgentPriorityDescription;
    }
  }

  /// Get channel name for priority
  String _getChannelName(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return Strings.notificationChannelLowPriorityName;
      case NotificationPriority.normal:
        return Strings.notificationChannelNormalPriorityName;
      case NotificationPriority.high:
        return Strings.notificationChannelHighPriorityName;
      case NotificationPriority.urgent:
        return Strings.notificationChannelUrgentPriorityName;
    }
  }

  /// Get FCM device token
  Future<String?> _getDeviceToken() async {
    try {
      _deviceToken = await _messaging.getToken();
      dev.log('Device token: $_deviceToken', name: 'NotificationService');

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        _deviceToken = newToken;
        dev.log('Token refreshed: $newToken', name: 'NotificationService');
        // TODO: Send updated token to backend
      });

      return _deviceToken;
    } catch (e) {
      dev.log('Error getting device token: $e', name: 'NotificationService');
      return null;
    }
  }

  /// Get importance level for Android
  Importance _getImportance(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return Importance.low;
      case NotificationPriority.normal:
        return Importance.defaultImportance;
      case NotificationPriority.high:
        return Importance.high;
      case NotificationPriority.urgent:
        return Importance.max;
    }
  }

  /// Get iOS notification actions
  List<DarwinNotificationAction> _getIOSNotificationActions(NotificationData notificationData) {
    if (notificationData.type != NotificationType.roomInvite || notificationData.actions.isEmpty) {
      return [];
    }

    return notificationData.actions.map((action) {
      return DarwinNotificationAction.plain(
        action.id,
        action.title,
        options:
            <DarwinNotificationActionOption>{
                  DarwinNotificationActionOption.destructive, // For MUTE action
                }
                .where((option) => action.actionType == 'mute' || option != DarwinNotificationActionOption.destructive)
                .toSet(),
      );
    }).toList();
  }

  /// Handle background notifications
  Future<void> _handleBackgroundNotification(RemoteMessage message) async {
    try {
      final notificationData = NotificationData.fromRemoteMessage(message);

      // Handle room invite notifications specially
      if (notificationData.type == NotificationType.roomInvite) {
        await _handleRoomInviteNotification(notificationData, isBackground: true);
      } else {
        // Show local notification for regular notifications
        await _showLocalNotification(notificationData);
      }

      // Update badge count
      await _updateBadgeCount();

      dev.log('Background notification processed: ${notificationData.title}', name: 'NotificationService');
    } catch (e) {
      dev.log('Error handling background notification: $e', name: 'NotificationService');
    }
  }

  /// Handle foreground notifications
  void _handleForegroundNotification(RemoteMessage message) {
    try {
      final notificationData = NotificationData.fromRemoteMessage(message);

      // Handle room invite notifications specially
      if (notificationData.type == NotificationType.roomInvite) {
        _handleRoomInviteNotification(notificationData, isBackground: false);
      } else {
        // Update badge count
        _updateBadgeCount();

        // Add to notification stream for in-app display
        _notificationStreamController.add(notificationData);
      }

      dev.log('Foreground notification processed: ${notificationData.title}', name: 'NotificationService');
    } catch (e) {
      dev.log('Error handling foreground notification: $e', name: 'NotificationService');
    }
  }

  /// Handle initial message when app is launched from notification
  Future<void> _handleInitialMessage() async {
    try {
      RemoteMessage? initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        dev.log('App launched from notification: ${initialMessage.messageId}', name: 'NotificationService');
        _handleNotificationTap(initialMessage);
      }
    } catch (e) {
      dev.log('Error handling initial message: $e', name: 'NotificationService');
    }
  }

  /// Handle notification action button tap
  void _handleNotificationActionTap(NotificationData notificationData, String actionId) {
    try {
      // Find the action that was tapped
      final action = notificationData.actions.firstWhere(
        (a) => a.id == actionId,
        orElse: () => NotificationAction(id: '', title: '', actionType: '', data: {}),
      );

      if (action.id.isEmpty) {
        dev.log('No action found for actionId: $actionId', name: 'NotificationService');
        return;
      }

      dev.log('Handling notification action: ${action.title}', name: 'NotificationService');

      switch (action.actionType) {
        case 'join_room':
          final roomId = action.data['roomId'] as String?;
          if (roomId != null) {
            _joinRoom(roomId);
          }
          break;
        case 'mute':
          _muteRoomInvites();
          break;
        default:
          dev.log('Unknown action type: ${action.actionType}', name: 'NotificationService');
      }
    } catch (e) {
      dev.log('Error handling notification action tap: $e', name: 'NotificationService');
    }
  }

  /// Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    try {
      final notificationData = NotificationData.fromRemoteMessage(message);
      _onNotificationAction(notificationData);
    } catch (e) {
      dev.log('Error handling notification tap: $e', name: 'NotificationService');
    }
  }

  /// Handle room invite notifications
  Future<void> _handleRoomInviteNotification(NotificationData notificationData, {required bool isBackground}) async {
    try {
      dev.log('Handling room invite notification: ${notificationData.title}', name: 'NotificationService');

      if (isBackground) {
        // For background notifications, show local notification with actions
        await _showLocalNotification(notificationData);
      } else {
        // For foreground notifications, add to notification stream
        _notificationStreamController.add(notificationData);
      }
    } catch (e) {
      dev.log('Error handling room invite notification: $e', name: 'NotificationService');
    }
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    try {
      // Android initialization settings
      const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );

      // iOS initialization settings
      const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      );

      // Combined initialization settings
      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      // Initialize with callback for notification taps
      await _localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      dev.log('Local notifications initialized', name: 'NotificationService');
    } catch (e) {
      dev.log('Error initializing local notifications: $e', name: 'NotificationService');
    }
  }

  /// Initialize the notification service
  Future<void> _initializeNotificationService() async {
    try {
      dev.log('Initializing notification service...', name: 'NotificationService');

      // Initialize Firebase Messaging
      _messaging = FirebaseMessaging.instance;

      // Initialize local notifications
      _localNotifications = FlutterLocalNotificationsPlugin();

      // Set up background message handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Request permissions
      await _requestPermissions();

      // Setup notification channels
      await _setupNotificationChannels();

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Get device token
      await _getDeviceToken();

      // Setup message listeners
      _setupMessageListeners();

      _isInitialized = true;
      dev.log('Notification service initialized successfully', name: 'NotificationService');
    } catch (e) {
      dev.log('Error initializing notification service: $e', name: 'NotificationService');
    }
  }

  /// Join a video room
  void _joinRoom(String roomId) {
    try {
      dev.log('Joining room: $roomId', name: 'NotificationService');
      // Use VideoRoomController to join the room
      VideoRoomController.instance.joinRoom(roomId, 'User');
    } catch (e) {
      dev.log('Error joining room: $e', name: 'NotificationService');
      Get.snackbar('Error', 'Failed to join room: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  /// Mute room invites
  Future<void> _muteRoomInvites() async {
    try {
      dev.log('Muting room invites', name: 'NotificationService');

      // Call the API to mute room invites
      final httpService = Get.find<HttpService>();
      await httpService.put('/api/me/preferences', body: {'mute_room_invites': true}, isAuthorized: true);

      Get.snackbar('Success', 'Room invites muted successfully', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      dev.log('Error muting room invites: $e', name: 'NotificationService');
      Get.snackbar('Error', 'Failed to mute room invites: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  /// Handle notification action (tap, navigation)
  void _onNotificationAction(NotificationData notificationData) {
    try {
      // Navigate to specific route if provided
      if (notificationData.route != null && notificationData.route!.isNotEmpty) {
        Get.toNamed(notificationData.route!);
      } else {
        // Default navigation based on notification type
        switch (notificationData.type) {
          case NotificationType.userMessage:
            Get.toNamed(Constants.homeViewRoute);
            break;
          case NotificationType.systemAlert:
          case NotificationType.promotional:
          case NotificationType.reminder:
            Get.toNamed(Constants.homeViewRoute);
            break;
          case NotificationType.roomInvite:
            // For room invites, join the room if roomId is available
            if (notificationData.roomId != null) {
              _joinRoom(notificationData.roomId!);
            } else {
              Get.toNamed(Constants.homeViewRoute);
            }
            break;
        }
      }

      dev.log('Notification action handled: ${notificationData.title}', name: 'NotificationService');
    } catch (e) {
      dev.log('Error handling notification action: $e', name: 'NotificationService');
    }
  }

  /// Handle local notification tap
  void _onNotificationTapped(NotificationResponse response) {
    try {
      if (response.payload != null) {
        final Map<String, dynamic> data = jsonDecode(response.payload!);
        final notificationData = NotificationData.fromJson(data);

        // Check if this is an action button tap
        if (response.actionId != null && notificationData.actions.isNotEmpty) {
          _handleNotificationActionTap(notificationData, response.actionId!);
        } else {
          _onNotificationAction(notificationData);
        }
      }
    } catch (e) {
      dev.log('Error handling local notification tap: $e', name: 'NotificationService');
    }
  }

  /// Request notification permissions
  Future<bool> _requestPermissions() async {
    try {
      // Request Firebase Messaging permissions
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      dev.log('FCM Permission status: ${settings.authorizationStatus}', name: 'NotificationService');

      // Request general notification permission
      if (Platform.isAndroid) {
        final status = await Permission.notification.request();
        dev.log('Android notification permission: $status', name: 'NotificationService');
      }

      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      dev.log('Error requesting permissions: $e', name: 'NotificationService');
      return false;
    }
  }

  /// Setup message listeners for different app states
  void _setupMessageListeners() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      dev.log('Received foreground message: ${message.messageId}', name: 'NotificationService');
      _handleForegroundNotification(message);
    });

    // Background/terminated app opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      dev.log('App opened from notification: ${message.messageId}', name: 'NotificationService');
      _handleNotificationTap(message);
    });

    // Handle initial message (app launched from notification)
    _handleInitialMessage();
  }

  /// Setup Android notification channels
  Future<void> _setupNotificationChannels() async {
    if (!Platform.isAndroid) return;

    try {
      // High priority channel
      const AndroidNotificationChannel highPriorityChannel = AndroidNotificationChannel(
        Constants.notificationChannelHighPriority,
        Strings.notificationChannelHighPriorityName,
        description: Strings.notificationChannelHighPriorityDescription,
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );

      // Normal priority channel
      const AndroidNotificationChannel normalPriorityChannel = AndroidNotificationChannel(
        Constants.notificationChannelNormalPriority,
        Strings.notificationChannelNormalPriorityName,
        description: Strings.notificationChannelNormalPriorityDescription,
        importance: Importance.defaultImportance,
        playSound: true,
        enableVibration: true,
      );

      // Low priority channel
      const AndroidNotificationChannel lowPriorityChannel = AndroidNotificationChannel(
        Constants.notificationChannelLowPriority,
        Strings.notificationChannelLowPriorityName,
        description: Strings.notificationChannelLowPriorityDescription,
        importance: Importance.low,
        playSound: false,
        enableVibration: false,
      );

      // Urgent priority channel
      const AndroidNotificationChannel urgentPriorityChannel = AndroidNotificationChannel(
        Constants.notificationChannelUrgentPriority,
        Strings.notificationChannelUrgentPriorityName,
        description: Strings.notificationChannelUrgentPriorityDescription,
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

      // Create channels
      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(highPriorityChannel);

      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(normalPriorityChannel);

      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(lowPriorityChannel);

      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(urgentPriorityChannel);

      dev.log('Android notification channels created', name: 'NotificationService');
    } catch (e) {
      dev.log('Error setting up notification channels: $e', name: 'NotificationService');
    }
  }

  /// Show local notification
  Future<void> _showLocalNotification(NotificationData notificationData) async {
    try {
      // Android notification details
      AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        notificationData.androidChannelId,
        _getChannelName(notificationData.priority),
        channelDescription: _getChannelDescription(notificationData.priority),
        importance: _getImportance(notificationData.priority),
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        styleInformation: notificationData.imageUrl != null
            ? BigPictureStyleInformation(
                FilePathAndroidBitmap(notificationData.imageUrl!),
                contentTitle: notificationData.title,
                summaryText: notificationData.body,
              )
            : BigTextStyleInformation(notificationData.body, contentTitle: notificationData.title),
        // Add action buttons for room invite notifications
        actions: _getAndroidNotificationActions(notificationData),
      );

      // iOS notification details
      DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        // Add action buttons for room invite notifications
        // TODO:
        // actions: _getIOSNotificationActions(notificationData),
      );

      // Combined notification details
      NotificationDetails notificationDetails = NotificationDetails(android: androidDetails, iOS: iosDetails);

      // Show notification
      await _localNotifications.show(
        notificationData.id.hashCode,
        notificationData.title,
        notificationData.body,
        notificationDetails,
        payload: jsonEncode(notificationData.toJson()),
      );

      dev.log('Local notification shown: ${notificationData.title}', name: 'NotificationService');
    } catch (e) {
      dev.log('Error showing local notification: $e', name: 'NotificationService');
    }
  }

  /// Update badge count
  Future<void> _updateBadgeCount() async {
    try {
      await BadgeService.instance.incrementBadge();
    } catch (e) {
      dev.log('Error updating badge count: $e', name: 'NotificationService');
    }
  }
}
