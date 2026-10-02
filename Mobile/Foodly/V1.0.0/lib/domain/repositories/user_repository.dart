import '../entities/user.dart';

/// Contract for User persistence and retrieval.
abstract class UserRepository {
  Future<User?> getUser();
  Future<void> saveUser(User user);
}
