import 'package:flutter/material.dart';

/// Central colour tokens for KoshurWorks.
///
/// These are initial design tokens, not final brand decisions. Replace the
/// values here once the official visual identity is ready; widgets read
/// colours from this class or from the generated [ColorScheme].
abstract final class AppColors {
  // Brand
  static const forest = Color(0xFF174D3B);
  static const forestDark = Color(0xFF0F3A2C);
  static const forestSoft = Color(0xFF2E6B55);
  static const amber = Color(0xFFD69B45);
  static const amberSoft = Color(0xFFF6E8D1);
  static const amberDark = Color(0xFF8F6020);

  // Surfaces
  static const offWhite = Color(0xFFF7F6F0);
  static const white = Color(0xFFFFFFFF);
  static const sage = Color(0xFFE4EDE6);
  static const sageDeep = Color(0xFFCADBCF);

  // Text
  static const charcoal = Color(0xFF202722);
  static const textSecondary = Color(0xFF5F6862);
  static const textTertiary = Color(0xFF858D87);

  // Lines
  static const border = Color(0xFFE2E2D8);
  static const borderStrong = Color(0xFFCFCFC3);

  // Status
  static const success = Color(0xFF2F7D4F);
  static const successSoft = Color(0xFFE1F0E6);
  static const warning = Color(0xFFA86E17);
  static const warningSoft = Color(0xFFFBEFD9);
  static const error = Color(0xFFB3412E);
  static const errorSoft = Color(0xFFF8E3DF);
  static const neutralSoft = Color(0xFFEDEDE6);

  /// Muted tones used for avatar and image placeholder backgrounds.
  static const avatarTones = <Color>[
    Color(0xFFDCE8E0),
    Color(0xFFF3E4CC),
    Color(0xFFE2E6EE),
    Color(0xFFEFDEDA),
    Color(0xFFE6E2D3),
    Color(0xFFDDE7EA),
  ];
}
