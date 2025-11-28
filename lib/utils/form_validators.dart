/// Reusable form validation rules
class FormValidators {
  /// Validates that a field is not empty
  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates that a numeric field is a valid positive number
  static String? positiveNumber(String? value, {String fieldName = 'Amount'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    
    final number = double.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }
    
    if (number <= 0) {
      return '$fieldName must be greater than 0';
    }
    
    return null;
  }

  /// Validates that a numeric field is a valid non-negative number
  static String? nonNegativeNumber(String? value, {String fieldName = 'Value'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    
    final number = double.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }
    
    if (number < 0) {
      return '$fieldName cannot be negative';
    }
    
    return null;
  }

  /// Validates maximum length
  static String? maxLength(String? value, int max, {String fieldName = 'This field'}) {
    if (value != null && value.length > max) {
      return '$fieldName must be $max characters or less';
    }
    return null;
  }

  /// Combines multiple validators
  static String? combine(String? value, List<String? Function(String?)> validators) {
    for (final validator in validators) {
      final result = validator(value);
      if (result != null) {
        return result;
      }
    }
    return null;
  }
}
