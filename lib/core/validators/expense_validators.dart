/// Validation rules for expense-related data
class ExpenseValidators {
  ExpenseValidators._();

  /// Validates expense amount
  ///
  /// Returns null if valid, error message if invalid
  static String? validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Amount is required';
    }

    final amount = double.tryParse(value.trim());
    if (amount == null) {
      return 'Please enter a valid number';
    }

    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }

    if (amount > 1000000) {
      return 'Amount exceeds maximum limit of \$1,000,000';
    }

    // Check for reasonable decimal places (max 2)
    final parts = value.split('.');
    if (parts.length == 2 && parts[1].length > 2) {
      return 'Amount can have at most 2 decimal places';
    }

    return null;
  }

  /// Validates expense description
  ///
  /// Returns null if valid, error message if invalid
  static String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Description is required';
    }

    final trimmed = value.trim();

    if (trimmed.length < 3) {
      return 'Description must be at least 3 characters';
    }

    if (trimmed.length > 200) {
      return 'Description is too long (max 200 characters)';
    }

    // Check for invalid characters
    if (trimmed.contains(RegExp(r'[<>]'))) {
      return 'Description contains invalid characters';
    }

    return null;
  }

  /// Validates category ID selection
  ///
  /// Returns null if valid, error message if invalid
  static String? validateCategory(int? categoryId) {
    if (categoryId == null) {
      return 'Please select a category';
    }

    if (categoryId <= 0) {
      return 'Invalid category selected';
    }

    return null;
  }

  /// Validates expense date
  ///
  /// Returns null if valid, error message if invalid
  static String? validateDate(DateTime? date) {
    if (date == null) {
      return 'Date is required';
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = DateTime(date.year, date.month, date.day);

    // Don't allow future dates
    if (selectedDate.isAfter(today)) {
      return 'Expense date cannot be in the future';
    }

    // Don't allow dates more than 10 years old
    final tenYearsAgo = today.subtract(const Duration(days: 365 * 10));
    if (selectedDate.isBefore(tenYearsAgo)) {
      return 'Expense date cannot be more than 10 years old';
    }

    return null;
  }

  /// Validates a parsed amount value (for use in business logic)
  static bool isValidAmountValue(double amount) {
    return amount > 0 && amount <= 1000000;
  }
}
