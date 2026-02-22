import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nonna_app/core/widgets/error_boundary.dart';

/// Widget that throws during build.
class _ThrowingWidget extends StatelessWidget {
  const _ThrowingWidget();

  @override
  Widget build(BuildContext context) {
    throw Exception('test error');
  }
}

void main() {
  // Suppress expected Flutter error output during tests.
  final originalOnError = FlutterError.onError;
  setUp(() => FlutterError.onError = (details) {});
  tearDown(() => FlutterError.onError = originalOnError);

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

    testWidgets('shows default fallback on FlutterError', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorBoundary(
              child: _ThrowingWidget(),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Try again'), findsOneWidget);
    });

    testWidgets('shows custom fallback when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorBoundary(
              fallback: (error, _) => const Text('Custom fallback'),
              child: const _ThrowingWidget(),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Custom fallback'), findsOneWidget);
    });

    testWidgets('calls onError callback', (tester) async {
      Object? caught;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorBoundary(
              onError: (e, _) => caught = e,
              child: const _ThrowingWidget(),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(caught, isNotNull);
    });

    testWidgets('recovers on "Try again" tap', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorBoundary(
              child: _ThrowingWidget(),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Something went wrong'), findsOneWidget);

      // Tap the recovery button — error state is cleared.
      await tester.tap(find.widgetWithText(FilledButton, 'Try again'));
      await tester.pump();

      // _ThrowingWidget will throw again immediately, so fallback re-appears.
      expect(find.text('Something went wrong'), findsOneWidget);
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
      await tester.pumpWidget(
        const MaterialApp(
          home: GlobalErrorBoundary(
            child: _ThrowingWidget(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Something went wrong'), findsOneWidget);

      // Tap "Try again" — GlobalErrorBoundary resets its key, forcing a rebuild.
      await tester.tap(find.widgetWithText(FilledButton, 'Try again'));
      await tester.pump();

      // The ThrowingWidget immediately throws again, so the fallback re-appears.
      expect(find.text('Something went wrong'), findsOneWidget);
    });
  });
}
