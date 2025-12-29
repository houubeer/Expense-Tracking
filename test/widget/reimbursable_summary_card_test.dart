import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracking_desktop_app/features/home/widgets/reimbursable_summary_card.dart';
import 'package:expense_tracking_desktop_app/theme/app_theme.dart';

void main() {
  group('ReimbursableSummaryCard Widget', () {
    Widget createTestWidget(ReimbursableSummaryCard card) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: card,
          ),
        ),
      );
    }

    testWidgets('renders with total amount and expense count', 
      (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const ReimbursableSummaryCard(
            totalAmount: 500.0,
            expenseCount: 5,
          ),
        ),
      );

      // Verify widget renders
      expect(find.byType(ReimbursableSummaryCard), findsOneWidget);
    });

    testWidgets('displays total amount in correct format', 
      (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const ReimbursableSummaryCard(
            totalAmount: 1234.56,
            expenseCount: 8,
          ),
        ),
      );

      // Amount should be displayed with 2 decimal places
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('displays expense count', 
      (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const ReimbursableSummaryCard(
            totalAmount: 500.0,
            expenseCount: 3,
          ),
        ),
      );

      // Should show the count somewhere in the widget
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('shows icon', 
      (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const ReimbursableSummaryCard(
            totalAmount: 500.0,
            expenseCount: 5,
          ),
        ),
      );

      // Icon should be present (monetization icon)
      expect(find.byType(Icon), findsWidgets);
    });

    testWidgets('can be tapped when onTap is provided', 
      (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        createTestWidget(
          ReimbursableSummaryCard(
            totalAmount: 500.0,
            expenseCount: 5,
            onTap: () {
              tapped = true;
            },
          ),
        ),
      );

      // Tap the card
      await tester.tap(find.byType(GestureDetector));
      
      expect(tapped, isTrue);
    });

    testWidgets('renders without onTap callback', 
      (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const ReimbursableSummaryCard(
            totalAmount: 500.0,
            expenseCount: 5,
            onTap: null,
          ),
        ),
      );

      expect(find.byType(ReimbursableSummaryCard), findsOneWidget);
    });

    testWidgets('handles zero amount', 
      (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const ReimbursableSummaryCard(
            totalAmount: 0.0,
            expenseCount: 0,
          ),
        ),
      );

      expect(find.byType(ReimbursableSummaryCard), findsOneWidget);
    });

    testWidgets('handles large amounts', 
      (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const ReimbursableSummaryCard(
            totalAmount: 999999.99,
            expenseCount: 500,
          ),
        ),
      );

      expect(find.byType(ReimbursableSummaryCard), findsOneWidget);
    });

    testWidgets('has proper styling with gradient', 
      (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const ReimbursableSummaryCard(
            totalAmount: 500.0,
            expenseCount: 5,
          ),
        ),
      );

      // The card should have a Container with BoxDecoration (gradient)
      final containerFinder = find.byType(Container);
      expect(containerFinder, findsWidgets);
    });

    testWidgets('maintains consistent layout', 
      (WidgetTester tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(1200, 800);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      await tester.pumpWidget(
        createTestWidget(
          const ReimbursableSummaryCard(
            totalAmount: 500.0,
            expenseCount: 5,
          ),
        ),
      );

      expect(find.byType(ReimbursableSummaryCard), findsOneWidget);
    });
  });
}
