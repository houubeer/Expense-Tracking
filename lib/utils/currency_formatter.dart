/// Utility class for formatting currency values
class CurrencyFormatter {
  /// Format amount with currency symbol
  static String format(double amount,
      {String currency = 'DZD', int decimals = 2}) {
    return '${amount.toStringAsFixed(decimals)} $currency';
  }

  /// Format amount without decimals
  static String formatWhole(double amount, {String currency = 'DZD'}) {
    return '${amount.toStringAsFixed(0)} $currency';
  }

  /// Format percentage
  static String formatPercentage(double percentage, {int decimals = 1}) {
    return '${percentage.toStringAsFixed(decimals)}%';
  }
}
