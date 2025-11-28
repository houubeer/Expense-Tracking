import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/database/daos/expense_dao.dart';

class ExpenseRepository {
  final ExpenseDao _expenseDao;

  ExpenseRepository(AppDatabase database) : _expenseDao = database.expenseDao;

  Stream<List<ExpenseWithCategory>> watchExpensesWithCategory() {
    return _expenseDao.watchExpensesWithCategory();
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
