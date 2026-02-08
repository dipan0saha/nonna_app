import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/performance_limits.dart';
import '../../../core/constants/supabase_tables.dart';
import '../../../core/di/providers.dart';
import '../../../core/enums/invitation_status.dart';
import '../../../core/models/invitation.dart';
import '../../../core/services/cache_service.dart';
import '../../../core/services/database_service.dart';
import '../../../core/services/realtime_service.dart';

/// Invites Status provider for the Invites Status tile
///
/// **Functional Requirements**: Section 3.5.4 - Tile-Specific Providers
/// Reference: docs/Core_development_component_identification.md
///
/// Features:
/// - Fetches pending invitations (owner only)
/// - Acceptance tracking and status updates
/// - Real-time updates via Supabase subscriptions
/// - Local caching with TTL
///
/// Dependencies: DatabaseService, CacheService, RealtimeService, Invitation model

/// State class for invites status
class InvitesStatusState {
  final List<Invitation> invitations;
  final bool isLoading;
  final String? error;
  final int pendingCount;

  const InvitesStatusState({
    this.invitations = const [],
    this.isLoading = false,
    this.error,
    this.pendingCount = 0,
  });

  InvitesStatusState copyWith({
    List<Invitation>? invitations,
    bool? isLoading,
    String? error,
    int? pendingCount,
  }) {
    return InvitesStatusState(
      invitations: invitations ?? this.invitations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      pendingCount: pendingCount ?? this.pendingCount,
    );
  }
}

/// Invites Status provider
///
/// Manages pending invitations with real-time updates and acceptance tracking.
class InvitesStatusNotifier extends Notifier<InvitesStatusState> {
  // Configuration
  static const String _cacheKeyPrefix = 'invites_status';

  String? _subscriptionId;

  @override
  InvitesStatusState build() {
    ref.onDispose(() {
      _cancelRealtimeSubscription();
    });
    return const InvitesStatusState();
  }

  // ==========================================
  // Public Methods
  // ==========================================

  /// Fetch pending invitations for a specific baby profile (owner only)
  ///
  /// [babyProfileId] The baby profile identifier
  /// [forceRefresh] Whether to bypass cache and fetch from server
  Future<void> fetchInvitations({
    required String babyProfileId,
    bool forceRefresh = false,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Try to load from cache first
      if (!forceRefresh) {
        final cachedInvitations = await _loadFromCache(babyProfileId);
        if (cachedInvitations != null && cachedInvitations.isNotEmpty) {
          final pendingCount = cachedInvitations
              .where((inv) => inv.status == InvitationStatus.pending)
              .length;
          state = state.copyWith(
            invitations: cachedInvitations,
            isLoading: false,
            pendingCount: pendingCount,
          );
          return;
        }
      }

      // Fetch from database
      final invitations = await _fetchFromDatabase(babyProfileId);
      final pendingCount = invitations
          .where((inv) => inv.status == InvitationStatus.pending)
          .length;

      // Save to cache
      await _saveToCache(babyProfileId, invitations);

      state = state.copyWith(
        invitations: invitations,
        isLoading: false,
        pendingCount: pendingCount,
      );

      // Setup real-time subscription
      await _setupRealtimeSubscription(babyProfileId);

      debugPrint(
        '✅ Loaded ${invitations.length} invitations (${pendingCount} pending) for profile: $babyProfileId',
      );
    } catch (e) {
      final errorMessage = 'Failed to fetch invitations: $e';
      debugPrint('❌ $errorMessage');
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
    }
  }

  /// Get pending invitations only
  List<Invitation> getPendingInvitations() {
    return state.invitations
        .where((inv) => inv.status == InvitationStatus.pending)
        .toList();
  }

  /// Get accepted invitations
  List<Invitation> getAcceptedInvitations() {
    return state.invitations
        .where((inv) => inv.status == InvitationStatus.accepted)
        .toList();
  }

  /// Get declined invitations
  List<Invitation> getDeclinedInvitations() {
    return state.invitations
        .where((inv) => inv.status == InvitationStatus.declined)
        .toList();
  }

  /// Refresh invitations
  Future<void> refresh({required String babyProfileId}) async {
    await fetchInvitations(
      babyProfileId: babyProfileId,
      forceRefresh: true,
    );
  }

  // ==========================================
  // Private Methods
  // ==========================================

