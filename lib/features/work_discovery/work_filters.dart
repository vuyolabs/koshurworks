import 'package:flutter/material.dart';

import '../../core/widgets/filter_sheet.dart';
import '../../data/models/work_category.dart';
import '../../data/models/work_listing.dart';

enum WorkSort {
  newest('Newest first'),
  highestPay('Highest pay'),
  mostWorkers('Most workers needed'),
  startingSoon('Starting soonest');

  const WorkSort(this.label);
  final String label;
}

/// Filter group ids for the work discovery sheet.
abstract final class WorkFilterKeys {
  static const district = 'district';
  static const compensation = 'compensation';
  static const duration = 'duration';
  static const start = 'start';
}

List<FilterGroup> workFilterGroups(List<String> districts) => [
  FilterGroup(id: WorkFilterKeys.district, title: 'District', icon: Icons.place_outlined, options: districts),
  FilterGroup(
    id: WorkFilterKeys.compensation,
    title: 'Compensation type',
    icon: Icons.payments_outlined,
    options: [for (final c in CompensationType.values) c.label],
  ),
  FilterGroup(
    id: WorkFilterKeys.duration,
    title: 'Duration',
    icon: Icons.schedule_rounded,
    options: [for (final d in DurationBucket.values) d.label],
  ),
  FilterGroup(
    id: WorkFilterKeys.start,
    title: 'Availability',
    icon: Icons.event_available_outlined,
    options: [for (final s in StartTiming.values) s.label],
  ),
];

/// Pure filtering and sorting so the logic can move to an API later.
List<WorkListing> applyWorkFilters(
  List<WorkListing> listings, {
  String query = '',
  WorkCategory? category,
  FilterSelection filters = const {},
  WorkSort sort = WorkSort.newest,
  DateTime? now,
}) {
  final today = now ?? DateTime.now();
  final q = query.trim().toLowerCase();
  Set<String> pick(String key) => filters[key] ?? const {};
  final districts = pick(WorkFilterKeys.district);
  final comp = pick(WorkFilterKeys.compensation);
  final dur = pick(WorkFilterKeys.duration);
  final start = pick(WorkFilterKeys.start);

  bool matchesQuery(WorkListing l) {
    if (q.isEmpty) return true;
    final haystack = [
      l.title,
      l.description,
      l.category.name,
      l.district,
      l.locality,
      ...l.skills,
    ].join(' ').toLowerCase();
    return q.split(RegExp(r'\s+')).every(haystack.contains);
  }

  final result = listings.where((l) {
    if (category != null && l.category != category) return false;
    if (districts.isNotEmpty && !districts.contains(l.district)) return false;
    if (comp.isNotEmpty && !comp.contains(l.compensationType.label)) return false;
    if (dur.isNotEmpty && !dur.contains(l.durationBucket.label)) return false;
    if (start.isNotEmpty && !start.contains(l.startTimingFrom(today).label)) return false;
    return matchesQuery(l);
  }).toList();

  int payOf(WorkListing l) => switch (l.compensationType) {
    CompensationType.dailyWage => (l.amount ?? 0) * 20,
    _ => l.amount ?? 0,
  };

  result.sort(switch (sort) {
    WorkSort.newest => (a, b) => b.postedAt.compareTo(a.postedAt),
    WorkSort.highestPay => (a, b) => payOf(b).compareTo(payOf(a)),
    WorkSort.mostWorkers => (a, b) => b.workersNeeded.compareTo(a.workersNeeded),
    WorkSort.startingSoon => (a, b) => a.startDate.compareTo(b.startDate),
  });
  return result;
}
