import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nonna_app/core/constants/onboarding_storage_keys.dart';
import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:nonna_app/features/home/presentation/providers/user_baby_profiles_provider.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_routes.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_types.dart';
import 'package:nonna_app/features/onboarding/presentation/utils/onboarding_analytics.dart';

/// Immutable coordinator state persisted in [LocalStorageService].
class OnboardingCoordinatorState {
  const OnboardingCoordinatorState({
    this.path = OnboardingPath.owner,
    this.step,
    this.carouselIndex = 0,
    this.pendingInviteToken,
    this.babyStatus,
    this.createdBabyProfileId,
    this.inviteeEmail,
    this.usedOAuth = false,
  });

  final OnboardingPath path;
  final OnboardingStep? step;
  final int carouselIndex;
  final String? pendingInviteToken;
  final BabyStatus? babyStatus;
  final String? createdBabyProfileId;
  final String? inviteeEmail;
  final bool usedOAuth;

  bool get hasActiveStep => step != null;

  String? get resumeRoute =>
      step == null ? null : OnboardingRoutes.pathForStep(step!);

  OnboardingCoordinatorState copyWith({
    OnboardingPath? path,
    OnboardingStep? step,
    bool clearStep = false,
    int? carouselIndex,
    String? pendingInviteToken,
    bool clearPendingInviteToken = false,
    BabyStatus? babyStatus,
    bool clearBabyStatus = false,
    String? createdBabyProfileId,
    bool clearCreatedBabyProfileId = false,
    String? inviteeEmail,
    bool clearInviteeEmail = false,
    bool? usedOAuth,
  }) {
    return OnboardingCoordinatorState(
      path: path ?? this.path,
      step: clearStep ? null : (step ?? this.step),
      carouselIndex: carouselIndex ?? this.carouselIndex,
      pendingInviteToken: clearPendingInviteToken
          ? null
          : (pendingInviteToken ?? this.pendingInviteToken),
      babyStatus: clearBabyStatus ? null : (babyStatus ?? this.babyStatus),
      createdBabyProfileId: clearCreatedBabyProfileId
          ? null
          : (createdBabyProfileId ?? this.createdBabyProfileId),
      inviteeEmail:
          clearInviteeEmail ? null : (inviteeEmail ?? this.inviteeEmail),
      usedOAuth: usedOAuth ?? this.usedOAuth,
    );
  }
}

