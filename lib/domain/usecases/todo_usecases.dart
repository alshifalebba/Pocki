import 'package:pocki/domain/entities/todo_entity.dart';
import 'package:pocki/domain/repositories/todo_repository.dart';

class GetTodosStreamUseCase {
  final TodoRepository _repository;
  GetTodosStreamUseCase(this._repository);

  Stream<List<TodoEntity>> call(String userId) => _repository.getTodosStream(userId);
}

class AddTodoUseCase {
  final TodoRepository _repository;
  AddTodoUseCase(this._repository);

  Future<void> call(TodoEntity todo) => _repository.addTodo(todo);
}

class UpdateTodoUseCase {
  final TodoRepository _repository;
  UpdateTodoUseCase(this._repository);

  Future<void> call(TodoEntity todo) => _repository.updateTodo(todo);
}

class DeleteTodoUseCase {
  final TodoRepository _repository;
  DeleteTodoUseCase(this._repository);

  Future<void> call(String userId, String todoId) => _repository.deleteTodo(userId, todoId);
}
