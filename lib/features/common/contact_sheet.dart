import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/avatars.dart';
import '../../core/widgets/sheets.dart';

/// Contact options for a hirer or worker. Prototype only: nothing is dialled
/// or sent, and no contact details are revealed.
Future<void> showPrototypeContactSheet(
  BuildContext context, {
  required String name,
  required String subtitle,
}) {
  return showAppSheet<void>(
    context,
    builder: (sheetContext) {
      final theme = Theme.of(sheetContext).textTheme;

      void choose(String message) {
        Navigator.of(sheetContext).pop();
        showAppSnack(context, message, icon: Icons.science_outlined);
      }

      return Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppAvatar(name: name, size: 52),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Contact $name', style: theme.titleLarge),
                      Text(subtitle, style: theme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _ContactOption(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'Message in KoshurWorks',
              subtitle: 'Keeps your number private',
              onTap: () => choose('Prototype only. No message was sent.'),
            ),
            const SizedBox(height: AppSpacing.xs),
            _ContactOption(
              icon: Icons.call_outlined,
              title: 'Request a call back',
              subtitle: 'Numbers are shared only after both agree',
              onTap: () => choose('Prototype only. No call was requested.'),
            ),
            const SizedBox(height: AppSpacing.md),
            const PrototypeNote(
              text:
                  'Contact details are hidden in this prototype. '
                  'Never pay anyone a fee to get work or to book a worker.',
            ),
          ],
        ),
      );
    },
  );
}

class _ContactOption extends StatelessWidget {
  const _ContactOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Material(
      color: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadii.mdAll,
        side: BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.mdAll,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Icon(icon, color: AppColors.forest),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.titleSmall),
                    Text(subtitle, style: theme.bodySmall),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}
