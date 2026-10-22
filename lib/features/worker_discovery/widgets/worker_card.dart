import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/avatars.dart';
import '../../../core/widgets/motion.dart';
import '../../../core/widgets/pressable_card.dart';
import '../../../core/widgets/status_badges.dart';
import '../../../data/models/worker_profile.dart';

/// Worker summary card. [compact] is the vertical carousel variant.
class WorkerCard extends StatelessWidget {
  const WorkerCard({
    super.key,
    required this.worker,
    required this.onTap,
    this.onContact,
    this.compact = false,
  });

  final WorkerProfile worker;
  final VoidCallback onTap;
  final VoidCallback? onContact;
  final bool compact;

  String get _semantic =>
      '${worker.name}, ${worker.category.name}, ${worker.locality}, ${worker.district}. '
      '${worker.yearsExperience} years experience. ${worker.availability.label}.';

  @override
  Widget build(BuildContext context) => compact ? _buildCompact(context) : _buildFull(context);

  Widget _buildCompact(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return PressableCard(
      onTap: onTap,
      semanticLabel: _semantic,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppAvatar(name: worker.name, size: 48),
              const Spacer(),
              RatingLabel(rating: worker.rating),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(worker.name, style: theme.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(
            worker.category.name,
            style: theme.bodySmall?.copyWith(color: AppColors.forestSoft, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.xs),
          LocationLabel(district: worker.district, dense: true),
          const Spacer(),
          AvailabilityIndicator(availability: worker.availability),
        ],
      ),
    );
  }

  Widget _buildFull(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return PressableCard(
      onTap: onTap,
      semanticLabel: _semantic,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppAvatar(name: worker.name, size: 56),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(worker.name, style: theme.titleMedium, overflow: TextOverflow.ellipsis),
                        ),
                        if (worker.isDemoVerified) ...[
                          const SizedBox(width: 4),
                          const Tooltip(
                            message: 'Sample verification status only',
                            child: Icon(Icons.verified_rounded, size: 17, color: AppColors.success),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      '${worker.category.name} · ${worker.headline}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.bodySmall,
                    ),
                    const SizedBox(height: 6),
                    LocationLabel(district: worker.district, locality: worker.locality, dense: true),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              InfoTag(
                label: '${worker.yearsExperience} yrs experience',
                icon: Icons.workspace_premium_outlined,
              ),
              if (worker.dailyRateFrom case final rate?)
                InfoTag(label: 'From ${Formatters.rupees(rate)}/day', icon: Icons.payments_outlined),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          const Divider(),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Expanded(child: AvailabilityIndicator(availability: worker.availability)),
              const SizedBox(width: AppSpacing.xs),
              RatingLabel(rating: worker.rating, reviewCount: worker.reviewCount),
              if (onContact != null) ...[
                const SizedBox(width: AppSpacing.xs),
                IconButton(
                  tooltip: 'Contact ${worker.name}',
                  onPressed: onContact,
                  style: IconButton.styleFrom(backgroundColor: AppColors.sage),
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 19, color: AppColors.forest),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class WorkerCardSkeleton extends StatelessWidget {
  const WorkerCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: [
          SkeletonBox(width: 56, height: 56, radius: 28),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 120, height: 14),
                SizedBox(height: 8),
                SkeletonBox(height: 10),
                SizedBox(height: 8),
                SkeletonBox(width: 90, height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
