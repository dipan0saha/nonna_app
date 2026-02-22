import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nonna_app/core/models/name_suggestion.dart';
import 'package:nonna_app/core/models/vote.dart';

/// Gamification feature state
///
/// **Functional Requirements**: Section 3.6.4 - Additional Feature Screens
class GamificationState {
  final List<NameSuggestion> nameSuggestions;
  final List<Vote> votes;
  final bool isLoading;
  final String? error;

  const GamificationState({
    this.nameSuggestions = const [],
    this.votes = const [],
    this.isLoading = false,
    this.error,
  });

  GamificationState copyWith({
    List<NameSuggestion>? nameSuggestions,
    List<Vote>? votes,
    bool? isLoading,
    String? error,
  }) {
    return GamificationState(
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
  Future<void> load({required String babyProfileId}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      // TODO: fetch from database
      await Future<void>.delayed(const Duration(milliseconds: 100));
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false);
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
