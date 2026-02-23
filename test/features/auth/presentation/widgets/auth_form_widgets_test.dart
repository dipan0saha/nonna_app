import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/features/auth/presentation/widgets/auth_form_widgets.dart';

void main() {
  group('Validators', () {
    group('validateEmail', () {
      test('returns error for empty value', () {
        expect(validateEmail(null), isNotNull);
        expect(validateEmail(''), isNotNull);
        expect(validateEmail('  '), isNotNull);
      });

      test('returns error for invalid email', () {
        expect(validateEmail('not-an-email'), isNotNull);
        expect(validateEmail('missing@tld'), isNotNull);
        expect(validateEmail('@nodomain.com'), isNotNull);
      });

      test('returns null for valid email', () {
        expect(validateEmail('user@example.com'), isNull);
        expect(validateEmail('test.user+tag@sub.domain.org'), isNull);
      });
    });

    group('validatePassword', () {
      test('returns error for empty value', () {
        expect(validatePassword(null), isNotNull);
        expect(validatePassword(''), isNotNull);
      });

      test('returns error when too short', () {
        expect(validatePassword('short'), isNotNull);
        expect(validatePassword('1234567'), isNotNull);
      });

      test('returns null for valid password', () {
        expect(validatePassword('validpass'), isNull);
        expect(validatePassword('12345678'), isNull);
      });
    });

    group('validateDisplayName', () {
      test('returns error for empty value', () {
        expect(validateDisplayName(null), isNotNull);
        expect(validateDisplayName(''), isNotNull);
        expect(validateDisplayName(' '), isNotNull);
      });

      test('returns error when too short', () {
        expect(validateDisplayName('A'), isNotNull);
      });

      test('returns null for valid name', () {
        expect(validateDisplayName('Jo'), isNull);
        expect(validateDisplayName('Alice'), isNull);
      });
    });

    group('validatePasswordConfirm', () {
      test('returns error when empty', () {
        expect(validatePasswordConfirm('', 'pass1234'), isNotNull);
        expect(validatePasswordConfirm(null, 'pass1234'), isNotNull);
      });

      test('returns error when passwords do not match', () {
        expect(validatePasswordConfirm('different', 'pass1234'), isNotNull);
      });

      test('returns null when passwords match', () {
        expect(validatePasswordConfirm('pass1234', 'pass1234'), isNull);
      });
    });
  });

  group('AuthEmailField', () {
    testWidgets('renders with email label', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              child: AuthEmailField(controller: controller),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('auth_email_field')), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      controller.dispose();
    });

    testWidgets('validates on form submission', (tester) async {
      final formKey = GlobalKey<FormState>();
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: Column(
                children: [
                  AuthEmailField(controller: controller),
                  ElevatedButton(
                    onPressed: () => formKey.currentState?.validate(),
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Submit'));
      await tester.pump();

      expect(find.text('Email is required'), findsOneWidget);
      controller.dispose();
    });
  });

  group('AuthPasswordField', () {
    testWidgets('renders with password label', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              child: AuthPasswordField(controller: controller),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('auth_password_field')), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      controller.dispose();
    });

    testWidgets('toggles password visibility', (tester) async {
      final controller = TextEditingController(text: 'secret');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              child: AuthPasswordField(controller: controller),
            ),
          ),
        ),
      );

      final field = tester.widget<TextField>(find.descendant(
        of: find.byKey(const Key('auth_password_field')),
        matching: find.byType(TextField),
      ));
      expect(field.obscureText, isTrue);

      await tester.tap(find.byKey(const Key('password_visibility_toggle')));
      await tester.pump();

      final updatedField = tester.widget<TextField>(find.descendant(
        of: find.byKey(const Key('auth_password_field')),
        matching: find.byType(TextField),
      ));
      expect(updatedField.obscureText, isFalse);
      controller.dispose();
    });

    testWidgets('shows validation error for short password', (tester) async {
      final formKey = GlobalKey<FormState>();
      final controller = TextEditingController(text: 'short');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: Column(
                children: [
                  AuthPasswordField(controller: controller),
                  ElevatedButton(
                    onPressed: () => formKey.currentState?.validate(),
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Submit'));
      await tester.pump();

      expect(
          find.text('Password must be at least 8 characters'), findsOneWidget);
      controller.dispose();
    });
  });

  group('AuthNameField', () {
    testWidgets('renders with Full Name label', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              child: AuthNameField(controller: controller),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('auth_name_field')), findsOneWidget);
      expect(find.text('Full Name'), findsOneWidget);
      controller.dispose();
    });
  });

  group('AuthPrimaryButton', () {
    testWidgets('renders with label and calls onPressed', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthPrimaryButton(
              label: 'Test',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Test'), findsOneWidget);
      await tester.tap(find.text('Test'));
      expect(tapped, isTrue);
    });

    testWidgets('shows loading indicator when isLoading is true',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthPrimaryButton(
              label: 'Test',
              onPressed: () {},
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Test'), findsNothing);
    });

    testWidgets('is disabled when isLoading is true', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthPrimaryButton(
              label: 'Test',
              onPressed: () => tapped = true,
              isLoading: true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      expect(tapped, isFalse);
    });
  });

  group('GoogleSignInButton', () {
    testWidgets('renders and calls onPressed', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GoogleSignInButton(onPressed: () => tapped = true),
          ),
        ),
      );

      expect(find.byKey(const Key('google_sign_in_button')), findsOneWidget);
      await tester.tap(find.byKey(const Key('google_sign_in_button')));
      expect(tapped, isTrue);
    });
  });

  group('FacebookSignInButton', () {
    testWidgets('renders and calls onPressed', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FacebookSignInButton(onPressed: () => tapped = true),
          ),
        ),
      );

      expect(find.byKey(const Key('facebook_sign_in_button')), findsOneWidget);
      await tester.tap(find.byKey(const Key('facebook_sign_in_button')));
      expect(tapped, isTrue);
    });
  });

  group('AuthDivider', () {
    testWidgets('renders OR text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AuthDivider()),
        ),
      );

      expect(find.text('OR'), findsOneWidget);
    });
  });

  group('AuthErrorMessage', () {
    testWidgets('renders error message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AuthErrorMessage(message: 'Something went wrong'),
          ),
        ),
      );

      expect(find.byKey(const Key('auth_error_message')), findsOneWidget);
      expect(find.text('Something went wrong'), findsOneWidget);
    });
  });
}
