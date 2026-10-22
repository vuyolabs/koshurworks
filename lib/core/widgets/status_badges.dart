import 'package:flutter/material.dart';

import '../../data/models/work_listing.dart';
import '../../data/models/worker_profile.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import '../utils/formatters.dart';

/// Small rounded label with optional icon.
class InfoTag extends StatelessWidget {
  const InfoTag({
    super.key,
    required this.label,
    this.icon,
    this.background = AppColors.neutralSoft,
    this.foreground = AppColors.textSecondary,
  });

  final String label;
  final IconData? icon;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(color: background, borderRadius: AppRadii.pillAll),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 14, color: foreground), const SizedBox(width: 4)],
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: foreground),
            ),
          ),
        ],
      ),
    );
  }
}

/// Marks content as demonstration data.
class SampleDataTag extends StatelessWidget {
  const SampleDataTag({super.key, this.label = 'Sample data'});

  final String label;

  @override
  Widget build(BuildContext context) => InfoTag(
    label: label,
    icon: Icons.science_outlined,
    background: AppColors.amberSoft,
    foreground: AppColors.amberDark,
  );
}

/// Prototype verification status. Never implies real verification.
class VerificationBadge extends StatelessWidget {
  const VerificationBadge({super.key, required this.verified});

  final bool verified;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: verified
          ? 'Sample status only. No identity has been checked in this prototype.'
          : 'This sample profile has no verification status.',
      child: InfoTag(
        label: verified ? 'Verified (demo)' : 'Not verified',
        icon: verified ? Icons.verified_rounded : Icons.help_outline_rounded,
        background: verified ? AppColors.successSoft : AppColors.neutralSoft,
        foreground: verified ? AppColors.success : AppColors.textSecondary,
      ),
    );
  }
}

/// District and locality with a pin icon.
class LocationLabel extends StatelessWidget {
  const LocationLabel({super.key, required this.district, this.locality, this.dense = false});

  final String district;
  final String? locality;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final text = locality == null ? district : '$locality, $district';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.place_outlined, size: dense ? 15 : 17, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: (dense ? Theme.of(context).textTheme.bodySmall : Theme.of(context).textTheme.bodyMedium)
                ?.copyWith(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

/// Compensation summary, for example "₹900 / day" or "Quotation required".
class CompensationLabel extends StatelessWidget {
  const CompensationLabel({super.key, required this.type, this.amount, this.large = false});

  final CompensationType type;
  final int? amount;
  final bool large;

  static String primaryText(CompensationType type, int? amount) {
    final value = amount;
    return switch (type) {
      CompensationType.dailyWage => value == null ? 'Daily wage' : '${Formatters.rupees(value)} / day',
      CompensationType.fixedPrice => value == null ? 'Fixed price' : Formatters.rupees(value),
      CompensationType.negotiable =>
        value == null ? 'Negotiable' : '${Formatters.rupees(value)} (negotiable)',
      CompensationType.quotation => 'Quotation required',
    };
  }

  static String? secondaryText(CompensationType type, int? amount) => switch (type) {
    CompensationType.fixedPrice when amount != null => 'fixed project price',
    CompensationType.dailyWage => 'daily wage',
    CompensationType.negotiable when amount == null => 'rate to be discussed',
    CompensationType.quotation => 'send your price',
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final secondary = secondaryText(type, amount);
    final hasAmount = amount != null;
    return Text.rich(
      TextSpan(
        text: primaryText(type, amount),
        children: [
          if (secondary != null && hasAmount) TextSpan(text: '  $secondary', style: theme.bodySmall),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: (large ? theme.titleLarge : theme.titleMedium)?.copyWith(
        color: hasAmount ? AppColors.forest : AppColors.charcoal,
      ),
    );
  }
}

/// Coloured dot and label for worker availability.
class AvailabilityIndicator extends StatelessWidget {
  const AvailabilityIndicator({super.key, required this.availability, this.pill = false});

  final WorkerAvailability availability;
  final bool pill;

  static Color colorFor(WorkerAvailability a) => switch (a) {
    WorkerAvailability.available => AppColors.success,
    WorkerAvailability.soon => AppColors.warning,
    WorkerAvailability.busy => AppColors.textTertiary,
  };

  @override
  Widget build(BuildContext context) {
    final color = colorFor(availability);
    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            availability.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
          ),
        ),
      ],
    );
    if (!pill) return row;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: AppRadii.pillAll),
      child: row,
    );
  }
}

/// Star rating with review count.
class RatingLabel extends StatelessWidget {
  const RatingLabel({super.key, required this.rating, this.reviewCount});

  final double rating;
  final int? reviewCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Semantics(
      label:
          'Rated ${rating.toStringAsFixed(1)} out of 5'
          '${reviewCount == null ? '' : ' from $reviewCount sample reviews'}',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 17, color: AppColors.amber),
          const SizedBox(width: 2),
          Text(rating.toStringAsFixed(1), style: theme.labelMedium),
          if (reviewCount != null) ...[
            const SizedBox(width: 3),
            Text('($reviewCount)', style: theme.bodySmall),
          ],
        ],
      ),
    );
  }
}
