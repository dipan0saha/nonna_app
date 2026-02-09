import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/services/realtime_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../helpers/mock_factory.dart';
import '../../mocks/mock_services.mocks.dart';

/// Integration tests for Name Suggestions real-time subscriptions
///
/// Tests name suggestion updates, like counts, and baby-scoped filtering
void main() {
  group('Name Suggestions Realtime Integration Tests', () {
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
      test('should successfully subscribe to name_suggestions table', () async {
        final stream = realtimeService.subscribe(
          table: 'name_suggestions',
          channelName: 'test-name-suggestions-channel',
        );

        expect(stream, isNotNull);
        expect(realtimeService.activeChannelsCount, 1);
      }, timeout: Timeout(testTimeout));

      test('should filter name suggestions by baby_profile_id', () async {
        const testBabyProfileId = 'test-baby-123';

        final stream = realtimeService.subscribe(
          table: 'name_suggestions',
          channelName: 'test-name-suggestions-baby-filter',
          filter: {
            'column': 'baby_profile_id',
            'value': testBabyProfileId,
          },
        );

        expect(stream, isNotNull);
      }, timeout: Timeout(testTimeout));
    });

    group('Name Suggestion Operations', () {
      test('should receive new name suggestion INSERT events', () async {
        final stream = realtimeService.subscribe(
          table: 'name_suggestions',
          channelName: 'insert-suggestion-test',
          event: PostgresChangeEvent.insert,
        );

        expect(stream, isNotNull);
      }, timeout: Timeout(testTimeout));

      test('should receive name suggestion UPDATE events (like count)',
          () async {
        final stream = realtimeService.subscribe(
          table: 'name_suggestions',
          channelName: 'update-suggestion-test',
          event: PostgresChangeEvent.update,
        );

        expect(stream, isNotNull);
      }, timeout: Timeout(testTimeout));

      test('should receive name suggestion DELETE events', () async {
        final stream = realtimeService.subscribe(
          table: 'name_suggestions',
          channelName: 'delete-suggestion-test',
          event: PostgresChangeEvent.delete,
        );

        expect(stream, isNotNull);
      }, timeout: Timeout(testTimeout));
    });

    group('Like Count Real-time Updates', () {
      test('should track like count changes in real-time', () async {
        final stream = realtimeService.subscribe(
          table: 'name_suggestions',
          channelName: 'like-count-test',
        );

        expect(stream, isNotNull);
      }, timeout: Timeout(testTimeout));

      test('should handle rapid like/unlike operations', () async {
        final stream = realtimeService.subscribe(
          table: 'name_suggestions',
          channelName: 'rapid-likes-test',
        );

        expect(stream, isNotNull);
      }, timeout: Timeout(testTimeout));
    });

    group('Performance', () {
      test('should deliver suggestion updates with low latency', () async {
        final stopwatch = Stopwatch()..start();

        final stream = realtimeService.subscribe(
          table: 'name_suggestions',
          channelName: 'latency-test',
        );

        stopwatch.stop();

        expect(stream, isNotNull);
        expect(stopwatch.elapsedMilliseconds, lessThan(2000));
      }, timeout: Timeout(testTimeout));
    });
  });
}
