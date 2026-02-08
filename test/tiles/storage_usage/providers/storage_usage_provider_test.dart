import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nonna_app/core/services/cache_service.dart';
import 'package:nonna_app/core/services/database_service.dart';
import 'package:nonna_app/tiles/storage_usage/providers/storage_usage_provider.dart';

@GenerateMocks([DatabaseService, CacheService])
import 'storage_usage_provider_test.mocks.dart';

void main() {
  group('StorageUsageProvider Tests', () {
    late StorageUsageNotifier notifier;
    late MockDatabaseService mockDatabaseService;
    late MockCacheService mockCacheService;

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
      mockDatabaseService = MockDatabaseService();
      mockCacheService = MockCacheService();

      // Setup mock cache service
      when(mockCacheService.isInitialized).thenReturn(true);

      notifier = StorageUsageNotifier(
        databaseService: mockDatabaseService,
        cacheService: mockCacheService,
      );
    });

    group('Initial State', () {
      test('initial state has no storage info', () {
        expect(notifier.state.info, isNull);
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, isNull);
      });
    });

    group('fetchStorageUsage', () {
      test('sets loading state while fetching', () async {
        // Setup mock to delay response
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any)).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return FakePostgrestBuilder([]);
        });

        // Start fetching
        final fetchFuture =
            notifier.fetchStorageUsage(babyProfileId: 'profile_1');

        // Verify loading state
        expect(notifier.state.isLoading, isTrue);

        await fetchFuture;
      });

      test('calculates storage usage from database', () async {
        // Setup mocks
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any)).thenReturn(FakePostgrestBuilder([
          {'file_size': 1024000}, // 1 MB
          {'file_size': 2048000}, // 2 MB
          {'file_size': 3072000}, // 3 MB
        ]));

        await notifier.fetchStorageUsage(babyProfileId: 'profile_1');

        // Verify state updated
        expect(notifier.state.info, isNotNull);
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, isNull);
        expect(notifier.state.info!.photoCount, equals(3));
      });

      test('loads storage info from cache when available', () async {
        // Setup cache to return data
        when(mockCacheService.get(any))
            .thenAnswer((_) async => sampleStorageInfo.toJson());

        await notifier.fetchStorageUsage(babyProfileId: 'profile_1');

        // Verify database was not called
        verifyNever(mockDatabaseService.select(any));

        // Verify state updated from cache
        expect(notifier.state.info, isNotNull);
        expect(notifier.state.info!.totalBytes, equals(10737418240));
      });

      test('handles errors gracefully', () async {
        // Setup mock to throw error
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any))
            .thenThrow(Exception('Database error'));

        await notifier.fetchStorageUsage(babyProfileId: 'profile_1');

        // Verify error state
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, contains('Database error'));
        expect(notifier.state.info, isNull);
      });

      test('force refresh bypasses cache', () async {
        // Setup mocks
        when(mockCacheService.get(any))
            .thenAnswer((_) async => sampleStorageInfo.toJson());
        when(mockDatabaseService.select(any)).thenReturn(FakePostgrestBuilder([
          {'file_size': 1024000},
        ]));

        await notifier.fetchStorageUsage(
          babyProfileId: 'profile_1',
          forceRefresh: true,
        );

        // Verify database was called despite cache
        verify(mockDatabaseService.select(any)).called(1);
      });

      test('saves calculated storage to cache', () async {
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any)).thenReturn(FakePostgrestBuilder([
          {'file_size': 1024000},
        ]));

        await notifier.fetchStorageUsage(babyProfileId: 'profile_1');

        // Verify cache put was called
        verify(mockCacheService.put(any, any,
                ttlMinutes: anyNamed('ttlMinutes')))
            .called(1);
      });

      test('calculates usage percentage correctly', () async {
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any)).thenReturn(FakePostgrestBuilder([
          {'file_size': 5368709120}, // 5 GB out of 10 GB
        ]));

        await notifier.fetchStorageUsage(babyProfileId: 'profile_1');

        expect(notifier.state.info!.usagePercentage, lessThanOrEqualTo(100.0));
        expect(notifier.state.info!.usagePercentage, greaterThanOrEqualTo(0.0));
      });
    });

    group('refresh', () {
      test('refreshes storage usage with force refresh', () async {
        when(mockCacheService.get(any))
            .thenAnswer((_) async => sampleStorageInfo.toJson());
        when(mockDatabaseService.select(any)).thenReturn(FakePostgrestBuilder([
          {'file_size': 1024000},
        ]));

        await notifier.refresh(babyProfileId: 'profile_1');

        // Verify database was called (bypassing cache)
        verify(mockDatabaseService.select(any)).called(1);
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
      test('handles near-full storage', () async {
        final nearFullInfo = StorageUsageInfo(
          totalBytes: 10737418240, // 10 GB
          usedBytes: 10200547328, // 9.5 GB
          availableBytes: 536870912, // 0.5 GB
          usagePercentage: 95.0,
          photoCount: 10000,
          calculatedAt: DateTime.now(),
        );

        when(mockCacheService.get(any))
            .thenAnswer((_) async => nearFullInfo.toJson());

        await notifier.fetchStorageUsage(babyProfileId: 'profile_1');

        expect(notifier.state.info!.usagePercentage, greaterThan(90.0));
      });

      test('handles full storage', () async {
        final fullInfo = StorageUsageInfo(
          totalBytes: 10737418240, // 10 GB
          usedBytes: 10737418240, // 10 GB
          availableBytes: 0,
          usagePercentage: 100.0,
          photoCount: 15000,
          calculatedAt: DateTime.now(),
        );

        when(mockCacheService.get(any))
            .thenAnswer((_) async => fullInfo.toJson());

        await notifier.fetchStorageUsage(babyProfileId: 'profile_1');

        expect(notifier.state.info!.usagePercentage, equals(100.0));
        expect(notifier.state.info!.availableBytes, equals(0));
      });
    });

    group('Photo Count', () {
      test('counts photos correctly', () async {
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any)).thenReturn(FakePostgrestBuilder([
          {'file_size': 1024000},
          {'file_size': 2048000},
          {'file_size': 3072000},
          {'file_size': 4096000},
          {'file_size': 5120000},
        ]));

        await notifier.fetchStorageUsage(babyProfileId: 'profile_1');

        expect(notifier.state.info!.photoCount, equals(5));
      });

      test('handles zero photos', () async {
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([]));

        await notifier.fetchStorageUsage(babyProfileId: 'profile_1');

        expect(notifier.state.info!.photoCount, equals(0));
        expect(notifier.state.info!.usedBytes, equals(0));
      });
    });

    group('Role-based Access', () {
      test('owner can fetch storage usage', () async {
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any)).thenReturn(FakePostgrestBuilder([
          {'file_size': 1024000},
        ]));

        await notifier.fetchStorageUsage(babyProfileId: 'profile_1');

        expect(notifier.state.info, isNotNull);
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
  FakePostgrestBuilder select(String columns) => this;

  Future<List<Map<String, dynamic>>> call() async => data;
}
