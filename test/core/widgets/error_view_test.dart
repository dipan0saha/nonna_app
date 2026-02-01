import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/widgets/error_view.dart';

void main() {
  group('ErrorView', () {
    testWidgets('displays error message', (tester) async {
      const errorMessage = 'Something went wrong';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorView(message: errorMessage),
          ),
        ),
      );

      expect(find.text(errorMessage), findsOneWidget);
    });

    testWidgets('displays default title when not specified', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorView(message: 'Error message'),
          ),
        ),
      );

      expect(find.text('Error'), findsOneWidget);
    });

    testWidgets('displays custom title when specified', (tester) async {
      const customTitle = 'Custom Error';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorView(
              message: 'Error message',
              title: customTitle,
            ),
          ),
        ),
      );

      expect(find.text(customTitle), findsOneWidget);
    });

    testWidgets('displays error icon by default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorView(message: 'Error message'),
          ),
        ),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('displays custom icon when specified', (tester) async {
      const customIcon = Icons.warning;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorView(
              message: 'Error message',
              icon: customIcon,
            ),
          ),
        ),
      );

      expect(find.byIcon(customIcon), findsOneWidget);
    });

    testWidgets('shows retry button when onRetry is provided', (tester) async {
      var retryTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorView(
              message: 'Error message',
              onRetry: () => retryTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Retry'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);

      await tester.tap(find.text('Retry'));
      expect(retryTapped, isTrue);
    });

    testWidgets('hides retry button when onRetry is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorView(message: 'Error message'),
          ),
        ),
      );

      expect(find.text('Retry'), findsNothing);
    });

    testWidgets('is centered on screen', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorView(message: 'Error message'),
          ),
        ),
      );

      final center = find.ancestor(
        of: find.byType(Column),
        matching: find.byType(Center),
      );

      expect(center, findsOneWidget);
    });

    testWidgets('uses error color from theme', (tester) async {
      const errorColor = Colors.red;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: const ColorScheme.light(error: errorColor),
          ),
          home: const Scaffold(
            body: ErrorView(message: 'Error message'),
          ),
        ),
      );

      final icon = tester.widget<Icon>(
        find.byIcon(Icons.error_outline),
      );

      expect(icon.color, equals(errorColor));
    });

    testWidgets('retry button invokes callback when tapped', (tester) async {
      var callCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorView(
              message: 'Error message',
              onRetry: () => callCount++,
            ),
          ),
        ),
      );

      // Tap on the retry text (which is inside the button)
      await tester.tap(find.text('Retry'));
      expect(callCount, equals(1));

      await tester.tap(find.text('Retry'));
      expect(callCount, equals(2));
    });
  });

  group('InlineErrorView', () {
    testWidgets('displays error message', (tester) async {
      const errorMessage = 'Inline error message';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InlineErrorView(message: errorMessage),
          ),
        ),
      );

      expect(find.text(errorMessage), findsOneWidget);
    });

    testWidgets('displays error icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InlineErrorView(message: 'Error'),
          ),
        ),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('shows retry button when onRetry is provided', (tester) async {
      var retryTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InlineErrorView(
              message: 'Error',
              onRetry: () => retryTapped = true,
            ),
          ),
        ),
      );

      final refreshIcon = find.byIcon(Icons.refresh);
      expect(refreshIcon, findsOneWidget);

      await tester.tap(refreshIcon);
      expect(retryTapped, isTrue);
    });

    testWidgets('hides retry button when onRetry is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InlineErrorView(message: 'Error'),
          ),
        ),
      );

      final refreshIcon = find.byIcon(Icons.refresh);
      expect(refreshIcon, findsNothing);
    });

    testWidgets('displays in a container with border', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InlineErrorView(message: 'Error'),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.byType(Container).first,
      );

      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
      expect(decoration.borderRadius, isNotNull);
    });

    testWidgets('uses Row layout', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InlineErrorView(message: 'Error'),
          ),
        ),
      );

      expect(find.byType(Row), findsOneWidget);
    });

    testWidgets('retry button invokes callback', (tester) async {
      var callCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InlineErrorView(
              message: 'Error',
              onRetry: () => callCount++,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.refresh));
      expect(callCount, equals(1));
    });
  });
}
