import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/core/services/local_storage_service.dart';
import 'package:nonna_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:nonna_app/features/auth/presentation/providers/auth_state.dart';
import 'package:nonna_app/features/baby_profile/presentation/providers/baby_profile_provider.dart';
import 'package:nonna_app/features/onboarding/presentation/screens/owner/onboarding_create_baby_screen.dart';
import 'package:nonna_app/features/onboarding/presentation/widgets/onboarding_scaffold.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier(this._initial);

  final AuthState _initial;

  @override
  AuthState build() => _initial;
}

class _FakeBabyProfileNotifier extends BabyProfileNotifier {
  @override
  BabyProfileState build() => const BabyProfileState();
}

Widget _wrap(Widget child, {required LocalStorageService storage}) {
  final user = supabase.User(
    id: 'user-1',
    appMetadata: const {},
    userMetadata: const {},
    aud: 'authenticated',
    createdAt: DateTime.now().toIso8601String(),
  );
  final session = supabase.Session(
    accessToken: 'access',
    tokenType: 'bearer',
    user: user,
  );

  return ProviderScope(
    overrides: [
      localStorageServiceProvider.overrideWithValue(storage),
      isAuthenticatedProvider.overrideWithValue(true),
      currentAuthUserProvider.overrideWithValue(user),
      authProvider.overrideWith(
        () => _FakeAuthNotifier(
          AuthState.authenticated(user: user, session: session),
        ),
      ),
      babyProfileProvider.overrideWith(_FakeBabyProfileNotifier.new),
    ],
    child: MaterialApp(
      home: OnboardingThemeScope(child: child),
    ),
  );
}

void main() {
  late LocalStorageService storage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = LocalStorageService();
    await storage.initialize();
  });

  testWidgets('shows prototype create-baby elements', (tester) async {
    await tester.pumpWidget(
      _wrap(const OnboardingCreateBabyScreen(), storage: storage),
    );
    await tester.pumpAndSettle();

    expect(find.text("Create your baby's profile"), findsOneWidget);
    expect(find.text('Expecting'), findsOneWidget);
    expect(find.text('Already Born'), findsOneWidget);
    expect(find.text('Expected Due Date'), findsOneWidget);
    expect(find.text('Not sure yet'), findsOneWidget);
    expect(find.text("Boy's name (optional)"), findsOneWidget);
    expect(find.text("Girl's name (optional)"), findsOneWidget);
    expect(find.text('Add a photo'), findsOneWidget);
  });

  testWidgets('hides unsure gender and dual names when already born',
      (tester) async {
    await tester.pumpWidget(
      _wrap(const OnboardingCreateBabyScreen(), storage: storage),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Already Born'));
    await tester.pumpAndSettle();

    expect(find.text('Not sure yet'), findsNothing);
    expect(find.text('Date of Birth'), findsOneWidget);
    expect(find.text("Boy's name (optional)"), findsOneWidget);
    expect(find.text("Girl's name (optional)"), findsNothing);
  });
}
