import 'package:flutter/material.dart';

/// Spacing scale in logical pixels.
abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  /// Horizontal padding shared by every screen.
  static const double screen = 20;
  static const screenPadding = EdgeInsets.symmetric(horizontal: screen);
}

/// Corner radii.
abstract final class AppRadii {
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 20;
  static const double xl = 28;
  static const double pill = 999;

  static const smAll = BorderRadius.all(Radius.circular(sm));
  static const mdAll = BorderRadius.all(Radius.circular(md));
  static const lgAll = BorderRadius.all(Radius.circular(lg));
  static const xlAll = BorderRadius.all(Radius.circular(xl));
  static const pillAll = BorderRadius.all(Radius.circular(pill));
}

/// Restrained elevation tokens.
abstract final class AppShadows {
  static const soft = <BoxShadow>[BoxShadow(color: Color(0x0F1B2A22), blurRadius: 16, offset: Offset(0, 6))];
  static const raised = <BoxShadow>[
    BoxShadow(color: Color(0x2E174D3B), blurRadius: 22, offset: Offset(0, 10)),
  ];
}

/// Motion tokens. Use [AppMotion.of] so reduced-motion settings are honoured.
abstract final class AppMotion {
  static const fast = Duration(milliseconds: 150);
  static const medium = Duration(milliseconds: 260);
  static const slow = Duration(milliseconds: 420);
  static const curve = Curves.easeOutCubic;

  /// Material 3 "emphasized" curves: quick start, long gentle settle.
  static const emphasized = Cubic(0.05, 0.7, 0.1, 1.0);
  static const emphasizedAccelerate = Cubic(0.3, 0.0, 0.8, 0.15);

  /// Screen transitions.
  static const page = Duration(milliseconds: 520);
  static const pageReverse = Duration(milliseconds: 380);

  /// Bottom sheets and dialogs.
  static const sheet = Duration(milliseconds: 480);
  static const sheetReverse = Duration(milliseconds: 320);
  static const dialog = Duration(milliseconds: 420);

  /// Animation style for modal bottom sheets, or none with reduced motion.
  static AnimationStyle sheetStyle(BuildContext context) => reduced(context)
      ? AnimationStyle.noAnimation
      : const AnimationStyle(
          duration: sheet,
          reverseDuration: sheetReverse,
          curve: emphasized,
          reverseCurve: emphasizedAccelerate,
        );

  /// Animation style for snack bars.
  static AnimationStyle snackStyle(BuildContext context) => reduced(context)
      ? AnimationStyle.noAnimation
      : const AnimationStyle(
          duration: Duration(milliseconds: 420),
          reverseDuration: Duration(milliseconds: 280),
        );

  static bool reduced(BuildContext context) => MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  /// Like [of] but never zero. Size animations cannot use a zero duration,
  /// so reduced motion gets a 1ms step that still looks instant.
  static Duration size(BuildContext context, Duration duration) =>
      reduced(context) ? const Duration(milliseconds: 1) : duration;

  /// Returns [duration], or zero when the user prefers reduced motion.
  static Duration of(BuildContext context, Duration duration) => reduced(context) ? Duration.zero : duration;
}

/// Breakpoints for adapting layouts to larger Android screens.
abstract final class AppBreakpoints {
  static const double compact = 360;
  static const double medium = 600;

  /// Max content width on tablets, foldables and landscape.
  static const double contentMaxWidth = 720;
}
