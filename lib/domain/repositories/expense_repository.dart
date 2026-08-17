import '../../domain/entities/expense_entity.dart';
import '../../domain/entities/fixed_expense_entity.dart';

abstract class ExpenseRepository {
  Stream<List<ExpenseEntity>> getExpensesStream(String userId);
  Future<List<ExpenseEntity>> getCachedExpenses();
  Future<void> addExpense(ExpenseEntity expense);
  Future<void> deleteExpense(String userId, String expenseId);

  // Fixed Expenses
  Stream<List<FixedExpenseEntity>> getFixedExpensesStream(String userId);
  Future<List<FixedExpenseEntity>> getCachedFixedExpenses();
  Future<void> addFixedExpense(FixedExpenseEntity expense);
  Future<void> updateFixedExpense(FixedExpenseEntity expense);
  Future<void> deleteFixedExpense(String userId, String fixedExpenseId);
}
