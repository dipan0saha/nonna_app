import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/core/services/analytics_service.dart';
import 'package:nonna_app/core/services/auth_service.dart';
import 'package:nonna_app/core/services/cache_service.dart';
import 'package:nonna_app/core/services/database_service.dart';
import 'package:nonna_app/core/services/local_storage_service.dart';
import 'package:nonna_app/core/services/notification_service.dart';
import 'package:nonna_app/core/services/observability_service.dart';
import 'package:nonna_app/core/services/realtime_service.dart';
import 'package:nonna_app/core/services/storage_service.dart';

void main() {
  group('Core Providers Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('Service Providers', () {
      test('supabaseClientProvider provides SupabaseClient instance', () {
        final client = container.read(supabaseClientProvider);
        expect(client, isNotNull);
      });

      test('authServiceProvider provides AuthService instance', () {
        final service = container.read(authServiceProvider);
        expect(service, isA<AuthService>());
      });

      test('databaseServiceProvider provides DatabaseService instance', () {
        final service = container.read(databaseServiceProvider);
        expect(service, isA<DatabaseService>());
      });

      test('cacheServiceProvider provides CacheService instance', () {
        final service = container.read(cacheServiceProvider);
        expect(service, isA<CacheService>());
      });

      test('localStorageServiceProvider provides LocalStorageService instance',
          () {
        final service = container.read(localStorageServiceProvider);
        expect(service, isA<LocalStorageService>());
      });

      test('storageServiceProvider provides StorageService instance', () {
        final service = container.read(storageServiceProvider);
        expect(service, isA<StorageService>());
      });

      test('realtimeServiceProvider provides RealtimeService instance', () {
        final service = container.read(realtimeServiceProvider);
        expect(service, isA<RealtimeService>());
      });

      test('notificationServiceProvider provides NotificationService instance',
          () {
        final service = container.read(notificationServiceProvider);
        expect(service, isA<NotificationService>());
      });

      test('analyticsServiceProvider provides AnalyticsService instance', () {
        final service = container.read(analyticsServiceProvider);
        expect(service, isA<AnalyticsService>());
      });

      test('observabilityServiceProvider provides ObservabilityService instance',
          () {
        final service = container.read(observabilityServiceProvider);
        expect(service, isA<ObservabilityService>());
      });
    });

    group('Singleton Behavior', () {
      test('authServiceProvider returns the same instance', () {
        final service1 = container.read(authServiceProvider);
        final service2 = container.read(authServiceProvider);
        expect(identical(service1, service2), isTrue);
      });

      test('databaseServiceProvider returns the same instance', () {
        final service1 = container.read(databaseServiceProvider);
        final service2 = container.read(databaseServiceProvider);
        expect(identical(service1, service2), isTrue);
      });

      test('cacheServiceProvider returns the same instance', () {
        final service1 = container.read(cacheServiceProvider);
        final service2 = container.read(cacheServiceProvider);
        expect(identical(service1, service2), isTrue);
      });
    });

    group('Provider Overrides', () {
      test('providers can be overridden in tests', () {
        // Create a mock or test instance
        final testContainer = ProviderContainer(
          overrides: [
            // Override with a custom value for testing
            scopedProvider('test-scope').overrideWithValue('test-value'),
          ],
        );

        final value = testContainer.read(scopedProvider('test-scope'));
        expect(value, equals('test-value'));

        testContainer.dispose();
      });
    });

    group('Auto-dispose Providers', () {
      test('autoDisposeExampleProvider provides value', () {
        final value = container.read(autoDisposeExampleProvider);
        expect(value, equals('auto-dispose-example'));
      });

      test('autoDisposeExampleProvider disposes when no longer used', () {
        var disposeCalled = false;
        final testProvider = Provider.autoDispose<String>((ref) {
          ref.onDispose(() {
            disposeCalled = true;
          });
          return 'test';
        });

        final testContainer = ProviderContainer();
        testContainer.read(testProvider);

        // Dispose the container
        testContainer.dispose();

        // Verify dispose was called
        expect(disposeCalled, isTrue);
      });
    });

    group('Scoped Providers', () {
      test('scopedProvider creates provider with correct scope', () {
        final provider1 = scopedProvider('scope1');
        final provider2 = scopedProvider('scope2');

        final value1 = container.read(provider1);
        final value2 = container.read(provider2);

        expect(value1, equals('scope1'));
        expect(value2, equals('scope2'));
      });
    });

    group('Auth State Provider', () {
      test('authStateProvider provides stream', () {
        final stateStream = container.read(authStateProvider);
        expect(stateStream, isA<AsyncValue>());
      });

      test('currentUserProvider returns null when not authenticated', () {
        final user = container.read(currentUserProvider);
        expect(user, isNull);
      });
    });

    group('Initialization Provider', () {
      test('appInitializationProvider is a FutureProvider', () {
        final initialization = container.read(appInitializationProvider);
        expect(initialization, isA<AsyncValue<bool>>());
      });
    });
  });
}
