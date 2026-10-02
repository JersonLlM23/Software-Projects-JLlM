import '../entities/timeline_event.dart';
import '../repositories/activity_repository.dart';
import '../repositories/meal_repository.dart';

/// Fetches all activity events and meals for a given date, converts them into unified TimelineEvents,
/// and sorts them chronologically by start time.
class GetDailyTimelineUseCase {
  final ActivityRepository _activityRepository;
  final MealRepository _mealRepository;

  const GetDailyTimelineUseCase(
    this._activityRepository,
    this._mealRepository,
  );

  Future<List<TimelineEvent>> execute(DateTime date) async {
    final activities = await _activityRepository.getActivitiesByDate(date);
    final meals = await _mealRepository.getMealsByDate(date);

    final List<TimelineEvent> events = [];

    for (final activity in activities) {
      events.add(TimelineEvent.fromActivity(activity));
    }

    for (final meal in meals) {
      events.add(TimelineEvent.fromMeal(meal));
    }

    // Sort chronologically by start time
    events.sort();

    return events;
  }
}
