import 'dart:async';

import 'package:flutter/foundation.dart';

/// Manages real-time subscriptions safely within Riverpod lifecycle callbacks
///
/// This service addresses Riverpod's constraint that prevents calling ref.read()
/// inside onDispose() callbacks by providing a safe way to cancel subscriptions
/// without accessing providers during disposal.
class RealtimeSubscriptionManager {
  final Map<String, StreamSubscription<dynamic>> _activeSubscriptions = {};

  /// Subscribe to a stream and store the subscription for later cleanup
  ///
  /// [id] Unique identifier for the subscription
  /// [stream] The stream to subscribe to
  /// [onData] Callback for handling stream events
  /// Returns the StreamSubscription for manual control if needed
  StreamSubscription<T> subscribe<T>(
    String id,
    Stream<T> stream,
    void Function(T) onData,
  ) {
    // Cancel any existing subscription with the same id
    _activeSubscriptions[id]?.cancel();

    final subscription = stream.listen(onData);
    _activeSubscriptions[id] = subscription;

    debugPrint('✅ Realtime subscription created: $id');
    return subscription;
  }

  /// Cancel a specific subscription
  ///
  /// [id] The subscription identifier to cancel
  void unsubscribe(String id) {
    final subscription = _activeSubscriptions[id];
    if (subscription != null) {
      subscription.cancel();
      _activeSubscriptions.remove(id);
      debugPrint('✅ Realtime subscription cancelled: $id');
    }
  }

  /// Cancel all active subscriptions
  ///
  /// Safe to call from Riverpod lifecycle callbacks (onDispose)
  void dispose() {
    final ids = List<String>.from(_activeSubscriptions.keys);
    for (final id in ids) {
      unsubscribe(id);
    }
    debugPrint('✅ All realtime subscriptions disposed');
  }

  /// Get the number of active subscriptions (for debugging/testing)
  int get activeSubscriptionCount => _activeSubscriptions.length;

  /// Check if a subscription is active
  bool isSubscribed(String id) => _activeSubscriptions.containsKey(id);
}
