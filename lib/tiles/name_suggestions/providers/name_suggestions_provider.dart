import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nonna_app/core/constants/supabase_tables.dart';
import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/core/models/name_suggestion.dart';

/// Provider state for name suggestions tile
class NameSuggestionsState {
  final List<NameSuggestion> suggestions;
  final bool isLoading;
  final String? error;

  const NameSuggestionsState({
    this.suggestions = const [],
    this.isLoading = false,
    this.error,
  });

  NameSuggestionsState copyWith({
    List<NameSuggestion>? suggestions,
    bool? isLoading,
    String? error,
  }) {
    return NameSuggestionsState(
      suggestions: suggestions ?? this.suggestions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class NameSuggestionsNotifier extends Notifier<NameSuggestionsState> {
  @override
  NameSuggestionsState build() => const NameSuggestionsState();

  Future<void> load(
      {required String babyProfileId, bool forceRefresh = false}) async {
    if (state.isLoading && !forceRefresh) return;

    try {
      state = state.copyWith(isLoading: true, error: null);

      final db = ref.read(databaseServiceProvider);
      final rawData = await db
          .select(SupabaseTables.nameSuggestions)
          .eq('baby_profile_id', babyProfileId)
          .order('created_at', ascending: false)
          .limit(10); // Standard tile limit

      if (!ref.mounted) return;

      final suggestions =
          rawData.map((json) => NameSuggestion.fromJson(json)).toList();
      state = state.copyWith(isLoading: false, suggestions: suggestions);
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final nameSuggestionsProvider =
    NotifierProvider.autoDispose<NameSuggestionsNotifier, NameSuggestionsState>(
  NameSuggestionsNotifier.new,
);
