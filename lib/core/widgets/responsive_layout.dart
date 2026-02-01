import 'package:flutter/material.dart';
import 'package:nonna_app/core/utils/screen_size_utils.dart';

/// Responsive layout widget for breakpoint-based layouts
///
/// Provides an easy way to create responsive UIs that adapt to different
/// screen sizes. Supports mobile, tablet, and desktop layouts with
/// automatic selection based on screen width.
///
/// Example:
/// ```dart
/// ResponsiveLayout(
///   mobile: MobileView(),
///   tablet: TabletView(),
///   desktop: DesktopView(),
/// )
/// ```
class ResponsiveLayout extends StatelessWidget {
  /// Creates a responsive layout widget
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  });

  /// Widget to display on mobile devices
  final Widget mobile;

  /// Widget to display on tablets (falls back to mobile if null)
  final Widget? tablet;

  /// Widget to display on desktops (falls back to tablet or mobile if null)
  final Widget? desktop;

  /// Widget to display on large desktops (falls back to desktop/tablet/mobile)
  final Widget? largeDesktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ScreenSizeUtils.responsive(
          context: context,
          mobile: mobile,
          tablet: tablet,
          desktop: desktop,
          largeDesktop: largeDesktop,
        );
      },
    );
  }
}

/// Responsive builder for custom responsive logic
///
/// Provides access to screen width, device type, and other metrics
/// for building custom responsive layouts.
///
/// Example:
/// ```dart
/// ResponsiveBuilder(
///   builder: (context, deviceType, screenWidth) {
///     if (deviceType == DeviceType.mobile) {
///       return SingleColumnLayout();
///     } else {
///       return TwoColumnLayout();
///     }
///   },
/// )
/// ```
class ResponsiveBuilder extends StatelessWidget {
  /// Creates a responsive builder widget
  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  /// Builder function that receives device information
  final Widget Function(
    BuildContext context,
    DeviceType deviceType,
    double screenWidth,
  ) builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = ScreenSizeUtils.getDeviceType(context);
        final screenWidth = ScreenSizeUtils.getScreenWidth(context);
        
        return builder(context, deviceType, screenWidth);
      },
    );
  }
}

/// Responsive value builder for selecting values based on screen size
///
/// Useful for responsive padding, sizing, spacing, etc.
///
/// Example:
/// ```dart
/// Padding(
///   padding: ResponsiveValue<EdgeInsets>(
///     mobile: EdgeInsets.all(8),
///     tablet: EdgeInsets.all(16),
///     desktop: EdgeInsets.all(24),
///   ).value(context),
///   child: child,
/// )
/// ```
class ResponsiveValue<T> {
  /// Creates a responsive value
  const ResponsiveValue({
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  });

  /// Value for mobile devices
  final T mobile;

  /// Value for tablets (falls back to mobile if null)
  final T? tablet;

  /// Value for desktops (falls back to tablet or mobile if null)
  final T? desktop;

  /// Value for large desktops (falls back to desktop/tablet/mobile if null)
  final T? largeDesktop;

  /// Get the value for the current screen size
  T value(BuildContext context) {
    return ScreenSizeUtils.responsive(
      context: context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
      largeDesktop: largeDesktop,
    );
  }
}

/// Responsive padding widget
///
/// Applies different padding based on screen size.
///
/// Example:
/// ```dart
/// ResponsivePadding(
///   mobile: EdgeInsets.all(8),
///   desktop: EdgeInsets.all(24),
///   child: child,
/// )
/// ```
class ResponsivePadding extends StatelessWidget {
  /// Creates responsive padding
  const ResponsivePadding({
    super.key,
    required this.child,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  });

  /// Child widget
  final Widget child;

  /// Padding for mobile devices
  final EdgeInsets mobile;

  /// Padding for tablets
  final EdgeInsets? tablet;

  /// Padding for desktops
  final EdgeInsets? desktop;

  /// Padding for large desktops
  final EdgeInsets? largeDesktop;

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveValue(
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
      largeDesktop: largeDesktop,
    ).value(context);

    return Padding(
      padding: padding,
      child: child,
    );
  }
}

/// Responsive container with max width constraint
///
/// Centers content with a maximum width that adapts to screen size.
/// Useful for preventing content from becoming too wide on large screens.
///
/// Example:
/// ```dart
/// ResponsiveContainer(
///   child: content,
/// )
/// ```
class ResponsiveContainer extends StatelessWidget {
  /// Creates a responsive container
  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.alignment = Alignment.topCenter,
  });

  /// Child widget
  final Widget child;

  /// Optional padding
  final EdgeInsets? padding;

  /// Alignment of the child within the container
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? ScreenSizeUtils.getContentPadding(context),
      alignment: alignment,
      child: ConstrainedBox(
        constraints: ScreenSizeUtils.getContentConstraints(context),
        child: child,
      ),
    );
  }
}

