import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/services/observability_service.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() {
  group('ObservabilityService', () {
    group('isInitialized', () {
      test('returns false before initialization', () {
        expect(ObservabilityService.isInitialized, false);
      });
    });

    group('environment', () {
      test('returns null before initialization', () {
        expect(ObservabilityService.environment, null);
      });
    });

    group('captureException', () {
      test('does not throw when not initialized', () async {
        await expectLater(
          ObservabilityService.captureException(Exception('test')),
          completes,
        );
      });
    });

    group('captureMessage', () {
      test('does not throw when not initialized', () async {
        await expectLater(
          ObservabilityService.captureMessage('test message'),
          completes,
        );
      });
    });

    group('addBreadcrumb', () {
      test('does not throw when not initialized', () {
        expect(
          () => ObservabilityService.addBreadcrumb(message: 'test'),
          returnsNormally,
        );
      });
    });

    group('addNavigationBreadcrumb', () {
      test('does not throw when not initialized', () {
        expect(
          () => ObservabilityService.addNavigationBreadcrumb(
            from: 'home',
            to: 'profile',
          ),
          returnsNormally,
        );
      });
    });

    group('addHttpBreadcrumb', () {
      test('does not throw when not initialized', () {
        expect(
          () => ObservabilityService.addHttpBreadcrumb(
            method: 'GET',
            url: 'https://api.example.com',
            statusCode: 200,
          ),
          returnsNormally,
        );
      });
    });

    group('addUserActionBreadcrumb', () {
      test('does not throw when not initialized', () {
        expect(
          () => ObservabilityService.addUserActionBreadcrumb(
            action: 'button_click',
          ),
          returnsNormally,
        );
      });
    });

    group('setUser', () {
      test('does not throw when not initialized', () async {
        await expectLater(
          ObservabilityService.setUser(
            userId: '123',
            email: 'test@example.com',
          ),
          completes,
        );
      });
    });

    group('clearUser', () {
      test('does not throw when not initialized', () async {
        await expectLater(
          ObservabilityService.clearUser(),
          completes,
        );
      });
    });

    group('setContext', () {
      test('does not throw when not initialized', () async {
        await expectLater(
          ObservabilityService.setContext('test', 'value'),
          completes,
        );
      });
    });

    group('setTag', () {
      test('does not throw when not initialized', () async {
        await expectLater(
          ObservabilityService.setTag('test', 'value'),
          completes,
        );
      });
    });

    group('startTransaction', () {
      test('returns null when not initialized', () {
        final transaction = ObservabilityService.startTransaction(
          name: 'test',
          operation: 'test_op',
        );
        expect(transaction, null);
      });
    });
  });
}
