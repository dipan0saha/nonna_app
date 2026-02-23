import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nonna_app/core/constants/spacing.dart';

/// Screen for inviting followers to a baby profile by email.
///
/// **Functional Requirements**: Section 3.6.4 - Additional Feature Screens
class InviteFollowersScreen extends ConsumerStatefulWidget {
  const InviteFollowersScreen({
    super.key,
    required this.babyProfileId,
    required this.invitedByUserId,
    this.onInviteSent,
    this.onDone,
  });

  final String babyProfileId;
  final String invitedByUserId;
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

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email);
  }

  Future<void> _sendInvite() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSending = true;
      _errorMessage = null;
      _successMessage = null;
    });

    // Simulate sending – in production this would call a service
    await Future<void>.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;
    setState(() {
      _isSending = false;
      _successMessage = 'Invitation sent to ${_emailController.text.trim()}';
      _emailController.clear();
    });
    widget.onInviteSent?.call();
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
                onFieldSubmitted: (_) => _sendInvite(),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email is required';
                  }
                  if (!_isValidEmail(value.trim())) {
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
