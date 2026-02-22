import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nonna_app/core/constants/spacing.dart';
import 'package:nonna_app/core/enums/gender.dart';
import 'package:nonna_app/features/baby_profile/presentation/providers/baby_profile_provider.dart';

/// Screen for creating a new baby profile.
///
/// **Functional Requirements**: Section 3.6.3 - Profile Management Screens
class CreateBabyProfileScreen extends ConsumerStatefulWidget {
  const CreateBabyProfileScreen({
    super.key,
    required this.userId,
    this.onCreated,
    this.onCancelled,
  });

  final String userId;
  final ValueChanged<String>? onCreated;
  final VoidCallback? onCancelled;

  @override
  ConsumerState<CreateBabyProfileScreen> createState() =>
      _CreateBabyProfileScreenState();
}

class _CreateBabyProfileScreenState
    extends ConsumerState<CreateBabyProfileScreen> {
  late final TextEditingController _nameController;
  Gender _selectedGender = Gender.unknown;
  DateTime? _expectedBirthDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickExpectedBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expectedBirthDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _expectedBirthDate = picked);
    }
  }

  Future<void> _create() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Baby name is required')),
      );
      return;
    }

    final profile = await ref
        .read(babyProfileProvider.notifier)
        .createProfile(
          name: _nameController.text.trim(),
          userId: widget.userId,
          expectedBirthDate: _expectedBirthDate,
          gender: _selectedGender,
        );

    if (!mounted) return;
    if (profile != null) {
      widget.onCreated?.call(profile.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(babyProfileProvider);

    return Scaffold(
      key: const Key('create_baby_profile_screen'),
      appBar: AppBar(title: const Text('Create Baby Profile')),
      body: SingleChildScrollView(
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
              subtitle: Text(
                _expectedBirthDate != null
                    ? '${_expectedBirthDate!.year}-'
                        '${_expectedBirthDate!.month.toString().padLeft(2, '0')}-'
                        '${_expectedBirthDate!.day.toString().padLeft(2, '0')}'
                    : 'Not set',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickExpectedBirthDate,
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
              onPressed: state.isSaving ? null : _create,
              child: state.isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Create'),
            ),
            AppSpacing.verticalGapS,
            OutlinedButton(
              onPressed: widget.onCancelled,
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
