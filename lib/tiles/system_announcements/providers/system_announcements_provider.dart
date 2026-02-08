import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/services/cache_service.dart';

/// Announcement priority levels
enum AnnouncementPriority {
  low,
  medium,
  high,
  critical,
}

/// System announcement
class SystemAnnouncement {
  final String id;
  final String title;
  final String body;
  final AnnouncementPriority priority;
  final DateTime createdAt;
  final DateTime? expiresAt;

  const SystemAnnouncement({
    required this.id,
    required this.title,
    required this.body,
    required this.priority,
    required this.createdAt,
    this.expiresAt,
  });

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'priority': priority.name,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }

  factory SystemAnnouncement.fromJson(Map<String, dynamic> json) {
    return SystemAnnouncement(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      priority: AnnouncementPriority.values.firstWhere(
        (p) => p.name == json['priority'],
        orElse: () => AnnouncementPriority.medium,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
    );
  }
}

/// System Announcements provider for the System Announcements tile
///
/// **Functional Requirements**: Section 3.5.4 - Tile-Specific Providers
/// Reference: docs/Core_development_component_identification.md
///
/// Features:
/// - Global announcements (not baby-specific)
/// - Dismissal tracking per user
/// - Priority levels (low, medium, high, critical)
/// - Simple text announcements with title and body
/// - Local storage for announcements and dismissals
///
/// Dependencies: CacheService

/// State class for system announcements
class SystemAnnouncementsState {
  final List<SystemAnnouncement> announcements;
  final Set<String> dismissedIds;
  final bool isLoading;
  final String? error;

  const SystemAnnouncementsState({
    this.announcements = const [],
    this.dismissedIds = const {},
    this.isLoading = false,
    this.error,
  });

