import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/database/daos/expense_dao.dart';

abstract class IExpenseRepository {
  Stream<List<ExpenseWithCategory>> watchExpensesWithCategory();
  Future<int> insertExpense(ExpensesCompanion expense);
  Future<bool> updateExpense(Expense expense);
  Future<int> deleteExpense(int id);
}
