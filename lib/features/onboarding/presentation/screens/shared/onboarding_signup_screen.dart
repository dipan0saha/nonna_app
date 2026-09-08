import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:nonna_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:nonna_app/features/auth/presentation/widgets/auth_form_widgets.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_coordinator_provider.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_routes.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_types.dart';
import 'package:nonna_app/core/constants/onboarding_integration_keys.dart';
import 'package:nonna_app/features/onboarding/presentation/utils/onboarding_analytics.dart';
import 'package:nonna_app/features/onboarding/presentation/utils/onboarding_auth_helpers.dart';
import 'package:nonna_app/features/onboarding/presentation/widgets/onboarding_buttons.dart';
import 'package:nonna_app/features/onboarding/presentation/widgets/onboarding_carousel.dart';
import 'package:nonna_app/features/onboarding/presentation/widgets/onboarding_fields.dart';
import 'package:nonna_app/features/onboarding/presentation/widgets/onboarding_scaffold.dart';

/// Branded onboarding signup — OAuth + email (no name field, no terms checkbox).
class OnboardingSignupScreen extends ConsumerStatefulWidget {
  const OnboardingSignupScreen({super.key, required this.path});

  final OnboardingPath path;

  @override
  ConsumerState<OnboardingSignupScreen> createState() =>
      _OnboardingSignupScreenState();
}

class _OnboardingSignupScreenState
    extends ConsumerState<OnboardingSignupScreen> {
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final coordinator = ref.read(onboardingCoordinatorProvider.notifier);
      await coordinator.setPath(widget.path);
      await coordinator.syncStepForRoute(OnboardingRoutes.signup);
      final inviteeEmail = ref.read(onboardingCoordinatorProvider).inviteeEmail;
      if (inviteeEmail != null && _emailController.text.isEmpty) {
        _emailController.text = inviteeEmail;
      }
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
    if (route != null) {
      context.go(route);
    } else {
      context.go(onboardingSignupBackRoute(widget.path));
    }
  }

  Future<void> _goToLogin() async {
    await ref
        .read(onboardingCoordinatorProvider.notifier)
        .goToStep(OnboardingStep.login);
    if (mounted) context.go(OnboardingRoutes.login);
  }

  Future<void> _signUpWithEmail() async {
    if (_isSubmitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);
    final email = _emailController.text.trim();
    await ref
        .read(onboardingCoordinatorProvider.notifier)
        .setInviteeEmail(email);

    final success = await ref.read(authProvider.notifier).signUpWithEmail(
          email: email,
          password: _passwordController.text,
          displayName: onboardingEmailDisplayNamePlaceholder(email),
        );

    if (mounted) setState(() => _isSubmitting = false);
    if (!mounted || !success) return;

    await ref.read(onboardingAnalyticsProvider).trackSignUp(method: 'email');

    await navigateAfterOnboardingAuth(
      ref: ref,
      context: context,
      usedOAuth: false,
      isSignUp: true,
    );
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
        isSignUp: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final inviteeEmail = ref.watch(onboardingCoordinatorProvider).inviteeEmail;
    final lockEmail =
        widget.path != OnboardingPath.owner && inviteeEmail != null;

    return OnboardingScaffold(
      showBack: true,
      onBack: _handleBack,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 6),
          const OnboardingLogoMark(),
          const SizedBox(height: 26),
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
          const OnboardingDivider(),
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
                  readOnly: lockEmail,
                  fieldKey: const Key('onboarding_signup_email'),
                ),
                const SizedBox(height: 16),
                OnboardingPasswordField(
                  controller: _passwordController,
                  validator: validatePassword,
                  onFieldSubmitted: (_) => _signUpWithEmail(),
                  fieldKey: const Key('onboarding_signup_password'),
                ),
                const SizedBox(height: 8),
                const OnboardingHelperText('At least 8 characters.'),
                const SizedBox(height: 18),
                OnboardingPrimaryButton(
                  buttonKey: OnboardingIntegrationKeys.signupPrimary,
                  label: 'Create Account',
                  isLoading: _isLoading,
                  onPressed: _signUpWithEmail,
                ),
              ],
            ),
          ),
          OnboardingBottomLink(
            prefix: 'Already have an account? ',
            actionLabel: 'Log in',
            actionKey: const Key('onboarding_signup_login_link'),
            onTap: _goToLogin,
          ),
        ],
      ),
    );
  }
}
