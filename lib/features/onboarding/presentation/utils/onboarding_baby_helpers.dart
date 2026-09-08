import 'package:nonna_app/core/enums/gender.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_types.dart';

/// Which name inputs to show on create-baby (prototype `renderNameFields`).
enum OnboardingBabyNameFieldsMode {
  expectingBoth,
  bornSingleBoy,
  bornSingleGirl,
}

OnboardingBabyNameFieldsMode onboardingBabyNameFieldsMode({
  required BabyStatus status,
  required Gender gender,
}) {
  if (status == BabyStatus.expecting) {
    return OnboardingBabyNameFieldsMode.expectingBoth;
  }
  return gender == Gender.female
      ? OnboardingBabyNameFieldsMode.bornSingleGirl
      : OnboardingBabyNameFieldsMode.bornSingleBoy;
}

bool onboardingShowsUnsureGenderPill(BabyStatus status) =>
    status == BabyStatus.expecting;

/// Resolves the primary `baby_profiles.name` from optional onboarding fields.
String resolveOnboardingBabyName({
  required BabyStatus status,
  required Gender gender,
  String? boyName,
  String? girlName,
  String? bornName,
}) {
  final boy = boyName?.trim() ?? '';
  final girl = girlName?.trim() ?? '';
  final single = bornName?.trim() ?? '';

  if (status == BabyStatus.born) {
    if (single.isNotEmpty) return single;
    if (gender == Gender.female && girl.isNotEmpty) return girl;
    if (boy.isNotEmpty) return boy;
    if (girl.isNotEmpty) return girl;
    return 'Baby';
  }

  if (boy.isNotEmpty && girl.isEmpty) return boy;
  if (girl.isNotEmpty && boy.isEmpty) return girl;
  if (boy.isNotEmpty) return boy;
  if (girl.isNotEmpty) return girl;
  return 'Baby';
}
