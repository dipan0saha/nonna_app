import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:nonna_app/core/config/app_config.dart';
import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/core/themes/onboarding_theme.dart';
import 'package:nonna_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_coordinator_provider.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_routes.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_types.dart';
import 'package:nonna_app/features/onboarding/presentation/utils/onboarding_follower_helpers.dart';
import 'package:nonna_app/features/onboarding/presentation/utils/onboarding_coowner_helpers.dart';
import 'package:nonna_app/features/onboarding/presentation/utils/onboarding_auth_helpers.dart';
import 'package:nonna_app/features/onboarding/presentation/widgets/onboarding_buttons.dart';
import 'package:nonna_app/features/onboarding/presentation/widgets/onboarding_fields.dart';
import 'package:nonna_app/features/onboarding/presentation/widgets/onboarding_scaffold.dart';
import 'package:nonna_app/features/profile/presentation/providers/profile_provider.dart';
import 'package:nonna_app/features/profile/presentation/widgets/profile_widgets.dart';

/// Complete profile — display name, optional photo, terms checkbox (#34 UI-only).
class OnboardingCompleteProfileScreen extends ConsumerStatefulWidget {
  const OnboardingCompleteProfileScreen({super.key});

  @override
  ConsumerState<OnboardingCompleteProfileScreen> createState() =>
      _OnboardingCompleteProfileScreenState();
}

