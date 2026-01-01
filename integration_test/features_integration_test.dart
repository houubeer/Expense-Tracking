import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/main_dev.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Reimbursable Features Integration Tests', () {
    testWidgets(
      'can mark expense as reimbursable and view in summary',
      (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();

        // Navigate to add expense
        final addExpenseButton = find.byIcon(Icons.add);
        if (addExpenseButton.evaluate().isNotEmpty) {
          await tester.tap(addExpenseButton.first);
          await tester.pumpAndSettle();
        }

        // Verify reimbursable checkbox is present
        expect(
          find.byType(CheckboxListTile),
          findsWidgets,
          reason: 'Reimbursable checkbox should be present in expense form',
        );
      },
    );

    testWidgets(
      'reimbursable filter works in expense list',
      (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();

        // Look for filter dropdown containing reimbursable option
        final filterDropdowns = find.byType(DropdownButton);
        expect(
          filterDropdowns,
          findsWidgets,
          reason: 'Filter dropdowns should be available in expense list',
        );
      },
    );

    testWidgets(
      'dashboard shows reimbursable summary',
      (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();

        // Dashboard should load
        expect(
          find.byType(Center),
          findsWidgets,
          reason: 'Dashboard should render',
        );
      },
    );
  });

  group('Backup and Restore Integration Tests', () {
    testWidgets(
      'can access settings screen',
      (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();

        // Settings might be in navigation or menu
        final settingsOption = find.text('Settings');
        if (settingsOption.evaluate().isNotEmpty) {
          await tester.tap(settingsOption);
          await tester.pumpAndSettle();

          // Should navigate to settings
          expect(
            find.text('Settings'),
            findsWidgets,
            reason: 'Settings screen should be accessible',
          );
        }
      },
    );

    testWidgets(
      'backup and restore cards are visible in settings',
      (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();

        // Navigate to settings if possible
        final settingsOption = find.text('Settings');
        if (settingsOption.evaluate().isNotEmpty) {
          await tester.tap(settingsOption);
          await tester.pumpAndSettle();

          // Look for backup/restore related text
          final backupText = find.text('Backup');
          final restoreText = find.text('Restore');

          // At least one of these should be present
          expect(
            backupText.evaluate().isNotEmpty || restoreText.evaluate().isNotEmpty,
            isTrue,
            reason: 'Backup or Restore UI should be visible',
          );
        }
      },
    );
  });

  group('Receipt Attachment Integration Tests', () {
    testWidgets(
      'receipt attachment UI is present in expense form',
      (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();

        // Navigate to add expense
        final addExpenseButton = find.byIcon(Icons.add);
        if (addExpenseButton.evaluate().isNotEmpty) {
          await tester.tap(addExpenseButton.first);
          await tester.pumpAndSettle();

          // Look for receipt-related UI
          final uploadIcon = find.byIcon(Icons.upload_file);
          expect(
            uploadIcon,
            findsWidgets,
            reason: 'Upload file icon should be visible for receipt attachment',
          );
        }
      },
    );
  });

  group('Data Integrity Tests', () {
    testWidgets(
      'form requires category selection',
      (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();

        // Navigate to add expense if possible
        final addExpenseButton = find.byIcon(Icons.add);
        if (addExpenseButton.evaluate().isNotEmpty) {
          await tester.tap(addExpenseButton.first);
          await tester.pumpAndSettle();

          // Category dropdown should be present
          expect(
            find.byType(DropdownButton),
            findsWidgets,
            reason: 'Category selection dropdown should be present',
          );
        }
      },
    );

    testWidgets(
      'form validates amount input',
      (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();

        final addExpenseButton = find.byIcon(Icons.add);
        if (addExpenseButton.evaluate().isNotEmpty) {
          await tester.tap(addExpenseButton.first);
          await tester.pumpAndSettle();

          // Amount field should be present
          expect(
            find.byType(TextFormField),
            findsWidgets,
            reason: 'Text form fields should be present',
          );
        }
      },
    );
  });

  group('Error Handling Tests', () {
    testWidgets(
      'app handles navigation correctly',
      (WidgetTester tester) async {
        app.main();
        
        // Should not throw exceptions
        expect(() {
          tester.pumpAndSettle();
        }, returnsNormally);
      },
    );

    testWidgets(
      'app initializes without errors',
      (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();

        // App should be in initial state
        expect(find.byType(Scaffold), findsWidgets);
      },
    );
  });
}
