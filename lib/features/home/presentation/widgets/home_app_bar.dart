import 'package:flutter/material.dart';

import 'package:nonna_app/core/themes/colors.dart';

/// Home screen app bar
///
/// **Functional Requirements**: Section 3.6.2 - Main App Screens Part I
/// Reference: docs/Core_development_component_identification.md
///
/// Features:
/// - Baby profile name display
/// - Notification icon with badge count
/// - Settings icon
/// - Callbacks for user interactions
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({
    super.key,
    this.babyProfileName,
    this.notificationCount = 0,
    this.onNotificationTap,
    this.onSettingsTap,
    this.onBabyProfileTap,
  });

  /// The name of the currently selected baby profile
  final String? babyProfileName;

  /// Number of unread notifications (shows badge when > 0)
  final int notificationCount;

  /// Called when the notification icon is tapped
  final VoidCallback? onNotificationTap;

  /// Called when the settings icon is tapped
  final VoidCallback? onSettingsTap;

  /// Called when the baby profile name is tapped
  final VoidCallback? onBabyProfileTap;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      key: const Key('home_app_bar'),
      title: GestureDetector(
        onTap: onBabyProfileTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              babyProfileName ?? 'Nonna',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (onBabyProfileTap != null) ...[
              const SizedBox(width: 4),
              const Icon(Icons.arrow_drop_down, size: 20),
            ],
          ],
        ),
      ),
      actions: [
        // Notification icon with optional badge
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              key: const Key('notification_icon_button'),
              icon: const Icon(Icons.notifications_outlined),
              onPressed: onNotificationTap,
            ),
            if (notificationCount > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    notificationCount > 99
                        ? '99+'
                        : notificationCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        IconButton(
          key: const Key('settings_icon_button'),
          icon: const Icon(Icons.settings_outlined),
          onPressed: onSettingsTap,
        ),
      ],
    );
  }
}