class _OnboardingCompleteProfileScreenState
    extends ConsumerState<OnboardingCompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _picker = ImagePicker();

  var _syncedStep = false;
  var _initializedFields = false;
  var _termsAccepted = false;
  var _isSaving = false;
  var _isUploadingPhoto = false;
  XFile? _selectedImage;
  String? _prefilledAvatarUrl;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_syncedStep) {
      _syncedStep = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(onboardingCoordinatorProvider.notifier)
            .syncStepForRoute(OnboardingRoutes.completeProfile);
      });
    }
    _prefillFromAuth();
  }

  void _prefillFromAuth() {
    if (_initializedFields) return;
    final user = ref.read(currentAuthUserProvider);
    if (user == null) return;

    final metadata = user.userMetadata;
    final name = onboardingDisplayNameFromMetadata(metadata) ??
        user.email?.split('@').first;
    if (name != null && _nameController.text.isEmpty) {
      _nameController.text = name;
    }

    final avatarUrl = onboardingAvatarUrlFromMetadata(metadata);
    if (avatarUrl != null) {
      _prefilledAvatarUrl = avatarUrl;
    }

    _initializedFields = true;
  }

  Future<void> _handleBack() async {
    final route =
        await ref.read(onboardingCoordinatorProvider.notifier).goBack();
    if (!mounted) return;
    if (route != null) context.go(route);
  }

  Future<void> _pickPhoto() async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked != null && mounted) {
        setState(() => _selectedImage = picked);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open $url')),
      );
    }
  }

  Future<void> _handleContinue() async {
    if (_isSaving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Please accept the Terms of Service and Privacy Policy.'),
        ),
      );
      return;
    }

    final userId = ref.read(currentAuthUserProvider)?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to continue.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    String? avatarUrl = _prefilledAvatarUrl;
    if (_selectedImage != null) {
      setState(() => _isUploadingPhoto = true);
      try {
        final storagePath =
            await ref.read(storageServiceProvider).uploadUserAvatar(
                  imageFile: _selectedImage!,
                  userId: userId,
                );
        avatarUrl = ref
            .read(storageServiceProvider)
            .getPublicUrl('user-avatars', storagePath);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading photo: $e')),
        );
        setState(() {
          _isSaving = false;
          _isUploadingPhoto = false;
        });
        return;
      }
      if (mounted) setState(() => _isUploadingPhoto = false);
    }

    await ref.read(profileProvider.notifier).upsertProfile(
          userId: userId,
          displayName: _nameController.text.trim(),
          avatarUrl: avatarUrl,
        );

    if (!mounted) return;
    setState(() => _isSaving = false);

    final profileState = ref.read(profileProvider);
    if (!profileState.saveSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(profileState.saveError ?? 'Could not save profile.'),
        ),
      );
      return;
    }

    final path = ref.read(onboardingCoordinatorProvider).path;

    if (path == OnboardingPath.follower) {
      final acceptResult = await acceptPendingFollowerInvite(ref);
      if (!mounted) return;
      if (!acceptResult.success) {
        if (acceptResult.wrongEmail) {
          context.go(OnboardingRoutes.wrongEmail);
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                acceptResult.errorMessage ?? 'Could not accept invitation.'),
          ),
        );
        return;
      }
      if (acceptResult.alreadyMember) {
        await finishFollowerOnboardingAndGoHome(ref: ref, context: context);
        return;
      }
    }

    if (path == OnboardingPath.coOwner) {
      final acceptResult = await acceptPendingFollowerInvite(ref);
      if (!mounted) return;
      if (!acceptResult.success) {
        if (acceptResult.wrongEmail) {
          context.go(OnboardingRoutes.wrongEmail);
          return;
        }
        if (isMaxOwnersAcceptError(acceptResult.errorMessage)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'This baby profile already has the maximum number of owners.',
              ),
            ),
          );
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                acceptResult.errorMessage ?? 'Could not accept invitation.'),
          ),
        );
        return;
      }
      if (acceptResult.alreadyMember) {
        await finishCoOwnerOnboardingAndGoHome(ref: ref, context: context);
        return;
      }
    }

    final nextRoute = OnboardingRoutes.nextRouteAfterCompleteProfile(path);
    await ref
        .read(onboardingCoordinatorProvider.notifier)
        .advanceToRoute(nextRoute);
    if (mounted) context.go(nextRoute);
  }

  Widget _buildAvatar() {
    if (_selectedImage != null) {
      return CircleAvatar(
        radius: 52,
        backgroundImage: kIsWeb
            ? NetworkImage(_selectedImage!.path)
            : FileImage(File(_selectedImage!.path)) as ImageProvider,
      );
    }
    if (_prefilledAvatarUrl != null) {
      return ProfileAvatar(
        avatarUrl: _prefilledAvatarUrl,
        displayName: _nameController.text,
        radius: 52,
      );
    }
    return Container(
      width: 104,
      height: 104,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: OnboardingColors.border, width: 1.5),
        color: OnboardingColors.surface,
      ),
      child: const Icon(
        Icons.photo_camera_outlined,
        size: 28,
        color: OnboardingColors.muted,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = _isSaving || _isUploadingPhoto;
    final usedOAuth = ref.watch(onboardingCoordinatorProvider).usedOAuth;
    final subtext = usedOAuth
        ? 'We pulled in your details — add a photo so family knows who\'s who.'
        : 'Add your name and photo so family knows who\'s who.';

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
        body: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              const OnboardingHeadline('Complete your profile'),
              const SizedBox(height: 8),
              OnboardingSupportText(subtext),
              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  key: const Key('onboarding_complete_profile_avatar'),
                  onTap: isLoading ? null : _pickPhoto,
                  child: Column(
                    children: [
                      _buildAvatar(),
                      const SizedBox(height: 8),
                      Text(
                        _selectedImage != null || _prefilledAvatarUrl != null
                            ? 'Change photo'
                            : 'Add a photo',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: OnboardingColors.sageDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              OnboardingTextField(
                controller: _nameController,
                label: 'Full name',
                hint: 'Your name',
                validator: validateDisplayName,
                fieldKey: const Key('onboarding_complete_profile_name'),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      key: const Key('onboarding_complete_profile_terms'),
                      value: _termsAccepted,
                      activeColor: OnboardingColors.sage,
                      onChanged: isLoading
                          ? null
                          : (value) =>
                              setState(() => _termsAccepted = value ?? false),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: isLoading
                          ? null
                          : () =>
                              setState(() => _termsAccepted = !_termsAccepted),
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: OnboardingColors.muted,
                            height: 1.45,
                          ),
                          children: [
                            const TextSpan(text: 'I agree to the '),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.baseline,
                              baseline: TextBaseline.alphabetic,
                              child: GestureDetector(
                                onTap: () =>
                                    _openUrl(AppConfig.termsOfServiceUrl),
                                child: Text(
                                  'Terms of Service',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: OnboardingColors.sageDark,
                                    fontWeight: FontWeight.w700,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                            const TextSpan(text: ' and '),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.baseline,
                              baseline: TextBaseline.alphabetic,
                              child: GestureDetector(
                                onTap: () =>
                                    _openUrl(AppConfig.privacyPolicyUrl),
                                child: Text(
                                  'Privacy Policy',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: OnboardingColors.sageDark,
                                    fontWeight: FontWeight.w700,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
