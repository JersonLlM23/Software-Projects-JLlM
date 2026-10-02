import '../entities/activity_event.dart';
import '../repositories/activity_repository.dart';

class UpdateActivityEventUseCase {
  final ActivityRepository _repository;

  const UpdateActivityEventUseCase(this._repository);

  Future<void> execute(ActivityEvent activity) {
    return _repository.updateActivity(activity);
  }
}
