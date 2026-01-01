import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/models/employee_model.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:expense_tracking_desktop_app/constants/strings.dart';

/// Add Employee Form Dialog
/// Desktop-optimized form for adding new employees
class AddEmployeeForm extends StatefulWidget {
  final void Function(Employee) onSubmit;

  const AddEmployeeForm({
    super.key,
    required this.onSubmit,
  });

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

  final List<String> _departments = [
    'Engineering',
    'Marketing',
    'Sales',
    'Product',
    'Design',
    'Human Resources',
    'Finance',
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
                  'Add New Employee',
                  style: AppTextStyles.heading2,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Fill in the employee details below',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Full Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name *',
                    hintText: 'John Doe',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter employee name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                // Email
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email *',
                    hintText: 'john.doe@company.com',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                // Phone
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone *',
                    hintText: '+213 555-0123',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                // Role
                TextFormField(
                  controller: _roleController,
                  decoration: const InputDecoration(
                    labelText: 'Role *',
                    hintText: 'Software Engineer',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter role';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                // Department
                DropdownButtonFormField<String>(
                  value: _selectedDepartment,
                  decoration: const InputDecoration(
                    labelText: 'Department *',
                    border: OutlineInputBorder(),
                  ),
                  items: _departments.map((dept) {
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
                    decoration: const InputDecoration(
                      labelText: 'Hire Date *',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
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
                  decoration: const InputDecoration(
                    labelText: 'Status *',
                    border: OutlineInputBorder(),
                  ),
                  items: EmployeeStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status.displayName),
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
                      child: const Text(AppStrings.btnCancel),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    FilledButton(
                      onPressed: _handleSubmit,
                      child: const Text('Add Employee'),
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
