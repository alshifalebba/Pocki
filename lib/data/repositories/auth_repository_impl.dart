import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase/firebase_data_source.dart';
import '../datasources/local/local_cache_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseDataSource _firebaseDataSource;
  final LocalCacheDataSource _localCacheDataSource;

  UserEntity? _cachedUser;

  AuthRepositoryImpl(this._firebaseDataSource, this._localCacheDataSource);

  @override
  UserEntity? get currentUser => _cachedUser;

  @override
  Stream<UserEntity?> get authUserStream {
    return _firebaseDataSource.authStateChanges.asyncMap((user) async {
      if (user == null) {
        _cachedUser = null;
        await _localCacheDataSource.clearAll();
        return null;
      }
      final profile = await fetchUserProfile(user.uid);
      _cachedUser = profile;
      return profile;
    });
  }

  @override
  Future<UserEntity> login(String email, String password) async {
    final user = await _firebaseDataSource.login(email, password);
    _cachedUser = user;
    await _localCacheDataSource.cacheUser(user);
    return user;
  }

  @override
  Future<UserEntity> register({
    required String name,
    required String nickname,
    required String email,
    required String phone,
    required String password,
  }) async {
    final user = await _firebaseDataSource.register(
      name: name,
      nickname: nickname,
      email: email,
      phone: phone,
      password: password,
    );
    _cachedUser = user;
    await _localCacheDataSource.cacheUser(user);
    return user;
  }

  @override
  Future<void> logout() async {
    await _firebaseDataSource.logout();
    await _localCacheDataSource.clearAll();
    _cachedUser = null;
  }

  @override
  Future<UserEntity?> fetchUserProfile(String uid) async {
    final remote = await _firebaseDataSource.getUserProfile(uid);
    if (remote != null) {
      await _localCacheDataSource.cacheUser(remote);
      _cachedUser = remote;
      return remote;
    }
    final cached = await _localCacheDataSource.getCachedUser();
    if (cached != null) _cachedUser = cached;
    return cached;
  }

  @override
  Future<void> updateUserProfile(UserEntity user) async {
    await _firebaseDataSource.updateUserProfile(user);
    await _localCacheDataSource.cacheUser(user);
    _cachedUser = user;
  }
}
