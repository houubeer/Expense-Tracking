/// Utility class for formatting dates consistently across the application
class DateFormatters {
  /// Format a date as "MMM DD" (e.g., "Jan 15", "Dec 31")
  static String formatShortDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  /// Truncate a description to a maximum number of words
  static String truncateDescription(String description, {int maxWords = 4}) {
    final words = description.split(' ');
    if (words.length <= maxWords) {
      return description;
    }
    return '${words.take(maxWords).join(' ')}...';
  }
}
