import '../entities/meal.dart';

/// Contract for Meal Events persistence and retrieval.
abstract class MealRepository {
  Future<List<Meal>> getAllMeals();
  Future<List<Meal>> getMealsByDate(DateTime date);
  Future<Meal?> getMealById(String id);
  Future<void> addMeal(Meal meal);
  Future<void> updateMeal(Meal meal);
  Future<void> deleteMeal(String id);
}
