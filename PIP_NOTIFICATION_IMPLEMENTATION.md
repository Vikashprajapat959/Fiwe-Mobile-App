# PIP Support & Persistent Notification Implementation

This document describes the implementation of Picture-in-Picture (PIP) mode support and persistent local notifications for video room functionality in the Fiwe Flutter application using the 100ms HMS Room Kit.

## 📋 Features Implemented

### ✅ Picture-in-Picture (PIP) Support
- **Android**: Automatic PIP entry on app minimize (API 26-30), system-managed for Android 12+
- **iOS**: Manual PIP activation with camera access entitlements
- **Integration**: Seamless HMS Room Kit integration with native PIP controllers
- **State Management**: Real-time PIP state tracking and lifecycle management

### ✅ Persistent Notifications
- **Foreground Service**: Continuous notification during active video calls
- **Real-time Updates**: Live duration tracking and participant count
- **Platform Actions**: Android notification actions for mute/unmute and leave call
- **Crash Recovery**: Service survives app crashes with state restoration

### ✅ Duration Tracking
- **Accurate Timing**: Second-level precision with automatic formatting
- **Multiple Formats**: MM:SS for calls under 1 hour, H:MM:SS for longer calls
- **Persistent State**: Duration continues during app backgrounding

### ✅ Room State Monitoring
- **HMS Integration**: Full HMS Room Kit event listening and state tracking
- **Participant Management**: Real-time participant join/leave detection
- **Connection Status**: Network quality and connection state monitoring
- **Media State**: Microphone and camera state tracking

## 🏗️ Architecture Overview

### Service Architecture
```
VideoRoomController
├── PipManagerService          # PIP mode management
├── VideoRoomNotificationService  # Persistent notifications
└── RoomStateMonitorService    # HMS event monitoring
```

### Data Flow
```
HMS Room Kit Events → RoomStateMonitorService → NotificationService/PipManager → UI Updates
```

## 📁 File Structure

### Core Services
- `lib/src/services/pip_manager_service.dart` - PIP functionality management
- `lib/src/services/video_room_notification_service.dart` - Notification handling
- `lib/src/services/room_state_monitor_service.dart` - HMS event monitoring
- `lib/src/services/video_room_service_registry.dart` - Service registration

### Models
- `lib/src/models/video_room_models.dart` - Data models for room state

### Controllers & Views
- `lib/src/controllers/video_room_controller.dart` - Updated with PIP/notification integration
- `lib/src/views/video_room/video_room_view.dart` - Enhanced UI with PIP controls

### Platform Configuration
- `android/app/src/main/kotlin/com/app/fiwe/MainActivity.kt` - Android PIP handling
- `android/app/src/main/AndroidManifest.xml` - Android PIP permissions (already configured)
- `ios/Runner/Runner.entitlements` - iOS multitasking camera access entitlement

## 🚀 Usage Guide

### Service Registration

Add this to your app initialization (main.dart or dependency injection setup):

```dart
import 'package:fiwe/src/services/video_room_service_registry.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Register video room services
  await VideoRoomServiceRegistry.registerServices();
  await VideoRoomServiceRegistry.initializeServices();
  
  runApp(MyApp());
}
```

### Manual PIP Control

```dart
final controller = Get.find<VideoRoomController>();

// Enter PIP mode manually
await controller.enterPipMode();

// Exit PIP mode
await controller.exitPipMode();

// Check PIP status
bool isInPip = controller.isPipActive;
```

### Notification Management

Notifications are automatically managed by the `VideoRoomController`:

```dart
// Notifications start automatically when joining a room
await controller.createRoom(title, topicId, randomTopic);

// Notifications stop automatically when leaving
await controller.leaveRoom();

// Check notification status
bool hasNotification = controller.hasActiveNotification;
```

### Room State Monitoring

```dart
final monitor = Get.find<RoomStateMonitorService>();

// Get current participants
List<Participant> participants = monitor.participants;

// Get room duration
String? duration = monitor.getFormattedDuration();

// Get monitoring info
Map<String, dynamic> info = monitor.getMonitoringInfo();
```

## 🔧 Platform Configuration

### Android Setup

The Android configuration is already complete:

1. **Manifest Permissions**: `android:supportsPictureInPicture="true"` ✅
2. **MainActivity**: Enhanced with PIP state tracking and notification handling ✅
3. **Auto-PIP**: Automatic entry on minimize for supported Android versions ✅

### iOS Setup

1. **Entitlements**: Added `com.apple.developer.avfoundation.multitasking-camera-access` ✅
2. **Info.plist**: Background modes already configured ✅
3. **Manual PIP**: User-initiated PIP through UI controls ✅

