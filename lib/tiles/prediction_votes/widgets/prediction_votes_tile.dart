import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nonna_app/core/constants/spacing.dart';
import 'package:nonna_app/core/themes/colors.dart';
import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/core/widgets/empty_state.dart';
import 'package:nonna_app/core/enums/vote_type.dart';
import 'package:nonna_app/tiles/prediction_votes/providers/prediction_votes_provider.dart';

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

  void _loadData() {
    final id =
        widget.babyProfileId ?? ref.read(selectedBabyProfileProvider) ?? '';
    if (id.isNotEmpty) {
      ref.read(predictionVotesProvider.notifier).load(babyProfileId: id);
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

    return Card(
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Prediction Votes',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            AppSpacing.verticalGapM,
            if (state.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (state.error != null)
              Center(
                  child: Text(state.error!,
                      style: const TextStyle(color: Colors.red)))
            else if (state.votes.isEmpty)
              const EmptyState(
                icon: Icons.how_to_vote_outlined,
                message: 'No votes yet',
              )
            else
              Builder(
                builder: (context) {
                  // Aggregate votes
                  final Map<String, int> counts = {};
                  final Map<String, VoteType> types = {};
                  final Map<String, String> values = {};

                  for (final vote in state.votes) {
                    final bool isBirthdate =
                        vote.voteType == VoteType.birthdate;
                    final String displayValue = isBirthdate
                        ? (vote.valueDate != null
                            ? DateFormat.yMMMd().format(vote.valueDate!)
                            : 'Unknown Date')
                        : (vote.valueText ?? 'Unknown Value');

                    final key = '${vote.voteType.displayName}|$displayValue';
                    counts[key] = (counts[key] ?? 0) + 1;
                    types[key] = vote.voteType;
                    values[key] = displayValue;
                  }

                  // Sort by most votes
                  final sortedKeys = counts.keys.toList()
                    ..sort((a, b) => counts[b]!.compareTo(counts[a]!));

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: sortedKeys.length,
                    itemBuilder: (context, index) {
                      final key = sortedKeys[index];
                      final count = counts[key]!;
                      final voteType = types[key]!;
                      final displayValue = values[key]!;
                      final bool isBirthdate = voteType == VoteType.birthdate;

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          isBirthdate ? Icons.calendar_today : Icons.face,
                          color: AppColors.secondary,
                        ),
                        title: Text(
                          '${voteType.displayName}: $displayValue',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text('$count vote${count == 1 ? '' : 's'}'),
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
