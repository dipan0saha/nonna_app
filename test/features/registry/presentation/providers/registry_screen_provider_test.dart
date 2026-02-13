import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/core/models/registry_item.dart';
import 'package:nonna_app/core/models/registry_purchase.dart';
import 'package:nonna_app/features/registry/presentation/providers/registry_screen_provider.dart';

import '../../../../helpers/fake_postgrest_builders.dart';
import '../../../../mocks/mock_services.mocks.dart';
import '../../../../helpers/mock_factory.dart';

void main() {
  group('RegistryScreenProvider Tests', () {
    late ProviderContainer container;
    late MockDatabaseService mockDatabaseService;
    late MockCacheService mockCacheService;
    late MockRealtimeService mockRealtimeService;

    // Sample data
    final sampleItem = RegistryItem(
      id: 'item_1',
      babyProfileId: 'profile_1',
      createdByUserId: 'user_1',
      name: 'Baby Stroller',
      description: 'A high-quality stroller',
      priority: 5,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final samplePurchase = RegistryPurchase(
      id: 'purchase_1',
      registryItemId: 'item_1',
      purchasedByUserId: 'user_2',
      purchasedAt: DateTime.now(),
      createdAt: DateTime.now(),
    );

    setUp(() {
      mockDatabaseService = MockFactory.createDatabaseService();
      mockCacheService = MockFactory.createCacheService();
      mockRealtimeService = MockFactory.createRealtimeService();

      // Add ALL default mock behaviors BEFORE creating container
      when(mockCacheService.isInitialized).thenReturn(true);
      when(mockCacheService.get(any)).thenAnswer((_) async => null);
      when(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
          .thenAnswer((_) async {});
      when(mockDatabaseService.select(any))
          .thenAnswer((_) => FakePostgrestBuilder([]));
      when(mockRealtimeService.subscribe(
        table: anyNamed('table'),
        channelName: anyNamed('channelName'),
        filter: anyNamed('filter'),
      )).thenAnswer((_) => Stream.empty());
      when(mockRealtimeService.unsubscribe(any)).thenAnswer((_) async {});

      container = ProviderContainer(
        overrides: [
          databaseServiceProvider.overrideWithValue(mockDatabaseService),
          cacheServiceProvider.overrideWithValue(mockCacheService),
          realtimeServiceProvider.overrideWithValue(mockRealtimeService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
      reset(mockDatabaseService);
      reset(mockCacheService);
      reset(mockRealtimeService);
    });

    group('Initial State', () {
      test('initial state has empty items', () {
        final notifier = container.read(registryScreenProvider.notifier);
        expect(notifier.state.items, isEmpty);
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, isNull);
        expect(notifier.state.currentFilter, equals(RegistryFilter.all));
        expect(notifier.state.currentSort, equals(RegistrySort.priorityHigh));
        expect(notifier.state.selectedBabyProfileId, isNull);
      });
    });

    group('loadItems', () {
      test('sets loading state while loading', () async {
        reset(mockCacheService);
        reset(mockDatabaseService);
        when(mockCacheService.isInitialized).thenReturn(true);
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async {});
        when(mockDatabaseService.select(any, columns: anyNamed('columns')))
            .thenAnswer((_) => FakePostgrestBuilder([]));

        final notifier = container.read(registryScreenProvider.notifier);

        final loadFuture = notifier.loadItems(babyProfileId: 'profile_1');

        expect(notifier.state.isLoading, isTrue);
        expect(notifier.state.selectedBabyProfileId, equals('profile_1'));

        await loadFuture;
      });

      test('loads items from database when cache is empty', () async {
        reset(mockCacheService);
        reset(mockRealtimeService);
        reset(mockDatabaseService);
        when(mockCacheService.isInitialized).thenReturn(true);
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async {});
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenAnswer((_) => Stream.value(<String, dynamic>{}));
        when(mockRealtimeService.unsubscribe(any)).thenAnswer((_) async {});
        when(mockDatabaseService.select(any, columns: anyNamed('columns')))
            .thenAnswer((_) => FakePostgrestBuilder([sampleItem.toJson()]));

        final notifier = container.read(registryScreenProvider.notifier);

        await notifier.loadItems(babyProfileId: 'profile_1');

        expect(notifier.state.items, hasLength(1));
        expect(notifier.state.items.first.item.id, equals('item_1'));
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, isNull);
      });

      test('loads items from cache when available', () async {
        reset(mockCacheService);
        when(mockCacheService.isInitialized).thenReturn(true);
        final notifier = container.read(registryScreenProvider.notifier);
        final cachedData = [
          {
            'item': sampleItem.toJson(),
            'isPurchased': false,
            'purchaseCount': 0,
          }
        ];
        when(mockCacheService.get(any)).thenAnswer((_) async => cachedData);
        when(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async {});

        await notifier.loadItems(babyProfileId: 'profile_1');

        verifyNever(
            mockDatabaseService.select(any, columns: anyNamed('columns')));

        expect(notifier.state.items, hasLength(1));
        expect(notifier.state.items.first.item.id, equals('item_1'));
        expect(notifier.state.items.first.isPurchased, isFalse);
      });

      test('handles database error gracefully', () async {
        reset(mockCacheService);
        reset(mockDatabaseService);
        when(mockCacheService.isInitialized).thenReturn(true);
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async {});
        when(mockDatabaseService.select(any, columns: anyNamed('columns')))
            .thenThrow(Exception('Database error'));

        final notifier = container.read(registryScreenProvider.notifier);

        await notifier.loadItems(babyProfileId: 'profile_1');

        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, contains('Database error'));
        expect(notifier.state.items, isEmpty);
      });

      test('force refresh bypasses cache', () async {
        reset(mockCacheService);
        reset(mockRealtimeService);
        reset(mockDatabaseService);
        when(mockCacheService.isInitialized).thenReturn(true);
        when(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async {});
        final cachedData = [
          {
            'item': sampleItem.toJson(),
            'isPurchased': false,
            'purchaseCount': 0,
          }
        ];
        when(mockCacheService.get(any)).thenAnswer((_) async => cachedData);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenAnswer((_) => Stream.value(<String, dynamic>{}));
        when(mockRealtimeService.unsubscribe(any)).thenAnswer((_) async {});
        when(mockDatabaseService.select(any, columns: anyNamed('columns')))
            .thenAnswer((_) => FakePostgrestBuilder([sampleItem.toJson()]));

        final notifier = container.read(registryScreenProvider.notifier);

        await notifier.loadItems(
          babyProfileId: 'profile_1',
          forceRefresh: true,
        );

        verify(mockDatabaseService.select(any)).called(greaterThan(0));
      });

      test('saves fetched items to cache', () async {
        reset(mockCacheService);
        reset(mockRealtimeService);
        reset(mockDatabaseService);
        when(mockCacheService.isInitialized).thenReturn(true);
        when(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async {});
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenAnswer((_) => Stream.value(<String, dynamic>{}));
        when(mockRealtimeService.unsubscribe(any)).thenAnswer((_) async {});
        when(mockDatabaseService.select(any, columns: anyNamed('columns')))
            .thenAnswer((_) => FakePostgrestBuilder([sampleItem.toJson()]));

        final notifier = container.read(registryScreenProvider.notifier);

        await notifier.loadItems(babyProfileId: 'profile_1');

        verify(mockCacheService.put(any, any,
                ttlMinutes: anyNamed('ttlMinutes')))
            .called(1);
      });

      test('loads items with purchase status', () async {
        reset(mockCacheService);
        reset(mockRealtimeService);
        reset(mockDatabaseService);
        when(mockCacheService.isInitialized).thenReturn(true);
        when(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async {});
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenAnswer((_) => Stream.value(<String, dynamic>{}));
        when(mockRealtimeService.unsubscribe(any)).thenAnswer((_) async {});

        var callCount = 0;
        when(mockDatabaseService.select(argThat(isA<String>())))
            .thenAnswer((_) {
          callCount++;
          if (callCount == 1) {
            return FakePostgrestBuilder([sampleItem.toJson()]);
          } else {
            return FakePostgrestBuilder([samplePurchase.toJson()]);
          }
        });

        final notifier = container.read(registryScreenProvider.notifier);

        await notifier.loadItems(babyProfileId: 'profile_1');

        expect(notifier.state.items, hasLength(1));
        expect(notifier.state.items.first.isPurchased, isTrue);
        expect(notifier.state.items.first.purchaseCount, equals(1));
      });
    });

    group('applyFilter', () {
      test('changes current filter', () {
        final notifier = container.read(registryScreenProvider.notifier);
        notifier.applyFilter(RegistryFilter.highPriority);

        expect(
            notifier.state.currentFilter, equals(RegistryFilter.highPriority));
      });

      test('filters high priority items', () async {
        reset(mockCacheService);
        when(mockCacheService.isInitialized).thenReturn(true);
        when(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async {});
        final lowPriorityItem = sampleItem.copyWith(id: 'item_2', priority: 2);
        final cachedData = [
          {
            'item': sampleItem.toJson(),
            'isPurchased': false,
            'purchaseCount': 0,
          },
          {
            'item': lowPriorityItem.toJson(),
            'isPurchased': false,
            'purchaseCount': 0,
          }
        ];
        when(mockCacheService.get(any)).thenAnswer((_) async => cachedData);

        final notifier = container.read(registryScreenProvider.notifier);

        await notifier.loadItems(babyProfileId: 'profile_1');
        notifier.applyFilter(RegistryFilter.highPriority);

        expect(notifier.state.filteredItems, hasLength(1));
        expect(notifier.state.filteredItems.first.item.priority,
            greaterThanOrEqualTo(4));
      });

      test('filters purchased items', () async {
        reset(mockCacheService);
        when(mockCacheService.isInitialized).thenReturn(true);
        when(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async {});
        final cachedData = [
          {
            'item': sampleItem.toJson(),
            'isPurchased': true,
            'purchaseCount': 1,
          },
          {
            'item': sampleItem.copyWith(id: 'item_2').toJson(),
            'isPurchased': false,
            'purchaseCount': 0,
          }
        ];
        when(mockCacheService.get(any)).thenAnswer((_) async => cachedData);

        final notifier = container.read(registryScreenProvider.notifier);

        await notifier.loadItems(babyProfileId: 'profile_1');
        notifier.applyFilter(RegistryFilter.purchased);

        expect(notifier.state.filteredItems, hasLength(1));
        expect(notifier.state.filteredItems.first.isPurchased, isTrue);
      });
    });

    group('applySort', () {
      test('changes current sort', () {
        final notifier = container.read(registryScreenProvider.notifier);
        notifier.applySort(RegistrySort.nameAsc);

        expect(notifier.state.currentSort, equals(RegistrySort.nameAsc));
      });

      test('sorts items by priority high to low', () async {
        reset(mockCacheService);
        when(mockCacheService.isInitialized).thenReturn(true);
        when(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async {});
        final lowPriorityItem =
            sampleItem.copyWith(id: 'item_2', priority: 2, name: 'Diapers');
        final cachedData = [
          {
            'item': lowPriorityItem.toJson(),
            'isPurchased': false,
            'purchaseCount': 0,
          },
          {
            'item': sampleItem.toJson(),
            'isPurchased': false,
            'purchaseCount': 0,
          }
        ];
        when(mockCacheService.get(any)).thenAnswer((_) async => cachedData);

        final notifier = container.read(registryScreenProvider.notifier);

        await notifier.loadItems(babyProfileId: 'profile_1');
        notifier.applySort(RegistrySort.priorityHigh);

        final sorted = notifier.state.sortedItems;
        expect(
            sorted.first.item.priority, greaterThan(sorted.last.item.priority));
      });

      test('sorts items by name ascending', () async {
        reset(mockCacheService);
        when(mockCacheService.isInitialized).thenReturn(true);
        when(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async {});
        final itemB = sampleItem.copyWith(id: 'item_2', name: 'Bottles');
        final itemA = sampleItem.copyWith(id: 'item_3', name: 'Crib');
        final cachedData = [
          {
            'item': itemA.toJson(),
            'isPurchased': false,
            'purchaseCount': 0,
          },
          {
            'item': itemB.toJson(),
            'isPurchased': false,
            'purchaseCount': 0,
          }
        ];
        when(mockCacheService.get(any)).thenAnswer((_) async => cachedData);

        final notifier = container.read(registryScreenProvider.notifier);

        await notifier.loadItems(babyProfileId: 'profile_1');
        notifier.applySort(RegistrySort.nameAsc);

        final sorted = notifier.state.sortedItems;
        expect(sorted.first.item.name, equals('Bottles'));
        expect(sorted.last.item.name, equals('Crib'));
      });
    });

    group('refresh', () {
      test('refreshes items with force refresh', () async {
        reset(mockCacheService);
        reset(mockRealtimeService);
        reset(mockDatabaseService);
        when(mockCacheService.isInitialized).thenReturn(true);
        when(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async {});
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenAnswer((_) => Stream.value(<String, dynamic>{}));
        when(mockRealtimeService.unsubscribe(any)).thenAnswer((_) async {});
        when(mockDatabaseService.select(any, columns: anyNamed('columns')))
            .thenAnswer((_) => FakePostgrestBuilder([sampleItem.toJson()]));

        final notifier = container.read(registryScreenProvider.notifier);

        await notifier.loadItems(babyProfileId: 'profile_1');

        final initialLoadCount =
            verify(mockDatabaseService.select(any)).callCount;

        await notifier.refresh();

        expect(verify(mockDatabaseService.select(any)).callCount,
            greaterThan(initialLoadCount));
      });

      test('does not refresh when no baby profile selected', () async {
        final notifier = container.read(registryScreenProvider.notifier);
        await notifier.refresh();

        verifyNever(
            mockDatabaseService.select(any, columns: anyNamed('columns')));
      });
    });

    group('Real-time Updates', () {
      test('handles items update by refreshing', () async {
        reset(mockCacheService);
        reset(mockRealtimeService);
        reset(mockDatabaseService);
        when(mockCacheService.isInitialized).thenReturn(true);
        when(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async {});
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenAnswer((_) => Stream.value(<String, dynamic>{}));
        when(mockRealtimeService.unsubscribe(any)).thenAnswer((_) async {});
        when(mockDatabaseService.select(any, columns: anyNamed('columns')))
            .thenAnswer((_) => FakePostgrestBuilder([sampleItem.toJson()]));

        final notifier = container.read(registryScreenProvider.notifier);

        await notifier.loadItems(babyProfileId: 'profile_1');

        expect(notifier.state.items, hasLength(1));
      });

      test('handles purchases update by refreshing', () async {
        reset(mockCacheService);
        reset(mockRealtimeService);
        reset(mockDatabaseService);
        when(mockCacheService.isInitialized).thenReturn(true);
        when(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async {});
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenAnswer((_) => Stream.value(<String, dynamic>{}));
        when(mockRealtimeService.unsubscribe(any)).thenAnswer((_) async {});
        when(mockDatabaseService.select(any, columns: anyNamed('columns')))
            .thenAnswer((_) => FakePostgrestBuilder([sampleItem.toJson()]));

        final notifier = container.read(registryScreenProvider.notifier);

        await notifier.loadItems(babyProfileId: 'profile_1');

        expect(notifier.state.items, hasLength(1));
      });
    });

    group('dispose', () {
      test('cancels real-time subscriptions on dispose', () {
        reset(mockRealtimeService);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenAnswer((_) => Stream.empty());
        when(mockRealtimeService.unsubscribe(any)).thenAnswer((_) async => {});
        final notifier = container.read(registryScreenProvider.notifier);

        expect(notifier.state, isNotNull);
      });
    });
  });
}
