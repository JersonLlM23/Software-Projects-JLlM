import '../entities/user.dart';
import '../repositories/user_repository.dart';

class SaveUserUseCase {
  final UserRepository _repository;

  const SaveUserUseCase(this._repository);

  Future<void> execute(User user) {
    return _repository.saveUser(user);
  }
}
