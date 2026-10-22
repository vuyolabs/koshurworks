import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/form_widgets.dart';
import '../../../core/widgets/sheets.dart';
import '../../../data/models/worker_profile.dart';

/// Edits a few profile fields and returns the updated profile.
/// Changes are kept in memory only.
Future<WorkerProfile?> showEditProfileSheet(BuildContext context, WorkerProfile profile) {
  return showAppSheet<WorkerProfile>(context, builder: (_) => _EditProfileSheet(profile: profile));
}

class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet({required this.profile});

  final WorkerProfile profile;

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.profile.name);
  late final _headline = TextEditingController(text: widget.profile.headline);
  late final _about = TextEditingController(text: widget.profile.about);
  late WorkerAvailability _availability = widget.profile.availability;

  @override
  void dispose() {
    _name.dispose();
    _headline.dispose();
    _about.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(
      widget.profile.copyWith(
        name: _name.text.trim(),
        headline: _headline.text.trim(),
        about: _about.text.trim(),
        availability: _availability,
      ),
    );
  }

  String? _required(String? v, String field, {int min = 2}) =>
      (v == null || v.trim().length < min) ? 'Please enter at least $min characters for $field' : null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xl),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edit profile', style: theme.headlineSmall),
              const SizedBox(height: AppSpacing.md),
              LabeledField(
                label: 'Display name',
                isRequired: true,
                child: TextFormField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => _required(v, 'your name'),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              LabeledField(
                label: 'Headline',
                isRequired: true,
                child: TextFormField(
                  controller: _headline,
                  maxLength: 60,
                  decoration: const InputDecoration(helperText: 'For example: Furniture and door fitting'),
                  validator: (v) => _required(v, 'your headline', min: 6),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              LabeledField(
                label: 'About you',
                child: TextFormField(controller: _about, maxLines: 3, maxLength: 240),
              ),
              const SizedBox(height: AppSpacing.xs),
              LabeledField(
                label: 'Availability',
                isRequired: true,
                child: SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<WorkerAvailability>(
                    showSelectedIcon: false,
                    segments: [
                      for (final a in WorkerAvailability.values)
                        ButtonSegment(
                          value: a,
                          label: Text(switch (a) {
                            WorkerAvailability.available => 'Now',
                            WorkerAvailability.soon => 'Soon',
                            WorkerAvailability.busy => 'Busy',
                          }),
                        ),
                    ],
                    selected: {_availability},
                    onSelectionChanged: (s) => setState(() => _availability = s.first),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const PrototypeNote(text: 'Changes are kept on this device for this session only.'),
              const SizedBox(height: AppSpacing.lg),
              AppButton(label: 'Save changes', expand: true, onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }
}
