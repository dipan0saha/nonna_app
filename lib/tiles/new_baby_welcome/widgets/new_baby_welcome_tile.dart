import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:nonna_app/core/constants/spacing.dart';
import 'package:nonna_app/core/enums/gender.dart';
import 'package:nonna_app/core/models/baby_profile.dart';
import 'package:nonna_app/core/themes/colors.dart';
import 'package:nonna_app/core/widgets/shimmer_placeholder.dart';
import 'package:nonna_app/core/extensions/context_extensions.dart';
import 'package:nonna_app/tiles/core/tile_icons.dart';
import 'package:nonna_app/tiles/core/widgets/tile_header.dart';

/// Tile shown on the owner Home screen for 7 days after a baby is born.
///
/// Displays:
/// - Baby's circular avatar photo (or gender-coloured placeholder)
/// - Baby name
/// - Gender chip
/// - Actual birth date  (formatted, e.g. "10 May 2026")
/// - Birth weight (kg)  if recorded
/// - Birth height (cm)  if recorded
/// - A warm congratulatory headline
class NewBabyWelcomeTile extends StatelessWidget {
  const NewBabyWelcomeTile({
    super.key,
    required this.babyProfile,
    this.isLoading = false,
    this.error,
    this.onRefresh,
  });

  final BabyProfile? babyProfile;
  final bool isLoading;
  final String? error;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const Key('new_baby_welcome_tile'),
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TileHeader(
              icon: TileIcons.newBabyWelcome,
              title: 'Welcome, Little One!',
              iconColor: AppColors.secondary,
            ),
            AppSpacing.verticalGapS,
            _buildBody(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (isLoading) {
      return _LoadingPlaceholder();
    }

    if (error != null) {
      return _ErrorView(message: error!, onRetry: onRefresh);
    }

    if (babyProfile == null) {
      return const SizedBox.shrink();
    }

    return _WelcomeContent(profile: babyProfile!);
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _WelcomeContent extends StatelessWidget {
  const _WelcomeContent({required this.profile});

  final BabyProfile profile;

  @override
  Widget build(BuildContext context) {
    final birthDate = profile.actualBirthDate;
    if (birthDate == null) return const SizedBox.shrink();
    final daysSince = DateTime.now().difference(birthDate).inDays;
    final formattedDate = DateFormat('dd MMM yyyy').format(birthDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Avatar + name row ---
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _BabyAvatar(profile: profile),
            AppSpacing.horizontalGapM,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name,
                    style: context.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppSpacing.verticalGapXS,
                  _GenderChip(gender: profile.gender),
                ],
              ),
            ),
          ],
        ),

        AppSpacing.verticalGapM,
        const Divider(height: 1),
        AppSpacing.verticalGapM,

        // --- Stats row ---
        _StatsRow(
          birthDate: formattedDate,
          weightKg: profile.birthWeightKg,
          heightCm: profile.birthHeightCm,
        ),

        AppSpacing.verticalGapM,

        // --- Day counter badge ---
        _DayCounterBadge(daysSince: daysSince),
      ],
    );
  }
}

class _BabyAvatar extends StatelessWidget {
  const _BabyAvatar({required this.profile});

  final BabyProfile profile;

  static const double _size = 80.0;

  @override
  Widget build(BuildContext context) {
    final photoUrl = profile.profilePhotoUrl;

    if (photoUrl != null && photoUrl.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: photoUrl,
          width: _size,
          height: _size,
          fit: BoxFit.cover,
          placeholder: (_, __) => _placeholder(context),
          errorWidget: (_, __, ___) => _placeholder(context),
        ),
      );
    }

    return _placeholder(context);
  }

  Widget _placeholder(BuildContext context) {
    return CircleAvatar(
      radius: _size / 2,
      backgroundColor: profile.gender.color.withValues(alpha: 0.2),
      child: Icon(
        Icons.child_friendly_outlined,
        size: 40,
        color: profile.gender.color,
      ),
    );
  }
}

class _GenderChip extends StatelessWidget {
  const _GenderChip({required this.gender});

  final Gender gender;

  @override
  Widget build(BuildContext context) {
    return Chip(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      avatar: Icon(gender.icon, size: 14, color: gender.color),
      label: Text(
        gender.displayName,
        style: context.textTheme.labelSmall,
      ),
      backgroundColor: gender.color.withValues(alpha: 0.12),
      side: BorderSide.none,
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.birthDate,
    required this.weightKg,
    required this.heightCm,
  });

  final String birthDate;
  final double? weightKg;
  final double? heightCm;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.m,
      runSpacing: AppSpacing.xs,
      children: [
        _StatChip(
          icon: Icons.calendar_today_outlined,
          label: birthDate,
        ),
        if (weightKg != null)
          _StatChip(
            icon: Icons.monitor_weight_outlined,
            label: '${weightKg!.toStringAsFixed(3)} kg',
          ),
        if (heightCm != null)
          _StatChip(
            icon: Icons.straighten_outlined,
            label: '${heightCm!.toStringAsFixed(1)} cm',
          ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 4),
        Text(label, style: context.textTheme.bodySmall),
      ],
    );
  }
}

class _DayCounterBadge extends StatelessWidget {
  const _DayCounterBadge({required this.daysSince});

  final int daysSince;

  @override
  Widget build(BuildContext context) {
    final label = daysSince == 0
        ? '🎉 Born today!'
        : '🎉 ${daysSince} ${daysSince == 1 ? "day" : "days"} old';

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s, vertical: AppSpacing.xs / 2),
      decoration: BoxDecoration(
        color: AppColors.secondaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: context.textTheme.labelMedium?.copyWith(
          color: AppColors.secondaryDark,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _LoadingPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const ShimmerPlaceholder(
                width: 80, height: 80, shape: BoxShape.circle),
            AppSpacing.horizontalGapM,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ShimmerPlaceholder(width: 120, height: 22),
                SizedBox(height: 8),
                ShimmerPlaceholder(width: 70, height: 18),
              ],
            ),
          ],
        ),
        AppSpacing.verticalGapM,
        const ShimmerPlaceholder(width: double.infinity, height: 14),
        AppSpacing.verticalGapXS,
        const ShimmerPlaceholder(width: 160, height: 14),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.error_outline, color: AppColors.error, size: 20),
        AppSpacing.horizontalGapS,
        Expanded(
          child: Text(message,
              style: context.textTheme.bodySmall
                  ?.copyWith(color: AppColors.error)),
        ),
        if (onRetry != null)
          TextButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    );
  }
}
