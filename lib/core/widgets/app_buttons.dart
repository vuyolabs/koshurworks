import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import 'motion.dart';

enum AppButtonVariant { primary, secondary, accent, ghost }

/// The single button component for the app.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.expand = false,
    this.loading = false,
    this.compact = false,
  });

  const AppButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = false,
    this.loading = false,
    this.compact = false,
  }) : variant = AppButtonVariant.secondary;

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonVariant variant;
  final bool expand;
  final bool loading;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final height = compact ? 44.0 : 54.0;
    final padding = EdgeInsets.symmetric(horizontal: compact || expand ? AppSpacing.sm : AppSpacing.xl);

    final content = AnimatedSwitcher(
      duration: AppMotion.of(context, AppMotion.fast),
      child: loading
          ? SizedBox.square(
              key: const ValueKey('loading'),
              dimension: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: variant == AppButtonVariant.primary ? AppColors.white : AppColors.forest,
              ),
            )
          : Row(
              key: const ValueKey('label'),
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: AppSpacing.xs)],
                Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
              ],
            ),
    );

    final onTap = loading ? null : onPressed;
    final size = WidgetStatePropertyAll(Size(expand ? double.infinity : 48, height));
    final pad = WidgetStatePropertyAll(padding);

    final Widget button = switch (variant) {
      AppButtonVariant.primary => FilledButton(
        onPressed: onTap,
        style: ButtonStyle(minimumSize: size, padding: pad),
        child: content,
      ),
      AppButtonVariant.accent => FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.amber,
          foregroundColor: AppColors.charcoal,
        ).copyWith(minimumSize: size, padding: pad),
        child: content,
      ),
      AppButtonVariant.secondary => OutlinedButton(
        onPressed: onTap,
        style: ButtonStyle(minimumSize: size, padding: pad),
        child: content,
      ),
      AppButtonVariant.ghost => TextButton(
        onPressed: onTap,
        style: ButtonStyle(minimumSize: size, padding: pad),
        child: content,
      ),
    };

    final pressable = PressScale(enabled: onTap != null, scale: 0.96, child: button);
    return expand ? SizedBox(width: double.infinity, child: pressable) : pressable;
  }
}

/// Round icon button with a soft surface, used in headers.
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.badgeCount = 0,
    this.background = AppColors.white,
    this.foreground = AppColors.charcoal,
    this.borderColor = AppColors.border,
  });

  /// Variant for use on the forest-green app bar.
  const CircleIconButton.onDark({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.badgeCount = 0,
  }) : background = const Color(0x1FFFFFFF),
       foreground = AppColors.white,
       borderColor = const Color(0x33FFFFFF);

  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;
  final int badgeCount;
  final Color background;
  final Color foreground;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: PressScale(
        scale: 0.9,
        child: Material(
          color: background,
          shape: CircleBorder(side: BorderSide(color: borderColor)),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: SizedBox.square(
              dimension: 44,
              child: Badge(
                isLabelVisible: badgeCount > 0,
                backgroundColor: AppColors.amber,
                textColor: AppColors.charcoal,
                offset: const Offset(-6, 6),
                label: AnimatedSwitcher(
                  duration: AppMotion.of(context, AppMotion.medium),
                  transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                  child: Text('$badgeCount', key: ValueKey(badgeCount)),
                ),
                child: Center(child: Icon(icon, size: 21, color: foreground)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
