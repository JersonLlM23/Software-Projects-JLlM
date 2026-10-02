import '../entities/activity_event.dart';
import '../repositories/activity_repository.dart';

class GetActivitiesByDateUseCase {
  final ActivityRepository _repository;

  const GetActivitiesByDateUseCase(this._repository);

  Future<List<ActivityEvent>> execute(DateTime date) {
    return _repository.getActivitiesByDate(date);
  }
}
