import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/widgets/offline_indicator.dart';

void main() {
  group('OfflineIndicator', () {
    // -------------------------------------------------------------------------
    // Visibility
    // -------------------------------------------------------------------------

    group('Visibility', () {
      testWidgets('renders nothing when online (isOffline = false)',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: OfflineIndicator(isOffline: false),
            ),
          ),
        );

        expect(find.byType(Container), findsNothing);
        expect(find.byIcon(Icons.wifi_off), findsNothing);
      });

      testWidgets('renders banner when offline (isOffline = true)',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: OfflineIndicator(isOffline: true),
            ),
          ),
        );

        expect(find.byIcon(Icons.wifi_off), findsOneWidget);
      });
    });

    // -------------------------------------------------------------------------
    // Offline message
    // -------------------------------------------------------------------------

    group('Messages', () {
      testWidgets('shows default offline message', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: OfflineIndicator(isOffline: true),
            ),
          ),
        );

        expect(find.text('No internet connection'), findsOneWidget);
      });

      testWidgets('shows custom offline message', (tester) async {
        const customMessage = 'You are offline';
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: OfflineIndicator(
                isOffline: true,
                message: customMessage,
              ),
            ),
          ),
        );

        expect(find.text(customMessage), findsOneWidget);
      });

      testWidgets('shows syncMessage when isSyncing is true', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: OfflineIndicator(
                isOffline: true,
                isSyncing: true,
              ),
            ),
          ),
        );

        expect(find.text('Syncing data…'), findsOneWidget);
      });

      testWidgets('shows custom syncMessage when isSyncing is true',
          (tester) async {
        const customSync = 'Uploading changes…';
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: OfflineIndicator(
                isOffline: true,
                isSyncing: true,
                syncMessage: customSync,
              ),
            ),
          ),
        );

        expect(find.text(customSync), findsOneWidget);
      });
    });

    // -------------------------------------------------------------------------
    // Retry button
    // -------------------------------------------------------------------------

    group('Retry button', () {
      testWidgets('shows retry button when onRetry is provided and not syncing',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: OfflineIndicator(
                isOffline: true,
                onRetry: () {},
              ),
            ),
          ),
        );

        expect(find.text('Retry'), findsOneWidget);
      });

      testWidgets('retry button is hidden when isSyncing is true',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: OfflineIndicator(
                isOffline: true,
                isSyncing: true,
                onRetry: () {},
              ),
            ),
          ),
        );

        expect(find.text('Retry'), findsNothing);
      });

      testWidgets('retry button is hidden when onRetry is null',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: OfflineIndicator(isOffline: true),
            ),
          ),
        );

        expect(find.text('Retry'), findsNothing);
      });

      testWidgets('tapping retry button calls onRetry callback',
          (tester) async {
        var retryCount = 0;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: OfflineIndicator(
                isOffline: true,
                onRetry: () => retryCount++,
              ),
            ),
          ),
        );

        await tester.tap(find.text('Retry'));
        expect(retryCount, equals(1));
      });
    });

    // -------------------------------------------------------------------------
    // Syncing indicator
    // -------------------------------------------------------------------------

    group('Syncing indicator', () {
      testWidgets('shows progress spinner when isSyncing is true',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: OfflineIndicator(
                isOffline: true,
                isSyncing: true,
              ),
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('hides progress spinner when isSyncing is false',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: OfflineIndicator(isOffline: true),
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsNothing);
      });
    });

    // -------------------------------------------------------------------------
    // Colours
    // -------------------------------------------------------------------------

    group('Colours', () {
      testWidgets('uses default red background', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: OfflineIndicator(isOffline: true),
            ),
          ),
        );

        final container = tester.widget<Container>(
          find
              .ancestor(
                of: find.byIcon(Icons.wifi_off),
                matching: find.byType(Container),
              )
              .first,
        );

        expect(container.color, isNotNull);
      });

      testWidgets('respects custom backgroundColor', (tester) async {
        const customBg = Colors.blue;
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: OfflineIndicator(
                isOffline: true,
                backgroundColor: customBg,
              ),
            ),
          ),
        );

        final container = tester.widget<Container>(
          find
              .ancestor(
                of: find.byIcon(Icons.wifi_off),
                matching: find.byType(Container),
              )
              .first,
        );

        expect(container.color, equals(customBg));
      });
    });
  });

  // ---------------------------------------------------------------------------
  // StreamOfflineIndicator
  // ---------------------------------------------------------------------------

  group('StreamOfflineIndicator', () {
    testWidgets('shows banner when stream emits false', (tester) async {
      final controller = StreamController<bool>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StreamOfflineIndicator(
              connectivityStream: controller.stream,
              initiallyOnline: true,
            ),
          ),
        ),
      );

      // Initially online – no banner
      expect(find.byIcon(Icons.wifi_off), findsNothing);

      // Emit offline
      controller.add(false);
      await tester.pump();

      expect(find.byIcon(Icons.wifi_off), findsOneWidget);

      await controller.close();
    });

    testWidgets('hides banner when stream emits true after offline',
        (tester) async {
      final controller = StreamController<bool>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StreamOfflineIndicator(
              connectivityStream: controller.stream,
              initiallyOnline: false,
            ),
          ),
        ),
      );

      // Initially offline
      controller.add(false);
      await tester.pump();
      expect(find.byIcon(Icons.wifi_off), findsOneWidget);

      // Come back online
      controller.add(true);
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.wifi_off), findsNothing);

      await controller.close();
    });

    testWidgets('shows syncing indicator when syncStatusStream emits true',
        (tester) async {
      final connectController = StreamController<bool>();
      final syncController = StreamController<bool>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StreamOfflineIndicator(
              connectivityStream: connectController.stream,
              syncStatusStream: syncController.stream,
              initiallyOnline: false,
            ),
          ),
        ),
      );

      connectController.add(false);
      syncController.add(true);
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await connectController.close();
      await syncController.close();
    });

    testWidgets('calls onRetry when retry button is tapped', (tester) async {
      final controller = StreamController<bool>();
      var retried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StreamOfflineIndicator(
              connectivityStream: controller.stream,
              initiallyOnline: false,
              onRetry: () => retried = true,
            ),
          ),
        ),
      );

      controller.add(false);
      await tester.pump();

      await tester.tap(find.text('Retry'));
      expect(retried, isTrue);

      await controller.close();
    });

    testWidgets('respects custom message', (tester) async {
      final controller = StreamController<bool>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StreamOfflineIndicator(
              connectivityStream: controller.stream,
              initiallyOnline: false,
              message: 'Device is offline',
            ),
          ),
        ),
      );

      controller.add(false);
      await tester.pump();

      expect(find.text('Device is offline'), findsOneWidget);

      await controller.close();
    });
  });
}