/// Responsive grid layout
///
/// Creates a grid with a responsive number of columns.
///
/// Example:
/// ```dart
/// ResponsiveGrid(
///   mobileColumns: 2,
///   tabletColumns: 3,
///   desktopColumns: 4,
///   children: items,
/// )
/// ```
class ResponsiveGrid extends StatelessWidget {
  /// Creates a responsive grid
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns = 2,
    this.tabletColumns = 3,
    this.desktopColumns = 4,
    this.largeDesktopColumns = 6,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
  });

  /// Child widgets for the grid
  final List<Widget> children;

  /// Number of columns on mobile
  final int mobileColumns;

  /// Number of columns on tablet
  final int tabletColumns;

  /// Number of columns on desktop
  final int desktopColumns;

  /// Number of columns on large desktop
  final int largeDesktopColumns;

  /// Horizontal spacing between items
  final double spacing;

  /// Vertical spacing between rows
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    final columns = ScreenSizeUtils.getGridColumns(
      context,
      mobileColumns: mobileColumns,
      tabletColumns: tabletColumns,
      desktopColumns: desktopColumns,
      largeDesktopColumns: largeDesktopColumns,
    );

    return GridView.count(
      crossAxisCount: columns,
      mainAxisSpacing: runSpacing,
      crossAxisSpacing: spacing,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: children,
    );
  }
}

/// Responsive wrap layout
///
/// Creates a wrap layout with responsive spacing.
///
/// Example:
/// ```dart
/// ResponsiveWrap(
///   children: chips,
/// )
/// ```
class ResponsiveWrap extends StatelessWidget {
  /// Creates a responsive wrap
  const ResponsiveWrap({
    super.key,
    required this.children,
    this.mobileSpacing = 8.0,
    this.tabletSpacing = 12.0,
    this.desktopSpacing = 16.0,
    this.alignment = WrapAlignment.start,
    this.crossAlignment = WrapCrossAlignment.start,
  });

  /// Child widgets
  final List<Widget> children;

  /// Spacing on mobile
  final double mobileSpacing;

  /// Spacing on tablet
  final double tabletSpacing;

  /// Spacing on desktop
  final double desktopSpacing;

  /// Horizontal alignment
  final WrapAlignment alignment;

  /// Vertical alignment
  final WrapCrossAlignment crossAlignment;

  @override
  Widget build(BuildContext context) {
    final spacing = ResponsiveValue(
      mobile: mobileSpacing,
      tablet: tabletSpacing,
      desktop: desktopSpacing,
    ).value(context);

    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      alignment: alignment,
      crossAxisAlignment: crossAlignment,
      children: children,
    );
  }
}

/// Adaptive columns layout
///
/// Switches between single and multi-column layouts based on screen size.
///
/// Example:
/// ```dart
/// AdaptiveColumns(
///   children: [leftPanel, rightPanel],
/// )
/// ```
class AdaptiveColumns extends StatelessWidget {
  /// Creates an adaptive columns layout
  const AdaptiveColumns({
    super.key,
    required this.children,
    this.spacing = 16.0,
    this.breakpoint,
  });

  /// Child widgets (typically 2 for main/sidebar layout)
  final List<Widget> children;

  /// Spacing between columns
  final double spacing;

  /// Custom breakpoint (defaults to tablet breakpoint)
  final double? breakpoint;

  @override
  Widget build(BuildContext context) {
    final shouldStack = ScreenSizeUtils.getScreenWidth(context) < 
        (breakpoint ?? ScreenSizeUtils.tabletBreakpoint);

    if (shouldStack) {
      // Stack vertically on small screens
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1) SizedBox(height: spacing),
          ],
        ],
      );
    } else {
      // Display side-by-side on larger screens
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            Expanded(child: children[i]),
            if (i < children.length - 1) SizedBox(width: spacing),
          ],
        ],
      );
    }
  }
}

/// Orientation-aware layout
///
/// Provides different layouts for portrait and landscape orientations.
///
/// Example:
/// ```dart
/// OrientationLayout(
///   portrait: PortraitView(),
///   landscape: LandscapeView(),
/// )
/// ```
class OrientationLayout extends StatelessWidget {
  /// Creates an orientation-aware layout
  const OrientationLayout({
    super.key,
    required this.portrait,
    this.landscape,
  });

  /// Widget to display in portrait orientation
  final Widget portrait;

  /// Widget to display in landscape orientation (falls back to portrait)
  final Widget? landscape;

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.landscape && landscape != null) {
          return landscape!;
        }
        return portrait;
      },
    );
  }
}
