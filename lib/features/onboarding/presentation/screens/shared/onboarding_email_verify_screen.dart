import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:nonna_app/core/themes/onboarding_theme.dart';
import 'package:nonna_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_coordinator_provider.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_routes.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_types.dart';
import 'package:nonna_app/features/onboarding/presentation/widgets/onboarding_buttons.dart';
import 'package:nonna_app/features/onboarding/presentation/widgets/onboarding_fields.dart';
import 'package:nonna_app/features/onboarding/presentation/widgets/onboarding_scaffold.dart';

/// Email verification step — shown after email/password signup only.
class OnboardingEmailVerifyScreen extends ConsumerStatefulWidget {
  const OnboardingEmailVerifyScreen({super.key});

  @override
  ConsumerState<OnboardingEmailVerifyScreen> createState() =>
      _OnboardingEmailVerifyScreenState();
}

class _OnboardingEmailVerifyScreenState
    extends ConsumerState<OnboardingEmailVerifyScreen> {
  var _syncedStep = false;
  var _isResending = false;
  String? _resendMessage;
  Timer? _sessionPollTimer;

  @override
  void dispose() {
    _sessionPollTimer?.cancel();
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
          .syncStepForRoute(OnboardingRoutes.emailVerify);
      _maybeAdvanceIfAuthenticated();
      _startSessionPolling();
    });
  }

  void _startSessionPolling() {
    _sessionPollTimer?.cancel();
    _sessionPollTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (!mounted) return;
      if (ref.read(isAuthenticatedProvider)) {
        _maybeAdvanceIfAuthenticated();
        return;
      }
      await ref.read(authProvider.notifier).refreshSession();
      if (!mounted) return;
      if (ref.read(isAuthenticatedProvider)) {
        _maybeAdvanceIfAuthenticated();
      }
    });
  }

  Future<void> _maybeAdvanceIfAuthenticated() async {
    if (!ref.read(isAuthenticatedProvider) || !mounted) return;
    await ref
        .read(onboardingCoordinatorProvider.notifier)
        .goToStep(OnboardingStep.completeProfile);
    if (mounted) context.go(OnboardingRoutes.completeProfile);
  }

  Future<void> _handleBack() async {
    final route =
        await ref.read(onboardingCoordinatorProvider.notifier).goBack();
    if (!mounted) return;
    if (route != null) context.go(route);
  }

  Future<void> _handleContinue() async {
    if (ref.read(isAuthenticatedProvider)) {
      await _maybeAdvanceIfAuthenticated();
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please verify your email first, then tap Continue.'),
      ),
    );
  }

  Future<void> _handleResend() async {
    final email = ref.read(onboardingCoordinatorProvider).inviteeEmail;
    if (email == null || email.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No email on file. Go back and sign up again.')),
      );
      return;
    }
    if (_isResending) return;

    setState(() {
      _isResending = true;
      _resendMessage = null;
    });

    final success = await ref
        .read(authProvider.notifier)
        .resendSignupVerificationEmail(email);

    if (!mounted) return;
    setState(() {
      _isResending = false;
      _resendMessage = success
          ? 'Verification email sent.'
          : ref.read(authProvider).errorMessage ?? 'Could not resend email.';
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(isAuthenticatedProvider, (previous, next) {
      if (next) _maybeAdvanceIfAuthenticated();
    });

    final email =
        ref.watch(onboardingCoordinatorProvider).inviteeEmail ?? 'your email';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _handleBack();
      },
      child: OnboardingScaffold(
        showBack: true,
        onBack: _handleBack,
        bottom: OnboardingPrimaryButton(
          label: 'Continue',
          onPressed: _handleContinue,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 30),
            Center(
              child: Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  color: OnboardingColors.sageTint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mail_outline_rounded,
                  size: 38,
                  color: OnboardingColors.sageDark,
                ),
              ),
            ),
            const SizedBox(height: 22),
            const OnboardingHeadline(
              'Check your email',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: GoogleFonts.inter(
                  fontSize: OnboardingMetrics.supportTextSize,
                  color: OnboardingColors.muted,
                  height: 1.45,
                ),
                children: [
                  const TextSpan(
                    text: 'We sent a verification link to ',
                  ),
                  TextSpan(
                    text: email,
                    style: const TextStyle(
                      color: OnboardingColors.text,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const TextSpan(
                    text:
                        '. Click it to activate your account. Google and Facebook sign-ups skip this step.',
                  ),
                ],
              ),
            ),
            if (_resendMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                _resendMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: _resendMessage == 'Verification email sent.'
                      ? OnboardingColors.sageDark
                      : Colors.red,
                ),
              ),
            ],
            const SizedBox(height: 28),
            OnboardingBottomLink(
              prefix: '',
              actionLabel: _isResending ? 'Sending…' : 'Resend email',
              actionKey: const Key('onboarding_email_verify_resend'),
              onTap: _isResending ? () {} : _handleResend,
            ),
          ],
        ),
      ),
    );
  }
}
