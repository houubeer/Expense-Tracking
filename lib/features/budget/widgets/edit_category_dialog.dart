import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/features/budget/repositories/i_category_repository.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:expense_tracking_desktop_app/constants/strings.dart';
import 'package:expense_tracking_desktop_app/widgets/buttons.dart';

class EditCategoryDialog extends StatefulWidget {
  final ICategoryRepository categoryRepository;
  final Category category;
  final TextEditingController budgetController;

  const EditCategoryDialog({
    super.key,
    required this.categoryRepository,
    required this.category,
    required this.budgetController,
  });

  @override
  State<EditCategoryDialog> createState() => _EditCategoryDialogState();
}

class _EditCategoryDialogState extends State<EditCategoryDialog> {
  late Color _selectedColor;
  late IconData _selectedIcon;

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
  void initState() {
    super.initState();
    _selectedColor = Color(widget.category.color);
    _selectedIcon = _getIconFromCodePoint(widget.category.iconCodePoint);
  }

  IconData _getIconFromCodePoint(String codePointStr) {
    try {
      final codePoint = int.parse(codePointStr);
      return IconData(codePoint, fontFamily: 'MaterialIcons');
    } catch (e) {
      return Icons.category;
    }
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
                  Text('Edit ${widget.category.name}',
                      style: AppTextStyles.heading3),
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

              // Budget Field
              TextField(
                controller: widget.budgetController,
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
                  final isSelected = color.value == _selectedColor.value;
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
                                  color: color.withOpacity(0.4),
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
                                ? _selectedColor.withOpacity(0.2)
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
                    onPressed: () async {
                      final navigator = Navigator.of(context);
                      final messenger = ScaffoldMessenger.of(context);
                      final value =
                          double.tryParse(widget.budgetController.text) ?? 0.0;
                      if (value < 0) {
                        final colorScheme = Theme.of(context).colorScheme;
                        messenger.showSnackBar(
                          SnackBar(
                            content: const Text(AppStrings.errBudgetNegative),
                            backgroundColor: colorScheme.error,
                          ),
                        );
                        return;
                      }

                      try {
                        // Update category with new values
                        final updatedCategory = widget.category.copyWith(
                          budget: value,
                          color: _selectedColor.value,
                          iconCodePoint: _selectedIcon.codePoint.toString(),
                        );

                        await widget.categoryRepository
                            .updateCategory(updatedCategory);

                        if (mounted) {
                          final colorScheme = Theme.of(context).colorScheme;
                          navigator.pop();
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                '${AppStrings.msgCategoryUpdated} ${widget.category.name}',
                              ),
                              backgroundColor: colorScheme.tertiary,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          final colorScheme = Theme.of(context).colorScheme;
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Failed to update category: ${e.toString()}'),
                              backgroundColor: colorScheme.error,
                            ),
                          );
                        }
                      }
                    },
                    child: const Text(AppStrings.btnSaveChanges),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
