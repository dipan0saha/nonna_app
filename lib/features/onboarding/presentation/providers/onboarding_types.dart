/// Onboarding path implied by entry point (owner carousel vs invite link).
enum OnboardingPath {
  owner,
  follower,
  coOwner,
}

/// Baby status selected during owner create-baby step.
enum BabyStatus {
  expecting,
  born,
}

/// Ordered steps across owner, follower, and co-owner flows.
enum OnboardingStep {
  carousel,
  signup,
  login,
  emailVerify,
  completeProfile,
  createBaby,
  firstMoment,
  batchInvite,
  followerInvite,
  coOwnerInvite,
  confirmRelationship,
  followerCarousel,
  coOwnerWelcome,
}

OnboardingPath? onboardingPathFromStorage(String? value) {
  if (value == null) return null;
  for (final path in OnboardingPath.values) {
    if (path.name == value) return path;
  }
  return null;
}

BabyStatus? babyStatusFromStorage(String? value) {
  if (value == null) return null;
  for (final status in BabyStatus.values) {
    if (status.name == value) return status;
  }
  return null;
}

OnboardingStep? onboardingStepFromStorage(String? value) {
  if (value == null) return null;
  for (final step in OnboardingStep.values) {
    if (step.name == value) return step;
  }
  return null;
}
