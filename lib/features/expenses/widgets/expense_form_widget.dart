// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:expense_tracking_desktop_app/constants/strings.dart';
import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/providers/app_providers.dart';
import 'package:expense_tracking_desktop_app/utils/icon_utils.dart';
import 'package:expense_tracking_desktop_app/widgets/buttons.dart';

class ExpenseFormWidget extends ConsumerStatefulWidget {
  const ExpenseFormWidget({
    required this.formKey,
    required this.amountController,
    required this.descriptionController,
    required this.selectedDate,
    required this.selectedCategoryId,
    required this.onDateChanged,
    required this.onCategoryChanged,
    required this.onSubmit,
    required this.onReset,
    super.key,
    this.isEditing = false,
    this.isSubmitting = false,
    this.isReimbursable = false,
    this.onReimbursableChanged,
    this.receiptPath,
    this.onAttachReceipt,
    this.onRemoveReceipt,
  });
  final GlobalKey<FormState> formKey;
  final TextEditingController amountController;
  final TextEditingController descriptionController;
  final DateTime selectedDate;
  final int? selectedCategoryId;
  final void Function(DateTime) onDateChanged;
  final void Function(int?) onCategoryChanged;
  final VoidCallback? onSubmit;
  final VoidCallback onReset;
  final bool isEditing;
  final bool isSubmitting;
  final bool isReimbursable;
  final void Function(bool)? onReimbursableChanged;
  final String? receiptPath;
  final VoidCallback? onAttachReceipt;
  final VoidCallback? onRemoveReceipt;

  @override
  ConsumerState<ExpenseFormWidget> createState() => _ExpenseFormWidgetState();
}

class _ExpenseFormWidgetState extends ConsumerState<ExpenseFormWidget> {
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != widget.selectedDate) {
      widget.onDateChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Form(
          key: widget.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Amount Field
              Text(AppStrings.labelAmount, style: AppTextStyles.label),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: widget.amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                style: AppTextStyles.bodyLarge,
                decoration: InputDecoration(
                  hintText: '0.00',
                  suffixText: AppStrings.currency,
                  filled: true,
                  fillColor: colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    borderSide: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    borderSide: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    borderSide: BorderSide(color: colorScheme.primary),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.xl),

              // Category Dropdown
              Text(AppStrings.labelCategory, style: AppTextStyles.label),
              const SizedBox(height: AppSpacing.sm),
              StreamBuilder<List<Category>>(
                stream:
                    ref.watch(categoryRepositoryProvider).watchAllCategories(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final categories = snapshot.data!;
                  return DropdownButtonFormField<int>(
                    // Use initialValue for form field initialization
                    value: widget.selectedCategoryId,
                    items: categories.map((category) {
                      return DropdownMenuItem(
                        value: category.id,
                        child: Row(
                          children: [
                            Icon(
                              IconUtils.fromCodePoint(category.iconCodePoint),
                              color: Color(category.color),
                              size: AppSpacing.iconSm,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Text(category.name),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: widget.onCategoryChanged,
                    decoration: InputDecoration(
                      hintText: 'Select Category',
                      filled: true,
                      fillColor: colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusLg),
                        borderSide:
                            BorderSide(color: colorScheme.outlineVariant),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusLg),
                        borderSide:
                            BorderSide(color: colorScheme.outlineVariant),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusLg),
                        borderSide: BorderSide(color: colorScheme.primary),
                      ),
                    ),
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a category';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 24),

              // Date Picker
              Text('Date', style: AppTextStyles.label),
              const SizedBox(height: AppSpacing.sm),
              Semantics(
                button: true,
                label:
                    'Select date, currently ${DateFormat('MMM dd, yyyy').format(widget.selectedDate)}',
                child: InkWell(
                  onTap: () => _selectDate(context),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today,
                            color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: AppSpacing.md),
                        Text(
                          DateFormat('MMM dd, yyyy')
                              .format(widget.selectedDate),
                          style: AppTextStyles.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Description Field
              Text(AppStrings.labelDescription, style: AppTextStyles.label),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: widget.descriptionController,
                maxLines: 3,
                style: AppTextStyles.bodyLarge,
                decoration: InputDecoration(
                  hintText: AppStrings.hintDescription,
                  filled: true,
                  fillColor: colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    borderSide: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    borderSide: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    borderSide: BorderSide(color: colorScheme.primary),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.xl),

              // Reimbursable Checkbox
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: CheckboxListTile(
                  value: widget.isReimbursable,
                  onChanged: widget.onReimbursableChanged != null
                      ? (value) =>
                          widget.onReimbursableChanged!(value ?? false)
                      : null,
                  title: Text(
                    AppStrings.labelReimbursableExpense,
                    style: AppTextStyles.bodyLarge,
                  ),
                  subtitle: Text(
                    AppStrings.labelReimbursableHint,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  secondary: Icon(
                    Icons.monetization_on_outlined,
                    color: widget.isReimbursable
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  ),
                  controlAffinity: ListTileControlAffinity.trailing,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Receipt Attachment Section
              Text(AppStrings.labelReceipt, style: AppTextStyles.label),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  border: Border.all(
                    color: widget.receiptPath != null
                        ? colorScheme.primary.withOpacity(0.5)
                        : colorScheme.outlineVariant,
                  ),
                ),
                child: widget.receiptPath != null
                    ? Row(
                        children: [
                          Icon(
                            Icons.attachment,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppStrings.msgReceiptAttached,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: colorScheme.primary,
                                  ),
                                ),
                                Text(
                                  _getFileName(widget.receiptPath!),
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              color: colorScheme.error,
                            ),
                            onPressed: widget.onRemoveReceipt,
                            tooltip: AppStrings.labelRemoveReceipt,
                          ),
                        ],
                      )
                    : InkWell(
                        onTap: widget.onAttachReceipt,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusSm),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.sm,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.upload_file,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                AppStrings.labelAttachReceipt,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Action Buttons
              if (!widget.isEditing)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TertiaryButton(
                      onPressed: widget.isSubmitting ? null : widget.onReset,
                      icon: Icons.refresh,
                      child: const Text(AppStrings.btnReset),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    PrimaryButton(
                      onPressed: widget.onSubmit,
                      icon: Icons.add,
                      isLoading: widget.isSubmitting,
                      child: Text(widget.isSubmitting
                          ? 'Adding...'
                          : AppStrings.btnAddExpense),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getFileName(String path) {
    final parts = path.split(RegExp(r'[/\\]'));
    return parts.isNotEmpty ? parts.last : path;
  }
}
