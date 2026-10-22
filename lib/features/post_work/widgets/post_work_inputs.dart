import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';

/// Selectable card with icon, title and description.
class ChoiceCard extends StatelessWidget {
  const ChoiceCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final duration = AppMotion.of(context, AppMotion.medium);
    return Semantics(
      selected: selected,
      button: true,
      label: '$title. $description',
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: duration,
        curve: AppMotion.curve,
        decoration: BoxDecoration(
          color: selected ? AppColors.sage : AppColors.white,
          borderRadius: AppRadii.mdAll,
          border: Border.all(
            color: selected ? AppColors.forest : AppColors.border,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: AppRadii.mdAll,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, size: 20, color: AppColors.forest),
                      const Spacer(),
                      AnimatedOpacity(
                        opacity: selected ? 1 : 0,
                        duration: duration,
                        child: const Icon(Icons.check_circle_rounded, size: 18, color: AppColors.forest),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(title, style: theme.titleSmall),
                  Text(description, style: theme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Minus / count / plus control.
class CountStepper extends StatelessWidget {
  const CountStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 50,
    this.unit = 'people',
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    Widget button(IconData icon, String tooltip, int next, bool enabled) => IconButton.filledTonal(
      tooltip: tooltip,
      onPressed: enabled ? () => onChanged(next) : null,
      style: IconButton.styleFrom(
        backgroundColor: AppColors.sage,
        foregroundColor: AppColors.forest,
        minimumSize: const Size(48, 48),
      ),
      icon: Icon(icon),
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadii.mdAll,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          button(Icons.remove_rounded, 'Fewer', value - 1, value > min),
          Expanded(
            child: Semantics(
              liveRegion: true,
              child: Column(
                children: [
                  AnimatedSwitcher(
                    duration: AppMotion.of(context, AppMotion.fast),
                    transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
                    child: Text('$value', key: ValueKey(value), style: theme.headlineSmall),
                  ),
                  Text(
                    value == 1 ? unit.replaceAll(RegExp(r'people$'), 'person') : unit,
                    style: theme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          button(Icons.add_rounded, 'More', value + 1, value < max),
        ],
      ),
    );
  }
}
