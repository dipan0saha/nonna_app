import 'package:flutter/material.dart';

/// Screen size utilities for responsive design
///
/// Provides:
/// - Device type detection (mobile, tablet, desktop)
/// - Breakpoint constants
/// - Orientation helpers
/// - Safe area calculations
/// - Responsive value selection
///
/// Follows common breakpoint conventions:
/// - Mobile: < 600dp
/// - Tablet: 600dp - 1024dp
/// - Desktop: >= 1024dp
class ScreenSizeUtils {
  // Prevent instantiation
  ScreenSizeUtils._();

  // ============================================================
  // Breakpoint Constants
  // ============================================================

  /// Mobile breakpoint (phones)
  /// Screens smaller than this are considered mobile
  static const double mobileBreakpoint = 600.0;

  /// Tablet breakpoint
  /// Screens between mobile and desktop breakpoints are tablets
  static const double tabletBreakpoint = 1024.0;

  /// Desktop breakpoint
  /// Screens larger than this are considered desktop
  static const double desktopBreakpoint = 1440.0;

  /// Large desktop breakpoint
  /// Very large screens (4K monitors, etc.)
  static const double largeDesktopBreakpoint = 1920.0;

  // ============================================================
  // Screen Width Helpers
  // ============================================================

  /// Get the screen width from context
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get the screen height from context
  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Get the smaller dimension (width or height)
  static double getSmallerDimension(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width < size.height ? size.width : size.height;
  }

  /// Get the larger dimension (width or height)
  static double getLargerDimension(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width > size.height ? size.width : size.height;
  }

  // ============================================================
  // Device Type Detection
  // ============================================================

  /// Check if the current device is mobile
  static bool isMobile(BuildContext context) {
    return getScreenWidth(context) < mobileBreakpoint;
  }

