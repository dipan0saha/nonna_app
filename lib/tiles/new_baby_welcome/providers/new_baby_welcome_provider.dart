import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/performance_limits.dart';
import '../../../core/constants/supabase_tables.dart';
import '../../../core/di/providers.dart';
import '../../../core/models/baby_profile.dart';

/// The window (in days from actual birth date) during which the
/// NewBabyWelcome tile is shown on the owner Home screen.
const int kNewBabyWelcomeWindowDays = 7;

/// State for the NewBabyWelcome tile.
///
/// Holds the baby profile whose birth date is within the 7-day welcome window,
/// plus standard loading/error flags.
class NewBabyWelcomeState {
  final BabyProfile? babyProfile;
  final bool isLoading;
  final String? error;

  const NewBabyWelcomeState({
    this.babyProfile,
    this.isLoading = false,
    this.error,
  });

  /// Whether the welcome window is still active for the loaded profile.
  bool get isWithinWelcomeWindow {
    if (babyProfile?.actualBirthDate == null) return false;
    final daysSinceBirth =
        DateTime.now().difference(babyProfile!.actualBirthDate!).inDays;
    return daysSinceBirth >= 0 && daysSinceBirth < kNewBabyWelcomeWindowDays;
  }

  NewBabyWelcomeState copyWith({
    BabyProfile? babyProfile,
    bool? isLoading,
    String? error,
  }) {
    return NewBabyWelcomeState(
      babyProfile: babyProfile ?? this.babyProfile,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier for the NewBabyWelcome tile.
///
/// Fetches the baby profile for the given [babyProfileId], determines if
/// `actual_birth_date` is within [kNewBabyWelcomeWindowDays] days of today,
/// and exposes the result via [NewBabyWelcomeState].
///
/// Caching: profile data is cached via [CacheService] with a short TTL so
/// the tile reacts quickly after a birth date is saved, while remaining
/// resilient to brief network outages.
class NewBabyWelcomeNotifier extends Notifier<NewBabyWelcomeState> {
  static const String _cacheKeyPrefix = 'new_baby_welcome_v1';

  @override
  NewBabyWelcomeState build() => const NewBabyWelcomeState();

  // ==========================================
  // Public Methods
  // ==========================================

  /// Fetch the baby profile and evaluate whether the welcome tile should show.
  Future<void> fetchProfile({
    required String babyProfileId,
    bool forceRefresh = false,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Try cache first
      if (!forceRefresh) {
        final cached = await _loadFromCache(babyProfileId);
        if (!ref.mounted) return;
        if (cached != null) {
          state = state.copyWith(
            babyProfile: cached,
            isLoading: false,
          );
          return;
        }
      }

      final profile = await _fetchFromDatabase(babyProfileId);
      if (!ref.mounted) return;

      await _saveToCache(babyProfileId, profile);
      if (!ref.mounted) return;

      state = state.copyWith(
        babyProfile: profile,
        isLoading: false,
      );

      debugPrint(
        '✅ NewBabyWelcome: loaded profile "${profile?.name}", '
        'within window: ${state.isWithinWelcomeWindow}',
      );
    } catch (e) {
      if (!ref.mounted) return;
      final msg = 'Failed to load baby profile for welcome tile: $e';
      debugPrint('❌ $msg');
      state = state.copyWith(isLoading: false, error: msg);
    }
  }

  /// Force-refresh (e.g. after birth date is saved).
  Future<void> refresh({required String babyProfileId}) async {
    await fetchProfile(babyProfileId: babyProfileId, forceRefresh: true);
  }

  // ==========================================
  // Private Methods
  // ==========================================

  Future<BabyProfile?> _fetchFromDatabase(String babyProfileId) async {
    final db = ref.read(databaseServiceProvider);
    final response = await db
        .select(SupabaseTables.babyProfiles)
        .eq(SupabaseTables.id, babyProfileId)
        .isFilter(SupabaseTables.deletedAt, null)
        .maybeSingle();

    if (response == null) return null;
    return BabyProfile.fromJson(Map<String, dynamic>.from(response as Map));
  }

  Future<BabyProfile?> _loadFromCache(String babyProfileId) async {
    final cacheService = ref.read(cacheServiceProvider);
    if (!cacheService.isInitialized) return null;
    try {
      final cached = await cacheService.get(_cacheKey(babyProfileId));
      if (cached == null) return null;
      return BabyProfile.fromJson(Map<String, dynamic>.from(cached as Map));
    } catch (e) {
      debugPrint('⚠️ NewBabyWelcome: cache read failed: $e');
      return null;
    }
  }

  Future<void> _saveToCache(String babyProfileId, BabyProfile? profile) async {
    if (profile == null) return;
    final cacheService = ref.read(cacheServiceProvider);
    if (!cacheService.isInitialized) return;
    try {
      await cacheService.put(
        _cacheKey(babyProfileId),
        profile.toJson(),
        ttlMinutes: PerformanceLimits.tileCacheDuration.inMinutes,
      );
    } catch (e) {
      debugPrint('⚠️ NewBabyWelcome: cache write failed: $e');
    }
  }

  String _cacheKey(String babyProfileId) => '${_cacheKeyPrefix}_$babyProfileId';
}

/// Global provider for [NewBabyWelcomeNotifier].
final newBabyWelcomeProvider =
    NotifierProvider<NewBabyWelcomeNotifier, NewBabyWelcomeState>(
  NewBabyWelcomeNotifier.new,
);
