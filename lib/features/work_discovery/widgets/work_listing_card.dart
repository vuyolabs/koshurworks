import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/motion.dart';
import '../../../core/widgets/pressable_card.dart';
import '../../../core/widgets/status_badges.dart';
import '../../../data/models/work_listing.dart';

/// Work opportunity card shared by home, discovery, saved and account screens.
class WorkListingCard extends StatelessWidget {
  const WorkListingCard({
    super.key,
    required this.listing,
    required this.isSaved,
    required this.onTap,
    required this.onSaveToggle,
    this.compact = false,
  });

  final WorkListing listing;
  final bool isSaved;
  final VoidCallback onTap;
  final VoidCallback onSaveToggle;

  /// Tighter layout for horizontal carousels.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final workers = Formatters.plural(listing.workersNeeded, 'worker');

    return PressableCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.xs, AppSpacing.md),
      semanticLabel:
          '${listing.title}, ${listing.locality}, ${listing.district}. '
          '${CompensationLabel.primaryText(listing.compensationType, listing.amount)}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CategoryBadge(icon: listing.category.icon),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              listing.category.name.toUpperCase(),
                              overflow: TextOverflow.ellipsis,
                              style: theme.labelSmall?.copyWith(color: AppColors.forestSoft),
                            ),
                          ),
                          if (listing.isUrgent) ...[
                            const SizedBox(width: AppSpacing.xs),
                            const InfoTag(
                              label: 'Urgent',
                              background: AppColors.amberSoft,
                              foreground: AppColors.amberDark,
                            ),
                          ],
                          if (listing.isPrototypeDraft) ...[
                            const SizedBox(width: AppSpacing.xs),
                            const SampleDataTag(label: 'Your draft'),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        listing.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedBookmarkButton(isSaved: isSaved, onPressed: onSaveToggle),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.xs),
            child: LocationLabel(district: listing.district, locality: listing.locality),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              InfoTag(label: workers, icon: Icons.groups_2_outlined),
              InfoTag(label: listing.durationLabel, icon: Icons.schedule_rounded),
              if (!compact)
                InfoTag(label: Formatters.startLabel(listing.startDate), icon: Icons.event_outlined),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          const Divider(),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.xs),
            child: Row(
              children: [
                Expanded(
                  child: CompensationLabel(type: listing.compensationType, amount: listing.amount),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(Formatters.timeAgo(listing.postedAt), style: theme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(color: AppColors.sage, borderRadius: AppRadii.mdAll),
      child: Icon(icon, color: AppColors.forest, size: 22),
    );
  }
}

/// Loading placeholder with the same footprint as [WorkListingCard].
class WorkListingCardSkeleton extends StatelessWidget {
  const WorkListingCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SkeletonBox(width: 44, height: 44, radius: AppRadii.md),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 80, height: 10),
                    SizedBox(height: 8),
                    SkeletonBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          SkeletonBox(width: 160, height: 12),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              SkeletonBox(width: 80, height: 24, radius: AppRadii.pill),
              SizedBox(width: 6),
              SkeletonBox(width: 90, height: 24, radius: AppRadii.pill),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          SkeletonBox(width: 120, height: 16),
        ],
      ),
    );
  }
}
