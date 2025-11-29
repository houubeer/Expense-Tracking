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

  Future<int> insertExpense(ExpensesCompanion expense) {
    return _expenseDao.insertExpense(expense);
  }

  Future<bool> updateExpense(Expense expense) {
    return _expenseDao.updateExpense(expense);
  }

  Future<int> deleteExpense(int id) {
    return _expenseDao.deleteExpense(id);
  }
}
