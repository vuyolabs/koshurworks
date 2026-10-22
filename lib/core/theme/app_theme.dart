import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_tokens.dart';
import 'app_typography.dart';

/// Material 3 foundations customised with KoshurWorks tokens.
abstract final class AppTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(seedColor: AppColors.forest).copyWith(
      primary: AppColors.forest,
      onPrimary: AppColors.white,
      primaryContainer: AppColors.sage,
      onPrimaryContainer: AppColors.forestDark,
      secondary: AppColors.amber,
      onSecondary: AppColors.charcoal,
      secondaryContainer: AppColors.amberSoft,
      onSecondaryContainer: AppColors.amberDark,
      surface: AppColors.offWhite,
      onSurface: AppColors.charcoal,
      onSurfaceVariant: AppColors.textSecondary,
      surfaceContainerLowest: AppColors.white,
      surfaceContainerLow: AppColors.white,
      surfaceContainer: AppColors.white,
      surfaceContainerHigh: AppColors.white,
      surfaceContainerHighest: AppColors.neutralSoft,
      outline: AppColors.borderStrong,
      outlineVariant: AppColors.border,
      error: AppColors.error,
    );

    final text = AppTypography.textTheme;

    const fieldBorder = OutlineInputBorder(
      borderRadius: AppRadii.mdAll,
      borderSide: BorderSide(color: AppColors.border),
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: AppTypography.fontFamily,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.offWhite,
      textTheme: text,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.forest,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.white,
        iconTheme: const IconThemeData(color: AppColors.white),
        actionsIconTheme: const IconThemeData(color: AppColors.white),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge?.copyWith(color: AppColors.white),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1, space: 1),
      iconTheme: const IconThemeData(color: AppColors.charcoal, size: 22),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.forest,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.neutralSoft,
          minimumSize: const Size(48, 54),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.mdAll),
          textStyle: text.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.forest,
          backgroundColor: AppColors.white,
          minimumSize: const Size(48, 54),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          side: const BorderSide(color: AppColors.borderStrong),
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.mdAll),
          textStyle: text.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.forest,
          textStyle: text.labelMedium,
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.smAll),
        ),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 15),
        hintStyle: text.bodyMedium?.copyWith(color: AppColors.textTertiary),
        helperStyle: text.bodySmall,
        helperMaxLines: 2,
        errorMaxLines: 2,
        errorStyle: text.bodySmall?.copyWith(color: AppColors.error),
        border: fieldBorder,
        enabledBorder: fieldBorder,
        focusedBorder: fieldBorder.copyWith(
          borderSide: const BorderSide(color: AppColors.forest, width: 1.6),
        ),
        errorBorder: fieldBorder.copyWith(borderSide: const BorderSide(color: AppColors.error)),
        focusedErrorBorder: fieldBorder.copyWith(
          borderSide: const BorderSide(color: AppColors.error, width: 1.6),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.offWhite,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: AppColors.borderStrong,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl))),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.offWhite,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.lgAll),
        titleTextStyle: text.titleLarge,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.charcoal,
        contentTextStyle: text.bodyMedium?.copyWith(color: AppColors.white),
        actionTextColor: AppColors.amber,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.mdAll),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? AppColors.white : AppColors.textTertiary,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? AppColors.forest : AppColors.neutralSoft,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? AppColors.forest : AppColors.borderStrong,
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? AppColors.forest : AppColors.white,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? AppColors.white : AppColors.charcoal,
          ),
          iconColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? AppColors.white : AppColors.charcoal,
          ),
          side: const WidgetStatePropertyAll(BorderSide(color: AppColors.border)),
          textStyle: WidgetStatePropertyAll(text.labelMedium),
          minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.forest),
      datePickerTheme: const DatePickerThemeData(
        backgroundColor: AppColors.offWhite,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}
