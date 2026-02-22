import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nonna_app/core/services/offline_cache_manager.dart';

import '../../mocks/mock_services.mocks.dart';

void main() {
  group('OfflineCacheManager', () {
    late MockCacheService mockCache;
    late OfflineCacheManager manager;

    /// Returns a MockCacheService pre-configured for common operations.
    MockCacheService _buildCache() {
      final mock = MockCacheService();
      when(mock.get<String>(any)).thenAnswer((_) async => null);
      when(mock.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
          .thenAnswer((_) async {});
      when(mock.delete(any)).thenAnswer((_) async {});
      return mock;
    }

    setUp(() {
      mockCache = _buildCache();
    });

    tearDown(() async {
      if (manager.isInitialized) {
        await manager.dispose();
      }
    });

    // -------------------------------------------------------------------------
    // Initialization
    // -------------------------------------------------------------------------

    group('Initialization', () {
      test('starts as not initialized', () {
        manager = OfflineCacheManager(cacheService: mockCache);
        expect(manager.isInitialized, isFalse);
      });

      test('throws StateError on cacheData before initialization', () {
        manager = OfflineCacheManager(cacheService: mockCache);
        expect(
          () async => await manager.cacheData('key', {'v': 1}),
          throwsStateError,
        );
      });

      test('throws StateError on checkConnectivity before initialization', () {
        manager = OfflineCacheManager(cacheService: mockCache);
        expect(
          () async => await manager.checkConnectivity(),
          throwsStateError,
        );
      });

      test('throws StateError on processQueue before initialization', () {
        manager = OfflineCacheManager(cacheService: mockCache);
        expect(
          () async => await manager.processQueue(),
          throwsStateError,
        );
      });

      test('isInitialized is true after initialize()', () async {
        manager = OfflineCacheManager(cacheService: mockCache);
        await manager.initialize();
        expect(manager.isInitialized, isTrue);
      });

      test('handles double initialization gracefully', () async {
        manager = OfflineCacheManager(cacheService: mockCache);
        await manager.initialize();
        await manager.initialize(); // should not throw
        expect(manager.isInitialized, isTrue);
      });

      test('pendingSyncCount starts at zero', () async {
        manager = OfflineCacheManager(cacheService: mockCache);
        await manager.initialize();
        expect(manager.pendingSyncCount, equals(0));
      });
    });

    // -------------------------------------------------------------------------
    // Connectivity
    // -------------------------------------------------------------------------

    group('Connectivity', () {
      test('checkConnectivity returns true when checker returns true',
          () async {
        manager = OfflineCacheManager(
          cacheService: mockCache,
          connectivityChecker: () async => true,
        );
        await manager.initialize();
        expect(await manager.checkConnectivity(), isTrue);
      });

      test('checkConnectivity returns false when checker returns false',
          () async {
        manager = OfflineCacheManager(
          cacheService: mockCache,
          connectivityChecker: () async => false,
        );
        await manager.initialize();
        expect(await manager.checkConnectivity(), isFalse);
      });

      test('updateConnectivity toggles isOnline', () async {
        manager = OfflineCacheManager(cacheService: mockCache);
        await manager.initialize();

        manager.updateConnectivity(false);
        expect(manager.isOnline, isFalse);

        manager.updateConnectivity(true);
        expect(manager.isOnline, isTrue);
      });

      test('connectivityStream emits false when going offline', () async {
        manager = OfflineCacheManager(cacheService: mockCache);
        await manager.initialize();

        expectLater(manager.connectivityStream, emits(isFalse));
        manager.updateConnectivity(false);
      });

      test('connectivityStream emits true when coming back online', () async {
        manager = OfflineCacheManager(cacheService: mockCache);
        await manager.initialize();
        manager.updateConnectivity(false); // go offline first

        expectLater(manager.connectivityStream, emits(isTrue));
        manager.updateConnectivity(true);
      });

      test('does not emit duplicate connectivity events', () async {
        manager = OfflineCacheManager(cacheService: mockCache);
        await manager.initialize();

        final events = <bool>[];
        manager.connectivityStream.listen(events.add);

        manager.updateConnectivity(true); // same state – no emit
        manager.updateConnectivity(false);
        manager.updateConnectivity(false); // same state – no emit

        await Future<void>.delayed(Duration.zero);
        expect(events, equals([false]));
      });
    });

    // -------------------------------------------------------------------------
    // Cache operations – online
    // -------------------------------------------------------------------------

    group('Cache operations (online)', () {
      setUp(() async {
        manager = OfflineCacheManager(
          cacheService: mockCache,
          connectivityChecker: () async => true,
        );
        await manager.initialize();
      });

      test('cacheData calls cache put when online', () async {
        await manager.cacheData('my_key', {'name': 'test'});
        verify(mockCache.put('my_key', any)).called(1);
      });

      test('cacheData does not enqueue when online', () async {
        await manager.cacheData('my_key', {'name': 'test'});
        expect(manager.pendingSyncCount, equals(0));
      });

      test('deleteData calls cache delete when online', () async {
        await manager.deleteData('del_key');
        verify(mockCache.delete('del_key')).called(1);
      });

      test('getData returns decoded map', () async {
        when(mockCache.get<String>('data_key'))
            .thenAnswer((_) async => jsonEncode({'answer': 42}));
        final result =
            await manager.getData<Map<String, dynamic>>('data_key');
        expect(result, isNotNull);
        expect(result!['answer'], equals(42));
      });

      test('getData returns null for missing key', () async {
        when(mockCache.get<String>('missing')).thenAnswer((_) async => null);
        final result =
            await manager.getData<Map<String, dynamic>>('missing');
        expect(result, isNull);
      });
    });

    // -------------------------------------------------------------------------
    // Cache operations – offline queue
    // -------------------------------------------------------------------------

    group('Cache operations (offline)', () {
      setUp(() async {
        manager = OfflineCacheManager(cacheService: mockCache);
        await manager.initialize();
        manager.updateConnectivity(false);
      });

      test('cacheData enqueues operation when offline', () async {
        await manager.cacheData('offline_key', {'x': 42});
        expect(manager.pendingSyncCount, equals(1));
      });

      test('deleteData enqueues operation when offline', () async {
        await manager.deleteData('del_key');
        expect(manager.pendingSyncCount, equals(1));
      });

      test('multiple operations accumulate in queue', () async {
        await manager.cacheData('k1', {'a': 1});
        await manager.cacheData('k2', {'b': 2});
        await manager.deleteData('k3');
        expect(manager.pendingSyncCount, equals(3));
      });

      test('clearQueue empties the sync queue', () async {
        await manager.cacheData('k1', {'a': 1});
        await manager.clearQueue();
        expect(manager.pendingSyncCount, equals(0));
      });

      test('cacheData does NOT call cache put when offline', () async {
        // put is only called for the sync-queue persistence, not the user key
        await manager.cacheData('offline_key', {'x': 1});
        verifyNever(mockCache.put('offline_key', any));
      });
    });

    // -------------------------------------------------------------------------
    // processQueue
    // -------------------------------------------------------------------------

    group('processQueue', () {
      test('applies queued update operations', () async {
        manager = OfflineCacheManager(cacheService: mockCache);
        await manager.initialize();
        manager.updateConnectivity(false);

        await manager.cacheData('queued_key', {'value': 99});
        expect(manager.pendingSyncCount, equals(1));

        manager.updateConnectivity(true);
        await manager.processQueue();

        expect(manager.pendingSyncCount, equals(0));
        verify(mockCache.put('queued_key', any)).called(1);
      });

      test('applies queued delete operations', () async {
        manager = OfflineCacheManager(cacheService: mockCache);
        await manager.initialize();
        manager.updateConnectivity(false);

        await manager.deleteData('del_key');
        manager.updateConnectivity(true);
        await manager.processQueue();

        expect(manager.pendingSyncCount, equals(0));
        verify(mockCache.delete('del_key')).called(1);
      });

      test('processQueue does nothing when queue is empty', () async {
        manager = OfflineCacheManager(cacheService: mockCache);
        await manager.initialize();
        // should not throw
        await manager.processQueue();
        expect(manager.pendingSyncCount, equals(0));
      });
    });

    // -------------------------------------------------------------------------
    // Conflict resolution
    // -------------------------------------------------------------------------

    group('Conflict resolution', () {
      setUp(() async {
        manager = OfflineCacheManager(
          cacheService: mockCache,
          conflictResolutionStrategy: ConflictResolutionStrategy.lastWriteWins,
        );
        await manager.initialize();
      });

      test('lastWriteWins returns local when local is newer', () {
        final now = DateTime.now();
        final earlier = now.subtract(const Duration(minutes: 1));
        final result = manager.resolveConflict(
          localData: {'data': 'local'},
          remoteData: {'data': 'remote'},
          localTimestamp: now,
          remoteTimestamp: earlier,
        );
        expect(result['data'], equals('local'));
      });

      test('lastWriteWins returns remote when remote is newer', () {
        final now = DateTime.now();
        final earlier = now.subtract(const Duration(minutes: 1));
        final result = manager.resolveConflict(
          localData: {'data': 'local'},
          remoteData: {'data': 'remote'},
          localTimestamp: earlier,
          remoteTimestamp: now,
        );
        expect(result['data'], equals('remote'));
      });

      test('lastWriteWins returns remote when no timestamps provided', () {
        final result = manager.resolveConflict(
          localData: {'data': 'local'},
          remoteData: {'data': 'remote'},
        );
        expect(result['data'], equals('remote'));
      });

      test('remoteWins always returns remote data', () async {
        final remoteManager = OfflineCacheManager(
          cacheService: mockCache,
          conflictResolutionStrategy: ConflictResolutionStrategy.remoteWins,
        );
        await remoteManager.initialize();
        final result = remoteManager.resolveConflict(
          localData: {'data': 'local'},
          remoteData: {'data': 'remote'},
        );
        expect(result['data'], equals('remote'));
        await remoteManager.dispose();
      });

      test('localWins always returns local data', () async {
        final localManager = OfflineCacheManager(
          cacheService: mockCache,
          conflictResolutionStrategy: ConflictResolutionStrategy.localWins,
        );
        await localManager.initialize();
        final result = localManager.resolveConflict(
          localData: {'data': 'local'},
          remoteData: {'data': 'remote'},
        );
        expect(result['data'], equals('local'));
        await localManager.dispose();
      });
    });

    // -------------------------------------------------------------------------
    // SyncOperation serialisation
    // -------------------------------------------------------------------------

    group('SyncOperation', () {
      test('serialises to and from JSON', () {
        final op = SyncOperation(
          id: 'op_1',
          key: 'test_key',
          type: SyncOperationType.update,
          timestamp: DateTime(2024, 1, 15, 12),
          data: {'name': 'Alice'},
          retryCount: 2,
        );

        final restored = SyncOperation.fromJson(op.toJson());
        expect(restored.id, equals(op.id));
        expect(restored.key, equals(op.key));
        expect(restored.type, equals(op.type));
        expect(restored.timestamp, equals(op.timestamp));
        expect(restored.data, equals(op.data));
        expect(restored.retryCount, equals(op.retryCount));
      });

      test('copyWith updates retryCount', () {
        final op = SyncOperation(
          id: 'op_2',
          key: 'k',
          type: SyncOperationType.create,
          timestamp: DateTime(2024),
          retryCount: 0,
        );
        final updated = op.copyWith(retryCount: 3);
        expect(updated.retryCount, equals(3));
        expect(updated.id, equals(op.id));
      });

      test('all SyncOperationType values survive round-trip', () {
        for (final type in SyncOperationType.values) {
          final op = SyncOperation(
            id: 'op_$type',
            key: 'k',
            type: type,
            timestamp: DateTime.now(),
          );
          final restored = SyncOperation.fromJson(op.toJson());
          expect(restored.type, equals(type));
        }
      });
    });
  });
}
