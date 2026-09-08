import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nonna_app/core/constants/onboarding_storage_keys.dart';
import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/core/services/local_storage_service.dart';
import 'package:nonna_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_coordinator_provider.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_routes.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_types.dart';

void main() {
  group('OnboardingCoordinatorNotifier', () {
    late ProviderContainer container;
    late LocalStorageService storage;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storage = LocalStorageService();
      await storage.initialize();
      container = ProviderContainer(
        overrides: [
          localStorageServiceProvider.overrideWithValue(storage),
          isAuthenticatedProvider.overrideWithValue(false),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('persists path and step to local storage', () async {
      final notifier = container.read(onboardingCoordinatorProvider.notifier);
      await notifier.setPath(OnboardingPath.owner);
      await notifier.goToStep(OnboardingStep.signup);

      expect(
        storage.getString(OnboardingStorageKeys.path),
        OnboardingPath.owner.name,
      );
      expect(
        storage.getString(OnboardingStorageKeys.step),
        OnboardingStep.signup.name,
      );
      expect(
        container.read(onboardingCoordinatorProvider).resumeRoute,
        OnboardingRoutes.signup,
      );
    });

    test('advanceToRoute updates step for forward navigation', () async {
      final notifier = container.read(onboardingCoordinatorProvider.notifier);
      await notifier.goToStep(OnboardingStep.signup);

      await notifier.advanceToRoute(OnboardingRoutes.emailVerify);

      expect(
        container.read(onboardingCoordinatorProvider).step,
        OnboardingStep.emailVerify,
      );
      expect(
        storage.getString(OnboardingStorageKeys.step),
        OnboardingStep.emailVerify.name,
      );
    });

    test('goBack from signup returns owner carousel for owner path', () async {
      final notifier = container.read(onboardingCoordinatorProvider.notifier);
      await notifier.goToStep(OnboardingStep.signup);

      final route = await notifier.goBack();
      expect(route, OnboardingRoutes.ownerCarousel);
      expect(
        container.read(onboardingCoordinatorProvider).step,
        OnboardingStep.carousel,
      );
    });

    test('persists usedOAuth across reload', () async {
      final notifier = container.read(onboardingCoordinatorProvider.notifier);
      await notifier.setUsedOAuth(true);

      expect(storage.getBool(OnboardingStorageKeys.usedOAuth), isTrue);

      final reloaded = container.read(onboardingCoordinatorProvider);
      expect(reloaded.usedOAuth, isTrue);
    });

    test('completeOnboarding clears coordinator keys and marks completed',
        () async {
      final notifier = container.read(onboardingCoordinatorProvider.notifier);
      await notifier.goToStep(OnboardingStep.createBaby);
      await notifier.setPendingInviteToken('token-123');

      await notifier.completeOnboarding();

      expect(storage.isOnboardingCompleted, isTrue);
      expect(storage.getString(OnboardingStorageKeys.step), isNull);
      expect(
        storage.getString(OnboardingStorageKeys.pendingInviteToken),
        isNull,
      );
      expect(
          container.read(onboardingCoordinatorProvider).hasActiveStep, isFalse);
    });

    test('dismissPendingInvite resets to owner carousel', () async {
      final notifier = container.read(onboardingCoordinatorProvider.notifier);
      await notifier.setPendingInviteToken(
        'token-abc',
        path: OnboardingPath.follower,
      );

      await notifier.dismissPendingInvite();

      final state = container.read(onboardingCoordinatorProvider);
      expect(state.pendingInviteToken, isNull);
      expect(state.path, OnboardingPath.owner);
      expect(state.step, OnboardingStep.carousel);
    });
  });
}
