import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/user_entity.dart';
import '../../../../domain/usecases/auth_usecases.dart';

// EVENTS
abstract class AuthEvent {}

class AuthCheckRequestedEvent extends AuthEvent {}

class LoginSubmittedEvent extends AuthEvent {
  final String email;
  final String password;
  LoginSubmittedEvent({required this.email, required this.password});
}

class RegisterSubmittedEvent extends AuthEvent {
  final String name;
  final String nickname;
  final String email;
  final String phone;
  final String password;

  RegisterSubmittedEvent({
    required this.name,
    required this.nickname,
    required this.email,
    required this.phone,
    required this.password,
  });
}

class LogoutRequestedEvent extends AuthEvent {}

class UpdateAuthUserEvent extends AuthEvent {
  final UserEntity user;
  UpdateAuthUserEvent(this.user);
}

// STATES
abstract class AuthState {}

class AuthInitialState extends AuthState {}

class AuthLoadingState extends AuthState {}

class AuthenticatedState extends AuthState {
  final UserEntity user;
  AuthenticatedState(this.user);
}

class UnauthenticatedState extends AuthState {}

class AuthFailureState extends AuthState {
  final String errorMessage;
  AuthFailureState(this.errorMessage);
}

// BLOC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final GetInitialUserUseCase getInitialUserUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
    required this.getInitialUserUseCase,
  }) : super(AuthInitialState()) {
    on<AuthCheckRequestedEvent>(_onAuthCheckRequested);
    on<LoginSubmittedEvent>(_onLoginSubmitted);
    on<RegisterSubmittedEvent>(_onRegisterSubmitted);
    on<LogoutRequestedEvent>(_onLogoutRequested);
    on<UpdateAuthUserEvent>(_onUpdateAuthUser);
  }

  void _onUpdateAuthUser(
    UpdateAuthUserEvent event,
    Emitter<AuthState> emit,
  ) {
    emit(AuthenticatedState(event.user));
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());
    try {
      final user = await getInitialUserUseCase();
      if (user != null) {
        emit(AuthenticatedState(user));
      } else {
        emit(UnauthenticatedState());
      }
    } catch (e) {
      emit(UnauthenticatedState());
    }
  }

  Future<void> _onLoginSubmitted(
    LoginSubmittedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());
    try {
      final user = await loginUseCase(event.email, event.password);
      emit(AuthenticatedState(user));
    } catch (e) {
      emit(AuthFailureState(e.toString()));
    }
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmittedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());
    try {
      final user = await registerUseCase(
        name: event.name,
        nickname: event.nickname,
        email: event.email,
        phone: event.phone,
        password: event.password,
      );
      emit(AuthenticatedState(user));
    } catch (e) {
      emit(AuthFailureState(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());
    await logoutUseCase();
    emit(UnauthenticatedState());
  }
}
