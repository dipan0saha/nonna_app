import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nonna_app/core/constants/spacing.dart';
import 'package:nonna_app/core/themes/colors.dart';
import 'package:nonna_app/core/themes/nonna_theme_extension.dart';
import 'package:nonna_app/features/settings/presentation/providers/settings_provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// Settings screen for configuring app preferences.
///
/// **Functional Requirements**: Section 3.6.4 - Additional Feature Screens
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      key: const Key('settings_screen'),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Settings'),
            backgroundColor: theme.scaffoldBackgroundColor,
            scrolledUnderElevation: 0,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: AppSpacing.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Preferences Section
                  _SectionHeader(
                      title: 'Preferences',
                      color: Theme.of(context).colorScheme.onSurface),
                  _SettingsCard(
                    children: [
                      _EnhancedSwitchTile(
                        key: const Key('notifications_toggle'),
                        title: 'Push Notifications',
                        subtitle: 'Receive updates about events',
                        icon: Icons.notifications_active_rounded,
                        iconColor: AppColors.warningDark,
                        backgroundColor: AppColors.warningLight,
                        value: state.notificationsEnabled,
                        onChanged: (v) =>
                            notifier.toggleNotifications(enabled: v),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.l),

                  // Support & About Section (New functional visual additions)
                  _SectionHeader(
                      title: 'About',
                      color: Theme.of(context).colorScheme.onSurface),
                  _SettingsCard(
                    children: [
                      _EnhancedListTile(
                        title: 'Help & Support',
                        subtitle: 'Get help or send feedback',
                        icon: Icons.help_outline_rounded,
                        iconColor: context.nonnaTheme.sageDark,
                        backgroundColor: AppColors.sageTint,
                        onTap: () async {
                          final uri = Uri(
                            scheme: 'mailto',
                            path: 'support@nonna.app',
                            queryParameters: {
                              'subject': 'Nonna App Support',
                            },
                          );
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Could not open email client. Please contact support@nonna.app')),
                              );
                            }
                          }
                        },
                      ),
                      const _Divider(),
                      _EnhancedListTile(
                        title: 'App Version',
                        subtitle: 'v1.0.0 (Build 1)',
                        icon: Icons.info_outline_rounded,
                        iconColor: Colors.grey.shade600,
                        backgroundColor: Colors.grey.shade200,
                        showTrailing: false,
                        onTap: null, // Read-only tile
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.l),

                  if (state.saveError != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.m),
                      child: Text(
                        state.saveError!,
                        style: TextStyle(color: colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // Bottom padding for scrollability
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: Column(
            children: children,
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 64.0),
      child: Divider(
        height: 1,
        thickness: 1,
        color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.4),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.color});
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.m, bottom: AppSpacing.xs),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _EnhancedListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final VoidCallback? onTap;
  final bool showTrailing;

  const _EnhancedListTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    this.onTap,
    this.showTrailing = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: showTrailing
          ? const Icon(Icons.chevron_right_rounded, color: Colors.grey)
          : null,
      onTap: onTap,
    );
  }
}

class _EnhancedSwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _EnhancedSwitchTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: 4),
      value: value,
      onChanged: onChanged,
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(subtitle),
    );
  }
}
