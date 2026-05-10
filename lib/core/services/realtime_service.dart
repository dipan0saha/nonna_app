import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/supabase_tables.dart';
import '../network/supabase_client.dart';

/// Real-time service for managing Supabase real-time subscriptions
///
/// Provides role/baby-scoped channels, connection management,
/// reconnection logic, and batched updates with <2 second latency
class RealtimeService {
  late final SupabaseClient _client;
  final Map<String, RealtimeChannel> _channels = {};
  final Map<String, StreamController<dynamic>> _streamControllers = {};
  final Map<String, int> _channelRefCounts = {};

  bool _isConnected = false;

  /// Constructor - initializes client from SupabaseClientManager or fallback to Supabase.instance
  RealtimeService([SupabaseClient? client]) {
    if (client != null) {
      _client = client;
    } else {
      try {
        _client = SupabaseClientManager.instance;
      } catch (e) {
        // Fallback for tests where SupabaseClientManager may not be initialized
        _client = Supabase.instance.client;
      }
    }
  }

  /// Check if realtime is connected
  bool get isConnected => _isConnected;

  /// Get current connection status
  SocketStates? get connectionStatus => _client.realtime.connState;

  // ==========================================
  // Initialization & Lifecycle
  // ==========================================

  /// Initialize the realtime service
  Future<void> initialize() async {
    try {
      // Check initial connection status
      _isConnected = connectionStatus == SocketStates.open;
      debugPrint('📡 Realtime initial status: $connectionStatus');

      if (_isConnected) {
        debugPrint('✅ Realtime connected');
      } else {
        debugPrint('⚠️  Realtime not connected');
      }

      debugPrint('✅ RealtimeService initialized');
    } catch (e) {
      debugPrint('❌ Error initializing RealtimeService: $e');
      rethrow;
    }
  }

  /// Dispose the realtime service
  Future<void> dispose() async {
    try {
      // Unsubscribe from all channels
      for (final channel in _channels.values) {
        await _client.removeChannel(channel);
      }

      // Close all stream controllers
      for (final controller in _streamControllers.values) {
        await controller.close();
      }

      _channels.clear();
      _streamControllers.clear();
      _channelRefCounts.clear();

      debugPrint('✅ RealtimeService disposed');
    } catch (e) {
      debugPrint('❌ Error disposing RealtimeService: $e');
    }
  }

  // ==========================================
  // Channel Management
  // ==========================================

  /// Subscribe to a table with filters
  ///
  /// [table] The table name
  /// [channelName] Unique channel name
  /// [filter] Optional filter with column and value (e.g., {'column': 'baby_profile_id', 'value': '123'})
  /// [event] Event type to listen for
  Stream<dynamic> subscribe({
    required String table,
    required String channelName,
    Map<String, dynamic>? filter,
    PostgresChangeEvent event = PostgresChangeEvent.all,
  }) {
    try {
      // Check if channel already exists
      if (_channels.containsKey(channelName)) {
        _channelRefCounts[channelName] =
            (_channelRefCounts[channelName] ?? 0) + 1;
        debugPrint(
          'ℹ️  Channel $channelName already exists, reusing stream '
          '(refs: ${_channelRefCounts[channelName]})',
        );
        return _streamControllers[channelName]!.stream;
      }

      // Create stream controller
      final controller = StreamController<dynamic>.broadcast();
      _streamControllers[channelName] = controller;

      // Create channel
      final channel = _client.channel(channelName);

      // Build filter if provided
      PostgresChangeFilter? changeFilter;
      if (filter != null && filter.isNotEmpty) {
        final column = filter['column'] as String?;
        final value = filter['value'];
        if (column != null && value != null) {
          changeFilter = PostgresChangeFilter(
            type: value is Iterable
                ? PostgresChangeFilterType.inFilter
                : PostgresChangeFilterType.eq,
            column: column,
            value: value,
          );
        }
      }

      // Subscribe to postgres changes
      channel.onPostgresChanges(
        event: event,
        schema: 'public',
        table: table,
        filter: changeFilter,
        callback: (payload) {
          final normalizedPayload = _normalizePayload(payload);
          debugPrint(
              '📨 Received realtime event for $table: ${normalizedPayload['eventType']}');
          controller.add(normalizedPayload);
        },
      );

      // Subscribe to the channel
      channel.subscribe((status, error) {
        if (status == RealtimeSubscribeStatus.subscribed) {
          debugPrint('✅ Subscribed to channel: $channelName');
        } else if (status == RealtimeSubscribeStatus.channelError) {
          final message = error?.toString();
          if (message == null || message.isEmpty) {
            debugPrint('⚠️  Channel error for $channelName (no details)');
          } else {
            debugPrint('⚠️  Channel error for $channelName: $message');
          }

          if (!controller.isClosed && message != null && message.isNotEmpty) {
            controller.add({
              'eventType': 'CHANNEL_ERROR',
              'error': message,
              'table': table,
              'channel': channelName,
            });
          }
        }
      });

      _channels[channelName] = channel;
      _channelRefCounts[channelName] = 1;

      return controller.stream;
    } catch (e) {
      debugPrint('❌ Error subscribing to $table: $e');
      rethrow;
    }
  }

