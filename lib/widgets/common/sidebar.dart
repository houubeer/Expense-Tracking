import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/constants/colors.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  static const List<Map<String, dynamic>> _items = [
    {"icon": Icons.dashboard_rounded, "label": "Dashboard"},
    {"icon": Icons.add_circle_outline_rounded, "label": "Add Expense"},
    {"icon": Icons.list_alt_rounded, "label": "Transactions"},
    {"icon": Icons.pie_chart_outline_rounded, "label": "Budgets"},
    {"icon": Icons.label_outline_rounded, "label": "Categories"},
    {"icon": Icons.settings_outlined, "label": "Settings"},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      color: AppColors.primary, // Slate 900
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 40, 32, 40),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.account_balance_wallet,
                      color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Expense",
                        style: AppTextStyles.heading3.copyWith(
                          color: AppColors.white,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        "Manager",
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                          fontSize: 12,
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
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 4),
              itemBuilder: (context, i) => _SidebarTile(
                icon: _items[i]["icon"] as IconData,
                label: _items[i]["label"] as String,
                isSelected: selectedIndex == i,
                onTap: () => onDestinationSelected(i),
              ),
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
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.accent
                : isHovered
                    ? AppColors.primaryLight.withOpacity(0.5)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
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
              const SizedBox(width: 12),
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
