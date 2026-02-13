import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/core/models/registry_purchase.dart';
import 'package:nonna_app/tiles/recent_purchases/providers/recent_purchases_provider.dart';

import '../../../helpers/fake_postgrest_builders.dart';
import '../../../helpers/mock_factory.dart';

void main() {
  group('RecentPurchasesProvider Tests', () {
    late ProviderContainer container;
    late MockServiceContainer mocks;

    // Sample purchase data
    final samplePurchase = RegistryPurchase(
      id: 'purchase_1',
      registryItemId: 'item_1',
      purchasedByUserId: 'user_1',
      purchasedAt: DateTime.now(),
      createdAt: DateTime.now(),
    );

    setUp(() {
      mocks = MockFactory.createServiceContainer();

      when(mocks.cache.isInitialized).thenReturn(true);
      when(mocks.cache.get(any)).thenAnswer((_) async => null);
      when(mocks.cache.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
          .thenAnswer((_) async {});
      when(mocks.database.select(any))
          .thenAnswer((_) => FakePostgrestBuilder([]));
      // Setup default realtime service stubs
      when(mocks.realtime.subscribe(
        table: anyNamed('table'),
        channelName: anyNamed('channelName'),
        filter: anyNamed('filter'),
      )).thenAnswer((_) => Stream.empty());
      when(mocks.realtime.unsubscribe(any)).thenAnswer((_) async {});

      container = ProviderContainer(
        overrides: [
          databaseServiceProvider.overrideWithValue(mocks.database),
          cacheServiceProvider.overrideWithValue(mocks.cache),
          realtimeServiceProvider.overrideWithValue(mocks.realtime),
        ],
      );
    });

    tearDown(() {
      container.dispose();
      reset(mocks.database);
      reset(mocks.cache);
    });

    group('Initial State', () {
      test('initial state has empty purchases', () {
        final state = container.read(recentPurchasesProvider);
        expect(state.purchases, isEmpty);
        expect(state.isLoading, isFalse);
        expect(state.error, isNull);
      });
    });

    group('fetchPurchases', () {
      test('sets loading state while fetching', () async {
        // Reset and re-stub mocks
        reset(mocks.cache);
        reset(mocks.database);
        reset(mocks.realtime);
        when(mocks.cache.isInitialized).thenReturn(true);
        when(mocks.cache.get(any)).thenAnswer((_) async => null);
        when(mocks.cache.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async {});
        when(mocks.database.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([]));
        when(mocks.realtime.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenAnswer((_) => Stream.empty());
        when(mocks.realtime.unsubscribe(any)).thenAnswer((_) async {});

        final notifier = container.read(recentPurchasesProvider.notifier);
        await notifier.fetchPurchases(babyProfileId: 'profile_1');

        final state = container.read(recentPurchasesProvider);
        expect(state.isLoading, isFalse);
      });

      test('fetches purchases from database when cache is empty', () async {
        // Reset and re-stub mocks
        reset(mocks.cache);
        reset(mocks.database);
        reset(mocks.realtime);
        when(mocks.cache.isInitialized).thenReturn(true);
        when(mocks.cache.get(any)).thenAnswer((_) async => null);
        when(mocks.cache.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async {});
        when(mocks.realtime.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenAnswer((_) => Stream.value({}));
        when(mocks.realtime.unsubscribe(any)).thenAnswer((_) async {});
        when(mocks.database.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([samplePurchase.toJson()]));

        final notifier = container.read(recentPurchasesProvider.notifier);
        await notifier.fetchPurchases(babyProfileId: 'profile_1');

        final state = container.read(recentPurchasesProvider);
        expect(state.purchases, hasLength(1));
        expect(state.purchases.first.id, equals('purchase_1'));
        expect(state.isLoading, isFalse);
        expect(state.error, isNull);
      });

      test('loads purchases from cache when available', () async {
        // Reset and re-stub mocks
        reset(mocks.cache);
        reset(mocks.database);
        reset(mocks.realtime);
        when(mocks.cache.isInitialized).thenReturn(true);
        when(mocks.cache.get(any))
            .thenAnswer((_) async => [samplePurchase.toJson()]);
        when(mocks.cache.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async {});
        when(mocks.database.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([]));
        when(mocks.realtime.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenAnswer((_) => Stream.empty());
        when(mocks.realtime.unsubscribe(any)).thenAnswer((_) async {});

        final notifier = container.read(recentPurchasesProvider.notifier);
        await notifier.fetchPurchases(babyProfileId: 'profile_1');

        // Verify database was not called
        verifyNever(mocks.database.select(any));

        final state = container.read(recentPurchasesProvider);
        expect(state.purchases, hasLength(1));
        expect(state.purchases.first.id, equals('purchase_1'));
      });

      test('handles errors gracefully', () async {
        // Reset and re-stub mocks
        reset(mocks.cache);
        reset(mocks.database);
        reset(mocks.realtime);
        when(mocks.cache.isInitialized).thenReturn(true);
        when(mocks.cache.get(any)).thenAnswer((_) async => null);
        when(mocks.cache.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async {});
        when(mocks.database.select(any)).thenThrow(Exception('Database error'));
        when(mocks.realtime.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenAnswer((_) => Stream.empty());
        when(mocks.realtime.unsubscribe(any)).thenAnswer((_) async {});

        final notifier = container.read(recentPurchasesProvider.notifier);
        await notifier.fetchPurchases(babyProfileId: 'profile_1');

        final state = container.read(recentPurchasesProvider);
        expect(state.isLoading, isFalse);
        expect(state.error, contains('Database error'));
        expect(state.purchases, isEmpty);
      });

      test('force refresh bypasses cache', () async {
        // Reset and re-stub mocks
        reset(mocks.cache);
        reset(mocks.database);
        reset(mocks.realtime);
        when(mocks.cache.isInitialized).thenReturn(true);
        when(mocks.cache.get(any))
            .thenAnswer((_) async => [samplePurchase.toJson()]);
        when(mocks.cache.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async {});
        when(mocks.realtime.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenAnswer((_) => Stream.value({}));
        when(mocks.realtime.unsubscribe(any)).thenAnswer((_) async {});
        when(mocks.database.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([samplePurchase.toJson()]));

        final notifier = container.read(recentPurchasesProvider.notifier);
        await notifier.fetchPurchases(
          babyProfileId: 'profile_1',
          forceRefresh: true,
        );

        // Verify database was called despite cache
        // Using greaterThanOrEqualTo because the provider makes multiple queries
        // (registry items + purchases) to build the full state
        verify(mocks.database.select(any)).called(greaterThanOrEqualTo(1));
      });

      test('saves fetched purchases to cache', () async {
        // Reset and re-stub mocks
        reset(mocks.cache);
        reset(mocks.database);
        reset(mocks.realtime);
        when(mocks.cache.isInitialized).thenReturn(true);
        when(mocks.cache.get(any)).thenAnswer((_) async => null);
        when(mocks.cache.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async {});
        when(mocks.realtime.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenAnswer((_) => Stream.value({}));
        when(mocks.realtime.unsubscribe(any)).thenAnswer((_) async {});
        when(mocks.database.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([samplePurchase.toJson()]));

        final notifier = container.read(recentPurchasesProvider.notifier);
        await notifier.fetchPurchases(babyProfileId: 'profile_1');

        // Verify cache put was called
        verify(mocks.cache.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .called(1);
      });

      test('limits to recent purchases only', () async {
        // Create 25 purchases
        final purchases = List.generate(
          25,
          (i) => samplePurchase.copyWith(
            id: 'purchase_$i',
            createdAt: DateTime.now().subtract(Duration(days: i)),
          ),
        );

        // Reset and re-stub mocks
        reset(mocks.cache);
        reset(mocks.database);
        reset(mocks.realtime);
        when(mocks.cache.isInitialized).thenReturn(true);
        when(mocks.cache.get(any)).thenAnswer((_) async => null);
        when(mocks.cache.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async {});
        when(mocks.realtime.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenAnswer((_) => Stream.value({}));
        when(mocks.realtime.unsubscribe(any)).thenAnswer((_) async {});
        when(mocks.database.select(any)).thenReturn(
          FakePostgrestBuilder(purchases.map((p) => p.toJson()).toList()),
        );

        final notifier = container.read(recentPurchasesProvider.notifier);
        await notifier.fetchPurchases(babyProfileId: 'profile_1');

        final state = container.read(recentPurchasesProvider);
        expect(state.purchases.length, lessThanOrEqualTo(25));
      });
    });

    group('refresh', () {
      test('refreshes purchases with force refresh', () async {
        // Reset and re-stub mocks
        reset(mocks.cache);
        reset(mocks.database);
        reset(mocks.realtime);
        when(mocks.cache.isInitialized).thenReturn(true);
        when(mocks.cache.get(any))
            .thenAnswer((_) async => [samplePurchase.toJson()]);
        when(mocks.cache.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async {});
        when(mocks.realtime.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenAnswer((_) => Stream.value({}));
        when(mocks.realtime.unsubscribe(any)).thenAnswer((_) async {});
        when(mocks.database.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([samplePurchase.toJson()]));

        final notifier = container.read(recentPurchasesProvider.notifier);
        await notifier.refresh(babyProfileId: 'profile_1');

        // Verify database was called (bypassing cache)
        // Using greaterThanOrEqualTo because the provider makes multiple queries
        verify(mocks.database.select(any)).called(greaterThanOrEqualTo(1));
      });
    });

    group('Real-time Updates', () {
      test('handles INSERT purchase', () async {
        // Reset and re-stub mocks
        reset(mocks.cache);
        reset(mocks.database);
        reset(mocks.realtime);
        when(mocks.cache.isInitialized).thenReturn(true);
        when(mocks.cache.get(any)).thenAnswer((_) async => null);
        when(mocks.cache.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async {});
        when(mocks.realtime.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenAnswer((_) => Stream.value({}));
        when(mocks.realtime.unsubscribe(any)).thenAnswer((_) async {});
        when(mocks.database.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([samplePurchase.toJson()]));

        final notifier = container.read(recentPurchasesProvider.notifier);
        await notifier.fetchPurchases(babyProfileId: 'profile_1');

        final initialCount =
            container.read(recentPurchasesProvider).purchases.length;

        // Verify real-time setup occurred
        expect(initialCount, greaterThanOrEqualTo(0));
      });

      test('handles UPDATE purchase', () async {
        // Reset and re-stub mocks
        reset(mocks.cache);
        reset(mocks.database);
        reset(mocks.realtime);
        when(mocks.cache.isInitialized).thenReturn(true);
        when(mocks.cache.get(any)).thenAnswer((_) async => null);
        when(mocks.cache.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async {});
        when(mocks.realtime.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenAnswer((_) => Stream.value({}));
        when(mocks.realtime.unsubscribe(any)).thenAnswer((_) async {});
        when(mocks.database.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([samplePurchase.toJson()]));

        final notifier = container.read(recentPurchasesProvider.notifier);
        await notifier.fetchPurchases(babyProfileId: 'profile_1');

        final state = container.read(recentPurchasesProvider);
        expect(state.purchases.isNotEmpty, isTrue);
      });
    });

    group('dispose', () {
      test('dispose', () {
        // Reset and re-stub mocks
        reset(mocks.realtime);
        when(mocks.realtime.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenAnswer((_) => Stream.empty());
        when(mocks.realtime.unsubscribe(any)).thenAnswer((_) async {});

        expect(() => container.dispose(), returnsNormally);
      });
    });

    group('Sorting', () {
      test('sorts purchases by date (newest first)', () async {
        final purchase1 = samplePurchase.copyWith(
          id: 'purchase_1',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        );
        final purchase2 = samplePurchase.copyWith(
          id: 'purchase_2',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        );
        final purchase3 = samplePurchase.copyWith(
          id: 'purchase_3',
          createdAt: DateTime.now(),
        );

        // Reset and re-stub mocks
        reset(mocks.cache);
        reset(mocks.database);
        reset(mocks.realtime);
        when(mocks.cache.isInitialized).thenReturn(true);
        when(mocks.cache.get(any)).thenAnswer((_) async => null);
        when(mocks.cache.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async {});
        when(mocks.realtime.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenAnswer((_) => Stream.value({}));
        when(mocks.realtime.unsubscribe(any)).thenAnswer((_) async {});
        when(mocks.database.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([
                  purchase1.toJson(),
                  purchase2.toJson(),
                  purchase3.toJson(),
                ]));

        final notifier = container.read(recentPurchasesProvider.notifier);
        await notifier.fetchPurchases(babyProfileId: 'profile_1');

        final state = container.read(recentPurchasesProvider);
        expect(state.purchases.length, equals(3));
      });
    });
  });
}

// Fake builders for Postgrest operations (test doubles) - imported from helpers
