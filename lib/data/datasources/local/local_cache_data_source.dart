import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocki/domain/entities/expense_entity.dart';
import 'package:pocki/domain/entities/fixed_expense_entity.dart';
import 'package:pocki/domain/entities/todo_entity.dart';
import 'package:pocki/domain/entities/user_entity.dart';

class LocalCacheDataSource {
  static const String _userKey = 'pocki_cached_user';
  static const String _expensesKey = 'pocki_cached_expenses';
  static const String _todosKey = 'pocki_cached_todos';
  static const String _fixedExpensesKey = 'pocki_cached_fixed_expenses';

  Future<void> cacheUser(UserEntity user) async {
    final prefs = await SharedPreferences.getInstance();
    // toJson() uses ISO 8601 strings — safe for dart:convert jsonEncode()
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<UserEntity?> getCachedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_userKey);
    if (jsonStr != null) {
      try {
        return UserEntity.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Future<void> cacheExpenses(List<ExpenseEntity> list) async {
    final prefs = await SharedPreferences.getInstance();
    // toJson() uses ISO 8601 strings — safe for dart:convert jsonEncode()
    final jsonList = list.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_expensesKey, jsonList);
  }

  Future<List<ExpenseEntity>> getCachedExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_expensesKey);
    if (jsonList != null) {
      try {
        return jsonList
            .map((e) => ExpenseEntity.fromJson(
                jsonDecode(e) as Map<String, dynamic>))
            .toList();
      } catch (_) {
        return [];
      }
    }
    return [];
  }

  Future<void> cacheTodos(List<TodoEntity> list) async {
    final prefs = await SharedPreferences.getInstance();
    // toJson() uses ISO 8601 strings — safe for dart:convert jsonEncode()
    final jsonList = list.map((t) => jsonEncode(t.toJson())).toList();
    await prefs.setStringList(_todosKey, jsonList);
  }

  Future<List<TodoEntity>> getCachedTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_todosKey);
    if (jsonList != null) {
      try {
        return jsonList
            .map((t) =>
                TodoEntity.fromJson(jsonDecode(t) as Map<String, dynamic>))
            .toList();
      } catch (_) {
        return [];
      }
    }
    return [];
  }

  Future<void> cacheFixedExpenses(List<FixedExpenseEntity> list) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = list.map((f) => jsonEncode(f.toJson())).toList();
    await prefs.setStringList(_fixedExpensesKey, jsonList);
  }

  Future<List<FixedExpenseEntity>> getCachedFixedExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_fixedExpensesKey);
    if (jsonList != null) {
      try {
        return jsonList
            .map((f) => FixedExpenseEntity.fromJson(
                jsonDecode(f) as Map<String, dynamic>))
            .toList();
      } catch (_) {
        return [];
      }
    }
    return [];
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_expensesKey);
    await prefs.remove(_todosKey);
    await prefs.remove(_fixedExpensesKey);
  }
}
