import 'package:flutter_test/flutter_test.dart';

import 'package:nonna_app/core/enums/gender.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_types.dart';
import 'package:nonna_app/features/onboarding/presentation/utils/onboarding_baby_helpers.dart';

void main() {
  group('onboardingBabyNameFieldsMode', () {
    test('expecting always shows both name fields', () {
      expect(
        onboardingBabyNameFieldsMode(
          status: BabyStatus.expecting,
          gender: Gender.unknown,
        ),
        OnboardingBabyNameFieldsMode.expectingBoth,
      );
    });

    test('born branch uses single field by gender (#47)', () {
      expect(
        onboardingBabyNameFieldsMode(
          status: BabyStatus.born,
          gender: Gender.female,
        ),
        OnboardingBabyNameFieldsMode.bornSingleGirl,
      );
      expect(
        onboardingBabyNameFieldsMode(
          status: BabyStatus.born,
          gender: Gender.male,
        ),
        OnboardingBabyNameFieldsMode.bornSingleBoy,
      );
    });
  });

  group('onboardingShowsUnsureGenderPill', () {
    test('hides unsure pill when already born', () {
      expect(onboardingShowsUnsureGenderPill(BabyStatus.born), isFalse);
      expect(onboardingShowsUnsureGenderPill(BabyStatus.expecting), isTrue);
    });
  });

  group('resolveOnboardingBabyName', () {
    test('uses placeholder when no names entered', () {
      expect(
        resolveOnboardingBabyName(
          status: BabyStatus.expecting,
          gender: Gender.unknown,
        ),
        'Baby',
      );
    });

    test('prefers entered boy or girl names', () {
      expect(
        resolveOnboardingBabyName(
          status: BabyStatus.expecting,
          gender: Gender.unknown,
          boyName: 'Liam',
          girlName: 'Olivia',
        ),
        'Liam',
      );
    });

    test('born uses single gender field', () {
      expect(
        resolveOnboardingBabyName(
          status: BabyStatus.born,
          gender: Gender.female,
          girlName: 'Olivia',
        ),
        'Olivia',
      );
    });
  });
}
