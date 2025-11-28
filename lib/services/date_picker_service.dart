import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/constants/colors.dart';

/// Service for consistent date picker configuration across the app
class DatePickerService {
  /// Shows a date picker dialog with consistent theming
  ///
  /// Returns the selected date or null if cancelled
  static Future<DateTime?> selectDate(
    BuildContext context, {
    required DateTime initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    return await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.textInverse,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
  }
}
