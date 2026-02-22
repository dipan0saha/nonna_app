import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nonna_app/core/constants/spacing.dart';
import 'package:nonna_app/features/profile/presentation/providers/profile_provider.dart';
import 'package:nonna_app/features/profile/presentation/widgets/profile_widgets.dart';

/// Screen for editing the user's profile (display name, biometric toggle).
///
/// **Functional Requirements**: Section 3.6.3 - Profile Management Screens
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({
    super.key,
    required this.userId,
    this.onSaved,
    this.onCancelled,
  });

  final String userId;
  final VoidCallback? onSaved;
  final VoidCallback? onCancelled;

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _displayNameController;
  bool _biometricEnabled = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(profileProvider.notifier)
          .loadProfile(userId: widget.userId);
    });
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  void _prefillFromState(ProfileState state) {
    if (!_initialized && state.profile != null) {
      _displayNameController.text = state.profile!.displayName;
      _biometricEnabled = state.profile!.biometricEnabled;
      _initialized = true;
    }
  }

  Future<void> _save(ProfileState state) async {
    if (_displayNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Display name must not be empty')),
      );
      return;
    }

    await ref.read(profileProvider.notifier).updateProfile(
          userId: widget.userId,
          displayName: _displayNameController.text.trim(),
        );

    if (!mounted) return;
    final updated = ref.read(profileProvider);
    if (updated.saveSuccess) {
      widget.onSaved?.call();
    }
  }

  void _onChangePhoto() {
    // Photo change placeholder – not implemented in this version
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileProvider);
    _prefillFromState(state);

    return Scaffold(
      key: const Key('edit_profile_screen'),
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  ProfileAvatar(
                    avatarUrl: state.profile?.avatarUrl,
                    displayName: state.profile?.displayName ?? '',
                    radius: 48,
                  ),
                  FloatingActionButton.small(
                    onPressed: _onChangePhoto,
                    heroTag: 'change_photo',
                    child: const Icon(Icons.camera_alt, size: 18),
                  ),
                ],
              ),
            ),
            AppSpacing.verticalGapL,
            TextFormField(
              controller: _displayNameController,
              decoration: const InputDecoration(
                labelText: 'Display Name',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.done,
            ),
            AppSpacing.verticalGapM,
            SwitchListTile(
              title: const Text('Enable Biometric Login'),
              value: _biometricEnabled,
              onChanged: (value) => setState(() => _biometricEnabled = value),
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
              onPressed: state.isSaving ? null : () => _save(state),
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
          ],
        ),
      ),
    );
  }
}
