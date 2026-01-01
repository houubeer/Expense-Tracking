import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/features/dashboard/models/manager_model.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:intl/intl.dart';

/// Table widget for displaying pending manager requests
class PendingManagerTable extends StatelessWidget {
  final List<Manager> managers;
  final void Function(String managerId) onApprove;
  final void Function(String managerId) onReject;
  final void Function(String managerId) onView;

  const PendingManagerTable({
    super.key,
    required this.managers,
    required this.onApprove,
    required this.onReject,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (managers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 64,
                color: colorScheme.primary.withValues(alpha: 0.3),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'No Pending Approvals',
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
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
                  flex: 2,
                  child: Text('Name', style: textTheme.titleSmall),
                ),
                Expanded(
                  flex: 2,
                  child: Text('Email', style: textTheme.titleSmall),
                ),
                Expanded(
                  flex: 2,
                  child: Text('Company', style: textTheme.titleSmall),
                ),
                Expanded(
                  flex: 2,
                  child: Text('Phone', style: textTheme.titleSmall),
                ),
                Expanded(
                  flex: 1,
                  child: Text('Date', style: textTheme.titleSmall),
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
                  onApprove: () => onApprove(manager.id),
                  onReject: () => onReject(manager.id),
                  onView: () => onView(manager.id),
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
  final Manager manager;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onView;

  const _ManagerRow({
    required this.manager,
    required this.onApprove,
    required this.onReject,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              manager.name,
              style:
                  textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
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
            flex: 2,
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
              manager.phone,
              style: textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              dateFormat.format(manager.requestDate),
              style: textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.check_circle, size: 20),
                  color: colorScheme.tertiary,
                  onPressed: onApprove,
                  tooltip: 'Approve',
                ),
                IconButton(
                  icon: const Icon(Icons.cancel, size: 20),
                  color: colorScheme.error,
                  onPressed: onReject,
                  tooltip: 'Reject',
                ),
                IconButton(
                  icon: const Icon(Icons.visibility, size: 20),
                  color: colorScheme.primary,
                  onPressed: onView,
                  tooltip: 'View Profile',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
