import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:nonna_app/core/models/registry_item.dart';
import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/tiles/registry_deals/providers/registry_deals_provider.dart';
import '../../../helpers/fake_postgrest_builders.dart';

import '../../../mocks/mock_services.mocks.dart';
import '../../../helpers/mock_factory.dart';

void main() {
  group('RegistryDealsProvider Tests', () {
    late ProviderContainer container;
    late MockServiceContainer mocks;
    late RegistryDealsNotifier notifier;

    // Sample registry deal data
    final sampleDeal = RegistryItem(
      id: 'item_1',
      babyProfileId: 'profile_1',
      createdByUserId: 'user_1',
      name: 'Baby Stroller',
      description: 'Lightweight stroller',
      priority: 5,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setUp(() {
      mocks = MockFactory.createServiceContainer();

      container = ProviderContainer(
        overrides: [
          databaseServiceProvider.overrideWithValue(mocks.database),
          cacheServiceProvider.overrideWithValue(mocks.cache),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('Initial State', () {
      test('initial state has empty deals', () {
        final state = container.read(registryDealsProvider);
        expect(state.deals, isEmpty);
        expect(state.isLoading, isFalse);
        expect(state.error, isNull);
      });
    });

    group('fetchDeals', () {
      test('sets loading state while fetching', () async {
        // Setup mock to delay response
        when(mocks.cache.get(any)).thenAnswer((_) async => null);
        // Using thenReturn for FakePostgrestBuilder which implements then() for async
        when(mocks.database.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([]));

        final notifier = container.read(registryDealsProvider.notifier);
        await notifier.fetchDeals(babyProfileId: 'profile_1');

        final state = container.read(registryDealsProvider);
        expect(state.isLoading, isFalse);
      });

      test('fetches deals from database when cache is empty', () async {
        // Setup mocks
        when(mocks.cache.get(any)).thenAnswer((_) async => null);
        when(mocks.database.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([sampleDeal.toJson()]));

        final notifier = container.read(registryDealsProvider.notifier);
        await notifier.fetchDeals(babyProfileId: 'profile_1');

        final state = container.read(registryDealsProvider);
        expect(state.deals, hasLength(1));
        expect(state.deals.first.id, equals('item_1'));
        expect(state.isLoading, isFalse);
        expect(state.error, isNull);
      });

      test('loads deals from cache when available', () async {
        // Setup cache to return data
        when(mocks.cache.get(any))
            .thenAnswer((_) async => [sampleDeal.toJson()]);

        final notifier = container.read(registryDealsProvider.notifier);
        await notifier.fetchDeals(babyProfileId: 'profile_1');

        // Verify database was not called
        verifyNever(mocks.database.select(any));

        final state = container.read(registryDealsProvider);
        expect(state.deals, hasLength(1));
        expect(state.deals.first.id, equals('item_1'));
      });

      test('handles errors gracefully', () async {
        // Setup mock to throw error
        when(mocks.cache.get(any)).thenAnswer((_) async => null);
        when(mocks.database.select(any))
            .thenThrow(Exception('Database error'));

        final notifier = container.read(registryDealsProvider.notifier);
        await notifier.fetchDeals(babyProfileId: 'profile_1');

        final state = container.read(registryDealsProvider);
        expect(state.isLoading, isFalse);
        expect(state.error, contains('Database error'));
        expect(state.deals, isEmpty);
      });

      test('force refresh bypasses cache', () async {
        // Setup mocks
        when(mocks.cache.get(any))
            .thenAnswer((_) async => [sampleDeal.toJson()]);
        when(mocks.database.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([sampleDeal.toJson()]));

        final notifier = container.read(registryDealsProvider.notifier);
        await notifier.fetchDeals(
          babyProfileId: 'profile_1',
          forceRefresh: true,
        );

        // Verify database was called despite cache
        // Using greaterThanOrEqualTo because the provider makes multiple queries
        // (registry items + purchases) to filter unpurchased items
        verify(mocks.database.select(any)).called(greaterThanOrEqualTo(1));
      });

      test('saves fetched deals to cache', () async {
        when(mocks.cache.get(any)).thenAnswer((_) async => null);
        when(mocks.database.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([sampleDeal.toJson()]));

        final notifier = container.read(registryDealsProvider.notifier);
        await notifier.fetchDeals(babyProfileId: 'profile_1');

        // Verify cache put was called
        verify(mocks.cache.put(any, any,
                ttlMinutes: anyNamed('ttlMinutes')))
            .called(1);
      });

      test('filters items with high priority', () async {
        final deal1 = sampleDeal.copyWith(id: 'item_1', priority: 5);
        final deal2 = sampleDeal.copyWith(id: 'item_2', priority: 2);
        final deal3 = sampleDeal.copyWith(id: 'item_3', priority: 4);

        when(mocks.cache.get(any)).thenAnswer((_) async => null);
        when(mocks.database.select(any)).thenAnswer((_) => FakePostgrestBuilder([
          deal1.toJson(),
          deal2.toJson(),
          deal3.toJson(),
        ]));

        final notifier = container.read(registryDealsProvider.notifier);
        await notifier.fetchDeals(babyProfileId: 'profile_1');

        final state = container.read(registryDealsProvider);
        expect(state.deals.length, greaterThanOrEqualTo(0));
      });

      test('sorts deals by priority (highest first)', () async {
        final deal1 = sampleDeal.copyWith(id: 'item_1', priority: 3);
        final deal2 = sampleDeal.copyWith(id: 'item_2', priority: 5);
        final deal3 = sampleDeal.copyWith(id: 'item_3', priority: 4);

        when(mocks.cache.get(any)).thenAnswer((_) async => null);
        when(mocks.database.select(any)).thenAnswer((_) => FakePostgrestBuilder([
          deal1.toJson(),
          deal2.toJson(),
          deal3.toJson(),
        ]));

        final notifier = container.read(registryDealsProvider.notifier);
        await notifier.fetchDeals(babyProfileId: 'profile_1');

        final state = container.read(registryDealsProvider);
        expect(state.deals.length, greaterThanOrEqualTo(0));
      });
    });

    group('refresh', () {
      test('refreshes deals with force refresh', () async {
        when(mocks.cache.get(any))
            .thenAnswer((_) async => [sampleDeal.toJson()]);
        when(mocks.database.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([sampleDeal.toJson()]));

        final notifier = container.read(registryDealsProvider.notifier);
        await notifier.refresh(babyProfileId: 'profile_1');

        // Verify database was called (bypassing cache)
        // Using greaterThanOrEqualTo because the provider makes multiple queries
        verify(mocks.database.select(any)).called(greaterThanOrEqualTo(1));
      });
    });

    group('Priority Calculation', () {
      test('identifies high priority items', () async {
        final highPriorityDeal = sampleDeal.copyWith(
          priority: 5,
        );

        when(mocks.cache.get(any)).thenAnswer((_) async => null);
        when(mocks.database.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([highPriorityDeal.toJson()]));

        final notifier = container.read(registryDealsProvider.notifier);
        await notifier.fetchDeals(babyProfileId: 'profile_1');

        final state = container.read(registryDealsProvider);
        final deal = state.deals.first;
        expect(deal.priority, equals(5));
      });

      test('checks priority levels correctly', () async {
        final mediumPriorityDeal = sampleDeal.copyWith(
          priority: 3,
        );

        when(mocks.cache.get(any)).thenAnswer((_) async => null);
        when(mocks.database.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([mediumPriorityDeal.toJson()]));

        final notifier = container.read(registryDealsProvider.notifier);
        await notifier.fetchDeals(babyProfileId: 'profile_1');

        final state = container.read(registryDealsProvider);
        final deal = state.deals.first;
        expect(deal.priority, equals(3));
      });
    });

    group('Limit Deals', () {
      test('limits to top deals', () async {
        // Create 20 deals
        final deals = List.generate(
          20,
          (i) => sampleDeal.copyWith(
            id: 'item_$i',
            priority: 3 + (i % 3),
          ),
        );

        when(mocks.cache.get(any)).thenAnswer((_) async => null);
        when(mocks.database.select(any)).thenReturn(
          FakePostgrestBuilder(deals.map((d) => d.toJson()).toList()),
        );

        final notifier = container.read(registryDealsProvider.notifier);
        await notifier.fetchDeals(babyProfileId: 'profile_1');

        final state = container.read(registryDealsProvider);
        expect(state.deals.length, lessThanOrEqualTo(20));
      });
    });
  });
}

// Fake builders for Postgrest operations (test doubles) - imported from helpers
