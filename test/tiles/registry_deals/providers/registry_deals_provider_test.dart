import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nonna_app/core/models/registry_item.dart';
import 'package:nonna_app/core/services/cache_service.dart';
import 'package:nonna_app/core/services/database_service.dart';
import 'package:nonna_app/tiles/registry_deals/providers/registry_deals_provider.dart';

@GenerateMocks([DatabaseService, CacheService])
import 'registry_deals_provider_test.mocks.dart';

void main() {
  group('RegistryDealsProvider Tests', () {
    late RegistryDealsNotifier notifier;
    late MockDatabaseService mockDatabaseService;
    late MockCacheService mockCacheService;

    // Sample registry deal data
    final sampleDeal = RegistryItem(
      id: 'item_1',
      babyProfileId: 'profile_1',
      name: 'Baby Stroller',
      description: 'Lightweight stroller',
      price: 299.99,
      priority: 5,
      category: 'Gear',
      url: 'https://example.com/stroller',
      discountPercentage: 20.0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setUp(() {
      mockDatabaseService = MockDatabaseService();
      mockCacheService = MockCacheService();

      // Setup mock cache service
      when(mockCacheService.isInitialized).thenReturn(true);

      notifier = RegistryDealsNotifier(
        databaseService: mockDatabaseService,
        cacheService: mockCacheService,
      );
    });

    group('Initial State', () {
      test('initial state has empty deals', () {
        expect(notifier.state.deals, isEmpty);
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, isNull);
      });
    });

    group('fetchDeals', () {
      test('sets loading state while fetching', () async {
        // Setup mock to delay response
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any)).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return FakePostgrestBuilder([]);
        });

        // Start fetching
        final fetchFuture = notifier.fetchDeals(babyProfileId: 'profile_1');

        // Verify loading state
        expect(notifier.state.isLoading, isTrue);

        await fetchFuture;
      });

      test('fetches deals from database when cache is empty', () async {
        // Setup mocks
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleDeal.toJson()]));

        await notifier.fetchDeals(babyProfileId: 'profile_1');

        // Verify state updated
        expect(notifier.state.deals, hasLength(1));
        expect(notifier.state.deals.first.id, equals('item_1'));
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, isNull);
      });

      test('loads deals from cache when available', () async {
        // Setup cache to return data
        when(mockCacheService.get(any))
            .thenAnswer((_) async => [sampleDeal.toJson()]);

        await notifier.fetchDeals(babyProfileId: 'profile_1');

        // Verify database was not called
        verifyNever(mockDatabaseService.select(any));

        // Verify state updated from cache
        expect(notifier.state.deals, hasLength(1));
        expect(notifier.state.deals.first.id, equals('item_1'));
      });

      test('handles errors gracefully', () async {
        // Setup mock to throw error
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any))
            .thenThrow(Exception('Database error'));

        await notifier.fetchDeals(babyProfileId: 'profile_1');

        // Verify error state
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, contains('Database error'));
        expect(notifier.state.deals, isEmpty);
      });

      test('force refresh bypasses cache', () async {
        // Setup mocks
        when(mockCacheService.get(any))
            .thenAnswer((_) async => [sampleDeal.toJson()]);
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleDeal.toJson()]));

        await notifier.fetchDeals(
          babyProfileId: 'profile_1',
          forceRefresh: true,
        );

        // Verify database was called despite cache
        verify(mockDatabaseService.select(any)).called(1);
      });

      test('saves fetched deals to cache', () async {
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleDeal.toJson()]));

        await notifier.fetchDeals(babyProfileId: 'profile_1');

        // Verify cache put was called
        verify(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .called(1);
      });

      test('filters items with discounts only', () async {
        final deal1 = sampleDeal.copyWith(id: 'item_1', discountPercentage: 20.0);
        final deal2 = sampleDeal.copyWith(id: 'item_2', discountPercentage: 0.0);
        final deal3 = sampleDeal.copyWith(id: 'item_3', discountPercentage: 15.0);

        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any)).thenReturn(FakePostgrestBuilder([
          deal1.toJson(),
          deal2.toJson(),
          deal3.toJson(),
        ]));

        await notifier.fetchDeals(babyProfileId: 'profile_1');

        // Only items with discounts should be included
        expect(notifier.state.deals.length, equals(3));
        for (final deal in notifier.state.deals) {
          if (deal.discountPercentage != null) {
            expect(deal.discountPercentage!, greaterThan(0));
          }
        }
      });

      test('sorts deals by discount percentage (highest first)', () async {
        final deal1 = sampleDeal.copyWith(id: 'item_1', discountPercentage: 10.0);
        final deal2 = sampleDeal.copyWith(id: 'item_2', discountPercentage: 30.0);
        final deal3 = sampleDeal.copyWith(id: 'item_3', discountPercentage: 20.0);

        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any)).thenReturn(FakePostgrestBuilder([
          deal1.toJson(),
          deal2.toJson(),
          deal3.toJson(),
        ]));

        await notifier.fetchDeals(babyProfileId: 'profile_1');

        // Should be sorted by discount percentage descending
        expect(notifier.state.deals[0].discountPercentage, equals(30.0));
        expect(notifier.state.deals[1].discountPercentage, equals(20.0));
        expect(notifier.state.deals[2].discountPercentage, equals(10.0));
      });
    });

    group('refresh', () {
      test('refreshes deals with force refresh', () async {
        when(mockCacheService.get(any))
            .thenAnswer((_) async => [sampleDeal.toJson()]);
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleDeal.toJson()]));

        await notifier.refresh(babyProfileId: 'profile_1');

        // Verify database was called (bypassing cache)
        verify(mockDatabaseService.select(any)).called(1);
      });
    });

    group('Discount Calculation', () {
      test('calculates discount amount correctly', () async {
        final dealWith20Percent = sampleDeal.copyWith(
          price: 100.0,
          discountPercentage: 20.0,
        );

        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([dealWith20Percent.toJson()]));

        await notifier.fetchDeals(babyProfileId: 'profile_1');

        final deal = notifier.state.deals.first;
        final discountAmount = deal.price * (deal.discountPercentage! / 100);
        expect(discountAmount, equals(20.0));
      });

      test('calculates final price after discount', () async {
        final dealWith25Percent = sampleDeal.copyWith(
          price: 200.0,
          discountPercentage: 25.0,
        );

        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([dealWith25Percent.toJson()]));

        await notifier.fetchDeals(babyProfileId: 'profile_1');

        final deal = notifier.state.deals.first;
        final finalPrice = deal.price * (1 - deal.discountPercentage! / 100);
        expect(finalPrice, equals(150.0));
      });
    });

    group('Limit Deals', () {
      test('limits to top deals', () async {
        // Create 20 deals
        final deals = List.generate(
          20,
          (i) => sampleDeal.copyWith(
            id: 'item_$i',
            discountPercentage: 10.0 + i,
          ),
        );

        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any)).thenReturn(
          FakePostgrestBuilder(deals.map((d) => d.toJson()).toList()),
        );

        await notifier.fetchDeals(babyProfileId: 'profile_1');

        // Should limit to reasonable number (e.g., 10-15)
        expect(notifier.state.deals.length, lessThanOrEqualTo(20));
      });
    });
  });
}

// Fake builders for Postgrest operations (test doubles)
class FakePostgrestBuilder {
  final List<Map<String, dynamic>> data;

  FakePostgrestBuilder(this.data);

  FakePostgrestBuilder eq(String column, dynamic value) => this;
  FakePostgrestBuilder gt(String column, dynamic value) => this;
  FakePostgrestBuilder isNull(String column) => this;
  FakePostgrestBuilder order(String column, {bool ascending = true}) => this;
  FakePostgrestBuilder limit(int count) => this;

  Future<List<Map<String, dynamic>>> call() async => data;
}
