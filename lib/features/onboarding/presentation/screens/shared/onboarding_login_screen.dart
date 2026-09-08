import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:nonna_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:nonna_app/features/auth/presentation/widgets/auth_form_widgets.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_coordinator_provider.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_routes.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_types.dart';
import 'package:nonna_app/features/onboarding/presentation/utils/onboarding_auth_helpers.dart';
import 'package:nonna_app/features/onboarding/presentation/widgets/onboarding_buttons.dart';
import 'package:nonna_app/features/onboarding/presentation/widgets/onboarding_carousel.dart';
import 'package:nonna_app/features/onboarding/presentation/widgets/onboarding_fields.dart';
import 'package:nonna_app/features/onboarding/presentation/widgets/onboarding_scaffold.dart';

/// Branded onboarding login — mid-invite safe (#26, #27).
class OnboardingLoginScreen extends ConsumerStatefulWidget {
  const OnboardingLoginScreen({super.key});

  @override
  ConsumerState<OnboardingLoginScreen> createState() =>
      _OnboardingLoginScreenState();
}

class _OnboardingLoginScreenState extends ConsumerState<OnboardingLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  var _isSubmitting = false;
  var _syncedStep = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_syncedStep) return;
    _syncedStep = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(onboardingCoordinatorProvider.notifier)
          .syncStepForRoute(OnboardingRoutes.login);
    });
  }

  bool get _isLoading {
    final auth = ref.watch(authProvider);
    return auth.isLoading || _isSubmitting;
  }

  Future<void> _handleBack() async {
    final route =
        await ref.read(onboardingCoordinatorProvider.notifier).goBack();
    if (!mounted) return;
    if (route == OnboardingRoutes.signup) {
      final path = ref.read(onboardingCoordinatorProvider).path;
      context.go(OnboardingRoutes.signupPathFor(path));
      return;
    }
    context.go(route ??
        OnboardingRoutes.signupPathFor(
          ref.read(onboardingCoordinatorProvider).path,
        ));
  }

  Future<void> _goToSignup() async {
    final path = ref.read(onboardingCoordinatorProvider).path;
    await ref
        .read(onboardingCoordinatorProvider.notifier)
        .goToStep(OnboardingStep.signup);
    if (mounted) context.go(OnboardingRoutes.signupPathFor(path));
  }

  Future<void> _signInWithEmail() async {
    if (_isSubmitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);
    await ref.read(authProvider.notifier).signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
    if (mounted) setState(() => _isSubmitting = false);
    if (!mounted) return;

    final auth = ref.read(authProvider);
    if (auth.isAuthenticated) {
      await navigateAfterOnboardingAuth(
        ref: ref,
        context: context,
        usedOAuth: false,
        isSignUp: false,
      );
    }
  }

  Future<void> _signInWithOAuth(Future<void> Function() signIn) async {
    if (_isLoading) return;
    await signIn();
    if (!mounted) return;
    final auth = ref.read(authProvider);
    if (auth.isAuthenticated) {
      await ref.read(onboardingCoordinatorProvider.notifier).setUsedOAuth(true);
      await navigateAfterOnboardingAuth(
        ref: ref,
        context: context,
        usedOAuth: true,
        isSignUp: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final hasPendingInvite =
        ref.watch(onboardingCoordinatorProvider).pendingInviteToken != null;

    return OnboardingScaffold(
      showBack: true,
      onBack: _handleBack,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 6),
          const OnboardingLogoMark(),
          const SizedBox(height: 20),
          const OnboardingHeadline('Welcome back'),
          const SizedBox(height: 8),
          OnboardingSupportText(
            hasPendingInvite
                ? 'Sign in to accept your invitation and continue.'
                : 'Sign in to continue setting up your family space.',
          ),
          const SizedBox(height: 24),
          OnboardingGoogleButton(
            onPressed: _isLoading
                ? null
                : () => _signInWithOAuth(
                      ref.read(authProvider.notifier).signInWithGoogle,
                    ),
            isLoading: _isLoading,
          ),
          const SizedBox(height: 10),
          OnboardingFacebookButton(
            onPressed: _isLoading
                ? null
                : () => _signInWithOAuth(
                      ref.read(authProvider.notifier).signInWithFacebook,
                    ),
            isLoading: _isLoading,
          ),
          const OnboardingDivider(label: 'or sign in with email'),
          if (auth.hasError && auth.errorMessage != null) ...[
            Text(
              auth.errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
            const SizedBox(height: 12),
          ],
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OnboardingTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'you@email.com',
                  keyboardType: TextInputType.emailAddress,
                  validator: validateEmail,
                  fieldKey: const Key('onboarding_login_email'),
                ),
                const SizedBox(height: 16),
                OnboardingPasswordField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'Enter your password',
                  validator: validatePassword,
                  onFieldSubmitted: (_) => _signInWithEmail(),
                  fieldKey: const Key('onboarding_login_password'),
                ),
                const SizedBox(height: 18),
                OnboardingPrimaryButton(
                  label: 'Sign In',
                  isLoading: _isLoading,
                  onPressed: _signInWithEmail,
                ),
              ],
            ),
          ),
          OnboardingBottomLink(
            prefix: "Don't have an account? ",
            actionLabel: 'Sign up',
            actionKey: const Key('onboarding_login_signup_link'),
            onTap: _goToSignup,
          ),
        ],
      ),
    );
  }
}
