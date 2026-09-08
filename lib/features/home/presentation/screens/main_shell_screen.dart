import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/core/widgets/app_bottom_nav_bar.dart';
import 'package:nonna_app/core/widgets/app_navigation_rail.dart';
import 'package:nonna_app/core/widgets/responsive_scaffold.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/first_run_home_provider.dart';

/// Shell screen that hosts the 5 persistent tab destinations.
class MainShellScreen extends ConsumerWidget {
  const MainShellScreen({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  void _onTabTap(WidgetRef ref, int index) {
    final current = navigationShell.currentIndex;
    if (current == 0 && index != 0) {
      final babyId = ref.read(selectedBabyProfileProvider);
      final firstRun = ref.read(firstRunHomeProvider);
      if (babyId != null && firstRun.isFirstRunFor(babyId)) {
        ref.read(firstRunHomeProvider.notifier).dismissForBaby(babyId);
      }
    }

    navigationShell.goBranch(
      index,
      initialLocation: index == current,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ResponsiveScaffold(
      body: navigationShell,
      bottomNavigationBar: AppBottomNavBar(
        selectedIndex: navigationShell.currentIndex,
        onTap: (index) => _onTabTap(ref, index),
      ),
      navigationRail: AppNavigationRail(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => _onTabTap(ref, index),
      ),
    );
  }
}
