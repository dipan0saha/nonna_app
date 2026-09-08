import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/core/enums/gender.dart';
import 'package:nonna_app/core/themes/onboarding_theme.dart';
import 'package:nonna_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:nonna_app/features/baby_profile/presentation/providers/baby_profile_provider.dart';
import 'package:nonna_app/features/home/presentation/providers/user_baby_profiles_provider.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_coordinator_provider.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_routes.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_types.dart';
import 'package:nonna_app/features/onboarding/presentation/utils/onboarding_analytics.dart';
import 'package:nonna_app/features/onboarding/presentation/utils/onboarding_baby_helpers.dart';
import 'package:nonna_app/features/onboarding/presentation/widgets/onboarding_buttons.dart';
import 'package:nonna_app/features/onboarding/presentation/widgets/onboarding_carousel.dart';
import 'package:nonna_app/features/onboarding/presentation/widgets/onboarding_fields.dart';
import 'package:nonna_app/features/onboarding/presentation/widgets/onboarding_scaffold.dart';

const _genderBoy = 'Boy';
const _genderGirl = 'Girl';
const _genderUnsure = 'Not sure yet';

Gender _genderFromPill(String pill) {
  switch (pill) {
    case _genderBoy:
      return Gender.male;
    case _genderGirl:
      return Gender.female;
    default:
      return Gender.unknown;
  }
}

/// Owner create-baby step — expecting/born branch, gender pills, optional names.
class OnboardingCreateBabyScreen extends ConsumerStatefulWidget {
  const OnboardingCreateBabyScreen({super.key});

  @override
  ConsumerState<OnboardingCreateBabyScreen> createState() =>
      _OnboardingCreateBabyScreenState();
}

