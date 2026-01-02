import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/constants/colors.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';

/// Password validation requirements
class PasswordRequirement {
  final String description;
  final bool Function(String) validator;

  const PasswordRequirement({
    required this.description,
    required this.validator,
  });
}

/// Password validator utility
class PasswordValidator {
  /// Minimum password length
  static const int minLength = 8;

  /// Password requirements list
  static final List<PasswordRequirement> requirements = [
    PasswordRequirement(
      description: 'At least $minLength characters',
      validator: (password) => password.length >= minLength,
    ),
    PasswordRequirement(
      description: 'At least one uppercase letter (A-Z)',
      validator: (password) => RegExp(r'[A-Z]').hasMatch(password),
    ),
    PasswordRequirement(
      description: 'At least one lowercase letter (a-z)',
      validator: (password) => RegExp(r'[a-z]').hasMatch(password),
    ),
    PasswordRequirement(
      description: 'At least one number (0-9)',
      validator: (password) => RegExp(r'[0-9]').hasMatch(password),
    ),
    PasswordRequirement(
      description: 'At least one special character (!@#\$%^&*)',
      validator: (password) =>
          RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password),
    ),
  ];

  /// Validate password against all requirements
  static bool isValid(String password) {
    return requirements.every((req) => req.validator(password));
  }

  /// Get validation error message (returns null if valid)
  static String? validate(String? password) {
    if (password == null || password.isEmpty) {
      return 'Please enter a password';
    }

    if (password.length < minLength) {
      return 'Password must be at least $minLength characters';
    }

    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Password must contain at least one lowercase letter';
    }

    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password must contain at least one number';
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return 'Password must contain at least one special character';
    }

    return null;
  }

  /// Get list of unmet requirements
  static List<PasswordRequirement> getUnmetRequirements(String password) {
    return requirements.where((req) => !req.validator(password)).toList();
  }

  /// Get password strength (0.0 to 1.0)
  static double getStrength(String password) {
    if (password.isEmpty) return 0.0;

    int metRequirements =
        requirements.where((req) => req.validator(password)).length;
    return metRequirements / requirements.length;
  }

  /// Get strength label
  static String getStrengthLabel(double strength) {
    if (strength <= 0.2) return 'Very Weak';
    if (strength <= 0.4) return 'Weak';
    if (strength <= 0.6) return 'Fair';
    if (strength <= 0.8) return 'Strong';
    return 'Very Strong';
  }

  /// Get strength color
  static Color getStrengthColor(double strength) {
    if (strength <= 0.2) return AppColors.red;
    if (strength <= 0.4) return AppColors.orange;
    if (strength <= 0.6) return const Color(0xFFEAB308); // Yellow/Amber
    if (strength <= 0.8) return AppColors.green;
    return AppColors.green;
  }
}

/// Widget to display password requirements
class PasswordRequirementsWidget extends StatelessWidget {
  final String password;

  const PasswordRequirementsWidget({
    super.key,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    final strength = PasswordValidator.getStrength(password);
    final strengthLabel = PasswordValidator.getStrengthLabel(strength);
    final strengthColor = PasswordValidator.getStrengthColor(strength);

    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: strength,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          strengthLabel,
          style: AppTextStyles.bodySmall.copyWith(
            color: strengthColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
