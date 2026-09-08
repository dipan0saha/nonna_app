import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nonna_app/core/constants/onboarding_storage_keys.dart';
import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/core/services/local_storage_service.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/first_run_home_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  test('firstRunHomeProvider tracks pending and dismissed baby', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = LocalStorageService();
    await storage.initialize();
    await storage.setString(
      OnboardingStorageKeys.firstRunPendingBabyId,
      'baby-1',
    );

    final container = ProviderContainer(
      overrides: [
        localStorageServiceProvider.overrideWithValue(storage),
      ],
    );

    expect(
      container.read(firstRunHomeProvider).isFirstRunFor('baby-1'),
      isTrue,
    );

    await container
        .read(firstRunHomeProvider.notifier)
        .dismissForBaby('baby-1');
    expect(
      container.read(firstRunHomeProvider).isFirstRunFor('baby-1'),
      isFalse,
    );

    container.dispose();
  });
}