  /// Fetch invitations from database
  Future<List<Invitation>> _fetchFromDatabase(String babyProfileId) async {
    final databaseService = ref.read(databaseServiceProvider);
    final response = await databaseService
        .select(SupabaseTables.invitations)
        .eq(SupabaseTables.babyProfileId, babyProfileId)
        .order(SupabaseTables.createdAt, ascending: false);

    return (response as List)
        .map((json) => Invitation.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Load invitations from cache
  Future<List<Invitation>?> _loadFromCache(String babyProfileId) async {
    final cacheService = ref.read(cacheServiceProvider);
    if (!cacheService.isInitialized) return null;

    try {
      final cacheKey = _getCacheKey(babyProfileId);
      final cachedData = await cacheService.get(cacheKey);

      if (cachedData == null) return null;

      return (cachedData as List)
          .map((json) => Invitation.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('⚠️  Failed to load from cache: $e');
      return null;
    }
  }

  /// Save invitations to cache
  Future<void> _saveToCache(
    String babyProfileId,
    List<Invitation> invitations,
  ) async {
    final cacheService = ref.read(cacheServiceProvider);
    if (!cacheService.isInitialized) return;

    try {
      final cacheKey = _getCacheKey(babyProfileId);
      final jsonData = invitations.map((inv) => inv.toJson()).toList();
      await cacheService.put(cacheKey, jsonData, ttlMinutes: PerformanceLimits.tileCacheDuration.inMinutes);
    } catch (e) {
      debugPrint('⚠️  Failed to save to cache: $e');
    }
  }

  /// Get cache key
  String _getCacheKey(String babyProfileId) {
    return '${_cacheKeyPrefix}_$babyProfileId';
  }

  /// Setup real-time subscription for invitations
  Future<void> _setupRealtimeSubscription(String babyProfileId) async {
    try {
      _cancelRealtimeSubscription();

      final realtimeService = ref.read(realtimeServiceProvider);
      final channelName = 'invitations-channel-$babyProfileId';
      final stream = ref.read(realtimeServiceProvider).subscribe(
        table: SupabaseTables.invitations,
        channelName: channelName,
        filter: {
          'column': SupabaseTables.babyProfileId,
          'value': babyProfileId,
        },
      );
      
      _subscriptionId = channelName;
      
      stream.listen((payload) {
        _handleRealtimeUpdate(payload, babyProfileId);
      });

      debugPrint('✅ Real-time subscription setup for invitations');
    } catch (e) {
      debugPrint('⚠️  Failed to setup real-time subscription: $e');
    }
  }

  /// Handle real-time update
  void _handleRealtimeUpdate(
    Map<String, dynamic> payload,
    String babyProfileId,
  ) {
    try {
      final eventType = payload['eventType'] as String?;
      final newData = payload['new'] as Map<String, dynamic>?;

      if (eventType == 'INSERT' && newData != null) {
        final newInvitation = Invitation.fromJson(newData);
        final updatedInvitations = [newInvitation, ...state.invitations];
        final pendingCount = updatedInvitations
            .where((inv) => inv.status == InvitationStatus.pending)
            .length;
        state = state.copyWith(
          invitations: updatedInvitations,
          pendingCount: pendingCount,
        );
        _saveToCache(babyProfileId, updatedInvitations);
      } else if (eventType == 'UPDATE' && newData != null) {
        final updatedInvitation = Invitation.fromJson(newData);
        final updatedInvitations = state.invitations
            .map((inv) => inv.id == updatedInvitation.id ? updatedInvitation : inv)
            .toList();
        final pendingCount = updatedInvitations
            .where((inv) => inv.status == InvitationStatus.pending)
            .length;
        state = state.copyWith(
          invitations: updatedInvitations,
          pendingCount: pendingCount,
        );
        _saveToCache(babyProfileId, updatedInvitations);
      } else if (eventType == 'DELETE') {
        final oldData = payload['old'] as Map<String, dynamic>?;
        if (oldData != null) {
          final deletedId = oldData['id'] as String;
          final updatedInvitations =
              state.invitations.where((inv) => inv.id != deletedId).toList();
          final pendingCount = updatedInvitations
              .where((inv) => inv.status == InvitationStatus.pending)
              .length;
          state = state.copyWith(
            invitations: updatedInvitations,
            pendingCount: pendingCount,
          );
          _saveToCache(babyProfileId, updatedInvitations);
        }
      }

      debugPrint('✅ Real-time invitation update processed: $eventType');
    } catch (e) {
      debugPrint('❌ Failed to handle real-time update: $e');
    }
  }

  /// Cancel real-time subscription
  void _cancelRealtimeSubscription() {
    if (_subscriptionId != null) {
      final realtimeService = ref.read(realtimeServiceProvider);
      realtimeService.unsubscribe(_subscriptionId!);
      _subscriptionId = null;
      debugPrint('✅ Real-time subscription cancelled');
    }
  }
}

/// Provider for invites status
///
/// Usage:
/// ```dart
/// final invitesState = ref.watch(invitesStatusProvider);
/// final notifier = ref.read(invitesStatusProvider.notifier);
/// await notifier.fetchInvitations(babyProfileId: 'abc');
/// ```
final invitesStatusProvider =
    NotifierProvider.autoDispose<InvitesStatusNotifier, InvitesStatusState>(
  InvitesStatusNotifier.new,
);
