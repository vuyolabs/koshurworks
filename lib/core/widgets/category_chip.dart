import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import 'motion.dart';

/// Selectable pill with an animated selected state.
class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.onRemove,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  /// When set, shows a close icon (used for active filter chips).
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final duration = AppMotion.of(context, AppMotion.medium);
    final fg = selected ? AppColors.white : AppColors.charcoal;
    final text = Theme.of(context).textTheme.labelMedium;

    return Semantics(
      selected: selected,
      button: true,
      child: PressScale(
        scale: 0.94,
        child: AnimatedContainer(
          duration: duration,
          curve: AppMotion.curve,
          decoration: BoxDecoration(
            color: selected ? AppColors.forest : AppColors.white,
            borderRadius: AppRadii.pillAll,
            border: Border.all(color: selected ? AppColors.forest : AppColors.border),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: AppRadii.pillAll,
              onTap: onRemove ?? onTap,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 40),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: 17, color: selected ? AppColors.amber : AppColors.forest),
                        const SizedBox(width: 6),
                      ],
                      AnimatedDefaultTextStyle(
                        duration: duration,
                        style: (text ?? const TextStyle()).copyWith(color: fg),
                        child: Text(label),
                      ),
                      if (onRemove != null) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.close_rounded, size: 16, color: fg),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Horizontally scrolling row of chips with screen-edge padding.
class ChipRow extends StatelessWidget {
  const ChipRow({super.key, required this.children, this.padding = AppSpacing.screenPadding});

  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding,
      child: Row(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.xs),
            children[i],
          ],
        ],
      ),
    );
  }
}
