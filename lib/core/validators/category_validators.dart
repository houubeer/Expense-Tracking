/// Validation rules for category-related data
class CategoryValidators {
  CategoryValidators._();

  /// Validates category name
  ///
  /// Returns null if valid, error message if invalid
  static String? validateCategoryName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Category name is required';
    }

    final trimmed = value.trim();

    if (trimmed.length < 2) {
      return 'Category name must be at least 2 characters';
    }

    if (trimmed.length > 50) {
      return 'Category name is too long (max 50 characters)';
    }

    // Check for invalid characters
    if (trimmed.contains(RegExp(r'[<>;]'))) {
      return 'Category name contains invalid characters';
    }

    // Check for SQL injection attempts
    final lowerCase = trimmed.toLowerCase();
    if (lowerCase.contains('drop ') ||
        lowerCase.contains('delete ') ||
        lowerCase.contains('insert ') ||
        lowerCase.contains('update ')) {
      return 'Category name contains invalid keywords';
    }

    return null;
  }

  /// Validates category budget
  ///
  /// Returns null if valid, error message if invalid
  static String? validateBudget(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Budget is required';
    }

    final budget = double.tryParse(value.trim());
    if (budget == null) {
      return 'Please enter a valid number';
    }

    if (budget < 0) {
      return 'Budget cannot be negative';
    }

    if (budget > 10000000) {
      return 'Budget exceeds maximum limit of \$10,000,000';
    }

    // Check for reasonable decimal places (max 2)
    final parts = value.split('.');
    if (parts.length == 2 && parts[1].length > 2) {
      return 'Budget can have at most 2 decimal places';
    }

    return null;
  }

  /// Validates a parsed budget value (for use in business logic)
  static bool isValidBudgetValue(double budget) {
    return budget >= 0 && budget <= 10000000;
  }

  /// Validates category color value
  ///
  /// Returns null if valid, error message if invalid
  static String? validateColor(int? color) {
    if (color == null) {
      return 'Please select a color';
    }

    if (color < 0 || color > 0xFFFFFFFF) {
      return 'Invalid color value';
    }

    return null;
  }

  /// Validates icon code point
  ///
  /// Returns null if valid, error message if invalid
  static String? validateIconCodePoint(String? iconCodePoint) {
    if (iconCodePoint == null || iconCodePoint.trim().isEmpty) {
      return 'Please select an icon';
    }

    final trimmed = iconCodePoint.trim();

    if (trimmed.length > 10) {
      return 'Invalid icon code point';
    }

    return null;
  }
}
