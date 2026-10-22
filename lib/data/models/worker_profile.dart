import 'package:flutter/foundation.dart';

import 'work_category.dart';

enum WorkerAvailability {
  available('Available now'),
  soon('Available soon'),
  busy('Currently busy');

  const WorkerAvailability(this.label);
  final String label;
}

@immutable
class WorkHistoryItem {
  const WorkHistoryItem({required this.title, required this.place, required this.period});

  final String title;
  final String place;
  final String period;
}

@immutable
class Review {
  const Review({required this.author, required this.rating, required this.comment, required this.whenLabel});

  final String author;
  final double rating;
  final String comment;
  final String whenLabel;
}

/// A sample tradesperson profile. Contains no real contact details.
@immutable
class WorkerProfile {
  const WorkerProfile({
    required this.id,
    required this.name,
    required this.category,
    required this.headline,
    required this.district,
    required this.locality,
    required this.yearsExperience,
    required this.rating,
    required this.reviewCount,
    required this.jobsCompleted,
    required this.availability,
    required this.skills,
    required this.preferredLocations,
    required this.languages,
    required this.about,
    required this.workHistory,
    required this.reviews,
    this.portfolioLabels = const [],
    this.dailyRateFrom,
    this.isDemoVerified = false,
  });

  final String id;
  final String name;
  final WorkCategory category;
  final String headline;
  final String district;
  final String locality;
  final int yearsExperience;
  final double rating;
  final int reviewCount;
  final int jobsCompleted;
  final WorkerAvailability availability;
  final List<String> skills;
  final List<String> preferredLocations;
  final List<String> languages;
  final String about;
  final List<WorkHistoryItem> workHistory;
  final List<Review> reviews;

  /// Captions for portfolio image placeholders.
  final List<String> portfolioLabels;
  final int? dailyRateFrom;

  /// Sample verification flag. Nothing has been verified by a real service.
  final bool isDemoVerified;

  WorkerProfile copyWith({
    String? name,
    String? headline,
    String? about,
    WorkerAvailability? availability,
    List<String>? skills,
    List<String>? preferredLocations,
    String? district,
  }) {
    return WorkerProfile(
      id: id,
      name: name ?? this.name,
      category: category,
      headline: headline ?? this.headline,
      district: district ?? this.district,
      locality: locality,
      yearsExperience: yearsExperience,
      rating: rating,
      reviewCount: reviewCount,
      jobsCompleted: jobsCompleted,
      availability: availability ?? this.availability,
      skills: skills ?? this.skills,
      preferredLocations: preferredLocations ?? this.preferredLocations,
      languages: languages,
      about: about ?? this.about,
      workHistory: workHistory,
      reviews: reviews,
      portfolioLabels: portfolioLabels,
      dailyRateFrom: dailyRateFrom,
      isDemoVerified: isDemoVerified,
    );
  }
}
