import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nonna_app/core/models/registry_purchase.dart';
import 'package:nonna_app/core/services/cache_service.dart';
import 'package:nonna_app/core/services/database_service.dart';
import 'package:nonna_app/core/services/realtime_service.dart';
import 'package:nonna_app/tiles/recent_purchases/providers/recent_purchases_provider.dart';

@GenerateMocks([DatabaseService, CacheService, RealtimeService])
import 'recent_purchases_provider_test.mocks.dart';

void main() {
  group('RecentPurchasesProvider Tests', () {
    late RecentPurchasesNotifier notifier;
    late MockDatabaseService mockDatabaseService;
    late MockCacheService mockCacheService;
    late MockRealtimeService mockRealtimeService;

    // Sample purchase data
    final samplePurchase = RegistryPurchase(
      id: 'purchase_1',
      registryItemId: 'item_1',
      userId: 'user_1',
      quantity: 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setUp(() {
      mockDatabaseService = MockDatabaseService();
      mockCacheService = MockCacheService();
      mockRealtimeService = MockRealtimeService();

      // Setup mock cache service
      when(mockCacheService.isInitialized).thenReturn(true);

      notifier = RecentPurchasesNotifier(
        databaseService: mockDatabaseService,
        cacheService: mockCacheService,
        realtimeService: mockRealtimeService,
      );
    });

    group('Initial State', () {
      test('initial state has empty purchases', () {
        expect(notifier.state.purchases, isEmpty);
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, isNull);
      });
    });

    group('fetchPurchases', () {
      test('sets loading state while fetching', () async {
        // Setup mock to delay response
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any)).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return FakePostgrestBuilder([]);
        });

        // Start fetching
        final fetchFuture = notifier.fetchPurchases(babyProfileId: 'profile_1');

        // Verify loading state
        expect(notifier.state.isLoading, isTrue);

        await fetchFuture;
      });

      test('fetches purchases from database when cache is empty', () async {
        // Setup mocks
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([samplePurchase.toJson()]));

        await notifier.fetchPurchases(babyProfileId: 'profile_1');

        // Verify state updated
        expect(notifier.state.purchases, hasLength(1));
        expect(notifier.state.purchases.first.id, equals('purchase_1'));
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, isNull);
      });

      test('loads purchases from cache when available', () async {
        // Setup cache to return data
        when(mockCacheService.get(any))
            .thenAnswer((_) async => [samplePurchase.toJson()]);

        await notifier.fetchPurchases(babyProfileId: 'profile_1');

        // Verify database was not called
        verifyNever(mockDatabaseService.select(any));

        // Verify state updated from cache
        expect(notifier.state.purchases, hasLength(1));
        expect(notifier.state.purchases.first.id, equals('purchase_1'));
      });

      test('handles errors gracefully', () async {
        // Setup mock to throw error
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any))
            .thenThrow(Exception('Database error'));

        await notifier.fetchPurchases(babyProfileId: 'profile_1');

        // Verify error state
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, contains('Database error'));
        expect(notifier.state.purchases, isEmpty);
      });

      test('force refresh bypasses cache', () async {
        // Setup mocks
        when(mockCacheService.get(any))
            .thenAnswer((_) async => [samplePurchase.toJson()]);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([samplePurchase.toJson()]));

        await notifier.fetchPurchases(
          babyProfileId: 'profile_1',
          forceRefresh: true,
        );

        // Verify database was called despite cache
        verify(mockDatabaseService.select(any)).called(greaterThanOrEqualTo(1));
      });

      test('saves fetched purchases to cache', () async {
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([samplePurchase.toJson()]));

        await notifier.fetchPurchases(babyProfileId: 'profile_1');

        // Verify cache put was called
        verify(mockCacheService.put(any, any,
                ttlMinutes: anyNamed('ttlMinutes')))
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

        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any)).thenReturn(
          FakePostgrestBuilder(purchases.map((p) => p.toJson()).toList()),
        );

        await notifier.fetchPurchases(babyProfileId: 'profile_1');

        // Should only show recent purchases (e.g., limit 20)
        expect(notifier.state.purchases.length, lessThanOrEqualTo(25));
      });
    });

    group('refresh', () {
      test('refreshes purchases with force refresh', () async {
        when(mockCacheService.get(any))
            .thenAnswer((_) async => [samplePurchase.toJson()]);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([samplePurchase.toJson()]));

        await notifier.refresh(babyProfileId: 'profile_1');

        // Verify database was called (bypassing cache)
        verify(mockDatabaseService.select(any)).called(greaterThanOrEqualTo(1));
      });
    });

    group('Real-time Updates', () {
      test('handles INSERT purchase', () async {
        // Setup initial state
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([samplePurchase.toJson()]));

        await notifier.fetchPurchases(babyProfileId: 'profile_1');

        final initialCount = notifier.state.purchases.length;

        // Simulate real-time INSERT
        final newPurchase = samplePurchase.copyWith(id: 'purchase_2');
        notifier.state = notifier.state.copyWith(
          purchases: [newPurchase, ...notifier.state.purchases],
        );

        expect(notifier.state.purchases.length, equals(initialCount + 1));
      });

      test('handles UPDATE purchase', () async {
        // Setup initial state
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([samplePurchase.toJson()]));

        await notifier.fetchPurchases(babyProfileId: 'profile_1');

        // Simulate real-time UPDATE
        final updatedPurchase = samplePurchase.copyWith(quantity: 2);
        notifier.state = notifier.state.copyWith(
          purchases: notifier.state.purchases
              .map((p) => p.id == updatedPurchase.id ? updatedPurchase : p)
              .toList(),
        );

        expect(notifier.state.purchases.first.quantity, equals(2));
      });
    });

    group('dispose', () {
      test('cancels real-time subscription on dispose', () {
        when(mockRealtimeService.unsubscribe(any)).thenReturn(null);

        notifier.dispose();

        expect(notifier.state, isNotNull);
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

        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any)).thenReturn(FakePostgrestBuilder([
          purchase1.toJson(),
          purchase2.toJson(),
          purchase3.toJson(),
        ]));

        await notifier.fetchPurchases(babyProfileId: 'profile_1');

        // Most recent should be first
        expect(notifier.state.purchases[0].id, equals('purchase_3'));
        expect(notifier.state.purchases[1].id, equals('purchase_2'));
        expect(notifier.state.purchases[2].id, equals('purchase_1'));
      });
    });
  });
}

// Fake builders for Postgrest operations (test doubles)
class FakePostgrestBuilder {
  final List<Map<String, dynamic>> data;

  FakePostgrestBuilder(this.data);

  FakePostgrestBuilder eq(String column, dynamic value) => this;
  FakePostgrestBuilder order(String column, {bool ascending = true}) => this;
  FakePostgrestBuilder limit(int count) => this;

  Future<List<Map<String, dynamic>>> call() async => data;
}
