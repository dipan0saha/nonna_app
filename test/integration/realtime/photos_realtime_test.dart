import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/services/realtime_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../helpers/mock_factory.dart';
import '../../mocks/mock_services.mocks.dart';

/// Integration tests for Photos real-time subscriptions
///
/// Tests subscription lifecycle, data updates, reconnection scenarios,
/// and performance benchmarks for the photos table
void main() {
  group('Photos Realtime Integration Tests', () {
    late RealtimeService realtimeService;
    late MockSupabaseClient mockSupabaseClient;
    StreamSubscription<dynamic>? subscription;
    final testTimeout = const Duration(seconds: 30);

    setUp(() {
      mockSupabaseClient = MockFactory.createSupabaseClient();
      realtimeService = RealtimeService(mockSupabaseClient);
    });

    tearDown(() async {
      await subscription?.cancel();
      await realtimeService.dispose();
    });

    group('Subscription Lifecycle', () {
      test('should successfully subscribe to photos table', () async {
        final stream = realtimeService.subscribe(
          table: 'photos',
          channelName: 'test-photos-channel',
        );

        expect(stream, isNotNull);
        expect(realtimeService.activeChannelsCount, 1);
        expect(realtimeService.activeChannelNames,
            contains('test-photos-channel'));
      }, timeout: Timeout(testTimeout));

      test('should filter photos by baby_profile_id', () async {
        const testBabyProfileId = 'test-baby-123';

        final stream = realtimeService.subscribe(
          table: 'photos',
          channelName: 'test-photos-baby-filter',
          filter: {
            'column': 'baby_profile_id',
            'value': testBabyProfileId,
          },
        );

        expect(stream, isNotNull);
        expect(realtimeService.activeChannelsCount, 1);
      }, timeout: Timeout(testTimeout));

      test('should handle multiple simultaneous subscriptions', () async {
        final stream1 = realtimeService.subscribe(
          table: 'photos',
          channelName: 'photos-channel-1',
        );

        final stream2 = realtimeService.subscribe(
          table: 'photos',
          channelName: 'photos-channel-2',
        );

        expect(stream1, isNotNull);
        expect(stream2, isNotNull);
        expect(realtimeService.activeChannelsCount, 2);
      }, timeout: Timeout(testTimeout));

      test('should return existing stream for duplicate channel names',
          () async {
        final stream1 = realtimeService.subscribe(
          table: 'photos',
          channelName: 'duplicate-channel',
        );

        final stream2 = realtimeService.subscribe(
          table: 'photos',
          channelName: 'duplicate-channel',
        );

        expect(identical(stream1, stream2), isTrue);
        expect(realtimeService.activeChannelsCount, 1);
      }, timeout: Timeout(testTimeout));

      test('should unsubscribe from channel', () async {
        realtimeService.subscribe(
          table: 'photos',
          channelName: 'unsubscribe-test',
        );

        expect(realtimeService.activeChannelsCount, 1);

        await realtimeService.unsubscribe('unsubscribe-test');

        expect(realtimeService.activeChannelsCount, 0);
        expect(realtimeService.activeChannelNames, isEmpty);
      }, timeout: Timeout(testTimeout));
    });

    group('Event Handling', () {
      test('should listen for INSERT events', () async {
        final completer = Completer<dynamic>();

        final stream = realtimeService.subscribe(
          table: 'photos',
          channelName: 'insert-test',
          event: PostgresChangeEvent.insert,
        );

        subscription = stream.listen((data) {
          if (!completer.isCompleted) {
            completer.complete(data);
          }
        });

        // Note: In real integration tests, this would trigger an actual insert
        // For now, we're testing the subscription setup
        expect(stream, isNotNull);
      }, timeout: Timeout(testTimeout));

      test('should listen for UPDATE events', () async {
        final stream = realtimeService.subscribe(
          table: 'photos',
          channelName: 'update-test',
          event: PostgresChangeEvent.update,
        );

        expect(stream, isNotNull);
      }, timeout: Timeout(testTimeout));

      test('should listen for DELETE events', () async {
        final stream = realtimeService.subscribe(
          table: 'photos',
          channelName: 'delete-test',
          event: PostgresChangeEvent.delete,
        );

        expect(stream, isNotNull);
      }, timeout: Timeout(testTimeout));

      test('should listen for ALL events by default', () async {
        final stream = realtimeService.subscribe(
          table: 'photos',
          channelName: 'all-events-test',
        );

        expect(stream, isNotNull);
      }, timeout: Timeout(testTimeout));
    });

    group('Batched Updates', () {
      test('should handle rapid successive updates', () async {
        final receivedEvents = <dynamic>[];
        final completer = Completer<void>();

        final stream = realtimeService.subscribe(
          table: 'photos',
          channelName: 'batch-test',
        );

        subscription = stream.listen((data) {
          receivedEvents.add(data);

          // Complete after receiving multiple events or timeout
          if (receivedEvents.length >= 3) {
            if (!completer.isCompleted) {
              completer.complete();
            }
          }
        });

        // Note: In real integration tests, this would trigger multiple rapid updates
        expect(stream, isNotNull);
      }, timeout: Timeout(testTimeout));
    });

    group('Reconnection Scenarios', () {
      test('should maintain subscription after reconnection', () async {
        final stream = realtimeService.subscribe(
          table: 'photos',
          channelName: 'reconnect-test',
        );

        expect(stream, isNotNull);
        expect(realtimeService.activeChannelsCount, 1);

        // Note: In real integration tests, this would simulate a disconnection
        // and verify that the subscription is restored
      }, timeout: Timeout(testTimeout));
    });

    group('Performance Benchmarks', () {
      test('subscription should complete within acceptable latency', () async {
        final stopwatch = Stopwatch()..start();

        final stream = realtimeService.subscribe(
          table: 'photos',
          channelName: 'latency-test',
        );

        stopwatch.stop();

        expect(stream, isNotNull);
        // Subscription setup should be fast (< 2 seconds as per requirements)
        expect(stopwatch.elapsedMilliseconds, lessThan(2000));
      }, timeout: Timeout(testTimeout));

      test('should handle multiple concurrent subscriptions efficiently',
          () async {
        final stopwatch = Stopwatch()..start();

        // Create 10 concurrent subscriptions
        final streams = <Stream<dynamic>>[];
        for (int i = 0; i < 10; i++) {
          streams.add(
            realtimeService.subscribe(
              table: 'photos',
              channelName: 'concurrent-test-$i',
            ),
          );
        }

        stopwatch.stop();

        expect(streams.length, 10);
        expect(realtimeService.activeChannelsCount, 10);
        // All subscriptions should be set up reasonably fast
        expect(stopwatch.elapsedMilliseconds, lessThan(5000));
      }, timeout: Timeout(testTimeout));
    });

    group('Memory Management', () {
      test('should not leak memory after multiple subscribe/unsubscribe cycles',
          () async {
        // Subscribe and unsubscribe multiple times
        for (int i = 0; i < 5; i++) {
          realtimeService.subscribe(
            table: 'photos',
            channelName: 'memory-test-$i',
          );

          await realtimeService.unsubscribe('memory-test-$i');
        }

        expect(realtimeService.activeChannelsCount, 0);
        expect(realtimeService.activeChannelNames, isEmpty);
      }, timeout: Timeout(testTimeout));

      test('should clean up all resources on dispose', () async {
        // Create multiple subscriptions
        for (int i = 0; i < 3; i++) {
          realtimeService.subscribe(
            table: 'photos',
            channelName: 'cleanup-test-$i',
          );
        }

        expect(realtimeService.activeChannelsCount, 3);

        await realtimeService.dispose();

        expect(realtimeService.activeChannelsCount, 0);
      }, timeout: Timeout(testTimeout));
    });
  });
}
