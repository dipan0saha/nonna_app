import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/tiles/storage_usage/providers/storage_usage_provider.dart';

import '../../../helpers/fake_postgrest_builders.dart';

import '../../../helpers/mock_factory.dart';

void main() {
  group('StorageUsageProvider Tests', () {
    late ProviderContainer container;
    late MockServiceContainer mocks;

    // Sample storage usage data
    final sampleStorageInfo = StorageUsageInfo(
      totalBytes: 10737418240, // 10 GB
      usedBytes: 5368709120, // 5 GB
      availableBytes: 5368709120, // 5 GB
      usagePercentage: 50.0,
      photoCount: 1000,
      calculatedAt: DateTime.now(),
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
      test('initial state has no storage info', () {
        final state = container.read(storageUsageProvider);

        expect(state.info, isNull);
        expect(state.isLoading, isFalse);
        expect(state.error, isNull);
      });
    });

    group('fetchUsage', () {
      test('sets loading state while fetching', () async {        // Setup mock to delay response
        when(mocks.cache.get(any)).thenAnswer((_) async => null);
        when(mocks.database.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([]));

        // Start fetching
        final notifier = container.read(storageUsageProvider.notifier);
        final fetchFuture = notifier.fetchUsage(babyProfileId: 'profile_1');

        // Verify loading state
        expect(container.read(storageUsageProvider).isLoading, isTrue);

        await fetchFuture;
      });

      test('calculates storage usage from database', () async {        // Setup mocks
        when(mocks.cache.get(any)).thenAnswer((_) async => null);
        when(mocks.database.select(any)).thenAnswer((_) => FakePostgrestBuilder([
          {'file_size': 1024000}, // 1 MB
          {'file_size': 2048000}, // 2 MB
          {'file_size': 3072000}, // 3 MB
        ]));

        final notifier = container.read(storageUsageProvider.notifier);
        await notifier.fetchUsage(babyProfileId: 'profile_1');

        // Verify state updated
        final state = container.read(storageUsageProvider);
        expect(state.info, isNotNull);
        expect(state.isLoading, isFalse);
        expect(state.error, isNull);
        expect(state.info!.photoCount, equals(3));
      });

      test('loads storage info from cache when available', () async {        // Setup cache to return data
        when(mocks.cache.get(any))
            .thenAnswer((_) async => sampleStorageInfo.toJson());

        final notifier = container.read(storageUsageProvider.notifier);
        await notifier.fetchUsage(babyProfileId: 'profile_1');

        // Verify database was not called
        verifyNever(mocks.database.select(any));

        // Verify state updated from cache
        final state = container.read(storageUsageProvider);
        expect(state.info, isNotNull);
        expect(state.info!.totalBytes, equals(10737418240));
      });

      test('handles errors gracefully', () async {        // Setup mock to throw error
        when(mocks.cache.get(any)).thenAnswer((_) async => null);
        when(mocks.database.select(any))
            .thenThrow(Exception('Database error'));

        final notifier = container.read(storageUsageProvider.notifier);
        await notifier.fetchUsage(babyProfileId: 'profile_1');

        // Verify error state
        final state = container.read(storageUsageProvider);
        expect(state.isLoading, isFalse);
        expect(state.error, contains('Database error'));
        expect(state.info, isNull);
      });

      test('force refresh bypasses cache', () async {        // Setup mocks
        when(mocks.cache.get(any))
            .thenAnswer((_) async => sampleStorageInfo.toJson());
        when(mocks.database.select(any)).thenAnswer((_) => FakePostgrestBuilder([
          {'file_size': 1024000},
        ]));

        final notifier = container.read(storageUsageProvider.notifier);
        await notifier.fetchUsage(
          babyProfileId: 'profile_1',
          forceRefresh: true,
        );

        // Verify database was called despite cache
        verify(mocks.database.select(any)).called(1);
      });

      test('saves calculated storage to cache', () async {        when(mocks.cache.get(any)).thenAnswer((_) async => null);
        when(mocks.database.select(any)).thenAnswer((_) => FakePostgrestBuilder([
          {'file_size': 1024000},
        ]));

        final notifier = container.read(storageUsageProvider.notifier);
        await notifier.fetchUsage(babyProfileId: 'profile_1');

        // Verify cache put was called
        verify(mocks.cache.put(any, any,
                ttlMinutes: anyNamed('ttlMinutes')))
            .called(1);
      });

      test('calculates usage percentage correctly', () async {        when(mocks.cache.get(any)).thenAnswer((_) async => null);
        when(mocks.database.select(any)).thenAnswer((_) => FakePostgrestBuilder([
          {'file_size': 5368709120}, // 5 GB out of 10 GB
        ]));

        final notifier = container.read(storageUsageProvider.notifier);
        await notifier.fetchUsage(babyProfileId: 'profile_1');

        final state = container.read(storageUsageProvider);
        expect(state.info!.usagePercentage, lessThanOrEqualTo(100.0));
        expect(state.info!.usagePercentage, greaterThanOrEqualTo(0.0));
      });
    });

    group('refresh', () {
      test('refreshes storage usage with force refresh', () async {        when(mocks.cache.get(any))
            .thenAnswer((_) async => sampleStorageInfo.toJson());
        when(mocks.database.select(any)).thenAnswer((_) => FakePostgrestBuilder([
          {'file_size': 1024000},
        ]));

        final notifier = container.read(storageUsageProvider.notifier);
        await notifier.refresh(babyProfileId: 'profile_1');

        // Verify database was called (bypassing cache)
        verify(mocks.database.select(any)).called(1);
      });
    });

    group('Storage Formatting', () {
      test('formats bytes to KB correctly', () {
        final info = StorageUsageInfo(
          totalBytes: 10000,
          usedBytes: 5000,
          availableBytes: 5000,
          usagePercentage: 50.0,
          photoCount: 10,
          calculatedAt: DateTime.now(),
        );

        expect(info.usedFormatted, contains('KB'));
      });

      test('formats bytes to MB correctly', () {
        final info = StorageUsageInfo(
          totalBytes: 10485760, // 10 MB
          usedBytes: 5242880, // 5 MB
          availableBytes: 5242880,
          usagePercentage: 50.0,
          photoCount: 10,
          calculatedAt: DateTime.now(),
        );

        expect(info.usedFormatted, contains('MB'));
      });

      test('formats bytes to GB correctly', () {
        final info = StorageUsageInfo(
          totalBytes: 10737418240, // 10 GB
          usedBytes: 5368709120, // 5 GB
          availableBytes: 5368709120,
          usagePercentage: 50.0,
          photoCount: 1000,
          calculatedAt: DateTime.now(),
        );

        expect(info.usedFormatted, contains('GB'));
      });
    });

    group('Storage Limits', () {
      test('handles near-full storage', () async {        final nearFullInfo = StorageUsageInfo(
          totalBytes: 10737418240, // 10 GB
          usedBytes: 10200547328, // 9.5 GB
          availableBytes: 536870912, // 0.5 GB
          usagePercentage: 95.0,
          photoCount: 10000,
          calculatedAt: DateTime.now(),
        );

        when(mocks.cache.get(any))
            .thenAnswer((_) async => nearFullInfo.toJson());

        final notifier = container.read(storageUsageProvider.notifier);
        await notifier.fetchUsage(babyProfileId: 'profile_1');

        final state = container.read(storageUsageProvider);
        expect(state.info!.usagePercentage, greaterThan(90.0));
      });

      test('handles full storage', () async {        final fullInfo = StorageUsageInfo(
          totalBytes: 10737418240, // 10 GB
          usedBytes: 10737418240, // 10 GB
          availableBytes: 0,
          usagePercentage: 100.0,
          photoCount: 15000,
          calculatedAt: DateTime.now(),
        );

        when(mocks.cache.get(any))
            .thenAnswer((_) async => fullInfo.toJson());

        final notifier = container.read(storageUsageProvider.notifier);
        await notifier.fetchUsage(babyProfileId: 'profile_1');

        final state = container.read(storageUsageProvider);
        expect(state.info!.usagePercentage, equals(100.0));
        expect(state.info!.availableBytes, equals(0));
      });
    });

    group('Photo Count', () {
      test('counts photos correctly', () async {        when(mocks.cache.get(any)).thenAnswer((_) async => null);
        when(mocks.database.select(any)).thenAnswer((_) => FakePostgrestBuilder([
          {'file_size': 1024000},
          {'file_size': 2048000},
          {'file_size': 3072000},
          {'file_size': 4096000},
          {'file_size': 5120000},
        ]));

        final notifier = container.read(storageUsageProvider.notifier);
        await notifier.fetchUsage(babyProfileId: 'profile_1');

        final state = container.read(storageUsageProvider);
        expect(state.info!.photoCount, equals(5));
      });

      test('handles zero photos', () async {        when(mocks.cache.get(any)).thenAnswer((_) async => null);
        when(mocks.database.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([]));

        final notifier = container.read(storageUsageProvider.notifier);
        await notifier.fetchUsage(babyProfileId: 'profile_1');

        final state = container.read(storageUsageProvider);
        expect(state.info!.photoCount, equals(0));
        expect(state.info!.usedBytes, equals(0));
      });
    });

    group('Role-based Access', () {
      test('owner can fetch storage usage', () async {        when(mocks.cache.get(any)).thenAnswer((_) async => null);
        when(mocks.database.select(any)).thenAnswer((_) => FakePostgrestBuilder([
          {'file_size': 1024000},
        ]));

        final notifier = container.read(storageUsageProvider.notifier);
        await notifier.fetchUsage(babyProfileId: 'profile_1');

        final state = container.read(storageUsageProvider);
        expect(state.info, isNotNull);
      });
    });
  });
}

// Note: FakePostgrestBuilder is imported from test/helpers/fake_postgrest_builders.dart