**Note**: The iOS multitasking camera access entitlement requires Apple approval for production apps.

## 🎛️ Configuration Options

### Notification Update Frequency
Default: 5 seconds. Modify in `VideoRoomNotificationService`:

```dart
foregroundTaskOptions: ForegroundTaskOptions(
  eventAction: ForegroundTaskEventAction.repeat(5000), // 5 seconds
  ...
),
```

### PIP Aspect Ratio
Configured in HMS Room Kit. Default: 9:16 for portrait video calls.

### Duration Timer Precision
Default: 1 second updates. Modify in `RoomStateMonitorService`:

```dart
_durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
  // Update frequency
});
```

## 🐛 Debug Features

### Debug Information
Access comprehensive debug info in development:

```dart
final controller = Get.find<VideoRoomController>();
Map<String, dynamic> debugInfo = controller.getDebugInfo();
```

### Debug UI
The VideoRoomView includes a debug button (debug mode only) that shows:
- Current room state
- PIP status
- Notification status
- Participant count
- Service states

### Logging
All services include comprehensive logging with the `dart:developer` log function:

```
[PipManagerService] PIP initialized for room: room_123
[VideoRoomNotificationService] Notification started for room: Meeting Room
[RoomStateMonitorService] Participant joined: John Doe
```

## 🧪 Testing

### Manual Testing Steps

1. **PIP Testing**:
   - Join a video room
   - Minimize the app (Android: home button, iOS: home gesture)
   - Verify PIP window appears with video content
   - Tap PIP window to return to full screen

2. **Notification Testing**:
   - Join a video room
   - Verify persistent notification appears
   - Check duration updates (every 5 seconds)
   - Test notification actions (Android only)
   - Minimize app and verify notification persists

3. **Crash Recovery Testing**:
   - Join a video room
   - Force-kill the app
   - Verify notification remains visible
   - Tap notification to restart app

### Integration Testing

Test the complete flow:
1. Start video call → Services activate
2. Minimize app → PIP mode + notification active
3. Return to app → PIP deactivates, notification continues
4. Leave call → All services clean up

## 🔍 Troubleshooting

### Common Issues

1. **PIP not working on Android**:
   - Check Android version (requires API 26+)
   - Verify `supportsPictureInPicture="true"` in manifest
   - Check if device supports PIP

2. **iOS PIP not available**:
   - Verify iOS 15+ requirement
   - Check entitlements are properly configured
   - Ensure Apple approval for camera access (production)

3. **Notifications not appearing**:
   - Check notification permissions
   - Verify foreground service configuration
   - Check if battery optimization is disabled

4. **Services not initializing**:
   - Ensure `VideoRoomServiceRegistry.registerServices()` is called
   - Check GetX dependency injection
   - Verify service imports

### Log Analysis

Enable verbose logging and check for:
- Service registration confirmations
- HMS event callbacks
- PIP state changes
- Notification updates

## 📈 Performance Considerations

### Resource Usage
- **Battery**: Optimized with 5-second update intervals
- **Memory**: Efficient cleanup on room exit
- **CPU**: Minimal overhead with event-driven updates
- **Network**: No additional network usage

### Scalability
- Single active room session per device
- Maximum 1 notification update per 5 seconds
- Automatic cleanup prevents memory leaks

## 🔒 Security & Privacy

- **Camera Access**: Only active during video calls
- **Microphone**: Controlled by HMS Room Kit
- **Background Processing**: Limited to call duration tracking
- **Data Storage**: Minimal state persistence for crash recovery

## 🔄 Future Enhancements

Potential improvements for future versions:
1. **Multi-room Support**: Handle multiple concurrent calls
2. **Enhanced PIP Controls**: More media controls in PIP mode
3. **Smart Notifications**: AI-powered notification content
4. **Analytics Integration**: Usage metrics and performance tracking
5. **Custom PIP UI**: Branded PIP interface
6. **Advanced Background Modes**: More sophisticated background behavior

## 📚 Related Documentation

- [HMS Flutter SDK Documentation](https://www.100ms.live/docs/flutter/v2/foundation/basics)
- [Android PIP Guide](https://developer.android.com/develop/ui/views/picture-in-picture)
- [iOS PIP Implementation](https://developer.apple.com/documentation/avkit/adopting_picture_in_picture_in_a_custom_player)
- [Flutter Foreground Tasks](https://pub.dev/packages/flutter_foreground_task)

---

This implementation provides a robust foundation for PIP and persistent notification functionality in video calling applications, with comprehensive error handling, logging, and platform-specific optimizations.