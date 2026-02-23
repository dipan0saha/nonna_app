import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:nonna_app/features/auth/presentation/providers/auth_state.dart';
import 'package:nonna_app/features/auth/presentation/screens/signup_screen.dart';

// ---------------------------------------------------------------------------
// Fake AuthNotifier
// ---------------------------------------------------------------------------

class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier(this._initial);

  final AuthState _initial;

  @override
  AuthState build() => _initial;

  @override
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {}

  @override
  Future<void> signInWithGoogle() async {}

  @override
  Future<void> signInWithFacebook() async {}
}

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

Widget _buildSignupScreen(
  AuthState initialState, {
  VoidCallback? onLoginTap,
}) {
  return ProviderScope(
    overrides: [
      authProvider.overrideWith(() => _FakeAuthNotifier(initialState)),
    ],
    child: MaterialApp(
      home: SignupScreen(onLoginTap: onLoginTap),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('SignupScreen', () {
    testWidgets('renders all input fields', (tester) async {
      await tester.pumpWidget(
        _buildSignupScreen(const AuthState.unauthenticated()),
      );

      expect(find.byKey(const Key('auth_name_field')), findsOneWidget);
      expect(find.byKey(const Key('auth_email_field')), findsOneWidget);
      expect(find.byKey(const Key('signup_password_field')), findsOneWidget);
      expect(find.byKey(const Key('signup_confirm_password_field')),
          findsOneWidget);
    });

    testWidgets('renders sign-up button', (tester) async {
      await tester.pumpWidget(
        _buildSignupScreen(const AuthState.unauthenticated()),
      );

      expect(find.byKey(const Key('sign_up_button')), findsOneWidget);
    });

    testWidgets('renders OAuth buttons', (tester) async {
      await tester.pumpWidget(
        _buildSignupScreen(const AuthState.unauthenticated()),
      );

      expect(find.byKey(const Key('google_sign_in_button')), findsOneWidget);
      expect(find.byKey(const Key('facebook_sign_in_button')), findsOneWidget);
    });

    testWidgets('renders terms checkbox', (tester) async {
      await tester.pumpWidget(
        _buildSignupScreen(const AuthState.unauthenticated()),
      );

      expect(find.byKey(const Key('terms_checkbox')), findsOneWidget);
    });

    testWidgets('shows validation errors when submitting empty form',
        (tester) async {
      await tester.pumpWidget(
        _buildSignupScreen(const AuthState.unauthenticated()),
      );

      await tester.tap(find.byKey(const Key('sign_up_button')));
      await tester.pump();

      // At minimum the name field should have an error
      expect(find.text('Name is required'), findsOneWidget);
    });

    testWidgets('shows terms error when form valid but terms not accepted',
        (tester) async {
      await tester.pumpWidget(
        _buildSignupScreen(const AuthState.unauthenticated()),
      );

      // Fill required fields
      await tester.enterText(find.byKey(const Key('auth_name_field')), 'Alice');
      await tester.enterText(
          find.byKey(const Key('auth_email_field')), 'alice@example.com');
      await tester.enterText(
          find.byKey(const Key('signup_password_field')), 'password123');
      await tester.enterText(
          find.byKey(const Key('signup_confirm_password_field')),
          'password123');

      await tester.tap(find.byKey(const Key('sign_up_button')));
      await tester.pump();

      expect(
        find.text('You must accept the terms to continue'),
        findsOneWidget,
      );
    });

    testWidgets('shows error message when auth state has error',
        (tester) async {
      await tester.pumpWidget(
        _buildSignupScreen(const AuthState.error('Email already in use')),
      );
      await tester.pump();

      expect(find.byKey(const Key('auth_error_message')), findsOneWidget);
      expect(find.text('Email already in use'), findsOneWidget);
    });

    testWidgets('shows loading indicator when auth state is loading',
        (tester) async {
      await tester.pumpWidget(
        _buildSignupScreen(const AuthState.loading()),
      );
      await tester.pump();

      // Multiple buttons show progress indicators when loading
      expect(find.byType(CircularProgressIndicator), findsAtLeastNWidgets(1));
    });

    testWidgets('calls onLoginTap when sign-in link is tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        _buildSignupScreen(
          const AuthState.unauthenticated(),
          onLoginTap: () => tapped = true,
        ),
      );

      await tester.tap(find.byKey(const Key('go_to_login_button')));
      expect(tapped, isTrue);
    });

    testWidgets('renders go-to-login button', (tester) async {
      await tester.pumpWidget(
        _buildSignupScreen(const AuthState.unauthenticated()),
      );

      expect(find.byKey(const Key('go_to_login_button')), findsOneWidget);
    });
  });
}
