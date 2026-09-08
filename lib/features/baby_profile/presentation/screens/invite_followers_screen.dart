import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nonna_app/core/constants/spacing.dart';
import 'package:nonna_app/core/constants/supabase_tables.dart';
import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/core/utils/share_helpers.dart';
import 'package:nonna_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:nonna_app/features/baby_profile/presentation/providers/baby_profile_provider.dart';

/// Screen for inviting followers to a baby profile by email.
///
/// **Functional Requirements**: Section 3.6.4 - Additional Feature Screens
class InviteFollowersScreen extends ConsumerStatefulWidget {
  const InviteFollowersScreen({
    super.key,
    required this.babyProfileId,
    required this.invitedByUserId,
    this.babyName,
    this.onInviteSent,
    this.onDone,
  });

  final String babyProfileId;
  final String invitedByUserId;
  final String? babyName;
  final VoidCallback? onInviteSent;
  final VoidCallback? onDone;

  @override
  ConsumerState<InviteFollowersScreen> createState() =>
      _InviteFollowersScreenState();
}

class _InviteFollowersScreenState extends ConsumerState<InviteFollowersScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  bool _isSending = false;
  String? _successMessage;
  String? _errorMessage;
  String? _lastInviteUrl;
  String? _lastBabyName;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
  }

  Future<String> _resolveBabyName() async {
    final widgetName = widget.babyName?.trim();
    if (widgetName != null && widgetName.isNotEmpty) {
      return widgetName;
    }

    try {
      final response = await ref
          .read(databaseServiceProvider)
          .select(
            SupabaseTables.babyProfiles,
            columns: SupabaseTables.name,
          )
          .eq(SupabaseTables.id, widget.babyProfileId)
          .maybeSingle();

      final resolvedName = response?[SupabaseTables.name] as String?;
      if (resolvedName != null && resolvedName.trim().isNotEmpty) {
        return resolvedName.trim();
      }
    } catch (_) {
      // Keep fallback text if name lookup fails.
    }

    return 'your baby';
  }

  Future<void> _sendInvite() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSending = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final email = _emailController.text.trim();
      final invitation =
          await ref.read(babyProfileProvider.notifier).sendInvitation(
                babyProfileId: widget.babyProfileId,
                invitedByUserId: widget.invitedByUserId,
                email: email,
              );
      if (!mounted) return;

      final resolvedBabyName = await _resolveBabyName();
      if (!mounted) return;

      final inviteUrl = ShareHelpers.generateInvitationLink(
        invitation.tokenHash,
      );

      if (!mounted) return;
      setState(() {
        _isSending = false;
        _successMessage = 'Invitation sent to ${invitation.inviteeEmail}';
        _lastInviteUrl = inviteUrl;
        _lastBabyName = resolvedBabyName;
        _emailController.clear();
      });
      widget.onInviteSent?.call();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSending = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('invite_followers_screen'),
      appBar: AppBar(title: const Text('Invite Followers')),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Invite people to follow this baby profile by entering their email address.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              AppSpacing.verticalGapL,
              TextFormField(
                key: const Key('invite_email_field'),
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.send,
                onChanged: (_) {
                  if (_lastInviteUrl != null) {
                    setState(() {
                      _lastInviteUrl = null;
                      _lastBabyName = null;
                    });
                  }
                },
                onFieldSubmitted: (_) => _sendInvite(),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email is required';
                  }
                  final trimmed = value.trim();
                  if (!_isValidEmail(trimmed)) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),
              if (_successMessage != null) ...[
                AppSpacing.verticalGapS,
                Text(
                  _successMessage!,
                  key: const Key('invite_success_message'),
                  style: const TextStyle(color: Colors.green),
                  textAlign: TextAlign.center,
                ),
              ],
              if (_lastInviteUrl != null) ...[
                AppSpacing.verticalGapM,
                Container(
                  padding: AppSpacing.cardPadding,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Share this invite link',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      AppSpacing.verticalGapXS,
                      SelectableText(
                        _lastInviteUrl!,
                        maxLines: 2,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      AppSpacing.verticalGapS,
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                await Clipboard.setData(
                                  ClipboardData(text: _lastInviteUrl!),
                                );
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Invite link copied'),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.copy_outlined),
                              label: const Text('Copy'),
                            ),
                          ),
                          AppSpacing.horizontalGapS,
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                final inviterName = ref
                                            .read(authProvider)
                                            .userModel
                                            ?.displayName
                                            .trim()
                                            .isNotEmpty ==
                                        true
                                    ? ref
                                        .read(authProvider)
                                        .userModel!
                                        .displayName
                                        .trim()
                                    : 'A family member';

                                final shareText =
                                    ShareHelpers.generateInvitationText(
                                  _lastBabyName ?? 'your baby',
                                  inviterName,
                                );

                                ShareHelpers.shareLink(
                                  _lastInviteUrl!,
                                  text: shareText,
                                );
                              },
                              icon: const Icon(Icons.share_outlined),
                              label: const Text('Share'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              if (_errorMessage != null) ...[
                AppSpacing.verticalGapS,
                Text(
                  _errorMessage!,
                  key: const Key('invite_error_message'),
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
              AppSpacing.verticalGapL,
              ElevatedButton.icon(
                key: const Key('send_invite_button'),
                onPressed: _isSending ? null : _sendInvite,
                icon: _isSending
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                label: const Text('Send Invite'),
              ),
              AppSpacing.verticalGapS,
              OutlinedButton(
                onPressed: widget.onDone,
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
