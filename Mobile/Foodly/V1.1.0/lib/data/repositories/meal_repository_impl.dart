import '../../core/utils/date_time_utils.dart';
import '../../domain/entities/meal.dart';
import '../../domain/repositories/meal_repository.dart';
import '../datasources/local_data_source.dart';
import '../models/meal_model.dart';

class MealRepositoryImpl implements MealRepository {
  final LocalDataSource _localDataSource;

  MealRepositoryImpl(this._localDataSource);

  @override
  Future<List<Meal>> getAllMeals() async {
    final models = await _localDataSource.getMeals();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Meal>> getMealsByDate(DateTime date) async {
    final all = await getAllMeals();
    return all.where((m) => DateTimeUtils.isSameDay(m.dateTime, date)).toList();
  }

  @override
  Future<Meal?> getMealById(String id) async {
    final all = await getAllMeals();
    try {
      return all.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> addMeal(Meal meal) async {
    final all = await getAllMeals();
    all.add(meal);
    final models = all.map((m) => MealModel.fromEntity(m)).toList();
    await _localDataSource.saveMeals(models);
  }

  @override
  Future<void> updateMeal(Meal meal) async {
    final all = await getAllMeals();
    final index = all.indexWhere((m) => m.id == meal.id);
    if (index != -1) {
      all[index] = meal;
      final models = all.map((m) => MealModel.fromEntity(m)).toList();
      await _localDataSource.saveMeals(models);
    }
  }

  @override
  Future<void> deleteMeal(String id) async {
    final all = await getAllMeals();
    all.removeWhere((m) => m.id == id);
    final models = all.map((m) => MealModel.fromEntity(m)).toList();
    await _localDataSource.saveMeals(models);
  }
}
