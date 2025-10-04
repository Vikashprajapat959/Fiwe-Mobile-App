import 'package:fiwe_notification/fiwe_notification.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'In-App Notification Demo', home: const MyHomePage());
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('In-App Notification Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Show a simple notification
                InAppNotificationManager.setContext(context).show(
                  NotificationConfig(
                    title: "Success!",
                    description: "Your action was completed successfully.",
                    icon: const Icon(Icons.check_circle, color: Colors.green),
                    duration: const Duration(seconds: 5),
                    metadata: {"type": "success", "id": "123"},
                  ),
                );
              },
              child: const Text('Show Success Notification'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Show notification with actions
                InAppNotificationManager.setContext(context).show(
                  NotificationConfig(
                    title: "New Message",
                    description: "You have a new message from John.",
                    icon: const Icon(Icons.message),
                    actions: [
                      NotificationAction(label: "View", onPressed: () => print("View message")),
                      NotificationAction(label: "Dismiss", onPressed: () => InAppNotificationManager.dismiss()),
                    ],
                    duration: const Duration(seconds: 10),
                  ),
                );
              },
              child: const Text('Show Notification with Actions'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Show notification without auto-dismiss
                InAppNotificationManager.setContext(context).show(
                  NotificationConfig(
                    title: "Important Notice",
                    description: "This notification will stay until dismissed.",
                    icon: const Icon(Icons.info, color: Colors.blue),
                    onDismiss: () => print("Notification dismissed"),
                  ),
                );
              },
              child: const Text('Show Persistent Notification'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Dismiss the current notification
                InAppNotificationManager.dismiss();
              },
              child: const Text('Dismiss Current Notification'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Dismiss all notifications
                InAppNotificationManager.dismissAll();
              },
              child: const Text('Dismiss All Notifications'),
            ),
          ],
        ),
      ),
    );
  }
}
