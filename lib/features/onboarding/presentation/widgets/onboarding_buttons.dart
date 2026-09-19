import 'package:flutter/material.dart';

import 'package:nonna_app/core/themes/app_metrics.dart';

/// Minimum touch target per a11y (#52).
const double _kMinTouchTarget = 44;

class OnboardingPrimaryButton extends StatelessWidget {
  const OnboardingPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.semanticsLabel,
    this.buttonKey,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final String? semanticsLabel;
  final Key? buttonKey;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticsLabel ?? label,
      enabled: !isLoading && onPressed != null,
      child: SizedBox(
        width: double.infinity,
        height: _kMinTouchTarget,
        child: ElevatedButton(
          key: buttonKey,
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              vertical: AppMetrics.buttonVerticalPadding,
            ),
            minimumSize: const Size.fromHeight(_kMinTouchTarget),
          ),
          child: isLoading
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                )
              : Text(label),
        ),
      ),
    );
  }
}

class OnboardingOutlineButton extends StatelessWidget {
  const OnboardingOutlineButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.leading,
    this.isLoading = false,
    this.semanticsLabel,
    this.buttonKey,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;
  final bool isLoading;
  final String? semanticsLabel;
  final Key? buttonKey;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticsLabel ?? label,
      enabled: !isLoading && onPressed != null,
      child: SizedBox(
        width: double.infinity,
        height: _kMinTouchTarget,
        child: OutlinedButton(
          key: buttonKey,
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              vertical: AppMetrics.buttonVerticalPadding,
            ),
            minimumSize: const Size.fromHeight(_kMinTouchTarget),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (leading != null) ...[
                      leading!,
                      const SizedBox(width: 10),
                    ],
                    Text(label),
                  ],
                ),
        ),
      ),
    );
  }
}

class OnboardingGoogleButton extends StatelessWidget {
  const OnboardingGoogleButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return OnboardingOutlineButton(
      label: 'Continue with Google',
      onPressed: onPressed,
      isLoading: isLoading,
      leading: const Text('G',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF4285F4),
          )),
    );
  }
}

class OnboardingFacebookButton extends StatelessWidget {
  const OnboardingFacebookButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return OnboardingOutlineButton(
      label: 'Continue with Facebook',
      onPressed: onPressed,
      isLoading: isLoading,
      leading: const Text('f',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1877F2),
          )),
    );
  }
}
