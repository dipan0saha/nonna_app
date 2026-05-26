import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/core/services/realtime_service.dart';
import 'package:nonna_app/core/services/sync_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../helpers/fake_connectivity_wrapper.dart';

// ---------------------------------------------------------------------------
// Stubs — no external mock library required
// ---------------------------------------------------------------------------

/// A [SyncManager] subclass that records calls without any I/O.
class _FakeSyncManager extends SyncManager {
  _FakeSyncManager(RealtimeService realtimeService)
      : super(realtimeService: realtimeService);

  int forceFullSyncCallCount = 0;

  @override
  Future<void> initialize() async {
    // no-op — avoid starting background timers in tests
  }

  @override
  Future<void> forceFullSync() async {
    forceFullSyncCallCount++;
  }

  @override
  Future<void> dispose() async {
    // no-op
  }
}

// Creates a minimal [_FakeSyncManager] without hitting platform channels.
_FakeSyncManager _makeFakeSyncManager() {
  // SupabaseClient can be constructed with fake credentials without opening
  // any network connections.  RealtimeService stores but never uses it here
  // because _FakeSyncManager overrides every method that would access it.
  final fakeClient = SupabaseClient(
    'https://fake.supabase.co',
    'fake-anon-key',
    realtimeClientOptions: const RealtimeClientOptions(
      eventsPerSecond: 10,
    ),
  );
  return _FakeSyncManager(RealtimeService(fakeClient));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('NetworkStatusNotifier', () {
    late FakeConnectivityWrapper fakeConnectivity;
    late _FakeSyncManager fakeSyncManager;
    late ProviderContainer container;

    setUp(() {
      fakeConnectivity = FakeConnectivityWrapper(
        initial: [ConnectivityResult.wifi],
      );
      fakeSyncManager = _makeFakeSyncManager();
    });

    tearDown(() async {
      container.dispose();
      await fakeConnectivity.dispose();
    });

    ProviderContainer makeContainer({bool initialOnline = true}) {
      if (!initialOnline) {
        fakeConnectivity.setInitialResults([ConnectivityResult.none]);
      }
      return ProviderContainer(
        overrides: [
          connectivityWrapperProvider.overrideWithValue(fakeConnectivity),
          syncManagerProvider.overrideWithValue(fakeSyncManager),
        ],
      );
    }

    // -------------------------------------------------------------------------
    // 1. Initial state
    // -------------------------------------------------------------------------
    test('1. initial state is true before first stream event', () {
      container = makeContainer();
      // Default — assume online until async checkConnectivity() resolves.
      expect(container.read(isOnlineProvider), isTrue);
    });

    // -------------------------------------------------------------------------
    // 2. Goes offline
    // -------------------------------------------------------------------------
    test('2. state becomes false when stream emits ConnectivityResult.none',
        () async {
      container = makeContainer();
      expect(container.read(isOnlineProvider), isTrue);

      fakeConnectivity.emit([ConnectivityResult.none]);
      await Future<void>.delayed(Duration.zero);

      expect(container.read(isOnlineProvider), isFalse);
    });

    // -------------------------------------------------------------------------
    // 3. Comes back online
    // -------------------------------------------------------------------------
    test('3. state becomes true again when stream emits wifi after none',
        () async {
      container = makeContainer();
      expect(container.read(isOnlineProvider), isTrue);

      fakeConnectivity.emit([ConnectivityResult.none]);
      await Future<void>.delayed(Duration.zero);
      expect(container.read(isOnlineProvider), isFalse);

      fakeConnectivity.emit([ConnectivityResult.wifi]);
      await Future<void>.delayed(Duration.zero);
      expect(container.read(isOnlineProvider), isTrue);
    });

    // -------------------------------------------------------------------------
    // 4. Reconnect triggers SyncManager.forceFullSync exactly once
    // -------------------------------------------------------------------------
    test('4. forceFullSync called exactly once on offline→online transition',
        () async {
      container = makeContainer();
      expect(container.read(isOnlineProvider), isTrue);
      expect(fakeSyncManager.forceFullSyncCallCount, equals(0));

      fakeConnectivity.emit([ConnectivityResult.none]);
      await Future<void>.delayed(Duration.zero);
      expect(container.read(isOnlineProvider), isFalse);
      expect(fakeSyncManager.forceFullSyncCallCount, equals(0));

      fakeConnectivity.emit([ConnectivityResult.wifi]);
      await Future<void>.delayed(Duration.zero);
      expect(container.read(isOnlineProvider), isTrue);
      expect(fakeSyncManager.forceFullSyncCallCount, equals(1));
    });

    // -------------------------------------------------------------------------
    // 5. Online→online (no transition) — forceFullSync NOT called
    // -------------------------------------------------------------------------
    test('5. forceFullSync NOT called on online→online (no real transition)',
        () async {
      container = makeContainer();
      expect(container.read(isOnlineProvider), isTrue);

      // Emit online again — previousIsOnline was already true.
      fakeConnectivity.emit([ConnectivityResult.wifi]);
      await Future<void>.delayed(Duration.zero);
      expect(container.read(isOnlineProvider), isTrue);
      expect(fakeSyncManager.forceFullSyncCallCount, equals(0));
    });

    // -------------------------------------------------------------------------
    // 6. Multiple reconnect cycles — forceFullSync count tracks correctly
    // -------------------------------------------------------------------------
    test('6. forceFullSync called once per offline→online cycle', () async {
      container = makeContainer();
      // Trigger provider build so the connectivity stream listener is attached.
      expect(container.read(isOnlineProvider), isTrue);

      // First cycle.
      fakeConnectivity.emit([ConnectivityResult.none]);
      await Future<void>.delayed(Duration.zero);
      fakeConnectivity.emit([ConnectivityResult.wifi]);
      await Future<void>.delayed(Duration.zero);
      expect(fakeSyncManager.forceFullSyncCallCount, equals(1));

      // Second cycle.
      fakeConnectivity.emit([ConnectivityResult.none]);
      await Future<void>.delayed(Duration.zero);
      fakeConnectivity.emit([ConnectivityResult.mobile]);
      await Future<void>.delayed(Duration.zero);
      expect(fakeSyncManager.forceFullSyncCallCount, equals(2));
    });

    // -------------------------------------------------------------------------
    // 7. Cleanup on dispose — stream events ignored after container is disposed
    // -------------------------------------------------------------------------
    test('7. after dispose, stream events no longer update state', () async {
      container = makeContainer();
      expect(container.read(isOnlineProvider), isTrue);

      // Dispose triggers ref.onDispose → _subscription.cancel().
      container.dispose();

      // Emitting after disposal should not throw and should be ignored.
      fakeConnectivity.emit([ConnectivityResult.none]);
      await Future<void>.delayed(Duration.zero);
    });
  });
}