/// Orchestrates onboarding path, step, and persistence.
class OnboardingCoordinatorNotifier
    extends Notifier<OnboardingCoordinatorState> {
  @override
  OnboardingCoordinatorState build() {
    final storage = ref.watch(localStorageServiceProvider);
    if (!storage.isInitialized) {
      return const OnboardingCoordinatorState();
    }

    final loaded = _loadFromStorage();
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    if (isAuthenticated &&
        !storage.isOnboardingCompleted &&
        !loaded.hasActiveStep) {
      ref.listen(userBabyProfilesProvider, (previous, next) {
        next.whenData((profiles) async {
          if (profiles.isEmpty) return;
          if (!ref.mounted) return;
          if (ref.read(onboardingCoordinatorProvider).hasActiveStep) return;
          final currentStorage = ref.read(localStorageServiceProvider);
          if (currentStorage.isOnboardingCompleted) return;
          await currentStorage.setOnboardingCompleted(true);
        });
      });
    }

    return loaded;
  }

  OnboardingCoordinatorState _loadFromStorage() {
    final storage = ref.read(localStorageServiceProvider);
    return OnboardingCoordinatorState(
      path: onboardingPathFromStorage(
            storage.getString(OnboardingStorageKeys.path),
          ) ??
          OnboardingPath.owner,
      step: onboardingStepFromStorage(
          storage.getString(OnboardingStorageKeys.step)),
      carouselIndex: storage.getInt(OnboardingStorageKeys.carouselIndex) ?? 0,
      pendingInviteToken:
          storage.getString(OnboardingStorageKeys.pendingInviteToken),
      babyStatus: babyStatusFromStorage(
        storage.getString(OnboardingStorageKeys.babyStatus),
      ),
      createdBabyProfileId:
          storage.getString(OnboardingStorageKeys.createdBabyProfileId),
      inviteeEmail: storage.getString(OnboardingStorageKeys.inviteeEmail),
      usedOAuth: storage.getBool(OnboardingStorageKeys.usedOAuth) ?? false,
    );
  }

  Future<void> _persist(OnboardingCoordinatorState next) async {
    state = next;
    final storage = ref.read(localStorageServiceProvider);
    if (!storage.isInitialized) return;

    await storage.setString(OnboardingStorageKeys.path, next.path.name);
    if (next.step != null) {
      await storage.setString(OnboardingStorageKeys.step, next.step!.name);
    } else {
      await storage.remove(OnboardingStorageKeys.step);
    }
    await storage.setInt(
        OnboardingStorageKeys.carouselIndex, next.carouselIndex);

    if (next.pendingInviteToken != null) {
      await storage.setString(
        OnboardingStorageKeys.pendingInviteToken,
        next.pendingInviteToken!,
      );
    } else {
      await storage.remove(OnboardingStorageKeys.pendingInviteToken);
    }

    if (next.babyStatus != null) {
      await storage.setString(
          OnboardingStorageKeys.babyStatus, next.babyStatus!.name);
    } else {
      await storage.remove(OnboardingStorageKeys.babyStatus);
    }

    if (next.createdBabyProfileId != null) {
      await storage.setString(
        OnboardingStorageKeys.createdBabyProfileId,
        next.createdBabyProfileId!,
      );
    } else {
      await storage.remove(OnboardingStorageKeys.createdBabyProfileId);
    }

    if (next.inviteeEmail != null) {
      await storage.setString(
          OnboardingStorageKeys.inviteeEmail, next.inviteeEmail!);
    } else {
      await storage.remove(OnboardingStorageKeys.inviteeEmail);
    }

    await storage.setBool(OnboardingStorageKeys.usedOAuth, next.usedOAuth);
  }

  /// Sync coordinator step when a route is entered (guard resume alignment).
  Future<void> syncStepForRoute(String location) async {
    final step = OnboardingRoutes.stepForPath(location);
    if (step == null || state.step == step) return;
    await _persist(state.copyWith(step: step));
  }

  Future<void> setPath(OnboardingPath path) async {
    await _persist(state.copyWith(path: path));
  }

  Future<void> goToStep(OnboardingStep step) async {
    final next = state.copyWith(step: step);
    await _persist(next);
    await ref.read(onboardingAnalyticsProvider).trackStepViewed(
          step: step,
          path: next.path,
        );
  }

  Future<void> advanceToRoute(String route) async {
    final nextStep = OnboardingRoutes.stepForPath(route);
    if (nextStep == null) return;
    await _persist(state.copyWith(step: nextStep));
  }

  Future<void> setCarouselIndex(int index) async {
    await _persist(state.copyWith(carouselIndex: index));
  }

  Future<void> setPendingInviteToken(String? token,
      {OnboardingPath? path}) async {
    await _persist(
      state.copyWith(
        pendingInviteToken: token,
        clearPendingInviteToken: token == null,
        path: path ?? state.path,
        step: token != null && path != null
            ? OnboardingRoutes.initialInviteStep(path)
            : state.step,
      ),
    );
  }

  Future<void> setBabyStatus(BabyStatus status) async {
    await _persist(state.copyWith(babyStatus: status));
  }

  Future<void> setCreatedBabyProfileId(String id) async {
    await _persist(state.copyWith(createdBabyProfileId: id));
  }

  Future<void> setInviteeEmail(String? email) async {
    await _persist(
      state.copyWith(
        inviteeEmail: email,
        clearInviteeEmail: email == null,
      ),
    );
  }

  Future<void> setUsedOAuth(bool value) async {
    await _persist(state.copyWith(usedOAuth: value));
  }

  Future<void> dismissPendingInvite() async {
    await _persist(
      state.copyWith(
        clearPendingInviteToken: true,
        clearInviteeEmail: true,
        path: OnboardingPath.owner,
        step: OnboardingStep.carousel,
      ),
    );
  }

  /// Marks wizard complete and clears transient coordinator keys.
  Future<void> completeOnboarding() async {
    final completedPath = state.path;
    final storage = ref.read(localStorageServiceProvider);
    await storage.setOnboardingCompleted(true);
    await storage.clearOnboardingCoordinatorState();
    await ref
        .read(onboardingAnalyticsProvider)
        .trackCompleted(path: completedPath);
    state = const OnboardingCoordinatorState();
  }

  /// Path-aware back navigation target for [PopScope] / toolbar back.
  Future<String?> goBack() async {
    final current = state.step ?? OnboardingStep.carousel;

    switch (current) {
      case OnboardingStep.carousel:
        if (state.carouselIndex > 0) {
          await _persist(
            state.copyWith(carouselIndex: state.carouselIndex - 1),
          );
          return null;
        }
        return null;
      case OnboardingStep.signup:
        if (state.path == OnboardingPath.owner) {
          await goToStep(OnboardingStep.carousel);
          return OnboardingRoutes.ownerCarousel;
        }
        final inviteStep = state.path == OnboardingPath.coOwner
            ? OnboardingStep.coOwnerInvite
            : OnboardingStep.followerInvite;
        await goToStep(inviteStep);
        return OnboardingRoutes.pathForStep(inviteStep);
      case OnboardingStep.login:
        await goToStep(OnboardingStep.signup);
        return OnboardingRoutes.signupPathFor(state.path);
      case OnboardingStep.emailVerify:
        await goToStep(OnboardingStep.signup);
        return OnboardingRoutes.signupPathFor(state.path);
      case OnboardingStep.completeProfile:
        if (state.usedOAuth) {
          final inviteStep = _inviteStepForPath();
          if (inviteStep != null) {
            await goToStep(inviteStep);
            return OnboardingRoutes.pathForStep(inviteStep);
          }
          await goToStep(OnboardingStep.carousel);
          return OnboardingRoutes.ownerCarousel;
        }
        await goToStep(OnboardingStep.emailVerify);
        return OnboardingRoutes.emailVerify;
      case OnboardingStep.createBaby:
        await goToStep(OnboardingStep.completeProfile);
        return OnboardingRoutes.completeProfile;
      case OnboardingStep.firstMoment:
        await goToStep(OnboardingStep.createBaby);
        return OnboardingRoutes.ownerCreateBaby;
      case OnboardingStep.batchInvite:
        await goToStep(OnboardingStep.firstMoment);
        return OnboardingRoutes.ownerFirstMoment;
      case OnboardingStep.followerInvite:
      case OnboardingStep.coOwnerInvite:
        await dismissPendingInvite();
        return OnboardingRoutes.ownerCarousel;
      case OnboardingStep.confirmRelationship:
        await goToStep(OnboardingStep.completeProfile);
        return OnboardingRoutes.completeProfile;
      case OnboardingStep.followerCarousel:
        await goToStep(OnboardingStep.confirmRelationship);
        return OnboardingRoutes.confirmRelationship;
      case OnboardingStep.coOwnerWelcome:
        await goToStep(OnboardingStep.completeProfile);
        return OnboardingRoutes.completeProfile;
    }
  }

  OnboardingStep? _inviteStepForPath() {
    switch (state.path) {
      case OnboardingPath.follower:
        return OnboardingStep.followerInvite;
      case OnboardingPath.coOwner:
        return OnboardingStep.coOwnerInvite;
      case OnboardingPath.owner:
        return null;
    }
  }
}

final onboardingCoordinatorProvider =
    NotifierProvider<OnboardingCoordinatorNotifier, OnboardingCoordinatorState>(
  OnboardingCoordinatorNotifier.new,
);

final isOnboardingCompletedProvider = Provider<bool>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  if (!storage.isInitialized) return false;
  return storage.isOnboardingCompleted;
});

/// Whether the authenticated user has at least one baby membership.
final userHasBabyMembershipsProvider = Provider<bool>((ref) {
  if (!ref.watch(isAuthenticatedProvider)) return false;
  final profiles = ref.watch(userBabyProfilesProvider);
  return profiles.maybeWhen(
    data: (list) => list.isNotEmpty,
    orElse: () => false,
  );
});
