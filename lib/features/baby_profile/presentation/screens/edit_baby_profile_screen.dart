import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nonna_app/core/constants/spacing.dart';
import 'package:nonna_app/core/enums/gender.dart';
import 'package:nonna_app/features/baby_profile/presentation/providers/baby_profile_provider.dart';
import 'package:nonna_app/features/baby_profile/presentation/widgets/baby_profile_widgets.dart';

/// Screen for editing an existing baby profile.
///
/// **Functional Requirements**: Section 3.6.3 - Profile Management Screens
class EditBabyProfileScreen extends ConsumerStatefulWidget {
  const EditBabyProfileScreen({
    super.key,
    required this.babyProfileId,
    required this.currentUserId,
    this.onSaved,
    this.onDeleted,
    this.onCancelled,
  });

  final String babyProfileId;
  final String currentUserId;
  final VoidCallback? onSaved;
  final VoidCallback? onDeleted;
  final VoidCallback? onCancelled;

  @override
  ConsumerState<EditBabyProfileScreen> createState() =>
      _EditBabyProfileScreenState();
}

class _EditBabyProfileScreenState extends ConsumerState<EditBabyProfileScreen> {
  static const int _twoYearsInDays = 730;

  late final TextEditingController _nameController;
  Gender _selectedGender = Gender.unknown;
  DateTime? _expectedBirthDate;
  DateTime? _actualBirthDate;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(babyProfileProvider.notifier).loadProfile(
            babyProfileId: widget.babyProfileId,
            currentUserId: widget.currentUserId,
          );
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _prefillFromState(BabyProfileState state) {
    if (!_initialized && state.profile != null) {
      final p = state.profile!;
      _nameController.text = p.name;
      _selectedGender = p.gender;
      _expectedBirthDate = p.expectedBirthDate;
      _actualBirthDate = p.actualBirthDate;
      _initialized = true;
    }
  }

  Future<void> _pickDate({
    required DateTime? current,
    required DateTime firstDate,
    required DateTime lastDate,
    required ValueChanged<DateTime> onPicked,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (picked != null) onPicked(picked);
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Baby name is required')),
      );
      return;
    }

    await ref.read(babyProfileProvider.notifier).updateProfile(
          babyProfileId: widget.babyProfileId,
          name: _nameController.text.trim(),
          gender: _selectedGender,
          expectedBirthDate: _expectedBirthDate,
          actualBirthDate: _actualBirthDate,
        );

    if (!mounted) return;
    final state = ref.read(babyProfileProvider);
    if (state.saveSuccess) {
      widget.onSaved?.call();
    }
  }

  Future<void> _confirmDelete() async {
    await DeleteProfileDialog.show(
      context,
      onConfirm: () async {
        final deleted = await ref
            .read(babyProfileProvider.notifier)
            .deleteProfile(babyProfileId: widget.babyProfileId);
        if (!mounted) return;
        if (deleted) widget.onDeleted?.call();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(babyProfileProvider);
    _prefillFromState(state);

    return Scaffold(
      key: const Key('edit_baby_profile_screen'),
      appBar: AppBar(title: const Text('Edit Baby Profile')),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: AppSpacing.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Baby Name',
                      border: OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  AppSpacing.verticalGapM,
                  Text(
                    'Gender',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  AppSpacing.verticalGapXS,
                  SegmentedButton<Gender>(
                    segments: Gender.values
                        .map(
                          (g) => ButtonSegment<Gender>(
                            value: g,
                            label: Text(g.displayName),
                            icon: Icon(g.icon),
                          ),
                        )
                        .toList(),
                    selected: {_selectedGender},
                    onSelectionChanged: (s) =>
                        setState(() => _selectedGender = s.first),
                  ),
                  AppSpacing.verticalGapM,
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Expected Birth Date'),
                    subtitle:
                        Text(_formatDate(_expectedBirthDate) ?? 'Not set'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () => _pickDate(
                      current: _expectedBirthDate,
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      onPicked: (d) => setState(() => _expectedBirthDate = d),
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Actual Birth Date'),
                    subtitle:
                        Text(_formatDate(_actualBirthDate) ?? 'Not yet born'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () => _pickDate(
                      current: _actualBirthDate,
                      firstDate: DateTime.now()
                          .subtract(const Duration(days: _twoYearsInDays)),
                      lastDate: DateTime.now(),
                      onPicked: (d) => setState(() => _actualBirthDate = d),
                    ),
                  ),
                  if (state.saveError != null) ...[
                    AppSpacing.verticalGapS,
                    Text(
                      state.saveError!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  AppSpacing.verticalGapL,
                  ElevatedButton(
                    onPressed: state.isSaving ? null : _save,
                    child: state.isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save'),
                  ),
                  AppSpacing.verticalGapS,
                  OutlinedButton(
                    onPressed: widget.onCancelled,
                    child: const Text('Cancel'),
                  ),
                  AppSpacing.verticalGapS,
                  OutlinedButton(
                    onPressed: state.isSaving ? null : _confirmDelete,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: const Text('Delete Profile'),
                  ),
                ],
              ),
            ),
    );
  }

  String? _formatDate(DateTime? date) {
    if (date == null) return null;
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
