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

  final List<_SidebarItem> items = const [
    _SidebarItem(icon: Icons.home, label: "Home"),
    _SidebarItem(icon: Icons.add_circle, label: "Add expense"),
    _SidebarItem(icon: Icons.list_alt, label: "View expenses"),
    _SidebarItem(icon: Icons.pie_chart, label: "Budgets"),
    _SidebarItem(icon: Icons.label, label: "Categories"),
    _SidebarItem(icon: Icons.settings, label: "Settings"),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.2,
      color: AppColors.primaryBlue, // using AppColors
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "ExpenseTracker",
            style: AppTextStyles.heading3.copyWith(color: AppColors.white),
          ),
          const SizedBox(height: 4),
          Text(
            "Track your spending with ease",
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.white),
          ),
          const SizedBox(height: 20),
          
          for (int i = 0; i < items.length; i++)
            _SidebarTile(
              icon: items[i].icon,
              label: items[i].label,
              isSelected: selectedIndex == i,
              onTap: () => onDestinationSelected(i),
            ),
        ],
      ),
    );
  }
}

class _SidebarTile extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: AppColors.grey200,
      highlightColor: AppColors.grey300,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.white,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem {
  final IconData icon;
  final String label;

  const _SidebarItem({required this.icon, required this.label});
}
