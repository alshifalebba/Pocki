import '../../domain/entities/todo_entity.dart';
import '../../domain/repositories/todo_repository.dart';
import '../datasources/firebase/firebase_data_source.dart';
import '../datasources/local/local_cache_data_source.dart';

class TodoRepositoryImpl implements TodoRepository {
  final FirebaseDataSource _firebaseDataSource;
  final LocalCacheDataSource _localCacheDataSource;

  TodoRepositoryImpl(this._firebaseDataSource, this._localCacheDataSource);

  @override
  Stream<List<TodoEntity>> getTodosStream(String userId) {
    return _firebaseDataSource.streamTodos(userId).map((list) {
      _localCacheDataSource.cacheTodos(list);
      return list;
    });
  }

  @override
  Future<List<TodoEntity>> getCachedTodos() {
    return _localCacheDataSource.getCachedTodos();
  }

  @override
  Future<void> addTodo(TodoEntity todo) async {
    await _firebaseDataSource.addTodo(todo);
  }

  @override
  Future<void> updateTodo(TodoEntity todo) async {
    await _firebaseDataSource.updateTodo(todo);
  }

  @override
  Future<void> deleteTodo(String userId, String todoId) async {
    await _firebaseDataSource.deleteTodo(userId, todoId);
  }
}
