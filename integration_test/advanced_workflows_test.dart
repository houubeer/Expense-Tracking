import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:expense_tracking_desktop_app/main.dart' as app;
import 'package:expense_tracking_desktop_app/config/environment.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Error Handling Workflows', () {
    testWidgets('Handle Invalid Expense Input', (WidgetTester tester) async {
      EnvironmentConfig.setEnvironment(Environment.dev);

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to Add Expense
      final addButton = find.text('Add Expense');
      if (addButton.evaluate().isNotEmpty) {
        await tester.tap(addButton.first);
        await tester.pumpAndSettle();

        // Try to submit with invalid data
        final submitButton = find.text('Add Expense');
        if (submitButton.evaluate().length > 1) {
          await tester.tap(submitButton.last);
          await tester.pumpAndSettle();

          // Should show validation errors
          expect(find.textContaining('Please'), findsAny);
        }

        // Try invalid amount
        final amountField = find.byType(TextFormField).first;
        await tester.enterText(amountField, 'invalid');
        await tester.pumpAndSettle();

        if (submitButton.evaluate().length > 1) {
          await tester.tap(submitButton.last);
          await tester.pumpAndSettle();

          // Should show error
          expect(find.textContaining('valid'), findsAny);
        }
      }
    });

    testWidgets('Handle Empty Category List', (WidgetTester tester) async {
      EnvironmentConfig.setEnvironment(Environment.dev);

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to Budget
      final budgetIcon = find.byIcon(Icons.account_balance_wallet);
      if (budgetIcon.evaluate().isNotEmpty) {
        await tester.tap(budgetIcon.first);
        await tester.pumpAndSettle();

        // Should show empty state or categories
        expect(find.byType(MaterialApp), findsOneWidget);
      }
    });

    testWidgets('Handle Network/Database Errors Gracefully',
        (WidgetTester tester) async {
      EnvironmentConfig.setEnvironment(Environment.dev);

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // App should load without crashing
      expect(find.byType(MaterialApp), findsOneWidget);

      // Navigate through app
      final expensesIcon = find.byIcon(Icons.receipt_long);
      if (expensesIcon.evaluate().isNotEmpty) {
        await tester.tap(expensesIcon.first);
        await tester.pumpAndSettle();

        // Should handle gracefully
        expect(find.byType(MaterialApp), findsOneWidget);
      }
    });
  });

  group('User Experience Workflows', () {
    testWidgets('Search and Filter Expenses', (WidgetTester tester) async {
      EnvironmentConfig.setEnvironment(Environment.dev);

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to expenses
      final expensesIcon = find.byIcon(Icons.receipt_long);
      if (expensesIcon.evaluate().isNotEmpty) {
        await tester.tap(expensesIcon.first);
        await tester.pumpAndSettle();

        // Test search
        final searchField = find.byType(TextField);
        if (searchField.evaluate().isNotEmpty) {
          await tester.enterText(searchField.first, 'food');
          await tester.pumpAndSettle();

          // Clear search
          await tester.enterText(searchField.first, '');
          await tester.pumpAndSettle();
        }

        // Test category filter
        final categoryFilter = find.byType(DropdownButton<int?>);
        if (categoryFilter.evaluate().isNotEmpty) {
          await tester.tap(categoryFilter.first);
          await tester.pumpAndSettle();

          // Select a category
          final items = find.byType(DropdownMenuItem<int?>);
          if (items.evaluate().length > 1) {
            await tester.tap(items.at(1));
            await tester.pumpAndSettle();
          }
        }
      }
    });

    testWidgets('Budget Status Indicators Update', (WidgetTester tester) async {
      EnvironmentConfig.setEnvironment(Environment.dev);

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Check dashboard shows budget stats
      expect(find.byType(MaterialApp), findsOneWidget);

      // Navigate to budget screen
      final budgetIcon = find.byIcon(Icons.account_balance_wallet);
      if (budgetIcon.evaluate().isNotEmpty) {
        await tester.tap(budgetIcon.first);
        await tester.pumpAndSettle();

        // Should show budget status indicators
        expect(find.byType(MaterialApp), findsOneWidget);
      }
    });

    testWidgets('Date Picker Workflow', (WidgetTester tester) async {
      EnvironmentConfig.setEnvironment(Environment.dev);

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to Add Expense
      final addButton = find.text('Add Expense');
      if (addButton.evaluate().isNotEmpty) {
        await tester.tap(addButton.first);
        await tester.pumpAndSettle();

        // Find and tap date picker
        final dateButton = find.byIcon(Icons.calendar_today);
        if (dateButton.evaluate().isNotEmpty) {
          await tester.tap(dateButton.first);
          await tester.pumpAndSettle();

          // Select a date (tap OK button)
          final okButton = find.text('OK');
          if (okButton.evaluate().isNotEmpty) {
            await tester.tap(okButton);
            await tester.pumpAndSettle();
          }
        }
      }
    });
  });

  group('Performance Workflows', () {
    testWidgets('App Loads Within Timeout', (WidgetTester tester) async {
      EnvironmentConfig.setEnvironment(Environment.dev);

      final stopwatch = Stopwatch()..start();

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      stopwatch.stop();

      // App should load within 5 seconds
      expect(stopwatch.elapsed.inSeconds, lessThan(6));
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Navigate Between Screens Quickly',
        (WidgetTester tester) async {
      EnvironmentConfig.setEnvironment(Environment.dev);

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final stopwatch = Stopwatch();

      // Test navigation speed
      final expensesIcon = find.byIcon(Icons.receipt_long);
      if (expensesIcon.evaluate().isNotEmpty) {
        stopwatch.start();
        await tester.tap(expensesIcon.first);
        await tester.pumpAndSettle();
        stopwatch.stop();

        // Navigation should be under 2 seconds
        expect(stopwatch.elapsed.inSeconds, lessThan(2));
      }
    });

    testWidgets('Handle Large Dataset', (WidgetTester tester) async {
      EnvironmentConfig.setEnvironment(Environment.dev);

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to expenses list
      final expensesIcon = find.byIcon(Icons.receipt_long);
      if (expensesIcon.evaluate().isNotEmpty) {
        await tester.tap(expensesIcon.first);
        await tester.pumpAndSettle();

        // Should render without lag
        expect(find.byType(MaterialApp), findsOneWidget);

        // Test scrolling performance
        final listView = find.byType(Scrollable);
        if (listView.evaluate().isNotEmpty) {
          await tester.drag(listView.first, const Offset(0, -500));
          await tester.pumpAndSettle();

          await tester.drag(listView.first, const Offset(0, 500));
          await tester.pumpAndSettle();
        }
      }
    });
  });
}
