import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/l10n/app_localizations.dart';
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
        throw Exception(AppLocalizations.of(context)!.errUserProfileNotFound);
      }

      _organizationId = profile.organizationId;
      if (_organizationId == null) {
        throw Exception(AppLocalizations.of(context)!.errNoOrganization);
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
          content: Text(AppLocalizations.of(context)!
              .msgAddEmployeeSuccess(result['fullName']!)),
          backgroundColor: AppColors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(AppLocalizations.of(context)!.errAddEmployee(e.toString())),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  Future<void> _removeEmployee(UserProfile employee) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.titleRemoveEmployee),
        content: Text(
          AppLocalizations.of(context)!
              .msgRemoveEmployeeConfirm(employee.fullName ?? employee.email),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.btnCancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
            child: Text(AppLocalizations.of(context)!.actionRemove,
                style: const TextStyle(color: Colors.white)),
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
          content: Text(AppLocalizations.of(context)!
              .msgRemoveEmployeeSuccess(employee.fullName ?? employee.email)),
          backgroundColor: AppColors.orange,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              AppLocalizations.of(context)!.errRemoveEmployee(e.toString())),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  Future<void> _toggleEmployeeStatus(UserProfile employee) async {
    try {
      final supabaseService = ref.read(supabaseServiceProvider);
      final newStatus = employee.isActive ? 'inactive' : 'active';
      await supabaseService.updateEmployeeStatus(
        employee.id,
        newStatus,
      );
      await _loadEmployees();

      if (!mounted) return;
      final status = employee.isActive
          ? AppLocalizations.of(context)!.statusDeactivated
          : AppLocalizations.of(context)!.statusActivated;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.msgEmployeeStatusChanged(
              employee.fullName ?? employee.email, status)),
          backgroundColor: AppColors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(AppLocalizations.of(context)!.errUpdateStatus(e.toString())),
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
        title: Text(AppLocalizations.of(context)!.titleTeamManagement),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textInverse,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEmployees,
            tooltip: AppLocalizations.of(context)!.actionRefresh,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addEmployee,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textInverse,
        icon: const Icon(Icons.person_add),
        label: Text(AppLocalizations.of(context)!.labelAddEmployee),
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
            const Icon(Icons.error_outline, size: 64, color: AppColors.red),
            const SizedBox(height: AppSpacing.lg),
            Text(
              AppLocalizations.of(context)!.titleErrorLoadingEmployees,
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
              label: Text(AppLocalizations.of(context)!.actionRetry),
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
            const Icon(
              Icons.group_outlined,
              size: 80,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              AppLocalizations.of(context)!.titleNoEmployees,
              style: AppTextStyles.heading2.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              AppLocalizations.of(context)!.msgNoEmployees,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            ElevatedButton.icon(
              onPressed: _addEmployee,
              icon: const Icon(Icons.person_add),
              label: Text(AppLocalizations.of(context)!.btnAddFirstEmployee),
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
