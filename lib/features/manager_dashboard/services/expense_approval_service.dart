
import '../repositories/expense_repository.dart';

class ExpenseApprovalService {
  final ExpenseRepository _expenseRepository;

  ExpenseApprovalService(this._expenseRepository);

  Future<bool> approveExpense(String expenseId, String managerId,
      {String managerName = 'Manager'}) async {
    try {
      await _expenseRepository.approveExpense(expenseId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> rejectExpense(
    String expenseId,
    String managerId,
    String reason, {
    String managerName = 'Manager',
  }) async {
    try {
      if (reason.trim().isEmpty) {
        throw ArgumentError('Rejection reason cannot be empty');
      }
      await _expenseRepository.rejectExpense(expenseId, reason);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> addComment(String expenseId, String comment) async {
    if (comment.trim().isEmpty) {
      throw ArgumentError('Comment cannot be empty');
    }
    await _expenseRepository.addComment(expenseId, comment);
  }
}
