import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import 'app_buttons.dart';
import 'motion.dart';

/// Friendly empty or error message with an optional action.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.isError = false,
  });

  const EmptyState.error({
    super.key,
    this.title = 'Something went wrong',
    this.message = 'We could not load this right now. Please try again.',
    this.actionLabel = 'Try again',
    this.onAction,
  }) : icon = Icons.cloud_off_rounded,
       isError = true;

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final tint = isError ? AppColors.errorSoft : AppColors.sage;
    final iconColor = isError ? AppColors.error : AppColors.forest;

    return FadeSlideIn(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
                ),
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    boxShadow: AppShadows.soft,
                  ),
                  child: Icon(icon, size: 34, color: iconColor),
                ),
                const Positioned(
                  top: 10,
                  right: 12,
                  child: Icon(Icons.auto_awesome, size: 16, color: AppColors.amber),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(title, style: theme.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              style: theme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AppButton.secondary(label: actionLabel!, onPressed: onAction, compact: true),
            ],
          ],
        ),
      ),
    );
  }
}
