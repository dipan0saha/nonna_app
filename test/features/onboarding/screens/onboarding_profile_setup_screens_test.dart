import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import 'package:nonna_app/core/constants/onboarding_storage_keys.dart';
import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/core/services/local_storage_service.dart';
import 'package:nonna_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:nonna_app/features/auth/presentation/providers/auth_state.dart';
import 'package:nonna_app/features/onboarding/presentation/screens/shared/onboarding_complete_profile_screen.dart';
import 'package:nonna_app/features/onboarding/presentation/screens/shared/onboarding_email_verify_screen.dart';
import 'package:nonna_app/features/onboarding/presentation/widgets/onboarding_scaffold.dart';
import 'package:nonna_app/features/profile/presentation/providers/profile_provider.dart';

class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier(this._initial);

  final AuthState _initial;

  @override
  AuthState build() => _initial;

  @override
  Future<bool> resendSignupVerificationEmail(String email) async => true;

  @override
  Future<void> refreshSession() async {}
}

class _FakeProfileNotifier extends ProfileNotifier {
  @override
  ProfileState build() => const ProfileState();
}

Widget _wrap(
  Widget child, {
  required LocalStorageService storage,
  bool isAuthenticated = false,
  supabase.User? user,
  supabase.Session? session,
}) {
  return ProviderScope(
    overrides: [
      localStorageServiceProvider.overrideWithValue(storage),
      isAuthenticatedProvider.overrideWithValue(isAuthenticated),
      currentAuthUserProvider.overrideWithValue(user),
      authProvider.overrideWith(
        () => _FakeAuthNotifier(
          user != null && session != null
              ? AuthState.authenticated(user: user, session: session)
              : const AuthState.unauthenticated(),
        ),
      ),
      profileProvider.overrideWith(_FakeProfileNotifier.new),
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

  group('OnboardingEmailVerifyScreen', () {
    testWidgets('shows prototype copy and resend link', (tester) async {
      await storage.setString(
        OnboardingStorageKeys.inviteeEmail,
        'test@example.com',
      );

      await tester.pumpWidget(
        _wrap(const OnboardingEmailVerifyScreen(), storage: storage),
      );
      await tester.pumpAndSettle();

      expect(find.text('Check your email'), findsOneWidget);
      expect(find.byKey(const Key('onboarding_email_verify_resend')),
          findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });
  });

  group('OnboardingCompleteProfileScreen', () {
    testWidgets('shows name field, photo picker, and terms checkbox',
        (tester) async {
      final user = supabase.User(
        id: 'user-1',
        appMetadata: const {},
        userMetadata: const {'full_name': 'Sarah Parker'},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
      );
      final session = supabase.Session(
        accessToken: 'access',
        tokenType: 'bearer',
        user: user,
      );

      await tester.pumpWidget(
        _wrap(
          const OnboardingCompleteProfileScreen(),
          storage: storage,
          isAuthenticated: true,
          user: user,
          session: session,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Complete your profile'), findsOneWidget);
      expect(find.text('Full name'), findsOneWidget);
      expect(find.text('Add a photo'), findsOneWidget);
      expect(find.text('Terms of Service'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);
      expect(
        find.byKey(const Key('onboarding_complete_profile_terms')),
        findsOneWidget,
      );
    });
  });
}
