import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nonna_app/core/constants/spacing.dart';
import 'package:nonna_app/core/widgets/empty_state.dart';
import 'package:nonna_app/features/gamification/presentation/providers/gamification_provider.dart';

/// Screen displaying gamification features: name suggestions and prediction votes.
///
/// **Functional Requirements**: Section 3.6.4 - Additional Feature Screens
class GamificationScreen extends ConsumerStatefulWidget {
  const GamificationScreen({
    super.key,
    required this.babyProfileId,
  });

  final String babyProfileId;

  @override
  ConsumerState<GamificationScreen> createState() => _GamificationScreenState();
}

class _GamificationScreenState extends ConsumerState<GamificationScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(gamificationProvider.notifier)
          .load(babyProfileId: widget.babyProfileId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await ref
        .read(gamificationProvider.notifier)
        .load(babyProfileId: widget.babyProfileId);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gamificationProvider);

    return Scaffold(
      key: const Key('gamification_screen'),
      appBar: AppBar(
        title: const Text('Fun & Games'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(key: Key('name_suggestions_tab'), text: 'Name Suggestions'),
            Tab(key: Key('votes_tab'), text: 'Votes'),
          ],
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(
                  child: Padding(
                    padding: AppSpacing.screenPadding,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          state.error!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        AppSpacing.verticalGapM,
                        ElevatedButton(
                          onPressed: _onRefresh,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _NameSuggestionsTab(
                          suggestions: state.nameSuggestions),
                      _VotesTab(votes: state.votes),
                    ],
                  ),
                ),
    );
  }
}

class _NameSuggestionsTab extends StatelessWidget {
  const _NameSuggestionsTab({required this.suggestions});

  final List suggestions;

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) {
      return const EmptyState(
        key: Key('no_name_suggestions_empty_state'),
        icon: Icons.child_care,
        message: 'No name suggestions yet',
      );
    }
    return ListView.builder(
      padding: AppSpacing.screenPadding,
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          key: Key('name_suggestion_$index'),
          leading: const Icon(Icons.child_care),
          title: Text(suggestions[index].suggestedName as String),
        );
      },
    );
  }
}

class _VotesTab extends StatelessWidget {
  const _VotesTab({required this.votes});

  final List votes;

  @override
  Widget build(BuildContext context) {
    if (votes.isEmpty) {
      return const EmptyState(
        key: Key('no_votes_empty_state'),
        icon: Icons.how_to_vote_outlined,
        message: 'No votes yet',
      );
    }
    return ListView.builder(
      padding: AppSpacing.screenPadding,
      itemCount: votes.length,
      itemBuilder: (context, index) {
        return ListTile(
          key: Key('vote_$index'),
          leading: const Icon(Icons.how_to_vote_outlined),
          title: Text(votes[index].voteType.toString()),
        );
      },
    );
  }
}
