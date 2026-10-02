import '../entities/activity_event.dart';

/// Contract for Activity Events persistence and retrieval.
abstract class ActivityRepository {
  Future<List<ActivityEvent>> getAllActivities();
  Future<List<ActivityEvent>> getActivitiesByDate(DateTime date);
  Future<ActivityEvent?> getActivityById(String id);
  Future<void> addActivity(ActivityEvent activity);
  Future<void> updateActivity(ActivityEvent activity);
  Future<void> deleteActivity(String id);
}
