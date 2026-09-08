import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/core/themes/onboarding_theme.dart';
import 'package:nonna_app/core/widgets/offline_indicator.dart';

/// Shared scaffold for onboarding screens — prototype padding, offline banner,
/// keyboard-safe scroll body, and tap-outside dismiss.
class OnboardingScaffold extends ConsumerWidget {
  const OnboardingScaffold({
    super.key,
    required this.body,
    this.showBack = false,
    this.showSkip = false,
    this.onBack,
    this.onSkip,
    this.skipLabel = 'Skip',
    this.bottom,
    this.resizeToAvoidBottomInset = true,
  });

  final Widget body;
  final bool showBack;
  final bool showSkip;
  final VoidCallback? onBack;
  final VoidCallback? onSkip;
  final String skipLabel;
  final Widget? bottom;
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);

    return Scaffold(
      backgroundColor: OnboardingColors.surface,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OfflineIndicator(isOffline: !isOnline),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: OnboardingMetrics.horizontalPadding,
              ),
              child: _TopRow(
                showBack: showBack,
                showSkip: showSkip,
                onBack: onBack,
                onSkip: onSkip,
                skipLabel: skipLabel,
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                behavior: HitTestBehavior.translucent,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: OnboardingMetrics.horizontalPadding,
                  ),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: body,
                ),
              ),
            ),
            if (bottom != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  OnboardingMetrics.horizontalPadding,
                  0,
                  OnboardingMetrics.horizontalPadding,
                  16,
                ),
                child: bottom!,
              ),
          ],
        ),
      ),
    );
  }
}

class _TopRow extends StatelessWidget {
  const _TopRow({
    required this.showBack,
    required this.showSkip,
    this.onBack,
    this.onSkip,
    required this.skipLabel,
  });

  final bool showBack;
  final bool showSkip;
  final VoidCallback? onBack;
  final VoidCallback? onSkip;
  final String skipLabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          if (showBack)
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              color: OnboardingColors.text,
              tooltip: 'Back',
            )
          else
            const SizedBox(width: 8),
          const Spacer(),
          if (showSkip)
            TextButton(
              onPressed: onSkip,
              child: Text(
                skipLabel,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: OnboardingColors.sageDark,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Wraps onboarding routes in the isolated prototype theme.
class OnboardingThemeScope extends StatelessWidget {
  const OnboardingThemeScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: OnboardingTheme.themeData,
      child: child,
    );
  }
}
