import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import 'package:nonna_app/core/constants/first_moment_presets.dart';
import 'package:nonna_app/core/constants/supabase_tables.dart';
import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/core/enums/gender.dart';
import 'package:nonna_app/core/themes/onboarding_theme.dart';
import 'package:nonna_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_coordinator_provider.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_routes.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_types.dart';
import 'package:nonna_app/features/onboarding/presentation/utils/onboarding_first_moment_helpers.dart';
import 'package:nonna_app/features/onboarding/presentation/widgets/onboarding_buttons.dart';
import 'package:nonna_app/features/onboarding/presentation/widgets/onboarding_carousel.dart';
import 'package:nonna_app/features/onboarding/presentation/widgets/onboarding_fields.dart';
import 'package:nonna_app/features/onboarding/presentation/widgets/onboarding_scaffold.dart';

/// First Moment step — expecting vs born variants; all skippable.
class OnboardingFirstMomentScreen extends ConsumerStatefulWidget {
  const OnboardingFirstMomentScreen({super.key});

  @override
  ConsumerState<OnboardingFirstMomentScreen> createState() =>
      _OnboardingFirstMomentScreenState();
}

class _OnboardingFirstMomentScreenState
    extends ConsumerState<OnboardingFirstMomentScreen> {
  final _nameInputController = TextEditingController();
  final _picker = ImagePicker();

  var _syncedStep = false;
  var _isSaving = false;
  String? _saveError;
  var _nameGender = Gender.male;
  final _nameDrafts = <FirstMomentNameDraft>[];
  final _selectedEvents = <String>{};
  final _selectedRegistry = <String>{};
  XFile? _photoFile;
  DateTime? _expectedBirthDate;
  DateTime? _actualBirthDate;
  String? _babyProfileId;

  @override
  void dispose() {
    _nameInputController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_syncedStep) return;
    _syncedStep = true;
    _babyProfileId =
        ref.read(onboardingCoordinatorProvider).createdBabyProfileId;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref
          .read(onboardingCoordinatorProvider.notifier)
          .syncStepForRoute(OnboardingRoutes.ownerFirstMoment);
      await _loadBabyDates();
    });
  }

  Future<void> _loadBabyDates() async {
    final babyId = _babyProfileId;
    if (babyId == null) return;
    try {
      final row = await ref
          .read(databaseServiceProvider)
          .select(SupabaseTables.babyProfiles)
          .eq('id', babyId)
          .maybeSingle();
      if (!mounted || row == null) return;
      setState(() {
        final expected = row['expected_birth_date'] as String?;
        final actual = row['actual_birth_date'] as String?;
        _expectedBirthDate = expected != null ? DateTime.parse(expected) : null;
        _actualBirthDate = actual != null ? DateTime.parse(actual) : null;
      });
    } catch (e) {
      debugPrint('⚠️ Could not load baby dates for First Moment: $e');
    }
  }

  BabyStatus get _babyStatus =>
      ref.read(onboardingCoordinatorProvider).babyStatus ??
      BabyStatus.expecting;

  Future<void> _handleBack() async {
    final route =
        await ref.read(onboardingCoordinatorProvider.notifier).goBack();
    if (!mounted) return;
    if (route != null) context.go(route);
  }

  void _toggleEvent(String id) {
    setState(() {
      if (_selectedEvents.contains(id)) {
        _selectedEvents.remove(id);
      } else if (canSelectMoreEvents(_selectedEvents)) {
        _selectedEvents.add(id);
      }
    });
  }

  void _toggleRegistry(String id) {
    setState(() {
      if (_selectedRegistry.contains(id)) {
        _selectedRegistry.remove(id);
      } else {
        _selectedRegistry.add(id);
      }
    });
  }

  void _addNameSuggestion() {
    final value = _nameInputController.text.trim();
    if (value.isEmpty) return;
    setState(() {
      _nameDrafts.add(FirstMomentNameDraft(name: value, gender: _nameGender));
      _nameInputController.clear();
    });
  }

  Future<void> _pickPhoto() async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked != null && mounted) setState(() => _photoFile = picked);
    } catch (e) {
      debugPrint('Error picking photo: $e');
    }
  }

  Future<void> _handleContinue() async {
    if (_isSaving) return;
    final userId = ref.read(currentAuthUserProvider)?.id;
    final babyId = _babyProfileId;
    if (userId == null || babyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Baby profile not found. Go back and try again.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
      _saveError = null;
    });

    final result = await persistFirstMomentContent(
      database: ref.read(databaseServiceProvider),
      storage: ref.read(storageServiceProvider),
      babyProfileId: babyId,
      userId: userId,
      babyStatus: _babyStatus,
      expectedBirthDate: _expectedBirthDate,
      actualBirthDate: _actualBirthDate,
      nameDrafts: _nameDrafts,
      selectedEventIds: _selectedEvents,
      selectedRegistryIds: _selectedRegistry,
      photoFile: _babyStatus == BabyStatus.born ? _photoFile : null,
    );

    if (!mounted) return;
    if (!result.success) {
      setState(() {
        _isSaving = false;
        _saveError = result.error;
      });
      return;
    }

    final nextRoute = OnboardingRoutes.ownerInvite;
    await ref
        .read(onboardingCoordinatorProvider.notifier)
        .advanceToRoute(nextRoute);
    if (mounted) context.go(nextRoute);
  }

  Widget _buildNameCard() {
    return OnboardingMomentCard(
      title: 'Suggest a name',
      children: [
        const OnboardingSupportText('Seeds the vote in Family Fun'),
        const SizedBox(height: 10),
        OnboardingSegmentedControl(
          leftLabel: 'Boy',
          rightLabel: 'Girl',
          isLeftSelected: _nameGender == Gender.male,
          onLeftTap: () => setState(() => _nameGender = Gender.male),
          onRightTap: () => setState(() => _nameGender = Gender.female),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OnboardingTextField(
                controller: _nameInputController,
                hint: 'Add a name...',
                fieldKey: const Key('onboarding_first_moment_name_input'),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 48,
              width: 48,
              child: ElevatedButton(
                onPressed: _addNameSuggestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: OnboardingColors.sage,
                  foregroundColor: OnboardingColors.primaryButtonText,
                  padding: EdgeInsets.zero,
                ),
                child: const Text('+', style: TextStyle(fontSize: 20)),
              ),
            ),
          ],
        ),
        if (_nameDrafts.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _nameDrafts.map((draft) {
              final genderLabel =
                  draft.gender == Gender.female ? 'Girl' : 'Boy';
              return Chip(
                label: Text('${draft.name} · $genderLabel'),
                backgroundColor: OnboardingColors.sageTint,
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildPhotoCard() {
    return OnboardingMomentCard(
      title: 'Upload your first photo',
      children: [
        const OnboardingSupportText('From your camera or library'),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _isSaving ? null : _pickPhoto,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: OnboardingColors.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _photoFile != null
                    ? const Icon(
                        Icons.check_circle,
                        color: OnboardingColors.sageDark,
                      )
                    : const Icon(
                        Icons.add_a_photo_outlined,
                        color: OnboardingColors.muted,
                      ),
              ),
              const SizedBox(height: 8),
              Text(
                _photoFile != null ? 'Photo selected' : 'Add a photo',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: OnboardingColors.sageDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEventsCard(List<FirstMomentEventPreset> presets) {
    return OnboardingMomentCard(
      title: 'Add a calendar event',
      children: [
        OnboardingSupportText(
          _babyStatus == BabyStatus.expecting
              ? 'AI-suggested for this stage'
              : 'AI-suggested for newborns',
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: presets
              .map(
                (p) => OnboardingChip(
                  label: '+ ${p.label}',
                  selected: _selectedEvents.contains(p.id),
                  onTap: () => _toggleEvent(p.id),
                ),
              )
              .toList(),
        ),
        if (_selectedEvents.length >= FirstMomentPresets.maxSelectableEvents)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: OnboardingHelperText(
              'You can add up to ${FirstMomentPresets.maxSelectableEvents} events now.',
            ),
          ),
      ],
    );
  }

  Widget _buildRegistryCard(List<FirstMomentRegistryPreset> presets) {
    return OnboardingMomentCard(
      title: 'Add a registry item',
      children: [
        OnboardingSupportText(
          _babyStatus == BabyStatus.expecting
              ? 'AI-suggested for this stage'
              : 'AI-suggested for newborns',
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: presets
              .map(
                (p) => OnboardingChip(
                  label: '+ ${p.label}',
                  selected: _selectedRegistry.contains(p.id),
                  onTap: () => _toggleRegistry(p.id),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isExpecting = _babyStatus == BabyStatus.expecting;
    final eventPresets = isExpecting
        ? FirstMomentPresets.expectingEvents
        : FirstMomentPresets.bornEvents;
    final registryPresets = isExpecting
        ? FirstMomentPresets.expectingRegistry
        : FirstMomentPresets.bornRegistry;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _handleBack();
      },
      child: OnboardingScaffold(
        showBack: true,
        onBack: _handleBack,
        bottom: OnboardingPrimaryButton(
          label: 'Continue',
          isLoading: _isSaving,
          onPressed: _handleContinue,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              const OnboardingHeadline('Add your first moment'),
              const SizedBox(height: 8),
              const OnboardingSupportText(
                'Totally optional, but it helps family feel like there\'s already something here.',
              ),
              const SizedBox(height: 18),
              if (isExpecting) ...[
                _buildNameCard(),
                _buildEventsCard(eventPresets),
                _buildRegistryCard(registryPresets),
              ] else ...[
                _buildPhotoCard(),
                _buildRegistryCard(registryPresets),
                _buildEventsCard(eventPresets),
              ],
              if (_saveError != null) ...[
                Text(
                  _saveError!,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                const OnboardingHelperText('Tap Continue to try again.'),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
