import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/app_state.dart';
import '../../../app/router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/category_chip.dart';
import '../../../core/widgets/content_width.dart';
import '../../../core/widgets/form_widgets.dart';
import '../../../core/widgets/motion.dart';
import '../../../core/widgets/sheets.dart';
import '../../../data/models/work_category.dart';
import '../../../data/models/work_listing.dart';
import '../../work_details/widgets/detail_widgets.dart';
import '../../work_discovery/widgets/work_listing_card.dart';
import '../widgets/post_work_inputs.dart';

enum ContactPreference {
  inApp('In-app chat'),
  callback('Call back'),
  either('Either');

  const ContactPreference(this.label);
  final String label;
}

/// Multi-section form for posting a work requirement. Submission creates an
/// in-memory draft only; nothing is published.
class PostWorkScreen extends StatefulWidget {
  const PostWorkScreen({super.key});

  @override
  State<PostWorkScreen> createState() => _PostWorkScreenState();
}

class _PostWorkScreenState extends State<PostWorkScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _locality = TextEditingController();
  final _budget = TextEditingController();
  final _customSkill = TextEditingController();

  WorkCategory? _category;
  String? _district;
  int _workers = 1;
  DateTime? _startDate;
  DurationBucket? _duration;
  CompensationType? _compensation;
  final List<String> _skills = [];
  ContactPreference _contact = ContactPreference.inApp;

  bool _attempted = false;
  bool _submitting = false;
  WorkListing? _submitted;

  @override
  void dispose() {
    for (final c in [_title, _description, _locality, _budget, _customSkill]) {
      c.dispose();
    }
    super.dispose();
  }

  // ---- Validation for custom inputs ---------------------------------------

  String? get _categoryError => _attempted && _category == null ? 'Choose a trade' : null;
  String? get _districtError => _attempted && _district == null ? 'Choose a district' : null;
  String? get _startError => _attempted && _startDate == null ? 'Pick a start date' : null;
  String? get _durationError => _attempted && _duration == null ? 'Choose an expected duration' : null;
  String? get _compError => _attempted && _compensation == null ? 'Choose how the work is paid' : null;
  String? get _skillsError => _attempted && _skills.isEmpty ? 'Add at least one skill' : null;

  bool get _customValid =>
      _category != null &&
      _district != null &&
      _startDate != null &&
      _duration != null &&
      _compensation != null &&
      _skills.isNotEmpty;

  /// Completeness check that does not trigger visible validation errors.
  bool get _looksComplete =>
      _customValid &&
      _title.text.trim().length >= 8 &&
      _description.text.trim().length >= 20 &&
      _locality.text.trim().length >= 2 &&
      _validateBudget(_budget.text) == null;

  String? _validateBudget(String? v) {
    final text = v?.trim() ?? '';
    if (text.isEmpty) return null;
    final value = int.tryParse(text);
    if (value == null || value <= 0) return 'Enter a whole number in rupees';
    if (value > 10000000) return 'That amount looks too large';
    if (_compensation == CompensationType.dailyWage && value < 100) {
      return 'Daily wage should be at least ₹100';
    }
    return null;
  }

  // ---- Actions -------------------------------------------------------------

  Future<void> _pickDistrict(AppState state) async {
    final picked = await showSelectionSheet<String>(
      context,
      title: 'District',
      options: state.workRepository.districts,
      labelOf: (d) => d,
      iconOf: (_) => Icons.place_outlined,
      selected: _district,
    );
    if (picked != null) setState(() => _district = picked);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showAppDatePicker(
      context,
      initialDate: _startDate ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 180)),
      helpText: 'When should work start?',
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  void _toggleSkill(String skill) {
    setState(() {
      if (!_skills.remove(skill)) _skills.add(skill);
    });
  }

  void _addCustomSkill() {
    final skill = _customSkill.text.trim();
    if (skill.length < 2) return;
    setState(() {
      if (!_skills.any((s) => s.toLowerCase() == skill.toLowerCase())) _skills.add(skill);
      _customSkill.clear();
    });
  }

  WorkListing _buildDraft(AppState state) {
    final now = DateTime.now();
    final category = _category ?? state.workRepository.categories.first;
    return WorkListing(
      id: 'draft-${now.microsecondsSinceEpoch}',
      title: _title.text.trim().isEmpty ? 'Your work title' : _title.text.trim(),
      category: category,
      description: _description.text.trim().isEmpty
          ? 'Your description will appear here.'
          : _description.text.trim(),
      district: _district ?? state.district,
      locality: _locality.text.trim().isEmpty ? 'Locality' : _locality.text.trim(),
      workersNeeded: _workers,
      compensationType: _compensation ?? CompensationType.negotiable,
      amount: _compensation == CompensationType.quotation ? null : int.tryParse(_budget.text.trim()),
      startDate: _startDate ?? now,
      durationLabel: _duration?.label ?? 'Duration not set',
      durationBucket: _duration ?? DurationBucket.underWeek,
      postedAt: now,
      skills: _skills.isEmpty ? const ['Skills not added'] : List.unmodifiable(_skills),
      experience: 'Contact preference: ${_contact.label}',
      hirer: Hirer(
        name: state.profile.name,
        type: HirerType.homeowner,
        memberSinceYear: now.year,
        postedCount: state.postedThisSession.length + 1,
      ),
      isPrototypeDraft: true,
    );
  }

  void _preview(AppState state) {
    final draft = _buildDraft(state);
    showInfoSheet(
      context,
      title: 'Preview',
      icon: Icons.visibility_outlined,
      children: [
        Text(
          'This is how workers would see your listing.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.md),
        WorkListingCard(listing: draft, isSaved: false, onTap: () {}, onSaveToggle: () {}),
        const SizedBox(height: AppSpacing.md),
        DetailSection(title: 'Description', child: Text(draft.description)),
        if (!_looksComplete) ...[
          const SizedBox(height: AppSpacing.md),
          const PrototypeNote(text: 'Some required details are still missing. Placeholders are shown.'),
        ],
      ],
    );
  }

  Future<void> _submit(AppState state) async {
    FocusScope.of(context).unfocus();
    setState(() => _attempted = true);
    final fieldsValid = _formKey.currentState?.validate() ?? false;
    if (!fieldsValid || !_customValid) {
      HapticFeedback.lightImpact();
      showAppSnack(context, 'Please complete the highlighted fields.', icon: Icons.error_outline_rounded);
      return;
    }
    setState(() => _submitting = true);
    // Simulated processing so the loading state is visible. No network call.
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    final draft = _buildDraft(state);
    state.addPrototypePost(draft);
    setState(() {
      _submitting = false;
      _submitted = draft;
    });
  }

  void _reset() {
    _formKey.currentState?.reset();
    for (final c in [_title, _description, _locality, _budget, _customSkill]) {
      c.clear();
    }
    setState(() {
      _category = null;
      _district = null;
      _workers = 1;
      _startDate = null;
      _duration = null;
      _compensation = null;
      _skills.clear();
      _contact = ContactPreference.inApp;
      _attempted = false;
      _submitted = null;
    });
  }

  // ---- Build ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final submitted = _submitted;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Close',
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Post Work'),
      ),
      body: AnimatedSwitcher(
        duration: AppMotion.of(context, AppMotion.slow),
        switchInCurve: AppMotion.curve,
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: ScaleTransition(scale: Tween(begin: 0.97, end: 1.0).animate(anim), child: child),
        ),
        child: submitted == null
            ? _buildForm(context, state)
            : _SuccessView(
                key: ValueKey(submitted.id),
                listing: submitted,
                onView: () => AppNavigator.openWork(context, submitted),
                onPostAnother: _reset,
                onDone: () => Navigator.of(context).maybePop(),
              ),
      ),
      bottomNavigationBar: submitted != null
          ? null
          : DetailActionBar(
              children: [
                Expanded(
                  flex: 2,
                  child: AppButton.secondary(
                    label: 'Preview',
                    icon: Icons.visibility_outlined,
                    expand: true,
                    onPressed: () => _preview(state),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: AppButton(
                    label: 'Submit',
                    icon: Icons.check_rounded,
                    expand: true,
                    loading: _submitting,
                    onPressed: () => _submit(state),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildForm(BuildContext context, AppState state) {
    final theme = Theme.of(context).textTheme;
    final category = _category;
    final suggestions = {...?category?.suggestedSkills, ..._skills}.toList();
    final isQuote = _compensation == CompensationType.quotation;

    final sections = <Widget>[
      Text(
        'Describe the work clearly so the right people can respond.',
        style: theme.bodyLarge?.copyWith(color: AppColors.textSecondary),
      ),
      FormSection(
        step: 1,
        title: 'The work',
        icon: Icons.description_outlined,
        children: [
          LabeledField(
            label: 'Work title',
            isRequired: true,
            child: TextFormField(
              controller: _title,
              textCapitalization: TextCapitalization.sentences,
              maxLength: 70,
              decoration: const InputDecoration(
                hintText: 'e.g. Need 2 masons for a boundary wall',
                helperText: 'Mention the trade and number of people',
              ),
              validator: (v) => (v?.trim().length ?? 0) < 8 ? 'Title should be at least 8 characters' : null,
            ),
          ),
          LabeledField(
            label: 'Trade',
            isRequired: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    for (final c in state.workRepository.categories)
                      CategoryChip(
                        label: c.name,
                        icon: c.icon,
                        selected: _category == c,
                        onTap: () => setState(() => _category = c),
                      ),
                  ],
                ),
                FieldError(_categoryError),
              ],
            ),
          ),
          LabeledField(
            label: 'Description',
            isRequired: true,
            child: TextFormField(
              controller: _description,
              maxLines: 4,
              maxLength: 500,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'What needs to be done? Are materials provided? Any timings?',
              ),
              validator: (v) => (v?.trim().length ?? 0) < 20
                  ? 'Please add a bit more detail (20 characters or more)'
                  : null,
            ),
          ),
        ],
      ),
      FormSection(
        step: 2,
        title: 'Where',
        icon: Icons.place_outlined,
        children: [
          LabeledField(
            label: 'District',
            isRequired: true,
            child: Column(
              children: [
                PickerField(
                  icon: Icons.map_outlined,
                  placeholder: 'Choose district',
                  value: _district,
                  hasError: _districtError != null,
                  onTap: () => _pickDistrict(state),
                ),
                FieldError(_districtError),
              ],
            ),
          ),
          LabeledField(
            label: 'Locality or area',
            isRequired: true,
            child: TextFormField(
              controller: _locality,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                hintText: 'e.g. Rawalpora',
                helperText: 'Do not enter your full address',
              ),
              validator: (v) => (v?.trim().length ?? 0) < 2 ? 'Enter a locality' : null,
            ),
          ),
        ],
      ),
      FormSection(
        step: 3,
        title: 'People and timing',
        icon: Icons.groups_2_outlined,
        children: [
          LabeledField(
            label: 'Workers required',
            isRequired: true,
            child: CountStepper(value: _workers, onChanged: (v) => setState(() => _workers = v)),
          ),
          LabeledField(
            label: 'Start date',
            isRequired: true,
            child: Column(
              children: [
                PickerField(
                  icon: Icons.event_outlined,
                  placeholder: 'Pick a date',
                  value: _startDate == null ? null : Formatters.shortDate(_startDate!),
                  hasError: _startError != null,
                  onTap: _pickDate,
                ),
                FieldError(_startError),
              ],
            ),
          ),
          LabeledField(
            label: 'Expected duration',
            isRequired: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    for (final d in DurationBucket.values)
                      CategoryChip(
                        label: d.label,
                        selected: _duration == d,
                        onTap: () => setState(() => _duration = d),
                      ),
                  ],
                ),
                FieldError(_durationError),
              ],
            ),
          ),
        ],
      ),
      FormSection(
        step: 4,
        title: 'Payment',
        icon: Icons.payments_outlined,
        children: [
          LabeledField(
            label: 'Compensation type',
            isRequired: true,
            child: Column(
              children: [
                _CompensationGrid(
                  selected: _compensation,
                  onSelected: (c) => setState(() => _compensation = c),
                ),
                FieldError(_compError),
              ],
            ),
          ),
          AnimatedSize(
            duration: AppMotion.size(context, AppMotion.medium),
            alignment: Alignment.topCenter,
            child: isQuote
                ? const PrototypeNote(text: 'Workers will send their own price, so no budget is needed.')
                : LabeledField(
                    label: _compensation == CompensationType.dailyWage ? 'Daily wage per person' : 'Budget',
                    child: TextFormField(
                      controller: _budget,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        prefixText: '₹ ',
                        hintText: _compensation == CompensationType.dailyWage ? '800' : '25000',
                        helperText: _compensation == CompensationType.dailyWage
                            ? 'Amount per working day'
                            : 'Total amount for the work. Leave empty if unsure.',
                      ),
                      validator: _validateBudget,
                    ),
                  ),
          ),
        ],
      ),
      FormSection(
        step: 5,
        title: 'Skills and contact',
        icon: Icons.handyman_outlined,
        children: [
          LabeledField(
            label: 'Skills required',
            isRequired: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (suggestions.isEmpty)
                  Text('Choose a trade above to see suggested skills.', style: theme.bodySmall)
                else
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      for (final s in suggestions)
                        CategoryChip(
                          label: s,
                          icon: _skills.contains(s) ? Icons.check_rounded : Icons.add_rounded,
                          selected: _skills.contains(s),
                          onTap: () => _toggleSkill(s),
                        ),
                    ],
                  ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: _customSkill,
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => _addCustomSkill(),
                  decoration: InputDecoration(
                    hintText: 'Add another skill',
                    suffixIcon: IconButton(
                      tooltip: 'Add skill',
                      icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.forest),
                      onPressed: _addCustomSkill,
                    ),
                  ),
                ),
                FieldError(_skillsError),
              ],
            ),
          ),
          LabeledField(
            label: 'How should workers reach you?',
            isRequired: true,
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<ContactPreference>(
                showSelectedIcon: false,
                segments: [
                  for (final c in ContactPreference.values) ButtonSegment(value: c, label: Text(c.label)),
                ],
                selected: {_contact},
                onSelectionChanged: (s) => setState(() => _contact = s.first),
              ),
            ),
          ),
        ],
      ),
      const PrototypeNote(
        text:
            'Prototype: submitting creates a local draft only. '
            'Nothing is published or shared.',
      ),
    ];

    return Form(
      key: _formKey,
      autovalidateMode: _attempted ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
      child: ListView(
        key: const ValueKey('form'),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen,
          AppSpacing.xs,
          AppSpacing.screen,
          AppSpacing.xxl,
        ),
        children: [
          ContentWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < sections.length; i++) ...[
                  if (i > 0) const SizedBox(height: AppSpacing.md),
                  FadeSlideIn(delay: FadeSlideIn.stagger(i, stepMs: 60), child: sections[i]),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompensationGrid extends StatelessWidget {
  const _CompensationGrid({required this.selected, required this.onSelected});

  final CompensationType? selected;
  final ValueChanged<CompensationType> onSelected;

  static const _meta = {
    CompensationType.dailyWage: (Icons.today_outlined, 'Paid per working day'),
    CompensationType.fixedPrice: (Icons.receipt_long_outlined, 'One price for the job'),
    CompensationType.negotiable: (Icons.forum_outlined, 'Agree the rate together'),
    CompensationType.quotation: (Icons.request_quote_outlined, 'Workers send a price'),
  };

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < 280 ? 1 : 2;
        final width = (constraints.maxWidth - AppSpacing.xs * (columns - 1)) / columns;
        return Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            for (final type in CompensationType.values)
              SizedBox(
                width: width,
                child: ChoiceCard(
                  icon: _meta[type]?.$1 ?? Icons.payments_outlined,
                  title: type.label,
                  description: _meta[type]?.$2 ?? '',
                  selected: selected == type,
                  onTap: () => onSelected(type),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SuccessView extends StatelessWidget {
  const _SuccessView({
    super.key,
    required this.listing,
    required this.onView,
    required this.onPostAnother,
    required this.onDone,
  });

  final WorkListing listing;
  final VoidCallback onView;
  final VoidCallback onPostAnother;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final reduced = AppMotion.reduced(context);
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        ContentWidth(
          maxWidth: 520,
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.lg),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: reduced ? 1 : 0.4, end: 1),
                duration: reduced ? Duration.zero : const Duration(milliseconds: 650),
                curve: Curves.elasticOut,
                builder: (context, v, child) => Transform.scale(scale: v, child: child),
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(
                    color: AppColors.forest,
                    shape: BoxShape.circle,
                    boxShadow: AppShadows.raised,
                  ),
                  child: const Icon(Icons.check_rounded, color: AppColors.amber, size: 52),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Draft ready', style: theme.headlineMedium, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Your requirement was saved as a local prototype draft. '
                'It has not been published and no one has been notified.',
                textAlign: TextAlign.center,
                style: theme.bodyLarge?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xl),
              FadeSlideIn(
                delay: const Duration(milliseconds: 200),
                child: WorkListingCard(listing: listing, isSaved: false, onTap: onView, onSaveToggle: () {}),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: 'View as listing',
                icon: Icons.visibility_outlined,
                expand: true,
                onPressed: onView,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton.secondary(
                label: 'Post another',
                icon: Icons.add_rounded,
                expand: true,
                onPressed: onPostAnother,
              ),
              const SizedBox(height: AppSpacing.xs),
              AppButton(label: 'Done', variant: AppButtonVariant.ghost, expand: true, onPressed: onDone),
            ],
          ),
        ),
      ],
    );
  }
}
