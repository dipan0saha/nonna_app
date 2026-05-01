import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nonna_app/core/constants/supabase_tables.dart';
import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/core/models/vote.dart';

/// Provider state for prediction votes tile
class PredictionVotesState {
  final List<Vote> votes;
  final bool isLoading;
  final String? error;

  const PredictionVotesState({
    this.votes = const [],
    this.isLoading = false,
    this.error,
  });

  PredictionVotesState copyWith({
    List<Vote>? votes,
    bool? isLoading,
    String? error,
  }) {
    return PredictionVotesState(
      votes: votes ?? this.votes,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class PredictionVotesNotifier extends Notifier<PredictionVotesState> {
  @override
  PredictionVotesState build() => const PredictionVotesState();

  Future<void> load(
      {required String babyProfileId, bool forceRefresh = false}) async {
    if (state.isLoading && !forceRefresh) return;

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
      state = state.copyWith(isLoading: false, votes: votes);
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final predictionVotesProvider =
    NotifierProvider.autoDispose<PredictionVotesNotifier, PredictionVotesState>(
  PredictionVotesNotifier.new,
);
