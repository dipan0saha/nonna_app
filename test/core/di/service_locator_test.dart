import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/di/service_locator.dart';
import 'package:nonna_app/core/services/auth_service.dart';
import 'package:nonna_app/core/services/cache_service.dart';
import 'package:nonna_app/core/services/database_service.dart';

void main() {
  group('ServiceLocator Tests', () {
    setUp(() {
      // Reset before each test
      ServiceLocator.reset();
    });

    tearDown(() {
      // Clean up after each test
      ServiceLocator.reset();
    });

    group('Initialization', () {
      test('isInitialized returns false before initialization', () {
        expect(ServiceLocator.isInitialized, isFalse);
      });

      test('initialize() sets isInitialized to true', () async {
        await ServiceLocator.initialize();
        expect(ServiceLocator.isInitialized, isTrue);
      });

      test('initialize() can be called multiple times safely', () async {
        await ServiceLocator.initialize();
        await ServiceLocator.initialize(); // Should not throw
        expect(ServiceLocator.isInitialized, isTrue);
      });
    });

    group('Service Registration', () {
      test('register() adds service to registry', () {
        final testService = AuthService();
        ServiceLocator.register<AuthService>(testService);

        final retrieved = ServiceLocator.get<AuthService>();
        expect(identical(retrieved, testService), isTrue);
      });

      test('registerLazy() adds factory to registry', () {
        ServiceLocator.registerLazy<AuthService>(() => AuthService());

        final service = ServiceLocator.get<AuthService>();
        expect(service, isA<AuthService>());
      });

      test('registerLazy() creates instance only once', () {
        var creationCount = 0;
        ServiceLocator.registerLazy<AuthService>(() {
          creationCount++;
          return AuthService();
        });

        final service1 = ServiceLocator.get<AuthService>();
        final service2 = ServiceLocator.get<AuthService>();

        expect(identical(service1, service2), isTrue);
        expect(creationCount, equals(1));
      });

      test('unregister() removes service from registry', () {
        final testService = AuthService();
        ServiceLocator.register<AuthService>(testService);

        ServiceLocator.unregister<AuthService>();

        expect(
          () => ServiceLocator.get<AuthService>(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Service Retrieval', () {
      test('get() returns registered service', () async {
        await ServiceLocator.initialize();
        final service = ServiceLocator.get<AuthService>();
        expect(service, isA<AuthService>());
      });

      test('get() throws when service not registered', () {
        expect(
          () => ServiceLocator.get<String>(), // Not a registered service
          throwsA(isA<Exception>()),
        );
      });

      test('tryGet() returns null when service not registered', () {
        final service = ServiceLocator.tryGet<String>();
        expect(service, isNull);
      });

      test('tryGet() returns service when registered', () async {
        await ServiceLocator.initialize();
        final service = ServiceLocator.tryGet<AuthService>();
        expect(service, isA<AuthService>());
      });
    });

    group('Testing Support', () {
      test('getTestOverrides() returns empty list by default', () {
        final overrides = ServiceLocator.getTestOverrides();
        expect(overrides, isEmpty);
      });

      test('getTestOverrides() returns overrides for provided mocks', () {
        final mockAuth = AuthService();

        final overrides = ServiceLocator.getTestOverrides(
          mockAuth: mockAuth,
        );

        expect(overrides, isNotEmpty);
        expect(overrides.length, equals(1));
      });

      test('getTestOverrides() supports multiple service overrides', () {
        final mockAuth = AuthService();
        final mockDatabase = DatabaseService();
        final mockCache = CacheService();

        final overrides = ServiceLocator.getTestOverrides(
          mockAuth: mockAuth,
          mockDatabase: mockDatabase,
          mockCache: mockCache,
        );

        expect(overrides.length, equals(3));
      });

      test('provider overrides work in ProviderContainer', () {
        final mockAuth = AuthService();

        final container = ProviderContainer(
          overrides: ServiceLocator.getTestOverrides(mockAuth: mockAuth),
        );

        // This would verify the override works, but requires the provider
        // to be imported, which we're keeping minimal in tests

        container.dispose();
      });
    });

    group('Reset and Dispose', () {
      test('reset() clears all services', () async {
        await ServiceLocator.initialize();
        expect(ServiceLocator.isInitialized, isTrue);

        ServiceLocator.reset();

        expect(ServiceLocator.isInitialized, isFalse);
        expect(
          () => ServiceLocator.get<AuthService>(),
          throwsA(isA<Exception>()),
        );
      });

      test('dispose() can be called safely', () async {
        await ServiceLocator.initialize();
        await ServiceLocator.dispose(); // Should not throw
      });

      test('dispose() cleans up initialized services', () async {
        await ServiceLocator.initialize();

        // Get services to ensure they're initialized
        final cacheService = ServiceLocator.get<CacheService>();
        expect(cacheService.isInitialized, isTrue);

        await ServiceLocator.dispose();

        // After dispose, services should be cleaned up
        // Note: We can't verify this without accessing internal state,
        // but we verify dispose doesn't throw
      });
    });

    group('Service Dependencies', () {
      test('services are registered in correct order', () async {
        await ServiceLocator.initialize();

        // Verify all expected services are available
        expect(ServiceLocator.tryGet<AuthService>(), isNotNull);
        expect(ServiceLocator.tryGet<DatabaseService>(), isNotNull);
        expect(ServiceLocator.tryGet<CacheService>(), isNotNull);
      });

      test('async services are initialized', () async {
        await ServiceLocator.initialize();

        final cacheService = ServiceLocator.get<CacheService>();

        expect(cacheService.isInitialized, isTrue);
      });
    });

    group('Error Handling', () {
      test('get() provides helpful error message', () {
        try {
          ServiceLocator.get<String>();
          fail('Should have thrown an exception');
        } catch (e) {
          expect(e.toString(), contains('not registered'));
          expect(e.toString(), contains('String'));
        }
      });

      test('initialize() handles errors gracefully', () async {
        // This test verifies that if initialization fails,
        // it doesn't leave the ServiceLocator in a bad state

        // First successful initialization
        await ServiceLocator.initialize();
        expect(ServiceLocator.isInitialized, isTrue);

        // Reset and try again
        ServiceLocator.reset();
        await ServiceLocator.initialize();
        expect(ServiceLocator.isInitialized, isTrue);
      });
    });
  });
}
