import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nonna_app/core/constants/onboarding_storage_keys.dart';
import 'package:nonna_app/core/di/providers.dart';

/// First-run home overlay state (#40, #68).
class FirstRunHomeState {
  const FirstRunHomeState({
    this.pendingBabyProfileId,
    this.dismissedBabyIds = const {},
  });

  final String? pendingBabyProfileId;
  final Set<String> dismissedBabyIds;

  bool isFirstRunFor(String? babyProfileId) {
    if (babyProfileId == null || pendingBabyProfileId == null) return false;
    if (babyProfileId != pendingBabyProfileId) return false;
    return !dismissedBabyIds.contains(babyProfileId);
  }
}

class FirstRunHomeNotifier extends Notifier<FirstRunHomeState> {
  @override
  FirstRunHomeState build() => _load();

  FirstRunHomeState _load() {
    final storage = ref.read(localStorageServiceProvider);
    if (!storage.isInitialized) return const FirstRunHomeState();

    final pending =
        storage.getString(OnboardingStorageKeys.firstRunPendingBabyId);
    final dismissed = <String>{};
    if (pending != null &&
        storage.getBool(OnboardingStorageKeys.firstRunDismissedKey(pending)) ==
            true) {
      dismissed.add(pending);
    }
    return FirstRunHomeState(
      pendingBabyProfileId: pending,
      dismissedBabyIds: dismissed,
    );
  }

  void reload() {
    state = _load();
  }

  Future<void> dismissForBaby(String babyProfileId) async {
    final storage = ref.read(localStorageServiceProvider);
    if (!storage.isInitialized) return;
    await storage.setBool(
      OnboardingStorageKeys.firstRunDismissedKey(babyProfileId),
      true,
    );
    if (state.pendingBabyProfileId == babyProfileId) {
      await storage.remove(OnboardingStorageKeys.firstRunPendingBabyId);
    }
    reload();
  }
}

final firstRunHomeProvider =
    NotifierProvider<FirstRunHomeNotifier, FirstRunHomeState>(
  FirstRunHomeNotifier.new,
);
