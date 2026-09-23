import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/additional_amount_entity.dart';
import '../../../../domain/entities/expense_entity.dart';
import '../../../../domain/entities/fixed_expense_entity.dart';
import '../../../../domain/usecases/additional_amount_usecases.dart';
import '../../../../domain/usecases/expense_usecases.dart';

// EVENTS
abstract class ExpenseEvent {}

class LoadExpensesEvent extends ExpenseEvent {
  final String userId;
  LoadExpensesEvent(this.userId);
}

class ExpensesUpdatedEvent extends ExpenseEvent {
  final List<ExpenseEntity> expenses;
  ExpensesUpdatedEvent(this.expenses);
}

class FixedExpensesUpdatedEvent extends ExpenseEvent {
  final List<FixedExpenseEntity> fixedExpenses;
  FixedExpensesUpdatedEvent(this.fixedExpenses);
}

class AdditionalAmountsUpdatedEvent extends ExpenseEvent {
  final List<AdditionalAmountEntity> additionalAmounts;
  AdditionalAmountsUpdatedEvent(this.additionalAmounts);
}

class AddExpenseSubmittedEvent extends ExpenseEvent {
  final ExpenseEntity expense;
  AddExpenseSubmittedEvent(this.expense);
}

class DeleteExpenseSubmittedEvent extends ExpenseEvent {
  final String userId;
  final String expenseId;
  DeleteExpenseSubmittedEvent({required this.userId, required this.expenseId});
}

class AddFixedExpenseSubmittedEvent extends ExpenseEvent {
  final FixedExpenseEntity fixedExpense;
  AddFixedExpenseSubmittedEvent(this.fixedExpense);
}

class UpdateFixedExpenseSubmittedEvent extends ExpenseEvent {
  final FixedExpenseEntity fixedExpense;
  UpdateFixedExpenseSubmittedEvent(this.fixedExpense);
}

class DeleteFixedExpenseSubmittedEvent extends ExpenseEvent {
  final String userId;
  final String fixedExpenseId;
  DeleteFixedExpenseSubmittedEvent({required this.userId, required this.fixedExpenseId});
}

// Additional Amount Events
class AddAdditionalAmountSubmittedEvent extends ExpenseEvent {
  final AdditionalAmountEntity additionalAmount;
  AddAdditionalAmountSubmittedEvent(this.additionalAmount);
}

class UpdateAdditionalAmountSubmittedEvent extends ExpenseEvent {
  final AdditionalAmountEntity additionalAmount;
  UpdateAdditionalAmountSubmittedEvent(this.additionalAmount);
}

class DeleteAdditionalAmountSubmittedEvent extends ExpenseEvent {
  final String userId;
  final String additionalAmountId;
  DeleteAdditionalAmountSubmittedEvent(
      {required this.userId, required this.additionalAmountId});
}

// STATES
abstract class ExpenseState {}

class ExpenseInitialState extends ExpenseState {}

class ExpenseLoadingState extends ExpenseState {}

class ExpenseLoadedState extends ExpenseState {
  final List<ExpenseEntity> expenses;
  final List<FixedExpenseEntity> fixedExpenses;
  final List<AdditionalAmountEntity> additionalAmounts;

  ExpenseLoadedState({
    required this.expenses,
    this.fixedExpenses = const [],
    this.additionalAmounts = const [],
  });

  ExpenseLoadedState copyWith({
    List<ExpenseEntity>? expenses,
    List<FixedExpenseEntity>? fixedExpenses,
    List<AdditionalAmountEntity>? additionalAmounts,
  }) {
    return ExpenseLoadedState(
      expenses: expenses ?? this.expenses,
      fixedExpenses: fixedExpenses ?? this.fixedExpenses,
      additionalAmounts: additionalAmounts ?? this.additionalAmounts,
    );
  }
}

class ExpenseFailureState extends ExpenseState {
  final String errorMessage;
  ExpenseFailureState(this.errorMessage);
}

