import 'package:pocki/domain/entities/user_entity.dart';
import 'package:pocki/domain/repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository _repository;
  GetCurrentUserUseCase(this._repository);

  UserEntity? call() => _repository.currentUser;
}

class GetInitialUserUseCase {
  final AuthRepository _repository;
  GetInitialUserUseCase(this._repository);

  Future<UserEntity?> call() => _repository.getInitialUser();
}

class LoginUseCase {
  final AuthRepository _repository;
  LoginUseCase(this._repository);

  Future<UserEntity> call(String email, String password) {
    return _repository.login(email, password);
  }
}

class RegisterUseCase {
  final AuthRepository _repository;
  RegisterUseCase(this._repository);

  Future<UserEntity> call({
    required String name,
    required String nickname,
    required String email,
    required String phone,
    required String password,
  }) {
    return _repository.register(
      name: name,
      nickname: nickname,
      email: email,
      phone: phone,
      password: password,
    );
  }
}

class LogoutUseCase {
  final AuthRepository _repository;
  LogoutUseCase(this._repository);

  Future<void> call() => _repository.logout();
}

class UpdateUserProfileUseCase {
  final AuthRepository _repository;
  UpdateUserProfileUseCase(this._repository);

  Future<void> call(UserEntity user) => _repository.updateUserProfile(user);
}
