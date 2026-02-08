import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/performance_limits.dart';
import '../../../core/constants/supabase_tables.dart';
import '../../../core/di/providers.dart';
import '../../../core/models/notification.dart' as app_notification;

/// Notifications provider for the Notifications tile
///
/// **Functional Requirements**: Section 3.5.4 - Tile-Specific Providers
/// Reference: docs/Core_development_component_identification.md
///
/// Features:
/// - Fetches notifications from Supabase
/// - Read/unread state management
/// - Real-time updates via Supabase subscriptions
/// - Badge count calculation
/// - Local caching with TTL
///
/// Dependencies: DatabaseService, CacheService, RealtimeService, Notification model

/// State class for notifications
class NotificationsState {
  final List<app_notification.Notification> notifications;
  final bool isLoading;
  final String? error;
  final int unreadCount;

  const NotificationsState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
    this.unreadCount = 0,
  });

  NotificationsState copyWith({
    List<app_notification.Notification>? notifications,
    bool? isLoading,
    String? error,
    int? unreadCount,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

/// Notifications provider
///
/// Manages notifications with read/unread state and real-time updates.
class NotificationsNotifier extends Notifier<NotificationsState> {

  // Configuration
  static const String _cacheKeyPrefix = 'notifications';
  static const int _maxNotifications = 50;

  String? _subscriptionId;

  @override
  NotificationsState build() {
    ref.onDispose(() {
      _cancelRealtimeSubscription();
    });
    return const NotificationsState();
  }

  // ==========================================
  // Public Methods
  // ==========================================

  /// Fetch notifications for a specific user
  ///
  /// [userId] The user identifier
  /// [forceRefresh] Whether to bypass cache and fetch from server
  Future<void> fetchNotifications({
    required String userId,
    bool forceRefresh = false,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Try to load from cache first
      if (!forceRefresh) {
        final cachedNotifications = await _loadFromCache(userId);
        if (cachedNotifications != null && cachedNotifications.isNotEmpty) {
          final unreadCount =
              cachedNotifications.where((n) => !n.isRead).length;
          state = state.copyWith(
            notifications: cachedNotifications,
            isLoading: false,
            unreadCount: unreadCount,
          );
          return;
        }
      }

      // Fetch from database
      final notifications = await _fetchFromDatabase(userId);
      final unreadCount = notifications.where((n) => !n.isRead).length;

      // Save to cache
      await _saveToCache(userId, notifications);

      state = state.copyWith(
        notifications: notifications,
        isLoading: false,
        unreadCount: unreadCount,
      );

      // Setup real-time subscription
      await _setupRealtimeSubscription(userId);

      debugPrint(
        '✅ Loaded ${notifications.length} notifications (${unreadCount} unread) for user: $userId',
      );
    } catch (e) {
      final errorMessage = 'Failed to fetch notifications: $e';
      debugPrint('❌ $errorMessage');
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
    }
  }

  /// Mark notification as read
  Future<void> markAsRead({
    required String notificationId,
    required String userId,
  }) async {
    try {
      // Update in database
      await ref.read(databaseServiceProvider)
          .update(SupabaseTables.notifications, {'is_read': true})
          .eq(SupabaseTables.id, notificationId);

      // Update local state
      final updatedNotifications = state.notifications.map((n) {
        if (n.id == notificationId) {
          return app_notification.Notification(
            id: n.id,
            userId: n.userId,
            type: n.type,
            title: n.title,
            body: n.body,
            data: n.data,
            isRead: true,
            createdAt: n.createdAt,
            updatedAt: DateTime.now(),
          );
        }
        return n;
      }).toList();

      final unreadCount = updatedNotifications.where((n) => !n.isRead).length;

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: unreadCount,
      );

      // Update cache
      await _saveToCache(userId, updatedNotifications);

      debugPrint('✅ Marked notification as read: $notificationId');
    } catch (e) {
      debugPrint('❌ Failed to mark notification as read: $e');
      rethrow;
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead({required String userId}) async {
    try {
      // Update in database
      await ref.read(databaseServiceProvider)
          .update(SupabaseTables.notifications, {'is_read': true})
          .eq(SupabaseTables.userId, userId)
          .eq('is_read', false);

      // Update local state
      final updatedNotifications = state.notifications.map((n) {
        return app_notification.Notification(
          id: n.id,
          userId: n.userId,
          type: n.type,
          title: n.title,
          body: n.body,
          data: n.data,
          isRead: true,
          createdAt: n.createdAt,
          updatedAt: DateTime.now(),
        );
      }).toList();

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: 0,
      );

      // Update cache
      await _saveToCache(userId, updatedNotifications);

      debugPrint('✅ Marked all notifications as read');
    } catch (e) {
      debugPrint('❌ Failed to mark all notifications as read: $e');
      rethrow;
    }
  }

  /// Refresh notifications
  Future<void> refresh({required String userId}) async {
    await fetchNotifications(
      userId: userId,
      forceRefresh: true,
    );
  }

  // ==========================================
  // Private Methods
  // ==========================================

  /// Fetch notifications from database
  Future<List<app_notification.Notification>> _fetchFromDatabase(
    String userId,
  ) async {
    final response = await ref.read(databaseServiceProvider)
        .select(SupabaseTables.notifications)
        .eq(SupabaseTables.userId, userId)
        .order(SupabaseTables.createdAt, ascending: false)
        .limit(_maxNotifications);

    return (response as List)
        .map((json) =>
            app_notification.Notification.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Load notifications from cache
  Future<List<app_notification.Notification>?> _loadFromCache(
    String userId,
  ) async {
    final cacheService = ref.read(cacheServiceProvider);
    if (!cacheService.isInitialized) return null;

    try {
      final cacheKey = _getCacheKey(userId);
      final cachedData = await cacheService.get(cacheKey);

      if (cachedData == null) return null;

      return (cachedData as List)
          .map((json) => app_notification.Notification.fromJson(
              json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('⚠️  Failed to load from cache: $e');
      return null;
    }
  }

  /// Save notifications to cache
  Future<void> _saveToCache(
    String userId,
    List<app_notification.Notification> notifications,
  ) async {
    final cacheService = ref.read(cacheServiceProvider);
    if (!cacheService.isInitialized) return;

    try {
      final cacheKey = _getCacheKey(userId);
      final jsonData = notifications.map((n) => n.toJson()).toList();
      await cacheService.put(cacheKey, jsonData, ttlMinutes: PerformanceLimits.highFrequencyCacheDuration.inMinutes);
    } catch (e) {
      debugPrint('⚠️  Failed to save to cache: $e');
    }
  }

  /// Get cache key
  String _getCacheKey(String userId) {
    return '${_cacheKeyPrefix}_$userId';
  }

  /// Setup real-time subscription for notifications
  Future<void> _setupRealtimeSubscription(String userId) async {
    try {
      _cancelRealtimeSubscription();

      final channelName = 'notifications-channel-$userId';
      final stream = ref.read(realtimeServiceProvider).subscribe(
        table: SupabaseTables.notifications,
        channelName: channelName,
        filter: {
          'column': SupabaseTables.userId,
          'value': userId,
        },
      );
      
      _subscriptionId = channelName;
      
      stream.listen((payload) {
        _handleRealtimeUpdate(payload, userId);
      });

      debugPrint('✅ Real-time subscription setup for notifications');
    } catch (e) {
      debugPrint('⚠️  Failed to setup real-time subscription: $e');
    }
  }

  /// Handle real-time update
  void _handleRealtimeUpdate(Map<String, dynamic> payload, String userId) {
    try {
      final eventType = payload['eventType'] as String?;
      final newData = payload['new'] as Map<String, dynamic>?;

      if (eventType == 'INSERT' && newData != null) {
        final newNotification = app_notification.Notification.fromJson(newData);
        final updatedNotifications = [newNotification, ...state.notifications];
        final unreadCount = updatedNotifications.where((n) => !n.isRead).length;
        state = state.copyWith(
          notifications: updatedNotifications,
          unreadCount: unreadCount,
        );
        _saveToCache(userId, updatedNotifications);
      } else if (eventType == 'UPDATE' && newData != null) {
        final updatedNotification =
            app_notification.Notification.fromJson(newData);
        final updatedNotifications = state.notifications
            .map((n) => n.id == updatedNotification.id ? updatedNotification : n)
            .toList();
        final unreadCount = updatedNotifications.where((n) => !n.isRead).length;
        state = state.copyWith(
          notifications: updatedNotifications,
          unreadCount: unreadCount,
        );
        _saveToCache(userId, updatedNotifications);
      }

      debugPrint('✅ Real-time notification update processed: $eventType');
    } catch (e) {
      debugPrint('❌ Failed to handle real-time update: $e');
    }
  }

  /// Cancel real-time subscription
  void _cancelRealtimeSubscription() {
    if (_subscriptionId != null) {
      ref.read(realtimeServiceProvider).unsubscribe(_subscriptionId!);
      _subscriptionId = null;
      debugPrint('✅ Real-time subscription cancelled');
    }
  }
}

/// Provider for notifications
///
/// Usage:
/// ```dart
/// final notificationsState = ref.watch(notificationsProvider);
/// final notifier = ref.read(notificationsProvider.notifier);
/// await notifier.fetchNotifications(userId: 'abc');
/// ```
final notificationsProvider =
    NotifierProvider.autoDispose<NotificationsNotifier, NotificationsState>(
  NotificationsNotifier.new,
);
