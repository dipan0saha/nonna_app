import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nonna_app/core/constants/supabase_tables.dart';
import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/core/models/name_suggestion.dart';
import 'package:nonna_app/core/models/name_suggestion_like.dart';
import 'package:nonna_app/core/enums/gender.dart';

/// Provider state for name suggestions tile
class NameSuggestionsState {
  final List<NameSuggestion> suggestions;
  final List<NameSuggestionLike> likes;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;

  const NameSuggestionsState({
    this.suggestions = const [],
    this.likes = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
  });

  NameSuggestionsState copyWith({
    List<NameSuggestion>? suggestions,
    List<NameSuggestionLike>? likes,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
  }) {
    return NameSuggestionsState(
      suggestions: suggestions ?? this.suggestions,
      likes: likes ?? this.likes,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
    );
  }

  /// Check if the current user has liked a specific suggestion
  bool hasUserLiked(String suggestionId, String userId) {
    return likes.any(
      (like) =>
          like.nameSuggestionId == suggestionId && like.userId == userId,
    );
  }

  /// Get the like count for a specific suggestion
  int likeCount(String suggestionId) {
    return likes.where((like) => like.nameSuggestionId == suggestionId).length;
  }

  /// Find the user's like for a suggestion (to get its ID for deletion)
  NameSuggestionLike? userLike(String suggestionId, String userId) {
    try {
      return likes.firstWhere(
        (like) =>
            like.nameSuggestionId == suggestionId && like.userId == userId,
      );
    } catch (_) {
      return null;
    }
  }

  /// Find the user's existing like for names of a given gender
  /// (to enforce 1 vote per gender category)
  NameSuggestionLike? userLikeForGender(
      String userId, Gender gender, List<NameSuggestion> allSuggestions) {
    // Find all suggestion IDs of the given gender
    final genderSuggestionIds = allSuggestions
        .where((s) => s.gender == gender)
        .map((s) => s.id)
        .toSet();

    try {
      return likes.firstWhere(
        (like) =>
            like.userId == userId &&
            genderSuggestionIds.contains(like.nameSuggestionId),
      );
    } catch (_) {
      return null;
    }
  }
}

class NameSuggestionsNotifier extends Notifier<NameSuggestionsState> {
  @override
  NameSuggestionsState build() => const NameSuggestionsState();

  String? _currentBabyProfileId;

  Future<void> load(
      {required String babyProfileId, bool forceRefresh = false}) async {
    if (state.isLoading && !forceRefresh) return;

    _currentBabyProfileId = babyProfileId;

    try {
      state = state.copyWith(isLoading: true, error: null);

      final db = ref.read(databaseServiceProvider);

      // Fetch name suggestions
      final rawData = await db
          .select(SupabaseTables.nameSuggestions)
          .eq('baby_profile_id', babyProfileId)
          .order('created_at', ascending: false);

      if (!ref.mounted) return;

      final suggestions =
          rawData.map((json) => NameSuggestion.fromJson(json)).toList();

      // Fetch all likes for these suggestions
      List<NameSuggestionLike> allLikes = [];
      if (suggestions.isNotEmpty) {
        final suggestionIds = suggestions.map((s) => s.id).toList();
        final likesData = await db
            .select(SupabaseTables.nameSuggestionLikes)
            .inFilter('name_suggestion_id', suggestionIds);

        if (!ref.mounted) return;

        allLikes =
            likesData.map((json) => NameSuggestionLike.fromJson(json)).toList();
      }

      state = state.copyWith(
        isLoading: false,
        isSubmitting: false,
        suggestions: suggestions,
        likes: allLikes,
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false, isSubmitting: false, error: e.toString());
    }
  }

  /// Add a new name suggestion
  Future<bool> addSuggestion({
    required String babyProfileId,
    required String userId,
    required String name,
    required Gender gender,
  }) async {
    try {
      state = state.copyWith(isSubmitting: true, error: null);

      final db = ref.read(databaseServiceProvider);
      await db.insert(SupabaseTables.nameSuggestions, {
        'baby_profile_id': babyProfileId,
        'user_id': userId,
        'suggested_name': name.trim(),
        'gender': gender.toJson(),
      });

      if (!ref.mounted) return false;

      // Reload to get the server-generated data
      await load(babyProfileId: babyProfileId, forceRefresh: true);
      return true;
    } catch (e) {
      if (!ref.mounted) return false;
      debugPrint('❌ Failed to add name suggestion: $e');
      state = state.copyWith(
          isSubmitting: false, error: 'Failed to add suggestion: $e');
      return false;
    }
  }

  /// Like a name suggestion (enforces 1 like per gender per user)
  ///
  /// If the user already liked a different name in the same gender category,
  /// the old like is removed first.
  Future<bool> likeSuggestion({
    required String suggestionId,
    required String userId,
  }) async {
    try {
      state = state.copyWith(isSubmitting: true, error: null);

      final db = ref.read(databaseServiceProvider);

      // Find the suggestion to get its gender
      final suggestion = state.suggestions.firstWhere(
        (s) => s.id == suggestionId,
      );

      // Check if user already has a like in this gender category
      final existingLike = state.userLikeForGender(
          userId, suggestion.gender, state.suggestions);

      if (existingLike != null) {
        if (existingLike.nameSuggestionId == suggestionId) {
          // Already liked this exact suggestion — toggle off (unlike)
          await db
              .delete(SupabaseTables.nameSuggestionLikes)
              .eq('id', existingLike.id);
        } else {
          // Liked a different name in same gender — remove old, add new
          await db
              .delete(SupabaseTables.nameSuggestionLikes)
              .eq('id', existingLike.id);

          await db.insert(SupabaseTables.nameSuggestionLikes, {
            'name_suggestion_id': suggestionId,
            'user_id': userId,
          });
        }
      } else {
        // No existing like for this gender — add new
        await db.insert(SupabaseTables.nameSuggestionLikes, {
          'name_suggestion_id': suggestionId,
          'user_id': userId,
        });
      }

      if (!ref.mounted) return false;

      // Reload to reflect changes
      if (_currentBabyProfileId != null) {
        await load(
            babyProfileId: _currentBabyProfileId!, forceRefresh: true);
      }
      return true;
    } catch (e) {
      if (!ref.mounted) return false;
      debugPrint('❌ Failed to like name suggestion: $e');
      state = state.copyWith(
          isSubmitting: false, error: 'Failed to vote: $e');
      return false;
    }
  }
}

final nameSuggestionsProvider =
    NotifierProvider.autoDispose<NameSuggestionsNotifier, NameSuggestionsState>(
  NameSuggestionsNotifier.new,
);
