import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/l10n/app_localizations.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/models/employee_model.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';

/// Add Employee Form Dialog
/// Desktop-optimized form for adding new employees
class AddEmployeeForm extends StatefulWidget {
  const AddEmployeeForm({
    required this.onSubmit,
    super.key,
  });
  final void Function(Employee) onSubmit;

  @override
  State<AddEmployeeForm> createState() => _AddEmployeeFormState();
}

class _AddEmployeeFormState extends State<AddEmployeeForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _roleController = TextEditingController();

  String _selectedDepartment = 'Engineering';
  EmployeeStatus _selectedStatus = EmployeeStatus.active;
  DateTime _hireDate = DateTime.now();

  List<String> _getDepartments(BuildContext context) => [
        AppLocalizations.of(context)!.deptEngineering,
        AppLocalizations.of(context)!.deptMarketing,
        AppLocalizations.of(context)!.deptSales,
        AppLocalizations.of(context)!.deptProduct,
        AppLocalizations.of(context)!.deptDesign,
        AppLocalizations.of(context)!.deptHumanResources,
        AppLocalizations.of(context)!.deptFinance,
      ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  AppLocalizations.of(context)!.labelAddNewEmployee,
                  style: AppTextStyles.heading2,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  AppLocalizations.of(context)!.labelFillEmployeeDetails,
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Full Name
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: '${AppLocalizations.of(context)!.fullName} *',
                    hintText: 'John Doe',
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppLocalizations.of(context)!
                          .errEmployeeNameRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                // Email
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: '${AppLocalizations.of(context)!.labelEmail} *',
                    hintText: 'john.doe@company.com',
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppLocalizations.of(context)!.errEnterEmail;
                    }
                    if (!value.contains('@')) {
                      return AppLocalizations.of(context)!.errInvalidEmail;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                // Phone
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: '${AppLocalizations.of(context)!.location} *',
                    hintText: '+213 555-0123',
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppLocalizations.of(context)!.errPhoneRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                // Role
                TextFormField(
                  controller: _roleController,
                  decoration: InputDecoration(
                    labelText: '${AppLocalizations.of(context)!.labelRole} *',
                    hintText: AppLocalizations.of(context)!.hintRole,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppLocalizations.of(context)!.errRoleRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                // Department
                DropdownButtonFormField<String>(
                  value: _selectedDepartment,
                  decoration: InputDecoration(
                    labelText:
                        '${AppLocalizations.of(context)!.labelDepartment} *',
                    border: const OutlineInputBorder(),
                  ),
                  items: _getDepartments(context).map((dept) {
                    return DropdownMenuItem(
                      value: dept,
                      child: Text(dept),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedDepartment = value);
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                // Hire Date
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _hireDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => _hireDate = picked);
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText:
                          '${AppLocalizations.of(context)!.labelHireDate} *',
                      border: const OutlineInputBorder(),
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      '${_hireDate.day}/${_hireDate.month}/${_hireDate.year}',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Status
                DropdownButtonFormField<EmployeeStatus>(
                  value: _selectedStatus,
                  decoration: InputDecoration(
                    labelText: '${AppLocalizations.of(context)!.labelStatus} *',
                    border: const OutlineInputBorder(),
                  ),
                  items: EmployeeStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status == EmployeeStatus.suspended
                          ? AppLocalizations.of(context)!.labelStatusSuspended
                          : status.displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedStatus = value);
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(AppLocalizations.of(context)!.btnCancel),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    FilledButton(
                      onPressed: _handleSubmit,
                      child:
                          Text(AppLocalizations.of(context)!.labelAddEmployee),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final employee = Employee(
        id: 'emp${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text.trim(),
        role: _roleController.text.trim(),
        department: _selectedDepartment,
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        hireDate: _hireDate,
        status: _selectedStatus,
      );

      widget.onSubmit(employee);
      Navigator.of(context).pop();
    }
  }
}