  SystemAnnouncementsState copyWith({
    List<SystemAnnouncement>? announcements,
    Set<String>? dismissedIds,
    bool? isLoading,
    String? error,
  }) {
    return SystemAnnouncementsState(
      announcements: announcements ?? this.announcements,
      dismissedIds: dismissedIds ?? this.dismissedIds,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// System Announcements provider
///
/// Manages global system announcements with per-user dismissal tracking.
class SystemAnnouncementsNotifier extends StateNotifier<SystemAnnouncementsState> {
  final CacheService _cacheService;

  SystemAnnouncementsNotifier({
    required CacheService cacheService,
  })  : _cacheService = cacheService,
        super(const SystemAnnouncementsState());

  // Configuration
  static const String _cacheKeyAnnouncements = 'system_announcements';
  static const String _cacheKeyDismissed = 'dismissed_announcements';

  /// Mock announcements (in real app, would fetch from server)
  static final List<SystemAnnouncement> _mockAnnouncements = [
    SystemAnnouncement(
      id: 'welcome',
      title: 'Welcome to Nonna!',
      body: 'Thank you for joining our baby sharing community. Get started by creating your baby profile.',
      priority: AnnouncementPriority.medium,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    SystemAnnouncement(
      id: 'new_features',
      title: 'New Features Available',
      body: 'Check out our new photo filters and enhanced sharing options!',
      priority: AnnouncementPriority.low,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      expiresAt: DateTime.now().add(const Duration(days: 7)),
    ),
  ];

  // ==========================================
  // Public Methods
  // ==========================================

  /// Load system announcements for a specific user
  ///
  /// [userId] The user identifier for tracking dismissals
  Future<void> loadAnnouncements({required String userId}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Load announcements (in real app, would fetch from server)
      final announcements = await _loadAnnouncementsFromCache();

      // Load dismissed IDs for this user
      final dismissedIds = await _loadDismissedIds(userId);

      // Filter out expired announcements
      final activeAnnouncements = announcements
          .where((a) => !a.isExpired)
          .toList()
        ..sort((a, b) => b.priority.index.compareTo(a.priority.index));

      state = state.copyWith(
        announcements: activeAnnouncements,
        dismissedIds: dismissedIds,
        isLoading: false,
      );

      debugPrint(
        '✅ Loaded ${activeAnnouncements.length} system announcements for user: $userId',
      );
    } catch (e) {
      final errorMessage = 'Failed to load system announcements: $e';
      debugPrint('❌ $errorMessage');
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
    }
  }

  /// Fetch system announcements (alias for loadAnnouncements)
  ///
  /// This method is provided for backward compatibility with tests.
  /// In production, use loadAnnouncements with a specific userId.
  /// 
  /// Note: This uses a placeholder userId and should not be used in production code.
  /// Tests should be updated to call loadAnnouncements directly with a proper userId.
  Future<void> fetchAnnouncements() async {
    // TODO: Remove this method once tests are updated to use loadAnnouncements
    await loadAnnouncements(userId: 'test_user');
  }

  /// Dismiss an announcement for a specific user
  Future<void> dismissAnnouncement({
    required String announcementId,
    required String userId,
  }) async {
    try {
      final updatedDismissedIds = {...state.dismissedIds, announcementId};

      state = state.copyWith(dismissedIds: updatedDismissedIds);

      // Save dismissed IDs
      await _saveDismissedIds(userId, updatedDismissedIds);

      debugPrint('✅ Dismissed announcement: $announcementId');
    } catch (e) {
      debugPrint('❌ Failed to dismiss announcement: $e');
      rethrow;
    }
  }

  /// Get active (non-dismissed, non-expired) announcements
  List<SystemAnnouncement> getActiveAnnouncements() {
    return state.announcements
        .where((a) => !state.dismissedIds.contains(a.id) && !a.isExpired)
        .toList();
  }

  /// Get critical announcements only
  List<SystemAnnouncement> getCriticalAnnouncements() {
    return getActiveAnnouncements()
        .where((a) => a.priority == AnnouncementPriority.critical)
        .toList();
  }

  /// Clear all dismissals for a user
  Future<void> clearDismissals({required String userId}) async {
    try {
      state = state.copyWith(dismissedIds: {});
      await _saveDismissedIds(userId, {});
      debugPrint('✅ Cleared all dismissals for user: $userId');
    } catch (e) {
      debugPrint('❌ Failed to clear dismissals: $e');
      rethrow;
    }
  }

  // ==========================================
  // Private Methods
  // ==========================================

  /// Load announcements from cache (or use mock data)
  Future<List<SystemAnnouncement>> _loadAnnouncementsFromCache() async {
    if (!_cacheService.isInitialized) {
      return _mockAnnouncements;
    }

    try {
      final cachedData = await _cacheService.get(_cacheKeyAnnouncements);

      if (cachedData == null) {
        // Save mock announcements to cache
        await _saveAnnouncementsToCache(_mockAnnouncements);
        return _mockAnnouncements;
      }

      return (cachedData as List)
          .map((json) =>
              SystemAnnouncement.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('⚠️  Failed to load announcements from cache: $e');
      return _mockAnnouncements;
    }
  }

  /// Save announcements to cache
  Future<void> _saveAnnouncementsToCache(
    List<SystemAnnouncement> announcements,
  ) async {
    if (!_cacheService.isInitialized) return;

    try {
      final jsonData = announcements.map((a) => a.toJson()).toList();
      await _cacheService.put(_cacheKeyAnnouncements, jsonData);
    } catch (e) {
      debugPrint('⚠️  Failed to save announcements to cache: $e');
    }
  }

  /// Load dismissed announcement IDs for a user
  Future<Set<String>> _loadDismissedIds(String userId) async {
    if (!_cacheService.isInitialized) return {};

    try {
      final cacheKey = _getDismissedCacheKey(userId);
      final cachedData = await _cacheService.get(cacheKey);

      if (cachedData == null) return {};

      return (cachedData as List).cast<String>().toSet();
    } catch (e) {
      debugPrint('⚠️  Failed to load dismissed IDs from cache: $e');
      return {};
    }
  }

  /// Save dismissed announcement IDs for a user
  Future<void> _saveDismissedIds(String userId, Set<String> dismissedIds) async {
    if (!_cacheService.isInitialized) return;

    try {
      final cacheKey = _getDismissedCacheKey(userId);
      await _cacheService.put(cacheKey, dismissedIds.toList());
    } catch (e) {
      debugPrint('⚠️  Failed to save dismissed IDs to cache: $e');
    }
  }

  /// Get cache key for dismissed announcements
  String _getDismissedCacheKey(String userId) {
    return '${_cacheKeyDismissed}_$userId';
  }
}

/// Provider for system announcements
///
/// Usage:
/// ```dart
/// final announcementsState = ref.watch(systemAnnouncementsProvider);
/// final notifier = ref.read(systemAnnouncementsProvider.notifier);
/// await notifier.loadAnnouncements(userId: 'user123');
/// ```
final systemAnnouncementsProvider = StateNotifierProvider.autoDispose<
    SystemAnnouncementsNotifier, SystemAnnouncementsState>(
  (ref) {
    final cacheService = ref.watch(cacheServiceProvider);

    return SystemAnnouncementsNotifier(
      cacheService: cacheService,
    );
  },
);
