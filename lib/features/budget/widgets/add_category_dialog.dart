import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:expense_tracking_desktop_app/constants/strings.dart';
import 'package:expense_tracking_desktop_app/constants/category_options.dart';

/// Dialog for adding a new budget category
class AddCategoryDialog extends StatefulWidget {
  final Function(String name, double budget, int color, String iconCodePoint)
      onAdd;

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
  int _selectedColor = CategoryColors.colors[0].value;
  String _selectedIcon = CategoryIcons.icons[0].codePoint.toString();

  @override
  void dispose() {
    _nameController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AlertDialog(
      backgroundColor: colorScheme.surface,
      title: Text('Add New Category', style: AppTextStyles.heading3),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildNameField(),
            const SizedBox(height: AppSpacing.lg),
            _buildBudgetField(),
            const SizedBox(height: AppSpacing.lg),
            _buildColorPicker(colorScheme),
            const SizedBox(height: AppSpacing.lg),
            _buildIconPicker(colorScheme),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppStrings.btnCancel, style: AppTextStyles.bodyMedium),
        ),
        FilledButton(
          onPressed: _handleAdd,
          child: const Text(AppStrings.btnAdd),
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return TextField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'Category Name',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildBudgetField() {
    return TextField(
      controller: _budgetController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      decoration: InputDecoration(
        labelText: 'Monthly Budget',
        prefixText: 'DZD ',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildColorPicker(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.labelColor, style: AppTextStyles.label),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: CategoryColors.colors.map((color) {
            final isSelected = _selectedColor == color.value;
            return Semantics(
              button: true,
              label: 'Color option${isSelected ? ", selected" : ""}',
              selected: isSelected,
              child: InkWell(
                onTap: () => setState(() => _selectedColor = color.value),
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl + 4),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: colorScheme.onSurface, width: 2)
                        : null,
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: AppSpacing.iconXs + 2,
                        )
                      : null,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildIconPicker(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.labelIcon, style: AppTextStyles.label),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 200,
          child: SingleChildScrollView(
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: CategoryIcons.icons.map((icon) {
                final isSelected = _selectedIcon == icon.codePoint.toString();
                return Semantics(
                  button: true,
                  label: 'Category icon${isSelected ? ", selected" : ""}',
                  selected: isSelected,
                  child: InkWell(
                    onTap: () => setState(
                        () => _selectedIcon = icon.codePoint.toString()),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colorScheme.primary.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusSm),
                        border: isSelected
                            ? Border.all(color: colorScheme.primary)
                            : Border.all(color: colorScheme.outlineVariant),
                      ),
                      child: Icon(
                        icon,
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                        size: AppSpacing.iconMd,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  void _handleAdd() {
    if (_nameController.text.isEmpty) {
      return;
    }

    final budget = double.tryParse(_budgetController.text) ?? 0.0;
    
    // Validate budget is not negative
    if (budget < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Budget cannot be negative'),
        ),
      );
      return;
    }
    
    // Validate budget is reasonable (not more than 1 billion)
    if (budget > 1000000000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Budget value is too large'),
        ),
      );
      return;
    }
    
    widget.onAdd(
      _nameController.text,
      budget,
      _selectedColor,
      _selectedIcon,
    );
    Navigator.pop(context);
  }
}