// BLOC
class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final GetExpensesStreamUseCase getExpensesStreamUseCase;
  final AddExpenseUseCase addExpenseUseCase;
  final DeleteExpenseUseCase deleteExpenseUseCase;

  final GetFixedExpensesStreamUseCase getFixedExpensesStreamUseCase;
  final AddFixedExpenseUseCase addFixedExpenseUseCase;
  final UpdateFixedExpenseUseCase updateFixedExpenseUseCase;
  final DeleteFixedExpenseUseCase deleteFixedExpenseUseCase;

  final GetAdditionalAmountsStreamUseCase getAdditionalAmountsStreamUseCase;
  final AddAdditionalAmountUseCase addAdditionalAmountUseCase;
  final UpdateAdditionalAmountUseCase updateAdditionalAmountUseCase;
  final DeleteAdditionalAmountUseCase deleteAdditionalAmountUseCase;

  StreamSubscription<List<ExpenseEntity>>? _expensesSubscription;
  StreamSubscription<List<FixedExpenseEntity>>? _fixedExpensesSubscription;
  StreamSubscription<List<AdditionalAmountEntity>>? _additionalAmountsSubscription;

  List<ExpenseEntity> _latestExpenses = [];
  List<FixedExpenseEntity> _latestFixedExpenses = [];
  List<AdditionalAmountEntity> _latestAdditionalAmounts = [];

  ExpenseBloc({
    required this.getExpensesStreamUseCase,
    required this.addExpenseUseCase,
    required this.deleteExpenseUseCase,
    required this.getFixedExpensesStreamUseCase,
    required this.addFixedExpenseUseCase,
    required this.updateFixedExpenseUseCase,
    required this.deleteFixedExpenseUseCase,
    required this.getAdditionalAmountsStreamUseCase,
    required this.addAdditionalAmountUseCase,
    required this.updateAdditionalAmountUseCase,
    required this.deleteAdditionalAmountUseCase,
  }) : super(ExpenseInitialState()) {
    on<LoadExpensesEvent>(_onLoadExpenses);
    on<ExpensesUpdatedEvent>(_onExpensesUpdated);
    on<FixedExpensesUpdatedEvent>(_onFixedExpensesUpdated);
    on<AdditionalAmountsUpdatedEvent>(_onAdditionalAmountsUpdated);
    on<AddExpenseSubmittedEvent>(_onAddExpenseSubmitted);
    on<DeleteExpenseSubmittedEvent>(_onDeleteExpenseSubmitted);
    on<AddFixedExpenseSubmittedEvent>(_onAddFixedExpenseSubmitted);
    on<UpdateFixedExpenseSubmittedEvent>(_onUpdateFixedExpenseSubmitted);
    on<DeleteFixedExpenseSubmittedEvent>(_onDeleteFixedExpenseSubmitted);
    on<AddAdditionalAmountSubmittedEvent>(_onAddAdditionalAmountSubmitted);
    on<UpdateAdditionalAmountSubmittedEvent>(_onUpdateAdditionalAmountSubmitted);
    on<DeleteAdditionalAmountSubmittedEvent>(_onDeleteAdditionalAmountSubmitted);
  }

  void _onLoadExpenses(LoadExpensesEvent event, Emitter<ExpenseState> emit) {
    emit(ExpenseLoadingState());
    _expensesSubscription?.cancel();
    _fixedExpensesSubscription?.cancel();
    _additionalAmountsSubscription?.cancel();

    _expensesSubscription = getExpensesStreamUseCase(event.userId).listen(
      (expenses) => add(ExpensesUpdatedEvent(expenses)),
      onError: (error) => emit(ExpenseFailureState(error.toString())),
    );

    _fixedExpensesSubscription = getFixedExpensesStreamUseCase(event.userId).listen(
      (fixedExpenses) => add(FixedExpensesUpdatedEvent(fixedExpenses)),
      onError: (error) => emit(ExpenseFailureState(error.toString())),
    );

    final now = DateTime.now();
    _additionalAmountsSubscription = getAdditionalAmountsStreamUseCase(
      event.userId,
      now.month,
      now.year,
    ).listen(
      (amounts) => add(AdditionalAmountsUpdatedEvent(amounts)),
      onError: (error) => emit(ExpenseFailureState(error.toString())),
    );
  }

  void _onExpensesUpdated(ExpensesUpdatedEvent event, Emitter<ExpenseState> emit) {
    _latestExpenses = event.expenses;
    emit(ExpenseLoadedState(
      expenses: _latestExpenses,
      fixedExpenses: _latestFixedExpenses,
      additionalAmounts: _latestAdditionalAmounts,
    ));
  }

  void _onFixedExpensesUpdated(FixedExpensesUpdatedEvent event, Emitter<ExpenseState> emit) {
    _latestFixedExpenses = event.fixedExpenses;
    emit(ExpenseLoadedState(
      expenses: _latestExpenses,
      fixedExpenses: _latestFixedExpenses,
      additionalAmounts: _latestAdditionalAmounts,
    ));
  }

  void _onAdditionalAmountsUpdated(
      AdditionalAmountsUpdatedEvent event, Emitter<ExpenseState> emit) {
    _latestAdditionalAmounts = event.additionalAmounts;
    emit(ExpenseLoadedState(
      expenses: _latestExpenses,
      fixedExpenses: _latestFixedExpenses,
      additionalAmounts: _latestAdditionalAmounts,
    ));
  }

  Future<void> _onAddExpenseSubmitted(
    AddExpenseSubmittedEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    final currentState = state;
    try {
      await addExpenseUseCase(event.expense);
      // Success: Firestore stream listener auto-updates via ExpensesUpdatedEvent
    } catch (e) {
      emit(ExpenseFailureState(e.toString()));
      if (currentState is ExpenseLoadedState) {
        emit(currentState);
      }
    }
  }

  Future<void> _onDeleteExpenseSubmitted(
    DeleteExpenseSubmittedEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    final currentState = state;
    try {
      await deleteExpenseUseCase(event.userId, event.expenseId);
    } catch (e) {
      emit(ExpenseFailureState(e.toString()));
      if (currentState is ExpenseLoadedState) {
        emit(currentState);
      }
    }
  }

  Future<void> _onAddFixedExpenseSubmitted(
    AddFixedExpenseSubmittedEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      await addFixedExpenseUseCase(event.fixedExpense);
    } catch (e) {
      emit(ExpenseFailureState(e.toString()));
    }
  }

  Future<void> _onUpdateFixedExpenseSubmitted(
    UpdateFixedExpenseSubmittedEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      await updateFixedExpenseUseCase(event.fixedExpense);
    } catch (e) {
      emit(ExpenseFailureState(e.toString()));
    }
  }

  Future<void> _onDeleteFixedExpenseSubmitted(
    DeleteFixedExpenseSubmittedEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      await deleteFixedExpenseUseCase(event.userId, event.fixedExpenseId);
    } catch (e) {
      emit(ExpenseFailureState(e.toString()));
    }
  }

  Future<void> _onAddAdditionalAmountSubmitted(
    AddAdditionalAmountSubmittedEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    final currentState = state;
    try {
      await addAdditionalAmountUseCase(event.additionalAmount);
      // Stream listener will auto-update via AdditionalAmountsUpdatedEvent
    } catch (e) {
      emit(ExpenseFailureState(e.toString()));
      if (currentState is ExpenseLoadedState) {
        emit(currentState);
      }
    }
  }

  Future<void> _onUpdateAdditionalAmountSubmitted(
    UpdateAdditionalAmountSubmittedEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    final currentState = state;
    try {
      await updateAdditionalAmountUseCase(event.additionalAmount);
    } catch (e) {
      emit(ExpenseFailureState(e.toString()));
      if (currentState is ExpenseLoadedState) {
        emit(currentState);
      }
    }
  }

  Future<void> _onDeleteAdditionalAmountSubmitted(
    DeleteAdditionalAmountSubmittedEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    final currentState = state;
    try {
      await deleteAdditionalAmountUseCase(event.userId, event.additionalAmountId);
    } catch (e) {
      emit(ExpenseFailureState(e.toString()));
      if (currentState is ExpenseLoadedState) {
        emit(currentState);
      }
    }
  }

  @override
  Future<void> close() {
    _expensesSubscription?.cancel();
    _fixedExpensesSubscription?.cancel();
    _additionalAmountsSubscription?.cancel();
    return super.close();
  }
}
