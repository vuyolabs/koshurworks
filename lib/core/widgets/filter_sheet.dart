import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import 'app_buttons.dart';
import 'category_chip.dart';
import 'sheets.dart';

/// One group of options in the filter sheet.
@immutable
class FilterGroup {
  const FilterGroup({
    required this.id,
    required this.title,
    required this.icon,
    required this.options,
    this.multiSelect = true,
  });

  final String id;
  final String title;
  final IconData icon;
  final List<String> options;
  final bool multiSelect;
}

/// Selected option labels keyed by [FilterGroup.id].
typedef FilterSelection = Map<String, Set<String>>;

int countActiveFilters(FilterSelection selection) => selection.values.fold(0, (sum, set) => sum + set.length);

/// Shows the reusable filter sheet and resolves to the new selection,
/// or null when dismissed.
Future<FilterSelection?> showFilterSheet(
  BuildContext context, {
  required List<FilterGroup> groups,
  required FilterSelection initial,
  String title = 'Filters',
}) {
  return showAppSheet<FilterSelection>(
    context,
    builder: (_) => _FilterSheet(groups: groups, initial: initial, title: title),
  );
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.groups, required this.initial, required this.title});

  final List<FilterGroup> groups;
  final FilterSelection initial;
  final String title;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late final FilterSelection _selection = {
    for (final g in widget.groups) g.id: {...?widget.initial[g.id]},
  };
  late final Set<String> _expanded = {
    for (final g in widget.groups)
      if (g == widget.groups.first || (_selection[g.id]?.isNotEmpty ?? false)) g.id,
  };

  void _toggle(FilterGroup group, String option) {
    setState(() {
      final set = _selection[group.id] ??= {};
      if (set.contains(option)) {
        set.remove(option);
      } else {
        if (!group.multiSelect) set.clear();
        set.add(option);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final count = countActiveFilters(_selection);
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.88),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.md, AppSpacing.xs),
            child: Row(
              children: [
                Expanded(child: Text(widget.title, style: theme.headlineSmall)),
                TextButton(
                  onPressed: count == 0
                      ? null
                      : () => setState(() {
                          for (final s in _selection.values) {
                            s.clear();
                          }
                        }),
                  child: const Text('Reset all'),
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              itemCount: widget.groups.length,
              separatorBuilder: (_, _) => const Divider(),
              itemBuilder: (context, i) {
                final group = widget.groups[i];
                return _GroupSection(
                  group: group,
                  selected: _selection[group.id] ?? const {},
                  expanded: _expanded.contains(group.id),
                  onHeaderTap: () => setState(() {
                    if (!_expanded.remove(group.id)) _expanded.add(group.id);
                  }),
                  onToggle: (option) => _toggle(group, option),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, AppSpacing.md),
              child: AppButton(
                label: count == 0 ? 'Show all results' : 'Apply $count filter${count == 1 ? '' : 's'}',
                expand: true,
                onPressed: () => Navigator.of(context).pop(_selection),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupSection extends StatelessWidget {
  const _GroupSection({
    required this.group,
    required this.selected,
    required this.expanded,
    required this.onHeaderTap,
    required this.onToggle,
  });

  final FilterGroup group;
  final Set<String> selected;
  final bool expanded;
  final VoidCallback onHeaderTap;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final duration = AppMotion.of(context, AppMotion.medium);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          button: true,
          expanded: expanded,
          child: InkWell(
            onTap: onHeaderTap,
            borderRadius: AppRadii.smAll,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Row(
                children: [
                  Icon(group.icon, size: 20, color: AppColors.forest),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text(group.title, style: theme.titleMedium)),
                  if (selected.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.xs),
                      child: Text(
                        '${selected.length} selected',
                        style: theme.labelSmall?.copyWith(color: AppColors.amberDark),
                      ),
                    ),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: duration,
                    child: const Icon(Icons.expand_more_rounded),
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: AppMotion.size(context, duration),
          curve: AppMotion.curve,
          alignment: Alignment.topCenter,
          child: expanded
              ? Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      for (final option in group.options)
                        CategoryChip(
                          label: option,
                          selected: selected.contains(option),
                          onTap: () => onToggle(option),
                        ),
                    ],
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}
