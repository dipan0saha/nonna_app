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

  /// Load gamification data for a baby profile
  Future<void> load({
    required String babyProfileId,
    UserRole role = UserRole.follower,
    bool forceRefresh = false,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Async load tile configs
      TileLoader.loadForScreen(
        ref: ref,
        screenId: 'fun',
        role: role,
        forceRefresh: forceRefresh,
      ).then((tiles) {
        if (ref.mounted) state = state.copyWith(tiles: tiles);
      });

      // Fetch gamification data from database
      final db = ref.read(databaseServiceProvider);

      final nameSuggestionsData = await db
          .select(SupabaseTables.nameSuggestions)
          .eq('baby_profile_id', babyProfileId)
          .order('created_at', ascending: false);

      final votesData = await db
          .select(SupabaseTables.votes)
          .eq('baby_profile_id', babyProfileId)
          .order('created_at', ascending: false);

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
