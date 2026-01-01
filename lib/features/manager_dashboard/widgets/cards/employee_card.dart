import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/models/employee_model.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:expense_tracking_desktop_app/widgets/animations/animated_widgets.dart';

class EmployeeCard extends StatelessWidget {
  final Employee employee;
  final VoidCallback? onTap;
  final void Function(String)? onMenuAction;

  const EmployeeCard({
    super.key,
    required this.employee,
    this.onTap,
    this.onMenuAction,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedHoverCard(
      scale: 1.008,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.surface,
              colorScheme.surfaceContainerHighest,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primary.withValues(alpha: 0.15),
                            colorScheme.primary.withValues(alpha: 0.08),
                          ],
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.transparent,
                        child: Text(
                          employee.initials,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: employee.status == EmployeeStatus.active
                              ? Colors.green
                              : Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colorScheme.surface,
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (employee.status == EmployeeStatus.active
                                      ? Colors.green
                                      : Colors.red)
                                  .withValues(alpha: 0.3),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employee.name,
                        style: AppTextStyles.heading3.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        employee.role,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    size: 20,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  onSelected: onMenuAction,
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'view',
                      child: Text('View Details'),
                    ),
                    PopupMenuItem(
                      value: 'suspend',
                      child: Text(
                        employee.status == EmployeeStatus.active
                            ? 'Suspend'
                            : 'Activate',
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'remove',
                      child: Text('Remove'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Department',
                        style: AppTextStyles.caption.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        employee.department,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hire Date',
                        style: AppTextStyles.caption.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${employee.hireDate.day}/${employee.hireDate.month}/${employee.hireDate.year}',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Icon(
                  Icons.email_outlined,
                  size: 16,
                  color: colorScheme.primary.withValues(alpha: 0.7),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    employee.email,
                    style: AppTextStyles.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(
                  Icons.phone_outlined,
                  size: 16,
                  color: colorScheme.primary.withValues(alpha: 0.7),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  employee.phone,
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
