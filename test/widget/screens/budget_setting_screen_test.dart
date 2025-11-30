import 'package:expense_tracking_desktop_app/features/budget/screens/budget_setting_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('BudgetSettingScreen renders correctly', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: BudgetSettingScreen()),
        ),
      ),
    );

    await tester.pump();

    expect(find.byType(BudgetSettingScreen), findsOneWidget);
  });
}
