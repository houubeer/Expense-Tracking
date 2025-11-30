import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:expense_tracking_desktop_app/features/budget/view_models/budget_view_model.dart';
import 'package:expense_tracking_desktop_app/features/budget/repositories/i_category_reader.dart';
import 'package:expense_tracking_desktop_app/features/budget/repositories/i_category_writer.dart';
import 'package:expense_tracking_desktop_app/services/error_reporting_service.dart';
import 'package:expense_tracking_desktop_app/database/app_database.dart';

import 'budget_view_model_comprehensive_test.mocks.dart';

@GenerateMocks([ICategoryReader, ICategoryWriter, ErrorReportingService])
void main() {
  late BudgetViewModel viewModel;
  late MockICategoryReader mockReader;
  late MockICategoryWriter mockWriter;
  late MockErrorReportingService mockErrorReporting;

  setUp(() {
    mockReader = MockICategoryReader();
    mockWriter = MockICategoryWriter();
    mockErrorReporting = MockErrorReportingService();

    viewModel = BudgetViewModel(
      mockReader,
      mockWriter,
      mockErrorReporting,
    );
  });

  tearDown(() {
    viewModel.dispose();
  });

  group('BudgetViewModel - Comprehensive Tests', () {
    group('addCategory', () {
      test('should successfully add a valid category', () async {
        // Arrange
        when(mockWriter.insertCategory(any)).thenAnswer((_) async => 1);

        // Act
        await viewModel.addCategory(
          name: 'Food',
          budget: 500.0,
          color: 0xFF4CAF50,
          iconCodePoint: '0xe3e7',
        );

        // Assert
        verify(mockWriter.insertCategory(any)).called(1);
      });

      test('should throw validation error for empty name', () async {
        // Act & Assert
        expect(
          () => viewModel.addCategory(
            name: '',
            budget: 500.0,
            color: 0xFF4CAF50,
            iconCodePoint: '0xe3e7',
          ),
          throwsException,
        );

        verifyNever(mockWriter.insertCategory(any));
      });

      test('should throw validation error for negative budget', () async {
        // Act & Assert
        expect(
          () => viewModel.addCategory(
            name: 'Food',
            budget: -100.0,
            color: 0xFF4CAF50,
            iconCodePoint: '0xe3e7',
          ),
          throwsException,
        );

        verifyNever(mockWriter.insertCategory(any));
      });

      test('should trim category name before insertion', () async {
        // Arrange
        when(mockWriter.insertCategory(any)).thenAnswer((_) async => 1);

        // Act
        await viewModel.addCategory(
          name: '  Food  ',
          budget: 500.0,
          color: 0xFF4CAF50,
          iconCodePoint: '0xe3e7',
        );

        // Assert
        final captured = verify(mockWriter.insertCategory(captureAny)).captured;
        final companion = captured[0] as CategoriesCompanion;
        expect(companion.name.value, equals('Food'));
      });
    });

    group('deleteCategory', () {
      test('should successfully delete a category', () async {
        // Arrange
        when(mockWriter.deleteCategory(1))
            .thenAnswer((_) async => Future.value());

        // Act
        await viewModel.deleteCategory(1);

        // Assert
        verify(mockWriter.deleteCategory(1)).called(1);
      });

      test('should handle errors when deleting category', () async {
        // Arrange
        when(mockWriter.deleteCategory(1))
            .thenThrow(Exception('Cannot delete'));

        // Act & Assert
        expect(
          () => viewModel.deleteCategory(1),
          throwsException,
        );
      });
    });
  });
}
