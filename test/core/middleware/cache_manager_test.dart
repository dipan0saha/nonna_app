import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nonna_app/core/middleware/cache_manager.dart';

import '../../mocks/mock_services.mocks.dart';
import '../../helpers/mock_factory.dart';

void main() {
  late MockCacheService mockCacheService;
  late CacheManager cacheManager;

  setUp(() {
    mockCacheService = MockFactory.createCacheService();
    cacheManager = CacheManager(mockCacheService);
  });

  group('CacheManager', () {
    group('constants', () {
      test('has correct cache warming strategies', () {
        expect(CacheManager.warmOnAppStart, 'warm_on_app_start');
        expect(CacheManager.warmOnDemand, 'warm_on_demand');
        expect(CacheManager.warmOnBackground, 'warm_on_background');
      });

      test('has correct cache eviction policies', () {
        expect(CacheManager.lruEviction, 'lru');
        expect(CacheManager.lfuEviction, 'lfu');
        expect(CacheManager.fifoEviction, 'fifo');
      });

      test('has correct TTL presets', () {
        expect(CacheManager.shortTtl, 5);
        expect(CacheManager.mediumTtl, 30);
        expect(CacheManager.longTtl, 60);
        expect(CacheManager.veryLongTtl, 1440);
      });
    });

    group('getOrFetch', () {
      test('returns cached data when available', () async {
        when(mockCacheService.get<String>('test-key'))
            .thenAnswer((_) async => 'cached-value');

        final result = await cacheManager.getOrFetch<String>(
          key: 'test-key',
          fetchFunction: () async => 'fetched-value',
        );

        expect(result, 'cached-value');
        verify(mockCacheService.get<String>('test-key')).called(1);
        verifyNever(
            mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')));
      });

      test('fetches and caches data when not in cache', () async {
        when(mockCacheService.get<String>('test-key'))
            .thenAnswer((_) async => null);
        when(mockCacheService.put('test-key', 'fetched-value',
                ttlMinutes: null))
            .thenAnswer((_) async => {});

        final result = await cacheManager.getOrFetch<String>(
          key: 'test-key',
          fetchFunction: () async => 'fetched-value',
        );

        expect(result, 'fetched-value');
        verify(mockCacheService.get<String>('test-key')).called(1);
        verify(mockCacheService.put('test-key', 'fetched-value',
                ttlMinutes: null))
            .called(1);
      });

      test('caches data with TTL', () async {
        when(mockCacheService.get<String>('test-key'))
            .thenAnswer((_) async => null);
        when(mockCacheService.put('test-key', 'fetched-value', ttlMinutes: 30))
            .thenAnswer((_) async => {});

        await cacheManager.getOrFetch<String>(
          key: 'test-key',
          fetchFunction: () async => 'fetched-value',
          ttlMinutes: 30,
        );

        verify(mockCacheService.put('test-key', 'fetched-value',
                ttlMinutes: 30))
            .called(1);
      });

      test('throws error when fetch function fails', () async {
        when(mockCacheService.get<String>('test-key'))
            .thenAnswer((_) async => null);

        expect(
          () => cacheManager.getOrFetch<String>(
            key: 'test-key',
            fetchFunction: () async => throw Exception('Fetch failed'),
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('invalidateByPattern', () {
      test('invalidates matching cache entries', () async {
        when(mockCacheService.getAllKeys()).thenReturn(
            ['baby_123_events', 'baby_123_photos', 'user_456_profile']);
        when(mockCacheService.delete(any)).thenAnswer((_) async => {});

        await cacheManager.invalidateByPattern('baby_123');

        verify(mockCacheService.delete('baby_123_events')).called(1);
        verify(mockCacheService.delete('baby_123_photos')).called(1);
        verifyNever(mockCacheService.delete('user_456_profile'));
      });

      test('handles empty key list', () async {
        when(mockCacheService.getAllKeys()).thenReturn([]);

        await cacheManager.invalidateByPattern('pattern');

        verifyNever(mockCacheService.delete(any));
      });
    });

    group('invalidateByPrefix', () {
      test('invalidates entries with matching prefix', () async {
        when(mockCacheService.getAllKeys())
            .thenReturn(['baby_123_events', 'baby_456_events', 'user_789']);
        when(mockCacheService.delete(any)).thenAnswer((_) async => {});

        await cacheManager.invalidateByPrefix('baby_123');

        verify(mockCacheService.delete('baby_123_events')).called(1);
        verifyNever(mockCacheService.delete('baby_456_events'));
        verifyNever(mockCacheService.delete('user_789'));
      });
    });

    group('invalidateBabyProfile', () {
      test('calls cache service invalidateByBabyProfile', () async {
        when(mockCacheService.invalidateByBabyProfile('baby-123'))
            .thenAnswer((_) async => {});

        await cacheManager.invalidateBabyProfile('baby-123');

        verify(mockCacheService.invalidateByBabyProfile('baby-123')).called(1);
      });
    });

    group('warmCache', () {
      test('warms cache with provided loaders', () async {
        when(mockCacheService.has(any)).thenAnswer((_) async => false);
        when(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async => {});

        final loaders = <String, Future<dynamic> Function()>{
          'key1': () async => 'value1',
          'key2': () async => 'value2',
        };

        await cacheManager.warmCache(loaders);

        verify(mockCacheService.put('key1', 'value1',
                ttlMinutes: CacheManager.mediumTtl))
            .called(1);
        verify(mockCacheService.put('key2', 'value2',
                ttlMinutes: CacheManager.mediumTtl))
            .called(1);
      });

      test('skips already cached entries', () async {
        when(mockCacheService.has('key1')).thenAnswer((_) async => true);
        when(mockCacheService.has('key2')).thenAnswer((_) async => false);
        when(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async => {});

        final loaders = <String, Future<dynamic> Function()>{
          'key1': () async => 'value1',
          'key2': () async => 'value2',
        };

        await cacheManager.warmCache(loaders);

        verifyNever(mockCacheService.put('key1', any,
            ttlMinutes: anyNamed('ttlMinutes')));
        verify(mockCacheService.put('key2', 'value2',
                ttlMinutes: CacheManager.mediumTtl))
            .called(1);
      });
    });

    group('getCacheStats', () {
      test('returns correct cache statistics', () async {
        when(mockCacheService.getAllKeys())
            .thenReturn(['key1', 'key2', 'key3']);
        when(mockCacheService.getCacheSize())
            .thenAnswer((_) async => 1024 * 1024 * 5); // 5 MB

        final stats = await cacheManager.getCacheStats();

        expect(stats['total_entries'], 3);
        expect(stats['cache_size_bytes'], 1024 * 1024 * 5);
        expect(stats['cache_size_mb'], '5.00');
      });

      test('handles errors gracefully', () async {
        when(mockCacheService.getAllKeys()).thenThrow(Exception('Error'));

        final stats = await cacheManager.getCacheStats();

        expect(stats.containsKey('error'), true);
      });
    });

    group('cache key builders', () {
      test('babyProfileKey builds correct key', () {
        final key = CacheManager.babyProfileKey('baby-123', 'events');
        expect(key, 'baby_baby-123_events');
      });

      test('userKey builds correct key', () {
        final key = CacheManager.userKey('user-456', 'profile');
        expect(key, 'user_user-456_profile');
      });

      test('tileKey builds correct key', () {
        final key = CacheManager.tileKey('baby-123', 'home', 'upcoming_events');
        expect(key, 'baby_baby-123_screen_home_tile_upcoming_events');
      });

      test('eventKey builds correct key', () {
        final key = CacheManager.eventKey('baby-123', 'event-789');
        expect(key, 'baby_baby-123_event_event-789');
      });

      test('photoKey builds correct key', () {
        final key = CacheManager.photoKey('baby-123', 'photo-101');
        expect(key, 'baby_baby-123_photo_photo-101');
      });
    });

    group('applyEvictionPolicy', () {
      test('does not evict when size is within limit', () async {
        when(mockCacheService.getCacheSize())
            .thenAnswer((_) async => 10 * 1024 * 1024); // 10 MB

        await cacheManager.applyEvictionPolicy(maxSizeBytes: 50 * 1024 * 1024);

        verifyNever(mockCacheService.cleanupExpired());
      });

      test('applies eviction when size exceeds limit', () async {
        when(mockCacheService.getCacheSize())
            .thenAnswer((_) async => 60 * 1024 * 1024); // 60 MB
        when(mockCacheService.cleanupExpired()).thenAnswer((_) async => {});

        await cacheManager.applyEvictionPolicy(maxSizeBytes: 50 * 1024 * 1024);

        verify(mockCacheService.cleanupExpired()).called(1);
      });
    });
  });
}
