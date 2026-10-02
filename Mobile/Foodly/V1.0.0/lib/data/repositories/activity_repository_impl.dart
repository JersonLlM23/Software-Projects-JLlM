import '../../core/utils/date_time_utils.dart';
import '../../domain/entities/activity_event.dart';
import '../../domain/repositories/activity_repository.dart';
import '../datasources/local_data_source.dart';
import '../models/activity_event_model.dart';

class ActivityRepositoryImpl implements ActivityRepository {
  final LocalDataSource _localDataSource;

  ActivityRepositoryImpl(this._localDataSource);

  @override
  Future<List<ActivityEvent>> getAllActivities() async {
    final models = await _localDataSource.getActivities();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<ActivityEvent>> getActivitiesByDate(DateTime date) async {
    final all = await getAllActivities();
    return all.where((a) => DateTimeUtils.isSameDay(a.startDateTime, date)).toList();
  }

  @override
  Future<ActivityEvent?> getActivityById(String id) async {
    final all = await getAllActivities();
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> addActivity(ActivityEvent activity) async {
    final all = await getAllActivities();
    all.add(activity);
    final models = all.map((a) => ActivityEventModel.fromEntity(a)).toList();
    await _localDataSource.saveActivities(models);
  }

  @override
  Future<void> updateActivity(ActivityEvent activity) async {
    final all = await getAllActivities();
    final index = all.indexWhere((a) => a.id == activity.id);
    if (index != -1) {
      all[index] = activity;
      final models = all.map((a) => ActivityEventModel.fromEntity(a)).toList();
      await _localDataSource.saveActivities(models);
    }
  }

  @override
  Future<void> deleteActivity(String id) async {
    final all = await getAllActivities();
    all.removeWhere((a) => a.id == id);
    final models = all.map((a) => ActivityEventModel.fromEntity(a)).toList();
    await _localDataSource.saveActivities(models);
  }
}
