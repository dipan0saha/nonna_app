import 'package:flutter_test/flutter_test.dart';

import 'package:nonna_app/core/enums/gender.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_types.dart';
import 'package:nonna_app/features/onboarding/presentation/utils/onboarding_first_moment_helpers.dart';

void main() {
  group('eventStartsAt', () {
    test('staggers events on different calendar days (#20)', () {
      final anchor = DateTime(2026, 6, 1);
      final day0 = eventStartsAt(anchor, 0);
      final day7 = eventStartsAt(anchor, 7);
      expect(day0.toUtc().day, isNot(day7.toUtc().day));
    });
  });

  group('canSelectMoreEvents', () {
    test('caps at max selectable events', () {
      expect(canSelectMoreEvents({'a'}), isTrue);
      expect(
        canSelectMoreEvents({'a', 'b'}),
        isFalse,
      );
    });
  });

  group('firstMomentAnchorDate', () {
    test('uses due date for expecting and birth date for born', () {
      final due = DateTime(2026, 12, 1);
      final born = DateTime(2026, 3, 1);
      expect(
        firstMomentAnchorDate(
          status: BabyStatus.expecting,
          expectedBirthDate: due,
        ),
        due,
      );
      expect(
        firstMomentAnchorDate(
          status: BabyStatus.born,
          actualBirthDate: born,
        ),
        born,
      );
    });
  });
}
