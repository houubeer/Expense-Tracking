import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/features/budget/repositories/category_repository.dart';
import 'package:expense_tracking_desktop_app/constants/colors.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:expense_tracking_desktop_app/constants/strings.dart';

class EditCategoryDialog extends StatefulWidget {
  final CategoryRepository categoryRepository;
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
    AppColors.purple,
    AppColors.teal,
    AppColors.accent,
    AppColors.orange,
    AppColors.green,
    AppColors.red,
    AppColors.primary,
    AppColors.primaryLight,
    AppColors.accentLight,
    AppColors.primaryDark,
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
    return Dialog(
      backgroundColor: AppColors.surface,
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
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl - 8),
              const Divider(color: AppColors.border),
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
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    borderSide: const BorderSide(color: AppColors.primary),
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
                              ? AppColors.textPrimary
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
                                : AppColors.background,
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusSm),
                            border: Border.all(
                              color: isSelected
                                  ? _selectedColor
                                  : AppColors.border,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            icon,
                            color: isSelected
                                ? _selectedColor
                                : AppColors.textSecondary,
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
                      foregroundColor: AppColors.textSecondary,
                    ),
                    child: const Text(AppStrings.btnCancel),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  ElevatedButton(
                    onPressed: () async {
                      final navigator = Navigator.of(context);
                      final messenger = ScaffoldMessenger.of(context);
                      final value =
                          double.tryParse(widget.budgetController.text) ?? 0.0;
                      if (value < 0) {
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text(AppStrings.errBudgetNegative),
                            backgroundColor: AppColors.red,
                          ),
                        );
                        return;
                      }

                      // Update category with new values
                      final updatedCategory = widget.category.copyWith(
                        budget: value,
                        color: _selectedColor.value,
                        iconCodePoint: _selectedIcon.codePoint.toString(),
                      );

                      await widget.categoryRepository
                          .updateCategory(updatedCategory);

                      if (mounted) {
                        navigator.pop();
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              '${AppStrings.msgCategoryUpdated} ${widget.category.name}',
                            ),
                            backgroundColor: AppColors.green,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xxl - 8,
                          vertical: AppSpacing.md),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                    ),
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
