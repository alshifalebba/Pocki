import '../../domain/entities/expense_entity.dart';
import '../../domain/entities/fixed_expense_entity.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/firebase/firebase_data_source.dart';
import '../datasources/local/local_cache_data_source.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final FirebaseDataSource _firebaseDataSource;
  final LocalCacheDataSource _localCacheDataSource;

  ExpenseRepositoryImpl(this._firebaseDataSource, this._localCacheDataSource);

  @override
  Stream<List<ExpenseEntity>> getExpensesStream(String userId) {
    return _firebaseDataSource.streamExpenses(userId).map((list) {
      _localCacheDataSource.cacheExpenses(list);
      return list;
    });
  }

  @override
  Future<List<ExpenseEntity>> getCachedExpenses() {
    return _localCacheDataSource.getCachedExpenses();
  }

  @override
  Future<void> addExpense(ExpenseEntity expense) async {
    await _firebaseDataSource.addExpense(expense);
  }

  @override
  Future<void> deleteExpense(String userId, String expenseId) async {
    await _firebaseDataSource.deleteExpense(userId, expenseId);
  }

  // FIXED EXPENSES
  @override
  Stream<List<FixedExpenseEntity>> getFixedExpensesStream(String userId) {
    return _firebaseDataSource.streamFixedExpenses(userId).map((list) {
      _localCacheDataSource.cacheFixedExpenses(list);
      return list;
    });
  }

  @override
  Future<List<FixedExpenseEntity>> getCachedFixedExpenses() {
    return _localCacheDataSource.getCachedFixedExpenses();
  }

  @override
  Future<void> addFixedExpense(FixedExpenseEntity expense) async {
    await _firebaseDataSource.addFixedExpense(expense);
  }

  @override
  Future<void> updateFixedExpense(FixedExpenseEntity expense) async {
    await _firebaseDataSource.updateFixedExpense(expense);
  }

  @override
  Future<void> deleteFixedExpense(String userId, String fixedExpenseId) async {
    await _firebaseDataSource.deleteFixedExpense(userId, fixedExpenseId);
  }
}
