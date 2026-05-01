import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nonna_app/core/constants/spacing.dart';
import 'package:nonna_app/core/themes/colors.dart';
import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/core/widgets/empty_state.dart';
import 'package:nonna_app/tiles/name_suggestions/providers/name_suggestions_provider.dart';

class NameSuggestionsSmartTile extends ConsumerStatefulWidget {
  const NameSuggestionsSmartTile({super.key, this.babyProfileId});

  final String? babyProfileId;

  @override
  ConsumerState<NameSuggestionsSmartTile> createState() =>
      _NameSuggestionsSmartTileState();
}

class _NameSuggestionsSmartTileState
    extends ConsumerState<NameSuggestionsSmartTile> {
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
      ref.read(nameSuggestionsProvider.notifier).load(babyProfileId: id);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String?>(selectedBabyProfileProvider, (previous, next) {
      if (next != previous && next != null) {
        _loadData();
      }
    });

    final state = ref.watch(nameSuggestionsProvider);

    return Card(
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name Suggestions',
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
            else if (state.suggestions.isEmpty)
              const EmptyState(
                icon: Icons.child_care,
                message: 'No name suggestions yet',
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.suggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = state.suggestions[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      suggestion.gender.icon,
                      color: suggestion.gender.color,
                    ),
                    title: Text(
                      suggestion.suggestedName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text('Gender: ${suggestion.gender.displayName}'),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
