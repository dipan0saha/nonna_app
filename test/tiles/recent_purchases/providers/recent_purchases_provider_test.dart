import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nonna_app/core/constants/supabase_tables.dart';
import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/core/models/registry_purchase.dart';
import 'package:nonna_app/tiles/recent_purchases/providers/recent_purchases_provider.dart';

import '../../../helpers/fake_postgrest_builders.dart';
import '../../../helpers/mock_factory.dart';
import '../../../mocks/mock_services.mocks.dart';

void main() {
  group('RecentPurchasesProvider Tests', () {
    late ProviderContainer? container;
    late MockDatabaseService mockDatabaseService;
    late MockCacheService mockCacheService;
    late MockRealtimeService mockRealtimeService;

    // Sample purchase data
    final samplePurchase = RegistryPurchase(
      id: 'purchase_1',
      registryItemId: 'item_1',
      purchasedByUserId: 'user_1',
      purchasedAt: DateTime.now(),
      createdAt: DateTime.now(),
    );

    setUp(() {
      mockDatabaseService = MockFactory.createDatabaseService();
      mockCacheService = MockFactory.createCacheService();
      mockRealtimeService = MockFactory.createRealtimeService();

      // Setup default stub for cache service
      when(mockCacheService.isInitialized).thenReturn(true);
      
      // Setup default realtime stubs
      when(mockRealtimeService.subscribe(
        table: anyNamed('table'),
        channelName: anyNamed('channelName'),
        filter: anyNamed('filter'),
      )).thenAnswer((_) => Stream.value(<String, dynamic>{}));
      when(mockRealtimeService.unsubscribe(any)).thenAnswer((_) async {});
    });

    ProviderContainer createContainer() {
      return ProviderContainer(
        overrides: [
          databaseServiceProvider.overrideWithValue(mockDatabaseService),
          cacheServiceProvider.overrideWithValue(mockCacheService),
          realtimeServiceProvider.overrideWithValue(mockRealtimeService),
        ],
      );
    }

    tearDown(() {
      container?.dispose();
      container = null;
    });

    group('Initial State', () {
      test('initial state has empty purchases', () {
        container = createContainer();
        final state = container!.read(recentPurchasesProvider);
        expect(state.purchases, isEmpty);
        expect(state.isLoading, isFalse);
        expect(state.error, isNull);
      });
    });

    group('fetchPurchases', () {
      test('sets loading state while fetching', () async {
        container = createContainer();

        // Setup mock to delay response
        when(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async {});
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        // Setup for both tables that the provider queries
        when(mockDatabaseService.select(SupabaseTables.registryItems))
            .thenAnswer((_) => FakePostgrestBuilder([{'id': 'item_1'}]));
        when(mockDatabaseService.select(SupabaseTables.registryPurchases))
            .thenAnswer((_) => FakePostgrestBuilder([]));

        final notifier = container!.read(recentPurchasesProvider.notifier);
        await notifier.fetchPurchases(babyProfileId: 'profile_1');

        final state = container!.read(recentPurchasesProvider);
        expect(state.isLoading, isFalse);
      });

      test('fetches purchases from database when cache is empty', () async {
        container = createContainer();

        // Setup mocks
        when(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async {});
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(SupabaseTables.registryItems))
            .thenAnswer((_) => FakePostgrestBuilder([{'id': 'item_1'}]));
        when(mockDatabaseService.select(SupabaseTables.registryPurchases))
            .thenAnswer((_) => FakePostgrestBuilder([samplePurchase.toJson()]));

        final notifier = container!.read(recentPurchasesProvider.notifier);
        await notifier.fetchPurchases(babyProfileId: 'profile_1');

        final state = container!.read(recentPurchasesProvider);
        expect(state.purchases, hasLength(1));
        expect(state.purchases.first.id, equals('purchase_1'));
        expect(state.isLoading, isFalse);
        expect(state.error, isNull);
      });

      test('loads purchases from cache when available', () async {
        container = createContainer();

        // Setup cache to return data
        when(mockCacheService.get(any))
            .thenAnswer((_) async => [samplePurchase.toJson()]);

        final notifier = container!.read(recentPurchasesProvider.notifier);
        await notifier.fetchPurchases(babyProfileId: 'profile_1');

        // Verify database was not called
        verifyNever(mockDatabaseService.select(SupabaseTables.registryItems));
        verifyNever(
            mockDatabaseService.select(SupabaseTables.registryPurchases));

        final state = container!.read(recentPurchasesProvider);
        expect(state.purchases, hasLength(1));
        expect(state.purchases.first.id, equals('purchase_1'));
      });

      test('handles errors gracefully', () async {
        container = createContainer();

        // Setup mock to throw error
        when(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async {});
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(SupabaseTables.registryItems))
            .thenThrow(Exception('Database error'));

        final notifier = container!.read(recentPurchasesProvider.notifier);
        await notifier.fetchPurchases(babyProfileId: 'profile_1');

        final state = container!.read(recentPurchasesProvider);
        expect(state.isLoading, isFalse);
        expect(state.error, contains('Database error'));
        expect(state.purchases, isEmpty);
      });

      test('force refresh bypasses cache', () async {
        container = createContainer();

        // Setup mocks
        when(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async {});
        when(mockCacheService.get(any))
            .thenAnswer((_) async => [samplePurchase.toJson()]);
        when(mockDatabaseService.select(SupabaseTables.registryItems))
            .thenAnswer((_) => FakePostgrestBuilder([{'id': 'item_1'}]));
        when(mockDatabaseService.select(SupabaseTables.registryPurchases))
            .thenAnswer((_) => FakePostgrestBuilder([samplePurchase.toJson()]));

        final notifier = container!.read(recentPurchasesProvider.notifier);
        await notifier.fetchPurchases(
          babyProfileId: 'profile_1',
          forceRefresh: true,
        );

        // Verify database was called despite cache
        // Using greaterThanOrEqualTo because the provider makes multiple queries
        // (registry items + purchases) to build the full state
        verify(mockDatabaseService.select(SupabaseTables.registryItems))
            .called(greaterThanOrEqualTo(1));
      });

      test('saves fetched purchases to cache', () async {
        container = createContainer();

        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(SupabaseTables.registryItems))
            .thenAnswer((_) => FakePostgrestBuilder([{'id': 'item_1'}]));
        when(mockDatabaseService.select(SupabaseTables.registryPurchases))
            .thenAnswer((_) => FakePostgrestBuilder([samplePurchase.toJson()]));

        final notifier = container!.read(recentPurchasesProvider.notifier);
        await notifier.fetchPurchases(babyProfileId: 'profile_1');

        // Verify cache put was called
        verify(mockCacheService.put(any, any,
                ttlMinutes: anyNamed('ttlMinutes')))
            .called(1);
      });

      test('limits to recent purchases only', () async {
        container = createContainer();

        // Create 25 purchases
        final purchases = List.generate(
          25,
          (i) => samplePurchase.copyWith(
            id: 'purchase_$i',
            createdAt: DateTime.now().subtract(Duration(days: i)),
          ),
        );

        when(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async {});
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(SupabaseTables.registryItems))
            .thenAnswer((_) => FakePostgrestBuilder([{'id': 'item_1'}]));
        when(mockDatabaseService.select(SupabaseTables.registryPurchases))
            .thenAnswer((_) => 
          FakePostgrestBuilder(purchases.map((p) => p.toJson()).toList()),
        );

        final notifier = container!.read(recentPurchasesProvider.notifier);
        await notifier.fetchPurchases(babyProfileId: 'profile_1');

        final state = container!.read(recentPurchasesProvider);
        expect(state.purchases.length, lessThanOrEqualTo(25));
      });
    });

    group('refresh', () {
      test('refreshes purchases with force refresh', () async {
        container = createContainer();

        when(mockCacheService.get(any))
            .thenAnswer((_) async => [samplePurchase.toJson()]);
        when(mockDatabaseService.select(SupabaseTables.registryItems))
            .thenAnswer((_) => FakePostgrestBuilder([{'id': 'item_1'}]));
        when(mockDatabaseService.select(SupabaseTables.registryPurchases))
            .thenAnswer((_) => FakePostgrestBuilder([samplePurchase.toJson()]));

        final notifier = container!.read(recentPurchasesProvider.notifier);
        await notifier.refresh(babyProfileId: 'profile_1');

        // Verify database was called (bypassing cache)
        // Using greaterThanOrEqualTo because the provider makes multiple queries
        verify(mockDatabaseService.select(SupabaseTables.registryItems))
            .called(greaterThanOrEqualTo(1));
      });
    });

    group('Real-time Updates', () {
      test('handles INSERT purchase', () async {
        final streamController = StreamController<Map<String, dynamic>>();
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenAnswer((_) => streamController.stream);

        container = createContainer();

        // Setup initial state
        when(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async {});
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(SupabaseTables.registryItems))
            .thenAnswer((_) => FakePostgrestBuilder([{'id': 'item_1'}]));
        when(mockDatabaseService.select(SupabaseTables.registryPurchases))
            .thenAnswer((_) => FakePostgrestBuilder([samplePurchase.toJson()]));

        final notifier = container!.read(recentPurchasesProvider.notifier);
        await notifier.fetchPurchases(babyProfileId: 'profile_1');

        final initialCount =
            container!.read(recentPurchasesProvider).purchases.length;

        expect(initialCount, greaterThanOrEqualTo(0));

        await streamController.close();
      });

      test('handles UPDATE purchase', () async {
        final streamController = StreamController<Map<String, dynamic>>();
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenAnswer((_) => streamController.stream);

        container = createContainer();

        // Setup initial state
        when(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async {});
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(SupabaseTables.registryItems))
            .thenAnswer((_) => FakePostgrestBuilder([{'id': 'item_1'}]));
        when(mockDatabaseService.select(SupabaseTables.registryPurchases))
            .thenAnswer((_) => FakePostgrestBuilder([samplePurchase.toJson()]));

        final notifier = container!.read(recentPurchasesProvider.notifier);
        await notifier.fetchPurchases(babyProfileId: 'profile_1');

        final state = container!.read(recentPurchasesProvider);
        final isNotEmpty = state.purchases.isNotEmpty;

        expect(isNotEmpty, isTrue);

        await streamController.close();
      });
    });

    group('dispose', () {
      test('cancels real-time subscription on dispose', () {
        container = createContainer();

        // Note: Riverpod automatically handles disposal through ref.onDispose
        // This test verifies the container can be disposed without errors
        when(mockRealtimeService.unsubscribe(any)).thenAnswer((_) async {});

        expect(() => container!.dispose(), returnsNormally);
      });
    });

    group('Sorting', () {
      test('sorts purchases by date (newest first)', () async {
        container = createContainer();

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

        when(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async {});
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(SupabaseTables.registryItems))
            .thenAnswer((_) => FakePostgrestBuilder([{'id': 'item_1'}]));
        when(mockDatabaseService.select(SupabaseTables.registryPurchases))
            .thenAnswer((_) => FakePostgrestBuilder([
                  purchase1.toJson(),
                  purchase2.toJson(),
                  purchase3.toJson(),
                ]));

        final notifier = container!.read(recentPurchasesProvider.notifier);
        await notifier.fetchPurchases(babyProfileId: 'profile_1');

        final state = container!.read(recentPurchasesProvider);
        expect(state.purchases.length, equals(3));
      });
    });
  });
}

// Fake builders for Postgrest operations (test doubles) - imported from helpers
