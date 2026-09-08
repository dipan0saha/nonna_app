import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:nonna_app/core/constants/spacing.dart';
import 'package:nonna_app/core/router/app_router.dart';
import 'package:nonna_app/core/widgets/error_view.dart';
import 'package:nonna_app/features/baby_profile/presentation/providers/invite_accept_provider.dart';

/// Screen that resolves and accepts invitation links.
class InviteAcceptScreen extends ConsumerStatefulWidget {
  const InviteAcceptScreen({
    super.key,
    required this.token,
  });

  final String token;

  @override
  ConsumerState<InviteAcceptScreen> createState() => _InviteAcceptScreenState();
}

class _InviteAcceptScreenState extends ConsumerState<InviteAcceptScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(inviteAcceptProvider.notifier).lookupToken(widget.token);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(inviteAcceptProvider);
    final notifier = ref.read(inviteAcceptProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Invitation')),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: _buildBody(context, state, notifier),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    InviteAcceptState state,
    InviteAcceptNotifier notifier,
  ) {
    switch (state.status) {
      case InviteAcceptStatus.idle:
      case InviteAcceptStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case InviteAcceptStatus.found:
      case InviteAcceptStatus.accepting:
        final isSubmitting = state.status == InviteAcceptStatus.accepting;
        return _InvitationCard(
          babyName: state.babyName ?? 'your baby',
          inviterName: state.inviterName ?? 'A family member',
          isSubmitting: isSubmitting,
          onAccept: isSubmitting ? null : () => notifier.accept(widget.token),
          onDecline: () async {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        );
      case InviteAcceptStatus.accepted:
        return _StatusCard(
          title: 'You are in!',
          message:
              'You are now following ${state.babyName ?? 'this baby profile'}.',
          icon: Icons.check_circle_outline,
          actionLabel: 'Go to Home',
          onAction: () => context.go(AppRoutes.home),
        );
      case InviteAcceptStatus.alreadyMember:
        return _StatusCard(
          title: 'Already Following',
          message:
              'You are already following ${state.babyName ?? 'this baby profile'}.',
          icon: Icons.info_outline,
          actionLabel: 'Go to Home',
          onAction: () => context.go(AppRoutes.home),
        );
      case InviteAcceptStatus.expired:
        return _StatusCard(
          title: 'Invite Expired',
          message:
              'This invitation is no longer valid. Ask the inviter to send a new one.',
          icon: Icons.schedule,
          actionLabel: 'Go to Home',
          onAction: () => context.go(AppRoutes.home),
        );
      case InviteAcceptStatus.notFound:
        return _StatusCard(
          title: 'Invalid Invite',
          message: 'This invitation link is invalid or has already been used.',
          icon: Icons.link_off,
          actionLabel: 'Go to Home',
          onAction: () => context.go(AppRoutes.home),
        );
      case InviteAcceptStatus.error:
        return Center(
          child: InlineErrorView(
            message: state.error ?? 'Something went wrong.',
            onRetry: () => notifier.lookupToken(widget.token),
          ),
        );
    }
  }
}

class _InvitationCard extends StatelessWidget {
  const _InvitationCard({
    required this.babyName,
    required this.inviterName,
    required this.isSubmitting,
    required this.onAccept,
    required this.onDecline,
  });

  final String babyName;
  final String inviterName;
  final bool isSubmitting;
  final VoidCallback? onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: Padding(
          padding: AppSpacing.cardPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Join Baby Profile',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              AppSpacing.verticalGapS,
              Text(
                '$inviterName invited you to follow $babyName on Nonna.',
                textAlign: TextAlign.center,
              ),
              AppSpacing.verticalGapL,
              ElevatedButton.icon(
                onPressed: onAccept,
                icon: isSubmitting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                label: const Text('Accept Invitation'),
              ),
              AppSpacing.verticalGapS,
              OutlinedButton(
                onPressed: onDecline,
                child: const Text('Decline'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.title,
    required this.message,
    required this.icon,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String message;
  final IconData icon;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: Padding(
          padding: AppSpacing.cardPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48),
              AppSpacing.verticalGapS,
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              AppSpacing.verticalGapXS,
              Text(
                message,
                textAlign: TextAlign.center,
              ),
              AppSpacing.verticalGapL,
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
