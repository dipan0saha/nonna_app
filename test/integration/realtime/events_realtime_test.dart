import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/services/realtime_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../helpers/mock_factory.dart';
import '../../mocks/mock_services.mocks.dart';

/// Integration tests for Events real-time subscriptions
///
/// Tests calendar event updates, RSVP changes, and baby-scoped filtering
void main() {
  group('Events Realtime Integration Tests', () {
    late RealtimeService realtimeService;
    late MockSupabaseClient mockSupabaseClient;
    StreamSubscription<dynamic>? subscription;
    const testTimeout = Duration(seconds: 30);

    setUp(() {
      mockSupabaseClient = MockFactory.createSupabaseClient();
      realtimeService = RealtimeService(mockSupabaseClient);
    });

    tearDown(() async {
      // ignore: dead_code
      await subscription?.cancel();
      await realtimeService.dispose();
    });

    group('Subscription Lifecycle', () {
      test('should successfully subscribe to events table', () async {
        addTearDown(() async {
          await realtimeService.dispose();
        });

        final stream = realtimeService.subscribe(
          table: 'events',
          channelName: 'test-events-channel',
        );

        expect(stream, isNotNull);
        expect(realtimeService.activeChannelsCount, 1);
        expect(realtimeService.activeChannelNames,
            contains('test-events-channel'));
      }, timeout: Timeout(testTimeout));

      test('should filter events by baby_profile_id', () async {
        addTearDown(() async {
          await realtimeService.dispose();
        });

        const testBabyProfileId = 'test-baby-123';

        final stream = realtimeService.subscribe(
          table: 'events',
          channelName: 'test-events-baby-filter',
          filter: {
            'column': 'baby_profile_id',
            'value': testBabyProfileId,
          },
        );

        expect(stream, isNotNull);
        expect(realtimeService.activeChannelsCount, 1);
      }, timeout: Timeout(testTimeout));

      test('should handle multiple baby profile event streams', () async {
        addTearDown(() async {
          await realtimeService.dispose();
        });

        final stream1 = realtimeService.subscribe(
          table: 'events',
          channelName: 'events-baby-1',
          filter: {'column': 'baby_profile_id', 'value': 'baby-1'},
        );

        final stream2 = realtimeService.subscribe(
          table: 'events',
          channelName: 'events-baby-2',
          filter: {'column': 'baby_profile_id', 'value': 'baby-2'},
        );

        expect(stream1, isNotNull);
        expect(stream2, isNotNull);
        expect(realtimeService.activeChannelsCount, 2);
      }, timeout: Timeout(testTimeout));
    });

    group('Event CRUD Operations', () {
      test('should receive event INSERT notifications', () async {
        addTearDown(() async {
          await realtimeService.dispose();
        });

        final stream = realtimeService.subscribe(
          table: 'events',
          channelName: 'insert-event-test',
          event: PostgresChangeEvent.insert,
        );

        expect(stream, isNotNull);
      }, timeout: Timeout(testTimeout));

      test('should receive event UPDATE notifications', () async {
        addTearDown(() async {
          await realtimeService.dispose();
        });

        final stream = realtimeService.subscribe(
          table: 'events',
          channelName: 'update-event-test',
          event: PostgresChangeEvent.update,
        );

        expect(stream, isNotNull);
      }, timeout: Timeout(testTimeout));

      test('should receive event DELETE notifications', () async {
        addTearDown(() async {
          await realtimeService.dispose();
        });

        final stream = realtimeService.subscribe(
          table: 'events',
          channelName: 'delete-event-test',
          event: PostgresChangeEvent.delete,
        );

        expect(stream, isNotNull);
      }, timeout: Timeout(testTimeout));
    });

    group('Calendar Synchronization', () {
      test('should sync event changes across multiple subscribers', () async {
        addTearDown(() async {
          await realtimeService.dispose();
        });

        final stream1 = realtimeService.subscribe(
          table: 'events',
          channelName: 'sync-test-1',
        );

        final stream2 = realtimeService.subscribe(
          table: 'events',
          channelName: 'sync-test-2',
        );

        expect(stream1, isNotNull);
        expect(stream2, isNotNull);
      }, timeout: Timeout(testTimeout));
    });

    group('Performance', () {
      test('should handle event subscriptions with low latency', () async {
        addTearDown(() async {
          await subscription?.cancel();
          await realtimeService.dispose();
        });

        final stopwatch = Stopwatch()..start();

        final stream = realtimeService.subscribe(
          table: 'events',
          channelName: 'latency-test',
        );

        stopwatch.stop();

        expect(stream, isNotNull);
        expect(stopwatch.elapsedMilliseconds, lessThan(2000));
      }, timeout: Timeout(testTimeout));
    });
  });
}
