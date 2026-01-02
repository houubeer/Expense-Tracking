import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/features/dashboard/models/manager_model.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';

/// Table widget for displaying active managers
class ActiveManagersTable extends StatelessWidget {

  const ActiveManagersTable({
    required this.managers, required this.onView, required this.onSuspend, required this.onDelete, super.key,
  });
  final List<Manager> managers;
  final void Function(String managerId) onView;
  final void Function(String managerId) onSuspend;
  final void Function(String managerId) onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (managers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxxl),
          child: Text(
            'No Active Managers',
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: colorScheme.outlineVariant),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text('Manager Name', style: textTheme.titleSmall),
                ),
                Expanded(
                  flex: 3,
                  child: Text('Company', style: textTheme.titleSmall),
                ),
                Expanded(
                  flex: 2,
                  child: Text('Email', style: textTheme.titleSmall),
                ),
                Expanded(
                  child: Text('Status', style: textTheme.titleSmall),
                ),
                const SizedBox(width: 150),
              ],
            ),
          ),
          // Rows
          Expanded(
            child: ListView.separated(
              itemCount: managers.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: colorScheme.outlineVariant,
              ),
              itemBuilder: (context, index) {
                final manager = managers[index];
                return _ManagerRow(
                  manager: manager,
                  onView: () => onView(manager.id),
                  onSuspend: () => onSuspend(manager.id),
                  onDelete: () => onDelete(manager.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ManagerRow extends StatelessWidget {

  const _ManagerRow({
    required this.manager,
    required this.onView,
    required this.onSuspend,
    required this.onDelete,
  });
  final Manager manager;
  final VoidCallback onView;
  final VoidCallback onSuspend;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Text(
                    manager.initials,
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    manager.name,
                    style: textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              manager.companyName,
              style: textTheme.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              manager.email,
              style: textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: _StatusBadge(status: manager.status),
          ),
          SizedBox(
            width: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility, size: 20),
                  color: colorScheme.primary,
                  onPressed: onView,
                  tooltip: 'View',
                ),
                IconButton(
                  icon: const Icon(Icons.block, size: 20),
                  color: colorScheme.error,
                  onPressed: onSuspend,
                  tooltip: 'Suspend',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: colorScheme.error,
                  onPressed: onDelete,
                  tooltip: 'Delete',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {

  const _StatusBadge({required this.status});
  final ManagerStatus status;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Color backgroundColor;
    Color textColor;

    switch (status) {
      case ManagerStatus.approved:
        backgroundColor = colorScheme.tertiary.withValues(alpha: 0.1);
        textColor = colorScheme.tertiary;
        break;
      case ManagerStatus.suspended:
        backgroundColor = colorScheme.error.withValues(alpha: 0.1);
        textColor = colorScheme.error;
        break;
      default:
        backgroundColor = colorScheme.surfaceContainerHighest;
        textColor = colorScheme.onSurfaceVariant;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(
        status.displayName,
        style: textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
