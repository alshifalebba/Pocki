import 'package:pocki/domain/entities/expense_entity.dart';
import 'package:pocki/domain/entities/fixed_expense_entity.dart';
import 'package:pocki/domain/repositories/expense_repository.dart';

class GetExpensesStreamUseCase {
  final ExpenseRepository _repository;
  GetExpensesStreamUseCase(this._repository);

  Stream<List<ExpenseEntity>> call(String userId) => _repository.getExpensesStream(userId);
}

class AddExpenseUseCase {
  final ExpenseRepository _repository;
  AddExpenseUseCase(this._repository);

  Future<void> call(ExpenseEntity expense) => _repository.addExpense(expense);
}

class DeleteExpenseUseCase {
  final ExpenseRepository _repository;
  DeleteExpenseUseCase(this._repository);

  Future<void> call(String userId, String expenseId) => _repository.deleteExpense(userId, expenseId);
}

// FIXED EXPENSES USE CASES
class GetFixedExpensesStreamUseCase {
  final ExpenseRepository _repository;
  GetFixedExpensesStreamUseCase(this._repository);

  Stream<List<FixedExpenseEntity>> call(String userId) => _repository.getFixedExpensesStream(userId);
}

class AddFixedExpenseUseCase {
  final ExpenseRepository _repository;
  AddFixedExpenseUseCase(this._repository);

  Future<void> call(FixedExpenseEntity expense) => _repository.addFixedExpense(expense);
}

class UpdateFixedExpenseUseCase {
  final ExpenseRepository _repository;
  UpdateFixedExpenseUseCase(this._repository);

  Future<void> call(FixedExpenseEntity expense) => _repository.updateFixedExpense(expense);
}

class DeleteFixedExpenseUseCase {
  final ExpenseRepository _repository;
  DeleteFixedExpenseUseCase(this._repository);

  Future<void> call(String userId, String fixedExpenseId) => _repository.deleteFixedExpense(userId, fixedExpenseId);
}
