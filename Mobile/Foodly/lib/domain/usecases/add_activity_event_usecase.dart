import '../entities/activity_event.dart';
import '../repositories/activity_repository.dart';

class AddActivityEventUseCase {
  final ActivityRepository _repository;

  const AddActivityEventUseCase(this._repository);

  Future<void> execute(ActivityEvent activity) {
    return _repository.addActivity(activity);
  }
}
