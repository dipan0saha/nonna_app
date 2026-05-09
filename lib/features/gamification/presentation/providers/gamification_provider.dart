import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nonna_app/core/constants/supabase_tables.dart';
import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/core/models/name_suggestion.dart';
import 'package:nonna_app/core/models/vote.dart';
import 'package:nonna_app/core/models/tile_config.dart';
import 'package:nonna_app/core/utils/tile_loader.dart';
import 'package:nonna_app/core/enums/user_role.dart';

/// Gamification feature state
///
/// **Functional Requirements**: Section 3.6.4 - Additional Feature Screens
class GamificationState {
  final List<TileConfig> tiles;
  final List<NameSuggestion> nameSuggestions;
  final List<Vote> votes;
  final bool isLoading;
  final String? error;

  const GamificationState({
    this.tiles = const [],
    this.nameSuggestions = const [],
    this.votes = const [],
    this.isLoading = false,
    this.error,
  });

  GamificationState copyWith({
    List<TileConfig>? tiles,
    List<NameSuggestion>? nameSuggestions,
    List<Vote>? votes,
    bool? isLoading,
    String? error,
  }) {
    return GamificationState(
      tiles: tiles ?? this.tiles,
      nameSuggestions: nameSuggestions ?? this.nameSuggestions,
      votes: votes ?? this.votes,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Gamification Notifier
class GamificationNotifier extends Notifier<GamificationState> {
  @override
  GamificationState build() => const GamificationState();

  List<TileConfig> _defaultTiles(UserRole role) {
    final now = DateTime.now();
    return [
      TileConfig(
        id: 'fallback-name-suggestions',
        screenId: 'gamification',
        tileDefinitionId: 'NameSuggestionsTile',
        componentName: 'NameSuggestionsTile',
        role: role,
        displayOrder: 10,
        isVisible: true,
        createdAt: now,
        updatedAt: now,
      ),
      TileConfig(
        id: 'fallback-prediction-votes',
        screenId: 'gamification',
        tileDefinitionId: 'PredictionVotesTile',
        componentName: 'PredictionVotesTile',
        role: role,
        displayOrder: 20,
        isVisible: true,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  Future<List<TileConfig>> _loadTiles({
    required String babyProfileId,
    required UserRole role,
    required bool forceRefresh,
  }) async {
    final screenCandidates = ['fun', 'gamification'];
    List<TileConfig> tiles = const [];

    for (final screenId in screenCandidates) {
      try {
        final loaded = await TileLoader.loadForScreen(
          ref: ref,
          babyProfileId: babyProfileId,
          screenId: screenId,
          role: role,
          forceRefresh: forceRefresh,
        );
        if (loaded.isNotEmpty) {
          tiles = loaded;
          break;
        }
      } catch (_) {
        // Continue trying other screen IDs/fallback.
      }
    }

    if (tiles.isEmpty) {
      return _defaultTiles(role);
    }

    final filteredTiles = tiles.where((t) => t.componentName != 'EngagementRecapTile').toList();

    final componentNames =
        filteredTiles.map((t) => t.componentName).whereType<String>().toSet();
    final missing = _defaultTiles(role)
        .where((t) => !componentNames.contains(t.componentName))
        .toList();

    final merged = [...filteredTiles, ...missing]
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    return merged;
  }

  /// Load gamification data for a baby profile
  Future<void> load({
    required String babyProfileId,
    UserRole role = UserRole.follower,
    bool forceRefresh = false,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final db = ref.read(databaseServiceProvider);

      // Kick off independent fetches in parallel to reduce first-open latency.
      final tilesFuture = _loadTiles(
        babyProfileId: babyProfileId,
        role: role,
        forceRefresh: forceRefresh,
      );

      final nameSuggestionsFuture = db
          .select(SupabaseTables.nameSuggestions)
          .eq('baby_profile_id', babyProfileId)
          .order('created_at', ascending: false);

      final votesFuture = db
          .select(SupabaseTables.votes)
          .eq('baby_profile_id', babyProfileId)
          .order('created_at', ascending: false);

      final tiles = await tilesFuture;
      if (!ref.mounted) return;
      state = state.copyWith(tiles: tiles);

      final nameSuggestionsData = await nameSuggestionsFuture;
      final votesData = await votesFuture;

      if (!ref.mounted) return;

      final nameSuggestions = nameSuggestionsData.map((json) {
        try {
          return NameSuggestion.fromJson(json);
        } catch (e) {
          debugPrint('Error parsing NameSuggestion: $e\nJSON: $json');
          rethrow;
        }
      }).toList();

      final votes = votesData.map((json) {
        try {
          return Vote.fromJson(json);
        } catch (e) {
          debugPrint('Error parsing Vote: $e\nJSON: $json');
          rethrow;
        }
      }).toList();

      state = state.copyWith(
        isLoading: false,
        nameSuggestions: nameSuggestions,
        votes: votes,
      );
      debugPrint('✅ Gamification data loaded for $babyProfileId');
    } catch (e) {
      if (!ref.mounted) return;
      final msg = 'Failed to load gamification data: $e';
      debugPrint('❌ $msg');
      state = state.copyWith(isLoading: false, error: msg);
    }
  }
}

/// Gamification provider
final gamificationProvider =
    NotifierProvider.autoDispose<GamificationNotifier, GamificationState>(
  GamificationNotifier.new,
);
