import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:nonna_app/core/widgets/app_bottom_nav_bar.dart';
import 'package:nonna_app/core/widgets/app_navigation_rail.dart';
import 'package:nonna_app/core/widgets/responsive_scaffold.dart';

/// Shell screen that hosts the 5 persistent tab destinations.
///
/// Rendered by [StatefulShellRoute.indexedStack] in [app_router.dart].
/// Receives [navigationShell] from GoRouter, which:
/// - Acts as the [body] (renders the active branch's navigator content)
/// - Exposes [currentIndex] for the selected tab
/// - Exposes [goBranch] for programmatic tab switching
///
/// Navigation chrome (bottom bar / rail) is delegated to [ResponsiveScaffold],
/// which automatically switches between [AppBottomNavBar] on mobile and
/// [AppNavigationRail] on tablet (≥ 600 dp).
class MainShellScreen extends StatelessWidget {
  const MainShellScreen({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  void _onTabTap(int index) {
    // initialLocation: true returns the user to the top of the branch stack
    // when re-tapping the already-active tab (mirrors standard iOS/Android behaviour).
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      body: navigationShell,
      bottomNavigationBar: AppBottomNavBar(
        selectedIndex: navigationShell.currentIndex,
        onTap: _onTabTap,
      ),
      navigationRail: AppNavigationRail(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTabTap,
      ),
    );
  }
}
