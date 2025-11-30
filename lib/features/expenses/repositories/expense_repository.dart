import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/database/daos/expense_dao.dart';
import 'package:expense_tracking_desktop_app/features/expenses/repositories/i_expense_repository.dart';
import 'package:expense_tracking_desktop_app/features/expenses/services/i_expense_service.dart'
    as domain;

class ExpenseRepository implements IExpenseRepository {
  final ExpenseDao _expenseDao;

  ExpenseRepository(AppDatabase database) : _expenseDao = database.expenseDao;

  @override
  Stream<List<domain.ExpenseWithCategory>> watchExpensesWithCategory() {
    // Map DAO types to domain types
    return _expenseDao.watchExpensesWithCategory().map(
          (daoList) => daoList
              .map(
                (daoExpense) => domain.ExpenseWithCategory(
                  expense: daoExpense.expense,
                  category: daoExpense.category,
                ),
              )
              .toList(),
        );
  }

  Future<int> insertExpense(ExpensesCompanion expense) async {
    try {
      return await _expenseDao.insertExpense(expense);
    } catch (e) {
      throw Exception('Failed to insert expense: $e');
    }
  }

  Future<bool> updateExpense(Expense expense) async {
    try {
      return await _expenseDao.updateExpense(expense);
    } catch (e) {
      throw Exception('Failed to update expense: $e');
    }
  }

  Future<int> deleteExpense(int id) async {
    try {
      return await _expenseDao.deleteExpense(id);
    } catch (e) {
      throw Exception('Failed to delete expense: $e');
    }
  }
}
