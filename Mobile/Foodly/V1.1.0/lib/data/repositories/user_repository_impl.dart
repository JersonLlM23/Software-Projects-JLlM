import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/local_data_source.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final LocalDataSource _localDataSource;

  UserRepositoryImpl(this._localDataSource);

  @override
  Future<User?> getUser() async {
    final userModel = await _localDataSource.getUser();
    return userModel?.toEntity();
  }

  @override
  Future<void> saveUser(User user) async {
    final userModel = UserModel.fromEntity(user);
    await _localDataSource.saveUser(userModel);
  }

  @override
  Future<void> clearAllData() async {
    await _localDataSource.clearAllUserData();
  }
}
