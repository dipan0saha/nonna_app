import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/constants/strings.dart';

void main() {
  group('AppStrings', () {
    test('has app information', () {
      expect(AppStrings.appName, 'Nonna');
      expect(AppStrings.appName.isNotEmpty, true);
      expect(AppStrings.appTagline.isNotEmpty, true);
    });

    group('error messages', () {
      test('has generic error message', () {
        expect(AppStrings.errorGeneric.isNotEmpty, true);
      });

      test('has network error message', () {
        expect(AppStrings.errorNetwork.isNotEmpty, true);
      });

      test('has authentication error messages', () {
        expect(AppStrings.errorInvalidEmail.isNotEmpty, true);
        expect(AppStrings.errorInvalidPassword.isNotEmpty, true);
        expect(AppStrings.errorWeakPassword.isNotEmpty, true);
      });

      test('has file upload error messages', () {
        expect(AppStrings.errorFileTooLarge.isNotEmpty, true);
        expect(AppStrings.errorInvalidFileType.isNotEmpty, true);
      });
    });

    group('validation messages', () {
      test('has required field message', () {
        expect(AppStrings.validationRequired.isNotEmpty, true);
      });

      test('has email validation message', () {
        expect(AppStrings.validationEmailInvalid.isNotEmpty, true);
      });

      test('has password validation messages', () {
        expect(AppStrings.validationPasswordTooShort.isNotEmpty, true);
        expect(AppStrings.validationPasswordsMismatch.isNotEmpty, true);
      });
    });

    group('success messages', () {
      test('has common success messages', () {
        expect(AppStrings.successSaved.isNotEmpty, true);
        expect(AppStrings.successDeleted.isNotEmpty, true);
        expect(AppStrings.successUpdated.isNotEmpty, true);
      });
    });

    group('empty state messages', () {
      test('has empty state messages', () {
        expect(AppStrings.emptyEvents.isNotEmpty, true);
        expect(AppStrings.emptyPhotos.isNotEmpty, true);
        expect(AppStrings.emptyNotifications.isNotEmpty, true);
      });
    });

    group('button labels', () {
      test('has common button labels', () {
        expect(AppStrings.buttonOk, 'OK');
        expect(AppStrings.buttonCancel, 'Cancel');
        expect(AppStrings.buttonSave, 'Save');
        expect(AppStrings.buttonDelete, 'Delete');
      });
    });

    group('role names', () {
      test('has role constants', () {
        expect(AppStrings.roleOwner, 'Owner');
        expect(AppStrings.roleFollower, 'Follower');
      });
    });
  });
}
