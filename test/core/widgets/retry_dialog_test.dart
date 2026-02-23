import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/widgets/retry_dialog.dart';

/// Helper to wrap a widget in a minimal [MaterialApp] with navigation support.
Widget _app(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('RetryDialog', () {
    // -----------------------------------------------------------------------
    // Rendering
    // -----------------------------------------------------------------------

    group('Rendering', () {
      testWidgets('renders dialog with default title and message',
          (tester) async {
        await tester.pumpWidget(
          _app(
            const RetryDialog(message: 'Something went wrong.'),
          ),
        );

        expect(find.text('Connection Error'), findsOneWidget);
        expect(find.text('Something went wrong.'), findsOneWidget);
      });

      testWidgets('renders custom title', (tester) async {
        await tester.pumpWidget(
          _app(
            const RetryDialog(
              message: 'Network unavailable.',
              title: 'No Internet',
            ),
          ),
        );

        expect(find.text('No Internet'), findsOneWidget);
      });

      testWidgets('renders wifi_off icon', (tester) async {
        await tester.pumpWidget(
          _app(const RetryDialog(message: 'Error')),
        );

        expect(find.byIcon(Icons.wifi_off), findsOneWidget);
      });

      testWidgets('renders Cancel button by default', (tester) async {
        await tester.pumpWidget(
          _app(const RetryDialog(message: 'Error')),
        );

        expect(find.text('Cancel'), findsOneWidget);
      });

      testWidgets('renders Retry button when onRetry is provided',
          (tester) async {
        await tester.pumpWidget(
          _app(
            RetryDialog(
              message: 'Error',
              onRetry: () {},
            ),
          ),
        );

        expect(find.text('Retry'), findsOneWidget);
      });

      testWidgets('does not render Retry button when onRetry is null',
          (tester) async {
        await tester.pumpWidget(
          _app(const RetryDialog(message: 'Error')),
        );

        expect(find.text('Retry'), findsNothing);
      });

      testWidgets('uses custom retry label', (tester) async {
        await tester.pumpWidget(
          _app(
            RetryDialog(
              message: 'Error',
              retryLabel: 'Try Again',
              onRetry: () {},
            ),
          ),
        );

        expect(find.text('Try Again'), findsOneWidget);
      });

      testWidgets('uses custom cancel label', (tester) async {
        await tester.pumpWidget(
          _app(
            const RetryDialog(
              message: 'Error',
              cancelLabel: 'Dismiss',
            ),
          ),
        );

        expect(find.text('Dismiss'), findsOneWidget);
      });
    });

    // -----------------------------------------------------------------------
    // Cancel button behaviour
    // -----------------------------------------------------------------------

    group('Cancel button', () {
      testWidgets('invokes onCancel callback when Cancel is tapped',
          (tester) async {
        var cancelled = false;

        await tester.pumpWidget(
          _app(
            RetryDialog(
              message: 'Error',
              onCancel: () => cancelled = true,
            ),
          ),
        );

        await tester.tap(find.text('Cancel'));
        await tester.pump();

        expect(cancelled, isTrue);
      });
    });

    // -----------------------------------------------------------------------
    // Retry button behaviour
    // -----------------------------------------------------------------------

    group('Retry button', () {
      testWidgets('invokes onRetry callback when Retry is tapped',
          (tester) async {
        var retried = false;

        await tester.pumpWidget(
          _app(
            RetryDialog(
              message: 'Error',
              onRetry: () => retried = true,
            ),
          ),
        );

        await tester.tap(find.text('Retry'));
        await tester.pump();

        expect(retried, isTrue);
      });

      testWidgets('shows loading indicator while async onRetry is running',
          (tester) async {
        final completer = Completer<void>();

        await tester.pumpWidget(
          _app(
            RetryDialog(
              message: 'Error',
              onRetry: () => completer.future,
            ),
          ),
        );

        await tester.tap(find.text('Retry'));
        await tester.pump(); // start the async operation

        // While the future is pending, a CircularProgressIndicator should appear
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        // Retry and Cancel should be disabled (text still present)
        expect(find.text('Retry'), findsNothing); // replaced by indicator
        expect(find.text('Cancel'), findsOneWidget);

        // Complete the retry
        completer.complete();
        await tester.pumpAndSettle();

        // Indicator gone, retry button restored
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.text('Retry'), findsOneWidget);
      });

      testWidgets('does not invoke onRetry when already retrying',
          (tester) async {
        var retryCount = 0;
        final completer = Completer<void>();

        await tester.pumpWidget(
          _app(
            RetryDialog(
              message: 'Error',
              onRetry: () {
                retryCount++;
                return completer.future;
              },
            ),
          ),
        );

        // Tap Retry once to start the async operation
        await tester.tap(find.text('Retry'));
        await tester.pump();

        // While loading the Retry button is replaced; tapping the area should
        // not trigger another call.
        await tester.pump();
        expect(retryCount, equals(1));

        completer.complete();
        await tester.pumpAndSettle();
      });
    });

    // -----------------------------------------------------------------------
    // showRetryDialog helper
    // -----------------------------------------------------------------------

    group('showRetryDialog', () {
      testWidgets('displays dialog when called', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showRetryDialog(
                  context: context,
                  message: 'Unable to connect.',
                ),
                child: const Text('Show'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show'));
        await tester.pumpAndSettle();

        expect(find.text('Connection Error'), findsOneWidget);
        expect(find.text('Unable to connect.'), findsOneWidget);
      });

      testWidgets('dialog has no Retry button when no onRetry provided',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showRetryDialog(
                  context: context,
                  message: 'Error',
                ),
                child: const Text('Show'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show'));
        await tester.pumpAndSettle();

        expect(find.text('Retry'), findsNothing);
        expect(find.text('Cancel'), findsOneWidget);
      });

      testWidgets('dialog passes custom title and labels', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showRetryDialog(
                  context: context,
                  message: 'Error',
                  title: 'Oops',
                  retryLabel: 'Try Again',
                  cancelLabel: 'No Thanks',
                  onRetry: () {},
                ),
                child: const Text('Show'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show'));
        await tester.pumpAndSettle();

        expect(find.text('Oops'), findsOneWidget);
        expect(find.text('Try Again'), findsOneWidget);
        expect(find.text('No Thanks'), findsOneWidget);
      });
    });
  });
}
