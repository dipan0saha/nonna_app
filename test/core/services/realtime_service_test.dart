import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/services/realtime_service.dart';

import '../../mocks/mock_services.mocks.dart';
import '../../helpers/mock_factory.dart';

void main() {
  group('RealtimeService', () {
    late RealtimeService realtimeService;
    late MockSupabaseClient mockSupabaseClient;

    setUp(() {
      mockSupabaseClient = MockFactory.createSupabaseClient();

      // Initialize service with mock client
      realtimeService = RealtimeService(mockSupabaseClient);
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
