import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/user_entity.dart';
import '../../../../domain/usecases/auth_usecases.dart';

// EVENTS
abstract class ProfileEvent {}

class UpdateProfileQuoteEvent extends ProfileEvent {
  final UserEntity currentUser;
  final String newQuote;
  UpdateProfileQuoteEvent({required this.currentUser, required this.newQuote});
}

class UpdateMonthlyBudgetEvent extends ProfileEvent {
  final UserEntity currentUser;
  final double newBudget;
  UpdateMonthlyBudgetEvent({required this.currentUser, required this.newBudget});
}

class UpdateProfileInfoEvent extends ProfileEvent {
  final UserEntity currentUser;
  final String name;
  final String nickname;
  final String phone;
  UpdateProfileInfoEvent({
    required this.currentUser,
    required this.name,
    required this.nickname,
    required this.phone,
  });
}

// STATES
abstract class ProfileState {}

class ProfileInitialState extends ProfileState {}

class ProfileLoadingState extends ProfileState {}

class ProfileUpdatedState extends ProfileState {
  final UserEntity user;
  ProfileUpdatedState(this.user);
}

class ProfileFailureState extends ProfileState {
  final String errorMessage;
  ProfileFailureState(this.errorMessage);
}

// BLOC
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UpdateUserProfileUseCase updateUserProfileUseCase;

  ProfileBloc({required this.updateUserProfileUseCase}) : super(ProfileInitialState()) {
    on<UpdateProfileQuoteEvent>(_onUpdateProfileQuote);
    on<UpdateMonthlyBudgetEvent>(_onUpdateMonthlyBudget);
    on<UpdateProfileInfoEvent>(_onUpdateProfileInfo);
  }

  Future<void> _onUpdateProfileInfo(
    UpdateProfileInfoEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoadingState());
    try {
      final updatedUser = event.currentUser.copyWith(
        name: event.name,
        nickname: event.nickname,
        phone: event.phone,
        updatedAt: DateTime.now(),
      );
      await updateUserProfileUseCase(updatedUser);
      emit(ProfileUpdatedState(updatedUser));
    } catch (e) {
      emit(ProfileFailureState(e.toString()));
    }
  }

  Future<void> _onUpdateProfileQuote(
    UpdateProfileQuoteEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoadingState());
    try {
      final updatedUser = event.currentUser.copyWith(
        quote: event.newQuote,
        updatedAt: DateTime.now(),
      );
      await updateUserProfileUseCase(updatedUser);
      emit(ProfileUpdatedState(updatedUser));
    } catch (e) {
      emit(ProfileFailureState(e.toString()));
    }
  }

  Future<void> _onUpdateMonthlyBudget(
    UpdateMonthlyBudgetEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoadingState());
    try {
      final updatedUser = event.currentUser.copyWith(
        monthlyBudget: event.newBudget,
        updatedAt: DateTime.now(),
      );
      await updateUserProfileUseCase(updatedUser);
      emit(ProfileUpdatedState(updatedUser));
    } catch (e) {
      emit(ProfileFailureState(e.toString()));
    }
  }
}
