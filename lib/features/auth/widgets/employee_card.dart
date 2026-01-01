import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/constants/colors.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:expense_tracking_desktop_app/features/auth/models/user_profile.dart';

/// Card widget for displaying employee information
class EmployeeCard extends StatelessWidget {
  final UserProfile employee;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onRemove;

  const EmployeeCard({
    super.key,
    required this.employee,
    this.onToggleStatus,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: _getRoleColor().withOpacity(0.1),
              child: Text(
                _getInitials(),
                style: AppTextStyles.heading3.copyWith(
                  color: _getRoleColor(),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        employee.fullName ?? 'Unknown',
                        style: AppTextStyles.heading3.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _buildRoleBadge(),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    employee.email,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Status indicator
            _buildStatusIndicator(),
            const SizedBox(width: AppSpacing.md),

            // Actions
            if (onToggleStatus != null || onRemove != null)
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: AppColors.textSecondary),
                onSelected: (value) {
                  switch (value) {
                    case 'toggle':
                      onToggleStatus?.call();
                      break;
                    case 'remove':
                      onRemove?.call();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  if (onToggleStatus != null)
                    PopupMenuItem(
                      value: 'toggle',
                      child: Row(
                        children: [
                          Icon(
                            employee.isActive
                                ? Icons.block_outlined
                                : Icons.check_circle_outline,
                            size: 20,
                            color: employee.isActive
                                ? AppColors.orange
                                : AppColors.green,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(employee.isActive ? 'Deactivate' : 'Activate'),
                        ],
                      ),
                    ),
                  if (onRemove != null)
                    PopupMenuItem(
                      value: 'remove',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline,
                              size: 20, color: AppColors.red),
                          const SizedBox(width: AppSpacing.sm),
                          Text('Remove',
                              style: TextStyle(color: AppColors.red)),
                        ],
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _getInitials() {
    final name = employee.fullName ?? 'U';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.length >= 2
        ? name.substring(0, 2).toUpperCase()
        : name.toUpperCase();
  }

  Widget _buildRoleBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _getRoleColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        employee.role.name.toUpperCase(),
        style: AppTextStyles.bodySmall.copyWith(
          color: _getRoleColor(),
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: employee.isActive
            ? AppColors.green.withOpacity(0.1)
            : AppColors.textTertiary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color:
                  employee.isActive ? AppColors.green : AppColors.textTertiary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            employee.isActive ? 'Active' : 'Inactive',
            style: AppTextStyles.bodySmall.copyWith(
              color:
                  employee.isActive ? AppColors.green : AppColors.textTertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor() {
    switch (employee.role) {
      case UserRole.owner:
        return AppColors.purple;
      case UserRole.manager:
        return AppColors.primary;
      case UserRole.employee:
        return AppColors.teal;
    }
  }
}
