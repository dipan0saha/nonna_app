import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/core/services/local_storage_service.dart';
import 'package:nonna_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:nonna_app/features/auth/presentation/providers/auth_state.dart';
import 'package:nonna_app/features/baby_profile/presentation/providers/baby_profile_provider.dart';
import 'package:nonna_app/features/onboarding/presentation/screens/owner/onboarding_batch_invite_screen.dart';
import 'package:nonna_app/features/onboarding/presentation/widgets/onboarding_scaffold.dart';

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

void main() {
  late LocalStorageService storage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = LocalStorageService();
    await storage.initialize();
  });

  testWidgets('shows batch invite prototype copy', (tester) async {
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

    await tester.pumpWidget(
      ProviderScope(
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
        child: const MaterialApp(
          home: OnboardingThemeScope(child: OnboardingBatchInviteScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Invite family & friends'), findsOneWidget);
    expect(find.text('Send Invites'), findsOneWidget);
    expect(find.text('+ Add another'), findsOneWidget);
  });
}
