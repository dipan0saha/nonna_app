import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/services/realtime_service.dart';

void main() {
  group('RealtimeService', () {
    late RealtimeService realtimeService;

    setUp(() {
      realtimeService = RealtimeService();
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
