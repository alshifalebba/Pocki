import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pocki/core/errors/app_exceptions.dart';
import 'package:pocki/domain/entities/additional_amount_entity.dart';
import 'package:pocki/domain/entities/expense_entity.dart';
import 'package:pocki/domain/entities/fixed_expense_entity.dart';
import 'package:pocki/domain/entities/todo_entity.dart';
import 'package:pocki/domain/entities/user_entity.dart';

class FirebaseDataSource {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // AUTH API
  Future<UserEntity> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserEntity.fromDocument(doc.data()!);
      } else {
        final newUser = UserEntity.defaultUser(uid, email);
        await _firestore.collection('users').doc(uid).set(newUser.toDocument());
        return newUser;
      }
    } on FirebaseAuthException catch (e) {
      throw AppExceptions.fromFirebaseAuth(e.code);
    } catch (e) {
      throw AppExceptions(e.toString());
    }
  }

  Future<UserEntity> register({
    required String name,
    required String nickname,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;
      final now = DateTime.now();

      final user = UserEntity(
        uid: uid,
        name: name,
        nickname: nickname,
        email: email,
        phone: phone,
        avatarUrl: null,
        monthlyBudget: 15000.0,
        quote: 'Stay focused and make it happen. ✨',
        createdAt: now,
        updatedAt: now,
      );

      await _firestore.collection('users').doc(uid).set(user.toDocument());
      return user;
    } on FirebaseAuthException catch (e) {
      throw AppExceptions.fromFirebaseAuth(e.code);
    } catch (e) {
      throw AppExceptions(e.toString());
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<UserEntity?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserEntity.fromDocument(doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> updateUserProfile(UserEntity user) async {
    await _firestore.collection('users').doc(user.uid).set(
          user.toDocument(),
          SetOptions(merge: true),
        );
  }

  // EXPENSES FIRESTORE API
  Future<void> addExpense(ExpenseEntity expense) async {
    await _firestore
        .collection('users')
        .doc(expense.userId)
        .collection('expenses')
        .doc(expense.id)
        .set(expense.toDocument());
  }

  Future<void> deleteExpense(String userId, String expenseId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .doc(expenseId)
        .delete();
  }

  Stream<List<ExpenseEntity>> streamExpenses(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ExpenseEntity.fromDocument(doc.data())).toList());
  }

  // FIXED EXPENSES FIRESTORE API
  Future<void> addFixedExpense(FixedExpenseEntity expense) async {
    await _firestore
        .collection('users')
        .doc(expense.userId)
        .collection('fixedExpenses')
        .doc(expense.id)
        .set(expense.toDocument());
  }

  Future<void> updateFixedExpense(FixedExpenseEntity expense) async {
    await _firestore
        .collection('users')
        .doc(expense.userId)
        .collection('fixedExpenses')
        .doc(expense.id)
        .set(expense.toDocument(), SetOptions(merge: true));
  }

  Future<void> deleteFixedExpense(String userId, String fixedExpenseId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('fixedExpenses')
        .doc(fixedExpenseId)
        .delete();
  }

  Stream<List<FixedExpenseEntity>> streamFixedExpenses(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('fixedExpenses')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => FixedExpenseEntity.fromDocument(doc.data())).toList());
  }

  // ADDITIONAL AMOUNTS FIRESTORE API
  Future<void> addAdditionalAmount(AdditionalAmountEntity amount) async {
    await _firestore
        .collection('users')
        .doc(amount.userId)
        .collection('additionalAmounts')
        .doc(amount.id)
        .set(amount.toDocument());
  }

  Future<void> updateAdditionalAmount(AdditionalAmountEntity amount) async {
    await _firestore
        .collection('users')
        .doc(amount.userId)
        .collection('additionalAmounts')
        .doc(amount.id)
        .set(amount.toDocument(), SetOptions(merge: true));
  }

  Future<void> deleteAdditionalAmount(String userId, String additionalAmountId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('additionalAmounts')
        .doc(additionalAmountId)
        .delete();
  }

  Stream<List<AdditionalAmountEntity>> streamAdditionalAmounts(
      String userId, int month, int year) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('additionalAmounts')
        .snapshots()
        .map((snapshot) {
          final items = snapshot.docs
              .map((doc) => AdditionalAmountEntity.fromDocument(doc.data()))
              .where((item) => item.month == month && item.year == year)
              .toList();
          items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return items;
        });
  }

  // TODOS FIRESTORE API
  Future<void> addTodo(TodoEntity todo) async {
    await _firestore
        .collection('users')
        .doc(todo.userId)
        .collection('todos')
        .doc(todo.id)
        .set(todo.toDocument());
  }

  Future<void> updateTodo(TodoEntity todo) async {
    await _firestore
        .collection('users')
        .doc(todo.userId)
        .collection('todos')
        .doc(todo.id)
        .set(todo.toDocument(), SetOptions(merge: true));
  }

  Future<void> deleteTodo(String userId, String todoId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('todos')
        .doc(todoId)
        .delete();
  }

  Stream<List<TodoEntity>> streamTodos(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('todos')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TodoEntity.fromDocument(doc.data())).toList());
  }
}
