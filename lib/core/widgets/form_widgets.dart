import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

/// A titled card that groups related form fields.
class FormSection extends StatelessWidget {
  const FormSection({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
    this.subtitle,
    this.step,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final int? step;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(color: AppColors.sage, borderRadius: AppRadii.smAll),
                child: Icon(icon, color: AppColors.forest, size: 20),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (step != null)
                      Text('STEP $step', style: theme.labelSmall?.copyWith(color: AppColors.amberDark)),
                    Semantics(header: true, child: Text(title, style: theme.titleMedium)),
                    if (subtitle != null) Text(subtitle!, style: theme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.md),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// Label above an input, with an optional required marker.
class LabeledField extends StatelessWidget {
  const LabeledField({
    super.key,
    required this.label,
    required this.child,
    this.isRequired = false,
    this.trailing,
  });

  final String label;
  final Widget child;
  final bool isRequired;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelMedium;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: label,
                  children: [
                    if (isRequired)
                      const TextSpan(
                        text: ' *',
                        style: TextStyle(color: AppColors.error),
                      ),
                    if (!isRequired)
                      const TextSpan(
                        text: '  Optional',
                        style: TextStyle(color: AppColors.textTertiary, fontWeight: FontWeight.w400),
                      ),
                  ],
                ),
                style: style,
              ),
            ),
            ?trailing,
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        child,
      ],
    );
  }
}

/// Inline validation message for custom (non-TextField) inputs.
class FieldError extends StatelessWidget {
  const FieldError(this.message, {super.key});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: AppMotion.size(context, AppMotion.fast),
      alignment: Alignment.topLeft,
      child: message == null
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, size: 15, color: AppColors.error),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      message!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

/// Tappable field that looks like an input, used for pickers.
class PickerField extends StatelessWidget {
  const PickerField({
    super.key,
    required this.icon,
    required this.placeholder,
    required this.onTap,
    this.value,
    this.hasError = false,
  });

  final IconData icon;
  final String placeholder;
  final String? value;
  final VoidCallback onTap;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      label: value ?? placeholder,
      excludeSemantics: true,
      child: Material(
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.mdAll,
          side: BorderSide(color: hasError ? AppColors.error : AppColors.border),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadii.mdAll,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 15),
            child: Row(
              children: [
                Icon(icon, size: 20, color: AppColors.textSecondary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    value ?? placeholder,
                    style: theme.bodyMedium?.copyWith(
                      color: value == null ? AppColors.textTertiary : AppColors.charcoal,
                    ),
                  ),
                ),
                const Icon(Icons.expand_more_rounded, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
