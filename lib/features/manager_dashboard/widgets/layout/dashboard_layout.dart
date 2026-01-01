import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';

/// Dashboard layout wrapper providing consistent padding
/// Note: Sidebar is already provided by the router, so we only wrap content
class DashboardLayout extends StatelessWidget {
  final Widget child;

  const DashboardLayout({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: child,
      ),
    );
  }
}