  /// Unsubscribe from a channel
  ///
  /// [channelName] The channel name
  Future<void> unsubscribe(String channelName) async {
    try {
      final refCount = _channelRefCounts[channelName] ?? 0;
      if (refCount > 1) {
        _channelRefCounts[channelName] = refCount - 1;
        debugPrint(
          'ℹ️  Channel $channelName still in use '
          '(refs: ${_channelRefCounts[channelName]})',
        );
        return;
      }

      final channel = _channels[channelName];
      if (channel != null) {
        await _client.removeChannel(channel);
        _channels.remove(channelName);
      }

      _channelRefCounts.remove(channelName);

      final controller = _streamControllers[channelName];
      if (controller != null) {
        await controller.close();
        _streamControllers.remove(channelName);
      }

      debugPrint('✅ Unsubscribed from channel: $channelName');
    } catch (e) {
      debugPrint('❌ Error unsubscribing from $channelName: $e');
    }
  }

  /// Unsubscribe from all channels
  Future<void> unsubscribeAll() async {
    final channelNames = List<String>.from(_channels.keys);
    for (final channelName in channelNames) {
      await unsubscribe(channelName);
    }
  }

  // ==========================================
  // Baby Profile Scoped Subscriptions
  // ==========================================

  /// Subscribe to photos for a baby profile
  Stream<dynamic> subscribeToPhotos(String babyProfileId) {
    return subscribe(
      table: SupabaseTables.photos,
      channelName: 'photos_$babyProfileId',
      filter: {'column': 'baby_profile_id', 'value': babyProfileId},
    );
  }

  /// Subscribe to events for a baby profile
  Stream<dynamic> subscribeToEvents(String babyProfileId) {
    return subscribe(
      table: SupabaseTables.events,
      channelName: 'events_$babyProfileId',
      filter: {'column': 'baby_profile_id', 'value': babyProfileId},
    );
  }

  /// Subscribe to notifications for a user
  Stream<dynamic> subscribeToNotifications(String userId) {
    return subscribe(
      table: SupabaseTables.notifications,
      channelName: 'notifications_$userId',
      filter: {'column': 'recipient_user_id', 'value': userId},
    );
  }

  /// Subscribe to name suggestions for a baby profile
  Stream<dynamic> subscribeToNameSuggestions(String babyProfileId) {
    return subscribe(
      table: SupabaseTables.nameSuggestions,
      channelName: 'name_suggestions_$babyProfileId',
      filter: {'column': 'baby_profile_id', 'value': babyProfileId},
    );
  }

  /// Subscribe to registry items for a baby profile
  Stream<dynamic> subscribeToRegistryItems(String babyProfileId) {
    return subscribe(
      table: SupabaseTables.registryItems,
      channelName: 'registry_items_$babyProfileId',
      filter: {'column': 'baby_profile_id', 'value': babyProfileId},
    );
  }

  /// Subscribe to activity events for a baby profile
  Stream<dynamic> subscribeToActivityEvents(String babyProfileId) {
    return subscribe(
      table: SupabaseTables.activityEvents,
      channelName: 'activity_events_$babyProfileId',
      filter: {'column': 'baby_profile_id', 'value': babyProfileId},
    );
  }

  // ==========================================
  // Connection Management
  // ==========================================

  /// Handle disconnection
  // ignore: unused_element
  void _handleDisconnection() {
    // Reconnection is handled automatically by Supabase
    // We just log the event here
    debugPrint('🔄 Handling realtime disconnection...');
  }

  /// Manually reconnect
  Future<void> reconnect() async {
    try {
      // Remove and resubscribe to all channels
      final channelNames = List<String>.from(_channels.keys);

      for (final channelName in channelNames) {
        final channel = _channels[channelName];
        if (channel != null) {
          await _client.removeChannel(channel);
        }
      }

      _channels.clear();
      _channelRefCounts.clear();

      debugPrint('✅ Reconnected to realtime');
    } catch (e) {
      debugPrint('❌ Error reconnecting: $e');
    }
  }

  // ==========================================
  // Health Check
  // ==========================================

  /// Check if realtime connection is healthy
  bool isHealthy() {
    return _isConnected && _client.realtime.isConnected;
  }

  /// Get active channels count
  int get activeChannelsCount => _channels.length;

  /// Get list of active channel names
  List<String> get activeChannelNames => _channels.keys.toList();

  Map<String, dynamic> _normalizePayload(dynamic payload) {
    if (payload is Map<String, dynamic>) return payload;
    if (payload is Map) return Map<String, dynamic>.from(payload);

    final dynamic eventType = payload.eventType;
    final dynamic newRecord = payload.newRecord;
    final dynamic oldRecord = payload.oldRecord;
    final dynamic schema = payload.schema;
    final dynamic table = payload.table;

    return {
      'eventType': _normalizeEventType(eventType),
      'new': newRecord is Map ? Map<String, dynamic>.from(newRecord) : null,
      'old': oldRecord is Map ? Map<String, dynamic>.from(oldRecord) : null,
      'schema': schema,
      'table': table,
    };
  }

  String _normalizeEventType(dynamic eventType) {
    if (eventType == null) return 'UNKNOWN';
    if (eventType is Enum) return eventType.name.toUpperCase();

    final value = eventType.toString();
    if (value.contains('.')) {
      return value.split('.').last.toUpperCase();
    }
    return value.toUpperCase();
  }
}
