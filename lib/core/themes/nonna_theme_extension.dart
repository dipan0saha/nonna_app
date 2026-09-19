import 'package:flutter/material.dart';

import 'colors.dart';

/// Brand tints and onboarding palette exposed on [ThemeData].
@immutable
class NonnaThemeExtension extends ThemeExtension<NonnaThemeExtension> {
  const NonnaThemeExtension({
    required this.sage,
    required this.sageDark,
    required this.sageTint,
    required this.peach,
    required this.peachDark,
    required this.peachTint,
    required this.muted,
    required this.primaryButtonForeground,
    required this.success,
    required this.warning,
    required this.info,
    required this.error,
  });

  final Color sage;
  final Color sageDark;
  final Color sageTint;
  final Color peach;
  final Color peachDark;
  final Color peachTint;
  final Color muted;
  final Color primaryButtonForeground;
  final Color success;
  final Color warning;
  final Color info;
  final Color error;

  static const NonnaThemeExtension light = NonnaThemeExtension(
    sage: AppColors.primary,
    sageDark: AppColors.primaryDark,
    sageTint: AppColors.sageTint,
    peach: AppColors.secondary,
    peachDark: AppColors.secondaryDark,
    peachTint: AppColors.peachTint,
    muted: AppColors.muted,
    primaryButtonForeground: AppColors.primaryButtonForeground,
    success: AppColors.success,
    warning: AppColors.warning,
    info: AppColors.info,
    error: AppColors.error,
  );

  @override
  NonnaThemeExtension copyWith({
    Color? sage,
    Color? sageDark,
    Color? sageTint,
    Color? peach,
    Color? peachDark,
    Color? peachTint,
    Color? muted,
    Color? primaryButtonForeground,
    Color? success,
    Color? warning,
    Color? info,
    Color? error,
  }) {
    return NonnaThemeExtension(
      sage: sage ?? this.sage,
      sageDark: sageDark ?? this.sageDark,
      sageTint: sageTint ?? this.sageTint,
      peach: peach ?? this.peach,
      peachDark: peachDark ?? this.peachDark,
      peachTint: peachTint ?? this.peachTint,
      muted: muted ?? this.muted,
      primaryButtonForeground:
          primaryButtonForeground ?? this.primaryButtonForeground,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      error: error ?? this.error,
    );
  }

  @override
  NonnaThemeExtension lerp(
      ThemeExtension<NonnaThemeExtension>? other, double t) {
    if (other is! NonnaThemeExtension) return this;
    return NonnaThemeExtension(
      sage: Color.lerp(sage, other.sage, t)!,
      sageDark: Color.lerp(sageDark, other.sageDark, t)!,
      sageTint: Color.lerp(sageTint, other.sageTint, t)!,
      peach: Color.lerp(peach, other.peach, t)!,
      peachDark: Color.lerp(peachDark, other.peachDark, t)!,
      peachTint: Color.lerp(peachTint, other.peachTint, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      primaryButtonForeground: Color.lerp(
          primaryButtonForeground, other.primaryButtonForeground, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      error: Color.lerp(error, other.error, t)!,
    );
  }
}

extension NonnaThemeContext on BuildContext {
  NonnaThemeExtension get nonnaTheme =>
      Theme.of(this).extension<NonnaThemeExtension>() ??
      NonnaThemeExtension.light;
}
