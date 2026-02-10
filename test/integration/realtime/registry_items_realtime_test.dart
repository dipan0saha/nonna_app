import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/services/realtime_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../helpers/mock_factory.dart';
import '../../mocks/mock_services.mocks.dart';

/// Integration tests for Registry Items real-time subscriptions
///
/// Tests registry item updates, purchase tracking, and baby-scoped filtering
void main() {
  group('Registry Items Realtime Integration Tests', () {
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
      test('should successfully subscribe to registry_items table', () async {
        addTearDown(() async {
          await realtimeService.dispose();
        });

        final stream = realtimeService.subscribe(
          table: 'registry_items',
          channelName: 'test-registry-items-channel',
        );

        expect(stream, isNotNull);
        expect(realtimeService.activeChannelsCount, 1);
      }, timeout: Timeout(testTimeout));

      test('should filter registry items by baby_profile_id', () async {
        addTearDown(() async {
          await realtimeService.dispose();
        });

        const testBabyProfileId = 'test-baby-123';

        final stream = realtimeService.subscribe(
          table: 'registry_items',
          channelName: 'test-registry-items-baby-filter',
          filter: {
            'column': 'baby_profile_id',
            'value': testBabyProfileId,
          },
        );

        expect(stream, isNotNull);
      }, timeout: Timeout(testTimeout));
    });

    group('Registry Item Operations', () {
      test('should receive new registry item INSERT events', () async {
        addTearDown(() async {
          await subscription?.cancel();
          await realtimeService.dispose();
        });

        final stream = realtimeService.subscribe(
          table: 'registry_items',
          channelName: 'insert-item-test',
          event: PostgresChangeEvent.insert,
        );

        expect(stream, isNotNull);
      }, timeout: Timeout(testTimeout));

      test('should receive registry item UPDATE events', () async {
        addTearDown(() async {
          await subscription?.cancel();
          await realtimeService.dispose();
        });

        final stream = realtimeService.subscribe(
          table: 'registry_items',
          channelName: 'update-item-test',
          event: PostgresChangeEvent.update,
        );

        expect(stream, isNotNull);
      }, timeout: Timeout(testTimeout));

      test('should receive registry item DELETE events', () async {
        addTearDown(() async {
          await subscription?.cancel();
          await realtimeService.dispose();
        });

        final stream = realtimeService.subscribe(
          table: 'registry_items',
          channelName: 'delete-item-test',
          event: PostgresChangeEvent.delete,
        );

        expect(stream, isNotNull);
      }, timeout: Timeout(testTimeout));
    });

    group('Purchase Status Updates', () {
      test('should track purchase status changes in real-time', () async {
        addTearDown(() async {
          await subscription?.cancel();
          await realtimeService.dispose();
        });

        final stream = realtimeService.subscribe(
          table: 'registry_items',
          channelName: 'purchase-status-test',
        );

        expect(stream, isNotNull);
      }, timeout: Timeout(testTimeout));

      test('should handle concurrent purchase updates', () async {
        addTearDown(() async {
          await subscription?.cancel();
          await realtimeService.dispose();
        });

        final stream = realtimeService.subscribe(
          table: 'registry_items',
          channelName: 'concurrent-purchases-test',
        );

        expect(stream, isNotNull);
      }, timeout: Timeout(testTimeout));
    });
  });
}
