import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Type scale tuned for readability on budget Android phones:
/// comfortable body sizes, strong heading weights and generous line height.
abstract final class AppTypography {
  /// Roboto is Android's system font; naming it keeps text consistent everywhere.
  static const fontFamily = 'Roboto';

  static const _base = TextStyle(
    fontFamily: fontFamily,
    color: AppColors.charcoal,
    letterSpacing: 0,
    height: 1.35,
  );

  static final textTheme = TextTheme(
    displaySmall: _base.copyWith(
      fontSize: 34,
      fontWeight: FontWeight.w800,
      height: 1.12,
      letterSpacing: -0.6,
    ),
    headlineMedium: _base.copyWith(
      fontSize: 28,
      fontWeight: FontWeight.w800,
      height: 1.15,
      letterSpacing: -0.4,
    ),
    headlineSmall: _base.copyWith(
      fontSize: 23,
      fontWeight: FontWeight.w700,
      height: 1.2,
      letterSpacing: -0.2,
    ),
    titleLarge: _base.copyWith(fontSize: 19, fontWeight: FontWeight.w700, height: 1.25),
    titleMedium: _base.copyWith(fontSize: 16, fontWeight: FontWeight.w700, height: 1.3),
    titleSmall: _base.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
    bodyLarge: _base.copyWith(fontSize: 16, height: 1.5),
    bodyMedium: _base.copyWith(fontSize: 14.5, height: 1.45),
    bodySmall: _base.copyWith(fontSize: 12.5, color: AppColors.textSecondary),
    labelLarge: _base.copyWith(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.1),
    labelMedium: _base.copyWith(fontSize: 13, fontWeight: FontWeight.w600),
    labelSmall: _base.copyWith(fontSize: 11.5, fontWeight: FontWeight.w600, letterSpacing: 0.2),
  );
}
