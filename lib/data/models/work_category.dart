import 'package:flutter/widgets.dart';

/// A trade or type of work, such as Mason or Electrician.
@immutable
class WorkCategory {
  const WorkCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.workerNoun,
    this.suggestedSkills = const [],
  });

  final String id;
  final String name;
  final IconData icon;

  /// Plural noun for the people in this trade, for example "masons".
  final String workerNoun;

  /// Skills offered as quick picks in the post-work form.
  final List<String> suggestedSkills;

  @override
  bool operator ==(Object other) => other is WorkCategory && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
