import 'package:flutter/material.dart';

import 'package:nonna_app/core/utils/screen_size_utils.dart';

/// A [Scaffold] wrapper that adapts navigation chrome to the current screen
/// size.
///
/// **Functional Requirements**: Section 3.30 - Responsive Layouts
///
/// - Mobile  (< 600 dp): standard bottom navigation bar.
/// - Tablet+ (≥ 600 dp): [NavigationRail] side-bar instead.
///
/// All standard [Scaffold] properties are forwarded.
class ResponsiveScaffold extends StatelessWidget {
  const ResponsiveScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.navigationRail,
    this.drawer,
    this.floatingActionButton,
    this.backgroundColor,
  });

  /// Main content of the scaffold.
  final Widget body;

  /// App bar, forwarded to [Scaffold.appBar].
  final PreferredSizeWidget? appBar;

  /// Navigation bar shown on **mobile** screens.
  ///
  /// Ignored when [navigationRail] is displayed.
  final Widget? bottomNavigationBar;

  /// Navigation rail shown on **tablet and larger** screens.
  ///
  /// When `null`, the mobile scaffold layout is used for all screen sizes,
  /// and [bottomNavigationBar] (if provided) will be shown regardless of
  /// screen size.
  final NavigationRail? navigationRail;

  /// Drawer, forwarded to [Scaffold.drawer].
  final Widget? drawer;

  /// FAB, forwarded to [Scaffold.floatingActionButton].
  final Widget? floatingActionButton;

  /// Background colour, forwarded to [Scaffold.backgroundColor].
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final isMobile = ScreenSizeUtils.isMobile(context);

    if (isMobile || navigationRail == null) {
      return Scaffold(
        appBar: appBar,
        body: body,
        bottomNavigationBar: bottomNavigationBar,
        drawer: drawer,
        floatingActionButton: floatingActionButton,
        backgroundColor: backgroundColor,
      );
    }

    // Tablet / desktop — show NavigationRail alongside the body.
    return Scaffold(
      appBar: appBar,
      drawer: drawer,
      floatingActionButton: floatingActionButton,
      backgroundColor: backgroundColor,
      body: Row(
        children: [
          navigationRail!,
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: body),
        ],
      ),
    );
  }
}