  /// Check if the current device is tablet
  static bool isTablet(BuildContext context) {
    final width = getScreenWidth(context);
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  /// Check if the current device is desktop
  static bool isDesktop(BuildContext context) {
    return getScreenWidth(context) >= tabletBreakpoint;
  }

  /// Check if the current device is a large desktop
  static bool isLargeDesktop(BuildContext context) {
    return getScreenWidth(context) >= largeDesktopBreakpoint;
  }

  /// Check if the current device is mobile or tablet (not desktop)
  static bool isMobileOrTablet(BuildContext context) {
    return getScreenWidth(context) < tabletBreakpoint;
  }

  /// Check if the current device is tablet or desktop (not mobile)
  static bool isTabletOrDesktop(BuildContext context) {
    return getScreenWidth(context) >= mobileBreakpoint;
  }

  // ============================================================
  // Device Type Enum
  // ============================================================

  /// Get the current device type
  static DeviceType getDeviceType(BuildContext context) {
    final width = getScreenWidth(context);
    
    if (width >= largeDesktopBreakpoint) {
      return DeviceType.largeDesktop;
    } else if (width >= tabletBreakpoint) {
      return DeviceType.desktop;
    } else if (width >= mobileBreakpoint) {
      return DeviceType.tablet;
    } else {
      return DeviceType.mobile;
    }
  }

  // ============================================================
  // Orientation Helpers
  // ============================================================

  /// Check if the device is in portrait orientation
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// Check if the device is in landscape orientation
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Get the current orientation
  static Orientation getOrientation(BuildContext context) {
    return MediaQuery.of(context).orientation;
  }

  // ============================================================
  // Safe Area Calculations
  // ============================================================

  /// Get the top safe area padding (status bar)
  static double getTopPadding(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }

  /// Get the bottom safe area padding (navigation bar, home indicator)
  static double getBottomPadding(BuildContext context) {
    return MediaQuery.of(context).padding.bottom;
  }

  /// Get the left safe area padding
  static double getLeftPadding(BuildContext context) {
    return MediaQuery.of(context).padding.left;
  }

  /// Get the right safe area padding
  static double getRightPadding(BuildContext context) {
    return MediaQuery.of(context).padding.right;
  }

  /// Get all safe area paddings
  static EdgeInsets getSafePadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Get the safe area insets
  static EdgeInsets getViewInsets(BuildContext context) {
    return MediaQuery.of(context).viewInsets;
  }

  // ============================================================
  // Responsive Value Selection
  // ============================================================

  /// Select a value based on device type
  /// 
  /// Provides different values for mobile, tablet, and desktop devices.
  /// If tablet or desktop values are not provided, falls back to mobile value.
  static T responsive<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
    T? largeDesktop,
  }) {
    final deviceType = getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
      case DeviceType.largeDesktop:
        return largeDesktop ?? desktop ?? tablet ?? mobile;
    }
  }

  /// Select a value based on screen width breakpoints
  /// 
  /// Similar to responsive() but allows custom breakpoint thresholds.
  static T responsiveValue<T>({
    required BuildContext context,
    required T defaultValue,
    T? small,
    T? medium,
    T? large,
    T? extraLarge,
    double? smallBreakpoint,
    double? mediumBreakpoint,
    double? largeBreakpoint,
    double? extraLargeBreakpoint,
  }) {
    final width = getScreenWidth(context);
    
    // Use provided breakpoints or defaults
    final smallBp = smallBreakpoint ?? mobileBreakpoint;
    final mediumBp = mediumBreakpoint ?? tabletBreakpoint;
    final largeBp = largeBreakpoint ?? desktopBreakpoint;
    final extraLargeBp = extraLargeBreakpoint ?? largeDesktopBreakpoint;
    
    if (extraLarge != null && width >= extraLargeBp) {
      return extraLarge;
    } else if (large != null && width >= largeBp) {
      return large;
    } else if (medium != null && width >= mediumBp) {
      return medium;
    } else if (small != null && width >= smallBp) {
      return small;
    }
    
    return defaultValue;
  }

  // ============================================================
  // Grid Column Calculations
  // ============================================================

  /// Get the recommended number of columns for a grid layout
  static int getGridColumns(BuildContext context, {
    int mobileColumns = 2,
    int tabletColumns = 3,
    int desktopColumns = 4,
    int largeDesktopColumns = 6,
  }) {
    return responsive(
      context: context,
      mobile: mobileColumns,
      tablet: tabletColumns,
      desktop: desktopColumns,
      largeDesktop: largeDesktopColumns,
    );
  }

  /// Calculate optimal column count based on item width
  /// 
  /// Automatically determines how many columns can fit given a
  /// desired item width and spacing.
  static int calculateColumns(
    BuildContext context, {
    required double itemWidth,
    double spacing = 16.0,
    double horizontalPadding = 32.0,
  }) {
    final screenWidth = getScreenWidth(context);
    final availableWidth = screenWidth - horizontalPadding;
    
    // Calculate how many items fit with spacing
    final columns = ((availableWidth + spacing) / (itemWidth + spacing)).floor();
    
    // Ensure at least 1 column
    return columns < 1 ? 1 : columns;
  }

  // ============================================================
  // Padding & Spacing Helpers
  // ============================================================

  /// Get responsive horizontal padding
  static double getHorizontalPadding(BuildContext context) {
    return responsive(
      context: context,
      mobile: 16.0,
      tablet: 24.0,
      desktop: 32.0,
      largeDesktop: 48.0,
    );
  }

  /// Get responsive vertical padding
  static double getVerticalPadding(BuildContext context) {
    return responsive(
      context: context,
      mobile: 16.0,
      tablet: 20.0,
      desktop: 24.0,
      largeDesktop: 32.0,
    );
  }

  /// Get responsive content padding
  static EdgeInsets getContentPadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: getHorizontalPadding(context),
      vertical: getVerticalPadding(context),
    );
  }

  /// Get responsive spacing between items
  static double getSpacing(BuildContext context) {
    return responsive(
      context: context,
      mobile: 12.0,
      tablet: 16.0,
      desktop: 20.0,
      largeDesktop: 24.0,
    );
  }

  // ============================================================
  // Content Width Constraints
  // ============================================================

  /// Get maximum content width for centered layouts
  /// 
  /// Prevents content from becoming too wide on large screens.
  static double getMaxContentWidth(BuildContext context) {
    return responsive(
      context: context,
      mobile: double.infinity,
      tablet: 768.0,
      desktop: 1200.0,
      largeDesktop: 1400.0,
    );
  }

  /// Get a constrained width for content
  /// 
  /// Useful for creating centered, max-width containers.
  static BoxConstraints getContentConstraints(BuildContext context) {
    return BoxConstraints(
      maxWidth: getMaxContentWidth(context),
    );
  }

  // ============================================================
  // Pixel Density
  // ============================================================

  /// Get the device pixel ratio
  static double getDevicePixelRatio(BuildContext context) {
    return MediaQuery.of(context).devicePixelRatio;
  }

  /// Check if the device has a high pixel density (Retina, etc.)
  static bool isHighDensity(BuildContext context) {
    return getDevicePixelRatio(context) >= 2.0;
  }

  // ============================================================
  // Utility Methods
  // ============================================================

  /// Get percentage of screen width
  static double percentWidth(BuildContext context, double percent) {
    return getScreenWidth(context) * (percent / 100);
  }

  /// Get percentage of screen height
  static double percentHeight(BuildContext context, double percent) {
    return getScreenHeight(context) * (percent / 100);
  }

  /// Check if screen is small (narrow)
  static bool isSmallScreen(BuildContext context) {
    return getScreenWidth(context) < mobileBreakpoint;
  }

  /// Check if screen is medium
  static bool isMediumScreen(BuildContext context) {
    final width = getScreenWidth(context);
    return width >= mobileBreakpoint && width < desktopBreakpoint;
  }

  /// Check if screen is large
  static bool isLargeScreen(BuildContext context) {
    return getScreenWidth(context) >= desktopBreakpoint;
  }
}

/// Device type enumeration
enum DeviceType {
  /// Mobile phone (< 600dp)
  mobile,
  
  /// Tablet (600dp - 1024dp)
  tablet,
  
  /// Desktop (1024dp - 1920dp)
  desktop,
  
  /// Large desktop (>= 1920dp)
  largeDesktop,
}
