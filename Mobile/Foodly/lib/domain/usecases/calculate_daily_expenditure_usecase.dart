import '../repositories/activity_repository.dart';

/// Calculates total energy expended (kcal) from recorded activities on a given date.
class CalculateDailyExpenditureUseCase {
  final ActivityRepository _activityRepository;

  const CalculateDailyExpenditureUseCase(this._activityRepository);

  Future<double> execute(DateTime date) async {
    final activities = await _activityRepository.getActivitiesByDate(date);
    return activities.fold<double>(
      0.0,
      (sum, activity) => sum + activity.calculatedEnergyKcal,
    );
  }
}
