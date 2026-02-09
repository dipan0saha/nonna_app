import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';

/// Checklist item
class ChecklistItem {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final int order;

  const ChecklistItem({
    required this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.order,
  });

  ChecklistItem copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    int? order,
  }) {
    return ChecklistItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      order: order ?? this.order,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'order': order,
    };
  }

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      isCompleted: json['isCompleted'] as bool,
      order: json['order'] as int,
    );
  }
}

/// Checklist provider for the Checklist tile
///
/// **Functional Requirements**: Section 3.5.4 - Tile-Specific Providers
/// Reference: docs/Core_development_component_identification.md
///
/// Features:
/// - Onboarding checklist (owner only)
/// - Completion tracking
/// - Progress calculation
/// - Store checklist state locally using CacheService
///
/// Dependencies: CacheService

/// State class for checklist
class ChecklistState {
  final List<ChecklistItem> items;
  final bool isLoading;
  final String? error;
  final int completedCount;
  final double progressPercentage;

  const ChecklistState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.completedCount = 0,
    this.progressPercentage = 0.0,
  });

  ChecklistState copyWith({
    List<ChecklistItem>? items,
    bool? isLoading,
    String? error,
    int? completedCount,
    double? progressPercentage,
  }) {
    return ChecklistState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      completedCount: completedCount ?? this.completedCount,
      progressPercentage: progressPercentage ?? this.progressPercentage,
    );
  }
}

/// Checklist provider
///
/// Manages onboarding checklist with local storage and completion tracking.
class ChecklistNotifier extends Notifier<ChecklistState> {
  @override
  ChecklistState build() {
    return const ChecklistState();
  }

  // Configuration
  static const String _cacheKeyPrefix = 'checklist';

  /// Default checklist items for onboarding
  static final List<ChecklistItem> _defaultItems = [
    ChecklistItem(
      id: 'setup_profile',
      title: 'Set up baby profile',
      description: 'Add your baby\'s name, due date, and profile photo',
      isCompleted: false,
      order: 1,
    ),
    ChecklistItem(
      id: 'create_registry',
      title: 'Create registry',
      description: 'Add items you need for your baby',
      isCompleted: false,
      order: 2,
    ),
    ChecklistItem(
      id: 'invite_family',
      title: 'Invite family & friends',
      description: 'Share your baby profile with loved ones',
      isCompleted: false,
      order: 3,
    ),
    ChecklistItem(
      id: 'upload_photo',
      title: 'Upload first photo',
      description: 'Share your first ultrasound or baby photo',
      isCompleted: false,
      order: 4,
    ),
    ChecklistItem(
      id: 'create_event',
      title: 'Create your first event',
      description: 'Plan a baby shower, gender reveal, or meet & greet',
      isCompleted: false,
      order: 5,
    ),
    ChecklistItem(
      id: 'explore_features',
      title: 'Explore app features',
      description: 'Check out all the ways to share and celebrate',
      isCompleted: false,
      order: 6,
    ),
  ];

  // ==========================================
  // Public Methods
  // ==========================================

  /// Load checklist for a specific baby profile (owner only)
  ///
  /// [babyProfileId] The baby profile identifier
  Future<void> loadChecklist({required String babyProfileId}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Load from cache
      final items = await _loadFromCache(babyProfileId);
      if (!ref.mounted) return;

      final completedCount = items.where((item) => item.isCompleted).length;
      final progressPercentage =
          items.isEmpty ? 0.0 : (completedCount / items.length) * 100;

      state = state.copyWith(
        items: items,
        isLoading: false,
        completedCount: completedCount,
        progressPercentage: progressPercentage,
      );

      debugPrint(
        '✅ Loaded checklist for profile: $babyProfileId ($completedCount/${items.length} completed)',
      );
    } catch (e) {
      if (!ref.mounted) return;
      final errorMessage = 'Failed to load checklist: $e';
      debugPrint('❌ $errorMessage');
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
    }
  }

  /// Toggle item completion status
  Future<void> toggleItem({
    required String itemId,
    required String babyProfileId,
  }) async {
    try {
      final updatedItems = state.items.map((item) {
        if (item.id == itemId) {
          return item.copyWith(isCompleted: !item.isCompleted);
        }
        return item;
      }).toList();

      final completedCount =
          updatedItems.where((item) => item.isCompleted).length;
      final progressPercentage = updatedItems.isEmpty
          ? 0.0
          : (completedCount / updatedItems.length) * 100;

      state = state.copyWith(
        items: updatedItems,
        completedCount: completedCount,
        progressPercentage: progressPercentage,
      );

      // Save to cache
      await _saveToCache(babyProfileId, updatedItems);
      if (!ref.mounted) return;

      debugPrint('✅ Toggled checklist item: $itemId');
    } catch (e) {
      debugPrint('❌ Failed to toggle checklist item: $e');
      rethrow;
    }
  }

  /// Reset checklist to default state
  Future<void> resetChecklist({required String babyProfileId}) async {
    try {
      final completedCount = 0;
      final progressPercentage = 0.0;

      state = state.copyWith(
        items: _defaultItems,
        completedCount: completedCount,
        progressPercentage: progressPercentage,
      );

      // Save to cache
      await _saveToCache(babyProfileId, _defaultItems);
      if (!ref.mounted) return;

      debugPrint('✅ Reset checklist for profile: $babyProfileId');
    } catch (e) {
      debugPrint('❌ Failed to reset checklist: $e');
      rethrow;
    }
  }

  /// Get incomplete items only
  List<ChecklistItem> getIncompleteItems() {
    return state.items.where((item) => !item.isCompleted).toList();
  }

  /// Get completed items only
  List<ChecklistItem> getCompletedItems() {
    return state.items.where((item) => item.isCompleted).toList();
  }

  // ==========================================
  // Private Methods
  // ==========================================

  /// Load checklist from cache
  Future<List<ChecklistItem>> _loadFromCache(String babyProfileId) async {
    final cacheService = ref.read(cacheServiceProvider);
    if (!cacheService.isInitialized) {
      return _defaultItems;
    }

    try {
      final cacheKey = _getCacheKey(babyProfileId);
      final cachedData = await cacheService.get(cacheKey);

      if (cachedData == null) {
        // First time loading, save default items
        await _saveToCache(babyProfileId, _defaultItems);
        return _defaultItems;
      }

      return (cachedData as List)
          .map((json) => ChecklistItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('⚠️  Failed to load from cache: $e');
      return _defaultItems;
    }
  }

  /// Save checklist to cache
  Future<void> _saveToCache(
    String babyProfileId,
    List<ChecklistItem> items,
  ) async {
    final cacheService = ref.read(cacheServiceProvider);
    if (!cacheService.isInitialized) return;

    try {
      final cacheKey = _getCacheKey(babyProfileId);
      final jsonData = items.map((item) => item.toJson()).toList();
      // No TTL - checklist should persist indefinitely
      await cacheService.put(cacheKey, jsonData);
    } catch (e) {
      debugPrint('⚠️  Failed to save to cache: $e');
    }
  }

  /// Get cache key
  String _getCacheKey(String babyProfileId) {
    return '${_cacheKeyPrefix}_$babyProfileId';
  }
}

/// Provider for checklist
///
/// Usage:
/// ```dart
/// final checklistState = ref.watch(checklistProvider);
/// final notifier = ref.read(checklistProvider.notifier);
/// await notifier.loadChecklist(babyProfileId: 'abc');
/// ```
final checklistProvider =
    NotifierProvider.autoDispose<ChecklistNotifier, ChecklistState>(
  ChecklistNotifier.new,
);
