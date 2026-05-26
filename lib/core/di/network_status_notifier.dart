import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';
import '../services/sync_manager.dart';
import '../../features/home/presentation/providers/home_screen_provider.dart';

/// Network Status Notifier
///
/// **Functional Requirements**: Section 3.6.8 – Offline-First Implementation
///
/// Monitors device connectivity and exposes a boolean `isOnline` state.
/// When the device transitions from offline → online, it triggers:
///   1. [SyncManager.forceFullSync] to refresh cached data
///   2. [HomeScreenNotifier.refresh] to reload home screen tiles
///
/// **Architecture note**: This notifier is intentionally NON-autoDispose so
/// it survives screen navigation and keeps monitoring connectivity for the
/// entire app lifecycle. [homeScreenProvider] is autoDispose; calling
/// [HomeScreenNotifier.refresh] is safe because it guards against a null
/// [selectedBabyProfileId] (no-op when disposed).
///
/// **Limitation**: [Connectivity] reports the network *type* (WiFi/mobile/none),
/// not actual internet reachability. Captive portals or DHCP failures may
/// produce false-positive "online" readings. [SyncManager]'s exponential
/// back-off handles failed refreshes gracefully.
class NetworkStatusNotifier extends Notifier<bool> {
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _previousIsOnline = true;

  @override
  bool build() {
    final connectivity = ref.read(connectivityWrapperProvider);

    // Async initial check — does not block build().
    connectivity.checkConnectivity().then((results) {
      if (!ref.mounted) return;
      final isOnline = _isOnlineFromResults(results);
      _previousIsOnline = isOnline;
      state = isOnline;
    });

    // Subscribe to connectivity changes.
    _subscription = connectivity.onConnectivityChanged.listen(
      (results) {
        final isOnline = _isOnlineFromResults(results);
        debugPrint(
            '🌐 Connectivity changed → ${isOnline ? "online" : "offline"}');

        if (!_previousIsOnline && isOnline) {
          // Transition: offline → online
          _handleReconnect();
        }

        _previousIsOnline = isOnline;
        state = isOnline;
      },
      onError: (Object error) {
        debugPrint('❌ NetworkStatusNotifier stream error: $error');
      },
    );

    ref.onDispose(() {
      _subscription?.cancel();
      _subscription = null;
    });

    // Default to online until the first async check resolves.
    return true;
  }

  /// Maps a list of [ConnectivityResult] values to a boolean.
  ///
  /// The device is considered online when at least one result is not [none].
  bool _isOnlineFromResults(List<ConnectivityResult> results) {
    return results.any((r) => r != ConnectivityResult.none);
  }

  /// Immediately marks the device as offline.
  ///
  /// Called by providers that catch a network-related exception (e.g.
  /// [SocketException]) *before* the OS connectivity event arrives.
  /// This bridges the timing gap between an HTTP failure (instant) and
  /// [Connectivity.onConnectivityChanged] (delayed by 100–500 ms or more).
  ///
  /// Idempotent: if already offline, this is a no-op. When the OS event
  /// eventually fires, [_previousIsOnline] is already `false`, so
  /// [_handleReconnect] will not be triggered spuriously.
  void markOffline() {
    if (_previousIsOnline) {
      _previousIsOnline = false;
      state = false;
      debugPrint('🌐 Network marked offline (detected via HTTP failure)');
    }
  }

  /// Immediately marks the device as online.
  ///
  /// Called by providers when a network request *succeeds*, confirming that
  /// connectivity is restored. This bridges the timing gap where
  /// [Connectivity.onConnectivityChanged] may not fire reliably on all
  /// platforms (e.g., Android emulators).
  ///
  /// Idempotent: if already online, this is a no-op. Does NOT trigger
  /// [_handleReconnect] — the successful request itself is the reconnect.
  void markOnline() {
    if (!_previousIsOnline) {
      _previousIsOnline = true;
      state = true;
      debugPrint(
          '🌐 Network marked online (detected via successful HTTP request)');
    }
  }

  /// Called when the device transitions from offline to online.
  ///
  /// Triggers a forced full sync and a home screen refresh.
  void _handleReconnect() {
    debugPrint('🔄 Network reconnected — triggering full sync + home refresh');

    try {
      ref.read(syncManagerProvider).forceFullSync();
    } catch (e) {
      debugPrint('⚠️  SyncManager forceFullSync error on reconnect: $e');
    }

    try {
      // homeScreenProvider is autoDispose; refresh() is a no-op when disposed.
      ref.read(homeScreenProvider.notifier).refresh();
    } catch (e) {
      debugPrint('⚠️  HomeScreenNotifier refresh error on reconnect: $e');
    }
  }
}
