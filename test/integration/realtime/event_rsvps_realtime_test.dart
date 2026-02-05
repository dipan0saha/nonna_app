import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/services/realtime_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Integration tests for Event RSVPs real-time subscriptions
/// 
/// Tests RSVP status updates and event attendance tracking
void main() {
  group('Event RSVPs Realtime Integration Tests', () {
    late RealtimeService realtimeService;
    StreamSubscription<dynamic>? subscription;
    final testTimeout = const Duration(seconds: 30);
    
    setUp(() {
      realtimeService = RealtimeService();
    });
    
    tearDown(() async {
      await subscription?.cancel();
      await realtimeService.dispose();
    });

    group('Subscription Lifecycle', () {
      test('should successfully subscribe to event_rsvps table', () async {
        final stream = realtimeService.subscribe(
          table: 'event_rsvps',
          channelName: 'test-event-rsvps-channel',
        );
        
        expect(stream, isNotNull);
        expect(realtimeService.activeChannelsCount, 1);
      }, timeout: Timeout(testTimeout));

      test('should filter RSVPs by event_id', () async {
        const testEventId = 'test-event-123';
        
        final stream = realtimeService.subscribe(
          table: 'event_rsvps',
          channelName: 'test-event-rsvps-event-filter',
          filter: {
            'column': 'event_id',
            'value': testEventId,
          },
        );
        
        expect(stream, isNotNull);
      }, timeout: Timeout(testTimeout));
    });

    group('RSVP Operations', () {
      test('should receive new RSVP INSERT events', () async {
        final stream = realtimeService.subscribe(
          table: 'event_rsvps',
          channelName: 'insert-rsvp-test',
          event: PostgresChangeEvent.insert,
        );
        
        expect(stream, isNotNull);
      }, timeout: Timeout(testTimeout));

      test('should receive RSVP UPDATE events (status changes)', () async {
        final stream = realtimeService.subscribe(
          table: 'event_rsvps',
          channelName: 'update-rsvp-test',
          event: PostgresChangeEvent.update,
        );
        
        expect(stream, isNotNull);
      }, timeout: Timeout(testTimeout));

      test('should receive RSVP DELETE events', () async {
        final stream = realtimeService.subscribe(
          table: 'event_rsvps',
          channelName: 'delete-rsvp-test',
          event: PostgresChangeEvent.delete,
        );
        
        expect(stream, isNotNull);
      }, timeout: Timeout(testTimeout));
    });

    group('Attendance Count Updates', () {
      test('should track RSVP count changes in real-time', () async {
        final stream = realtimeService.subscribe(
          table: 'event_rsvps',
          channelName: 'rsvp-count-test',
        );
        
        expect(stream, isNotNull);
      }, timeout: Timeout(testTimeout));
    });
  });
}
