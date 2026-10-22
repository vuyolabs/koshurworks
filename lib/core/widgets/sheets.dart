import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import 'app_buttons.dart';
import 'motion.dart';

/// Shows a modal bottom sheet with the app's slower, eased open and close,
/// and fades its content in just after the sheet starts rising.
///
/// Every sheet in the app goes through here so motion stays consistent.
Future<T?> showAppSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool isScrollControlled = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    useSafeArea: true,
    isScrollControlled: isScrollControlled,
    sheetAnimationStyle: AppMotion.sheetStyle(context),
    builder: (sheetContext) => FadeSlideIn(
      delay: const Duration(milliseconds: 90),
      offset: const Offset(0, 24),
      duration: const Duration(milliseconds: 460),
      child: builder(sheetContext),
    ),
  );
}

/// Shows [child] as a dialog that scales and fades in from the centre.
Future<T?> showAppDialog<T>(BuildContext context, {required Widget child}) {
  final reduced = AppMotion.reduced(context);
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black54,
    transitionDuration: reduced ? Duration.zero : AppMotion.dialog,
    pageBuilder: (_, _, _) => child,
    transitionBuilder: (context, animation, _, page) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: AppMotion.emphasized,
        reverseCurve: AppMotion.emphasizedAccelerate,
      );
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: ScaleTransition(scale: Tween(begin: 0.88, end: 1.0).animate(curved), child: page),
      );
    },
  );
}

/// Date picker shown through [showAppDialog] so it animates like other modals.
Future<DateTime?> showAppDatePicker(
  BuildContext context, {
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  String? helpText,
}) {
  return showAppDialog<DateTime>(
    context,
    child: DatePickerDialog(
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: helpText,
    ),
  );
}

/// Shows a short floating message. Used for prototype-only actions.
void showAppSnack(
  BuildContext context,
  String message, {
  IconData icon = Icons.info_outline_rounded,
  SnackBarAction? action,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: AppColors.amber, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(message)),
          ],
        ),
        action: action,
        duration: const Duration(seconds: 3),
      ),
      snackBarAnimationStyle: AppMotion.snackStyle(context),
    );
}

/// Bottom sheet asking the user to confirm an action. Resolves to true on confirm.
Future<bool> showConfirmationSheet(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  IconData icon = Icons.help_outline_rounded,
  String cancelLabel = 'Cancel',
  String? footnote,
  bool destructive = false,
}) async {
  final result = await showAppSheet<bool>(
    context,
    builder: (context) {
      final theme = Theme.of(context).textTheme;
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: destructive ? AppColors.errorSoft : AppColors.sage,
                borderRadius: AppRadii.mdAll,
              ),
              child: Icon(icon, color: destructive ? AppColors.error : AppColors.forest),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(title, style: theme.headlineSmall),
            const SizedBox(height: AppSpacing.xs),
            Text(message, style: theme.bodyLarge?.copyWith(color: AppColors.textSecondary)),
            if (footnote != null) ...[const SizedBox(height: AppSpacing.md), PrototypeNote(text: footnote)],
            const SizedBox(height: AppSpacing.xl),
            AppButton(label: confirmLabel, expand: true, onPressed: () => Navigator.of(context).pop(true)),
            const SizedBox(height: AppSpacing.xs),
            AppButton(
              label: cancelLabel,
              variant: AppButtonVariant.ghost,
              expand: true,
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      );
    },
  );
  return result ?? false;
}

/// Bottom sheet that lets the user pick one option.
Future<T?> showSelectionSheet<T>(
  BuildContext context, {
  required String title,
  required List<T> options,
  required String Function(T) labelOf,
  T? selected,
  IconData Function(T)? iconOf,
  String? subtitle,
}) {
  return showAppSheet<T>(
    context,
    builder: (context) {
      final theme = Theme.of(context).textTheme;
      return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.75),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.titleLarge),
                  if (subtitle != null) Text(subtitle, style: theme.bodySmall),
                ],
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                children: [
                  for (final (index, option) in options.indexed)
                    FadeSlideIn(
                      delay: Duration(milliseconds: 120 + 35 * index.clamp(0, 10)),
                      offset: const Offset(0, 14),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                        leading: iconOf == null ? null : Icon(iconOf(option), color: AppColors.forest),
                        title: Text(labelOf(option), style: theme.bodyLarge),
                        selected: option == selected,
                        trailing: option == selected
                            ? const Icon(Icons.check_circle_rounded, color: AppColors.forest)
                            : null,
                        onTap: () => Navigator.of(context).pop(option),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

/// Bottom sheet with a title and free-form content.
Future<void> showInfoSheet(
  BuildContext context, {
  required String title,
  required IconData icon,
  required List<Widget> children,
}) {
  return showAppSheet<void>(
    context,
    builder: (context) {
      final theme = Theme.of(context).textTheme;
      return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.85),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: AppColors.forest),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text(title, style: theme.titleLarge)),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              ...children,
            ],
          ),
        ),
      );
    },
  );
}

/// Inline note reminding that an action is prototype-only.
class PrototypeNote extends StatelessWidget {
  const PrototypeNote({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: const BoxDecoration(color: AppColors.amberSoft, borderRadius: AppRadii.mdAll),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.science_outlined, size: 18, color: AppColors.amberDark),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.amberDark),
            ),
          ),
        ],
      ),
    );
  }
}
