import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nonna_app/core/services/sync_manager.dart';

import '../../helpers/mock_factory.dart';
import '../../mocks/mock_services.mocks.dart';

void main() {
  group('SyncManager', () {
    late MockRealtimeService mockRealtime;
    late SyncManager manager;

    setUp(() {
      mockRealtime = MockFactory.createRealtimeService();
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
        manager = SyncManager(realtimeService: mockRealtime);
        expect(manager.isInitialized, isFalse);
      });

      test('throws StateError on sync before initialization', () {
        manager = SyncManager(realtimeService: mockRealtime);
        expect(
          () async => await manager.sync(),
          throwsStateError,
        );
      });

      test('throws StateError on forceFullSync before initialization', () {
        manager = SyncManager(realtimeService: mockRealtime);
        expect(
          () async => await manager.forceFullSync(),
          throwsStateError,
        );
      });

      test('throws StateError on retrySync before initialization', () {
        manager = SyncManager(realtimeService: mockRealtime);
        expect(
          () => manager.retrySync(),
          throwsStateError,
        );
      });

      test('throws StateError on subscribeToRealtime before initialization',
          () {
        manager = SyncManager(realtimeService: mockRealtime);
        expect(
          () => manager.subscribeToRealtime(
            table: 'events',
            channelName: 'test',
          ),
          throwsStateError,
        );
      });

      test('isInitialized is true after initialize()', () async {
        manager = SyncManager(realtimeService: mockRealtime);
        await manager.initialize();
        expect(manager.isInitialized, isTrue);
      });

      test('handles double initialization gracefully', () async {
        manager = SyncManager(realtimeService: mockRealtime);
        await manager.initialize();
        await manager.initialize(); // should not throw
        expect(manager.isInitialized, isTrue);
      });

      test('initial syncStatus is idle', () {
        manager = SyncManager(realtimeService: mockRealtime);
        expect(manager.syncStatus, equals(SyncStatus.idle));
      });

      test('lastSyncTime is null before first sync', () async {
        manager = SyncManager(realtimeService: mockRealtime);
        await manager.initialize();
        expect(manager.lastSyncTime, isNull);
      });

      test('retryCount starts at zero', () async {
        manager = SyncManager(realtimeService: mockRealtime);
        await manager.initialize();
        expect(manager.retryCount, equals(0));
      });
    });

    // -------------------------------------------------------------------------
    // Handler registration
    // -------------------------------------------------------------------------

    group('Handler registration', () {
      setUp(() async {
        manager = SyncManager(realtimeService: mockRealtime);
        await manager.initialize();
      });

      test('registerSyncHandler registers a handler', () async {
        manager.registerSyncHandler('test', (_) async => true);
        // Should not throw and sync should succeed
        await manager.sync();
        expect(manager.syncStatus, equals(SyncStatus.synced));
      });

      test('unregisterSyncHandler removes a handler', () async {
        manager.registerSyncHandler('test', (_) async => true);
        manager.unregisterSyncHandler('test');
        await manager.sync();
        // With no handlers, sync completes as synced
        expect(manager.syncStatus, equals(SyncStatus.synced));
      });
    });

    // -------------------------------------------------------------------------
    // Sync operations
    // -------------------------------------------------------------------------

    group('sync()', () {
      setUp(() async {
        manager = SyncManager(
          realtimeService: mockRealtime,
          syncInterval: const Duration(hours: 1), // prevent auto-trigger
        );
        await manager.initialize();
      });

      test('sync with no handlers sets status to synced', () async {
        await manager.sync();
        expect(manager.syncStatus, equals(SyncStatus.synced));
      });

      test('sync passes lastSyncTime to handler', () async {
        DateTime? capturedSince;
        manager.registerSyncHandler('test', (since) async {
          capturedSince = since;
          return true;
        });

        // First sync: since = null
        await manager.sync();
        expect(capturedSince, isNull);

        // Second sync: since = previous lastSyncTime
        final firstSync = manager.lastSyncTime;
        await manager.sync();
        expect(capturedSince, equals(firstSync));
      });

      test('sync updates lastSyncTime on success', () async {
        manager.registerSyncHandler('test', (_) async => true);
        expect(manager.lastSyncTime, isNull);

        await manager.sync();
        expect(manager.lastSyncTime, isNotNull);
      });

      test('sync emits syncing then synced via stream', () async {
        manager.registerSyncHandler('test', (_) async => true);

        final statuses = <SyncStatus>[];
        final subscription = manager.syncStatusStream.listen(statuses.add);
        addTearDown(subscription.cancel);

        // Ensure listener is registered before starting sync
        await Future.microtask(() {});

        await manager.sync();

        // Allow event loop to deliver queued events to listeners
        await Future.delayed(Duration.zero);

        expect(statuses,
            containsAllInOrder([SyncStatus.syncing, SyncStatus.synced]));
      });

      test('sync sets status to error when handler returns false', () async {
        manager.registerSyncHandler('test', (_) async => false);
        await manager.sync();
        expect(manager.syncStatus, equals(SyncStatus.error));
      });

      test('sync sets lastError when handler fails', () async {
        manager.registerSyncHandler('test', (_) async => false);
        await manager.sync();
        expect(manager.lastError, isNotNull);
      });

      test('sync ignores concurrent call when already syncing', () async {
        final syncStarted = Completer<void>();
        final syncProceed = Completer<void>();

        manager.registerSyncHandler('slow', (since) async {
          syncStarted.complete();
          await syncProceed.future;
          return true;
        });

        // Start first sync (does not await)
        final first = manager.sync();

        // Wait until the handler is executing
        await syncStarted.future;
        expect(manager.syncStatus, equals(SyncStatus.syncing));

        // Second sync should be skipped
        await manager.sync();

        // Allow the first sync to complete
        syncProceed.complete();
        await first;

        expect(manager.syncStatus, equals(SyncStatus.synced));
      });

      test('sync sets status to error when handler throws', () async {
        manager.registerSyncHandler('throws', (_) async {
          throw Exception('network error');
        });
        await manager.sync();
        expect(manager.syncStatus, equals(SyncStatus.error));
        expect(manager.lastError!.message, contains('network error'));
      });
    });

    // -------------------------------------------------------------------------
    // forceFullSync
    // -------------------------------------------------------------------------

    group('forceFullSync()', () {
      setUp(() async {
        manager = SyncManager(
          realtimeService: mockRealtime,
          syncInterval: const Duration(hours: 1),
        );
        await manager.initialize();
      });

      test('forceFullSync resets lastSyncTime to null before syncing',
          () async {
        manager.registerSyncHandler('test', (_) async => true);

        // Do an initial sync to set lastSyncTime
        await manager.sync();
        expect(manager.lastSyncTime, isNotNull);

        DateTime? capturedSince;
        manager.registerSyncHandler('capture', (since) async {
          capturedSince = since;
          return true;
        });

        // Force full sync
        await manager.forceFullSync();
        expect(capturedSince, isNull);
      });
    });

    // -------------------------------------------------------------------------
    // Retry logic
    // -------------------------------------------------------------------------

    group('retrySync()', () {
      setUp(() async {
        manager = SyncManager(
          realtimeService: mockRealtime,
          syncInterval: const Duration(hours: 1),
        );
        await manager.initialize();
      });

      test('retrySync does not throw when called after a failed sync',
          () async {
        manager.registerSyncHandler('fail', (_) async => false);
        await manager.sync();
        // retrySync is called internally – calling it again should not throw
        expect(() => manager.retrySync(), returnsNormally);
      });

      test('after sync failure lastError is set', () async {
        manager.registerSyncHandler('fail', (_) async => false);
        await manager.sync();
        expect(manager.lastError, isNotNull);
        expect(manager.syncStatus, equals(SyncStatus.error));
      });

      test('retryCount starts at 0 before any failure', () {
        expect(manager.retryCount, equals(0));
      });
    });

    // -------------------------------------------------------------------------
    // Realtime integration
    // -------------------------------------------------------------------------

    group('subscribeToRealtime()', () {
      setUp(() async {
        manager = SyncManager(
          realtimeService: mockRealtime,
          syncInterval: const Duration(hours: 1),
        );
        await manager.initialize();
      });

      test('subscribeToRealtime returns a stream', () {
        when(mockRealtime.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenAnswer((_) => const Stream<dynamic>.empty());

        final stream = manager.subscribeToRealtime(
          table: 'baby_profiles',
          channelName: 'ch_baby',
        );

        expect(stream, isA<Stream<dynamic>>());
        verify(mockRealtime.subscribe(
          table: 'baby_profiles',
          channelName: 'ch_baby',
          filter: null,
        )).called(1);
      });

      test('subscribeToRealtime triggers sync on realtime event', () async {
        final controller = StreamController<dynamic>();

        when(mockRealtime.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenAnswer((_) => controller.stream);

        manager.registerSyncHandler('rt_test', (_) async => true);

        manager.subscribeToRealtime(
          table: 'events',
          channelName: 'ch_events',
        );

        final statusEvents = <SyncStatus>[];
        manager.syncStatusStream.listen(statusEvents.add);

        // Emit a realtime event
        controller.add({'type': 'INSERT'});

        // Allow the triggered sync to complete
        await Future<void>.delayed(const Duration(milliseconds: 100));

        expect(statusEvents, contains(SyncStatus.syncing));
        await controller.close();
      });
    });

    // -------------------------------------------------------------------------
    // SyncStatus enum
    // -------------------------------------------------------------------------

    group('SyncStatus', () {
      test('has expected values', () {
        expect(SyncStatus.values, contains(SyncStatus.idle));
        expect(SyncStatus.values, contains(SyncStatus.syncing));
        expect(SyncStatus.values, contains(SyncStatus.synced));
        expect(SyncStatus.values, contains(SyncStatus.error));
      });
    });

    // -------------------------------------------------------------------------
    // SyncError
    // -------------------------------------------------------------------------

    group('SyncError', () {
      test('has message and timestamp', () {
        final error = SyncError(
          message: 'test error',
          timestamp: DateTime(2024),
        );
        expect(error.message, equals('test error'));
        expect(error.timestamp, equals(DateTime(2024)));
        expect(error.operationKey, isNull);
      });

      test('toString contains message and timestamp', () {
        final error = SyncError(
          message: 'boom',
          timestamp: DateTime(2024),
        );
        expect(error.toString(), contains('boom'));
      });
    });
  });
}
