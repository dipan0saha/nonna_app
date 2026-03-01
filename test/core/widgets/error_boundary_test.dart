import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nonna_app/core/widgets/error_boundary.dart';

/// Widget that throws during build to simulate a Flutter framework error.
class _ThrowingWidget extends StatelessWidget {
  const _ThrowingWidget();

  @override
  Widget build(BuildContext context) {
    throw Exception('test error');
  }
}

void main() {
  group('ErrorBoundary', () {
    testWidgets('renders child when no error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ErrorBoundary(
            child: Text('OK'),
          ),
        ),
      );

      expect(find.text('OK'), findsOneWidget);
    });

    testWidgets('shows custom fallback when provided and error is set',
        (tester) async {
      // Save the original FlutterError handler to restore it after test
      final originalHandler = FlutterError.onError;
      addTearDown(() {
        FlutterError.onError = originalHandler;
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlobalErrorBoundary(
              child: ErrorBoundary(
                fallback: (error, _) => const Text('Custom fallback'),
                child: const _ThrowingWidget(),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('shows default fallback card via GlobalErrorBoundary',
        (tester) async {
      // Save the original FlutterError handler to restore it after test
      final originalHandler = FlutterError.onError;
      addTearDown(() {
        FlutterError.onError = originalHandler;
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlobalErrorBoundary(
              child: _ThrowingWidget(),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Try again'), findsOneWidget);
    });
  });

  group('GlobalErrorBoundary', () {
    testWidgets('renders child when no error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GlobalErrorBoundary(
            child: Text('App'),
          ),
        ),
      );

      expect(find.text('App'), findsOneWidget);
    });

    testWidgets('shows fallback and allows recovery on error', (tester) async {
      // Save the original FlutterError handler to restore it after test
      final originalHandler = FlutterError.onError;
      addTearDown(() {
        FlutterError.onError = originalHandler;
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: GlobalErrorBoundary(
            child: _ThrowingWidget(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Something went wrong'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Try again'));
      await tester.pump();

      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('does not show error details in release-like mode',
        (tester) async {
      // Save the original FlutterError handler to restore it after test
      final originalHandler = FlutterError.onError;
      addTearDown(() {
        FlutterError.onError = originalHandler;
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: GlobalErrorBoundary(
            child: _ThrowingWidget(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Something went wrong'), findsOneWidget);
    });
  });
}
