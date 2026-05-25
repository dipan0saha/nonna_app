import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nonna_app/flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nonna_app/core/constants/spacing.dart';
import 'package:nonna_app/core/themes/colors.dart';
import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/core/enums/vote_type.dart';
import 'package:nonna_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:nonna_app/tiles/prediction_votes/providers/prediction_votes_provider.dart';
import 'package:nonna_app/tiles/core/tile_icons.dart';
import 'package:nonna_app/tiles/core/widgets/tile_header.dart';

class PredictionVotesSmartTile extends ConsumerStatefulWidget {
  const PredictionVotesSmartTile({super.key, this.babyProfileId});

  final String? babyProfileId;

  @override
  ConsumerState<PredictionVotesSmartTile> createState() =>
      _PredictionVotesSmartTileState();
}

class _PredictionVotesSmartTileState
    extends ConsumerState<PredictionVotesSmartTile> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  String get _babyProfileId =>
      widget.babyProfileId ?? ref.read(selectedBabyProfileProvider) ?? '';

  String get _userId => ref.read(authProvider).user?.id ?? '';

  void _loadData() {
    final id = _babyProfileId;
    if (id.isNotEmpty) {
      ref.read(predictionVotesProvider.notifier).load(babyProfileId: id);
    }
  }

  Future<void> _voteGender(String gender) async {
    final id = _babyProfileId;
    final userId = _userId;
    if (id.isEmpty || userId.isEmpty) return;

    await ref.read(predictionVotesProvider.notifier).voteGender(
          babyProfileId: id,
          userId: userId,
          genderValue: gender,
        );
  }

  Future<void> _voteBirthdate() async {
    final id = _babyProfileId;
    final userId = _userId;
    if (id.isEmpty || userId.isEmpty) return;

    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      helpText: AppLocalizations.of(context).tile_predictions_help_text,
    );

    if (picked != null && mounted) {
      await ref.read(predictionVotesProvider.notifier).voteBirthdate(
            babyProfileId: id,
            userId: userId,
            date: picked,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String?>(selectedBabyProfileProvider, (previous, next) {
      if (next != previous && next != null) {
        _loadData();
      }
    });

    final state = ref.watch(predictionVotesProvider);
    final userId = _userId;
    final theme = Theme.of(context);

    return Card(
      key: const Key('prediction_votes_tile'),
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ──
            TileHeader(
              icon: TileIcons.predictionVotes,
              title: AppLocalizations.of(context).tile_predictions_title,
              titleStyle: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.verticalGapM,

            // ── Loading ──
            if (state.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.error != null)
              Center(
                child: Text(
                  state.error!,
                  style: const TextStyle(color: Colors.red),
                ),
              )
            else ...[
              // ── Gender Vote Section ──
              _GenderVoteSection(
                votes: state.votes,
                userVote: state.userGenderVote(userId),
                isSubmitting: state.isSubmitting,
                onVote: userId.isNotEmpty ? _voteGender : null,
              ),

              const Divider(height: 24),

              // ── Birthdate Vote Section ──
              _BirthdateVoteSection(
                votes: state.votes,
                userVote: state.userBirthdateVote(userId),
                isSubmitting: state.isSubmitting,
                onVote: userId.isNotEmpty ? _voteBirthdate : null,
              ),

              // ── Vote Summary ──
              if (state.votes.isNotEmpty) ...[
                const Divider(height: 24),
                _VoteSummary(votes: state.votes),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Gender Vote Section
// ─────────────────────────────────────────────────────────────────────────────

class _GenderVoteSection extends StatelessWidget {
  const _GenderVoteSection({
    required this.votes,
    required this.userVote,
    required this.isSubmitting,
    required this.onVote,
  });

  final List votes;
  final dynamic userVote;
  final bool isSubmitting;
  final ValueChanged<String>? onVote;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final currentValue = userVote?.valueText;
    final translatedGenderValue = currentValue == 'Boy'
        ? l10n.tile_predictions_gender_boy
        : currentValue == 'Girl'
            ? l10n.tile_predictions_gender_girl
            : currentValue;

    // Count gender votes
    final genderVotes =
        votes.where((v) => v.voteType == VoteType.gender).toList();
    final boyCount = genderVotes.where((v) => v.valueText == 'Boy').length;
    final girlCount = genderVotes.where((v) => v.valueText == 'Girl').length;
    // Use only the sum of displayed categories as the denominator so that
    // Boy% + Girl% always equals exactly 100%.
    final totalGenderVotes = boyCount + girlCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.face, size: 20, color: AppColors.secondary),
            const SizedBox(width: 8),
            Text(
              l10n.tile_predictions_gender_title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (currentValue != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              l10n.tile_predictions_gender_your_vote(
                  translatedGenderValue ?? ''),
              style: TextStyle(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        Row(
          children: [
            Expanded(
              child: _GenderButton(
                label: l10n.tile_predictions_gender_boy,
                icon: Icons.male,
                color: Colors.blue,
                isSelected: currentValue == 'Boy',
                voteCount: boyCount,
                totalVotes: totalGenderVotes,
                isSubmitting: isSubmitting,
                onTap: onVote != null ? () => onVote!('Boy') : null,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _GenderButton(
                label: l10n.tile_predictions_gender_girl,
                icon: Icons.female,
                color: Colors.pink,
                isSelected: currentValue == 'Girl',
                voteCount: girlCount,
                totalVotes: totalGenderVotes,
                isSubmitting: isSubmitting,
                onTap: onVote != null ? () => onVote!('Girl') : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _GenderButton extends StatelessWidget {
  const _GenderButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.voteCount,
    required this.totalVotes,
    required this.isSubmitting,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final int voteCount;
  final int totalVotes;
  final bool isSubmitting;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final percentage =
        totalVotes > 0 ? (voteCount / totalVotes * 100).round() : 0;

    return Material(
      color: isSelected ? color.withValues(alpha: 0.12) : AppColors.gray50,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: isSubmitting ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : AppColors.gray200,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isSelected ? color : AppColors.gray700,
                ),
              ),
              if (totalVotes > 0) ...[
                const SizedBox(height: 4),
                Text(
                  '$percentage% ($voteCount)',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.gray500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Birthdate Vote Section
// ─────────────────────────────────────────────────────────────────────────────

class _BirthdateVoteSection extends StatelessWidget {
  const _BirthdateVoteSection({
    required this.votes,
    required this.userVote,
    required this.isSubmitting,
    required this.onVote,
  });

  final List votes;
  final dynamic userVote;
  final bool isSubmitting;
  final VoidCallback? onVote;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final currentDate = userVote?.valueDate;
    final locale = Localizations.localeOf(context).toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.calendar_today,
                size: 20, color: AppColors.secondary),
            const SizedBox(width: 8),
            Text(
              l10n.tile_predictions_birthdate_title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (currentDate != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              l10n.tile_predictions_birthdate_your_vote(
                DateFormat.yMMMd(locale).format(currentDate),
              ),
              style: TextStyle(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            key: const Key('vote_birthdate_button'),
            onPressed: isSubmitting ? null : onVote,
            icon: isSubmitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.event),
            label: Text(
              currentDate != null
                  ? l10n.tile_predictions_birthdate_change
                  : l10n.tile_predictions_birthdate_pick,
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              foregroundColor: AppColors.primaryDark,
              side: const BorderSide(color: AppColors.primaryDark),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Vote Summary
// ─────────────────────────────────────────────────────────────────────────────

class _VoteSummary extends StatelessWidget {
  const _VoteSummary({required this.votes});

  final List votes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    // Aggregate votes by type
    final genderVotes =
        votes.where((v) => v.voteType == VoteType.gender).length;
    final birthdateVotes =
        votes.where((v) => v.voteType == VoteType.birthdate).length;

    return Row(
      children: [
        Icon(Icons.bar_chart, size: 18, color: AppColors.gray500),
        const SizedBox(width: 6),
        Text(
          l10n.tile_predictions_summary(genderVotes, birthdateVotes),
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.gray500,
          ),
        ),
      ],
    );
  }
}
