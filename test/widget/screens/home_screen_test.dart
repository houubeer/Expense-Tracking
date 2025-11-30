import 'package:expense_tracking_desktop_app/features/home/providers/dashboard_provider.dart';
import 'package:expense_tracking_desktop_app/features/home/screens/home_screen.dart';
import 'package:expense_tracking_desktop_app/features/home/widgets/dashboard_header.dart';
import 'package:expense_tracking_desktop_app/features/home/widgets/dashboard_stats_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('HomeScreen renders dashboard when data is loaded', (tester) async {
    final state = DashboardState(
      activeCategories: 5,
      totalBudget: 1000,
      totalExpenses: 500,
      totalBalance: 500,
      dailyAverage: 10,
      recentExpenses: [],
      budgetData: [],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dashboardStateProvider.overrideWith((ref) => Stream.value(state)),
        ],
        child: const MaterialApp(
          home: Scaffold(body: HomeScreen()),
        ),
      ),
    );

    // Wait for stream to emit
    await tester.pump();

    expect(find.byType(DashboardHeader), findsOneWidget);
    expect(find.byType(DashboardStatsGrid), findsOneWidget);
    expect(find.text('Error:'), findsNothing);
  });

  testWidgets('HomeScreen renders loading indicator', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dashboardStateProvider.overrideWith((ref) => const Stream.empty()),
        ],
        child: const MaterialApp(
          home: Scaffold(body: HomeScreen()),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
