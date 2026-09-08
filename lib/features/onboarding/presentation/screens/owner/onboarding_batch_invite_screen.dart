import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/core/themes/onboarding_theme.dart';
import 'package:nonna_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:nonna_app/features/baby_profile/presentation/providers/baby_profile_provider.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_coordinator_provider.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_routes.dart';
import 'package:nonna_app/core/constants/onboarding_integration_keys.dart';
import 'package:nonna_app/features/onboarding/presentation/utils/onboarding_analytics.dart';
import 'package:nonna_app/features/onboarding/presentation/utils/onboarding_home_helpers.dart';
import 'package:nonna_app/features/onboarding/presentation/widgets/onboarding_buttons.dart';
import 'package:nonna_app/features/onboarding/presentation/widgets/onboarding_fields.dart';
import 'package:nonna_app/features/onboarding/presentation/widgets/onboarding_invite_row.dart';
import 'package:nonna_app/features/onboarding/presentation/widgets/onboarding_scaffold.dart';

class _InviteRowState {
  _InviteRowState()
      : nameController = TextEditingController(),
        emailController = TextEditingController();

  final TextEditingController nameController;
  final TextEditingController emailController;
  String relationship = kOnboardingRelationshipOptions.first;
  bool isSending = false;
  String? error;
  String? skipMessage;
  bool sent = false;

  void dispose() {
    nameController.dispose();
    emailController.dispose();
  }

  bool get showOwnerBadge =>
      relationship == 'Wife' || relationship == 'Husband';

  UserRole get invitedRole =>
      showOwnerBadge ? UserRole.owner : UserRole.follower;
}

/// Batch invite step — dynamic rows, partial failure, skip to home.
class OnboardingBatchInviteScreen extends ConsumerStatefulWidget {
  const OnboardingBatchInviteScreen({super.key});

  @override
  ConsumerState<OnboardingBatchInviteScreen> createState() =>
      _OnboardingBatchInviteScreenState();
}

class _OnboardingBatchInviteScreenState
    extends ConsumerState<OnboardingBatchInviteScreen> {
  final _rows = <_InviteRowState>[_InviteRowState()];
  var _syncedStep = false;
  var _isSendingBatch = false;

  @override
  void dispose() {
    for (final row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_syncedStep) return;
    _syncedStep = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(onboardingCoordinatorProvider.notifier)
          .syncStepForRoute(OnboardingRoutes.ownerInvite);
    });
  }

  Future<void> _handleBack() async {
    final route =
        await ref.read(onboardingCoordinatorProvider.notifier).goBack();
    if (!mounted) return;
    if (route != null) context.go(route);
  }

  void _addRow() {
    setState(() => _rows.add(_InviteRowState()));
  }

  void _removeRow(int index) {
    if (_rows.length <= 1) return;
    setState(() {
      _rows[index].dispose();
      _rows.removeAt(index);
    });
  }

  Future<void> _skipToHome() async {
    await finishOwnerOnboardingAndGoHome(ref: ref, context: context);
  }

  Future<void> _sendInvites() async {
    if (_isSendingBatch) return;
    final userId = ref.read(currentAuthUserProvider)?.id;
    final babyId = ref.read(onboardingCoordinatorProvider).createdBabyProfileId;
    if (userId == null || babyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Baby profile not found.')),
      );
      return;
    }

    setState(() => _isSendingBatch = true);
    final notifier = ref.read(babyProfileProvider.notifier);
    var anySent = false;

    for (final row in _rows) {
      final email = row.emailController.text.trim();
      if (email.isEmpty) continue;

      row.error = null;
      row.skipMessage = null;
      row.isSending = true;
      if (mounted) setState(() {});

      final skipReason = await notifier.inviteSkipReasonForEmail(
        babyProfileId: babyId,
        email: email,
      );
      if (skipReason != null) {
        row.skipMessage = skipReason;
        row.isSending = false;
        if (mounted) setState(() {});
        continue;
      }

      try {
        await notifier.sendInvitation(
          babyProfileId: babyId,
          invitedByUserId: userId,
          email: email,
          inviteeName: row.nameController.text.trim(),
          relationshipLabel: row.relationship,
          invitedRole: row.invitedRole,
        );
        row.sent = true;
        anySent = true;
        await ref.read(onboardingAnalyticsProvider).trackInvitationSent(
              babyProfileId: babyId,
              relationshipType: row.relationship,
            );
      } catch (e) {
        row.error = e.toString().replaceFirst('Exception: ', '');
      } finally {
        row.isSending = false;
        if (mounted) setState(() {});
      }
    }

    if (!mounted) return;
    setState(() => _isSendingBatch = false);

    if (anySent || _rows.every((r) => r.emailController.text.trim().isEmpty)) {
      await finishOwnerOnboardingAndGoHome(ref: ref, context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _handleBack();
      },
      child: OnboardingScaffold(
        showBack: true,
        onBack: _handleBack,
        bottom: Column(
          children: [
            OnboardingPrimaryButton(
              buttonKey: OnboardingIntegrationKeys.batchInvitePrimary,
              label: 'Send Invites',
              isLoading: _isSendingBatch,
              onPressed: _sendInvites,
            ),
            OnboardingBottomLink(
              prefix: '',
              actionLabel: 'Skip for now',
              onTap: _isSendingBatch ? () {} : _skipToHome,
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              const OnboardingHeadline('Invite family & friends'),
              const SizedBox(height: 8),
              const OnboardingSupportText(
                'Add the people you want to share this with. You can always invite more later.',
              ),
              const SizedBox(height: 16),
              ...List.generate(_rows.length, (index) {
                final row = _rows[index];
                return Column(
                  children: [
                    OnboardingInviteRow(
                      nameController: row.nameController,
                      emailController: row.emailController,
                      relationship: row.relationship,
                      showOwnerBadge: row.showOwnerBadge,
                      onRelationshipChanged: (value) {
                        setState(() => row.relationship = value);
                      },
                      onRemove:
                          _rows.length > 1 ? () => _removeRow(index) : null,
                    ),
                    if (row.showOwnerBadge)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          '👑 This person will also be a Baby Profile Owner',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: OnboardingColors.peachDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    if (row.skipMessage != null)
                      Text(
                        row.skipMessage!,
                        style:
                            const TextStyle(color: Colors.orange, fontSize: 12),
                      ),
                    if (row.error != null)
                      Text(
                        row.error!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    if (row.sent)
                      const Text(
                        'Invitation sent',
                        style: TextStyle(
                          color: OnboardingColors.sageDark,
                          fontSize: 12,
                        ),
                      ),
                  ],
                );
              }),
              TextButton(
                onPressed: _isSendingBatch ? null : _addRow,
                child: const Text('+ Add another'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
