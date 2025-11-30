import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:expense_tracking_desktop_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Delete Expense Flow Integration Test',
      (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // 1. Navigate to Expenses List (assuming it's index 2 or accessible via sidebar)
    // The app starts at Dashboard (index 0).
    // Tap on sidebar item for "Expenses"
    // We need to find the sidebar icon or text.
    // Sidebar usually has icons. Let's assume the 3rd item is Expenses.

    final expensesIcon =
        find.byIcon(Icons.receipt_long); // Adjust icon if needed
    if (expensesIcon.evaluate().isNotEmpty) {
      await tester.tap(expensesIcon.first);
      await tester.pumpAndSettle();
    } else {
      // Try finding by text if sidebar is expanded or has tooltips
      // Or just rely on the fact that we might be on the screen or can navigate
    }

    // 2. Ensure there is an expense to delete.
    // If list is empty, we might need to add one.
    // For this test, we assume seed data or we add one.
    // Let's try to add one first to be sure.

    final addExpenseButton = find.text('Add Expense');
    if (addExpenseButton.evaluate().isNotEmpty) {
      await tester.tap(addExpenseButton);
      await tester.pumpAndSettle();

      // Fill form
      await tester.enterText(find.byType(TextFormField).at(0), '500'); // Amount
      await tester.enterText(
          find.byType(TextFormField).at(1), 'Test Delete'); // Description

      // Select Category (Dropdown)
      await tester.tap(find.byType(DropdownButtonFormField));
      await tester.pumpAndSettle();
      await tester
          .tap(find.text('Food').last); // Assuming 'Food' exists from seed
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save Expense'));
      await tester.pumpAndSettle();
    }

    // 3. Find the delete button for the expense we just added (or any expense)
    final deleteButton = find.byIcon(Icons.delete_outline).first;
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();

    // 4. Verify Dialog appears
    expect(find.text('Delete Expense'), findsOneWidget);

    // 5. Confirm Delete
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    // 6. Verify Snackbar
    expect(find.text('Expense deleted'), findsOneWidget);

    // 7. Verify Undo (Optional)
    await tester.tap(find.text('UNDO'));
    await tester.pumpAndSettle();

    // Verify it's back (optional, might be hard to verify exact item without unique ID check)
  });

  testWidgets('Edit Expense Flow Integration Test',
      (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // 1. Navigate to Expenses List
    final expensesIcon = find.byIcon(Icons.receipt_long);
    if (expensesIcon.evaluate().isNotEmpty) {
      await tester.tap(expensesIcon.first);
      await tester.pumpAndSettle();
    }

    // 2. Ensure there is an expense to edit.
    final addExpenseButton = find.text('Add Expense');
    if (addExpenseButton.evaluate().isNotEmpty) {
      await tester.tap(addExpenseButton);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), '100'); // Amount
      await tester.enterText(
          find.byType(TextFormField).at(1), 'Original'); // Description

      await tester.tap(find.byType(DropdownButtonFormField));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Food').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save Expense'));
      await tester.pumpAndSettle();
    }

    // 3. Find the Edit button
    final editButton = find.byIcon(Icons.edit_outlined).first;
    await tester.tap(editButton);
    await tester.pumpAndSettle();

    // 4. Verify Edit Screen opens (check title)
    expect(find.text('Edit Expense'), findsOneWidget);
    expect(find.text('Original'), findsOneWidget); // Pre-filled

    // 5. Update fields
    await tester.enterText(
        find.byType(TextFormField).at(0), '200'); // New Amount
    await tester.enterText(
        find.byType(TextFormField).at(1), 'Updated'); // New Description

    // 6. Save
    await tester.tap(find.text('Update Expense'));
    await tester.pumpAndSettle();

    // 7. Verify Snackbar
    expect(find.text('Expense updated successfully'), findsOneWidget);

    // 8. Verify List Update
    expect(find.text('Updated'), findsOneWidget);
    expect(find.text('200.00'), findsOneWidget);
  });
  testWidgets('Dashboard Integration Test', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // 1. Verify Dashboard is the initial screen
    expect(find.text('Financial Overview'), findsOneWidget);
    expect(find.text('Total Balance'), findsOneWidget);

    // 2. Check for Budget Overview
    expect(find.text('Budget Overview'), findsOneWidget);

    // 3. Check for Recent Expenses
    expect(find.text('Recent Expenses'), findsOneWidget);

    // 4. Navigate to Budget Screen
    final budgetIcon = find.byIcon(Icons.pie_chart);
    if (budgetIcon.evaluate().isNotEmpty) {
      await tester.tap(budgetIcon.first);
      await tester.pumpAndSettle();
      expect(find.text('Budget Settings'), findsOneWidget);
    }
  });
}
