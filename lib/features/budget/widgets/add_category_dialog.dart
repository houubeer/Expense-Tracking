import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:expense_tracking_desktop_app/constants/strings.dart';
import 'package:expense_tracking_desktop_app/widgets/buttons.dart';

/// Dialog for adding a new budget category
class AddCategoryDialog extends StatefulWidget {
  final void Function(
      String name, double budget, int color, String iconCodePoint) onAdd;

  const AddCategoryDialog({
    super.key,
    required this.onAdd,
  });

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final _nameController = TextEditingController();
  final _budgetController = TextEditingController();
  Color _selectedColor = const Color(0xFF9333EA); // Purple
  IconData _selectedIcon = Icons.category;

  // Common category colors
  final List<Color> _categoryColors = [
    const Color(0xFF9333EA), // Purple
    const Color(0xFF06B6D4), // Teal
    const Color(0xFF6366F1), // Indigo
    const Color(0xFFF59E0B), // Orange
    const Color(0xFF10B981), // Green
    const Color(0xFFEF4444), // Red
    const Color(0xFF28448B), // Blue
    const Color(0xFF3d5a9e), // Light Blue
    const Color(0xFF818CF8), // Light Indigo
    const Color(0xFF1a2a52), // Dark Blue
  ];

  // Common category icons
  final List<IconData> _categoryIcons = [
    Icons.category,
    Icons.shopping_cart,
    Icons.restaurant,
    Icons.local_gas_station,
    Icons.home,
    Icons.directions_car,
    Icons.flight,
    Icons.hotel,
    Icons.medical_services,
    Icons.school,
    Icons.fitness_center,
    Icons.devices,
    Icons.subscriptions,
    Icons.lightbulb,
    Icons.build,
    Icons.shopping_bag,
    Icons.local_cafe,
    Icons.sports_esports,
    Icons.music_note,
    Icons.pets,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Dialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        padding: const EdgeInsets.all(AppSpacing.xxxl - 8),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Add New Category', style: AppTextStyles.heading3),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    color: colorScheme.onSurfaceVariant,
                    tooltip: 'Close',
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl - 8),
              Divider(color: colorScheme.outlineVariant),
              const SizedBox(height: AppSpacing.xxl - 8),

              // Name Field
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Category Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    borderSide: BorderSide(color: colorScheme.primary),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl - 8),

              // Budget Field
              TextField(
                controller: _budgetController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: InputDecoration(
                  labelText: AppStrings.labelMonthlyBudget,
                  prefixText: AppStrings.currencyPrefix,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    borderSide: BorderSide(color: colorScheme.primary),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl - 8),

              // Color Picker
              Text(AppStrings.labelColor, style: AppTextStyles.label),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: _categoryColors.map((color) {
                  final isSelected = color == _selectedColor;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? colorScheme.onSurface
                              : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withAlpha(102),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ]
                            : [],
                      ),
                      child: isSelected
                          ? const Icon(Icons.check,
                              color: Colors.white, size: AppSpacing.iconMd)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.xxl - 8),

              // Icon Picker
              Text(AppStrings.labelIcon, style: AppTextStyles.label),
              const SizedBox(height: AppSpacing.md),
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: _categoryIcons.map((icon) {
                      final isSelected =
                          icon.codePoint == _selectedIcon.codePoint;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedIcon = icon),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? _selectedColor.withAlpha(51)
                                : colorScheme.surfaceContainerHighest,
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusSm),
                            border: Border.all(
                              color: isSelected
                                  ? _selectedColor
                                  : colorScheme.outlineVariant,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            icon,
                            color: isSelected
                                ? _selectedColor
                                : colorScheme.onSurfaceVariant,
                            size: AppSpacing.iconMd,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: colorScheme.onSurfaceVariant,
                    ),
                    child: const Text(AppStrings.btnCancel),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  PrimaryButton(
                    onPressed: _handleAdd,
                    child: const Text(AppStrings.btnAdd),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleAdd() {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    if (_nameController.text.isEmpty) {
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Please enter a category name'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final budget = double.tryParse(_budgetController.text) ?? 0.0;

    // Validate budget is not negative
    if (budget < 0) {
      messenger.showSnackBar(
        SnackBar(
          content: const Text(AppStrings.errBudgetNegative),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    // Validate budget is reasonable (not more than 1 billion)
    if (budget > 1000000000) {
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Budget value is too large'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    widget.onAdd(
      _nameController.text,
      budget,
      // ignore: deprecated_member_use
      _selectedColor.value,
      _selectedIcon.codePoint.toString(),
    );
    navigator.pop();
  }
}
