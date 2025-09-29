import 'dart:isolate';

import 'package:fiwe/main.dart';
import 'package:fiwe/src/utils/constants.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

class ForegroundHandler extends TaskHandler {
  SendPort? _sendPort;
  TaskStarter? _starter;
  @override
  Future<void> handleTask(String taskId, Map<String, dynamic> data) async {
    // TODO: Implement foreground task handling logic
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) {
    // TODO: implement onDestroy
    throw UnimplementedError();
  }

  @override
  void onRepeatEvent(DateTime timestamp) {}

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    _starter = starter;
  }

  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp(Constants.videoRoomRoute);

    super.onNotificationPressed();
  }

  Future<void> init() async {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(channelId: 'fiwe.id', channelName: 'fiwe.channel'),
      iosNotificationOptions: const IOSNotificationOptions(),
      foregroundTaskOptions: ForegroundTaskOptions(eventAction: ForegroundTaskEventAction.nothing()),
    );
    FlutterForegroundTask.startService(
      notificationTitle: 'Active Video call',
      notificationText: 'Join video call',
      callback: startCallback,
    );
  }
}
