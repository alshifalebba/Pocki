import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/todo_entity.dart';
import '../../../../domain/usecases/todo_usecases.dart';

// EVENTS
abstract class TodoEvent {}

class LoadTodosEvent extends TodoEvent {
  final String userId;
  LoadTodosEvent(this.userId);
}

class TodosUpdatedEvent extends TodoEvent {
  final List<TodoEntity> todos;
  TodosUpdatedEvent(this.todos);
}

class AddTodoSubmittedEvent extends TodoEvent {
  final TodoEntity todo;
  AddTodoSubmittedEvent(this.todo);
}

class UpdateTodoSubmittedEvent extends TodoEvent {
  final TodoEntity todo;
  UpdateTodoSubmittedEvent(this.todo);
}

class ToggleTodoCompletedEvent extends TodoEvent {
  final TodoEntity todo;
  ToggleTodoCompletedEvent(this.todo);
}

class DeleteTodoSubmittedEvent extends TodoEvent {
  final String userId;
  final String todoId;
  DeleteTodoSubmittedEvent({required this.userId, required this.todoId});
}

// STATES
abstract class TodoState {}

class TodoInitialState extends TodoState {}

class TodoLoadingState extends TodoState {}

class TodoLoadedState extends TodoState {
  final List<TodoEntity> todos;
  TodoLoadedState(this.todos);
}

class TodoFailureState extends TodoState {
  final String errorMessage;
  TodoFailureState(this.errorMessage);
}

// BLOC
class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final GetTodosStreamUseCase getTodosStreamUseCase;
  final AddTodoUseCase addTodoUseCase;
  final UpdateTodoUseCase updateTodoUseCase;
  final DeleteTodoUseCase deleteTodoUseCase;
  StreamSubscription<List<TodoEntity>>? _todosSubscription;

  TodoBloc({
    required this.getTodosStreamUseCase,
    required this.addTodoUseCase,
    required this.updateTodoUseCase,
    required this.deleteTodoUseCase,
  }) : super(TodoInitialState()) {
    on<LoadTodosEvent>(_onLoadTodos);
    on<TodosUpdatedEvent>(_onTodosUpdated);
    on<AddTodoSubmittedEvent>(_onAddTodoSubmitted);
    on<UpdateTodoSubmittedEvent>(_onUpdateTodoSubmitted);
    on<ToggleTodoCompletedEvent>(_onToggleTodoCompleted);
    on<DeleteTodoSubmittedEvent>(_onDeleteTodoSubmitted);
  }

  void _onLoadTodos(LoadTodosEvent event, Emitter<TodoState> emit) {
    emit(TodoLoadingState());
    _todosSubscription?.cancel();
    _todosSubscription = getTodosStreamUseCase(event.userId).listen(
      (todos) => add(TodosUpdatedEvent(todos)),
      onError: (error) => emit(TodoFailureState(error.toString())),
    );
  }

  void _onTodosUpdated(TodosUpdatedEvent event, Emitter<TodoState> emit) {
    emit(TodoLoadedState(event.todos));
  }

  Future<void> _onAddTodoSubmitted(
    AddTodoSubmittedEvent event,
    Emitter<TodoState> emit,
  ) async {
    try {
      await addTodoUseCase(event.todo);
    } catch (e) {
      emit(TodoFailureState(e.toString()));
    }
  }

  Future<void> _onUpdateTodoSubmitted(
    UpdateTodoSubmittedEvent event,
    Emitter<TodoState> emit,
  ) async {
    try {
      await updateTodoUseCase(event.todo);
    } catch (e) {
      emit(TodoFailureState(e.toString()));
    }
  }

  Future<void> _onToggleTodoCompleted(
    ToggleTodoCompletedEvent event,
    Emitter<TodoState> emit,
  ) async {
    try {
      final updated = event.todo.copyWith(
        completed: !event.todo.completed,
        updatedAt: DateTime.now(),
      );
      await updateTodoUseCase(updated);
    } catch (e) {
      emit(TodoFailureState(e.toString()));
    }
  }

  Future<void> _onDeleteTodoSubmitted(
    DeleteTodoSubmittedEvent event,
    Emitter<TodoState> emit,
  ) async {
    try {
      await deleteTodoUseCase(event.userId, event.todoId);
    } catch (e) {
      emit(TodoFailureState(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _todosSubscription?.cancel();
    return super.close();
  }
}
