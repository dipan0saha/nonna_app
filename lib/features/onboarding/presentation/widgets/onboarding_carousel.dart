import 'package:flutter/material.dart';

import 'package:nonna_app/core/themes/app_metrics.dart';
import 'package:nonna_app/core/themes/nonna_theme_extension.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingLogoMark extends StatelessWidget {
  const OnboardingLogoMark({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'La Nonna',
          style: GoogleFonts.baloo2(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: context.nonnaTheme.sageDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'PRIVATE. ORGANIZED. CONNECTED.',
          style: GoogleFonts.inter(
            fontSize: 11,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w600,
            color: context.nonnaTheme.muted,
          ),
        ),
      ],
    );
  }
}

class OnboardingCarousel extends StatefulWidget {
  const OnboardingCarousel({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.currentIndex,
    this.onPageChanged,
    this.controller,
    this.pageHeight = 360,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final int currentIndex;
  final ValueChanged<int>? onPageChanged;
  final PageController? controller;
  final double pageHeight;

  @override
  State<OnboardingCarousel> createState() => _OnboardingCarouselState();
}

class _OnboardingCarouselState extends State<OnboardingCarousel> {
  PageController? _internalController;

  PageController get _controller =>
      widget.controller ??
      (_internalController ??=
          PageController(initialPage: widget.currentIndex));

  @override
  void dispose() {
    _internalController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: widget.pageHeight,
          child: PageView.builder(
            itemCount: widget.itemCount,
            controller: _controller,
            onPageChanged: widget.onPageChanged,
            itemBuilder: widget.itemBuilder,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.itemCount, (index) {
            final isActive = index == widget.currentIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? AppMetrics.activeDotWidth : AppMetrics.dotSize,
              height: AppMetrics.dotSize,
              decoration: BoxDecoration(
                color: isActive
                    ? context.nonnaTheme.sageDark
                    : Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(
                  isActive
                      ? AppMetrics.activeDotRadius
                      : AppMetrics.dotSize / 2,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class OnboardingSegmentedControl extends StatelessWidget {
  const OnboardingSegmentedControl({
    super.key,
    required this.leftLabel,
    required this.rightLabel,
    required this.isLeftSelected,
    required this.onLeftTap,
    required this.onRightTap,
  });

  final String leftLabel;
  final String rightLabel;
  final bool isLeftSelected;
  final VoidCallback onLeftTap;
  final VoidCallback onRightTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(AppMetrics.fieldRadius),
      ),
      child: Row(
        children: [
          _Segment(
            label: leftLabel,
            selected: isLeftSelected,
            onTap: onLeftTap,
          ),
          _Segment(
            label: rightLabel,
            selected: !isLeftSelected,
            onTap: onRightTap,
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? context.nonnaTheme.sageTint : Colors.transparent,
            borderRadius: BorderRadius.circular(AppMetrics.fieldRadius),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              color: selected
                  ? context.nonnaTheme.sageDark
                  : context.nonnaTheme.muted,
            ),
          ),
        ),
      ),
    );
  }
}

class OnboardingPillSelect extends StatelessWidget {
  const OnboardingPillSelect({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> options;
  final int? selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(options.length, (index) {
        final selected = selectedIndex == index;
        return GestureDetector(
          onTap: () => onSelected(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: selected
                  ? context.nonnaTheme.sageTint
                  : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: selected
                    ? context.nonnaTheme.sageDark
                    : Theme.of(context).colorScheme.outline,
              ),
            ),
            child: Text(
              options[index],
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: selected
                    ? context.nonnaTheme.sageDark
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        );
      }),
    );
  }
}

class OnboardingChip extends StatelessWidget {
  const OnboardingChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected
                ? context.nonnaTheme.primaryButtonForeground
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class OnboardingMomentCard extends StatelessWidget {
  const OnboardingMomentCard({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            context.nonnaTheme.sageTint,
            Theme.of(context).colorScheme.surface,
          ],
          stops: const [0, 0.6],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.nonnaTheme.sageTint),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.baloo2(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: children),
        ],
      ),
    );
  }
}
