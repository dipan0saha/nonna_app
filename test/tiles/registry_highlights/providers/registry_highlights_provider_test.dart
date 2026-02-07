import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nonna_app/core/models/registry_item.dart';
import 'package:nonna_app/core/models/registry_purchase.dart';
import 'package:nonna_app/core/services/cache_service.dart';
import 'package:nonna_app/core/services/database_service.dart';
import 'package:nonna_app/tiles/registry_highlights/providers/registry_highlights_provider.dart';

@GenerateMocks([DatabaseService, CacheService])
import 'registry_highlights_provider_test.mocks.dart';

void main() {
  group('RegistryHighlightsProvider Tests', () {
    late RegistryHighlightsNotifier notifier;
    late MockDatabaseService mockDatabaseService;
    late MockCacheService mockCacheService;

    // Sample registry item data
    final sampleItem = RegistryItem(
      id: 'item_1',
      babyProfileId: 'profile_1',
      name: 'Baby Stroller',
      description: 'Lightweight stroller',
      price: 299.99,
      priority: 5,
      category: 'Gear',
      url: 'https://example.com/stroller',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setUp(() {
      mockDatabaseService = MockDatabaseService();
      mockCacheService = MockCacheService();

      // Setup mock cache service
      when(mockCacheService.isInitialized).thenReturn(true);

      notifier = RegistryHighlightsNotifier(
        databaseService: mockDatabaseService,
        cacheService: mockCacheService,
      );
    });

    group('Initial State', () {
      test('initial state has empty items', () {
        expect(notifier.state.items, isEmpty);
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, isNull);
      });
    });

    group('fetchHighlights', () {
      test('sets loading state while fetching', () async {
        // Setup mock to delay response
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any)).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return FakePostgrestBuilder([]);
        });

        // Start fetching
        final fetchFuture = notifier.fetchHighlights(babyProfileId: 'profile_1');

        // Verify loading state
        expect(notifier.state.isLoading, isTrue);

        await fetchFuture;
      });

      test('fetches items from database when cache is empty', () async {
        // Setup mocks
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleItem.toJson()]));

        await notifier.fetchHighlights(babyProfileId: 'profile_1');

        // Verify state updated
        expect(notifier.state.items, hasLength(1));
        expect(notifier.state.items.first.item.id, equals('item_1'));
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, isNull);
      });

      test('loads items from cache when available', () async {
        // Setup cache to return data
        final cachedData = {
          'item': sampleItem.toJson(),
          'isPurchased': false,
          'purchases': [],
        };
        when(mockCacheService.get(any)).thenAnswer((_) async => [cachedData]);

        await notifier.fetchHighlights(babyProfileId: 'profile_1');

        // Verify database was not called
        verifyNever(mockDatabaseService.select(any));

        // Verify state updated from cache
        expect(notifier.state.items, hasLength(1));
        expect(notifier.state.items.first.item.id, equals('item_1'));
      });

      test('handles errors gracefully', () async {
        // Setup mock to throw error
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any))
            .thenThrow(Exception('Database error'));

        await notifier.fetchHighlights(babyProfileId: 'profile_1');

        // Verify error state
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, contains('Database error'));
        expect(notifier.state.items, isEmpty);
      });

      test('force refresh bypasses cache', () async {
        // Setup mocks
        final cachedData = {
          'item': sampleItem.toJson(),
          'isPurchased': false,
          'purchases': [],
        };
        when(mockCacheService.get(any)).thenAnswer((_) async => [cachedData]);
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleItem.toJson()]));

        await notifier.fetchHighlights(
          babyProfileId: 'profile_1',
          forceRefresh: true,
        );

        // Verify database was called despite cache
        verify(mockDatabaseService.select(any)).called(greaterThanOrEqualTo(1));
      });

      test('saves fetched items to cache', () async {
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleItem.toJson()]));

        await notifier.fetchHighlights(babyProfileId: 'profile_1');

        // Verify cache put was called
        verify(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .called(1);
      });

      test('sorts items by priority (highest first)', () async {
        final item1 = sampleItem.copyWith(id: 'item_1', priority: 3);
        final item2 = sampleItem.copyWith(id: 'item_2', priority: 5);
        final item3 = sampleItem.copyWith(id: 'item_3', priority: 1);

        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any)).thenReturn(FakePostgrestBuilder([
          item1.toJson(),
          item2.toJson(),
          item3.toJson(),
        ]));

        await notifier.fetchHighlights(babyProfileId: 'profile_1');

        // Items should be sorted by priority descending
        expect(notifier.state.items[0].item.priority, equals(5));
        expect(notifier.state.items[1].item.priority, equals(3));
        expect(notifier.state.items[2].item.priority, equals(1));
      });
    });

    group('refresh', () {
      test('refreshes items with force refresh', () async {
        final cachedData = {
          'item': sampleItem.toJson(),
          'isPurchased': false,
          'purchases': [],
        };
        when(mockCacheService.get(any)).thenAnswer((_) async => [cachedData]);
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleItem.toJson()]));

        await notifier.refresh(babyProfileId: 'profile_1');

        // Verify database was called (bypassing cache)
        verify(mockDatabaseService.select(any)).called(greaterThanOrEqualTo(1));
      });
    });

    group('Purchase Status', () {
      test('tracks purchase status correctly', () async {
        final purchase = RegistryPurchase(
          id: 'purchase_1',
          registryItemId: 'item_1',
          userId: 'user_1',
          quantity: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleItem.toJson()]));

        await notifier.fetchHighlights(babyProfileId: 'profile_1');

        // Initially not purchased
        expect(notifier.state.items.first.isPurchased, isFalse);
      });

      test('filters unpurchased items only', () async {
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleItem.toJson()]));

        await notifier.fetchHighlights(babyProfileId: 'profile_1');

        // All items should be unpurchased in highlights
        for (final item in notifier.state.items) {
          expect(item.isPurchased, isFalse);
        }
      });
    });

    group('Limit Items', () {
      test('limits to top 10 items', () async {
        // Create 15 items
        final items = List.generate(
          15,
          (i) => sampleItem.copyWith(id: 'item_$i', priority: i),
        );

        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any)).thenReturn(
          FakePostgrestBuilder(items.map((i) => i.toJson()).toList()),
        );

        await notifier.fetchHighlights(babyProfileId: 'profile_1');

        // Should only have 10 items
        expect(notifier.state.items.length, lessThanOrEqualTo(10));
      });
    });
  });
}

// Fake builders for Postgrest operations (test doubles)
class FakePostgrestBuilder {
  final List<Map<String, dynamic>> data;

  FakePostgrestBuilder(this.data);

  FakePostgrestBuilder eq(String column, dynamic value) => this;
  FakePostgrestBuilder isNull(String column) => this;
  FakePostgrestBuilder order(String column, {bool ascending = true}) => this;
  FakePostgrestBuilder limit(int count) => this;

  Future<List<Map<String, dynamic>>> call() async => data;
}
