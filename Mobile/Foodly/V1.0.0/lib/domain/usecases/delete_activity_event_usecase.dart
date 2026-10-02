import '../repositories/activity_repository.dart';

class DeleteActivityEventUseCase {
  final ActivityRepository _repository;

  const DeleteActivityEventUseCase(this._repository);

  Future<void> execute(String id) {
    return _repository.deleteActivity(id);
  }
}
