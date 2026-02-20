import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nonna_app/core/themes/colors.dart';
import 'package:nonna_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:nonna_app/features/auth/presentation/providers/auth_state.dart';
import 'package:nonna_app/features/auth/presentation/widgets/auth_form_widgets.dart';

/// Login screen
///
/// **Functional Requirements**: Section 3.6.1 - Authentication Screens
/// Reference: docs/Core_development_component_identification.md
///
/// Features:
/// - Email/password login
/// - OAuth login (Google, Facebook)
/// - "Forgot Password" flow
/// - Form validation
/// - Loading state
/// - Error messages
///
/// Navigation is handled through callbacks to keep this widget
/// easy to test without a full router setup.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({
    super.key,
    this.onSignUpTap,
    this.onForgotPasswordTap,
  });

  /// Called when the user wants to navigate to the sign-up screen.
  final VoidCallback? onSignUpTap;

  /// Called when the user wants to reset their password.
  final VoidCallback? onForgotPasswordTap;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _resetEmailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref.read(authProvider.notifier).signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  Future<void> _forgotPassword() async {
    if (widget.onForgotPasswordTap != null) {
      widget.onForgotPasswordTap!();
      return;
    }
    // Inline reset flow when no external callback is provided.
    final email = _emailController.text.trim();
    if (email.isEmpty || validateEmail(email) != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid email address to reset your password.'),
        ),
      );
      return;
    }
    try {
      await ref.read(authProvider.notifier).resetPassword(email);
      if (mounted) {
        setState(() => _resetEmailSent = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset email sent!')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send reset email.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo / title
              const Icon(
                Icons.child_care,
                size: 72,
                color: AppColors.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Welcome back',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to continue',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 32),

              // Error message
              if (authState.hasError && authState.errorMessage != null) ...[
                AuthErrorMessage(message: authState.errorMessage!),
                const SizedBox(height: 16),
              ],

              // Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    AuthEmailField(
                      controller: _emailController,
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 16),
                    AuthPasswordField(
                      controller: _passwordController,
                      enabled: !isLoading,
                      onSubmitted: (_) => _signIn(),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        key: const Key('forgot_password_button'),
                        onPressed: isLoading ? null : _forgotPassword,
                        child: const Text('Forgot Password?'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    AuthPrimaryButton(
                      label: 'Sign In',
                      onPressed: _signIn,
                      isLoading: isLoading,
                      buttonKey: const Key('sign_in_button'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const AuthDivider(),
              const SizedBox(height: 24),

              // OAuth buttons
              GoogleSignInButton(
                onPressed: isLoading
                    ? null
                    : () => ref.read(authProvider.notifier).signInWithGoogle(),
                isLoading: isLoading,
              ),
              const SizedBox(height: 12),
              FacebookSignInButton(
                onPressed: isLoading
                    ? null
                    : () =>
                        ref.read(authProvider.notifier).signInWithFacebook(),
                isLoading: isLoading,
              ),

              const SizedBox(height: 32),

              // Sign up link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextButton(
                    key: const Key('go_to_signup_button'),
                    onPressed: widget.onSignUpTap,
                    child: const Text('Sign Up'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
