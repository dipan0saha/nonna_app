import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/core/services/local_storage_service.dart';
import 'package:nonna_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:nonna_app/features/auth/presentation/providers/auth_state.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_types.dart';
import 'package:nonna_app/features/onboarding/presentation/screens/shared/onboarding_login_screen.dart';
import 'package:nonna_app/features/onboarding/presentation/screens/shared/onboarding_signup_screen.dart';
import 'package:nonna_app/features/onboarding/presentation/widgets/onboarding_scaffold.dart';

class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier(this._initial);

  final AuthState _initial;

  @override
  AuthState build() => _initial;

  @override
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async =>
      false;

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> signInWithGoogle() async {}

  @override
  Future<void> signInWithFacebook() async {}
}

Widget _wrap(Widget child, {required LocalStorageService storage}) {
  return ProviderScope(
    overrides: [
      localStorageServiceProvider.overrideWithValue(storage),
      isAuthenticatedProvider.overrideWithValue(false),
      authProvider.overrideWith(
          () => _FakeAuthNotifier(const AuthState.unauthenticated())),
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

  group('OnboardingSignupScreen', () {
    testWidgets('shows prototype elements without name or terms fields',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          const OnboardingSignupScreen(path: OnboardingPath.owner),
          storage: storage,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('PRIVATE. ORGANIZED. CONNECTED.'), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Continue with Facebook'), findsOneWidget);
      expect(find.text('or sign up with email'), findsOneWidget);
      expect(find.text('At least 8 characters.'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.byKey(const Key('onboarding_signup_login_link')),
          findsOneWidget);
      expect(find.text('Full Name'), findsNothing);
      expect(find.byType(Checkbox), findsNothing);
    });
  });

  group('OnboardingLoginScreen', () {
    testWidgets('shows welcome back and sign up link', (tester) async {
      await tester.pumpWidget(
        _wrap(const OnboardingLoginScreen(), storage: storage),
      );
      await tester.pumpAndSettle();

      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.byKey(const Key('onboarding_login_signup_link')),
          findsOneWidget);
    });
  });
}
