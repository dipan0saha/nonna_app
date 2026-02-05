import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/services/realtime_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('RealtimeService', () {
    late RealtimeService realtimeService;

    setUp(() async {
      // Initialize Supabase for testing
      try {
        await Supabase.initialize(
          url: 'https://test.supabase.co',
          anonKey: 'test-anon-key',
        );
      } catch (e) {
        // Already initialized, ignore
      }

      // Note: SupabaseClientManager.initialize() reads from .env file
      // For tests, we use the Supabase.instance directly via the setUp above
      // The RealtimeService will need to be mocked or refactored for proper testing
      // For now, we skip these tests as they require proper mocking
      realtimeService = RealtimeService();
    });

    tearDown(() async {
      try {
        await realtimeService.dispose();
      } catch (e) {
        // Ignore disposal errors in tests
      }
    });

    group('isConnected', () {
      test('returns false initially', () {
        expect(realtimeService.isConnected, false);
      });
    });

    group('activeChannelsCount', () {
      test('returns 0 initially', () {
        expect(realtimeService.activeChannelsCount, 0);
      });
    });

    group('activeChannelNames', () {
      test('returns empty list initially', () {
        expect(realtimeService.activeChannelNames, isEmpty);
      });
    });

    group('isHealthy', () {
      test('returns false when not connected', () {
        expect(realtimeService.isHealthy(), false);
      });
    });

    group('dispose', () {
      test('completes without errors', () async {
        await expectLater(
          realtimeService.dispose(),
          completes,
        );
      });
    });
  });
}
