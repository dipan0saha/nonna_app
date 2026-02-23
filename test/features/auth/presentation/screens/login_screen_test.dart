import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:nonna_app/features/auth/presentation/providers/auth_state.dart';
import 'package:nonna_app/features/auth/presentation/screens/login_screen.dart';

// ---------------------------------------------------------------------------
// Fake AuthNotifier for widget tests
// ---------------------------------------------------------------------------

class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier(this._initial);

  final AuthState _initial;

  @override
  AuthState build() => _initial;

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> signInWithGoogle() async {}

  @override
  Future<void> signInWithFacebook() async {}

  @override
  Future<void> resetPassword(String email) async {}
}

// ---------------------------------------------------------------------------
// Helper: wrap widget in ProviderScope with a given auth state
// ---------------------------------------------------------------------------

Widget _buildLoginScreen(
  AuthState initialState, {
  VoidCallback? onSignUpTap,
  VoidCallback? onForgotPasswordTap,
}) {
  return ProviderScope(
    overrides: [
      authProvider.overrideWith(() => _FakeAuthNotifier(initialState)),
    ],
    child: MaterialApp(
      home: LoginScreen(
        onSignUpTap: onSignUpTap,
        onForgotPasswordTap: onForgotPasswordTap,
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('LoginScreen', () {
    testWidgets('renders email and password fields', (tester) async {
      await tester.pumpWidget(
        _buildLoginScreen(const AuthState.unauthenticated()),
      );

      expect(find.byKey(const Key('auth_email_field')), findsOneWidget);
      expect(find.byKey(const Key('auth_password_field')), findsOneWidget);
    });

    testWidgets('renders sign in button', (tester) async {
      await tester.pumpWidget(
        _buildLoginScreen(const AuthState.unauthenticated()),
      );

      expect(find.byKey(const Key('sign_in_button')), findsOneWidget);
    });

    testWidgets('renders OAuth buttons', (tester) async {
      await tester.pumpWidget(
        _buildLoginScreen(const AuthState.unauthenticated()),
      );

      expect(find.byKey(const Key('google_sign_in_button')), findsOneWidget);
      expect(find.byKey(const Key('facebook_sign_in_button')), findsOneWidget);
    });

    testWidgets('renders forgot password button', (tester) async {
      await tester.pumpWidget(
        _buildLoginScreen(const AuthState.unauthenticated()),
      );

      expect(find.byKey(const Key('forgot_password_button')), findsOneWidget);
    });

    testWidgets('renders go to sign-up button', (tester) async {
      await tester.pumpWidget(
        _buildLoginScreen(const AuthState.unauthenticated()),
      );

      expect(find.byKey(const Key('go_to_signup_button')), findsOneWidget);
    });

    testWidgets('shows validation errors when submitting empty form',
        (tester) async {
      await tester.pumpWidget(
        _buildLoginScreen(const AuthState.unauthenticated()),
      );

      await tester.tap(find.byKey(const Key('sign_in_button')));
      await tester.pump();

      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('shows error message when auth state has error',
        (tester) async {
      await tester.pumpWidget(
        _buildLoginScreen(const AuthState.error('Invalid credentials')),
      );
      await tester.pump();

      expect(find.byKey(const Key('auth_error_message')), findsOneWidget);
      expect(find.text('Invalid credentials'), findsOneWidget);
    });

    testWidgets('shows loading indicator when auth state is loading',
        (tester) async {
      await tester.pumpWidget(
        _buildLoginScreen(const AuthState.loading()),
      );
      await tester.pump();

      // Multiple buttons show progress indicators when loading
      expect(find.byType(CircularProgressIndicator), findsAtLeastNWidgets(1));
    });

    testWidgets('calls onSignUpTap when sign-up button tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        _buildLoginScreen(
          const AuthState.unauthenticated(),
          onSignUpTap: () => tapped = true,
        ),
      );

      await tester.tap(find.byKey(const Key('go_to_signup_button')));
      expect(tapped, isTrue);
    });

    testWidgets('calls onForgotPasswordTap when forgot password tapped',
        (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        _buildLoginScreen(
          const AuthState.unauthenticated(),
          onForgotPasswordTap: () => tapped = true,
        ),
      );

      await tester.tap(find.byKey(const Key('forgot_password_button')));
      expect(tapped, isTrue);
    });
  });
}
