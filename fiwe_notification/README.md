# Fiwe Notification

An elegant in-app notification system for Flutter applications with smooth animations, stacking support, and extensive customization options.

[![Pub Version](https://img.shields.io/pub/v/fiwe_notification)](https://pub.dev/packages/fiwe_notification)
[![License](https://img.shields.io/github/license/your-username/fiwe_notification)](https://github.com/your-username/fiwe_notification/blob/main/LICENSE)

## Overview

Fiwe Notification is a powerful and customizable in-app notification package for Flutter applications. It provides smooth animations, notification stacking, and a variety of configuration options to create beautiful and functional notifications for your users.

### Key Features

- 🎨 **Beautiful Animations**: Smooth slide-in from top, horizontal swipe dismissal, and configurable auto-dismiss animations
- 📚 **Notification Stacking**: Display multiple notifications with automatic vertical stacking
- ⚙️ **Highly Customizable**: Configure icons, actions, duration, styling, and more
- 🎯 **Easy Integration**: Simple API that integrates seamlessly with your existing Flutter app
- 📱 **Responsive Design**: Works on all device sizes and orientations
- 🧪 **Well Tested**: Comprehensive test coverage for reliability
- 📦 **Lightweight**: Minimal dependencies and optimized performance
- 🎨 **Predefined Styles**: Built-in notification types (info, success, warning, error)

## Installation

Add `fiwe_notification` as a dependency in your `pubspec.yaml` file:

```yaml
dependencies:
  fiwe_notification: ^1.0.0
```

Then run:

```bash
flutter pub get
```

Alternatively, you can add the dependency directly from the command line:

```bash
flutter pub add fiwe_notification
```

### Requirements

- Flutter 1.17.0 or higher
- Dart SDK 3.9.0 or higher

### Compatibility

Fiwe Notification is compatible with:
- Flutter stable, beta, and dev channels
- Android API level 16 and higher
- iOS 9.0 and higher
- Web browsers with CanvasKit rendering
- macOS 10.11 and higher
- Windows 7 and higher
- Linux with GTK 3.0 or higher

## Quick Start

1. Import the package in your Dart file:

```dart
import 'package:fiwe_notification/fiwe_notification.dart';
```

2. Set the context and show a notification:

```dart
InAppNotificationManager.setContext(context).show(
  NotificationConfig(
    title: "Success!",
    description: "Your action was completed successfully.",
    icon: Icon(Icons.check_circle, color: Colors.green),
    duration: Duration(seconds: 5),
  ),
);
```

## Usage Examples

### Simple Notification

Display a basic notification with title and description:

```dart
InAppNotificationManager.setContext(context).show(
  NotificationConfig(
    title: "Welcome!",
    description: "Thanks for using our app.",
    icon: Icon(Icons.info),
    duration: Duration(seconds: 3),
  ),
);
```

### Notification with Actions

Add custom actions to your notifications:

```dart
InAppNotificationManager.setContext(context).show(
  NotificationConfig(
    title: "New Message",
    description: "You have a new message from John.",
    icon: Icon(Icons.message),
    actions: [
      NotificationAction(
        label: "View",
        onPressed: () => Navigator.pushNamed(context, '/messages'),
      ),
      NotificationAction(
        label: "Dismiss",
        onPressed: () => InAppNotificationManager.dismiss(),
        style: NotificationActionStyle.secondary,
      ),
    ],
    duration: Duration(seconds: 10),
  ),
);
```

### Persistent Notification

Create a notification that stays until manually dismissed:

```dart
InAppNotificationManager.setContext(context).show(
  NotificationConfig(
    title: "Important Update",
    description: "Please update your profile information.",
    icon: Icon(Icons.warning, color: Colors.orange),
    onDismiss: () => print("Notification dismissed by user"),
  ),
);
```

### Notification Types

Use predefined notification types for consistent styling:

```dart
// Success notification with green styling
InAppNotificationManager.setContext(context).show(
  NotificationConfig(
    title: "Payment Successful",
    description: "Your payment has been processed.",
    type: NotificationType.success,
    duration: Duration(seconds: 5),
  ),
);

// Error notification with red styling
InAppNotificationManager.setContext(context).show(
  NotificationConfig(
    title: "Connection Failed",
    description: "Unable to connect to the server.",
    type: NotificationType.error,
  ),
);
```

## Notification Management

### Dismissing Notifications

Fiwe Notification provides several methods to manage notifications programmatically:

```dart
// Dismiss the current notification (the topmost one)
InAppNotificationManager.dismiss();

// Dismiss a specific notification by index (useful for stacked notifications)
InAppNotificationManager.dismissAt(0);

// Dismiss all notifications at once
InAppNotificationManager.dismissAll();

// Check if any notifications are currently visible
bool isVisible = InAppNotificationManager.isVisible;
```

## API Reference

### InAppNotificationManager

The main interface for showing and managing notifications:

| Method | Description |
|--------|-------------|
| `setContext(BuildContext context)` | Set the context for notification display |
| `show(NotificationConfig config)` | Show a notification with the provided configuration |
| `dismiss()` | Dismiss the currently visible notification |
| `dismissAt(int index)` | Dismiss a specific notification by index |
| `dismissAll()` | Dismiss all notifications |
| `isVisible` | Check if any notifications are visible |

### NotificationConfig

Configuration object for customizing notification appearance and behavior:

| Property | Type | Description |
|----------|------|-------------|
| `title` | `String` | The title text for the notification (required) |
| `description` | `String?` | The detailed description text |
| `icon` | `Widget?` | Optional icon to display |
| `duration` | `Duration?` | Auto-dismiss duration (null for no auto-dismiss) |
| `metadata` | `Map<String, dynamic>?` | Custom metadata associated with notification |
| `actions` | `List<NotificationAction>?` | Custom action buttons |
| `onDismiss` | `VoidCallback?` | Callback when notification is dismissed |
| `dismissBeforeShow` | `bool` | Dismiss last notification before showing new one |
| `decoration` | `BoxDecoration?` | Custom styling for the notification container |
| `type` | `NotificationType` | Predefined notification type (info, success, warning, error) |
| `enableStacking` | `bool` | Enable/disable notification stacking |

### NotificationAction

Represents a custom action button in a notification:

| Property | Type | Description |
|----------|------|-------------|
| `label` | `String` | Button text |
| `onPressed` | `VoidCallback` | Action to perform when pressed |
| `style` | `NotificationActionStyle` | Visual style (primary or secondary) |

### Notification Types

| Type | Description |
|------|-------------|
| `NotificationType.info` | Informational notification (default) |
| `NotificationType.success` | Success notification with green styling |
| `NotificationType.warning` | Warning notification with orange styling |
| `NotificationType.error` | Error notification with red styling |

## Animations and User Interactions

Fiwe Notification provides smooth and intuitive animations:

- **Slide-in Animation**: Notifications smoothly slide in from the top of the screen
- **Horizontal Dismissal**: Users can swipe left or right to dismiss notifications
- **Auto-dismiss Animation**: Notifications automatically slide up and fade out after the specified duration
- **Stacking Animation**: When multiple notifications are displayed, they stack with smooth transitions

Users can interact with notifications in several ways:

- **Tap to Dismiss**: Click the '✕' button to close the notification
- **Swipe to Dismiss**: Swipe horizontally to dismiss the notification
- **Action Buttons**: Tap on custom action buttons for specific functionality
- **Long Press**: Provides visual feedback through subtle scaling animation

## Performance Considerations

Fiwe Notification is designed with performance in mind:

- **Lightweight**: Minimal impact on app performance
- **Memory Efficient**: Properly disposes of animation controllers and resources
- **Optimized Rendering**: Uses Flutter's built-in animation system for smooth performance
- **Resource Management**: Automatically cleans up when notifications are dismissed

### Best Practices

- Always call `setContext(context)` before showing notifications
- Use appropriate durations for auto-dismissal (3-5 seconds is typically ideal)
- Limit the number of stacked notifications to prevent UI clutter

## Contributing

Contributions are welcome! Here's how you can help:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a pull request

### Development Setup

1. Clone the repository
2. Run `flutter pub get`
3. Run tests with `flutter test`

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

If you have any questions or need help, please [open an issue](https://github.com/your-username/fiwe_notification/issues) on GitHub.