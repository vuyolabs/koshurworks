import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/motion.dart';
import '../../../data/models/work_category.dart';

/// Pill showing the current area, opens a picker on tap.
class LocationSelector extends StatelessWidget {
  const LocationSelector({super.key, required this.district, required this.onTap, this.onDark = false});

  final String district;
  final VoidCallback onTap;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      label: 'Location: $district, Jammu and Kashmir. Change location',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.pillAll,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.near_me_rounded, size: 18, color: AppColors.amber),
              const SizedBox(width: 6),
              Flexible(
                child: Text.rich(
                  TextSpan(
                    text: district,
                    style: theme.titleSmall?.copyWith(color: onDark ? AppColors.white : null),
                    children: [
                      TextSpan(
                        text: ', Jammu & Kashmir',
                        style: theme.bodySmall?.copyWith(
                          fontSize: 14,
                          color: onDark ? AppColors.white.withValues(alpha: 0.75) : null,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: onDark ? AppColors.white : AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Horizontal row of trade shortcuts.
class CategoryShortcuts extends StatelessWidget {
  const CategoryShortcuts({super.key, required this.categories, required this.onSelected});

  final List<WorkCategory> categories;
  final ValueChanged<WorkCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: AppSpacing.screenPadding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < categories.length; i++)
            Padding(
              padding: EdgeInsets.only(right: i == categories.length - 1 ? 0 : AppSpacing.sm),
              child: FadeSlideIn(
                delay: FadeSlideIn.stagger(i, stepMs: 40),
                offset: const Offset(36, 0),
                child: _CategoryTile(category: categories[i], onTap: () => onSelected(categories[i])),
              ),
            ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category, required this.onTap});

  final WorkCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: category.name,
      excludeSemantics: true,
      child: PressScale(
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadii.mdAll,
          child: SizedBox(
            width: 76,
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: AppRadii.lgAll,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Icon(category.icon, color: AppColors.forest, size: 28),
                ),
                const SizedBox(height: 6),
                Text(
                  category.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Dark green promotional banner with a call to action.
class PromoBanner extends StatelessWidget {
  const PromoBanner({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
    this.icon = Icons.add_circle_outline_rounded,
  });

  final String eyebrow;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Container(
      decoration: const BoxDecoration(
        borderRadius: AppRadii.xlAll,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.forest, AppColors.forestDark],
        ),
        boxShadow: AppShadows.raised,
      ),
      child: ClipRRect(
        borderRadius: AppRadii.xlAll,
        child: Stack(
          children: [
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.amber.withValues(alpha: 0.25), width: 18),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    eyebrow.toUpperCase(),
                    style: theme.labelSmall?.copyWith(color: AppColors.amber, letterSpacing: 1),
                  ),
                  const SizedBox(height: 6),
                  Text(title, style: theme.headlineSmall?.copyWith(color: AppColors.white)),
                  const SizedBox(height: 6),
                  Text(
                    message,
                    style: theme.bodyMedium?.copyWith(color: AppColors.white.withValues(alpha: 0.8)),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    label: actionLabel,
                    icon: icon,
                    variant: AppButtonVariant.accent,
                    compact: true,
                    onPressed: onAction,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
