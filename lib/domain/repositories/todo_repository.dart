import '../../domain/entities/todo_entity.dart';

abstract class TodoRepository {
  Stream<List<TodoEntity>> getTodosStream(String userId);
  Future<List<TodoEntity>> getCachedTodos();
  Future<void> addTodo(TodoEntity todo);
  Future<void> updateTodo(TodoEntity todo);
  Future<void> deleteTodo(String userId, String todoId);
}
