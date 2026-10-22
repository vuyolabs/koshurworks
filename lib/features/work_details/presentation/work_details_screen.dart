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
import '../../../data/models/work_listing.dart';
import '../../common/contact_sheet.dart';
import '../widgets/detail_widgets.dart';

/// Full information about one work listing.
class WorkDetailsScreen extends StatelessWidget {
  const WorkDetailsScreen({super.key, required this.listing});

  final WorkListing listing;

  Future<void> _expressInterest(BuildContext context, AppState state) async {
    if (state.isInterested(listing.id)) {
      final withdraw = await showConfirmationSheet(
        context,
        title: 'Withdraw interest?',
        message: 'This removes your interest for "${listing.title}" on this device.',
        confirmLabel: 'Withdraw interest',
        cancelLabel: 'Keep it',
        icon: Icons.undo_rounded,
        destructive: true,
      );
      if (withdraw && context.mounted) {
        state.withdrawInterest(listing.id);
        showAppSnack(context, 'Interest withdrawn.');
      }
      return;
    }
    final confirmed = await showConfirmationSheet(
      context,
      title: "Tell the hirer you're interested?",
      message:
          '${listing.hirer.name} would see your profile summary, skills and '
          'availability, then decide whether to contact you.',
      confirmLabel: "Yes, I'm interested",
      icon: Icons.handshake_outlined,
      footnote:
          'Prototype: your interest is saved on this device only. '
          'Nothing is sent to anyone.',
    );
    if (confirmed && context.mounted) {
      state.markInterested(listing.id);
      showAppSnack(
        context,
        'Interest recorded in this prototype. No message was sent.',
        icon: Icons.check_circle_outline_rounded,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final interested = state.isInterested(listing.id);
    final saved = state.isSaved(listing.id);
    final theme = Theme.of(context).textTheme;
    final hirer = listing.hirer;

    final sections = <Widget>[
      if (listing.isPrototypeDraft)
        const PrototypeNote(text: 'You created this draft in this session. It has not been published.')
      else
        const PrototypeNote(text: 'Sample listing for demonstration. The hirer and project are fictional.'),
      FactGrid(
        children: [
          FactTile(
            icon: Icons.groups_2_outlined,
            label: 'Workers needed',
            value: Formatters.plural(listing.workersNeeded, 'person', 'people'),
          ),
          FactTile(
            icon: Icons.event_outlined,
            label: 'Start date',
            value: Formatters.shortDate(listing.startDate),
          ),
          FactTile(icon: Icons.schedule_rounded, label: 'Duration', value: listing.durationLabel),
          FactTile(icon: Icons.payments_outlined, label: 'Payment', value: listing.compensationType.label),
        ],
      ),
      DetailSection(
        title: 'Compensation',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CompensationLabel(type: listing.compensationType, amount: listing.amount, large: true),
            const SizedBox(height: 4),
            Text(switch (listing.compensationType) {
              CompensationType.dailyWage => 'Paid per working day. Confirm payment schedule with the hirer.',
              CompensationType.fixedPrice => 'One price for the full scope of work.',
              CompensationType.negotiable => 'Open to negotiation. Share your expected rate.',
              CompensationType.quotation => 'The hirer wants your price after understanding the work.',
            }, style: theme.bodySmall),
          ],
        ),
      ),
      DetailSection(
        title: 'About the work',
        child: Text(listing.description, style: theme.bodyLarge),
      ),
      DetailSection(
        title: 'Location',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LocationLabel(district: listing.district, locality: listing.locality),
            const SizedBox(height: AppSpacing.sm),
            const SizedBox(
              height: 110,
              width: double.infinity,
              child: ImagePlaceholder(
                icon: Icons.map_outlined,
                label: 'Map preview is not part of this prototype',
              ),
            ),
          ],
        ),
      ),
      DetailSection(
        title: 'Skills and experience',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkillWrap(skills: listing.skills),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                const Icon(Icons.workspace_premium_outlined, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: AppSpacing.xs),
                Expanded(child: Text(listing.experience, style: theme.bodyMedium)),
              ],
            ),
          ],
        ),
      ),
      DetailSection(
        title: 'Posted by',
        child: Row(
          children: [
            AppAvatar(name: hirer.name, size: 52),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(hirer.name, style: theme.titleMedium),
                  Text(
                    '${hirer.type.label} · Member since ${hirer.memberSinceYear} · '
                    '${Formatters.plural(hirer.postedCount, 'post')}',
                    style: theme.bodySmall,
                  ),
                  const SizedBox(height: 6),
                  VerificationBadge(verified: hirer.isDemoVerified),
                ],
              ),
            ),
          ],
        ),
      ),
      DetailSection(
        title: 'Interest',
        trailing: InfoTag(
          label: '${listing.interestedCount + (interested ? 1 : 0)} interested',
          icon: Icons.favorite_border_rounded,
          background: AppColors.sage,
          foreground: AppColors.forest,
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StepRow(number: 1, text: "Tap I'm Interested to share your profile summary."),
            StepRow(number: 2, text: 'The hirer reviews interested workers.'),
            StepRow(number: 3, text: 'If shortlisted, the hirer contacts you to agree details.'),
          ],
        ),
      ),
      Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: const BoxDecoration(color: AppColors.sage, borderRadius: AppRadii.lgAll),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.shield_outlined, color: AppColors.forest),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Stay safe: never pay a fee to get work, and agree on payment before you start.',
                style: theme.bodyMedium?.copyWith(color: AppColors.forestDark),
              ),
            ),
          ],
        ),
      ),
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 268,
            backgroundColor: AppColors.forest,
            foregroundColor: AppColors.white,
            title: const Text('Work details'),
            titleTextStyle: theme.titleMedium?.copyWith(color: AppColors.white),
            actions: [
              AnimatedBookmarkButton(
                isSaved: saved,
                color: AppColors.white,
                onPressed: () {
                  state.toggleSaved(listing.id);
                  showAppSnack(context, saved ? 'Removed from saved work.' : 'Saved to your list.');
                },
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: DetailHero(
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screen,
                      64,
                      AppSpacing.screen,
                      AppSpacing.lg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            InfoTag(
                              label: listing.category.name,
                              icon: listing.category.icon,
                              background: AppColors.white.withValues(alpha: 0.14),
                              foreground: AppColors.white,
                            ),
                            if (listing.isUrgent) ...[
                              const SizedBox(width: AppSpacing.xs),
                              const InfoTag(
                                label: 'Urgent',
                                background: AppColors.amber,
                                foreground: AppColors.charcoal,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          listing.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.headlineSmall?.copyWith(color: AppColors.white),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '${listing.locality}, ${listing.district} · Posted ${Formatters.timeAgo(listing.postedAt).toLowerCase()}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.bodyMedium?.copyWith(color: AppColors.white.withValues(alpha: 0.8)),
                        ),
                      ],
                    ),
                  ),
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
        children: [
          Expanded(
            flex: 2,
            child: AppButton.secondary(
              label: 'Contact',
              icon: Icons.chat_bubble_outline_rounded,
              expand: true,
              onPressed: () => showPrototypeContactSheet(
                context,
                name: hirer.name,
                subtitle: '${hirer.type.label} · ${listing.district}',
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: AnimatedSwitcher(
              duration: AppMotion.of(context, AppMotion.medium),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: ScaleTransition(scale: Tween(begin: 0.94, end: 1.0).animate(anim), child: child),
              ),
              child: AppButton(
                key: ValueKey(interested),
                label: interested ? 'Interest sent' : "I'm Interested",
                icon: interested ? Icons.check_circle_rounded : Icons.handshake_outlined,
                variant: interested ? AppButtonVariant.accent : AppButtonVariant.primary,
                expand: true,
                onPressed: () => _expressInterest(context, state),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
