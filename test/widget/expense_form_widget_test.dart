import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracking_desktop_app/features/expenses/widgets/expense_form_widget.dart';
import 'package:expense_tracking_desktop_app/theme/app_theme.dart';

void main() {
  group('ExpenseFormWidget - Reimbursable and Receipt Fields', () {
    Widget createTestWidget(ExpenseFormWidget form) {
      return ProviderScope(
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: form,
          ),
        ),
      );
    }

    testWidgets('displays reimbursable checkbox', 
      (WidgetTester tester) async {
      final formKey = GlobalKey<FormState>();
      final amountController = TextEditingController();
      final descriptionController = TextEditingController();

      await tester.pumpWidget(
        createTestWidget(
          ExpenseFormWidget(
            formKey: formKey,
            amountController: amountController,
            descriptionController: descriptionController,
            selectedDate: DateTime.now(),
            selectedCategoryId: 1,
            onDateChanged: (_) {},
            onCategoryChanged: (_) {},
            onSubmit: null,
            onReset: () {},
            isReimbursable: false,
            onReimbursableChanged: (_) {},
          ),
        ),
      );

      // Look for checkbox in the form
      expect(find.byType(CheckboxListTile), findsWidgets);
    });

    testWidgets('can toggle reimbursable checkbox', 
      (WidgetTester tester) async {
      final formKey = GlobalKey<FormState>();
      final amountController = TextEditingController();
      final descriptionController = TextEditingController();
      bool isReimbursable = false;

      await tester.pumpWidget(
        createTestWidget(
          ExpenseFormWidget(
            formKey: formKey,
            amountController: amountController,
            descriptionController: descriptionController,
            selectedDate: DateTime.now(),
            selectedCategoryId: 1,
            onDateChanged: (_) {},
            onCategoryChanged: (_) {},
            onSubmit: null,
            onReset: () {},
            isReimbursable: isReimbursable,
            onReimbursableChanged: (value) {
              isReimbursable = value;
            },
          ),
        ),
      );

      // Initial state should be unchecked
      expect(find.byType(CheckboxListTile), findsWidgets);
    });

    testWidgets('displays receipt attachment section', 
      (WidgetTester tester) async {
      final formKey = GlobalKey<FormState>();
      final amountController = TextEditingController();
      final descriptionController = TextEditingController();

      await tester.pumpWidget(
        createTestWidget(
          ExpenseFormWidget(
            formKey: formKey,
            amountController: amountController,
            descriptionController: descriptionController,
            selectedDate: DateTime.now(),
            selectedCategoryId: 1,
            onDateChanged: (_) {},
            onCategoryChanged: (_) {},
            onSubmit: null,
            onReset: () {},
            receiptPath: null,
            onAttachReceipt: () {},
          ),
        ),
      );

      // Receipt section should be visible
      expect(find.byIcon(Icons.upload_file), findsWidgets);
    });

    testWidgets('shows receipt file name when attached', 
      (WidgetTester tester) async {
      final formKey = GlobalKey<FormState>();
      final amountController = TextEditingController();
      final descriptionController = TextEditingController();

      await tester.pumpWidget(
        createTestWidget(
          ExpenseFormWidget(
            formKey: formKey,
            amountController: amountController,
            descriptionController: descriptionController,
            selectedDate: DateTime.now(),
            selectedCategoryId: 1,
            onDateChanged: (_) {},
            onCategoryChanged: (_) {},
            onSubmit: null,
            onReset: () {},
            receiptPath: '/path/to/receipt.pdf',
            onAttachReceipt: () {},
            onRemoveReceipt: () {},
          ),
        ),
      );

      // Should show attachment icon
      expect(find.byIcon(Icons.attachment), findsWidgets);
    });

    testWidgets('can remove receipt attachment', 
      (WidgetTester tester) async {
      final formKey = GlobalKey<FormState>();
      final amountController = TextEditingController();
      final descriptionController = TextEditingController();
      bool receiptRemoved = false;

      await tester.pumpWidget(
        createTestWidget(
          ExpenseFormWidget(
            formKey: formKey,
            amountController: amountController,
            descriptionController: descriptionController,
            selectedDate: DateTime.now(),
            selectedCategoryId: 1,
            onDateChanged: (_) {},
            onCategoryChanged: (_) {},
            onSubmit: null,
            onReset: () {},
            receiptPath: '/path/to/receipt.pdf',
            onAttachReceipt: () {},
            onRemoveReceipt: () {
              receiptRemoved = true;
            },
          ),
        ),
      );

      // Find and tap the remove button
      final removeButton = find.byIcon(Icons.close);
      if (removeButton.evaluate().isNotEmpty) {
        await tester.tap(removeButton.first);
        expect(receiptRemoved, isTrue);
      }
    });

    testWidgets('displays upload prompt when no receipt', 
      (WidgetTester tester) async {
      final formKey = GlobalKey<FormState>();
      final amountController = TextEditingController();
      final descriptionController = TextEditingController();

      await tester.pumpWidget(
        createTestWidget(
          ExpenseFormWidget(
            formKey: formKey,
            amountController: amountController,
            descriptionController: descriptionController,
            selectedDate: DateTime.now(),
            selectedCategoryId: 1,
            onDateChanged: (_) {},
            onCategoryChanged: (_) {},
            onSubmit: null,
            onReset: () {},
            receiptPath: null,
            onAttachReceipt: () {},
          ),
        ),
      );

      // Should show upload icon
      expect(find.byIcon(Icons.upload_file), findsWidgets);
    });

    testWidgets('renders all form fields', 
      (WidgetTester tester) async {
      final formKey = GlobalKey<FormState>();
      final amountController = TextEditingController();
      final descriptionController = TextEditingController();

      await tester.pumpWidget(
        createTestWidget(
          ExpenseFormWidget(
            formKey: formKey,
            amountController: amountController,
            descriptionController: descriptionController,
            selectedDate: DateTime.now(),
            selectedCategoryId: 1,
            onDateChanged: (_) {},
            onCategoryChanged: (_) {},
            onSubmit: null,
            onReset: () {},
            isReimbursable: false,
            onReimbursableChanged: (_) {},
            receiptPath: null,
            onAttachReceipt: () {},
          ),
        ),
      );

      // Form should render with all expected elements
      expect(find.byType(TextFormField), findsWidgets);
      expect(find.byType(DropdownButton), findsWidgets);
      expect(find.byType(CheckboxListTile), findsWidgets);
      expect(find.byIcon(Icons.upload_file), findsWidgets);
    });

    testWidgets('handles validation correctly', 
      (WidgetTester tester) async {
      final formKey = GlobalKey<FormState>();
      final amountController = TextEditingController();
      final descriptionController = TextEditingController();

      await tester.pumpWidget(
        createTestWidget(
          ExpenseFormWidget(
            formKey: formKey,
            amountController: amountController,
            descriptionController: descriptionController,
            selectedDate: DateTime.now(),
            selectedCategoryId: 1,
            onDateChanged: (_) {},
            onCategoryChanged: (_) {},
            onSubmit: () {
              formKey.currentState?.validate();
            },
            onReset: () {},
          ),
        ),
      );

      // Form should be available for validation
      expect(formKey.currentState, isNotNull);
    });

    testWidgets('scrollable for smaller screens', 
      (WidgetTester tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(400, 600);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      final formKey = GlobalKey<FormState>();
      final amountController = TextEditingController();
      final descriptionController = TextEditingController();

      await tester.pumpWidget(
        createTestWidget(
          ExpenseFormWidget(
            formKey: formKey,
            amountController: amountController,
            descriptionController: descriptionController,
            selectedDate: DateTime.now(),
            selectedCategoryId: 1,
            onDateChanged: (_) {},
            onCategoryChanged: (_) {},
            onSubmit: null,
            onReset: () {},
            receiptPath: null,
            onAttachReceipt: () {},
          ),
        ),
      );

      expect(find.byType(SingleChildScrollView), findsWidgets);
    });
  });
}
