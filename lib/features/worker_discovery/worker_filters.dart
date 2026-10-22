import 'package:flutter/material.dart';

import '../../core/widgets/filter_sheet.dart';
import '../../data/models/work_category.dart';
import '../../data/models/worker_profile.dart';

abstract final class WorkerFilterKeys {
  static const district = 'district';
  static const availability = 'availability';
  static const experience = 'experience';
}

enum ExperienceBand {
  starter('Under 5 years', 0, 4),
  experienced('5 to 10 years', 5, 10),
  expert('Over 10 years', 11, 100);

  const ExperienceBand(this.label, this.min, this.max);
  final String label;
  final int min;
  final int max;
}

List<FilterGroup> workerFilterGroups(List<String> districts) => [
  FilterGroup(
    id: WorkerFilterKeys.district,
    title: 'District',
    icon: Icons.place_outlined,
    options: districts,
  ),
  FilterGroup(
    id: WorkerFilterKeys.availability,
    title: 'Availability',
    icon: Icons.event_available_outlined,
    options: [for (final a in WorkerAvailability.values) a.label],
  ),
  FilterGroup(
    id: WorkerFilterKeys.experience,
    title: 'Experience',
    icon: Icons.workspace_premium_outlined,
    options: [for (final e in ExperienceBand.values) e.label],
  ),
];

List<WorkerProfile> applyWorkerFilters(
  List<WorkerProfile> workers, {
  String query = '',
  WorkCategory? category,
  FilterSelection filters = const {},
}) {
  final q = query.trim().toLowerCase();
  final districts = filters[WorkerFilterKeys.district] ?? const {};
  final availability = filters[WorkerFilterKeys.availability] ?? const {};
  final bands = [
    for (final b in ExperienceBand.values)
      if (filters[WorkerFilterKeys.experience]?.contains(b.label) ?? false) b,
  ];

  final result = workers.where((w) {
    if (category != null && w.category != category) return false;
    if (districts.isNotEmpty &&
        !districts.contains(w.district) &&
        !w.preferredLocations.any(districts.contains)) {
      return false;
    }
    if (availability.isNotEmpty && !availability.contains(w.availability.label)) return false;
    if (bands.isNotEmpty && !bands.any((b) => w.yearsExperience >= b.min && w.yearsExperience <= b.max)) {
      return false;
    }
    if (q.isEmpty) return true;
    final haystack = [
      w.name,
      w.category.name,
      w.headline,
      w.district,
      w.locality,
      ...w.skills,
    ].join(' ').toLowerCase();
    return q.split(RegExp(r'\s+')).every(haystack.contains);
  }).toList();

  result.sort((a, b) {
    final avail = a.availability.index.compareTo(b.availability.index);
    return avail != 0 ? avail : b.rating.compareTo(a.rating);
  });
  return result;
}
