import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

/// Area under a primary app bar, typically holding a search field.
class HeaderBottom extends StatelessWidget implements PreferredSizeWidget {
  const HeaderBottom({super.key, required this.child, this.height = 72});

  final Widget child;
  final double height;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 0, AppSpacing.screen, AppSpacing.md),
      child: Align(alignment: Alignment.bottomCenter, child: child),
    );
  }
}

/// Two-line app bar title: a heading with a muted subtitle.
class HeaderTitle extends StatelessWidget {
  const HeaderTitle({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          header: true,
          child: Text(title, style: theme.headlineSmall?.copyWith(color: AppColors.white)),
        ),
        if (subtitle != null)
          Text(
            subtitle!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.bodySmall?.copyWith(color: AppColors.white.withValues(alpha: 0.75)),
          ),
      ],
    );
  }
}
