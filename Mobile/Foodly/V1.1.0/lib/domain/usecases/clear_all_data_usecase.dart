import '../repositories/user_repository.dart';

/// Use case for clearing all locally persisted Foodly data and resetting to initial state.
class ClearAllDataUseCase {
  final UserRepository repository;

  const ClearAllDataUseCase(this.repository);

  Future<void> execute() async {
    await repository.clearAllData();
  }
}
