import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nonna_app/core/constants/spacing.dart';
import 'package:nonna_app/core/themes/colors.dart';
import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/core/enums/gender.dart';
import 'package:nonna_app/core/widgets/empty_state.dart';
import 'package:nonna_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:nonna_app/tiles/name_suggestions/providers/name_suggestions_provider.dart';
import 'package:nonna_app/tiles/core/tile_icons.dart';
import 'package:nonna_app/tiles/core/widgets/tile_header.dart';

class NameSuggestionsSmartTile extends ConsumerStatefulWidget {
  const NameSuggestionsSmartTile({super.key, this.babyProfileId});

  final String? babyProfileId;

  @override
  ConsumerState<NameSuggestionsSmartTile> createState() =>
      _NameSuggestionsSmartTileState();
}

class _NameSuggestionsSmartTileState
    extends ConsumerState<NameSuggestionsSmartTile> {
  final _nameController = TextEditingController();
  Gender _selectedGender = Gender.unknown;
  bool _showForm = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String get _babyProfileId =>
      widget.babyProfileId ?? ref.read(selectedBabyProfileProvider) ?? '';

  String get _userId => ref.read(authProvider).user?.id ?? '';

  void _loadData() {
    final id = _babyProfileId;
    if (id.isNotEmpty) {
      ref.read(nameSuggestionsProvider.notifier).load(babyProfileId: id);
    }
  }

  Future<void> _submitName() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final id = _babyProfileId;
    final userId = _userId;
    if (id.isEmpty || userId.isEmpty) return;

    final success =
        await ref.read(nameSuggestionsProvider.notifier).addSuggestion(
              babyProfileId: id,
              userId: userId,
              name: name,
              gender: _selectedGender,
            );

    if (success && mounted) {
      _nameController.clear();
      setState(() {
        _showForm = false;
        _selectedGender = Gender.unknown;
      });
    }
  }

  Future<void> _toggleLike(String suggestionId) async {
    final userId = _userId;
    if (userId.isEmpty) return;

    await ref.read(nameSuggestionsProvider.notifier).likeSuggestion(
          suggestionId: suggestionId,
          userId: userId,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String?>(selectedBabyProfileProvider, (previous, next) {
      if (next != previous && next != null) {
        _loadData();
      }
    });

    final state = ref.watch(nameSuggestionsProvider);
    final userId = _userId;
    final theme = Theme.of(context);

    return Card(
      key: const Key('name_suggestions_tile'),
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ──
            TileHeader(
              icon: TileIcons.nameSuggestions,
              title: 'Name Suggestions',
              titleStyle: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              actions: [
                IconButton(
                  key: const Key('add_name_suggestion_button'),
                  icon: Icon(
                    _showForm ? Icons.close : Icons.add_circle_outline,
                    color: AppColors.primaryDark,
                  ),
                  onPressed: () => setState(() => _showForm = !_showForm),
                ),
              ],
            ),

            // ── Add Name Form ──
            if (_showForm) ...[
              AppSpacing.verticalGapS,
              _AddNameForm(
                controller: _nameController,
                selectedGender: _selectedGender,
                isSubmitting: state.isSubmitting,
                onGenderChanged: (g) => setState(() => _selectedGender = g),
                onSubmit: _submitName,
              ),
              AppSpacing.verticalGapM,
            ],

            // ── Content ──
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
            else if (state.suggestions.isEmpty)
              const EmptyState(
                icon: Icons.child_care,
                message: 'No name suggestions yet.\nTap + to suggest one!',
              )
            else
              _SuggestionsList(
                state: state,
                userId: userId,
                onLike: _toggleLike,
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Add Name Form
// ─────────────────────────────────────────────────────────────────────────────

class _AddNameForm extends StatelessWidget {
  const _AddNameForm({
    required this.controller,
    required this.selectedGender,
    required this.isSubmitting,
    required this.onGenderChanged,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final Gender selectedGender;
  final bool isSubmitting;
  final ValueChanged<Gender> onGenderChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryPale,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            key: const Key('name_suggestion_text_field'),
            controller: controller,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: 'Enter a baby name...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            runSpacing: 4,
            children: [
              const Text('Gender: ',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              ...Gender.values.map(
                (g) => ChoiceChip(
                  key: Key('gender_chip_${g.name}'),
                  avatar: Icon(g.icon, size: 16, color: g.color),
                  label:
                      Text(g.displayName, style: const TextStyle(fontSize: 12)),
                  selected: selectedGender == g,
                  onSelected: (_) => onGenderChanged(g),
                  selectedColor: g.color.withValues(alpha: 0.25),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              key: const Key('submit_name_suggestion_button'),
              onPressed: isSubmitting ? null : onSubmit,
              icon: isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send, size: 18),
              label: Text(isSubmitting ? 'Submitting...' : 'Suggest Name'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Suggestions List
// ─────────────────────────────────────────────────────────────────────────────

class _SuggestionsList extends StatelessWidget {
  const _SuggestionsList({
    required this.state,
    required this.userId,
    required this.onLike,
  });

  final NameSuggestionsState state;
  final String userId;
  final ValueChanged<String> onLike;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.suggestions.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final suggestion = state.suggestions[index];
        final likeCount = state.likeCount(suggestion.id);
        final isLiked = state.hasUserLiked(suggestion.id, userId);

        return ListTile(
          key: Key('name_suggestion_${suggestion.id}'),
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: suggestion.gender.color.withValues(alpha: 0.15),
            child: Icon(suggestion.gender.icon,
                color: suggestion.gender.color, size: 20),
          ),
          title: Text(
            suggestion.suggestedName,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            suggestion.gender.displayName,
            style: TextStyle(
              color: suggestion.gender.color,
              fontSize: 12,
            ),
          ),
          trailing: _VoteButton(
            count: likeCount,
            isVoted: isLiked,
            onTap: userId.isNotEmpty ? () => onLike(suggestion.id) : null,
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Vote Button
// ─────────────────────────────────────────────────────────────────────────────

class _VoteButton extends StatelessWidget {
  const _VoteButton({
    required this.count,
    required this.isVoted,
    required this.onTap,
  });

  final int count;
  final bool isVoted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isVoted
              ? AppColors.primaryDark.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isVoted ? AppColors.primaryDark : AppColors.gray300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isVoted ? Icons.favorite : Icons.favorite_border,
              size: 18,
              color: isVoted ? AppColors.primaryDark : AppColors.gray500,
            ),
            if (count > 0) ...[
              const SizedBox(width: 4),
              Text(
                '$count',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isVoted ? AppColors.primaryDark : AppColors.gray600,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
