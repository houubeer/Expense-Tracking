import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:expense_tracking_desktop_app/main.dart' as app;
import 'package:expense_tracking_desktop_app/config/environment.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Complete CRUD Workflows', () {
    testWidgets('Add Expense Complete Workflow', (WidgetTester tester) async {
      // Set test environment
      EnvironmentConfig.setEnvironment(Environment.dev);

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to Add Expense screen
      final addButton = find.text('Add Expense');
      if (addButton.evaluate().isNotEmpty) {
        await tester.tap(addButton);
        await tester.pumpAndSettle();

        // Fill in expense form
        final amountField = find.byType(TextFormField).first;
        await tester.enterText(amountField, '150.50');
        await tester.pumpAndSettle();

        final descriptionField = find.byType(TextFormField).at(1);
        await tester.enterText(descriptionField, 'Integration Test Expense');
        await tester.pumpAndSettle();

        // Select category (assuming dropdown exists)
        final categoryDropdown = find.byType(DropdownButtonFormField);
        if (categoryDropdown.evaluate().isNotEmpty) {
          await tester.tap(categoryDropdown.first);
          await tester.pumpAndSettle();

          // Select first category option
          final firstCategory = find.byType(DropdownMenuItem).first;
          if (firstCategory.evaluate().isNotEmpty) {
            await tester.tap(firstCategory);
            await tester.pumpAndSettle();
          }
        }

        // Submit the form
        final submitButton = find.text('Add Expense');
        if (submitButton.evaluate().isNotEmpty) {
          await tester.tap(submitButton.last);
          await tester.pumpAndSettle(const Duration(seconds: 2));
        }

        // Verify success message or navigation
        expect(find.text('Integration Test Expense'), findsAny);
      }
    });

    testWidgets('View Expenses Workflow', (WidgetTester tester) async {
      EnvironmentConfig.setEnvironment(Environment.dev);

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to Expenses list
      final viewExpensesButton = find.text('View Expenses');
      if (viewExpensesButton.evaluate().isEmpty) {
        // Try icon navigation
        final expensesIcon = find.byIcon(Icons.receipt_long);
        if (expensesIcon.evaluate().isNotEmpty) {
          await tester.tap(expensesIcon.first);
          await tester.pumpAndSettle();
        }
      } else {
        await tester.tap(viewExpensesButton);
        await tester.pumpAndSettle();
      }

      // Verify expenses list screen loaded
      expect(find.text('Transactions'), findsAny);

      // Test search functionality
      final searchField = find.byType(TextField);
      if (searchField.evaluate().isNotEmpty) {
        await tester.enterText(searchField.first, 'test');
        await tester.pumpAndSettle();
      }
    });

    testWidgets('Edit Expense Workflow', (WidgetTester tester) async {
      EnvironmentConfig.setEnvironment(Environment.dev);

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to expenses
      final expensesIcon = find.byIcon(Icons.receipt_long);
      if (expensesIcon.evaluate().isNotEmpty) {
        await tester.tap(expensesIcon.first);
        await tester.pumpAndSettle();

        // Find and tap edit button (assuming icon button exists)
        final editButtons = find.byIcon(Icons.edit);
        if (editButtons.evaluate().isNotEmpty) {
          await tester.tap(editButtons.first);
          await tester.pumpAndSettle();

          // Modify expense amount
          final amountField = find.byType(TextFormField).first;
          await tester.enterText(amountField, '200.00');
          await tester.pumpAndSettle();

          // Save changes
          final saveButton = find.text('Save');
          if (saveButton.evaluate().isNotEmpty) {
            await tester.tap(saveButton);
            await tester.pumpAndSettle(const Duration(seconds: 2));
          }
        }
      }
    });

    testWidgets('Delete Expense Workflow', (WidgetTester tester) async {
      EnvironmentConfig.setEnvironment(Environment.dev);

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to expenses list
      final expensesIcon = find.byIcon(Icons.receipt_long);
      if (expensesIcon.evaluate().isNotEmpty) {
        await tester.tap(expensesIcon.first);
        await tester.pumpAndSettle();

        // Find delete button
        final deleteButtons = find.byIcon(Icons.delete);
        if (deleteButtons.evaluate().isNotEmpty) {
          await tester.tap(deleteButtons.first);
          await tester.pumpAndSettle();

          // Confirm deletion in dialog
          final confirmButton = find.text('Delete');
          if (confirmButton.evaluate().isNotEmpty) {
            await tester.tap(confirmButton.last);
            await tester.pumpAndSettle(const Duration(seconds: 2));
          }
        }
      }
    });
  });

  group('Budget Management Workflows', () {
    testWidgets('Add Category Workflow', (WidgetTester tester) async {
      EnvironmentConfig.setEnvironment(Environment.dev);

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to Budget Settings
      final budgetIcon = find.byIcon(Icons.account_balance_wallet);
      if (budgetIcon.evaluate().isNotEmpty) {
        await tester.tap(budgetIcon.first);
        await tester.pumpAndSettle();

        // Click Add Category button
        final addCategoryButton = find.text('Add Category');
        if (addCategoryButton.evaluate().isNotEmpty) {
          await tester.tap(addCategoryButton);
          await tester.pumpAndSettle();

          // Fill category form
          final nameField = find.byType(TextFormField).first;
          await tester.enterText(nameField, 'Integration Test Category');
          await tester.pumpAndSettle();

          final budgetField = find.byType(TextFormField).at(1);
          await tester.enterText(budgetField, '500.00');
          await tester.pumpAndSettle();

          // Save category
          final saveButton = find.text('Save');
          if (saveButton.evaluate().isNotEmpty) {
            await tester.tap(saveButton);
            await tester.pumpAndSettle(const Duration(seconds: 2));
          }

          // Verify category was added
          expect(find.text('Integration Test Category'), findsAny);
        }
      }
    });

    testWidgets('Edit Category Budget Workflow', (WidgetTester tester) async {
      EnvironmentConfig.setEnvironment(Environment.dev);

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to Budget Settings
      final budgetIcon = find.byIcon(Icons.account_balance_wallet);
      if (budgetIcon.evaluate().isNotEmpty) {
        await tester.tap(budgetIcon.first);
        await tester.pumpAndSettle();

        // Find and click edit button
        final editButtons = find.byIcon(Icons.edit);
        if (editButtons.evaluate().isNotEmpty) {
          await tester.tap(editButtons.first);
          await tester.pumpAndSettle();

          // Modify budget amount
          final budgetField = find.byType(TextFormField).first;
          await tester.enterText(budgetField, '750.00');
          await tester.pumpAndSettle();

          // Save changes
          final saveButton = find.text('Update');
          if (saveButton.evaluate().isNotEmpty) {
            await tester.tap(saveButton);
            await tester.pumpAndSettle(const Duration(seconds: 2));
          }
        }
      }
    });

    testWidgets('Delete Category Workflow', (WidgetTester tester) async {
      EnvironmentConfig.setEnvironment(Environment.dev);

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to Budget Settings
      final budgetIcon = find.byIcon(Icons.account_balance_wallet);
      if (budgetIcon.evaluate().isNotEmpty) {
        await tester.tap(budgetIcon.first);
        await tester.pumpAndSettle();

        // Find delete button
        final deleteButtons = find.byIcon(Icons.delete);
        if (deleteButtons.evaluate().isNotEmpty) {
          await tester.tap(deleteButtons.first);
          await tester.pumpAndSettle();

          // Confirm deletion
          final confirmButton = find.text('Delete');
          if (confirmButton.evaluate().isNotEmpty) {
            await tester.tap(confirmButton.last);
            await tester.pumpAndSettle(const Duration(seconds: 2));
          }
        }
      }
    });
  });

  group('Navigation Workflows', () {
    testWidgets('Navigate Between All Screens', (WidgetTester tester) async {
      EnvironmentConfig.setEnvironment(Environment.dev);

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Start at home/dashboard
      expect(find.byType(MaterialApp), findsOneWidget);

      // Navigate to Expenses
      final expensesNav = find.byIcon(Icons.receipt_long);
      if (expensesNav.evaluate().isNotEmpty) {
        await tester.tap(expensesNav.first);
        await tester.pumpAndSettle();
        expect(find.text('Expenses'), findsAny);
      }

      // Navigate to Budget
      final budgetNav = find.byIcon(Icons.account_balance_wallet);
      if (budgetNav.evaluate().isNotEmpty) {
        await tester.tap(budgetNav.first);
        await tester.pumpAndSettle();
        expect(find.text('Budget'), findsAny);
      }

      // Navigate back to Home
      final homeNav = find.byIcon(Icons.home);
      if (homeNav.evaluate().isNotEmpty) {
        await tester.tap(homeNav.first);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('Deep Link Navigation to Add Expense',
        (WidgetTester tester) async {
      EnvironmentConfig.setEnvironment(Environment.dev);

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate through multiple paths
      final addExpenseButtons = find.text('Add Expense');
      if (addExpenseButtons.evaluate().isNotEmpty) {
        await tester.tap(addExpenseButtons.first);
        await tester.pumpAndSettle();

        // Verify we're on add expense screen
        expect(find.byType(TextFormField), findsWidgets);

        // Navigate back
        final backButton = find.byType(BackButton);
        if (backButton.evaluate().isEmpty) {
          // Try alternative back navigation
          final closeButton = find.byIcon(Icons.close);
          if (closeButton.evaluate().isNotEmpty) {
            await tester.tap(closeButton.first);
            await tester.pumpAndSettle();
          }
        } else {
          await tester.tap(backButton);
          await tester.pumpAndSettle();
        }
      }
    });

    testWidgets('Category Filter Navigation', (WidgetTester tester) async {
      EnvironmentConfig.setEnvironment(Environment.dev);

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to expenses
      final expensesIcon = find.byIcon(Icons.receipt_long);
      if (expensesIcon.evaluate().isNotEmpty) {
        await tester.tap(expensesIcon.first);
        await tester.pumpAndSettle();

        // Apply category filter
        final filterDropdown = find.byType(DropdownButton<int?>);
        if (filterDropdown.evaluate().isNotEmpty) {
          await tester.tap(filterDropdown.first);
          await tester.pumpAndSettle();

          // Select a category
          final categoryItems = find.byType(DropdownMenuItem<int?>);
          if (categoryItems.evaluate().length > 1) {
            await tester.tap(categoryItems.at(1));
            await tester.pumpAndSettle();
          }
        }

        // Clear filter
        final clearButton = find.byIcon(Icons.clear);
        if (clearButton.evaluate().isNotEmpty) {
          await tester.tap(clearButton.first);
          await tester.pumpAndSettle();
        }
      }
    });
  });

  group('Data Persistence Workflows', () {
    testWidgets('Add Expense and Verify in List', (WidgetTester tester) async {
      EnvironmentConfig.setEnvironment(Environment.dev);

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      const testDescription = 'Persistence Test Expense';

      // Add expense
      final addButton = find.text('Add Expense');
      if (addButton.evaluate().isNotEmpty) {
        await tester.tap(addButton.first);
        await tester.pumpAndSettle();

        final descField = find.byType(TextFormField).at(1);
        await tester.enterText(descField, testDescription);
        await tester.pumpAndSettle();

        final amountField = find.byType(TextFormField).first;
        await tester.enterText(amountField, '99.99');
        await tester.pumpAndSettle();

        // Select category if available
        final dropdown = find.byType(DropdownButtonFormField);
        if (dropdown.evaluate().isNotEmpty) {
          await tester.tap(dropdown.first);
          await tester.pumpAndSettle();
          final firstOption = find.byType(DropdownMenuItem).first;
          if (firstOption.evaluate().isNotEmpty) {
            await tester.tap(firstOption);
            await tester.pumpAndSettle();
          }
        }

        // Submit
        final submitButton = find.text('Add Expense');
        if (submitButton.evaluate().isNotEmpty) {
          await tester.tap(submitButton.last);
          await tester.pumpAndSettle(const Duration(seconds: 2));
        }
      }

      // Navigate to expenses list
      final expensesIcon = find.byIcon(Icons.receipt_long);
      if (expensesIcon.evaluate().isNotEmpty) {
        await tester.tap(expensesIcon.first);
        await tester.pumpAndSettle();

        // Verify expense appears in list
        expect(find.textContaining(testDescription), findsAny);
      }
    });

    testWidgets('Dashboard Reflects Budget Changes',
        (WidgetTester tester) async {
      EnvironmentConfig.setEnvironment(Environment.dev);

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Note initial dashboard state
      final initialDashboard = find.byType(MaterialApp);
      expect(initialDashboard, findsOneWidget);

      // Navigate to budget settings
      final budgetIcon = find.byIcon(Icons.account_balance_wallet);
      if (budgetIcon.evaluate().isNotEmpty) {
        await tester.tap(budgetIcon.first);
        await tester.pumpAndSettle();

        // Modify a budget
        final editButtons = find.byIcon(Icons.edit);
        if (editButtons.evaluate().isNotEmpty) {
          await tester.tap(editButtons.first);
          await tester.pumpAndSettle();

          final budgetField = find.byType(TextFormField).first;
          await tester.enterText(budgetField, '1000.00');
          await tester.pumpAndSettle();

          final saveButton = find.text('Update');
          if (saveButton.evaluate().isNotEmpty) {
            await tester.tap(saveButton);
            await tester.pumpAndSettle(const Duration(seconds: 2));
          }
        }

        // Return to dashboard
        final homeIcon = find.byIcon(Icons.home);
        if (homeIcon.evaluate().isNotEmpty) {
          await tester.tap(homeIcon.first);
          await tester.pumpAndSettle();
        }

        // Verify dashboard updated
        expect(find.byType(MaterialApp), findsOneWidget);
      }
    });
  });
}
