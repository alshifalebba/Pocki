import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user_profile.dart';
import '../models/expense.dart';
import '../models/todo.dart';

class DataRepository extends ChangeNotifier {
  static final DataRepository instance = DataRepository._internal();
  factory DataRepository() => instance;
  DataRepository._internal();

  UserProfile _user = UserProfile.defaultUser();
  List<Expense> _expenses = [];
  List<TodoTask> _todos = [];
  bool _initialized = false;

  UserProfile get user => _user;
  List<Expense> get expenses => List.unmodifiable(_expenses);
  List<TodoTask> get todos => List.unmodifiable(_todos);

  Future<void> init() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();

    // Load User
    final userJson = prefs.getString('pocki_user');
    if (userJson != null) {
      try {
        _user = UserProfile.fromJson(jsonDecode(userJson));
      } catch (e) {
        _user = UserProfile.defaultUser();
      }
    } else {
      _user = UserProfile.defaultUser();
      await saveUser(_user);
    }

    // Load Expenses
    final expensesJson = prefs.getStringList('pocki_expenses');
    if (expensesJson != null && expensesJson.isNotEmpty) {
      try {
        _expenses = expensesJson
            .map((e) => Expense.fromJson(jsonDecode(e)))
            .toList();
      } catch (e) {
        _loadDefaultExpenses();
      }
    } else {
      _loadDefaultExpenses();
      await _persistExpenses();
    }

    // Load Todos
    final todosJson = prefs.getStringList('pocki_todos');
    if (todosJson != null && todosJson.isNotEmpty) {
      try {
        _todos = todosJson
            .map((t) => TodoTask.fromJson(jsonDecode(t)))
            .toList();
      } catch (e) {
        _loadDefaultTodos();
      }
    } else {
      _loadDefaultTodos();
      await _persistTodos();
    }

    _initialized = true;
    notifyListeners();
  }

  void _loadDefaultExpenses() {
    final now = DateTime.now();
    _expenses = [
      Expense(
        id: const Uuid().v4(),
        category: ExpenseCategory.food,
        amount: 180.0,
        date: now,
        time: '01:20 PM',
        description: 'Lunch bowl',
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      Expense(
        id: const Uuid().v4(),
        category: ExpenseCategory.petrol,
        amount: 400.0,
        date: now,
        time: '09:15 AM',
        description: 'Fuel refilling',
        createdAt: now.subtract(const Duration(hours: 6)),
      ),
      Expense(
        id: const Uuid().v4(),
        category: ExpenseCategory.dress,
        amount: 1250.0,
        date: now.subtract(const Duration(days: 1)),
        time: '06:20 PM',
        description: 'Summer top',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      Expense(
        id: const Uuid().v4(),
        category: ExpenseCategory.groceries,
        amount: 620.0,
        date: now.subtract(const Duration(days: 1)),
        time: '10:00 AM',
        description: 'Weekly fruits & snacks',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      Expense(
        id: const Uuid().v4(),
        category: ExpenseCategory.other,
        amount: 150.0,
        date: now.subtract(const Duration(days: 2)),
        time: '08:45 PM',
        otherDetails: 'Birthday gift wrap',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
    ];
  }

  void _loadDefaultTodos() {
    final now = DateTime.now();
    _todos = [
      TodoTask(
        id: const Uuid().v4(),
        title: 'Study Flutter UI 📚',
        startDate: now,
        endDate: now,
        time: '06:00 PM',
        isCompleted: false,
        createdAt: now,
      ),
      TodoTask(
        id: const Uuid().v4(),
        title: 'Go to Gym 💪',
        startDate: now,
        endDate: now,
        time: '07:30 PM',
        isCompleted: false,
        createdAt: now,
      ),
      TodoTask(
        id: const Uuid().v4(),
        title: 'Project Submission 💻',
        startDate: now.add(const Duration(days: 1)),
        endDate: now.add(const Duration(days: 3)),
        time: '05:00 PM',
        isCompleted: false,
        createdAt: now,
      ),
      TodoTask(
        id: const Uuid().v4(),
        title: 'Buy Birthday Gift 🎁',
        startDate: now.add(const Duration(days: 2)),
        endDate: now.add(const Duration(days: 4)),
        time: '04:00 PM',
        isCompleted: false,
        createdAt: now,
      ),
      TodoTask(
        id: const Uuid().v4(),
        title: 'Read 20 pages 📖',
        startDate: now.subtract(const Duration(days: 3)),
        endDate: now.subtract(const Duration(days: 3)),
        time: '09:00 PM',
        isCompleted: true,
        createdAt: now.subtract(const Duration(days: 3)),
        completedAt: now.subtract(const Duration(days: 3)),
      ),
    ];
  }

  Future<void> saveUser(UserProfile updatedUser) async {
    _user = updatedUser;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pocki_user', jsonEncode(_user.toJson()));
    notifyListeners();
  }

  Future<void> addExpense(Expense expense) async {
    _expenses.insert(0, expense);
    await _persistExpenses();
    notifyListeners();
  }

  Future<void> deleteExpense(String id) async {
    _expenses.removeWhere((e) => e.id == id);
    await _persistExpenses();
    notifyListeners();
  }

  Future<void> addTodo(TodoTask task) async {
    _todos.insert(0, task);
    await _persistTodos();
    notifyListeners();
  }

  Future<void> toggleTodoStatus(String id) async {
    final index = _todos.indexWhere((t) => t.id == id);
    if (index != -1) {
      final old = _todos[index];
      _todos[index] = old.copyWith(
        isCompleted: !old.isCompleted,
        completedAt: !old.isCompleted ? DateTime.now() : null,
      );
      await _persistTodos();
      notifyListeners();
    }
  }

  Future<void> deleteTodo(String id) async {
    _todos.removeWhere((t) => t.id == id);
    await _persistTodos();
    notifyListeners();
  }

  Future<void> _persistExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _expenses.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('pocki_expenses', list);
  }

  Future<void> _persistTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _todos.map((t) => jsonEncode(t.toJson())).toList();
    await prefs.setStringList('pocki_todos', list);
  }

  // Calculation helpers
  double get monthlyExpensesTotal {
    final now = DateTime.now();
    return _expenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double get todayExpenseTotal {
    final now = DateTime.now();
    return _expenses
        .where((e) =>
            e.date.year == now.year &&
            e.date.month == now.month &&
            e.date.day == now.day)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double get remainingBudget => _user.monthlyBudget - monthlyExpensesTotal;

  int get daysRemainingInMonth {
    final now = DateTime.now();
    final lastDay = DateTime(now.year, now.month + 1, 0).day;
    return (lastDay - now.day) + 1;
  }

  double get dailySafeSpending {
    final remDays = daysRemainingInMonth;
    if (remDays <= 0) return 0;
    final rem = remainingBudget;
    return rem > 0 ? rem / remDays : 0;
  }

  double get dailyAverageSpent {
    final now = DateTime.now();
    final currentDay = now.day;
    return currentDay > 0 ? monthlyExpensesTotal / currentDay : 0;
  }
}
