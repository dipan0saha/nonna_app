import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nonna_app/core/constants/supabase_tables.dart';
import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/core/models/vote.dart';
import 'package:nonna_app/core/enums/vote_type.dart';

/// Provider state for prediction votes tile
class PredictionVotesState {
  final List<Vote> votes;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;

  const PredictionVotesState({
    this.votes = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
  });

  PredictionVotesState copyWith({
    List<Vote>? votes,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
  }) {
    return PredictionVotesState(
      votes: votes ?? this.votes,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
    );
  }

  /// Get the current user's gender vote (if any)
  Vote? userGenderVote(String userId) {
    try {
      return votes.firstWhere(
        (v) => v.userId == userId && v.voteType == VoteType.gender,
      );
    } catch (_) {
      return null;
    }
  }

  /// Get the current user's birthdate vote (if any)
  Vote? userBirthdateVote(String userId) {
    try {
      return votes.firstWhere(
        (v) => v.userId == userId && v.voteType == VoteType.birthdate,
      );
    } catch (_) {
      return null;
    }
  }
}

class PredictionVotesNotifier extends Notifier<PredictionVotesState> {
  @override
  PredictionVotesState build() => const PredictionVotesState();

  String? _currentBabyProfileId;

  Future<void> load(
      {required String babyProfileId, bool forceRefresh = false}) async {
    if (state.isLoading && !forceRefresh) return;

    _currentBabyProfileId = babyProfileId;

    try {
      state = state.copyWith(isLoading: true, error: null);

      final db = ref.read(databaseServiceProvider);
      final rawData = await db
          .select(SupabaseTables.votes)
          .eq('baby_profile_id', babyProfileId)
          .order('created_at', ascending: false)
          .limit(100); // Increased limit to allow meaningful local aggregation

      if (!ref.mounted) return;

      final votes = rawData.map((json) => Vote.fromJson(json)).toList();
      state = state.copyWith(isLoading: false, isSubmitting: false, votes: votes);
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false, isSubmitting: false, error: e.toString());
    }
  }

  /// Vote for gender prediction (1 vote per user — upsert pattern)
  ///
  /// If the user already has a gender vote, it is updated.
  /// Otherwise a new vote is inserted.
  Future<bool> voteGender({
    required String babyProfileId,
    required String userId,
    required String genderValue,
    bool isAnonymous = false,
  }) async {
    try {
      state = state.copyWith(isSubmitting: true, error: null);

      final db = ref.read(databaseServiceProvider);

      // Check if user already has a gender vote for this baby
      final existingVote = state.userGenderVote(userId);

      if (existingVote != null) {
        // Update existing vote
        await db
            .update(SupabaseTables.votes, {
              'value_text': genderValue,
              'is_anonymous': isAnonymous,
            })
            .eq('id', existingVote.id);
      } else {
        // Insert new vote
        await db.insert(SupabaseTables.votes, {
          'baby_profile_id': babyProfileId,
          'user_id': userId,
          'vote_type': VoteType.gender.toJson(),
          'value_text': genderValue,
          'is_anonymous': isAnonymous,
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
      debugPrint('❌ Failed to vote gender: $e');
      state = state.copyWith(
          isSubmitting: false, error: 'Failed to vote: $e');
      return false;
    }
  }

  /// Vote for birthdate prediction (1 vote per user — upsert pattern)
  ///
  /// If the user already has a birthdate vote, it is updated.
  /// Otherwise a new vote is inserted.
  Future<bool> voteBirthdate({
    required String babyProfileId,
    required String userId,
    required DateTime date,
    bool isAnonymous = false,
  }) async {
    try {
      state = state.copyWith(isSubmitting: true, error: null);

      final db = ref.read(databaseServiceProvider);

      // Check if user already has a birthdate vote for this baby
      final existingVote = state.userBirthdateVote(userId);

      if (existingVote != null) {
        // Update existing vote
        await db
            .update(SupabaseTables.votes, {
              'value_date':
                  '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
              'is_anonymous': isAnonymous,
            })
            .eq('id', existingVote.id);
      } else {
        // Insert new vote
        await db.insert(SupabaseTables.votes, {
          'baby_profile_id': babyProfileId,
          'user_id': userId,
          'vote_type': VoteType.birthdate.toJson(),
          'value_date':
              '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
          'is_anonymous': isAnonymous,
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
      debugPrint('❌ Failed to vote birthdate: $e');
      state = state.copyWith(
          isSubmitting: false, error: 'Failed to vote: $e');
      return false;
    }
  }
}

final predictionVotesProvider =
    NotifierProvider.autoDispose<PredictionVotesNotifier, PredictionVotesState>(
  PredictionVotesNotifier.new,
);
