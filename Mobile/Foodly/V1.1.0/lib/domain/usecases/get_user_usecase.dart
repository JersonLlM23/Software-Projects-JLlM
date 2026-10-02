import '../entities/user.dart';
import '../repositories/user_repository.dart';

class GetUserUseCase {
  final UserRepository _repository;

  const GetUserUseCase(this._repository);

  Future<User?> execute() {
    return _repository.getUser();
  }
}
