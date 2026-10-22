import 'package:flutter/foundation.dart';

import 'work_category.dart';

/// How a piece of work is paid.
enum CompensationType {
  dailyWage('Daily wage'),
  fixedPrice('Fixed project price'),
  negotiable('Negotiable'),
  quotation('Quotation required');

  const CompensationType(this.label);
  final String label;
}

/// Coarse duration buckets used for filtering.
enum DurationBucket {
  oneDay('1 day or less'),
  underWeek('Under a week'),
  fewWeeks('1 to 4 weeks'),
  overMonth('Over a month');

  const DurationBucket(this.label);
  final String label;
}

/// When the work is expected to begin.
enum StartTiming {
  immediate('Starts immediately'),
  thisWeek('Starts this week'),
  later('Starts later');

  const StartTiming(this.label);
  final String label;
}

/// The person or organisation posting work.
enum HirerType {
  homeowner('Homeowner'),
  contractor('Contractor'),
  business('Business');

  const HirerType(this.label);
  final String label;
}

@immutable
class Hirer {
  const Hirer({
    required this.name,
    required this.type,
    required this.memberSinceYear,
    required this.postedCount,
    this.isDemoVerified = false,
  });

  final String name;
  final HirerType type;
  final int memberSinceYear;
  final int postedCount;

  /// Sample verification flag. Nothing has been verified by a real service.
  final bool isDemoVerified;
}

/// A work opportunity posted by a hirer.
@immutable
class WorkListing {
  const WorkListing({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.district,
    required this.locality,
    required this.workersNeeded,
    required this.compensationType,
    required this.startDate,
    required this.durationLabel,
    required this.durationBucket,
    required this.postedAt,
    required this.skills,
    required this.experience,
    required this.hirer,
    this.amount,
    this.interestedCount = 0,
    this.isUrgent = false,
    this.isPrototypeDraft = false,
  });

  final String id;
  final String title;
  final WorkCategory category;
  final String description;
  final String district;
  final String locality;
  final int workersNeeded;
  final CompensationType compensationType;

  /// Proposed amount in rupees: per day for daily wage, total otherwise.
  final int? amount;
  final DateTime startDate;
  final String durationLabel;
  final DurationBucket durationBucket;
  final DateTime postedAt;
  final List<String> skills;
  final String experience;
  final Hirer hirer;
  final int interestedCount;
  final bool isUrgent;

  /// True for listings created through the post-work form in this session.
  final bool isPrototypeDraft;

  StartTiming startTimingFrom(DateTime now) {
    final days = _dateOnly(startDate).difference(_dateOnly(now)).inDays;
    if (days <= 1) return StartTiming.immediate;
    if (days <= 7) return StartTiming.thisWeek;
    return StartTiming.later;
  }
}

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
