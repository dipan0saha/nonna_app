import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nonna_app/core/themes/colors.dart';
import 'package:nonna_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:nonna_app/features/auth/presentation/providers/auth_state.dart';
import 'package:nonna_app/features/auth/presentation/widgets/auth_form_widgets.dart';

/// Sign-up screen
///
/// **Functional Requirements**: Section 3.6.1 - Authentication Screens
/// Reference: docs/Core_development_component_identification.md
///
/// Features:
/// - Email/password registration
/// - OAuth sign-up (Google, Facebook)
/// - Terms & conditions acceptance
/// - Email verification prompt after sign-up
/// - Form validation
/// - Error handling
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({
    super.key,
    this.onLoginTap,
    this.onTermsTap,
    this.onPrivacyTap,
  });

  /// Called when the user wants to navigate to the login screen.
  final VoidCallback? onLoginTap;

  /// Called when the user taps "Terms of Service".
  final VoidCallback? onTermsTap;

  /// Called when the user taps "Privacy Policy".
  final VoidCallback? onPrivacyTap;

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _termsAccepted = false;
  bool _termsError = false;
  bool _signUpComplete = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    setState(() => _termsError = !_termsAccepted);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_termsAccepted) return;

    await ref.read(authProvider.notifier).signUpWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          displayName: _nameController.text.trim(),
        );

    if (mounted) {
      final state = ref.read(authProvider);
      if (state.isAuthenticated || state.status == AuthStatus.authenticated) {
        setState(() => _signUpComplete = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

    if (_signUpComplete) {
      return _buildVerificationPrompt(context);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.child_care,
                size: 72,
                color: AppColors.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Create your account',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Join nonna to start tracking milestones',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 32),

              // Error banner
              if (authState.hasError && authState.errorMessage != null) ...[
                AuthErrorMessage(message: authState.errorMessage!),
                const SizedBox(height: 16),
              ],

              // Sign-up form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    AuthNameField(
                      controller: _nameController,
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 16),
                    AuthEmailField(
                      controller: _emailController,
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 16),
                    AuthPasswordField(
                      controller: _passwordController,
                      enabled: !isLoading,
                      labelText: 'Password',
                      hintText: 'Create a password',
                      fieldKey: const Key('signup_password_field'),
                    ),
                    const SizedBox(height: 16),
                    AuthPasswordField(
                      controller: _confirmPasswordController,
                      enabled: !isLoading,
                      labelText: 'Confirm Password',
                      hintText: 'Re-enter your password',
                      fieldKey: const Key('signup_confirm_password_field'),
                      validator: (v) =>
                          validatePasswordConfirm(v, _passwordController.text),
                      onSubmitted: (_) => _signUp(),
                    ),
                    const SizedBox(height: 16),

                    // Terms checkbox
                    _buildTermsCheckbox(context),
                    if (_termsError) ...[
                      const SizedBox(height: 4),
                      Text(
                        'You must accept the terms to continue',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.error,
                            ),
                      ),
                    ],
                    const SizedBox(height: 20),

                    AuthPrimaryButton(
                      label: 'Create Account',
                      onPressed: _signUp,
                      isLoading: isLoading,
                      buttonKey: const Key('sign_up_button'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const AuthDivider(),
              const SizedBox(height: 24),

              GoogleSignInButton(
                label: 'Sign up with Google',
                onPressed: isLoading
                    ? null
                    : () => ref.read(authProvider.notifier).signInWithGoogle(),
                isLoading: isLoading,
              ),
              const SizedBox(height: 12),
              FacebookSignInButton(
                label: 'Sign up with Facebook',
                onPressed: isLoading
                    ? null
                    : () =>
                        ref.read(authProvider.notifier).signInWithFacebook(),
                isLoading: isLoading,
              ),

              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextButton(
                    key: const Key('go_to_login_button'),
                    onPressed: widget.onLoginTap,
                    child: const Text('Sign In'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTermsCheckbox(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Checkbox(
          key: const Key('terms_checkbox'),
          value: _termsAccepted,
          onChanged: (v) => setState(() {
            _termsAccepted = v ?? false;
            if (_termsAccepted) _termsError = false;
          }),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodySmall,
              children: [
                const TextSpan(text: 'I agree to the '),
                TextSpan(
                  text: 'Terms of Service',
                  style: const TextStyle(
                    color: AppColors.primary,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = widget.onTermsTap,
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: const TextStyle(
                    color: AppColors.primary,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = widget.onPrivacyTap,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationPrompt(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.mark_email_read_outlined,
                  size: 80,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'Verify your email',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'We sent a verification link to ${_emailController.text.trim()}. '
                  'Please check your inbox and click the link to activate your account.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                AuthPrimaryButton(
                  label: 'Back to Sign In',
                  onPressed: widget.onLoginTap,
                  buttonKey: const Key('back_to_login_button'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
