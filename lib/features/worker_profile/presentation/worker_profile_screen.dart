import 'package:flutter/material.dart';

import '../../../app/app_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/avatars.dart';
import '../../../core/widgets/content_width.dart';
import '../../../core/widgets/motion.dart';
import '../../../core/widgets/sheets.dart';
import '../../../core/widgets/status_badges.dart';
import '../../../data/models/worker_profile.dart';
import '../../common/contact_sheet.dart';
import '../../work_details/widgets/detail_widgets.dart';
import '../widgets/edit_profile_sheet.dart';

/// Profile of a tradesperson. The `.own()` variant shows the user's own
/// profile with an edit action.
class WorkerProfileScreen extends StatelessWidget {
  const WorkerProfileScreen({super.key, required WorkerProfile this.worker});

  const WorkerProfileScreen.own({super.key}) : worker = null;

  final WorkerProfile? worker;

  Future<void> _edit(BuildContext context, AppState state) async {
    final updated = await showEditProfileSheet(context, state.profile);
    if (updated != null && context.mounted) {
      state.updateProfile(updated);
      showAppSnack(context, 'Profile updated on this device.', icon: Icons.check_circle_outline_rounded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final isOwn = worker == null;
    final w = worker ?? state.profile;
    final theme = Theme.of(context).textTheme;

    final sections = <Widget>[
      PrototypeNote(
        text: isOwn
            ? 'This is your sample profile. Edits stay on this device.'
            : 'Sample profile for demonstration. Ratings and reviews are illustrative.',
      ),
      Row(
        children: [
          Expanded(
            child: _Stat(value: '${w.yearsExperience} yrs', label: 'Experience'),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: _Stat(value: '${w.jobsCompleted}', label: 'Jobs done'),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: _Stat(value: w.rating.toStringAsFixed(1), label: 'Rating', star: true),
          ),
        ],
      ),
      DetailSection(
        title: 'About',
        child: Text(w.about, style: theme.bodyLarge),
      ),
      DetailSection(
        title: 'Skills and specialisations',
        child: SkillWrap(skills: w.skills),
      ),
      DetailSection(
        title: 'Work preferences',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PrefRow(
              icon: Icons.place_outlined,
              label: 'Preferred locations',
              value: w.preferredLocations.join(', '),
            ),
            _PrefRow(icon: Icons.translate_rounded, label: 'Languages', value: w.languages.join(', ')),
            if (w.dailyRateFrom case final rate?)
              _PrefRow(
                icon: Icons.payments_outlined,
                label: 'Typical rate',
                value: 'From ${Formatters.rupees(rate)} per day',
              ),
            _PrefRow(
              icon: Icons.event_available_outlined,
              label: 'Availability',
              value: w.availability.label,
            ),
          ],
        ),
      ),
      DetailSection(
        title: 'Past work',
        trailing: Text('Photos not uploaded', style: theme.bodySmall),
        child: w.portfolioLabels.isEmpty
            ? Text('No photos yet.', style: theme.bodyMedium)
            : GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AppSpacing.xs,
                crossAxisSpacing: AppSpacing.xs,
                children: [
                  for (var i = 0; i < w.portfolioLabels.length; i++)
                    ImagePlaceholder(
                      label: w.portfolioLabels[i],
                      icon: w.category.icon,
                      tone: AppColors.avatarTones[i % AppColors.avatarTones.length],
                    ),
                ],
              ),
      ),
      DetailSection(
        title: 'Work history',
        child: Column(
          children: [
            for (var i = 0; i < w.workHistory.length; i++)
              _TimelineItem(item: w.workHistory[i], isLast: i == w.workHistory.length - 1),
          ],
        ),
      ),
      DetailSection(
        title: 'Reviews',
        trailing: RatingLabel(rating: w.rating, reviewCount: w.reviewCount),
        child: Column(
          children: [
            for (var i = 0; i < w.reviews.length; i++) ...[
              if (i > 0) const Divider(height: AppSpacing.xl),
              _ReviewTile(review: w.reviews[i]),
            ],
          ],
        ),
      ),
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.forest,
            foregroundColor: AppColors.white,
            title: Text(isOwn ? 'My profile' : 'Profile'),
            titleTextStyle: theme.titleMedium?.copyWith(color: AppColors.white),
            actions: [
              if (isOwn)
                TextButton.icon(
                  onPressed: () => _edit(context, state),
                  style: TextButton.styleFrom(foregroundColor: AppColors.white),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit'),
                ),
              const SizedBox(width: AppSpacing.xs),
            ],
          ),
          SliverToBoxAdapter(
            child: DetailHero(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screen,
                  AppSpacing.xs,
                  AppSpacing.screen,
                  AppSpacing.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppAvatar(name: w.name, size: 76, ring: true),
                    const SizedBox(height: AppSpacing.sm),
                    Text(w.name, style: theme.headlineSmall?.copyWith(color: AppColors.white)),
                    Text(
                      '${w.category.name} · ${w.headline}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.bodyMedium?.copyWith(color: AppColors.white.withValues(alpha: 0.82)),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        _OnDark(child: AvailabilityIndicator(availability: w.availability)),
                        _OnDark(
                          child: LocationLabel(district: w.district, locality: w.locality, dense: true),
                        ),
                        if (!isOwn) VerificationBadge(verified: w.isDemoVerified),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: ContentWidth(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screen,
                  AppSpacing.lg,
                  AppSpacing.screen,
                  AppSpacing.xxl,
                ),
                child: Column(
                  children: [
                    for (var i = 0; i < sections.length; i++) ...[
                      if (i > 0) const SizedBox(height: AppSpacing.sm),
                      FadeSlideIn(delay: FadeSlideIn.stagger(i, stepMs: 40), child: sections[i]),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: DetailActionBar(
        children: isOwn
            ? [
                Expanded(
                  child: AppButton(
                    label: 'Edit profile',
                    icon: Icons.edit_outlined,
                    expand: true,
                    onPressed: () => _edit(context, state),
                  ),
                ),
              ]
            : [
                Expanded(
                  child: AppButton.secondary(
                    label: 'Invite to job',
                    icon: Icons.send_outlined,
                    expand: true,
                    onPressed: () => showAppSnack(
                      context,
                      'Prototype only. No invitation was sent to ${w.name}.',
                      icon: Icons.science_outlined,
                    ),
                  ),
                ),
                Expanded(
                  child: AppButton(
                    label: 'Contact',
                    icon: Icons.chat_bubble_outline_rounded,
                    expand: true,
                    onPressed: () => showPrototypeContactSheet(
                      context,
                      name: w.name,
                      subtitle: '${w.category.name} · ${w.district}',
                    ),
                  ),
                ),
              ],
      ),
    );
  }
}

/// Light pill so status widgets stay readable on the dark header.
class _OnDark extends StatelessWidget {
  const _OnDark({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: const BoxDecoration(color: AppColors.white, borderRadius: AppRadii.pillAll),
      child: child,
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, this.star = false});

  final String value;
  final String label;
  final bool star;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadii.mdAll,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (star) const Icon(Icons.star_rounded, size: 20, color: AppColors.amber),
                Text(value, style: theme.titleLarge?.copyWith(color: AppColors.forest)),
              ],
            ),
          ),
          Text(label, style: theme.bodySmall),
        ],
      ),
    );
  }
}

class _PrefRow extends StatelessWidget {
  const _PrefRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19, color: AppColors.forest),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.bodySmall),
                Text(value, style: theme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({required this.item, required this.isLast});

  final WorkHistoryItem item;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 20,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.forest, width: 3),
                  ),
                ),
                if (!isLast) Expanded(child: Container(width: 2, color: AppColors.sageDeep)),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: theme.titleSmall),
                  Text('${item.place} · ${item.period}', style: theme.bodySmall),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(review.author, style: theme.titleSmall)),
            RatingLabel(rating: review.rating),
          ],
        ),
        const SizedBox(height: 4),
        Text('"${review.comment}"', style: theme.bodyMedium),
        const SizedBox(height: 2),
        Text(review.whenLabel, style: theme.bodySmall),
      ],
    );
  }
}
