import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:expense_tracking_desktop_app/features/home/widgets/reimbursable_summary_card.dart';
import 'package:expense_tracking_desktop_app/constants/strings.dart';

void main() {
  group('ReimbursableSummaryCard Widget Tests', () {
    testWidgets('Display reimbursable summary with amount and count',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReimbursableSummaryCard(
              totalAmount: 2500.50,
              expenseCount: 5,
            ),
          ),
        ),
      );

      expect(find.byType(ReimbursableSummaryCard), findsOneWidget);
      expect(find.textContaining('2500.50'), findsOneWidget);
      expect(find.textContaining('5'), findsWidgets);
    });

    testWidgets('Display monetary icon for reimbursable expenses',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReimbursableSummaryCard(
              totalAmount: 1000.0,
              expenseCount: 3,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.monetization_on_outlined), findsWidgets);
    });

    testWidgets('Show correct expense count label', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReimbursableSummaryCard(
              totalAmount: 500.0,
              expenseCount: 2,
            ),
          ),
        ),
      );

      expect(find.textContaining('2'), findsWidgets);
    });

    testWidgets('Formatted currency display with 2 decimals',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReimbursableSummaryCard(
              totalAmount: 1234.56,
              expenseCount: 1,
            ),
          ),
        ),
      );

      expect(find.textContaining('1234.56'), findsOneWidget);
    });

    testWidgets('Zero decimal formatting', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReimbursableSummaryCard(
              totalAmount: 100.0,
              expenseCount: 1,
            ),
          ),
        ),
      );

      expect(find.textContaining('100.00'), findsOneWidget);
    });

    testWidgets('Card is interactive when onTap provided',
        (WidgetTester tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReimbursableSummaryCard(
              totalAmount: 1000.0,
              expenseCount: 5,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ReimbursableSummaryCard));
      expect(tapped, isTrue);
    });

    testWidgets('Gradient background renders', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReimbursableSummaryCard(
              totalAmount: 500.0,
              expenseCount: 2,
            ),
          ),
        ),
      );

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('Large amount displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReimbursableSummaryCard(
              totalAmount: 999999.99,
              expenseCount: 100,
            ),
          ),
        ),
      );

      expect(find.textContaining('999999.99'), findsOneWidget);
    });

    testWidgets('Large count displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReimbursableSummaryCard(
              totalAmount: 10000.0,
              expenseCount: 500,
            ),
          ),
        ),
      );

      expect(find.textContaining('500'), findsWidgets);
    });
  });
}
