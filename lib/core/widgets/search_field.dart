import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

/// Rounded search input with an optional filter button and active-filter count.
class AppSearchField extends StatefulWidget {
  const AppSearchField({
    super.key,
    required this.hintText,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onFilterPressed,
    this.activeFilterCount = 0,
  });

  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onFilterPressed;
  final int activeFilterCount;

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  TextEditingController? _owned;
  TextEditingController get _controller => widget.controller ?? (_owned ??= TextEditingController());

  @override
  void dispose() {
    _owned?.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (context, value, _) => TextField(
              controller: _controller,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: widget.hintText,
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                suffixIcon: AnimatedScale(
                  scale: value.text.isEmpty ? 0 : 1,
                  duration: AppMotion.of(context, AppMotion.medium),
                  curve: value.text.isEmpty ? Curves.easeIn : Curves.easeOutBack,
                  child: IgnorePointer(
                    ignoring: value.text.isEmpty,
                    child: IconButton(
                      tooltip: 'Clear search',
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: _clear,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (widget.onFilterPressed != null) ...[
          const SizedBox(width: AppSpacing.xs),
          _FilterButton(onPressed: widget.onFilterPressed!, count: widget.activeFilterCount),
        ],
      ],
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.onPressed, required this.count});

  final VoidCallback onPressed;
  final int count;

  @override
  Widget build(BuildContext context) {
    final active = count > 0;
    return Tooltip(
      message: 'Filters',
      child: Material(
        color: active ? AppColors.amber : AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.mdAll,
          side: BorderSide(color: active ? AppColors.amber : AppColors.border),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: AppRadii.mdAll,
          child: SizedBox.square(
            dimension: 52,
            child: Badge(
              isLabelVisible: active,
              backgroundColor: AppColors.forestDark,
              textColor: AppColors.white,
              offset: const Offset(-8, 8),
              label: Text('$count'),
              child: Center(child: Icon(Icons.tune_rounded, color: AppColors.charcoal)),
            ),
          ),
        ),
      ),
    );
  }
}
