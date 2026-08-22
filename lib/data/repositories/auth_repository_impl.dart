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
  Future<UserEntity?> getInitialUser() async {
    final firebaseUser = _firebaseDataSource.currentUser;
    if (firebaseUser == null) {
      _cachedUser = null;
      await _localCacheDataSource.clearAll();
      return null;
    }

    // Try loading cached profile first for fast startup
    final cached = await _localCacheDataSource.getCachedUser();
    if (cached != null && cached.uid == firebaseUser.uid) {
      _cachedUser = cached;
      // Refresh profile asynchronously in background
      fetchUserProfile(firebaseUser.uid);
      return cached;
    }

    // Fetch fresh profile from Firestore
    final remote = await fetchUserProfile(firebaseUser.uid);
    if (remote != null) {
      return remote;
    }

    // Fallback default user if user document doesn't exist in Firestore
    final fallback = UserEntity.defaultUser(firebaseUser.uid, firebaseUser.email ?? '');
    _cachedUser = fallback;
    await _localCacheDataSource.cacheUser(fallback);
    return fallback;
  }

  @override
  Stream<UserEntity?> get authUserStream {
    return _firebaseDataSource.authStateChanges.asyncMap((firebaseUser) async {
      if (firebaseUser == null) {
        _cachedUser = null;
        await _localCacheDataSource.clearAll();
        return null;
      }
      final profile = await fetchUserProfile(firebaseUser.uid);
      if (profile != null) {
        _cachedUser = profile;
        return profile;
      }
      final cached = await _localCacheDataSource.getCachedUser();
      if (cached != null && cached.uid == firebaseUser.uid) {
        _cachedUser = cached;
        return cached;
      }
      final fallback = UserEntity.defaultUser(firebaseUser.uid, firebaseUser.email ?? '');
      _cachedUser = fallback;
      return fallback;
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
    if (cached != null && cached.uid == uid) {
      _cachedUser = cached;
      return cached;
    }
    return null;
  }

  @override
  Future<void> updateUserProfile(UserEntity user) async {
    await _firebaseDataSource.updateUserProfile(user);
    await _localCacheDataSource.cacheUser(user);
    _cachedUser = user;
  }
}
