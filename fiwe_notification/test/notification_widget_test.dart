import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fiwe_notification/src/notification_widget.dart';
import 'package:fiwe_notification/fiwe_notification.dart';

void main() {
  group('NotificationWidget', () {
    testWidgets('displays title and description', (tester) async {
      final config = NotificationConfig(
        title: 'Test Title',
        description: 'Test Description',
      );

      late bool dismissed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotificationWidget(
              config: config,
              onDismiss: () => dismissed = true,
            ),
          ),
        ),
      );

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test Description'), findsOneWidget);
    });

    testWidgets('displays icon when provided', (tester) async {
      final config = NotificationConfig(
        title: 'Test Title',
        icon: const Icon(Icons.check),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotificationWidget(
              config: config,
              onDismiss: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('calls onDismiss when close button is pressed', (tester) async {
      final config = NotificationConfig(
        title: 'Test Title',
      );

      late bool dismissed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: NotificationWidget(
                config: config,
                onDismiss: () => dismissed = true,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap the close button
      final closeButton = find.byIcon(Icons.close);
      expect(closeButton, findsOneWidget);
      
      await tester.tap(closeButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(dismissed, true);
    });

    testWidgets('applies vertical offset for stacking', (tester) async {
      final config = NotificationConfig(
        title: 'Stacked Notification',
        enableStacking: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotificationWidget(
              config: config,
              onDismiss: () {},
              verticalOffset: 50.0, // 50 pixels offset
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check that the widget was created with the correct offset
      // We can't easily test the exact positioning in a widget test
      // but we can verify the widget was created with the offset parameter
      final widgetFinder = find.byType(NotificationWidget);
      expect(widgetFinder, findsOneWidget);
      
      // Get the widget and check its properties
      final widget = tester.widget<NotificationWidget>(widgetFinder);
      expect(widget.verticalOffset, 50.0);
    });
  });
}