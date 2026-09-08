import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/core/constants/onboarding_storage_keys.dart';
import 'package:nonna_app/features/home/presentation/providers/home_screen_provider.dart';
import 'package:nonna_app/features/home/presentation/providers/user_baby_profiles_provider.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/first_run_home_provider.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_coordinator_provider.dart';

/// Marks onboarding complete, bootstraps home, and navigates to `/home`.
Future<void> finishOwnerOnboardingAndGoHome({
  required WidgetRef ref,
  required BuildContext context,
}) async {
  final coordinatorState = ref.read(onboardingCoordinatorProvider);
  final babyId = coordinatorState.createdBabyProfileId ??
      ref.read(selectedBabyProfileProvider);

  if (babyId != null) {
    ref.read(selectedBabyProfileProvider.notifier).select(babyId);
  }

  final storage = ref.read(localStorageServiceProvider);
  if (babyId != null && storage.isInitialized) {
    await storage.setString(
      OnboardingStorageKeys.firstRunPendingBabyId,
      babyId,
    );
    ref.read(firstRunHomeProvider.notifier).reload();
  }

  await ref.read(onboardingCoordinatorProvider.notifier).completeOnboarding();
  ref.invalidate(userBabyProfilesProvider);

  if (babyId != null) {
    await ref.read(homeScreenProvider.notifier).loadTiles(
          babyProfileId: babyId,
          role: UserRole.owner,
        );
  }

  if (context.mounted) context.go('/home');
}
