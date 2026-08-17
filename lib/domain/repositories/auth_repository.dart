import '../../domain/entities/user_entity.dart';

abstract class AuthRepository {
  Stream<UserEntity?> get authUserStream;
  UserEntity? get currentUser;
  Future<UserEntity> login(String email, String password);
  Future<UserEntity> register({
    required String name,
    required String nickname,
    required String email,
    required String phone,
    required String password,
  });
  Future<void> logout();
  Future<UserEntity?> fetchUserProfile(String uid);
  Future<void> updateUserProfile(UserEntity user);
}