class _OnboardingCreateBabyScreenState
    extends ConsumerState<OnboardingCreateBabyScreen> {
  final _boyNameController = TextEditingController();
  final _girlNameController = TextEditingController();
  final _picker = ImagePicker();

  var _syncedStep = false;
  var _babyStatus = BabyStatus.expecting;
  var _genderPill = _genderUnsure;
  DateTime? _selectedDate;
  XFile? _selectedImage;
  var _isUploadingPhoto = false;
  String? _createdProfileId;

  @override
  void dispose() {
    _boyNameController.dispose();
    _girlNameController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_syncedStep) return;
    _syncedStep = true;

    final storedStatus = ref.read(onboardingCoordinatorProvider).babyStatus ??
        BabyStatus.expecting;
    _babyStatus = storedStatus;
    _genderPill = storedStatus == BabyStatus.born ? _genderBoy : _genderUnsure;
    _createdProfileId =
        ref.read(onboardingCoordinatorProvider).createdBabyProfileId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(onboardingCoordinatorProvider.notifier)
          .syncStepForRoute(OnboardingRoutes.ownerCreateBaby);
    });
  }

  Gender get _selectedGender => _genderFromPill(_genderPill);

  OnboardingBabyNameFieldsMode get _nameFieldsMode =>
      onboardingBabyNameFieldsMode(
        status: _babyStatus,
        gender: _selectedGender,
      );

  String get _dateLabel => _babyStatus == BabyStatus.expecting
      ? 'Expected Due Date'
      : 'Date of Birth';

  Future<void> _handleBack() async {
    final route =
        await ref.read(onboardingCoordinatorProvider.notifier).goBack();
    if (!mounted) return;
    if (route != null) context.go(route);
  }

  Future<void> _setBabyStatus(BabyStatus status) async {
    setState(() {
      _babyStatus = status;
      if (status == BabyStatus.born && _genderPill == _genderUnsure) {
        _genderPill = _genderBoy;
      }
    });
    await ref
        .read(onboardingCoordinatorProvider.notifier)
        .setBabyStatus(status);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: _babyStatus == BabyStatus.expecting
          ? now
          : now.subtract(const Duration(days: 365 * 5)),
      lastDate: _babyStatus == BabyStatus.expecting
          ? now.add(const Duration(days: 365))
          : now,
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickPhoto() async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked != null && mounted) setState(() => _selectedImage = picked);
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _handleContinue() async {
    final babyState = ref.read(babyProfileProvider);
    if (babyState.isSaving || _isUploadingPhoto) return;

    final userId = ref.read(currentAuthUserProvider)?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to continue.')),
      );
      return;
    }

    final name = resolveOnboardingBabyName(
      status: _babyStatus,
      gender: _selectedGender,
      boyName: _boyNameController.text,
      girlName: _girlNameController.text,
    );

    final notifier = ref.read(babyProfileProvider.notifier);
    late final String profileId;

    if (_createdProfileId != null) {
      profileId = _createdProfileId!;
    } else {
      final profile = await notifier.createProfile(
        name: name,
        userId: userId,
        expectedBirthDate:
            _babyStatus == BabyStatus.expecting ? _selectedDate : null,
        actualBirthDate: _babyStatus == BabyStatus.born ? _selectedDate : null,
        gender: _selectedGender,
      );

      if (!mounted) return;
      if (profile == null) return;

      profileId = profile.id;
      _createdProfileId = profileId;
      await ref.read(onboardingAnalyticsProvider).trackBabyProfileCreated(
            babyProfileId: profileId,
            hasPhoto: false,
            gender: _selectedGender.name,
          );
      await ref
          .read(onboardingCoordinatorProvider.notifier)
          .setCreatedBabyProfileId(profileId);
    }

    if (_selectedImage != null) {
      setState(() => _isUploadingPhoto = true);
      try {
        final storagePath =
            await ref.read(storageServiceProvider).uploadBabyProfilePhoto(
                  imageFile: _selectedImage!,
                  babyProfileId: profileId,
                );
        final photoUrl = ref
            .read(storageServiceProvider)
            .getPublicUrl('baby-profile-photos', storagePath);
        await notifier.updateProfile(
          babyProfileId: profileId,
          name: name,
          expectedBirthDate:
              _babyStatus == BabyStatus.expecting ? _selectedDate : null,
          actualBirthDate:
              _babyStatus == BabyStatus.born ? _selectedDate : null,
          gender: _selectedGender,
          profilePhotoUrl: photoUrl,
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading photo: $e')),
        );
        setState(() => _isUploadingPhoto = false);
        return;
      }
      if (mounted) setState(() => _isUploadingPhoto = false);
    }

    if (!mounted) return;
    final saveState = ref.read(babyProfileProvider);
    if (_selectedImage != null && !saveState.saveSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(saveState.saveError ?? 'Could not save baby photo.'),
        ),
      );
      return;
    }

    ref.read(selectedBabyProfileProvider.notifier).select(profileId);
    ref.invalidate(userBabyProfilesProvider);

    final coordinator = ref.read(onboardingCoordinatorProvider.notifier);
    await coordinator.setBabyStatus(_babyStatus);
    await coordinator.setCreatedBabyProfileId(profileId);

    final nextRoute = OnboardingRoutes.ownerFirstMoment;
    await coordinator.advanceToRoute(nextRoute);
    if (mounted) context.go(nextRoute);
  }

  Widget _buildNameFields() {
    switch (_nameFieldsMode) {
      case OnboardingBabyNameFieldsMode.expectingBoth:
        return Column(
          children: [
            OnboardingTextField(
              controller: _boyNameController,
              label: "Boy's name (optional)",
              hint: 'e.g. Liam',
              fieldKey: const Key('onboarding_create_baby_boy_name'),
            ),
            const SizedBox(height: 16),
            OnboardingTextField(
              controller: _girlNameController,
              label: "Girl's name (optional)",
              hint: 'e.g. Olivia',
              fieldKey: const Key('onboarding_create_baby_girl_name'),
            ),
          ],
        );
      case OnboardingBabyNameFieldsMode.bornSingleBoy:
        return OnboardingTextField(
          controller: _boyNameController,
          label: "Boy's name (optional)",
          hint: 'e.g. Liam',
          fieldKey: const Key('onboarding_create_baby_born_name'),
        );
      case OnboardingBabyNameFieldsMode.bornSingleGirl:
        return OnboardingTextField(
          controller: _girlNameController,
          label: "Girl's name (optional)",
          hint: 'e.g. Olivia',
          fieldKey: const Key('onboarding_create_baby_born_name'),
        );
    }
  }

  Widget _buildPhotoPicker() {
    return Center(
      child: GestureDetector(
        key: const Key('onboarding_create_baby_photo'),
        onTap: ref.watch(babyProfileProvider).isSaving || _isUploadingPhoto
            ? null
            : _pickPhoto,
        child: Column(
          children: [
            if (_selectedImage != null)
              CircleAvatar(
                radius: 52,
                backgroundImage: kIsWeb
                    ? NetworkImage(_selectedImage!.path)
                    : FileImage(File(_selectedImage!.path)) as ImageProvider,
              )
            else
              Container(
                width: 104,
                height: 104,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: OnboardingColors.border, width: 1.5),
                ),
                child: const Icon(
                  Icons.photo_camera_outlined,
                  size: 28,
                  color: OnboardingColors.muted,
                ),
              ),
            const SizedBox(height: 8),
            Text(
              _selectedImage != null ? 'Change photo' : 'Add a photo',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: OnboardingColors.sageDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final babyState = ref.watch(babyProfileProvider);
    final isLoading = babyState.isSaving || _isUploadingPhoto;
    final genderOptions = onboardingShowsUnsureGenderPill(_babyStatus)
        ? [_genderBoy, _genderGirl, _genderUnsure]
        : [_genderBoy, _genderGirl];
    final selectedGenderIndex = genderOptions.indexOf(_genderPill);

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
          isLoading: isLoading,
          onPressed: _handleContinue,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              const OnboardingHeadline("Create your baby's profile"),
              const SizedBox(height: 8),
              const OnboardingSupportText(
                'You can always add or change these details later.',
              ),
              const SizedBox(height: 20),
              OnboardingSegmentedControl(
                leftLabel: 'Expecting',
                rightLabel: 'Already Born',
                isLeftSelected: _babyStatus == BabyStatus.expecting,
                onLeftTap: () => _setBabyStatus(BabyStatus.expecting),
                onRightTap: () => _setBabyStatus(BabyStatus.born),
              ),
              const SizedBox(height: 18),
              OnboardingDatePickerField(
                label: _dateLabel,
                value: _selectedDate,
                placeholder: 'Select a date',
                onTap: isLoading ? () {} : _pickDate,
              ),
              const SizedBox(height: 18),
              Text(
                'Gender',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: OnboardingColors.text,
                ),
              ),
              const SizedBox(height: 8),
              OnboardingPillSelect(
                options: genderOptions,
                selectedIndex:
                    selectedGenderIndex >= 0 ? selectedGenderIndex : null,
                onSelected: (index) =>
                    setState(() => _genderPill = genderOptions[index]),
              ),
              const SizedBox(height: 18),
              _buildNameFields(),
              const SizedBox(height: 20),
              _buildPhotoPicker(),
              if (babyState.saveError != null) ...[
                const SizedBox(height: 16),
                Text(
                  babyState.saveError!,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                const OnboardingHelperText(
                  'Tap Continue to try again.',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
