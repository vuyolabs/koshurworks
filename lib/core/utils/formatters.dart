/// Small, dependency-free formatters for the prototype.
abstract final class Formatters {
  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  /// Formats rupees with Indian digit grouping, for example ₹1,25,000.
  static String rupees(int amount) {
    final digits = amount.abs().toString();
    if (digits.length <= 3) return '₹$digits';
    final last3 = digits.substring(digits.length - 3);
    var rest = digits.substring(0, digits.length - 3);
    final groups = <String>[];
    while (rest.length > 2) {
      groups.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) groups.insert(0, rest);
    return '₹${groups.join(',')},$last3';
  }

  /// "Mon, 27 Oct"
  static String shortDate(DateTime d) => '${_weekdays[d.weekday - 1]}, ${d.day} ${_months[d.month - 1]}';

  /// "27 Oct 2026"
  static String longDate(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

  /// "Just now", "3h ago", "2d ago"
  static String timeAgo(DateTime then, {DateTime? now}) {
    final diff = (now ?? DateTime.now()).difference(then);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return longDate(then);
  }

  /// "Starts today", "Starts tomorrow", "Starts Mon, 27 Oct"
  static String startLabel(DateTime start, {DateTime? now}) {
    final today = _dateOnly(now ?? DateTime.now());
    final days = _dateOnly(start).difference(today).inDays;
    if (days <= 0) return 'Starts today';
    if (days == 1) return 'Starts tomorrow';
    return 'Starts ${shortDate(start)}';
  }

  static String greeting({DateTime? now}) {
    final hour = (now ?? DateTime.now()).hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  static String initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  static String plural(int count, String singular, [String? pluralForm]) =>
      '$count ${count == 1 ? singular : (pluralForm ?? '${singular}s')}';

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}
