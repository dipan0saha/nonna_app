import 'package:flutter/material.dart';

import 'package:nonna_app/core/constants/spacing.dart';
import 'package:nonna_app/core/themes/colors.dart';

/// A widget that displays an animated squish (❤️-style) button with a count.
///
/// Shows a bounce animation when tapped, a filled heart when [isSquished],
/// and an outline heart when not squished.
class SquishPhotoWidget extends StatefulWidget {
  const SquishPhotoWidget({
    super.key,
    required this.squishCount,
    required this.isSquished,
    this.onSquish,
  });

  /// Number of squishes this photo has received
  final int squishCount;

  /// Whether the current user has squished this photo
  final bool isSquished;

  /// Called when the squish button is tapped
  final VoidCallback? onSquish;

  @override
  State<SquishPhotoWidget> createState() => _SquishPhotoWidgetState();
}

class _SquishPhotoWidgetState extends State<SquishPhotoWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward(from: 0);
    widget.onSquish?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          key: const Key('squish_button'),
          onTap: _handleTap,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Icon(
              widget.isSquished ? Icons.favorite : Icons.favorite_border,
              color: AppColors.secondary,
              size: 32,
            ),
          ),
        ),
        AppSpacing.horizontalGapXS,
        Text(
          '${widget.squishCount} ${widget.squishCount == 1 ? 'squish' : 'squishes'}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
