import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/constants/colors.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:expense_tracking_desktop_app/constants/app_routes.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:expense_tracking_desktop_app/constants/durations.dart';
import 'package:expense_tracking_desktop_app/constants/strings.dart';

class Sidebar extends StatelessWidget {
  final String currentPath;
  final Function(String) onDestinationSelected;

  const Sidebar({
    super.key,
    required this.currentPath,
    required this.onDestinationSelected,
  });

  static const List<Map<String, dynamic>> _items = [
    {
      "icon": Icons.dashboard_rounded,
      "label": AppStrings.navDashboard,
      "path": AppRoutes.home
    },
    {
      "icon": Icons.add_circle_outline_rounded,
      "label": AppStrings.navAddExpense,
      "path": AppRoutes.addExpense
    },
    {
      "icon": Icons.receipt_long_rounded,
      "label": AppStrings.navViewExpenses,
      "path": AppRoutes.viewExpenses
    },
    {
      "icon": Icons.pie_chart_outline_rounded,
      "label": AppStrings.navBudgets,
      "path": AppRoutes.budgets
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
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
            padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.xxxl, AppSpacing.xxl, AppSpacing.xxxl),
            child: Row(
              children: [
                // Logo Image
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppSpacing.borderRadiusLg,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentLight.withOpacity(0.3),
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
                        "Raseedi",
                        style: AppTextStyles.heading3.copyWith(
                          color: AppColors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        "Pro",
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.accentLight,
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
              itemCount: _items.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.xs),
              itemBuilder: (context, i) {
                final itemPath = _items[i]["path"] as String;
                // Check if current path starts with item path (for nested routes)
                // Special case for root '/' to match exactly or be the only one if others don't match
                bool isSelected = false;
                if (itemPath == '/') {
                  isSelected = currentPath == '/';
                } else {
                  isSelected = currentPath.startsWith(itemPath);
                }

                return _SidebarTile(
                  icon: _items[i]["icon"] as IconData,
                  label: _items[i]["label"] as String,
                  isSelected: isSelected,
                  onTap: () => onDestinationSelected(itemPath),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarTile({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_SidebarTile> createState() => _SidebarTileState();
}

class _SidebarTileState extends State<_SidebarTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.isSelected;
    final isHovered = _isHovered;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppDurations.fast,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.lg),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryLight.withOpacity(0.4)
                : isHovered
                    ? AppColors.primaryLight.withOpacity(0.2)
                    : Colors.transparent,
            borderRadius: AppSpacing.borderRadiusSm,
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                color: isSelected
                    ? AppColors.white
                    : isHovered
                        ? AppColors.white
                        : AppColors.textTertiary,
                size: 22,
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                widget.label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isSelected
                      ? AppColors.white
                      : isHovered
                          ? AppColors.white
                          : AppColors.textTertiary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
