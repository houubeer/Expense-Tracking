import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracking_desktop_app/constants/colors.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:expense_tracking_desktop_app/providers/app_providers.dart';
import 'package:expense_tracking_desktop_app/features/auth/models/user_profile.dart';
import 'package:expense_tracking_desktop_app/features/auth/widgets/employee_card.dart';
import 'package:expense_tracking_desktop_app/features/auth/widgets/add_employee_dialog.dart';

/// Employee management screen for managers to add/remove team members
class EmployeeManagementScreen extends ConsumerStatefulWidget {
  const EmployeeManagementScreen({super.key});

  @override
  ConsumerState<EmployeeManagementScreen> createState() =>
      _EmployeeManagementScreenState();
}

class _EmployeeManagementScreenState
    extends ConsumerState<EmployeeManagementScreen> {
  List<UserProfile> _employees = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _organizationId;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final supabaseService = ref.read(supabaseServiceProvider);

      // Get current user's organization
      final profile = await supabaseService.getCurrentUserProfile();
      if (profile == null) {
        throw Exception('User profile not found');
      }

      _organizationId = profile['organization_id'] as String?;
      if (_organizationId == null) {
        throw Exception('No organization associated with this account');
      }

      // Get employees for this organization
      final employees =
          await supabaseService.getOrganizationMembers(_organizationId!);

      if (!mounted) return;
      setState(() {
        _employees = employees.map((e) => UserProfile.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _addEmployee() async {
    if (_organizationId == null) return;

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => const AddEmployeeDialog(),
    );

    if (result == null) return;

    try {
      final supabaseService = ref.read(supabaseServiceProvider);
      await supabaseService.addEmployee(
        organizationId: _organizationId!,
        email: result['email']!,
        fullName: result['fullName']!,
        password: result['password']!,
      );

      await _loadEmployees();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Employee ${result['fullName']} added successfully'),
          backgroundColor: AppColors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add employee: $e'),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  Future<void> _removeEmployee(UserProfile employee) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Employee?'),
        content: Text(
          'Are you sure you want to remove ${employee.fullName} from the organization? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final supabaseService = ref.read(supabaseServiceProvider);
      await supabaseService.removeEmployee(employee.id);
      await _loadEmployees();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${employee.fullName} has been removed'),
          backgroundColor: AppColors.orange,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to remove employee: $e'),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  Future<void> _toggleEmployeeStatus(UserProfile employee) async {
    try {
      final supabaseService = ref.read(supabaseServiceProvider);
      await supabaseService.updateEmployeeStatus(
        employee.id,
        !employee.isActive,
      );
      await _loadEmployees();

      if (!mounted) return;
      final status = employee.isActive ? 'deactivated' : 'activated';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${employee.fullName} has been $status'),
          backgroundColor: AppColors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update status: $e'),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Team Management'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textInverse,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEmployees,
            tooltip: 'Refresh',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addEmployee,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textInverse,
        icon: const Icon(Icons.person_add),
        label: const Text('Add Employee'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return _buildErrorView();
    }

    if (_employees.isEmpty) {
      return _buildEmptyView();
    }

    return RefreshIndicator(
      onRefresh: _loadEmployees,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.xl),
        itemCount: _employees.length,
        itemBuilder: (context, index) {
          final employee = _employees[index];
          return EmployeeCard(
            employee: employee,
            onToggleStatus: () => _toggleEmployeeStatus(employee),
            onRemove: employee.role != UserRole.manager
                ? () => _removeEmployee(employee)
                : null,
          );
        },
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.red),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Error loading employees',
              style:
                  AppTextStyles.heading2.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _errorMessage!,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: _loadEmployees,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.group_outlined,
              size: 80,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'No Team Members Yet',
              style: AppTextStyles.heading2.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Add employees to your organization to start tracking expenses together.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            ElevatedButton.icon(
              onPressed: _addEmployee,
              icon: const Icon(Icons.person_add),
              label: const Text('Add First Employee'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textInverse,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
