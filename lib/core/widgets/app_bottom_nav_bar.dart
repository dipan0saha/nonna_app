import 'package:flutter/material.dart';

/// Persistent bottom navigation bar for the 5 main tabs.
///
/// Stateless — receives [selectedIndex] and [onTap] from [MainShellScreen],
/// which delegates tab switching to [StatefulNavigationShell.goBranch].
///
/// Theming is inherited from [AppTheme._bottomNavBarTheme] (already configured);
/// no local style overrides are needed here.
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    _NavItem(
        label: 'Home', selected: Icons.home, unselected: Icons.home_outlined),
    _NavItem(
        label: 'Gallery',
        selected: Icons.photo_library,
        unselected: Icons.photo_library_outlined),
    _NavItem(
        label: 'Calendar',
        selected: Icons.calendar_today,
        unselected: Icons.calendar_today_outlined),
    _NavItem(
        label: 'Registry',
        selected: Icons.card_giftcard,
        unselected: Icons.card_giftcard_outlined),
    _NavItem(
        label: 'Fun',
        selected: Icons.auto_awesome,
        unselected: Icons.auto_awesome_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      key: const Key('app_bottom_nav_bar'),
      currentIndex: selectedIndex,
      onTap: onTap,
      items: [
        for (final item in _items)
          BottomNavigationBarItem(
            icon: Icon(item.unselected),
            activeIcon: Icon(item.selected),
            label: item.label,
          ),
      ],
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.label,
    required this.selected,
    required this.unselected,
  });

  final String label;
  final IconData selected;
  final IconData unselected;
}
