import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:expense_tracking_desktop_app/constants/app_routes.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:expense_tracking_desktop_app/constants/durations.dart';
import 'package:expense_tracking_desktop_app/constants/strings.dart';
import 'package:expense_tracking_desktop_app/features/auth/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class Sidebar extends ConsumerWidget {
  const Sidebar({
    required this.currentPath,
    required this.onDestinationSelected,
    super.key,
  });
  final String currentPath;
  final void Function(String) onDestinationSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final isManager = ref.watch(isManagerProvider);

    final List<Map<String, dynamic>> items = [
      {
        'icon': Icons.dashboard_rounded,
        'label': AppStrings.navDashboard,
        'path': AppRoutes.home,
      },
      {
        'icon': Icons.add_circle_outline_rounded,
        'label': AppStrings.navAddExpense,
        'path': AppRoutes.addExpense,
      },
      {
        'icon': Icons.receipt_long_rounded,
        'label': AppStrings.navViewExpenses,
        'path': AppRoutes.viewExpenses,
      },
      {
        'icon': Icons.pie_chart_outline_rounded,
        'label': AppStrings.navBudgets,
        'path': AppRoutes.budgets,
      },
      if (isManager)
        {
          'icon': Icons.supervisor_account_rounded,
          'label': AppStrings.navManagerDashboard,
          'path': AppRoutes.managerDashboard,
        },
      {
        'icon': Icons.settings_rounded,
        'label': AppStrings.navSettings,
        'path': AppRoutes.settings,
      },
    ];

    return Container(
      width: 280,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.primary.withAlpha(217),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xxl,
              AppSpacing.xxxl,
              AppSpacing.xxl,
              AppSpacing.xxxl,
            ),
            child: Row(
              children: [
                // Logo Image
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: AppSpacing.borderRadiusLg,
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.secondaryContainer.withAlpha(77),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: AppSpacing.paddingSm,
                  child: Image.asset(
                    'assets/images/raseedi_logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Raseedi',
                        style: AppTextStyles.heading3.copyWith(
                          color: colorScheme.onPrimary,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Pro',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: colorScheme.secondaryContainer,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Navigation
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: items.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppSpacing.xs),
              itemBuilder: (context, i) {
                final itemPath = items[i]['path'] as String;
                bool isSelected = false;

                if (currentPath == itemPath) {
                  isSelected = true;
                } else if (itemPath != '/' &&
                    currentPath.startsWith('$itemPath/')) {
                  final hasMoreSpecificMatch = items.any((item) {
                    final otherPath = item['path'] as String;
                    return otherPath != itemPath &&
                        otherPath.length > itemPath.length &&
                        currentPath.startsWith(otherPath);
                  });
                  isSelected = !hasMoreSpecificMatch;
                }

                return _SidebarTile(
                  icon: items[i]['icon'] as IconData,
                  label: items[i]['label'] as String,
                  isSelected: isSelected,
                  onTap: () => onDestinationSelected(itemPath),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: _SidebarTile(
              icon: Icons.logout_rounded,
              label: 'Log out',
              isSelected: false,
              onTap: () async {
                await ref.read(authNotifierProvider.notifier).signOut();
                if (context.mounted) {
                  context.go(AppRoutes.login);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarTile extends StatefulWidget {
  const _SidebarTile({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_SidebarTile> createState() => _SidebarTileState();
}

class _SidebarTileState extends State<_SidebarTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = widget.isSelected;
    final isHovered = _isHovered;

    return Semantics(
      button: true,
      label: '${widget.label}${isSelected ? ", selected" : ""}',
      selected: isSelected,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: AppDurations.fast,
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.md,
              horizontal: AppSpacing.lg,
            ),
            margin: isSelected
                ? const EdgeInsets.only(right: AppSpacing.lg)
                : EdgeInsets.zero,
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primaryContainer.withAlpha(102)
                  : isHovered
                      ? colorScheme.primaryContainer.withAlpha(51)
                      : Colors.transparent,
              borderRadius: isSelected
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(AppSpacing.radiusMd),
                      bottomLeft: Radius.circular(AppSpacing.radiusMd),
                    )
                  : BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Row(
              children: [
                Icon(
                  widget.icon,
                  color: isSelected
                      ? colorScheme.onPrimary
                      : isHovered
                          ? colorScheme.onPrimary.withAlpha(230)
                          : colorScheme.onPrimary.withAlpha(166),
                  size: 22,
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  widget.label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isSelected
                        ? colorScheme.onPrimary
                        : isHovered
                            ? colorScheme.onPrimary.withAlpha(230)
                            : colorScheme.onPrimary.withAlpha(166),
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
